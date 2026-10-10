# Plan 11 — Lieferschein, rad-net-Ergebnisversand, Installer

**Priorität:** Mittel (nach Kern-Timing / Reporting)  
**Ziel:** Veranstalter-Abrechnung der Transponder (Lieferschein), Ergebnis-Übergabe an rad-net, einfache Verteilung von SmartTiming per Setup.

## Kontext

- Excel-Export über `Report.ExcelTemplateFiller` / Engine-`GetResultSQL` ist vorhanden (Ergebnislisten), aber **kein** Abrechnungs-/Lieferschein-Flow.
- Transponder-Nutzung ist über Assignments / Mapping und Starterlisten (Klassen) rekonstruierbar.
- rad-net (BDR-Umfeld) erwartet Ergebnismeldungen — Format/Kanal (Upload-API vs. E-Mail mit Anhang) noch zu klären.
- Auslieferung heute vermutlich manuell (EXE/Ordner); kein gepflegtes Setup-Projekt im Repo ersichtlich.

## Workpackages

| WP | Inhalt |
|----|--------|
| **11a Lieferschein** | Menüpunkt → Excel aus Vorlage mit Event- und Transponder-Zählung (Nachwuchs / Erwachsene) |
| **11b rad-net** | Upload und/oder E-Mail der kompletten Rennergebnisse an rad-net |
| **11c Installer** | Einfaches Installationsprogramm für SmartTiming |

---

## 11a — Lieferschein (Menü)

### Ziel

Dem Veranstalter die **Anzahl eingesetzter Transponder** in Rechnung stellen können. SmartTiming erzeugt dazu einen **Lieferschein** aus einer Excel-Vorlage (Vorlage noch zu erstellen).

### Befüllung (Platzhalter in der Vorlage)

| Feld | Quelle (Richtwert) |
|------|--------------------|
| Organisator | Event-Stammdaten |
| Rennen / Veranstaltung | Event-Titel / Rennnamen |
| Datum | Event- / Renntag |
| Anzahl Transponder Nachwuchs | distinkte eingesetzte Chips, Klassen → Nachwuchs |
| Anzahl Transponder Erwachsene | distinkte eingesetzte Chips, Klassen → Erwachsene |
| optional Summe | Summe beider |

**„Eingesetzte“ Transponder:** sinnvoll = distinkte ChipIds mit Assignment bzw. gewerteter Nutzung am Eventtag (nicht Mapping-Vorrat). Genauigkeit in den Schritten festnageln (nur Assignments vs. Assignments∩Passagen).

**Klassentrennung Nachwuchs / Erwachsene:** Heuristik aus gängigen Klassenbezeichnungen (z. B. `U11`…`U19`, `Jugend`, `Schüler`, `Nachwuchs` vs. `Elite`, `Master`, `Senior`, offene Herren/Damen ohne U-Prefix). Konkrete Regel-Tabelle im Code + Override-Liste; unklare Klassen → Dialog oder „Sonstiges“-Zähler.

### Scope

1. Excel-Vorlage `Lieferschein*.xlsx` (Design/Platzhalter — noch zu erstellen; Ablage z. B. unter Templates neben bestehenden Ergebnis-Vorlagen).
2. Menüpunkt (z. B. unter Berichte/Event): „Lieferschein…“.
3. Datensammlung + Befüllung analog `TExcelFiller` (neues Template-Mapping, keine Ranking-Zeilen).
4. Speichern unter wählbarem Pfad / vorgefülltem Dateinamen.

### Schritte 11a

1. Vorlage entwerfen (Platzhalter-Namen dokumentieren).
2. Zähllogik: distinkte Chips + Klassen→Jugend/Erwachsene (Regelkatalog).
3. Menü + Export-Pfad; Smoke mit Beispieldaten.

### Akzeptanz 11a

- Ein Klick erzeugt eine befüllte xlsx mit Organisator, Datum, Rennhinweis und zwei Mengenzeilen (Nachwuchs/Erwachsene).
- Zählung nachvollziehbar und gegen eine manuelle Stichprobe konsistent.

### Offen

- Exakte Platzhalter-Namen und Layout der Vorlage.
- Ob pro Eventtag eine Datei oder pro Rennen.
- Edge Cases: gleiche Chip mehrfach / Klasse gewechselt.

---

## 11b — Ergebnisse an rad-net (Upload / E-Mail)

### Ziel

Komplette Rennergebnisse an **rad-net** übergeben — per **Upload** und/oder **E-Mail-Versand** (je nach verfügbarer Schnittstelle).

### Scope

1. Klärung mit rad-net/BDR: Pflichtformat (CSV/XML/JSON?), Pflichtfelder, Auth, Endpoint vs. Mailbox.
2. Export der **vollen** Ergebnisdaten (alle Klassen/Wertungen des Rennens bzw. Eventtags — Scope mit Stakeholder festlegen) aus bestehender Engine-API / Excel/CSV.
3. UI: Menü „An rad-net senden…“ mit Vorschau, Zielwahl (Upload / E-Mail), Protokoll (Erfolg/Fehler).
4. E-Mail: MAPI oder SMTP-Konfiguration (Einstellungen); Anhang = vereinbartes Format.
5. Upload: HTTPS-Client, Credentials sicher (nicht hardcodiert; Settings/Credential Store).

### Schritte 11b

1. Spezifikation rad-net (Format + Kanal) einholen — **Blocker für Implementierung**.
2. Export-Adapter auf bestehendes Ranking/Reporting (Plan 7).
3. Versand-UI + Konfiguration; Fehlerfälle (Netz, Auth, Validierung).
4. Smoke gegen Test-Endpoint oder Test-Mailbox.

### Akzeptanz 11b

- Operator kann Ergebnisse in einem Schritt an rad-net übergeben (Upload und/oder Mail laut Spezifikation).
- Fehlschlag ist sichtbar und wiederholbar ohne Datenkorruption.

### Abhängigkeiten

- Plan 7 (Ranking/Export-API) sollte für den gewählten Renntyp greifen.
- Externe Spezifikation rad-net.

### Risiken

- API-Änderungen bei rad-net; Fallback E-Mail mit stabilem Dateiformat.
- Datenschutz / Einwilligung der Teilnehmerdaten beim Versand.

---

## 11c — Einfaches Installationsprogramm

### Ziel

SmartTiming per **einfachem Setup** installieren (nicht nur ZIP mit EXE).

### Scope (MVP)

1. Tool wählen (Empfehlung: **Inno Setup** — üblich für Delphi-Win64, skriptbar, CI-fähig).
2. Installiert: EXE, benötigte DLLs/Runtime, Ressourcen (Icons, Excel-Vorlagen, ggf. `CreateSchema.sql` / Demo-Pfade), Startmenü-/Desktop-Shortcut.
3. Schreiborte: Program Files (App) vs. ProgramData/Documents (Events, Logs, Templates) — klare Trennung, keine DB in Program Files.
4. Deinstallation; optionale Versionsanzeige.
5. Build-Skript/Doku: Setup aus Release-Build erzeugen.

### Nicht im MVP (optional später)

- Auto-Update, Silent-Deploy-MSI für Domänen, Code-Signing (empfohlen sobald Zertifikat da).

### Schritte 11c

1. Dateiliste „was muss auf die Zielmaschine“ (Dependency-Audit).
2. Inno-Skript + Ausgabeordner-Konvention.
3. Smoke-Install auf sauberer VM / zweitem PC.

### Akzeptanz 11c

- Frischer Windows-PC: Setup → Start → Event anlegen / Demo ohne manuelles DLL-Kopieren.

---

## Empfohlene Reihenfolge der WPs

```
11c Installer (Verteilung entkoppelt von Features)
  ↔ 11a Lieferschein (sobald Vorlage steht; nutzt Excel-Pfad wie Reporting)
  → 11b rad-net (nach Spezifikation; baut auf stabilem Export auf)
```

Im Gesamtprogramm: nach Plan 7 (Export-API) und belastbarem Event-Stammdaten-UI; parallel zu Plan 10 möglich.

## Abgrenzung

| | Plan 11 | Plan 7 / bestehende Exporte |
|--|---------|----------------------------|
| Lieferschein | Abrechnung Transponder-Stückzahlen | Ergebnislisten / Ranking-Excel |
| rad-net | Externer Meldeweg | lokaler Excel/CSV/Print/Viewer |
| Installer | Distribution | Build der Anwendung selbst |
