# Plan 6 — Korrektur-UI fertigstellen

**Priorität:** Mittel  
**Ziel:** Alle Kern-Korrekturpfade persistieren und rechnen neu; keine „Not implemented“-Sackgassen mehr auf dem Hot Path.

## Kontext

Mehrere Dialoge und Menüpunkte existieren, schreiben aber nicht zuverlässig in die DB oder rechnen Participation/Ranking nicht neu:

- Fahrer der Passage ändern (TODO)
- Durchfahrtszeit ändern (öffnet teils falschen Dialog / Stub)
- Strafen, Edit-Zeit: Formulare ohne Persistenz
- `FormAssignCompetitorToTransponder` ohne Logik
- Export CSV/HTML TODO

Neue Disziplinen würden diese Lücken multiplizieren.

## Rahmenbedingungen

- Korrekturen müssen Reload der Event-DB überleben.
- Nach jeder Korrektur: Cache + Protokoll + Participation + Ranking konsistent.
- Transponder-Zuweisung respektiert Parallel-Invariant (Plan 2).

## Scope

- Inventur und Schließen der Stubs in `RaceEngine.Custom`, `FormMain`, Assign-Form
- Persistenz über `TMainDataModule` + Recalc-API
- Menü-Bugs (Zeit vs. Fahrer) bereinigen

## Schritte

1. Inventar aller `TODO` / `ShowMessage('Not implemented…')` auf Korrekturpfaden. — **erledigt** (2026-08-10)
2. Pro Aktion spezifizieren: Dialog → DataModule-Update → Cache → Recalc → UI-Refresh.
3. Transponder zuweisen/entziehen als ersten vollständigen Pfad an Plan 2 anbinden.
4. Passage: Zeit ändern, Fahrer ändern, gültig/ungültig, entfernen.
5. Ranking-Kontextmenü: DNS/DNF/DSQ, Strafen, Zeit editieren → echte `PARTICIPATION`-Updates.
6. Regression ITT: typische Korrekturszenarien manuell/automatisiert prüfen.

## Abhängigkeiten

- Ideal nach [Plan 2](02-chip-zuordnung.md) und [Plan 3](03-rundenprotokoll.md).
- Interim möglich: nur `COMPETITORS.CHIPID` ohne Historie (mit Konflikt-Check für parallele Läufe).

## Akzeptanzkriterien

- Keine „Not implemented“-Meldung auf den Kernkorrekturpfaden.
- Jede genannte Korrektur überlebt Event-Reload.
- Doppelte Chip-Zuweisung parallel bleibt blockiert.

## Risiken

- Halbe Implementierungen (UI schreibt DB, Cache nicht) erzeugen Geisterzustände — immer End-to-End testen.
- Strafen-Format (`PENALTIES` als VARCHAR) unklar dokumentieren.

## Empfohlene Reihenfolge im Gesamtprogramm

Nach oder parallel zu Plan 5; vor produktiver Ausrollung neuer Engines (Plan 1 Fachlogik).

---

## Inventar Schritt 1 (Korrekturpfade)

Stand der Hot-Path-Aktionen in `RaceEngine.Custom` / `FormMain` / zugehörige Forms.

### Ranking-Kontextmenü (`FPopupMenuRanking`)

| Aktion | Handler | Status | Lücke |
|--------|---------|--------|-------|
| Entfernen (Teilnehmer) | `OnRemoveParticipant` | teilweise | DB-Remove + Ranking-Refresh; kein Chip-Assignment schließen? prüfen |
| DNS / DNF / DSQ / Reaktivieren | `OnDNS`/`OnDNF`/`OnDSQ`/`OnActivateParticipant` → `SetParticipantState` | **ok** | Persistenz + Ranking-Refresh vorhanden |
| Strafen | `OnPenalties` | **Stub** | Dialog öffnet, lädt/schreibt `PENALTIES` nicht; Bug: `if not ShowModal = mrOK` |
| Zielzeit ändern | `OnEditTime` | **Stub** | Dialog ohne Vorbelegung aus Selection; keine Persistenz; gleicher Operator-Bug |
| Chip entziehen | `OnUnassignChip` | teilweise | Unassign (Plan 2) ok; kein Ranking-/Protokoll-Refresh |
| Chip-Historie | `OnShowAssignmentHistory` | **ok** | nur Anzeige |
| Rundenprotokoll… | `OnShowCompetitorPassings` | **ok** | Plan 3 |

### Passagen-Kontextmenü (`FPopupMenuPassings`)

| Aktion | Handler | Status | Lücke |
|--------|---------|--------|-------|
| Ungültig / Gültig | `OnInvalidatePassing` / `OnValidatePassing` | **ok** | Status + Recalc + Rebuild |
| Rundenprotokoll… | (wie oben) | **ok** | |
| Fahrer ändern | `OnChangeCompetitorOfTransponder` | teilweise | Assign ok; ListItem-Name aktualisiert; **kein** Recalc der Zeitachse nach Zeit-Korrektur-Muster vollständig? Recalc ja; Passing.RaceId/CompetitorId im Store ggf. nachziehen |
| Durchfahrtszeit ändern | `OnChangePassingTime` | teilweise | DB/Cache-Zeit ok; **kein** `RecalcCountingLaps` / `ReassignLaps` / `RebuildProtocolDisplay` |
| Entfernen | `OnRemovePassing` | teilweise | DB/Cache-Delete + ListItem; **kein** Recalc/Ranking |
| Drag&Drop Zeit | `OnPassingItemDragDrop` | teilweise | UpdatePassing; **kein** Recalc; fragile `lDropItem.Data` |

### Forms / sonstige Korrektur-UI

| Ort | Status | Lücke |
|-----|--------|-------|
| `FormAssignCompetitor` | **ok** (Plan 2) | Auswahl funktioniert; früher Stub ist erledigt |
| `FormPenalty` | Shell only | kein Load/Save |
| `FormEditTime` | UI only | ok als Dialog; Aufrufer müssen persistieren |
| `FormCompetitorPassings` Validate/Invalidate | **ok** | über Engine |
| `FormUnassignedPassings` Assign/Delete | **ok** | Plan 2 |
| `FormMain.MenuItemLoadEventClick` | **Not implemented** | `ShowMessage('Not implemented yet.')` — Event laden |
| `FormMain.PopupMenuCompetitorDeleteClick` | **TODO** | Teilnehmer löschen leer |
| `FormMain.PopupMenuCompetitorAssignToRaceClick` | leer | Untermenü wird dynamisch befüllt; Click-Handler tot (unbenutzt?) |
| `ButtonResultExportCSV` / `HTML` | **TODO** | dauerhaft disabled |
| `TCustomRaceEngine.ExportResultsToCSV` | **Stub** | `lFileName` ungesetzt; `// TODO Write field value` — schreibt nichts Sinnvolles |
| Manuelle Passage (F10) | **ok** | Plan 5 |

### Nicht Korrektur-Hot-Path (Inventar, aber nachrangig)

- `FormMain` ListBox Sorting TODO, Settings TODO, Cache FillPassingListFrom TODO
- Decoder/MyLaps/SmartStarting/Viewer TODOs — außerhalb Plan-6-Scope

---

## Unterschritte (Arbeitsliste nach Inventar)

Abgeleitet aus Schritt 1; Reihenfolge orientiert an Plan-Schritten 2–6.

### A — Spezifikation / gemeinsame Recalc-API (→ Schritt 2)

1. Einheitliches Muster dokumentieren und als Engine-Helfer nutzen:  
   **Dialog → DataModule/Controller-Update → PassingStore/Assignment-Cache → `RecalcCountingLaps` + `ReassignLapsForRace` → `RebuildProtocolDisplay` / `RefreshRankingDisplay`.**
2. Operator-Bug überall fixen: `if Form.ShowModal <> mrOK then Exit` (nicht `if not ShowModal = mrOK`).
3. Kurze Matrix „Aktion → betroffene Tabellen/Caches“ (PASSINGS, PARTICIPATION, TRANSPONDERASSIGNMENTS, PassingStore).

### B — Chip-Zuweisung End-to-End härten (→ Schritt 3)

4. `OnUnassignChip`: nach Erfolg Ranking (+ ggf. Protokoll-Namen) refreshen.
5. `OnChangeCompetitorOfTransponder`: nach Assign `CompetitorId`/`RaceId` im PassingStore setzen; Recalc-Pfad verifizieren (Reload-Test).
6. Optional: Chip **zuweisen** aus Ranking-Menü (nicht nur entziehen), falls im Betrieb benötigt.

### C — Passagen-Korrekturen vervollständigen (→ Schritt 4)

7. `OnChangePassingTime`: nach Update `RecalcCountingLaps` + `ReassignLapsForRace` + `RebuildProtocolDisplay` + Ranking.
8. `OnRemovePassing`: nach Delete dieselbe Recalc-Kette; SYSTEM-Marker nicht löschbar machen.
9. Drag&Drop-Zeitkorrektur: Recalc-Kette; Null-Checks für Drop-Target; Plan-3-Drag&Drop falls noch offen abschließen.
10. Fahrer ändern: Edge Cases (leerer Chip, SYSTEM-Zeile, paralleler Chip-Konflikt) mit klarer Meldung.

### D — Ranking-Korrekturen (→ Schritt 5)

11. `OnPenalties`: aktuelle `PENALTIES` laden → Dialog → `UpdateParticipationValues` → Ranking-Refresh; Format von `PENALTIES` (VARCHAR) kurz spezifizieren.
12. `OnEditTime` (Zielzeit): Selection → aktuelle `FINISHTIME`/`STARTTIME` vorbelegen → persistieren → Ranking-Refresh (und klären: Startzeit vs. Zielzeit vs. manuelle Override-Semantik).
13. DNS/DNF/DSQ: Smoke-Test nach Event-Reload; bei Bedarf Assignment schließen analog Race-Ende.

### E — Randpfade FormMain / Export (Scope-Erweiterung nur wenn Hot Path)

14. `PopupMenuCompetitorDeleteClick`: Implementierung oder Menüpunkt entfernen/disablen.
15. `MenuItemLoadEventClick`: echte Event-Laden-Logik oder Menüpunkt ausblenden bis implementiert.
16. CSV-Export: `ExportResultsToCSV` Dateiname + Feldschreiben fertigstellen; Button verdrahten.
17. HTML-Export: entscheiden (implementieren vs. disabled lassen mit Hinweis).

### F — Regression (→ Schritt 6)

18. ITT-Checkliste manuell: Zeit ändern, Fahrer ändern, ungültig/gültig, löschen, DNS/DNF, Strafen, Chip entziehen — jeweils mit **Event-Reload**.
19. Parallelbetrieb: Chip-Konflikt bleibt blockiert; Korrektur in Lauf B trifft nicht Lauf A.
20. Optional: Self-Test/Smoke-Hooks analog PassingValidator für Recalc-Konsistenz.
