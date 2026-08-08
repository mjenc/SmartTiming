unit SmartTiming.Tools;

interface

uses
  Classes, SysUtils, DateUtils,
  Windows, Dialogs,Forms, Winapi.Messages,Registry,DBGrids,Controls,Graphics,
  Buttons,Grids,
  Variants,
  Generics.Defaults, UITypes, DB, SmartTiming.Event,
  Tools.SuperObject, SmartTiming.Consts, RaceEngine.Custom;

type
  TDBGrid = class(DBGrids.TDBGrid)
  private
    procedure WMVScroll(var Msg: TWMVScroll); message WM_VSCROLL;
  protected
    procedure UpdateScrollBar; override;
  end;

  SmartTimingTools = class
    class function FieldAsDatetime(AField: TField): TDatetime;
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
    class function IsRaceTypeSupported(ARaceType: TRaceType): Boolean;
    class function GetSupportedRaceTypes: TRaceTypes;
    class function GetRaceStatusEnumFromString(const AValue: string): TRaceStatus;
    class function GetRaceStatusStringFromEnum(ARaceStatus: TRaceStatus): string;
    class procedure GetColorsForRaceStatus(ARaceStatus: TRaceStatus; ASelected: boolean; var ABgColor, AFgColor: TColor);
    class procedure GetColorsForPodium(ARank: Integer; var ABgColor, AFgColor: TColor);
    class procedure FillRaceItemFromDataSet(ADataSet: TDataSet; ARaceItem: TRaceItem);
    class function GetFlagNameFromRaceStatus(ARaceStatus: TRaceStatus): string;
    class procedure SetColumnProperties(const ATable: string; AColumn: TColumn);
    class procedure OnGetDefaultColumnText(ASender: TField; var AText: string; ADisplayText: Boolean);
    class procedure OnGetDateTimeFromValue(ASender: TField; var AText: string; ADisplayText: Boolean);
    class procedure OnGetTimeFromValue(ASender: TField; var AText: string; ADisplayText: Boolean);
    class function ISOTimeStrToDateTime(const AStr: string): TDatetime;
    class function GetFieldAsDatetime(AField: TField; ADefaultIfNull: TDatetime): TDatetime;
    class procedure OnGetRaceStatus(ASender: TField; var AText: string; ADisplayText: Boolean);
    class procedure OnGetTxId(ASender: TField; var AText: string; ADisplayText: Boolean);
    class procedure DBGridDrawCheckBox(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
    class procedure InitFieldDescriptions;
    class function ShowDialog(const AMessage: string; const ATitle: string = ''; AButtons: TTaskDialogCommonButtons = [tcbOk]; ADefaultButton: TTaskDialogCommonButton = tcbCancel): TModalResult;
  end;

  TRaceEngineFactory = class
    class function CreateRaceEngineForRaceType(AParent: TWinControl; AEvent: TEventDataObject; ARaceItem: TRaceItem): TCustomRaceEngine;
  end;

var
  GFieldDescriptionsSuperObject: ISuperObject;

implementation

uses
  RaceEngine.TimeTrial, SmartTiming.Cache;

{==============================================================================}
class function SmartTimingTools.ShowDialog(const AMessage: string; const ATitle: string = ''; AButtons: TTaskDialogCommonButtons = [tcbOk]; ADefaultButton: TTaskDialogCommonButton = tcbCancel): TModalResult;
var
  lTaskDialog : TTaskDialog;
begin
  lTaskDialog := TTaskDialog.Create(nil);
  try
    if ATitle.IsEmpty then
      lTaskDialog.Title := Application.Title
    else
      lTaskDialog.Title := ATitle;
    lTaskDialog.Text := AMessage;
    lTaskDialog.CommonButtons := AButtons;
    if ADefaultButton in AButtons then
      lTaskDialog.DefaultButton := ADefaultButton;
    lTaskDialog.Execute;
    result := lTaskDialog.ModalResult;
  finally
    lTaskDialog.Free;
  end;
end;

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
  result := RegistryReadString(HKEY_CURRENT_USER, cRegKeyPath, 'LastUsedDatabase', gStdDataPath);
end;

{==============================================================================}
class procedure SmartTimingTools.SaveExportDirectory(const ADir: string);
begin
  RegistryWriteString(HKEY_CURRENT_USER, cRegKeyPath, 'ExportDir', ADir);
end;

{==============================================================================}
class function SmartTimingTools.LoadExportDirectory: string;
begin
  result := RegistryReadString(HKEY_CURRENT_USER, cRegKeyPath, 'ExportDir', gStdDataPath + cStdDatabaseName);
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
    lJSON.LoadFromFile(gStdDataPath + '\TableColumnDescriptions.json');
    GFieldDescriptionsSuperObject := TSuperObject.Create(PChar(lJSON.Text));
  finally
    FreeAndNil(lJSON);
  end;
end;

{==============================================================================}
class function SmartTimingTools.GetRaceTypeEnumFromString(const AValue: string): TRaceType;
begin
  if SameText(cRaceTypeNameITT, AValue) then
    Exit(rtIndividualTimeTrial);
  if SameText(cRaceTypeNameTTT, AValue) or SameText(cRaceTypeNameTTTLocked, AValue) then
    Exit(rtTeamTimeTrial);
  result := rtUnknown;
end;

{==============================================================================}
class function SmartTimingTools.GetRaceTypeStringFromEnum(ARaceType: TRaceType): string;
begin
  case ARaceType of
  rtIndividualTimeTrial:
    result := cRaceTypeNameITT;
  rtTeamTimeTrial:
    result := cRaceTypeNameTTTLocked;
  else
    result := cRaceTypeNameUnknown;
  end;
end;

{==============================================================================}
class function SmartTimingTools.IsRaceTypeSupported(ARaceType: TRaceType): Boolean;
begin
  Result := ARaceType in GetSupportedRaceTypes;
end;

{==============================================================================}
class function SmartTimingTools.GetSupportedRaceTypes: TRaceTypes;
begin
  // TTT (rtTeamTimeTrial) intentionally locked until fully implemented (Plan 8d / Plan 1).
  Result := [rtUnknown, rtIndividualTimeTrial];
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
  ABgColor := clWhite;
  AFgColor := clBlack;

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
class procedure SmartTimingTools.GetColorsForPodium(ARank: Integer; var ABgColor, AFgColor: TColor);
begin
  case ARank of
  1:
    begin
      ABgColor := TColor($37afd4);
      AFgColor := TColorRec.White;
    end;
  2:
    begin
      ABgColor := TColorRec.Silver;
      AFgColor := TColorRec.Black;
    end;
  3:
    begin
      ABgColor := TColor($327fcd);
      AFgColor := TColorRec.White;
    end;
  end;
end;

{==============================================================================}
class function SmartTimingTools.FieldAsDatetime(AField: TField): TDatetime;
begin
  if AField.IsNull then
    Exit(0.0);
  if AField.DataType = ftDatetime then
    Exit(AField.AsDateTime);
  if AField.DataType = ftWidememo then
    Exit(StrToDatetime(AField.AsString));

  result := StrToDatetime(AField.Text);
end;

{==============================================================================}
class procedure SmartTimingTools.FillRaceItemFromDataSet(ADataSet: TDataSet; ARaceItem: TRaceItem);
begin
  ARaceItem.Id := ADataSet.FieldByName('RACEID').AsInteger;
  ARaceItem.RaceType := TRaceType(ADataSet.FieldByName('RACETYPE').AsInteger);
  ARaceItem.StartTime := FieldAsDatetime(ADataSet.FieldByName('STARTTIME'));
  ARaceItem.Title := ADataSet.FieldByName('TITLE').AsString;
  ARaceItem.Laps := ADataSet.FieldByName('LAPS').AsInteger;
  ARaceItem.Distance := ADataSet.FieldByName('DISTANCE').AsFloat;
  ARaceItem.FirstPassingIsLap := ADataSet.FieldByName('FIRSTPASSINGISLAP').AsInteger <> 0;
  ARaceItem.MinLapDuration := ADataSet.FieldByName('MINLAPDURATION').AsInteger;
  ARaceItem.Status := TRaceStatus(ADataSet.FieldByName('STATUS').AsInteger);
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
    if SameText(AString, 'ftDatetime') then
      Exit(ftDatetime);
    if SameText(AString, 'ftTime') then
      Exit(ftTime);

    Exit(ftUnknown);
  end;

var
  lTables: ISuperArray;
  i: integer;
  lColumns: ISuperArray;
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
      lFieldType := GetFieldTypeFromString(lColumn.S['fieldtype']);
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
          AColumn.Field.OnGetText := OnGetRaceStatus
        else if SameText(lMethodName, 'OnGetTxId') then
          AColumn.Field.OnGetText := OnGetTxId;
      end;
    end;
  end;
end;

{==============================================================================}
class procedure SmartTimingTools.OnGetDefaultColumnText(ASender: TField; var AText: string; ADisplayText: Boolean);
begin
  if ASender.IsNull then
    AText := ''
  else
    AText := ASender.AsString;
end;

{==============================================================================}
class procedure SmartTimingTools.OnGetDateTimeFromValue(ASender: TField; var AText: string; ADisplayText: Boolean);
begin
  if ASender.IsNull then
  begin
    AText := '';
    Exit;
  end;

  AText := DateTimeToStr(SmartTimingTools.GetFieldAsDatetime(ASender, 0.0));
end;

{==============================================================================}
class function SmartTimingTools.GetFieldAsDatetime(AField: TField; ADefaultIfNull: TDatetime): TDatetime;
var
  lStringValue: string;
begin
  if AField.IsNull then
    Exit(ADefauLtIfNull);

  case AField.DataType of
  ftString, ftBytes, ftVarBytes, ftAutoInc, ftBlob, ftMemo, ftFmtMemo, ftFixedChar, ftWideString, ftVariant, ftFixedWideChar, ftWideMemo:
    begin
      lStringValue := VarToStr(AField.AsVariant);
      if not TryStrToDateTime(lStringValue, result) then
        result := ISOTimeStrToDateTime(lStringValue);
    end;
  ftSmallint, ftInteger, ftWord, ftFloat, ftCurrency, ftLargeint, ftLongWord, ftShortint, ftExtended, ftSingle:
    Exit(AField.AsExtended);
  ftDate, ftTime, ftDateTime, ftTimeStamp:
    Exit(AField.AsDateTime);
  else
    Exit(ADefauLtIfNull);
  end;
end;

{==============================================================================}
class procedure SmartTimingTools.OnGetTimeFromValue(ASender: TField; var AText: string; ADisplayText: Boolean);
begin
  if ASender.IsNull then
    AText := ''
  else
    AText := ASender.Value;
end;

{==============================================================================}
class function SmartTimingTools.ISOTimeStrToDateTime(const AStr: string): TDateTime;
var
  lYear: Word;
  lMonth: Word;
  lDay: Word;
  lHour: Word;
  lMinute: Word;
  lSecond: Word;
  lMSec: Word;
begin
  lYear := StrToInt(Copy(AStr, 1, 4));
  lMonth := StrToInt(Copy(AStr, 6, 2));
  lDay := StrToInt(Copy(AStr, 9, 2));
  lHour := StrToInt(Copy(AStr, 12, 2));
  lMinute := StrToInt(Copy(AStr, 15, 2));
  lSecond := StrToInt(Copy(AStr, 18, 2));
  if (Length(AStr) >= 21) and (AStr[20] = '.') then
    lMSec := StrToInt(Copy(AStr, 21, 3))
  else
    lMSec := 0;
  Result := EncodeDateTime(lYear, lMonth, lDay, lHour, lMinute, lSecond, lMSec);
end;
{==============================================================================}
class procedure SmartTimingTools.OnGetRaceStatus(ASender: TField; var AText: string; ADisplayText: Boolean);
begin
  if ASender.IsNull then
    AText := ''
  else
    AText := SmartTimingTools.GetRaceStatusStringFromEnum(TRaceStatus(ASender.AsInteger));
end;

{==============================================================================}
class procedure SmartTimingTools.OnGetTxId(ASender: TField; var AText: string; ADisplayText: Boolean);
var
  lShortId: integer;
begin
  if ASender.IsNull then
  begin
    AText := '';
    Exit;
  end;
  lShortId := TTransponderMappingStore.GetSingleton.GetShortIdFromTransponderId(ASender.AsString);
  if lShortId < 0 then
    AText := ASender.AsString
  else
    AText := lShortId.ToString;
end;

{==============================================================================}
class procedure SmartTimingTools.DBGridDrawCheckBox(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  if (not SameText(Column.Field.FieldName, 'FIRSTPASSINGISLAP'))
     and (not SameText(Column.Field.FieldName, 'DNS'))
     and (not SameText(Column.Field.FieldName, 'DNF'))
     and (not SameText(Column.Field.FieldName, 'DSQ')) then
    Exit;

  TDBGrid(Sender).Canvas.FillRect(Rect) ;
  if VarIsNull(Column.Field.Value) then
  begin
    DrawFrameControl(TDBGrid(Sender).Canvas.Handle,Rect, DFC_BUTTON, DFCS_BUTTONCHECK or DFCS_INACTIVE); {grayed}
    Exit;
  end;

  if Column.Field.AsInteger <> 0 then
    DrawFrameControl(TDBGrid(Sender).Canvas.Handle,Rect, DFC_BUTTON, DFCS_BUTTONCHECK or DFCS_CHECKED)
  else
    DrawFrameControl(TDBGrid(Sender).Canvas.Handle,Rect, DFC_BUTTON, DFCS_BUTTONCHECK);
end;

{==============================================================================}
class function TRaceEngineFactory.CreateRaceEngineForRaceType(AParent: TWinControl; AEvent: TEventDataObject; ARaceItem: TRaceItem): TCustomRaceEngine;
begin
  case ARaceItem.RaceType of
  rtIndividualTimeTrial, rtUnknown:
    Exit(TTimeTrialRaceEngine.Create(AParent, AEvent, ARaceItem));
  rtTeamTimeTrial:
    raise Exception.Create(cMessagesRaceTypeLocked);
  else
    raise Exception.Create('Race type is unknown');
  end;
end;

{==============================================================================}
procedure TDBGrid.WMVScroll(var Msg: TWMVScroll);
Var
 dataset: TDataSet;
 si: TScrollInfo;
Begin
 If (Msg.ScrollCode = SB_THUMBTRACK) Or
    (Msg.ScrollCode = SB_THUMBPOSITION) Then
 Begin
   dataset := Self.DataSource.DataSet;
   If Assigned(dataset) Then
   Begin
     si.cbSize := SizeOf(si);
     si.fMask := SIF_ALL;
     If Not GetScrollInfo(Self.Handle, SB_VERT, si) Then
       RaiseLastOSError;
     dataset.MoveBy(si.nTrackPos - dataset.RecNo);
     Msg.Result := 0;
   End
   Else
     inherited;
 End
 Else
   inherited;end;

{==============================================================================}
Procedure TDBGrid.UpdateScrollBar;
Var
 dataset: TDataSet;
 si: TScrollInfo;
Begin
 dataset := Self.DataSource.DataSet;
 If Assigned(dataset) Then
 Begin
   If Not dataset.Active Or (dataset.RecordCount <= Self.RowCount - 1) Then
     ShowScrollBar(Self.Handle, SB_VERT, False)
   Else
     Begin
       ShowScrollBar(Self.Handle, SB_VERT, True);
       If Win32MajorVersion >= 6 Then
         SetWindowPos(Self.Handle, 0, 0, 0, 0, 0, SWP_NOSIZE Or SWP_NOMOVE Or SWP_NOZORDER Or SWP_NOACTIVATE Or SWP_NOOWNERZORDER Or SWP_NOSENDCHANGING Or SWP_FRAMECHANGED);
       si.cbSize := sizeof(si);
       si.nMin := 1;
       si.nMax := dataset.RecordCount;
       si.nPos := dataset.RecNo;
       si.fMask := SIF_POS Or SIF_RANGE;
       SetScrollInfo(Self.Handle, SB_VERT, si, True);
     End;
   End
 Else
   ShowScrollBar(Self.Handle, SB_VERT, False);
End;
end.
