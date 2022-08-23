unit SmartTiming.Consts;

interface

uses
  Generics.Collections, SysUtils;

const
  // Database
  cStdDataPath = '%APPDATA%\MJ\';
  cStdDatabaseName = 'SmartTiming.db';
  cRegKeyPath = 'SOFTWARE\MJ\SmartTiming';

resourcestring
  cRaceTypeNameUnknown = 'Unbestimmt';
  cRaceTypeNameITT = 'Einzelzeitfahren';

  cRaceStatusNotStarted = 'Nicht gestartet';
  cRaceStatusWarmUp = 'Vorbereitung';
  cRaceStatusStarted = 'Gestartet';
  cRaceStatusNeutralized = 'Neutralisiert';
  cRaceStatusFinished = 'Beendet';

type
  TRaceType = (rtUnknown, rtIndividualTimeTrial);
  TRaceTypes = set of TRaceType;
  TRaceStatus = (rsNotStarted = 0, rsWarmUp, rsStarted, rsNeutralized, rsFinished);


implementation


end.
