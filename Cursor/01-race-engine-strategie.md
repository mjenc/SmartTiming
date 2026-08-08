# Plan 1 — Race-Engine als Strategie

**Priorität:** Hoch  
**Ziel:** Jede Disziplin steckt in einer Engine-Strategie; Factory, UI und API kennen keine ITT-Sonderfälle mehr.

## Kontext

SmartTiming unterstützt fachlich Rundstreckenrennen, Kriterium, Einzelzeitfahren und Mannschaftszeitfahren. Im Code ist nur das Einzelzeitfahren (`TTimeTrialRaceEngine`) produktiv umgesetzt. `TTeamTimeTrialRaceEngine` ist eine leere Ableitung. Kriterium und Rundstrecke fehlen in Enum, Factory und Ranking-Views.

Die Basisklasse `TCustomRaceEngine` und die Factory `TRaceEngineFactory` sind der richtige Ansatz, aber noch zu dünn befüllt.

## Rahmenbedingungen

- An einem Wettkampftag können **mehrere Läufe parallel** laufen.
- Doppelte Transpondervergabe über parallele Läufe ist verboten (siehe Plan 2).
- Bestehende ITT-Events müssen ohne Verhaltensänderung weiterlaufen.

## Scope

- Enum erweitern: z. B. `rtCircuit` (Rundstrecke), `rtCriterium`, `rtIndividualTimeTrial`, `rtTeamTimeTrial` (und ggf. `rtUnknown`)
- Pro Disziplin eine eigene Unit unter `RaceEngine.*.pas`
- `TRaceEngineFactory` mappt `TRaceType` → Engine
- `FormRaceDetails`: alle Typen wählbar; Felder typabhängig (Laps, Punkte, FirstPassingIsLap, …)
- Gemeinsame Basis `TCustomRaceEngine`: Display, Korrektur-Hooks, Statusmenge, abstraktes Scoring

## Schritte

1. Enum, Anzeigenamen und Factory erweitern; unbekannte/ungültige Typen hart ablehnen.
2. ITT hinter der bestehenden Implementierung belassen (Referenzverhalten, keine Fachänderung).
3. Skelette anlegen: `RaceEngine.Circuit`, `RaceEngine.Criterium`, `RaceEngine.TeamTimeTrial` (TTT nicht mehr leere ITT-Ableitung).
4. Pro Engine definieren: `AvailableRaceStates`, `UpdateParticipationTable`, Ranking-SQL-Hook.
5. Controller und WebService: Ranking nur noch über Engine-API, nicht über hardcodierte View-Namen.
6. Migration/Kompatibilität: bestehende DBs mit `RACETYPE` prüfen und ggf. mappen.

## Abhängigkeiten

- Ideal parallel mit [Plan 7 — Ranking & Reporting entkoppeln](07-ranking-reporting.md).
- Für korrekte Passage→Rennen-Zuordnung bei Parallelbetrieb: [Plan 2 — Chip-Zuordnung](02-chip-zuordnung.md).

## Akzeptanzkriterien

- Neues Rennen jedes unterstützten Typs ist anlegbar.
- ITT-Regression (Live-Passagen, Ranking, Export) bleibt grün.
- Zwei unterschiedliche Rennypen können parallel `Started` sein.
- Factory wirft nicht bei gültigen Typen; UI zeigt typ-spezifische Status-Flags.

## Risiken

- Flag-Buttons in `FormMain` sind ITT-geprägt — müssen über `AvailableRaceStates` der jeweiligen Engine gesteuert werden.
- Zu frühe Fachlogik in Skelett-Engines ohne Plan 2–4 erzeugt inkonsistente Wertungen.

## Empfohlene Reihenfolge im Gesamtprogramm

Skelette können früh angelegt werden; produktive Fachlogik erst nach Plan 2–4.
