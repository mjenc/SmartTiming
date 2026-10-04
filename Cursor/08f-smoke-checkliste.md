# Plan 8f — Smoke-Checkliste Parallelbetrieb & Pipeline

**Zweck:** Einmalig vor Multi-Disziplin-Rollout grün machen.  
**Automatisierte Teile:** Passing-Simulator → „Regel-Tests“ / „Korrektur-Tests“.  
**Manuelle Teile:** Operator am Live- oder Simulator-Decoder.

## Vorbereitung

- [ ] Neue Event-DB aus `CreateSchema.sql` (kein Altbestand).
- [ ] Tx-Mapping geladen (Simulator oder Datei).
- [ ] Mindestens zwei Rennen (z. B. Circuit + ITT) mit disjunkten Chips angelegt.
- [ ] Pro Rennen ≥ 2 Teilnehmer mit Chip-Zuordnung.
- [ ] Automatisierte Self-Tests im Passing-Simulator: beide Buttons **OK**.

## A — Parallele Läufe

| # | Schritt | Erwartung |
|---|---------|-----------|
| A1 | Rennen 1 → Warm-Up, Rennen 2 → Warm-Up | Beide aktiv; keine Fehlermeldung |
| A2 | Beide → Started | Flaggen/Status korrekt je Rennen |
| A3 | Passage mit Chip aus Rennen 1 | Nur in Protokoll/Ranking von Rennen 1 |
| A4 | Passage mit Chip aus Rennen 2 | Nur in Protokoll/Ranking von Rennen 2 |
| A5 | Zeitnahme-Tab zwischen Rennen wechseln | Leere/gefüllte Ranking-Liste ohne Absturz |

## B — No-Duplicate-Chip

| # | Schritt | Erwartung |
|---|---------|-----------|
| B1 | Chip von Fahrer A (Rennen 1, aktiv) dem Fahrer in Rennen 2 zuweisen | Blockiert mit klarer Meldung / Konfliktdialog |
| B2 | Warm-Up für Rennen mit Chip, der schon in anderem aktiven Lauf offen ist | Warm-Up-Konfliktdialog listet Treffer |
| B3 | Rennen 1 → Aborted/Stopped, dann Chip an Rennen 2 vergeben | Zuweisung möglich |

## C — Unzugeordnet / Training

| # | Schritt | Erwartung |
|---|---------|-----------|
| C1 | Passage mit Chip ohne Assignment | „Nicht zugeordnete Transponder“; kein Ranking-Einfluss |
| C2 | Chip später zuweisen | Orphans werden angehängt; Protokoll/Ranking aktualisiert |

## D — MinLap & Plausibilität

| # | Schritt | Erwartung |
|---|---------|-----------|
| D1 | MinLapDuration am Rennen setzen (z. B. 30 s) | Gespeichert |
| D2 | Zwei Hits desselben Chips mit Δt &lt; MinLap | AskOperator-Dialog; Passage zunächst ungültig |
| D3 | Operator „Annehmen“ | Wertung/Protokoll nachgezogen |
| D4 | „Immer akzeptieren“ (MinLap) und erneuter schneller Hit | Auto-Accept; Zähler AlwaysAccepted |

## E — Manuelle Passage

| # | Schritt | Erwartung |
|---|---------|-----------|
| E1 | Manuelle Passage mit gültigem BIB/Chip im aktiven Rennen | Erscheint im Protokoll; Scoring wenn Disposition Accept |
| E2 | Manuelle Passage ohne Zuordnung | Feedback-Meldung; kein falsches Ranking |
| E3 | Passage ungültig setzen / Zeit ändern / entfernen | Cache + DB konsistent; Recalc ohne Absturz |

## F — Restore / Neustart

| # | Schritt | Erwartung |
|---|---------|-----------|
| F1 | App beenden, Event erneut öffnen | Passagen, Unassigned, Flaggen wiederhergestellt |
| F2 | TTT nicht in Combo „neues Rennen“ | Nur ITT / Circuit / Criterium |

## Ergebnis

| Datum | Tester | Automatisierte Tests | Manuelle Checkliste | Bemerkung |
|-------|--------|----------------------|---------------------|-----------|
| 2026-10-04 | Operator | OK | OK | A–F ohne offenen Blocker |

**Definition of Done:** Automatisierte Tests OK **und** A–F ohne offenen Blocker einmal durchgelaufen. — **erreicht** (2026-10-04)
