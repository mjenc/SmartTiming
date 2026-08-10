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
2. Pro Aktion spezifizieren: Dialog → DataModule-Update → Cache → Recalc → UI-Refresh. — **erledigt**
   (`AfterPassingCorrection` / `AfterRankingCorrection`; Matrix unten)
3. Transponder zuweisen/entziehen als ersten vollständigen Pfad an Plan 2 anbinden. — **erledigt**
   (Unassign + Refresh; Fahrer ändern mit Store-Update + Recalc; Remove schließt Assignment bereits in DataModule)
4. Passage: Zeit ändern, Fahrer ändern, gültig/ungültig, entfernen. — **erledigt**
   (volle Recalc-Kette; SYSTEM geschützt; Drag&Drop mit Recalc)
5. Ranking-Kontextmenü: DNS/DNF/DSQ, Strafen, Zeit editieren → echte `PARTICIPATION`-Updates. — **erledigt**
   (Strafen-Freitext; Zielzeit=`FINISHTIME` + `FINISHTIMEOVERRIDE`; Kommuniqué an Excel/Druck;
   manuelle Zielzeit wird von Recalc nicht überschrieben; „Zurücksetzen“ → Recalc aus Passagen)
6. Regression ITT: typische Korrekturszenarien manuell/automatisiert prüfen. — **erledigt**
   (Self-Tests `TCorrectionRegression.RunSelfTests` im Decoder-Simulator; manuelle Checkliste unten)

### Aktions-Matrix (Schritt 2)

| Aktion | Dialog | Persistenz | Cache | Recalc | UI |
|--------|--------|------------|-------|--------|-----|
| Passagen gültig/ungültig | — | PASSINGS | PassingStore | ja | Protokoll+Ranking |
| Durchfahrtszeit ändern | FormEditTime | PASSINGS | PassingStore | ja | Protokoll+Ranking |
| Fahrer ändern | FormAssign | Assignments | PassingStore CompId | ja | Protokoll+Ranking |
| Passage entfernen | Confirm | PASSINGS DELETE | Store | ja | Protokoll+Ranking |
| Drag&Drop Zeit | — | PASSINGS | Store | ja | Protokoll+Ranking |
| DNS/DNF/DSQ/Aktiv | — | PARTICIPATION | — | — | Ranking |
| Strafen | FormPenalty | PARTICIPATION.PENALTIES | — | — | Ranking (+Kommuniqué Export) |
| Zielzeit ändern | FormEditTime | PARTICIPATION.FINISHTIME + **FINISHTIMEOVERRIDE** | — | bei Reset: ja | Ranking |
| Zielzeit zurücksetzen | FormEditTime „Zurücksetzen“ | OVERRIDE=0, Zeiten NULL | — | Recalc | Ranking |
| Chip entziehen | Confirm | Assignments | Store | ja | Protokoll+Ranking |
| Teilnehmer entfernen | — | PARTICIPATION+Assign close | — | — | Ranking |

## Abhängigkeiten

- Ideal nach [Plan 2](02-chip-zuordnung.md) und [Plan 3](03-rundenprotokoll.md).
- Interim möglich: nur `COMPETITORS.CHIPID` ohne Historie (mit Konflikt-Check für parallele Läufe).

## Akzeptanzkriterien

- Keine „Not implemented“-Meldung auf den Kernkorrekturpfaden.
- Jede genannte Korrektur überlebt Event-Reload.
- Doppelte Chip-Zuweisung parallel bleibt blockiert.

## Risiken

- Halbe Implementierungen (UI schreibt DB, Cache nicht) erzeugen Geisterzustände — immer End-to-End testen.
- **`PENALTIES` (VARCHAR):** Freitext-Kommuniqué des Operators (kein strukturiertes Strafenmodell).
  Beispiel: „Fahrer Max Mustermann #42 erhält 100 € Strafe wegen Beleidigung des Kommissärs.“
  Alle nicht-leeren `PENALTIES` eines Rennens müssen am **Ende des offiziellen Ergebnisses**
  (Druck / Excel / CSV / HTML / Viewer) als Kommuniqué-Block angehängt werden — nicht als Ranking-Spalte mitrechnen.

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
| Strafen | `OnPenalties` | **Stub** | Dialog öffnet, lädt/schreibt `PENALTIES` nicht; Bug: `if not ShowModal = mrOK`; Freitext-Kommuniqué (siehe Risiken) |
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

11. `OnPenalties`: aktuelle `PENALTIES` laden → Memo-Dialog (Freitext) → `UpdateParticipationValues` → Ranking-Refresh.
    Persistenz: ein Freitext pro Participation; leer = kein Kommuniqué-Eintrag.
12. Kommuniqué-Ausgabe: bei offiziellem Ergebnis (Excel/Druck/CSV/HTML/JSON) alle nicht-leeren `PENALTIES`
    des Rennens am Ende anhängen (Überschrift z. B. „Kommuniqué“ / „Strafen“), Reihenfolge stabil (z. B. Bib).
13. `OnEditTime` (Zielzeit): Selection → aktuelle `FINISHTIME`/`STARTTIME` vorbelegen → persistieren → Ranking-Refresh (und klären: Startzeit vs. Zielzeit vs. manuelle Override-Semantik).
14. DNS/DNF/DSQ: Smoke-Test nach Event-Reload; bei Bedarf Assignment schließen analog Race-Ende.

### E — Randpfade FormMain / Export (Scope-Erweiterung nur wenn Hot Path)

15. `PopupMenuCompetitorDeleteClick`: Implementierung oder Menüpunkt entfernen/disablen.
16. `MenuItemLoadEventClick`: echte Event-Laden-Logik oder Menüpunkt ausblenden bis implementiert.
17. CSV-Export: `ExportResultsToCSV` Dateiname + Feldschreiben fertigstellen; Button verdrahten; Kommuniqué-Anhang (siehe 12).
18. HTML-Export: entscheiden (implementieren vs. disabled lassen mit Hinweis); bei Implementierung Kommuniqué-Anhang.

### F — Regression (→ Schritt 6) — **erledigt**

19. ITT-Checkliste manuell: Zeit ändern, Fahrer ändern, ungültig/gültig, löschen, DNS/DNF, Strafen-Freitext + Kommuniqué am Ergebnisende, Chip entziehen — jeweils mit **Event-Reload**.
20. Parallelbetrieb: Chip-Konflikt bleibt blockiert; Korrektur in Lauf B trifft nicht Lauf A.
21. Optional: Self-Test/Smoke-Hooks analog PassingValidator für Recalc-Konsistenz.
    → `SmartTiming.CorrectionRegression` + Button **Korrektur-Regression** im Decoder-Simulator.

### Manuelle ITT-Checkliste (Schritt 6)

Voraussetzung: ITT-Lauf mit ≥2 Teilnehmern, Chip-Zuordnung, einige Passagen; parallel idealerweise zweiter Lauf.

| # | Szenario | Erwartung | Reload |
|---|----------|-----------|--------|
| 1 | Durchfahrtszeit ändern | Ranking/Protokoll neu; DB-Zeit stimmt | ja |
| 2 | Fahrer ändern (Passage) | Name/Race im Protokoll; Ranking neu | ja |
| 3 | Ungültig / wieder gültig | Status + Ranking | ja |
| 4 | Passage löschen | weg aus Protokoll; Ranking; SYSTEM nicht löschbar | ja |
| 5 | DNS / DNF / DSQ / Reaktivieren | Status in Ranking/DB | ja |
| 6 | Strafen-Freitext speichern | `PENALTIES` in DB; Excel/Druck Kommuniqué am Ende | ja |
| 7 | Zielzeit ändern | `FINISHTIME` + Override; Recalc lässt sie stehen; Zurücksetzen → Passagen-Zeit | ja |
| 8 | Chip entziehen | Assignment zu; Protokoll/Ranking Refresh | ja |
| 9 | Parallel: gleicher Chip in Lauf B | Zuweisung/Live blockiert bzw. AskOperator | — |
| 10 | Korrektur nur in Lauf B | Lauf A Ranking unverändert | ja |

Automatisiert (mit geöffnetem Event): Decoder-Simulator → **Korrektur-Regression** (Parallel-Policy, synthetische IDs, PENALTIES-Roundtrip + Kommuniqué-Text).
