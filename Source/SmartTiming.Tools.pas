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
    class procedure GetColorsForRaceStatus(ARaceStatus: TRaceStatus; ASelected: boolean; var ABgColor, AFgColor: TColor);
    class procedure FillRaceItemFromDataSet(AParent: TWinControl; ADataSet: TDataSet; ARaceItem: TRaceItem);
    class function GetFlagNameFromRaceStatus(ARaceStatus: TRaceStatus): string;
    class procedure SortGridColumns(ADBGrid: TDBGrid; const ATableName: string);
    class procedure SetColumnProperties(const ATable: string; AColumn: TColumn);
    class procedure OnGetDefaultColumnText(ASender: TField; var AText: string; ADisplayText: Boolean);
    class procedure OnGetDateTimeFromValue(ASender: TField; var AText: string; ADisplayText: Boolean);
    class procedure OnGetTimeFromValue(ASender: TField; var AText: string; ADisplayText: Boolean);
    class procedure OnGetRaceStatus(ASender: TField; var AText: string; ADisplayText: Boolean);
    class procedure InitFieldDescriptions;
  end;

  TRaceEngineFactory = class
    class function CreateRaceEngineForRaceType(AParent: TWinControl; ARaceItem: TRaceItem): TCustomRaceEngine;
  end;

var
  GFieldDescriptionsSuperObject: ISuperObject;

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
class procedure SmartTimingTools.InitFieldDescriptions;
var
  lJSON: TStringList;
begin
  lJSON := TStringList.Create;
  try
    lJSON.LoadFromFile(cStdDataPath + '\TableColumnDescriptions.json');
    GFieldDescriptionsSuperObject := TSuperObject.ParseString(PChar(lJSON.Text), false);
  finally
    FreeAndNil(lJSON);
  end;
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
  if SameText(cRaceStatusNeutralized, AValue) then
    Exit(rsNeutralized);
  if SameText(cRaceStatusFinished, AValue) then
    Exit(rsFinished);
  if SameText(cRaceStatusStopped, AValue) then
    Exit(rsStopped);
  if SameText(cRaceStatusAborted, AValue) then
    Exit(rsAborted);
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
  rsStopped:
    Exit(cRaceStatusStopped);
  rsAborted:
    Exit(cRaceStatusAborted);
  end;
end;

{==============================================================================}
class function SmartTimingTools.GetFlagNameFromRaceStatus(ARaceStatus: TRaceStatus): string;
begin
  result := '';
  case ARaceStatus of
  rsWarmUp:
    Exit(cFlagNameWarmUp);
  rsStarted:
    Exit(cFlagNameStart);
  rsNeutralized:
    Exit(cFlagNameNeutralize);
  rsFinished:
    Exit(cFlagNameFinish);
  rsStopped:
    Exit(cFlagNameStop);
  rsAborted:
    Exit(cFlagNameAbort);
  end;
end;

{==============================================================================}
class procedure SmartTimingTools.GetColorsForRaceStatus(ARaceStatus: TRaceStatus; ASelected: boolean; var ABgColor, AFgColor: TColor);
begin
  ABgColor := clWindow;
  AFgColor := clWindowText;

  if ASelected then
  begin
    case ARaceStatus of
    rsNotStarted:
      Exit;
    rsWarmUp:
      ABgColor := cColorWarmupDark;
    rsStarted:
      ABgColor := cColorStartedDark;
    rsNeutralized:
      ABgColor := cColorNeutralizedDark;
    rsFinished, rsStopped:
      ABgColor := cColorInactiveDark;
    end;
    AFgColor := clWhite;
    Exit;
  end;

  case ARaceStatus of
  rsNotStarted:
    Exit;
  rsWarmUp:
    begin
      ABgColor := cColorWarmup;
      AFgColor := clBlack;
    end;
  rsStarted:
    begin
      ABgColor := cColorStarted;
      AFgColor := clBlack;
    end;
  rsNeutralized:
    begin
      ABgColor := cColorNeutralized;
      AFgColor := clBlack;
    end;
  rsFinished, rsStopped:
    ABgColor := cColorInactive;
  end;
  AFgColor := clBlack;
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
class procedure SmartTimingTools.SortGridColumns(ADBGrid: TDBGrid; const ATableName: string);
var
  lTables: TSuperArray;
  lColumns: TSuperArray;
  i: integer;
  j: integer;
  k: integer;
  lGridColumn: TColumn;
  lPosition: integer;
begin
  lTables := GFieldDescriptionsSuperObject.A['tables'];
  if lTables = nil then
    Exit;

  for i := 0 to lTables.Length - 1 do
  begin
    if lTables.O[i].S['tablename'] <> ATableName then
      Continue;

    lColumns := lTables.O[i].A['columns'];
    if lColumns = nil then
      Exit;

    for j := ADBGrid.Columns.Count - 1 downto 0 do
    begin
      lGridColumn := ADBGrid.Columns[j];
      for k := 0 to lColumns.Length - 1 do
      begin
        if SameText(lColumns.O[k].S['columnname'], lGridColumn.FieldName) then
        begin
          lPosition := lColumns.O[k].I['position'];
          lGridColumn.Index := lPosition;
          break;
        end;
      end;
    end;
  end;
end;

{==============================================================================}
class procedure SmartTimingTools.SetColumnProperties(const ATable: string; AColumn: TColumn);
  function GetAlignmentFromString(const AString: string): TAlignment;
  begin
    if SameText(AString, 'taLeftJustify') then
      Exit(taLeftJustify);
    if SameText(AString, 'taRightJustify') then
      Exit(taRightJustify);
    if SameText(AString, 'taCenter') then
      Exit(taCenter);
    result := taRightJustify;
  end;

  function GetFieldTypeFromString(const AString: string): TFieldType;
  begin
    if SameText(AString, 'ftString') then
      Exit(ftString);
    Exit(ftUnknown);
  end;

var
  lTables: TSuperArray;
  i: integer;
  lColumns: TSuperArray;
  j: integer;
  lColumn: ISuperObject;
  lFieldType: TFieldType;
  lMethodName: string;
begin
  if AColumn.Field.DataType = ftWideMemo then
    AColumn.Field.OnGetText := OnGetDefaultColumnText;
  lTables := gFieldDescriptionsSuperObject.A['tables'];
  for i := 0 to lTables.Length - 1 do
  begin
    if lTables.O[i].S['tablename'] <> ATable then
      Continue;

    lColumns := lTables.O[i].A['columns'];
    for j := 0 to lColumns.Length - 1 do
    begin
      if lColumns.O[j].S['columnname'] <> AColumn.FieldName then
        Continue;

      lColumn := lColumns.O[j];
      AColumn.Visible := not lColumn.B['invisible'];
      AColumn.Title.Caption := lColumn.S['caption'];
      if Length(AColumn.Title.Caption) = 0 then
        AColumn.Title.Caption := AColumn.FieldName;
      AColumn.Width := lColumn.I['width'];
      AColumn.Alignment := GetAlignmentFromString(lColumn.S['align']);
      lFieldType := GetFieldTypeFromString('fieldtype');
      if lFieldType <> ftUnknown then
        AColumn.Field.SetFieldType(lFieldType);

      lMethodName := lColumn.S['ongettext'];
      if not lMethodName.IsEmpty then
      begin
        if SameText(lMethodName, 'OnGetDateTimeFromValue') then
          AColumn.Field.OnGetText := OnGetDateTimeFromValue
        else if SameText(lMethodName, 'OnGetTimeFromValue') then
          AColumn.Field.OnGetText := OnGetTimeFromValue
        else if SameText(lMethodName, 'OnGetRaceStatus') then
          AColumn.Field.OnGetText := OnGetRaceStatus;
      end;
    end;
  end;
end;

{==============================================================================}
class procedure SmartTimingTools.OnGetDefaultColumnText(ASender: TField; var AText: string; ADisplayText: Boolean);
begin
  AText := ASender.AsString;
end;

{==============================================================================}
class procedure SmartTimingTools.OnGetDateTimeFromValue(ASender: TField; var AText: string; ADisplayText: Boolean);
begin
  AText := DateTimeToStr(ASender.AsFloat);
end;

{==============================================================================}
class procedure SmartTimingTools.OnGetTimeFromValue(ASender: TField; var AText: string; ADisplayText: Boolean);
begin
  if ASender.IsNull then
    AText := ''
  else
    AText := TimeToStr(ASender.AsFloat);
end;

{==============================================================================}
class procedure SmartTimingTools.OnGetRaceStatus(ASender: TField; var AText: string; ADisplayText: Boolean);
begin
  AText := SmartTimingTools.GetRaceStatusStringFromEnum(TRaceStatus(ASender.AsInteger));
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
