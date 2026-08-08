# Plan 6 — Korrektur-UI fertigstellen

**Priorität:** Mittel  
**Ziel:** Alle Kern-Korrekturpfade persistieren und rechnen neu; keine „Not implemented“-Sackgassen mehr auf dem Hot Path.

## Kontext

Mehrere Dialoge und Menüpunkte existieren, schreiben aber nicht zuverlässig in die DB oder rechnen Participation/Ranking nicht neu:

- Fahrer der Passage ändern (TODO)
- Durchfahrtszeit ändern (öffnet teils falschen Dialog / Stub)
- Strafen, Edit-Zeit: Formulare ohne Persistenz
- `FormAssignCompetitorToTransponder` ohne Logik
- Export CSV/HTML TODO

Neue Disziplinen würden diese Lücken multiplizieren.

## Rahmenbedingungen

- Korrekturen müssen Reload der Event-DB überleben.
- Nach jeder Korrektur: Cache + Protokoll + Participation + Ranking konsistent.
- Transponder-Zuweisung respektiert Parallel-Invariant (Plan 2).

## Scope

- Inventur und Schließen der Stubs in `RaceEngine.Custom`, `FormMain`, Assign-Form
- Persistenz über `TMainDataModule` + Recalc-API
- Menü-Bugs (Zeit vs. Fahrer) bereinigen

## Schritte

1. Inventar aller `TODO` / `ShowMessage('Not implemented…')` auf Korrekturpfaden.
2. Pro Aktion spezifizieren: Dialog → DataModule-Update → Cache → Recalc → UI-Refresh.
3. Transponder zuweisen/entziehen als ersten vollständigen Pfad an Plan 2 anbinden.
4. Passage: Zeit ändern, Fahrer ändern, gültig/ungültig, entfernen.
5. Ranking-Kontextmenü: DNS/DNF/DSQ, Strafen, Zeit editieren → echte `PARTICIPATION`-Updates.
6. Regression ITT: typische Korrekturszenarien manuell/automatisiert prüfen.

## Abhängigkeiten

- Ideal nach [Plan 2](02-chip-zuordnung.md) und [Plan 3](03-rundenprotokoll.md).
- Interim möglich: nur `COMPETITORS.CHIPID` ohne Historie (mit Konflikt-Check für parallele Läufe).

## Akzeptanzkriterien

- Keine „Not implemented“-Meldung auf den Kernkorrekturpfaden.
- Jede genannte Korrektur überlebt Event-Reload.
- Doppelte Chip-Zuweisung parallel bleibt blockiert.

## Risiken

- Halbe Implementierungen (UI schreibt DB, Cache nicht) erzeugen Geisterzustände — immer End-to-End testen.
- Strafen-Format (`PENALTIES` als VARCHAR) unklar dokumentieren.

## Empfohlene Reihenfolge im Gesamtprogramm

Nach oder parallel zu Plan 5; vor produktiver Ausrollung neuer Engines (Plan 1 Fachlogik).
