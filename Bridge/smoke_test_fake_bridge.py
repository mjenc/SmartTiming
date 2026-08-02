#!/usr/bin/env python3
"""Smoke-test the fake Ubidium bridge protocol."""

import json
import socket
import sys
import time

HOST = "127.0.0.1"
PORT = 19503


def read_json(sock: socket.socket, timeout: float = 3.0) -> dict:
    sock.settimeout(timeout)
    buf = b""
    while b"\n" not in buf:
        chunk = sock.recv(4096)
        if not chunk:
            raise RuntimeError("connection closed")
        buf += chunk
    line, _ = buf.split(b"\n", 1)
    return json.loads(line.decode("utf-8"))


def send_json(sock: socket.socket, obj: dict) -> None:
    sock.sendall((json.dumps(obj) + "\n").encode("utf-8"))


def main() -> int:
    with socket.create_connection((HOST, PORT), timeout=3) as sock:
        send_json(sock, {"type": "ping"})
        assert read_json(sock)["type"] == "pong", "ping/pong failed"

        send_json(sock, {"type": "discover"})
        found = read_json(sock)
        assert found["type"] == "decoder_found", found
        assert found["device_id"] == "U-FAKE01", found

        send_json(
            sock,
            {
                "type": "connect",
                "address": found["address"],
                "device_id": found["device_id"],
            },
        )
        assert read_json(sock)["type"] == "connected"

        passing = read_json(sock, timeout=5.0)
        assert passing["type"] == "passing", passing
        assert "chip_id" in passing and "passing_time" in passing

        send_json(sock, {"type": "disconnect"})
        # may receive more passings before disconnected; drain briefly
        deadline = time.time() + 2.0
        saw_disconnect = False
        while time.time() < deadline:
            try:
                msg = read_json(sock, timeout=0.5)
            except (TimeoutError, socket.timeout):
                break
            if msg.get("type") == "disconnected":
                saw_disconnect = True
                break

        print("OK: ping, discover, connect, passing", passing.get("chip_id"))
        if saw_disconnect:
            print("OK: disconnect")
        return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as exc:
        print(f"FAIL: {exc}", file=sys.stderr)
        sys.exit(1)
