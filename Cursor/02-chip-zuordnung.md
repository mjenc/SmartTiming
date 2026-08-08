# Plan 2 — Chip-Zuordnung (zeitlich, parallel-sicher)

**Priorität:** Hoch  
**Ziel:** Transponder können nacheinander wiederverwendet werden; derselbe Chip darf **niemals** parallel zwei Teilnehmern zugeordnet sein.

## Kontext

Heute hängt die Zuordnung an einem aktuellen `COMPETITORS.CHIPID` ohne Historie. „Fahrer ändern“ und `FormAssignCompetitorToTransponder` sind Stubs. Bei mehreren gestarteten Rennen ist `GetRaceIdForPassing` potenziell mehrdeutig („erste SQL-Zeile“).

## Rahmenbedingungen

- **Parallele Läufe** sind First-Class.
- **Keine doppelte Transpondervergabe** über alle aktiven Rennen (`WarmUp` / `Started` / ggf. weitere konfigurierbare Status).
- Am selben Tag darf ein Chip nacheinander verschiedenen Fahrern gehören (nach Ende bzw. explizitem Entzug).

## Scope

- Neue Tabelle z. B. `TRANSPONDERASSIGNMENTS`:
  - `AssignmentId`, `ChipId`, `CompetitorId`
  - `ValidFrom`, `ValidTo` (NULL = aktuell gültig)
  - optional `RaceId` (wenn zuordnung rennbezogen sein soll)
- Invariant: für überlappende Gültigkeitsfenster kein zweites Assignment desselben `ChipId`
- Passage-Lookup über Chip **und** `PassingTime`
- Vergabe-UI und Import prüfen Konflikte gegen alle aktiven Rennen

## Zuordnungslogik einer Passage

1. Chip → höchstens ein aktiver Competitor (zeitliches Assignment).
2. Competitor → höchstens ein gestartetes Rennen (`PARTICIPATION` + Race-Status).
3. Ergebnis: genau ein `(RaceId, CompetitorId)` — oder unzugeordnet / Fehlerstatus.

Bei >1 Treffer: Datenfehler/Alarm (sollte durch Invariant verhindert sein).

## Schritte

1. Schema-Migration in `CreateSchema.sql` bzw. Upgrade-Skript; optional Sync von `COMPETITORS.CHIPID` als „aktuell gültig“.
2. Service/Cache `TTransponderAssignmentStore` (Memory + DB).
3. Assign / Unassign / Transfer-API mit Konfliktprüfung.
4. Passing-Pipeline (`GetRaceIdForPassing` / Controller) auf zeitbasiertes Lookup umstellen.
5. Bei 0 Treffern: Passage ohne Race bzw. Status „unzugeordnet“; bei >1: Alarm.
6. UI: Zuweisen, Entziehen, Historie; Stubs anbinden.
7. Vor Start eines Rennens: Pre-Check „Chip bereits in anderem aktiven Lauf“.

## Abhängigkeiten

- Grundlage für [Plan 3](03-rundenprotokoll.md), [Plan 4](04-plausibilitaet.md), [Plan 5](05-manuelle-passagen.md).
- Schema-Anteil überschneidet sich mit [Plan 8](08-architektur-qualitaet.md) (WP 8a).

## Akzeptanzkriterien

- Chip A bei Fahrer 1 in Lauf 1, nach Ende bei Fahrer 2 in Lauf 2 → Passagen jeweils korrekt zugeordnet.
- Versuch, Chip A parallel Fahrer 3 zuzuweisen → wird blockiert mit klarer Meldung.
- Zwei parallele Läufe mit disjunkten Chips → eindeutige `RaceId` pro Passage.

## Risiken

- Alt-Daten haben nur `COMPETITORS.CHIPID` → Migrationsskript und Fallback nötig.
- UI-Prozesse (Import, Live-Mapping) müssen alle denselben Konflikt-Check nutzen.

## Empfohlene Reihenfolge im Gesamtprogramm

Früh umsetzen (direkt nach schnellen Fixes aus Plan 8).
