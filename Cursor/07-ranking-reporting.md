# Plan 7 — Ranking & Reporting entkoppeln

**Priorität:** Mittel  
**Ziel:** Keine hardcodierten `RANKING_TIMETRIAL*`-Abhängigkeiten außerhalb der ITT-Engine; Viewer, Export und Print gehen über die Engine-API.

## Kontext

Ranking-SQL, Excel-Templates und HTTP-`/results` sind auf Time-Trial-Views ausgelegt. Neue Disziplinen können so nicht angeschlossen werden, ohne Servlet und UI erneut zu speziellen. Das Grid-Format-Suffix (`.TimeTrial`) zeigt bereits das richtige Muster.

## Rahmenbedingungen

- ITT-Verhalten und bestehende Viewer-Clients bleiben kompatibel.
- Bei Parallelbetrieb liefert jedes Rennen sein eigenes Ranking unabhängig.
- Schema kann disziplinspezifische Views erhalten (`RANKING_CIRCUIT`, …), aber der Aufrufer kennt nur die Engine.

## Scope

- Engine-API: z. B. `GetRankingSQL` / `GetResultSQL` (oder View-Name + Parameter)
- `TSmartTimingServlet` und Excel-Export/Print nutzen diese API
- Neue Views parallel zur Fachlogik der Engines (Plan 1)
- Grid-Format-Provider-Suffix pro Disziplin

## Schritte

1. ITT-Refactor: bestehende Views hinter Engine-Methoden kapseln (Verhalten unverändert). — **erledigt**
   (`GetRankingSQL` / `GetResultSQL` / `GetResultsJsonFieldTitles` auf `TCustomRaceEngine`;
   ITT setzt Format-Strings inkl. optionalem `%3:s`-Filter; UI-Refresh über diese API)
2. Servlet: `RaceId` → RaceItem/Engine → SQL/JSON. — **erledigt**
   (`FillResultResponse` ohne hardcodiertes `RANKING_TIMETRIAL`)
3. Export und Print analog umstellen. — **erledigt**
   (Excel Export/Print + CSV über `GetResultSQL`)
4. Mit Skelett-Engines aus Plan 1: Platzhalter-Ranking (z. B. Laps/Zeit), bis Fachregeln stehen.
5. Views für Circuit/Criterium/TTT anlegen, sobald Scoring definiert ist.

## Abhängigkeiten

- [Plan 1 — Race-Engine als Strategie](01-race-engine-strategie.md).
- Ranking-Views brauchen fachliche Regeln aus den jeweiligen Engines.

## Akzeptanzkriterien

- ITT-RankingViewer und Excel-Export verhalten sich wie zuvor.
- Neuer Renntyp ist ohne Änderung am Servlet-Kern anschließbar (nur neue Engine + View).
- Zwei parallele Rennen → zwei korrekte, unabhängige Rankings.

## Risiken

- Breaking Changes an JSON-API für RankingViewer — Versionierung oder Feldkompatibilität beachten.
- Window-Functions in SQLite-Views sind disziplinspezifisch; nicht eine „Universal-View“ erzwingen.

## Empfohlene Reihenfolge im Gesamtprogramm

Refactor (Schritt 1–3) früh mit Plan 1 Skeletten; neue Views mit Fachlogik der Engines.
