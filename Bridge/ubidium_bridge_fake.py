#!/usr/bin/env python3
"""Fake Ubidium bridge for SmartTiming.

Listens on TCP 127.0.0.1:19503 and speaks the JSON-Lines protocol
documented in DecoderInterface.RaceResult.pas.

Usage:
  python ubidium_bridge_fake.py
  python ubidium_bridge_fake.py --port 19503 --interval 2.0

Commands from Delphi:
  ping | discover | connect | disconnect

Events to Delphi:
  pong | decoder_found | connected | disconnected | passing | status | error
"""

from __future__ import annotations

import argparse
import json
import socket
import socketserver
import threading
import time
from datetime import datetime, timezone

DEFAULT_HOST = "127.0.0.1"
DEFAULT_PORT = 19503
FAKE_DEVICE_ID = "U-FAKE01"
FAKE_ADDRESS = "192.168.1.50"
FAKE_FIRMWARE = "fake-1.0"
FAKE_TYPE = "Ubidium"


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.%f")[:-3] + "Z"


class BridgeHandler(socketserver.StreamRequestHandler):
    def setup(self) -> None:
        super().setup()
        self.server: FakeBridgeServer
        self._stop = threading.Event()
        self._emitter: threading.Thread | None = None
        self._passing_number = 0
        self._device_id = FAKE_DEVICE_ID
        peer = self.client_address
        print(f"[+] client connected {peer[0]}:{peer[1]}")

    def finish(self) -> None:
        self._stop_emitter()
        print(f"[-] client disconnected {self.client_address[0]}:{self.client_address[1]}")
        super().finish()

    def send_obj(self, obj: dict) -> None:
        line = json.dumps(obj, separators=(",", ":")) + "\n"
        self.wfile.write(line.encode("utf-8"))
        self.wfile.flush()
        print(f"OUT {line.rstrip()}")

    def _stop_emitter(self) -> None:
        self._stop.set()
        if self._emitter and self._emitter.is_alive():
            self._emitter.join(timeout=2.0)
        self._emitter = None

    def _start_emitter(self) -> None:
        self._stop_emitter()
        self._stop = threading.Event()
        self._emitter = threading.Thread(target=self._emit_loop, daemon=True)
        self._emitter.start()

    def _emit_loop(self) -> None:
        interval = self.server.passing_interval
        while not self._stop.wait(interval):
            try:
                self._passing_number += 1
                chip = f"RR-{100000 + (self._passing_number % 50):06d}"
                self.send_obj(
                    {
                        "type": "passing",
                        "passing_number": self._passing_number,
                        "chip_id": chip,
                        "passing_time": utc_now_iso(),
                        "signal": -40 - (self._passing_number % 20),
                        "decoder_id": self._device_id,
                    }
                )
                if self._passing_number % 3 == 0:
                    self.send_obj(
                        {
                            "type": "status",
                            "noise": 5 + (self._passing_number % 7),
                            "gps": True,
                            "temperature": 34.0 + (self._passing_number % 5),
                            "input_voltage": 12.1,
                            "decoder_id": self._device_id,
                        }
                    )
            except OSError:
                break

    def handle(self) -> None:
        while True:
            raw = self.rfile.readline()
            if not raw:
                break
            line = raw.decode("utf-8", errors="replace").strip()
            if not line:
                continue
            print(f"IN  {line}")
            try:
                msg = json.loads(line)
            except json.JSONDecodeError:
                self.send_obj({"type": "error", "message": "invalid json"})
                continue

            msg_type = msg.get("type")
            if msg_type == "ping":
                self.send_obj({"type": "pong"})
            elif msg_type == "discover":
                self.send_obj(
                    {
                        "type": "decoder_found",
                        "device_id": FAKE_DEVICE_ID,
                        "address": FAKE_ADDRESS,
                        "firmware": FAKE_FIRMWARE,
                        "decoder_type": FAKE_TYPE,
                    }
                )
            elif msg_type == "connect":
                self._device_id = msg.get("device_id") or FAKE_DEVICE_ID
                self.send_obj({"type": "connected", "device_id": self._device_id})
                self._start_emitter()
            elif msg_type == "disconnect":
                self._stop_emitter()
                self.send_obj({"type": "disconnected", "device_id": self._device_id})
            else:
                self.send_obj(
                    {"type": "error", "message": f"unknown type: {msg_type}"}
                )


class FakeBridgeServer(socketserver.ThreadingTCPServer):
    allow_reuse_address = True

    def __init__(self, server_address, handler_class, passing_interval: float):
        super().__init__(server_address, handler_class)
        self.passing_interval = passing_interval


def main() -> None:
    parser = argparse.ArgumentParser(description="Fake Ubidium JSON-Lines bridge")
    parser.add_argument("--host", default=DEFAULT_HOST)
    parser.add_argument("--port", type=int, default=DEFAULT_PORT)
    parser.add_argument(
        "--interval",
        type=float,
        default=2.0,
        help="Seconds between fake passings after connect",
    )
    args = parser.parse_args()

    server = FakeBridgeServer((args.host, args.port), BridgeHandler, args.interval)
    print(f"Fake Ubidium bridge listening on {args.host}:{args.port}")
    print("Waiting for discover / connect ...")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down.")
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
