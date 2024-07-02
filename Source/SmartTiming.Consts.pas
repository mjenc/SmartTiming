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


  cButtonCaptionBackup = 'Sichern';
  cButtonCaptionExport = 'Exportieren';
  cButtonCaptionImport = 'Importieren';

  cMessagesBackupSucceeded = 'Das Datenbank-Backup wurde erfolgreich erstellt.';
  cMessagesBackupFailed = 'Das Erstellen eines Datenbank-Backup ist fehlgeschlagen.';
  cMessagesNoTxMapping = 'Es ist noch keine Transponder-Mapping-Tabelle importiert.'#13#10'Möchten Sie diese nun importieren?';
  cMessagesRaceNotFinishedYet = 'Das Rennen ist noch nicht beendet.';
  cMessagesComptitorDeleteConfirm = '%d Teilnehmer wirklich löschen?';
  cMessagesPassingDeleteConfirm = 'Durchgang von %s wirklich löschen?';
  cMessagesOpenDirectory = 'Verzeichnis öffnen?';
  cMessagesInvalidTimeFormat = 'Die eingebene Zeit ist ungültig.';

type
  TRaceType = (rtUnknown, rtIndividualTimeTrial, rtTeamTimeTrial);
  TRaceTypes = set of TRaceType;
  TRaceStatus = (rsNotStarted = 0, rsWarmUp, rsStarted, rsNeutralized, rsFinished, rsAborted, rsStopped);
  TRaceStates = set of TRaceStatus;
  TFinishStatus = (fsFinished, fsDNS, fsDNF, fsDSQ);
  TNOnGetColumnText = procedure (ASender: TField; var AText: string; ADisplayText: Boolean) of object;

  TParticipantState = (psActive, psDNS, psDNF, psDSQ);
  TPassingState = (psValid = 0, psInvalid);

var
  gHInstResDll: HINST = 0;

implementation

{$IFDEF MSWINDOWS}
uses
  SmartTiming.Tools, Windows;
{$ENDIF}

initialization
  {$IFDEF MSWINDOWS}
  gSmartTimingRoot := SmartTimingTools.RegistryReadString(HKEY_CURRENT_USER, cRegKeyPath, 'SmartTimingRoot');
  gStdDataPath := gSmartTimingRoot + 'Data\';
  gStdTemplatePath := gSmartTimingRoot + 'Templates\';
  {$ENDIF}
end.
