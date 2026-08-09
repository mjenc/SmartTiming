# Plan 9 — MyLaps-Decoder-Simulator (Test)

**Priorität:** Mittel  
**Ziel:** Ohne Hardware Passagen erzeugen, die denselben Pfad wie Decoder-Hits nehmen — Bedienung über **Transponder-Kurznummern**, Auflösung über die bestehende Mapping-Datei.

## Kontext

Für Tests (Chip-Zuordnung, Unassigned, parallele Läufe) fehlt ein zuverlässiger Ersatz für den MyLaps-Decoder. Es gibt bereits:

- `TDecoderEngine.SendSimulatedPassing` → gleiche Callback-Kette wie Live-Passagen
- Stub `FormPassingSimulator` (Klick auf Starterliste / `CHIPID`, fehlerhaft/`lpAssing`, kaum nutzbar)
- `FormAddPassing` (F10): **Produktions**-Nachtrag über **Bib**, nicht Decoder-Test
- Mapping-Datei `Data/TxMapping.txt`: `Kurznummer<TAB>ChipId` (z. B. `1	CL-11540`), Import über `ImportTxMapping` → `TRANSPONDERS` / `TTransponderMappingStore`
- `TMyLapsP3MessageParser.GetPassingPhrase` für optionale Protokoll-Ebene

## Rahmenbedingungen

- Kurznummer → ChipId **nur** über das bestehende Mapping (Datei wie `TxMapping.txt` / Cache), kein zweites Mapping-Format.
- Simulator ist **Testwerkzeug**, keine Produktions-Passage (Kennzeichnung z. B. `DecoderId = 'STSIM'`).
- Erzeugte Passagen laufen durch Controller → DB → Assignment-Resolve → Race-/Unassigned-UI (wie echte Hits).
- Mapping muss geladen sein (Import beim Start oder explizit im Simulator); unbekannte Kurznummer → klare Fehlermeldung, kein stilles No-Op.
- UI darf den Decoder-Thread nicht blockieren (bei Dialogen: Queue / asynchron, analog Ambiguous-Event).

## Scope

### UI (Kern)

- Formular (bestehenden `FormPassingSimulator` ersetzen/ausbauen):
  - Eingabe **Kurznummer** (Integer), Bestätigung per Enter / Button „Senden“
  - Anzeige der aufgelösten **ChipId** (Vorschau aus Mapping)
  - Optionale Felder: Passing-Zeit (Default `Now`), Signal/Hits mit sinnvollen Defaults
  - Protokoll/Liste der zuletzt gesendeten Passagen (Kurznummer, ChipId, Zeit, PassingNumber)
- Optional später: Mehrfach-Eingabe / kleine Sequenz (Liste von Kurznummern mit Intervall) — nicht Blocker für MVP

### Mapping

- Auflösung: `TTransponderMappingStore.GetTransponderIdFromShortId` bzw. `ConvertToValidChipId`
- Quelle: bereits importiertes Mapping; Verweis auf Beispiel `Data/TxMapping.txt`
- Wenn Cache leer: Hinweis + Shortcut zum Import (wie Main-Menü Tx-Mapping)

### Einspeisung

**Phase A (MVP, empfohlen zuerst):** In-Process über `SendSimulatedPassing`  
→ schnell, deckt Assignment-/UI-Tests ab, nutzt vorhandene Engine.

**Phase B (optional):** Echter MyLaps-P3-Loopback  
- kleiner TCP-Server (Port analog Operating Port `5403`), speist Phrasen aus `GetPassingPhrase`
- `TMyLapsP3Listener` verbindet wie zum echten Decoder
- sinnvoll für Parser-/Listener-Regression; nicht nötig für Plan-2-Fachtests

## Schritte

1. `FormPassingSimulator` bereinigen: Stub-Grid/Typo entfernen oder hinter Tab „Starterliste“ belassen; Fokus-Tab **„Kurznummer“**. — **erledigt**
2. Kurznummer-Eingabe + Mapping-Lookup + Fehlermeldung bei unbekanntem ShortId. — **erledigt**
3. Passing bauen (`PassingNumber` fortlaufend/MAX+1, `ChipId` aus Mapping, `DecoderId='STSIM'`, Defaults Signal/Hits) und über `SendSimulatedPassing` einspeisen. — **erledigt**
4. Kleines Sendeprotokoll in der Form; Mapping-leer-Zustand abfangen (Import-Hinweis). — **erledigt**
5. Menü/Hotkey in `FormMain` prüfen (Simulator erreichbar, ohne Event-DB zu erzwingen außer Mapping). — **erledigt**
6. *(Optional Phase B)* P3-Fake-Decoder + Umschalter „In-Process / P3-Loopback“. — offen

## Abhängigkeiten

- Mapping-Store und `ImportTxMapping` (vorhanden).
- `SendSimulatedPassing` / Controller-Passing-Pipeline (vorhanden; profitiert von Plan 2).
- Phase B: `DecoderInterface.MyLaps` (`GetPassingPhrase`, Ports).

## Abgrenzung

| | Simulator (dieser Plan) | Manuelle Passage (Plan 5 / F10) |
|--|-------------------------|----------------------------------|
| Eingabe | Kurznummer | Bib (+ Rennen) |
| Zweck | Decoder/Test | Operator-Nachtrag |
| Mapping | Pflicht (Short→Chip) | Chip über Assignment/Bib |
| `DecoderId` | `STSIM` (o. ä.) | `MANUAL` |

## Akzeptanzkriterien

- Nach Import von `Data/TxMapping.txt`: Eingabe Kurznummer `1` erzeugt Passage mit ChipId `CL-11540` und erscheint in Passagen-/Ranking- bzw. Unassigned-UI je nach Assignment.
- Unbekannte Kurznummer → Dialog/Hinweis, keine Passage.
- Ohne Mapping → Hinweis zum Import, kein Crash.
- Passage durchläuft denselben Controller-Pfad wie ein Decoder-Hit (Persistenz + Resolve).
- *(Phase B, falls umgesetzt)* App verbindet gegen lokalen Fake-Decoder; gesendete P3-Passage kommt als normaler Listener-Hit an.

## Risiken

- Verwechslung mit F10-Manual-UI → klare Caption („Decoder-Simulator / Test“) und Menü unter Entwicklung/Test.
- Phase B: Port-Konflikte mit echtem Decoder / Firewall — nur Loopback, klar dokumentieren.

## Empfohlene Reihenfolge

Nach Plan 2 (Chip-Pipeline stabil); Phase A unabhängig von Plan 3–7. Phase B bei Bedarf parallel zu Plan 8 (Decoder-Qualität).
