# Plan 1 — Race-Engine als Strategie

**Priorität:** Hoch  
**Ziel:** Jede Disziplin steckt in einer Engine-Strategie; Factory, UI und API kennen keine ITT-Sonderfälle mehr.

## Kontext

SmartTiming unterstützt fachlich Rundstreckenrennen, Kriterium, Einzelzeitfahren und Mannschaftszeitfahren. Im Code ist nur das Einzelzeitfahren (`TTimeTrialRaceEngine`) produktiv umgesetzt. `TTeamTimeTrialRaceEngine` ist eine leere Ableitung. Kriterium und Rundstrecke fehlen in Enum, Factory und Ranking-Views.

Die Basisklasse `TCustomRaceEngine` und die Factory `TRaceEngineFactory` sind der richtige Ansatz, aber noch zu dünn befüllt.

## Rahmenbedingungen

- An einem Wettkampftag können **mehrere Läufe parallel** laufen.
- Doppelte Transpondervergabe über parallele Läufe ist verboten (siehe Plan 2).
- ITT-Verhalten als Referenz beibehalten; Event-DBs werden neu aufgesetzt (keine Migrationspflicht).

## Scope

- Enum erweitern: z. B. `rtCircuit` (Rundstrecke), `rtCriterium`, `rtIndividualTimeTrial`, `rtTeamTimeTrial` (und ggf. `rtUnknown`)
- Pro Disziplin eine eigene Unit unter `RaceEngine.*.pas`
- `TRaceEngineFactory` mappt `TRaceType` → Engine
- `FormRaceDetails`: alle Typen wählbar; Felder typabhängig (Laps, Punkte, FirstPassingIsLap, …)
- Gemeinsame Basis `TCustomRaceEngine`: Display, Korrektur-Hooks, Statusmenge, abstraktes Scoring

## Schritte

1. Enum, Anzeigenamen und Factory erweitern; unbekannte/ungültige Typen hart ablehnen. — **erledigt**
   (`rtCircuit`/`rtCriterium` angehängt nach ITT/TTT wegen stabiler Ordinals;
   Factory mappt alle unterstützten Typen; `rtUnknown` → Exception)
2. ITT hinter der bestehenden Implementierung belassen (Referenzverhalten, keine Fachänderung). — **erledigt**
3. Skelette anlegen: `RaceEngine.Circuit`, `RaceEngine.Criterium`, `RaceEngine.TeamTimeTrial` (TTT nicht mehr leere ITT-Ableitung). — **erledigt**
   (gemeinsame Basis `RaceEngine.Skeleton`; Platzhalter-Ranking ohne Scoring; Export/Druck Hinweis)
4. Pro Engine definieren: `AvailableRaceStates`, `UpdateParticipationTable`, Ranking-SQL-Hook. — **teilweise**
   - **AvailableRaceStates:** alle Engines erlauben den vollen Statussatz (ITT/TTT-Einschränkung entfernt).
   - **Circuit:** Scoring + `RANKING_CIRCUIT` / `_BYCLASS` — gleiche Soll-Runden für alle Klassen;
     gemeinsamer Start = grüne Flagge (SYSTEM/`rsStarted`, F5, einmal pro Rennen);
     Flaggenzeiten verschiebbar (Korrektur-UI / Drag&Drop) außer Warm-Up (aktiviert Erfassung);
     nicht COMPETITOR/PARTICIPATION.STARTTIME; erster Fahrer mit Soll-Runden beendet Wertung;
     Ranking nach Runden (Überrundete zurück), dann Zeit.
     **Gesamtranking**; `_BYCLASS` filtert nur nach Klasse und nummeriert Plätze neu
     (keine eigene Wertung/Punkte pro Klasse).
   - **Criterium:** Scoring + `RANKING_CRITERIUM` / `_BYCLASS` (WB Straße § 11.2.3):
     feste Soll-Runden; Sieger = meiste Runden, bei Gleichstand Punkte.
     **Rundengewinn nur per Neue Spitze** (Spitzengruppe = Holdouts, nur wenn jemand
     zurückliegt — sonst NS ohne Holdout-Effekt). Hauptfeld fährt Soll, Überrunder
     enden mit Soll+N. **Verlustrunde:** zurückgefallene/überrundete Einzelne oder
     kleine Gruppen enden mit weniger Runden (wie Circuit), sobald das Hauptfeld Soll
     erreicht. PK → 5/3/2/1 race-weit (Schlussrunde doppelt bei Peak ≥ Soll−1).
     **Gesamtranking**; `_BYCLASS` = Filter der Gesamtordnung nach Klasse (keine neue
     Punktevergabe). Ranking: Runden, Punkte, späterer Punktgewinn.
   - TTT: weiterhin Skeleton (Schritt 4 Rest).
5. Controller und WebService: Ranking nur noch über Engine-API, nicht über hardcodierte View-Namen.
   (teilweise durch Plan 7 abgedeckt — bei neuen Engines prüfen)
6. UI/Factory für neue Typen verdrahten; unbekannte Typen ablehnen (keine DB-Migrationspfade).
   (Combo über `GetSupportedRaceTypes` bereits; typabhängige Felder noch offen)

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
