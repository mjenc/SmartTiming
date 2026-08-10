unit SmartTiming.Consts;

interface

uses
  Generics.Collections, SysUtils, System.UITypes, DB;

{$IFDEF MSWINDOWS}
var
  gSmartTimingRoot: string;
  gStdDataPath: string;
  gStdTemplatePath: string;
{$ENDIF}

const
  CRLF = #13#10;

  cManufacturer = 'MJ';
  cSmartStartingAppName = 'SmartStarting';
  cSmartTimingAppName = 'SmartTiming';
  cCopyright = '© Michael Jenc 2024';

  // Database
  cStdDatabaseName = 'SmartTiming.db';
  cCreateSchemaScriptName = 'CreateSchema.sql';

  cRegKeyPath = 'SOFTWARE\' + cManufacturer + '\' + cSmartTimingAppName;

  cNotFound = '<notfound>';

  sSportsIdCycling = 4;

  cColorWarmup     = TColor($FF96FF);
  cColorWarmupDark = TColor($960096);

  cColorStarted     = TColor($96FF96);
  cColorStartedDark = TColor($009600);

  cColorNeutralized     = TColor($FFFF96);
  cColorNeutralizedDark = TColor($FFFF00);

  cColorStopped     = TColor($FF8080);
  cColorStoppedDark = TColor($C80000);

  cColorInactive     = TColor($C8C8C8);
  cColorInactiveDark = TColor($404040);

  cRecalcRankingMilliSeconds = 2000;

  cDefaultDecoderSystemSubnetMasks = '192.168.181.255' + CRLF + '192.168.182.255';

  // WebService
  cWebServicePort = 9768;

  cDefaultListFormatRaces =
    '{"columns":[' +
    '{"Alignment":1,"Fieldname":"RACEID","Visible":true,"Width":25,"Title":"Nr.","Index":0},' +
    '{"Alignment":1,"Fieldname":"EVENTID","Visible":false,"Width":-1,"Index":1},' +
    '{"Alignment":0,"Fieldname":"TITLE","Visible":true,"Width":100,"Title":"Titel","Index":2},' +
    '{"Alignment":0,"Fieldname":"STARTTIME","Visible":true,"Width":120,"Title":"Startzeit","Index":3},' +
    '{"Alignment":0,"Fieldname":"RACETYPE","Visible":true,"Width":120,"Title":"Art","Index":4},' +
    '{"Alignment":1,"Fieldname":"LAPS","Visible":true,"Width":50,"Title":"Runden","Index":5},' +
    '{"Alignment":1,"Fieldname":"DISTANCE","Visible":true,"Width":50,"Title":"Distanz","Index":6},' +
    '{"Alignment":1,"Fieldname":"FIRSTPASSINGISLAP","Visible":true,"Width":145,"Title":"Erste Passage als Runde","Index":7},' +
    '{"Alignment":1,"Fieldname":"MINLAPDURATION","Visible":true,"Width":100,"Title":"Min. Rundenzeit","Index":8},' +
    '{"Alignment":0,"Fieldname":"STATUS","Visible":true,"Width":100,"Title":"Status","Index":9}]}';

  cDefaultListFormatCompetitors =
    '{"columns":[' +
    '{"Alignment":1,"Fieldname":"COMPETITORID","Visible":false,"Width":-1,"Index":0},' +
    '{"Alignment":0,"Fieldname":"CLASS","Visible":true,"Width":64,"Title":"Klasse","Index":1},' +
    '{"Alignment":1,"Fieldname":"BIB","Visible":true,"Width":43,"Title":"Start#","Index":2},' +
    '{"Alignment":0,"Fieldname":"FIRSTNAME","Visible":true,"Width":101,"Title":"Vorname","Index":3},' +
    '{"Alignment":0,"Fieldname":"LASTNAME","Visible":true,"Width":89,"Title":"Nachname","Index":4},' +
    '{"Alignment":0,"Fieldname":"CLUB","Visible":true,"Width":200,"Title":"Verein","Index":5},' +
    '{"Alignment":0,"Fieldname":"TEAM","Visible":true,"Width":200,"Title":"Team","Index":6},' +
    '{"Alignment":0,"Fieldname":"NATIONALITY","Visible":false,"Width":-1,"Title":"Nationalit\u00e4t","Index":7},' +
    '{"Alignment":0,"Fieldname":"NATIONALITYISO","Visible":false,"Width":-1,"Title":"Nat.","Index":8},'+
    '{"Alignment":0,"Fieldname":"UCIID","Visible":true,"Width":90,"Title":"UCI-ID","Index":9},' +
    '{"Alignment":1,"Fieldname":"CHIPID","Visible":true,"Width":50,"Title":"Tx-Id","Index":10},' +
    '{"Alignment":1,"Fieldname":"HANDICAPFACTOR","Visible":false,"Width":-1,"Title":"Handicapfaktor","Index":11},' +
    '{"Alignment":1,"Fieldname":"STARTTIME","Visible":true,"Width":63,"Title":"Startzeit","Index":12},' +
    '{"Alignment":0,"Fieldname":"ADDITIONAL1","Visible":false,"Width":-1,"Title":"Zus\u00e4tzlich 1","Index":13},' +
    '{"Alignment":0,"Fieldname":"ADDITIONAL2","Visible":false,"Width":-1,"Title":"Zus\u00e4tzlich 2","Index":14},' +
    '{"Alignment":0,"Fieldname":"ADDITIONAL3","Visible":false,"Width":-1,"Title":"Zus\u00e4tzlich 3","Index":15}]}';


resourcestring
  cRaceTypeNameUnknown = 'Unbestimmt';
  cRaceTypeNameITT = 'Einzelzeitfahren';
  cRaceTypeNameTTT = 'Mannschaftszeitfahren';
  cRaceTypeNameTTTLocked = 'Mannschaftszeitfahren (nicht verfügbar)';
  cMessagesRaceTypeLocked = 'Mannschaftszeitfahren ist derzeit gesperrt und wird später implementiert.';

  cRaceStatusNotStarted = 'Nicht gestartet';
  cRaceStatusWarmUp = 'Vorbereitung';
  cRaceStatusStarted = 'Gestartet';
  cRaceStatusNeutralized = 'Neutralisiert';
  cRaceStatusFinished = 'Ziel';
  cRaceStatusStopped = 'Gestoppt';
  cRaceStatusAborted = 'Abgebrochen';

  cFlagNameWarmUp = 'Flagge Vorbereitung';
  cFlagNameStart  = 'Flagge Start';
  cFlagNameNeutralize = 'Flagge Neutralisation';
  cFlagNameFinish = 'Flagge Ziel';
  cFlagNameAbort = 'Flagge Abbruch';
  cFlagNameStop = 'Flagge Stopp';

  cFieldTitleBib = 'Start#';
  cFieldTitleClass = 'Klasse';
  cFieldTitleFirstName = 'Vorname';
  cFieldTitleLastName = 'Nachname';
  cFieldTitleClub = 'Verein';
  cFieldTitleTeam = 'Team';
  cFieldTitleNationality = 'Nationalität';
  cFieldTitleUCIID = 'UCI-ID';
  cFieldTitleTransponder = 'Transponder';
  cFieldTitleStartTime = 'Startzeit';
  cFieldTitleHandicapFactor = 'Handicapfaktor';

  cFieldTitleLap = 'Runde';
  cFieldTitlePassingTime = 'Durchgangszeit';
  cFieldTitleGap = 'Abstand';
  cFieldTitleChipID = 'ChipID';
  cFieldTitlePassingStatus = 'Status';
  cFieldTitleLapTime = 'Rundenzeit';
  cFieldTitleSource = 'Quelle';

  cButtonCaptionBackup = 'Sichern';
  cButtonCaptionExport = 'Exportieren';
  cButtonCaptionImport = 'Importieren';

  cMessagesBackupSucceeded = 'Das Datenbank-Backup wurde erfolgreich erstellt.';
  cMessagesBackupFailed = 'Das Erstellen eines Datenbank-Backup ist fehlgeschlagen.';
  cMessagesNoTxMapping = 'Es ist noch keine Transponder-Mapping-Tabelle importiert.'#13#10'Möchten Sie diese nun importieren?';
  cMessagesTxMappingLoaded = 'Es wurden %d Transponder-Mapping-Einträge geladen.';
  cMessagesRaceNotFinishedYet = 'Das Rennen ist noch nicht beendet.';
  cMessagesComptitorDeleteConfirm = '%d Teilnehmer wirklich löschen?';
  cMessagesPassingDeleteConfirm = 'Durchgang von %s wirklich löschen?';
  cMessagesOpenDirectory = 'Verzeichnis öffnen?';
  cMessagesChipIdEmpty = 'Es wurde keine Chip-ID angegeben.';
  cMessagesChipAssignConflict =
    'Chip %s ist bereits zugeordnet (Rennen "%s", Fahrer %s, Status %s).';
  cMessagesChipAssignOk = 'Chip %s wurde dem Teilnehmer zugeordnet.';
  cMessagesChipUnassignOk = 'Chip-Zuordnung wurde beendet.';
  cMessagesChipUnassignNone = 'Für diesen Teilnehmer gibt es keine offene Chip-Zuordnung.';
  cMessagesChipTransferOk = 'Chip %s wurde übertragen.';
  cMessagesPassingAmbiguousAssignment =
    'Mehrdeutige Chip-Zuordnung für %s um %s (%d Treffer) — Passage nicht gewertet.';
  cMessagesCompetitorPassingsTitle = 'Rundenprotokoll — %s';
  cMessagesCompetitorPassingsNone = 'Keine Passagen für diesen Teilnehmer.';
  cMessagesCompetitorPassingsSelectOne = 'Bitte genau einen Teilnehmer auswählen.';
  cMessagesPassingStatusValid = 'Gültig';
  cMessagesPassingStatusInvalid = 'Ungültig';
  cMessagesPassingSourceManual = 'Manuell';
  cMessagesPassingSourceDecoder = 'Decoder';
  cMessagesPassingLapStart = 'Start';
  cMessagesMenuCompetitorPassings = 'Rundenprotokoll…';
  cMessagesProtocolFilterLabel = 'Filter:';
  cMessagesProtocolFilterAll = 'Alle';
  cMessagesProtocolFilterValid = 'Nur gültig';
  cMessagesProtocolFilterManual = 'Nur manuell';
  cMessagesPlausibilityTitle = 'Plausibilitätsprüfung';
  cMessagesPlausibilityHeader =
    'Chip %s um %s'#13#10#13#10'%s';
  cMessagesPlausibilityAlwaysAccept =
    'Für Chip %s MinLap immer annehmen (diese Sitzung)';
  cMessagesPlausibilityAccept = 'Annehmen';
  cMessagesPlausibilityReject = 'Verwerfen';
  cMessagesPlausibilityAcknowledge = 'OK';
  cMessagesPlausibilityStatsHint =
    'Plausibilität: %d verworfen · %d Dialog · %d markiert · %d angenommen · %d Auto';
  cMessagesPlausibilityStatsNone = 'Plausibilität: —';
  cMessagesNoRaceSelectedForAssign =
    'Bitte zuerst ein Rennen in der Zeitmessung auswählen.';
  cMessagesManualPassingPreviewNone = 'Fahrer / Chip';
  cMessagesManualPassingPreviewFmt = '%s · Chip %s';
  cMessagesManualPassingPreviewNoChip = '%s · kein Chip';
  cMessagesManualPassingNoActiveRace =
    'Kein aktives Rennen (Vorbereitung / Gestartet / Neutralisiert) verfügbar.';
  cMessagesManualPassingNoBib =
    'Bitte eine Startnummer eingeben.';
  cMessagesManualPassingBibInvalid =
    '„%s“ ist keine gültige Startnummer.';
  cMessagesManualPassingBibNotInRace =
    'Startnummer %d ist in diesem Rennen nicht gemeldet.';
  cMessagesManualPassingNoChip =
    'Für Startnummer %d (%s) ist kein Chip zugeordnet.'#13#10 +
    'Bitte zuerst eine Chip-Zuordnung vornehmen.';
  cMessagesManualPassingRejected =
    'Manuelle Passage wurde nicht gewertet:'#13#10'%s';
  cMessagesManualPassingPending =
    'Manuelle Passage erfasst — bitte Bestätigung im Plausibilitätsdialog:'#13#10'%s';
  cMessagesManualPassingAssignFailed =
    'Chip %s konnte für den Nachtrag nicht zugeordnet werden:'#13#10'%s';
  cMessagesCommuniqueHeader = 'Kommuniqué';
  cMessagesNoParticipantSelected = 'Bitte einen Teilnehmer im Ranking auswählen.';
  cMessagesPassingIsSystemMarker = 'System-Markierungen können nicht gelöscht oder bearbeitet werden.';
  cMessagesPassingDragSingleOnly =
    'Zeitkorrektur per Drag&Drop ist nur mit einer ausgewählten Passage möglich.';
  cMessagesChangeCompetitorNoChip = 'Diese Passage hat keinen Chip — Fahrer kann nicht geändert werden.';
  cMessagesFinishTimeOverrideHint =
    'Manuelle Zielzeit aktiv — Recalc überschreibt sie nicht. Zurücksetzen stellt die Passagen-Zeit wieder her.';
  cMessagesFinishTimeReset = 'Zurücksetzen';
  cMessagesChipUnassignConfirm = 'Chip-Zuordnung für %d Teilnehmer wirklich beenden?';
  cMessagesAssignmentHistoryEmpty = 'Keine Chip-Zuordnungen für dieses Rennen.';
  cMessagesWarmUpChipConflictsTitle = 'Chip-Konflikte vor Vorbereitung';
  cMessagesWarmUpChipConflictsHint =
    'Folgende Chips sind bereits in einem anderen aktiven Rennen zugeordnet.'#13#10 +
    'Beheben Sie die Konflikte oder setzen Sie die Vorbereitung trotzdem fort.';
  cMessagesWarmUpChipConflictsContinue = 'Trotzdem fortfahren';
  cMessagesWarmUpChipConflictsCancel = 'Abbrechen';
  cMessagesSimulatorMappingEmpty =
    'Es ist kein Transponder-Mapping geladen.'#13#10 +
    'Bitte zuerst eine Mapping-Datei importieren (z. B. Data\TxMapping.txt).';
  cMessagesSimulatorShortIdInvalid = 'Bitte eine gültige Transponder-Kurznummer eingeben.';
  cMessagesSimulatorShortIdUnknown = 'Kurznummer %d ist im Mapping nicht vorhanden.';
  cMessagesSimulatorCaption = 'Decoder-Simulator (Test)';
  cMessagesSimulatorImportMapping = 'Mapping importieren…';
  cMessagesSimulatorSend = 'Senden';
  cMessagesSimulatorMappingCount = 'Mapping: %d Einträge';
  cMessagesSimulatorMappingNone = 'Mapping: leer';
  cMessagesSimulatorRunCorrectionTests = 'Korrektur-Regression';

type
  TRaceType = (rtUnknown, rtIndividualTimeTrial, rtTeamTimeTrial);
  TRaceTypes = set of TRaceType;
  TRaceStatus = (rsNotStarted = 0, rsWarmUp, rsStarted, rsNeutralized, rsFinished, rsAborted, rsStopped);
  TRaceStates = set of TRaceStatus;

const
  cPassingImageValid = 0;
  cPassingImageInvalid = 1;
  cPassingImageManual = 2;
  cPassingImageFlagged = 3;
  cUnassignedPassingsDisplayLimit = 500;
  (* Race statuses that block parallel chip reuse (Plan 2). *)
  cActiveRaceStatusesForChipConflict: TRaceStates = [rsWarmUp, rsStarted, rsNeutralized];
  (* Race statuses that accept scored live passings (legacy: Started only). *)
  cRaceStatusesAcceptingPassings: TRaceStates = [rsStarted];

type
  TFinishStatus = (fsFinished, fsDNS, fsDNF, fsDSQ);
  TNOnGetColumnText = procedure (ASender: TField; var AText: string; ADisplayText: Boolean) of object;

  TParticipantState = (psActive, psDNS, psDNF, psDSQ);
  TPassingState = (psValid = 0, psInvalid);
  (* Plan 3 step 6: protocol list filter. *)
  TPassingProtocolFilter = (ppfAll, ppfValidOnly, ppfManualOnly);

var
  gHInstResDll: HINST = 0;

implementation

{$IFDEF MSWINDOWS}
uses
  Tools.Registry, Windows;
{$ENDIF}

initialization
  {$IFDEF MSWINDOWS}
  gSmartTimingRoot := TToolsRegistry.RegistryReadString(HKEY_CURRENT_USER, cRegKeyPath, 'SmartTimingRoot');
  gStdDataPath := gSmartTimingRoot + 'Data\';
  gStdTemplatePath := gSmartTimingRoot + 'Templates\';
  {$ENDIF}
end.
