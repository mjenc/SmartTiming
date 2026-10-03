# Plan 8 — Architektur- & Qualitätsthemen

**Priorität:** Mittel (Teilpakete teils sofort)  
**Ziel:** Fundament säubern, damit Pläne 1–7 nicht auf inkonsistenten Annahmen aufbauen.

## Kontext

Neben den Fachlücken gibt es Schema-Unebenheiten (`PASSINGS.CHIPID` als INTEGER vs. String im Code), Cache-/DB-Drift, Stub-Risiken (TTT wählbar ohne Logik) und verdächtige Stellen wie die Race-Listen-Bereinigung in `LoadRaces`. Der Controller bündelt viel Passing-Ingress-Logik.

## Rahmenbedingungen

- Parallele Läufe und No-Duplicate-Chip sind Testfälle für dieses Fundament.
- Änderungen sollen ITT nicht regressieren.
- Kleine, reviewbare Workpackages statt Big-Bang.
- **Keine Schema-Migrationen:** Event-DBs werden immer neu aus `CreateSchema.sql` erzeugt.

## Workpackages

| WP | Inhalt |
|----|--------|
| **8a Schema** | `PASSINGS.CHIPID` als TEXT; Indizes; Assignment-Tabelle — **erledigt** (nur `CreateSchema.sql`, keine Migration) |
| **8b Pipeline** | Passing-Ingress aus Controller in eigenen Service; weniger God-Object — **erledigt** (`TPassingService`: Ingest Live/Manual/SYSTEM, Restore, Update, Remove; Controller = Adapter + Engine-Recalc) |
| **8c Cache** | `UpdatePassing` inkl. Status; `FillPassingListForRaceId` respektiert `OnlyActive` — **erledigt** (atomarer Cache-Update Zeit+Status; OnlyActive war bereits korrekt) |
| **8d Bugs** | `LoadRaces`-Prune prüfen/fixen; TTT in UI sperren, bis Plan 1 TTT liefert — **erledigt** |
| **8e Teams** | Entweder TTT an `TEAMS`/`TEAMMEMBERS` anbinden oder Menü/Typ deaktivieren |
| **8f Tests** | Checkliste/Smoke: Parallelrennen, Chip-Konflikt, MinLap, Manual Passing |

## Schritte

1. **Sofort:** 8d Bugfix + TTT-Sperre.
2. **Früh:** 8a Schema nur in `CreateSchema.sql` (neue DBs).
3. **Mit Plan 3/4:** 8c Cache-Konsistenz für Status/Zeit. — **erledigt**
4. **Iterativ:** 8b PassingService-Extraktion. — **erledigt** (`Ingest` + Restore/Update/Remove)
5. **Vor Multi-Disziplin-Rollout:** 8e klären, 8f Checkliste einmal grün.

## Abhängigkeiten

- 8a überschneidet sich mit [Plan 2](02-chip-zuordnung.md).
- 8c stützt [Plan 3](03-rundenprotokoll.md) und [Plan 4](04-plausibilitaet.md).
- 8e/TTT: TTT-Engine auf spätere Version verschoben; 8e = Typ bleibt gesperrt (siehe 8d), keine TEAMS-Anbindung in diesem Durchgang.

## Akzeptanzkriterien

- Bekannte Inkonsistenzen (CHIPID-Typ, Cache-Status, LoadRaces) sind behoben oder dokumentiert.
- TTT ist nicht „scheinbar wählbar“ ohne Engine.
- Checkliste Parallelbetrieb + No-Duplicate-Chip ist dokumentiert und einmal erfolgreich durchgelaufen.

## Risiken

- Zu große Controller-Extraktion verzögert Features → in kleinen Schnitten.

## Empfohlene Reihenfolge im Gesamtprogramm

```
8d/8a (sofort/früh)
  → Plan 2
  → Plan 4 + 3
  → Plan 5 + 6
  → Plan 1 + 7
  → 8b/8e/8f begleitend bzw. zum Abschluss
```
