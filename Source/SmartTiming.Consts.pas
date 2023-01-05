unit SmartTiming.Consts;

interface

uses
  Generics.Collections, SysUtils;

const
  // Database
  cStdDataPath = 'd:\projects\SmartTiming\Data\';
  cStdDatabaseName = 'SmartTiming.db';
  cRegKeyPath = 'SOFTWARE\MJ\SmartTiming';

  cNotFound = '<notfound>';

resourcestring
  cRaceTypeNameUnknown = 'Unbestimmt';
  cRaceTypeNameITT = 'Einzelzeitfahren';

  cRaceStatusNotStarted = 'Nicht gestartet';
  cRaceStatusWarmUp = 'Vorbereitung';
  cRaceStatusStarted = 'Gestartet';
  cRaceStatusNeutralized = 'Neutralisiert';
  cRaceStatusFinished = 'Beendet';

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


  cFieldTitleLap = 'Runde';
  cFieldTitlePassingTime = 'Durchgangszeit';
  cFieldTitleGap = 'Abstand';
  cFieldTitleChipID = 'ChipID';

type
  TRaceType = (rtUnknown, rtIndividualTimeTrial, rtTeamTimeTrial);
  TRaceTypes = set of TRaceType;
  TRaceStatus = (rsNotStarted = 0, rsWarmUp, rsStarted, rsNeutralized, rsFinished);


implementation


end.
