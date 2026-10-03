# SmartTiming — Umsetzungspläne

Pläne zur Weiterentwicklung von SmartTiming (Mehrdisziplinen, parallele Läufe, Rundenprotokoll, Plausibilität).

**Rahmenbedingungen gesamt**

- Pro Wettkampftag eine SQLite-Datenbank, stets neu aus `CreateSchema.sql` (keine Alt-Daten-Migration).
- Mehrere Rennen parallel möglich.
- Keine doppelte Transpondervergabe über parallele aktive Läufe.
- Transponder nacheinander am Tag wiederverwendbar; Zuordnung rennbezogen.

## Pläne

| Nr | Datei | Titel | Priorität |
|----|--------|--------|-----------|
| 1 | [01-race-engine-strategie.md](01-race-engine-strategie.md) | Race-Engine als Strategie | Hoch |
| 2 | [02-chip-zuordnung.md](02-chip-zuordnung.md) | Chip-Zuordnung (zeitlich, parallel-sicher) | Hoch |
| 3 | [03-rundenprotokoll.md](03-rundenprotokoll.md) | Rundenprotokoll als Domäne | Hoch |
| 4 | [04-plausibilitaet.md](04-plausibilitaet.md) | Plausibilität | Hoch |
| 5 | [05-manuelle-passagen.md](05-manuelle-passagen.md) | Manuelle Passagen absichern | Mittel |
| 6 | [06-korrektur-ui.md](06-korrektur-ui.md) | Korrektur-UI fertigstellen | Mittel |
| 7 | [07-ranking-reporting.md](07-ranking-reporting.md) | Ranking & Reporting entkoppeln | Mittel |
| 8 | [08-architektur-qualitaet.md](08-architektur-qualitaet.md) | Architektur- & Qualitätsthemen | Mittel |
| 8f | [08f-smoke-checkliste.md](08f-smoke-checkliste.md) | Smoke-Checkliste Parallelbetrieb (zu Plan 8) | Mittel |
| 9 | [09-mylaps-decoder-simulator.md](09-mylaps-decoder-simulator.md) | MyLaps-Decoder-Simulator (Test) | Mittel |

## Empfohlene Gesamt-Reihenfolge

1. Plan 8 (Teil: Bugs/Schema)  
2. Plan 2 (Chip / Parallel-Invariant)  
3. Plan 4 + Plan 3 (Plausibilität + Protokoll)  
4. Plan 5 + Plan 6 (Manual + Korrektur-UI)  
5. Plan 1 + Plan 7 (Engines + Ranking-API)  
6. Plan 9 (Decoder-Simulator für Tests; Phase A früh nach Plan 2 sinnvoll)
