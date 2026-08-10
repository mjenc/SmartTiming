# Plan 5 — Manuelle Passagen absichern

**Priorität:** Mittel  
**Ziel:** Nachtrag bei verlorenem oder defektem Transponder ist zuverlässig, rennklar und auditierbar.

## Kontext

`FormAddPassing` (F10) erzeugt Passagen mit `DecoderId='MANUAL'`, funktioniert aber nur, wenn die Bib in einem **gestarteten** Rennen einen Chip hat. `PassingNumber` wird oft 0 gesetzt. Es gibt keine explizite Rennwahl bei Parallelbetrieb und keine gemeinsame Plausibilitätskette.

## Rahmenbedingungen

- Bei mehreren parallelen Läufen muss der Operator das Zielrennen wählen können.
- Manuelle Passagen durchlaufen dieselbe Pipeline wie Decoder-Hits (kein DB-Shortcut).
- Kennzeichnung als manuell im Rundenprotokoll.

## Scope

- UI: Rennwahl, Bib/Fahrer, Zeit (Default: jetzt), optional Chip
- Eindeutige `PassingNumber` (synthetisch negativ; nicht Decoder-`MAX+1`)
- `DecoderId = 'MANUAL'`; Status nach Validator
- Ohne Chip: Assignment (Plan 2) oder explizite Chip-Eingabe

## Schritte

1. `FormAddPassing` erweitern: Race-Combo (relevante Status), Bib-Suche, Zeitedit, Vorschau Fahrer/Chip. — **erledigt**
   (Combo nur aktive Rennen: WarmUp/Started/Neutralized; Default = Rennen des aktuellen Rundenprotokolls/`GetSelectedRaceId`)
2. Ohne aktives Rennen / ohne Zuordnung: klare Fehlermeldung (kein stilles No-Op). — **erledigt**
   (Dialoge für kein aktives Rennen, ungültige/fehlende Bib, Bib nicht im Rennen, kein Chip; OK deaktiviert ohne Rennen)
3. PassingNumber eindeutig vergeben. — **erledigt**
   (Synthetische IDs im negativen Raum via `AllocateSyntheticPassingNumber` = `Min(0, GetMinPassingNumber)-1`;
   Decoder-Sequenz / Lückenerkennung bleibt unangetastet; gilt für MANUAL und SYSTEM-Marker)
4. Validator aus Plan 4 mit Flag `IsManual` aufrufen. — **erledigt**
   (`BuildLiveContext`/`Validate`; MinLap → `pdAcceptMarked`; aktive Rennen inkl. WarmUp/Neutralized;
   Resolve auf gewähltes `RaceId` beschränkt)
5. Im Protokoll (Plan 3) als manuell kennzeichnen. — **erledigt**
   (`TPassing.IsManual`, Icon `cPassingImageManual`, Filter „Nur manuell“)
6. Nach Erfolg: gleiche Display-/Ranking-Aktualisierung wie bei Live-Passagen. — **erledigt**
   (Pipeline `AddPassingForRaceId` → Display/Participation/Ranking; synthetische IDs in `UpdateParticipationTable`)

### Review-Nachzüge (nach Schritt 6)

- `FLastConsideredPassingId := 0` im Recalc (kein negativer Decoder-Cursor → keine Doppelwertung)
- `AddManualPassing` liefert `TManualPassingResult`; UI meldet Reject / Pending
- Legacy-`COMPETITORS.CHIPID` → Auto-Assign vor Resolve
- Manual: kein Timing-Bias; ParallelConflict → `pdAcceptMarked`

## Abhängigkeiten

- [Plan 2](02-chip-zuordnung.md), [Plan 3](03-rundenprotokoll.md), [Plan 4](04-plausibilitaet.md).
- Ohne diese Pläne nur kosmetische UI-Verbesserung.

## Akzeptanzkriterien

- Nachtrag in parallelem Lauf B trifft nur Lauf B.
- Ohne gestartetes/gewähltes Rennen erscheint eine klare Fehlermeldung.
- Nachtrag erscheint im Protokoll und beeinflusst das Ranking (wenn gültig).

## Risiken

- Falsche Default-Zeit / Zeitzone; an Decoder-Bias und UTC/Lokal-Konvention angleichen.
- Missbrauch als „Ergebnis frisieren“ → Audit-Feld und sichtbare Kennzeichnung helfen.

## Empfohlene Reihenfolge im Gesamtprogramm

Nach Plan 2–4, parallel zu Plan 6 möglich.
