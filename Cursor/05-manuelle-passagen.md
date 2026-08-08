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
- Eindeutige `PassingNumber` (Sequence / MAX+1)
- `DecoderId = 'MANUAL'`; Status nach Validator
- Ohne Chip: Assignment (Plan 2) oder explizite Chip-Eingabe

## Schritte

1. `FormAddPassing` erweitern: Race-Combo (relevante Status), Bib-Suche, Zeitedit, Vorschau Fahrer/Chip.
2. Ohne aktives Rennen / ohne Zuordnung: klare Fehlermeldung (kein stilles No-Op).
3. PassingNumber eindeutig vergeben.
4. Validator aus Plan 4 mit Flag `IsManual` aufrufen.
5. Im Protokoll (Plan 3) als manuell kennzeichnen.
6. Nach Erfolg: gleiche Display-/Ranking-Aktualisierung wie bei Live-Passagen.

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
