# Plan 2 — Chip-Zuordnung (zeitlich, parallel-sicher, rennbezogen)

**Priorität:** Hoch  
**Ziel:** Transponder können nacheinander wiederverwendet werden; Zuordnungen sind **rennbezogen**; derselbe Chip darf **niemals** parallel zwei Teilnehmern (über aktive Rennen) zugeordnet sein.

## Kontext

Heute hängt die Zuordnung an einem aktuellen `COMPETITORS.CHIPID` ohne Historie. „Fahrer ändern“ und `FormAssignCompetitorToTransponder` sind Stubs. Bei mehreren gestarteten Rennen ist `GetRaceIdForPassing` potenziell mehrdeutig („erste SQL-Zeile“).

Trainierende Fahrer späterer Rennen können die Ziellinie passieren, ohne im laufenden Rennen zu sein — solche Passagen dürfen die Wertung nicht verfälschen und müssen sichtbar bleiben.

## Rahmenbedingungen

- **Parallele Läufe** sind First-Class.
- **Transponderzuordnungen sind rennbezogen** (`RaceId` ist Pflicht, kein rein globales Assignment).
- **Keine doppelte Transpondervergabe** über alle aktiven Rennen (`WarmUp` / `Started` / ggf. weitere konfigurierbare Status).
- Am selben Tag darf ein Chip nacheinander verschiedenen Fahrern / Rennen gehören (nach Ende bzw. explizitem Entzug).
- Passagen ohne Treffer in einem aktiven Rennen sind erwartbar (Training) und werden separat geführt.
- **Keine DB-Migration:** Event-Datenbanken werden stets neu über `CreateSchema.sql` angelegt. Alt-Daten und Upgrade-Pfade entfallen.

## Scope

- Tabelle `TRANSPONDERASSIGNMENTS` in `CreateSchema.sql`:
  - `AssignmentId`, `ChipId`, `CompetitorId`
  - `RaceId` **NOT NULL** (rennbezogen)
  - `ValidFrom`, `ValidTo` (NULL = aktuell gültig)
- Invariant: kein überlappendes aktives Assignment desselben `ChipId` über parallele/aktive Rennen
- Passage-Lookup über Chip, `PassingTime` und Assignment zum Rennen
- Vergabe-UI und Import prüfen Konflikte gegen alle aktiven Rennen
- Store/UI für **nicht zugeordnete Passagen** (Chip + Uhrzeiten)

## Zuordnungslogik einer Passage

1. Chip + Zeit → aktives rennbezogenes Assignment → `CompetitorId` + `RaceId`.
2. Zusätzlich prüfen: Competitor ist in diesem Rennen in `PARTICIPATION`, Race-Status erlaubt Wertung.
3. Ergebnis:
   - genau ein `(RaceId, CompetitorId)` → Passage dem Rennen zuordnen
   - **0 Treffer** → Passage **nicht** werten; in Liste „Nicht zugeordnete Transponder“ führen (Chip, PassingTime, optional Signal o. Ä.)
   - **>1 Treffer** → Datenfehler/Alarm (sollte durch Invariant verhindert sein)

Typischer 0-Treffer-Fall: Fahrer eines späteren Rennens trainiert und quert die Ziellinie, während ein anderes Rennen läuft.

## Schritte

1. Schema in `CreateSchema.sql` finalisieren (`RaceId` Pflicht, Indizes); bei Bedarf Assignment aus aktueller Chip-Vergabe beim Anlegen der Participation erzeugen.
2. Service/Cache `TTransponderAssignmentStore` (Memory + DB), immer mit `RaceId`.
3. Assign / Unassign / Transfer-API mit Konfliktprüfung (rennübergreifend gegen aktive Status).
4. Passing-Pipeline (`GetRaceIdForPassing` / Controller) auf Assignment-Lookup umstellen.
5. Bei 0 Treffern: Passage nicht dem Rennen zuordnen; in separater Liste **„Nicht zugeordnete Transponder“** mit Uhrzeiten der Passagen führen (und bei Bedarf anzeigen/löschen/später manuell zuordnen). Bei >1 Treffer: Alarm.
6. UI: Zuweisen, Entziehen, Historie (rennbezogen); Stubs anbinden; Ansicht der nicht zugeordneten Passagen.
7. Konflikt-Check beim **Statuswechsel zu Warm-Up**: Prüfung „Chip bereits in anderem aktiven Lauf zugeordnet“; gefundene Treffer in einem **Dialog** anzeigen (Operator entscheidet / behebt, bevor Warm-Up fortgesetzt wird).

## Abhängigkeiten

- Grundlage für [Plan 3](03-rundenprotokoll.md), [Plan 4](04-plausibilitaet.md), [Plan 5](05-manuelle-passagen.md).
- Schema in [Plan 8](08-architektur-qualitaet.md) / `CreateSchema.sql` (Tabelle vorhanden, `RaceId` NOT NULL).

## Akzeptanzkriterien

- Chip A bei Fahrer 1 in Lauf 1, nach Ende bei Fahrer 2 in Lauf 2 → Passagen jeweils korrekt zugeordnet.
- Versuch, Chip A parallel Fahrer 3 (anderes aktives Rennen) zuzuweisen → wird blockiert mit klarer Meldung.
- Zwei parallele Läufe mit disjunkten Chips → eindeutige `RaceId` pro Passage.
- Trainingspassage eines Chips ohne Assignment im laufenden Rennen → erscheint unter „Nicht zugeordnete Transponder“ mit Uhrzeit, ohne Ranking-Einfluss.
- Wechsel auf Warm-Up mit Konflikt → Dialog listet Treffer; Operator sieht Chip/Rennen/Fahrer.

## Risiken

- UI-Prozesse (Import, Live-Mapping) müssen alle denselben Konflikt-Check nutzen.
- Liste nicht zugeordneter Passagen kann bei Dauerbetrieb wachsen → Filter/Limit/Löschen vorsehen.

## Empfohlene Reihenfolge im Gesamtprogramm

Früh umsetzen; Schema nur über neue DBs / `CreateSchema.sql`.
