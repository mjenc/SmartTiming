# Plan 10 — MyLaps P3 Decoder-Protokoll (Resend, Status, Zeit, Fehler, Keepalive)

**Priorität:** Mittel  
**Ziel:** P3-Records über PASSING hinaus sinnvoll nutzen: Lücken nachladen (RESEND), Decoder-Gesundheit (STATUS/ERROR), Uhr-Sync (GET_TIME), Identifikation (VERSION), Verbindungsüberwachung (PING/WATCHDOG).

Capture-Referenz: `TraceProtocols/TraceWithPassingsAndMissedPassingsReload.pcapng`  
Basis im Code: `DecoderInterface.MyLaps` (`GetResendPhrase`, `GetRtcPhrase`, `SendQuery`, STATUS-/VERSION-Parser teilweise vorhanden).

## Workpackages

| WP | TOR | Inhalt | Priorität |
|----|-----|--------|-----------|
| **10a RESEND** | `0x04` | Lückenerkennung → Nachladen → Operator-Dialog Übernehmen/Verwerfen | Hoch (Kern) |
| **10b STATUS** | `0x02` | Noise, Spannung, Temp, GPS-Flag in UI / Warnungen | Hoch |
| **10c GET_TIME** | `0x24` | Periodische/On-Connect RTC-Abfrage; Drift vs. PC prüfen/loggen | Hoch |
| **10d ERROR** | `0xFFFF` | Decoder-Fehlercodes anzeigen/loggen (CRC, TOR unknown, …) | Hoch |
| **10e VERSION** | `0x03` | Typ/Firmware/DecoderId in Statusleiste oder Decoder-Panel | Mittel |
| **10f PING/WATCHDOG** | `0x20` / `0x18` | Keepalive / „verbunden seit …“ / Timeout → reconnect-Hinweis | Mittel |

GPS-Nutzung: siehe Abschnitt unten (kein eigenes WP für `GPS_INFO`/`0x30` nötig, solange STATUS.GPS reicht).

---

## 10a — RESEND (Reread nach Verbindungslücke)

### Kontext

Fortlaufende positive `PassingNumber`s; nach Abbruch zeigt die nächste Live-Passage die Lücke. MANUAL/SYSTEM bleiben negativ und lösen keinen RESEND aus.

Bereits vorhanden (noch nicht verdrahtet): `GetResendPhrase`, `SendQuery`; Hinweis in `AllocateSyntheticPassingNumber`.

### Protokoll (Capture + Parser)

**Request (Host → Decoder), Version 0 — `GetResendPhrase`:**

```
8E 00 1D 00 <CRC> 00 00 04 00
  01 04 <From LE 4>
  02 04 <Until LE 4>   (* inklusiv *)
  81 04 <DecoderId 4>
8F
```

Beispiel: Live `15054` nach letzter `15048` → From=`15049`, Until=`15053`.  
**Antwort:** normale **PASSING**-Records; oft danach RESEND-Echo Version 2 (kein Scoring-Payload).

### Scope 10a

1. Gap-Detector (`PassingNumber > lastSeen+1`) je DecoderId.
2. RESEND für `[lastSeen+1 … current-1]` (Chunking bei großen Lücken, Orbits ~5er-Blöcke).
3. Staging-Buffer — **nicht** still `Ingest`; Dialog Übernehmen/Verwerfen.
4. UI asynchron (Decoder-Thread nicht blockieren).
5. Optional: FakeDecoder beantwortet RESEND (Plan-9-Tests).

### Schritte 10a

1. Protokoll-Notiz + Abgleich Capture. — **erledigt** (2026-10-10)
2. Gap-Detector + RESEND senden.
3. Staging + Timeout/Teillieferung.
4. Operator-Dialog → Ingest oder Verwerfen.
5. Smoke (Capture-Szenario oder FakeDecoder).

### Akzeptanz 10a

- RESEND im Capture-kompatiblen Format; Reload-Hits nur nach Operator-OK in der Pipeline.
- Dedup nach `PassingNumber`; keine RESEND-Trigger durch negative IDs.

---

## 10b — STATUS

Schon geparst (`Noise`, `Gps`, `Temperature`, `InputVoltage`, `DecoderId`) → `TStatusStore` / Callbacks.

**Scope:** stabile Anzeige (Statusleiste oder kleines Decoder-Panel): Noise, Usp., Temp.; Schwellwert-Warnungen (z. B. Spannung niedrig, Noise hoch). GPS-Boolean aus STATUS hier mit anzeigen (siehe GPS unten).

**Akzeptanz:** Operator sieht aktuelle STATUS-Werte ohne Log-Datei; kritische Werte fallen auf.

---

## 10c — GET_TIME

`GetRtcPhrase` existiert; Orbits fragt RTC häufig ab.

**Scope:** nach Connect und periodisch GET_TIME; Decoder-Zeit vs. PC; Drift loggen und bei großem Offset warnen (Timing-Bias / Sync-Hinweis). Kein automatisches Umschreiben von Passagenzeiten ohne Operator-Freigabe.

**Akzeptanz:** Drift sichtbar; Warnung bei auffälligem Offset.

---

## 10d — ERROR

TOR `0xFFFF`; Felder laut P3-Doku: CODE (`0x01`), DESCRIPTION (`0x02`). Codes u. a. CRC, SOR missing, Header corrupt, TOR unknown, Parameters missing, Length too long.

**Scope:** Parser für ERROR; Log + kurze Operator-Meldung (nicht nur still verwerfen).

**Akzeptanz:** simulierte/fehlerhafte Phrasen erzeugen nachvollziehbaren ERROR-Eintrag in UI/Log.

---

## 10e — VERSION

Finder/Parser können Typ/Firmware/Id schon teilweise lesen.

**Scope:** nach Connect VERSION anzeigen (Typ, Firmware, DecoderId); bei Wechsel des aktiven Decoders aktualisieren.

**Akzeptanz:** verbundenes Gerät ist in der UI eindeutig identifizierbar.

---

## 10f — PING / WATCHDOG

Orbits: häufige PINGs; Verbindung „lebt“.

**Scope:** eingehende PING/WATCHDOG als Lebenszeichen; Timeout ohne Traffic → „Verbindung unsicher“ / Reconnect-Hinweis. Optional eigenes Keepalive nur wenn Decoder es erwartet (Capture prüfen, nicht spekulativ spammen).

**Akzeptanz:** längerer Stillstand ohne PASSING wird nicht mit „alles ok“ verwechselt, wenn auch PING ausbleibt.

---

## GPS-Status — wofür?

Im **STATUS**-Record (`Gps` bool, optional `SATINUSE`) bzw. ausführlicher in **GPS_INFO** (`0x30`):

| Verwendung | Nutzen für SmartTiming |
|------------|-------------------------|
| **Zeitqualität** | GPS-Lock ⇒ Decoder-RTC typischerweise zuverlässiger; ohne Lock eher Drift → Warnung vor/während dem Rennen (passt zu 10c). |
| **Operator-Hinweis** | Outdoor: „kein GPS“ = Zeiten ggf. nur relativ/PC-synced; vor Start prüfen. |
| **Diagnose/Log** | Nach Event nachvollziehen, ob Timing unter GPS-Lock lief. |
| **Nicht nötig** | GPS-Koordinaten für Ranking; Schleifen-Geofencing; Navigation. |

**Empfehlung:** GPS nur aus **STATUS** anzeigen/warnen (10b); eigenes Parsing von `GPS_INFO` erst, wenn Status-Flag allein nicht reicht.

---

## Abhängigkeiten & Reihenfolge der WPs

```
10e VERSION (schnell, Connect-UI)
  → 10b STATUS + GPS-Anzeige
  → 10c GET_TIME / Drift
  → 10d ERROR
  → 10f PING/WATCHDOG
  → 10a RESEND (größtes WP; braucht stabilen Listener + SendQuery)
```

Plan 9 (P3-Loopback/FakeDecoder) hilft für Tests ohne Hardware.  
`PassingService.Ingest` nur für übernommene RESEND-Hits und Live-PASSINGs.

## Abgrenzung

| Thema | In Scope | Nicht in Scope |
|-------|----------|----------------|
| Scoring-Pipeline | unverändert für Live; RESEND nur nach Dialog | Orbits-Settings (SESSION, NETWORK, TIMELINE, …) |
| Battery-Check-Lücken | — | lokale `MISSED`-Platzhalter bleiben getrennt |
| GPS | STATUS-Flag + Warnung | Karten, GPS_INFO-Felder (vorerst) |

## Risiken

- RESEND: Überlapp Live/Reload → Dedup; große Lücken → Chunking/Timeout.
- GET_TIME: falsche Auto-Korrektur von Passagenzeiten vermeiden.
- PING: aggressives Polling kann Decoder/andere Clients stören — am Capture orientieren.
- Mehrere TCP-Clients (max. 4) am Decoder.
