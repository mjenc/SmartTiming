unit SmartTiming.Consts;

interface

uses
  Generics.Collections, SysUtils, Graphics, DB;

const
  // Database
  cStdDataPath = 'd:\projects\SmartTiming\Data\';
  cStdDatabaseName = 'SmartTiming.db';
  cCreateSchemaScriptName = 'CreateSchema.sql';
  cStdTemplatePath = 'd:\projects\SmartTiming\Templates\';

  cRegKeyPath = 'SOFTWARE\MJ\SmartTiming';

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

type
  TRaceType = (rtUnknown, rtIndividualTimeTrial, rtTeamTimeTrial);
  TRaceTypes = set of TRaceType;
  TRaceStatus = (rsNotStarted = 0, rsWarmUp, rsStarted, rsNeutralized, rsFinished, rsAborted, rsStopped);
  TRaceStates = set of TRaceStatus;

  TNOnGetColumnText = procedure (ASender: TField; var AText: string; ADisplayText: Boolean) of object;

implementation


end.
