# Plan 4 — Plausibilität

**Priorität:** Hoch  
**Ziel:** Zentrale Regeln für verdächtige Passagen; `MinLapDuration` wird durchgesetzt; kritische Fälle können per Dialog bestätigt werden.

## Kontext

`MINLAPDURATION` wird in `RACES` gespeichert und in der UI editiert, aber in der Wertungslogik nicht geprüft. Es gibt keinen Plausibilitätsdialog. Doppelpassagen, Hits außerhalb des Live-Fensters oder unbekannte Chips können still falsch oder gar nicht landen.

## Rahmenbedingungen

- Parallele Läufe: eine Passage darf nie im „falschen“ Lauf landen, wenn die Vergabe korrekt ist (Plan 2).
- Chip-Konflikt (gleicher Chip aktiv in zwei Läufen) ist harte Warnung / Datenfehler.
- Verhalten konfigurierbar: annehmen / annehmen+markieren / ungültig / blockierender Dialog.

## Scope

- Komponente `TPassingValidator` (oder Engine-Methode) mit Regelkatalog
- Regeln (Mindestumfang):
  - unbekannter Chip
  - Chip nicht dem Rennen/Teilnehmer zugeordnet
  - Race nicht im wertenden Status
  - Δt zur letzten gültigen Passage &lt; `MinLapDuration`
  - Doppelhit / identische Zeit
  - Chip-Konflikt über parallele aktive Rennen
- Ergebnis schreibt `PASSINGSTATUS` und steuert, ob `UpdateParticipationTable` läuft

### Regelkatalog (Schritt 1)

| Regel | Enum | Default-Disposition |
|-------|------|---------------------|
| Unbekannter Chip (nicht im Tx-Mapping) | `pvrUnknownChip` | `pdReject` |
| Keine eindeutige Zuordnung | `pvrNotAssigned` | `pdReject` |
| Rennen nimmt keine Wertung an | `pvrRaceNotAccepting` | `pdReject` |
| Δt &lt; MinLapDuration | `pvrMinLapDuration` | `pdAskOperator` |
| Doppelhit (Δt ≤ 0) | `pvrDoubleHit` | `pdReject` |
| Mehrdeutige Assignment-Treffer | `pvrAmbiguousAssignment` | `pdAskOperator` |
| Chip parallel in anderem aktiven Rennen | `pvrParallelChipConflict` | `pdAskOperator` |

Implementierung: `Source/SmartTiming.PassingValidator.pas` (reine Kontext-Evaluation).  
Self-Tests: `TPassingValidator.RunCatalogSelfTests` — aufrufbar im Decoder-Simulator („Regelkatalog testen“).

## Schritte

1. Regelkatalog spezifizieren und mit Fake-Passings testen. — **erledigt**
2. Einbindung nach Race-/Fahrer-Zuordnung, vor Participation-Update. — **erledigt**
3. `MinLapDuration` aus `TRaceItem` lesen und anwenden. — **erledigt**
   (`GetMinLapDurationForRace`: RaceList/`TRaceItem.MinLapDuration`, Fallback DB; Validator wendet Δt-Regel an)
4. Dialog für kritische Fälle; optional „für diesen Chip immer annehmen“.
5. Logging und UI-Hinweis (z. B. Zähler verworfener/markierter Passagen).

## Abhängigkeiten

- [Plan 2](02-chip-zuordnung.md) für Chip/Race-Eindeutigkeit.
- [Plan 3](03-rundenprotokoll.md) für Anzeige und Bearbeitung des Status.
- Wird von [Plan 5](05-manuelle-passagen.md) mitgenutzt (`IsManual`-Flag).

## Akzeptanzkriterien

- Doppelpassage innerhalb `MinLapDuration` → ungültig oder Dialog; Ranking unverändert bei Verwerfen.
- Passage bei gestopptem/nicht live Rennen → nicht gewertet.
- Parallelbetrieb: bei korrekter Vergabe keine Cross-Race-Wertung.

## Risiken

- Zu aggressive Regeln blockieren den Betrieb → Defaults vorsichtig, Settings nötig.
- Dialoge auf dem Decoder-Thread vermeiden (immer Main-Thread / Queue).

## Empfohlene Reihenfolge im Gesamtprogramm

Nach Plan 2, zusammen mit Plan 3.
