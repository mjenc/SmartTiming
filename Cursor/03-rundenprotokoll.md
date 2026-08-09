# Plan 3 — Rundenprotokoll als Domäne

**Priorität:** Hoch  
**Ziel:** Die Passagen-Anzeige wird zum echten Rundenprotokoll; Passagen und Rundenzeiten einzelner Teilnehmer sind in einem Dialog prüfbar.

## Kontext

Die `TListView` der RaceEngine ist de facto das Rundenprotokoll, aber ohne Domänenmodell „Runde N von Fahrer X“. `PASSINGSTATUS` existiert in der DB, ist im `TPassing`-Record/Cache aber kaum abgebildet. Invalidate/Validate führen nicht zuverlässig zur Neuberechnung. Drag&Drop schreibt Zeiten grob um (−1 ms).

## Rahmenbedingungen

- Protokoll ist **rennbezogen** (bei Parallelbetrieb: Panel/Engine pro Rennen).
- Manuelle und Decoder-Passagen müssen unterscheidbar sein.
- Ungültig setzen einer Passage muss Laps/Ranking aktualisieren.

## Scope

- Domänenobjekt: Passage mit optional `LapIndex`, `CompetitorId`, `PassingStatus`
- `TPassing` um Status erweitern; Cache und DB synchron halten
- Dialog pro Teilnehmer: chronologische Passagen, Rundenzeiten (Δt), gültig/ungültig, manuell markiert
- Neuberechnung der `PARTICIPATION` nach Status- oder Zeitänderung

## Schritte

1. `PASSINGSTATUS` durchgängig machen (Record, Cache, UI-Icons). — **erledigt**
   (`LapIndex`/`CompetitorId` im Memory; Icons via `SmallImages` + CustomDraw; Manual erkennbar)
2. Engine-Hook `AssignLap(APassing)`; für ITT: Lap = Zählung gültiger Passagen (`FirstPassingIsLap` beachten). — **erledigt**
3. Dialog `FormCompetitorPassings` (öffenbar aus Ranking oder Protokoll). — **erledigt**
4. Invalidate/Validate → DB + Cache + `RecalculateParticipation`. — **erledigt**
   (`SetPassingStatusAndRecalc` → UpdatePassing + RecalcCountingLaps + ReassignLaps)
5. Drag&Drop-Zeitkorrektur ersetzen oder stark einschränken (explizite Zeitkorrektur bevorzugen).
6. Filter im Protokoll: nur gültig / alle / nur manuell.

## Abhängigkeiten

- [Plan 2 — Chip-Zuordnung](02-chip-zuordnung.md) für korrekte Fahrerzuordnung.
- [Plan 4 — Plausibilität](04-plausibilitaet.md) setzt Status, den das Protokoll anzeigt.
- Korrekturpfade in [Plan 6](06-korrektur-ui.md) nutzen dasselbe Recalc.

## Akzeptanzkriterien

- Operator sieht Rundenzeiten eines Fahrers und kann eine Passage ungültig setzen → Laps und Ranking aktualisieren sich.
- Manuelle vs. Decoder-Passagen sind erkennbar.
- Bei parallelen Läufen bleibt jedes Protokoll rennbezogen und vermischt keine Passagen.

## Risiken

- Uneinheitliche ListView- vs. Memo-Pfade in `TCustomRaceEngine` / TimeTrial — vor dem Dialog bereinigen.
- Recalc-Performance bei vielen Passagen; ggf. nur betroffene Competitor/Race neu berechnen.

## Empfohlene Reihenfolge im Gesamtprogramm

Nach Plan 2, ideal parallel oder direkt vor/mit Plan 4.
