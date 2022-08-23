unit SmartTiming.Tools;

interface

uses
  Windows, SysUtils, DateUtils, Registry,
  SmartTiming.Consts;

type
  SmartTimingTools = class
    class function RegistryReadString(aRootKey: HKEY; const aPath, aKey: string; aDefault: String = ''): String;
    class procedure RegistryWriteString(aRootKey: HKEY; const aPath, aKey: string; aValue: String);
    class function ReadLastOpenedDatabaseFromRegistry: string;
    class procedure SaveExportDirectory(const ADir: string);
    class function LoadExportDirectory: string;
    class function ReadTimingBiasFromRegistry: integer;

    class function GetRaceTypeEnumFromString(const AValue: string): TRaceType;
    class function GetRaceTypeStringFromEnum(ARaceType: TRaceType): string;
    class function GetRaceStatusEnumFromString(const AValue: string): TRaceStatus;
    class function GetRaceStatusStringFromEnum(ARaceStatus: TRaceStatus): string;
  end;

implementation

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

end.
