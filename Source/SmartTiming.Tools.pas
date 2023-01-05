unit SmartTiming.Tools;

interface

uses
  Classes, SysUtils, DateUtils, Windows,
  Registry, DBGrids, Controls, Graphics,
  Generics.Defaults, UITypes, DB,
  uSuperObject, SmartTiming.Consts, RaceEngine.Custom;

type
  SmartTimingTools = class
    class function RegistryReadString(aRootKey: HKEY; const aPath, aKey: string; aDefault: String = ''): String;
    class procedure RegistryWriteString(aRootKey: HKEY; const aPath, aKey: string; aValue: String);
    class function RegistryReadBool(aRootKey: HKEY; const aPath, aKey: string; aDefault: boolean = false): boolean;
    class procedure RegistryWriteBool(aRootKey: HKEY; const aPath, aKey: string; aValue: Boolean);
    class function ReadLastOpenedDatabaseFromRegistry: string;
    class procedure SaveExportDirectory(const ADir: string);
    class function LoadExportDirectory: string;
    class function ReadTimingBiasFromRegistry: integer;
    class function GetRaceTypeEnumFromString(const AValue: string): TRaceType;
    class function GetRaceTypeStringFromEnum(ARaceType: TRaceType): string;
    class function GetRaceStatusEnumFromString(const AValue: string): TRaceStatus;
    class function GetRaceStatusStringFromEnum(ARaceStatus: TRaceStatus): string;
    class function GetColorForRaceStatus(ARaceStatus: TRaceStatus): TColor;
    class procedure FillRaceItemFromDataSet(AParent: TWinControl; ADataSet: TDataSet; ARaceItem: TRaceItem);
  end;

  TRaceEngineFactory = class
    class function CreateRaceEngineForRaceType(AParent: TWinControl; ARaceItem: TRaceItem): TCustomRaceEngine;
  end;

implementation

uses
  RaceEngine.TimeTrial;

{==============================================================================}
class function SmartTimingTools.RegistryReadString(aRootKey: HKEY; const aPath, aKey: string; aDefault: String = ''): String;
var
  lReg : TRegistry;
  lRegDataType: TRegDataType;
begin
  result := aDefault;
  lReg := TRegistry.Create(KEY_QUERY_VALUE);
  try
    lReg.RootKey := aRootKey;
    if not lReg.OpenKeyReadOnly(aPath) then
      Exit;
    if not lReg.ValueExists(aKey) then
      Exit;

    lRegDataType := lReg.GetDataType(aKey);
    if not (lRegDataType in [rdString, rdExpandString]) then
      Exit;

    Result := lReg.ReadString(aKey);
  finally
    FreeAndNil(lReg);
  end;
end;

{==============================================================================}
class procedure SmartTimingTools.RegistryWriteString(aRootKey: HKEY; const aPath, aKey: string; aValue: String);
var
  lReg : TRegistry;
begin
  lReg := TRegistry.Create;
  try
    lReg.RootKey := aRootKey;
    if lReg.OpenKey(aPath, true) then
      lReg.WriteString(aKey, aValue);
  finally
    FreeAndNil(lReg);
  end;
end;

{==============================================================================}
class function SmartTimingTools.RegistryReadBool(aRootKey: HKEY; const aPath, aKey: string; aDefault: boolean = false): boolean;
var
  lReg : TRegistry;
  lRegDataType: TRegDataType;
begin
  lReg := TRegistry.Create(KEY_QUERY_VALUE);
  try
    lReg.RootKey := aRootKey;
    if not lReg.OpenKeyReadOnly(aPath) then
      Exit(aDefault);
    if not lReg.ValueExists(aKey) then
      Exit(aDefault);

    lRegDataType := lReg.GetDataType(aKey);
    if not (lRegDataType in [rdInteger]) then
      Exit(aDefault);

    Result := lReg.ReadInteger(aKey) <> 0;
  finally
    FreeAndNil(lReg);
  end;
end;

{==============================================================================}
class procedure SmartTimingTools.RegistryWriteBool(aRootKey: HKEY; const aPath, aKey: string; aValue: Boolean);
var
  lReg : TRegistry;
begin
  lReg := TRegistry.Create;
  try
    lReg.RootKey := aRootKey;
    if lReg.OpenKey(aPath, true) then
    begin
      if aValue then
        lReg.WriteInteger(aKey, 1)
      else
        lReg.WriteInteger(aKey, 0);
    end;
  finally
    FreeAndNil(lReg);
  end;
end;

{==============================================================================}
class function SmartTimingTools.ReadLastOpenedDatabaseFromRegistry: string;
begin
  result := RegistryReadString(HKEY_CURRENT_USER, cRegKeyPath, 'LastUsedDatabase', cStdDataPath);
end;

{==============================================================================}
class procedure SmartTimingTools.SaveExportDirectory(const ADir: string);
begin
  RegistryWriteString(HKEY_CURRENT_USER, cRegKeyPath, 'ExportDir', ADir);
end;

{==============================================================================}
class function SmartTimingTools.LoadExportDirectory: string;
begin
  result := RegistryReadString(HKEY_CURRENT_USER, cRegKeyPath, 'ExportDir', cStdDataPath + cStdDatabaseName);
end;

{==============================================================================}
class function SmartTimingTools.ReadTimingBiasFromRegistry: integer;
var
  s: string;
begin
  s := RegistryReadString(HKEY_CURRENT_USER, cRegKeyPath, 'TimingBias', '0');
  result := s.ToInteger;
end;

{==============================================================================}
class function SmartTimingTools.GetRaceTypeEnumFromString(const AValue: string): TRaceType;
begin
  if SameText(cRaceTypeNameITT, AValue) then
    Exit(rtIndividualTimeTrial);
  result := rtUnknown;
end;

{==============================================================================}
class function SmartTimingTools.GetRaceTypeStringFromEnum(ARaceType: TRaceType): string;
begin
  case ARaceType of
  rtIndividualTimeTrial:
    result := cRaceTypeNameITT;
  else
    result := cRaceTypeNameUnknown;
  end;
end;

{==============================================================================}
class function SmartTimingTools.GetRaceStatusEnumFromString(const AValue: string): TRaceStatus;
begin
  result := rsNotStarted;
  if SameText(cRaceStatusWarmUp, AValue) then
    Exit(rsWarmUp);
  if SameText(cRaceStatusStarted , AValue) then
    Exit(rsStarted);
  if SameText(cRaceStatusNeutralized, AValue) then
    Exit(rsNeutralized);
  if SameText(cRaceStatusFinished, AValue) then
    Exit(rsFinished);
end;

{==============================================================================}
class function SmartTimingTools.GetRaceStatusStringFromEnum(ARaceStatus: TRaceStatus): string;
begin
  result := '';
  case ARaceStatus of
  rsNotStarted:
    Exit(cRaceStatusNotStarted);
  rsWarmUp:
    Exit(cRaceStatusWarmUp);
  rsStarted:
    Exit(cRaceStatusStarted);
  rsNeutralized:
    Exit(cRaceStatusNeutralized);
  rsFinished:
    Exit(cRaceStatusFinished);
  end;
end;

{==============================================================================}
class function SmartTimingTools.GetColorForRaceStatus(ARaceStatus: TRaceStatus): TColor;
begin
  result := clWindow;
  case ARaceStatus of
  rsNotStarted:
    Exit;
  rsWarmUp:
    Exit($D7A6D7);
  rsStarted:
    Exit($87E061);
  rsNeutralized:
    Exit($91E4FF);
  rsFinished:
    Exit(TColors.Lightgrey);
  end;
end;

{==============================================================================}
class procedure SmartTimingTools.FillRaceItemFromDataSet(AParent: TWinControl; ADataSet: TDataSet; ARaceItem: TRaceItem);
begin
  ARaceItem.Id := ADataSet.FieldByName('RACEID').AsInteger;
  ARaceItem.RaceType := TRaceType(ADataSet.FieldByName('RACETYPE').AsInteger);
  ARaceItem.StartTime := ADataSet.FieldByName('STARTTIME').AsFloat;
  ARaceItem.Title := ADataSet.FieldByName('TITLE').AsString;
  ARaceItem.Laps := ADataSet.FieldByName('LAPS').AsInteger;
  ARaceItem.Distance := ADataSet.FieldByName('DISTANCE').AsFloat;
  ARaceItem.FirstPassingIsLap := ADataSet.FieldByName('FIRSTPASSINGISLAP').AsInteger <> 0;
  ARaceItem.MinLapDuration := ADataSet.FieldByName('MINLAPDURATION').AsInteger;
  ARaceItem.Status := TRaceStatus(ADataSet.FieldByName('STATUS').AsInteger);
  if ARaceItem.RaceEngine = nil then
    ARaceItem.RaceEngine := TRaceEngineFactory.CreateRaceEngineForRaceType(AParent, ARaceItem);
end;


{==============================================================================}
class function TRaceEngineFactory.CreateRaceEngineForRaceType(AParent: TWinControl; ARaceItem: TRaceItem): TCustomRaceEngine;
begin
  case ARaceItem.RaceType of
  rtIndividualTimeTrial:
    Exit(TTimeTrialRaceEngine.Create(AParent, ARaceItem));
  rtTeamTimeTrial:
    Exit(TTeamTimeTrialRaceEngine.Create(AParent, ARaceItem));
  else
    Exit(TCustomRaceEngine.Create(AParent, ARaceItem));
  end;
end;

end.
