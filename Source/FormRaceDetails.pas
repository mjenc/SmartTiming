unit FormRaceDetails;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Mask,
  Vcl.ExtCtrls, DB, DateUtils, DBClient,
  SmartTiming.Consts, SmartTiming.Tools, Vcl.DBCtrls,
  DataModule;

type
  TFormRaceDetails = class(TForm)
    PanelButtons: TPanel;
    ButtonOK: TButton;
    ButtonCancel: TButton;
    PanelMain: TPanel;
    Bezeichnung: TLabel;
    Label1: TLabel;
    EditTime: TMaskEdit;
    ComboBoxRaceType: TComboBox;
    Label2: TLabel;
    LabelLapCount: TLabel;
    CBFirstPassingCounts: TCheckBox;
    Label3: TLabel;
    Label4: TLabel;
    EditMinLapDuration: TMaskEdit;
    EditDate: TMaskEdit;
    DBEditTitle: TDBEdit;
    DBEditLapCount: TDBEdit;
    DBEditDistance: TDBEdit;
    procedure ButtonOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ComboBoxRaceTypeChange(Sender: TObject);
  private
    FDataSource: TDataSource;
    FEventId: integer;
    FIsInsert: Boolean;
    FEventDate: TDatetime;
    FStatus: integer;
    function GetStartDatetime: TDatetime;
    function GetLastUsedRaceType: TRaceType;
    procedure SaveLastUsedRaceType(ARaceType: TRaceType);
    function GetSelectedRaceType: TRaceType;
    procedure ApplyRaceTypeFields;
  public
    constructor Create(AOwner: TComponent; ADataSource: TDataSource; AEventId: integer; AIsInsert: boolean; AEventDate: TDatetime); reintroduce;
  end;

var
  GFormRaceDetails: TFormRaceDetails;

implementation

{$R *.dfm}

uses
  FormMain, SmartTiming.Controller;

{==============================================================================}
constructor TFormRaceDetails.Create(AOwner: TComponent; ADataSource: TDataSource; AEventId: integer; AIsInsert: boolean; AEventDate: TDatetime);
begin
  inherited Create(AOwner);
  FDataSource := ADataSource;
  FEventId := AEventId;
  FIsInsert := AIsInsert;
  FEventDate := AEventDate;
  FStatus := 0;
end;

{==============================================================================}
function TFormRaceDetails.GetLastUsedRaceType: TRaceType;
var
  lRaceType: TRaceType;
  lStored: string;
begin
  lStored := SmartTimingTools.RegistryReadString(HKEY_CURRENT_USER,
    cRegKeyPath + '\Settings', 'LastRaceType',
    SmartTimingTools.GetRaceTypeStringFromEnum(rtCircuit));
  lRaceType := SmartTimingTools.GetRaceTypeEnumFromString(lStored);
  if not SmartTimingTools.IsRaceTypeSupported(lRaceType) then
    Exit(rtCircuit);
  Result := lRaceType;
end;

{==============================================================================}
procedure TFormRaceDetails.SaveLastUsedRaceType(ARaceType: TRaceType);
begin
  if not SmartTimingTools.IsRaceTypeSupported(ARaceType) then
    Exit;
  SmartTimingTools.RegistryWriteString(HKEY_CURRENT_USER, cRegKeyPath + '\Settings',
    'LastRaceType', SmartTimingTools.GetRaceTypeStringFromEnum(ARaceType));
end;

{==============================================================================}
procedure TFormRaceDetails.FormCreate(Sender: TObject);
var
  lRaceType: TRaceType;
  lDateTime: TDatetime;
begin
  DBEditTitle.DataSource := FDataSource;
  DBEditTitle.DataField := 'TITLE';

  if FIsInsert or FDataSource.DataSet.FieldByName('STARTTIME').IsNull then
  begin
    EditDate.Text := DateToStr(FEventDate);
    EditTime.Text := FormatDatetime('hh:nn:00', Now);
  end
  else
  begin
    lDateTime := SmartTimingTools.GetFieldAsDatetime(FDataSource.DataSet.FieldByName('STARTTIME'), FEventDate);
    EditDate.Text := DateToStr(lDateTime);
    EditTime.Text := FormatDatetime('hh:nn:ss', lDateTime);
  end;

  if FIsInsert then
    FStatus := 0
  else
    FStatus := FDataSource.DataSet.FieldByName('STATUS').AsInteger;

  for lRaceType := Low(TRaceType) to High(TRaceType) do
  begin
    if not SmartTimingTools.IsRaceTypeSupported(lRaceType) then
      Continue;
    ComboBoxRaceType.Items.AddObject(
      SmartTimingTools.GetRaceTypeStringFromEnum(lRaceType), TObject(lRaceType));
  end;
  if FIsInsert then
    ComboBoxRaceType.ItemIndex := ComboBoxRaceType.Items.IndexOfObject(
      TObject(GetLastUsedRaceType))
  else
  begin
    (* Existing deferred types (e.g. TTT) stay visible so the operator can switch away. *)
    lRaceType := TRaceType(FDataSource.DataSet.FieldByName('RACETYPE').AsInteger);
    if SmartTimingTools.CanCreateRaceEngine(lRaceType) and
       (not SmartTimingTools.IsRaceTypeSupported(lRaceType)) and
       (ComboBoxRaceType.Items.IndexOfObject(TObject(lRaceType)) < 0) then
      ComboBoxRaceType.Items.AddObject(
        SmartTimingTools.GetRaceTypeStringFromEnum(lRaceType), TObject(lRaceType));
    if not SmartTimingTools.CanCreateRaceEngine(lRaceType) then
      lRaceType := rtCircuit;
    ComboBoxRaceType.ItemIndex := ComboBoxRaceType.Items.IndexOfObject(TObject(lRaceType));
  end;
  if ComboBoxRaceType.ItemIndex < 0 then
    ComboBoxRaceType.ItemIndex := 0;
  ApplyRaceTypeFields;

  DBEditLapCount.DataSource := FDataSource;
  DBEditLapCount.DataField := 'LAPS';
  if FIsInsert then
    DBEditLapCount.Field.Value := 1;

  if FIsInsert then
   CBFirstPassingCounts.Checked := False
  else
    CBFirstPassingCounts.Checked := FDataSource.DataSet.FieldByName('FIRSTPASSINGISLAP').AsInteger <> 0;

  DBEditDistance.DataSource := FDataSource;
  DBEditDistance.DataField := 'DISTANCE';

  lDateTime := Trunc(Now);
  if not FIsInsert then
    lDateTime.IncSecond(FDataSource.DataSet.FieldByName('MINLAPDURATION').AsInteger);
  EditMinLapDuration.Text := FormatDateTime('mm:ss', lDateTime);
end;

{==============================================================================}
procedure TFormRaceDetails.FormShow(Sender: TObject);
begin
  DBEditTitle.SetFocus;
end;

{==============================================================================}
function TFormRaceDetails.GetSelectedRaceType: TRaceType;
begin
  Result := rtCircuit;
  if ComboBoxRaceType.ItemIndex >= 0 then
    Result := TRaceType(Integer(ComboBoxRaceType.Items.Objects[ComboBoxRaceType.ItemIndex]));
end;

{==============================================================================}
procedure TFormRaceDetails.ApplyRaceTypeFields;
var
  lType: TRaceType;
  lFields: TRaceDetailFields;
  lTop: Integer;
  lEditLeft: Integer;

  procedure PlaceRow(ALabel, AEdit: TControl; AVisible: Boolean; ARowHeight: Integer);
  begin
    if ALabel <> nil then
    begin
      ALabel.Visible := AVisible;
      if AVisible then
        ALabel.Top := lTop + 3;
    end;
    if AEdit <> nil then
    begin
      AEdit.Visible := AVisible;
      if AVisible then
      begin
        AEdit.Top := lTop;
        if (AEdit <> CBFirstPassingCounts) and (AEdit.Left < lEditLeft) then
          AEdit.Left := lEditLeft;
      end;
    end;
    if AVisible then
      Inc(lTop, ARowHeight);
  end;

begin
  lType := GetSelectedRaceType;
  lFields := SmartTimingTools.GetRaceDetailFields(lType);
  LabelLapCount.Caption := cRaceDetailsLapCount;
  LabelLapCount.AutoSize := False;
  LabelLapCount.Width := 150;

  (* Always below Art combo — never reuse its Top (DPI / z-order overlap). *)
  lEditLeft := ComboBoxRaceType.Left;
  lTop := ComboBoxRaceType.Top + ComboBoxRaceType.Height + 12;
  PlaceRow(LabelLapCount, DBEditLapCount, rdfLaps in lFields, 29);
  PlaceRow(nil, CBFirstPassingCounts, rdfFirstPassingIsLap in lFields, 26);
  PlaceRow(Label3, DBEditDistance, rdfDistance in lFields, 29);
  PlaceRow(Label4, EditMinLapDuration, rdfMinLapDuration in lFields, 29);

  Label2.BringToFront;
  ComboBoxRaceType.BringToFront;
end;

{==============================================================================}
procedure TFormRaceDetails.ComboBoxRaceTypeChange(Sender: TObject);
begin
  ApplyRaceTypeFields;
end;

{==============================================================================}
function TFormRaceDetails.GetStartDatetime: TDatetime;
var
  lDateString: string;
  lTimeString: string;
begin
  lDateString := EditDate.Text;
  result := StrToDate(lDateString);
  lTimeString := EditTime.Text;
  result := result + StrToTime(lTimeString);
end;

{==============================================================================}
procedure TFormRaceDetails.ButtonOKClick(Sender: TObject);
var
  lDateTime: TDatetime;
begin
  if ComboBoxRaceType.ItemIndex >= 0 then
    SaveLastUsedRaceType(TRaceType(
      Integer(ComboBoxRaceType.Items.Objects[ComboBoxRaceType.ItemIndex])));

  if FIsInsert then
  begin
    FDataSource.DataSet.FieldByName('EVENTID').Value := FEventId;
    FDataSource.DataSet.FieldByName('RACEID').Value := MainDataModule.GetMaxRaceId(FEventId) + 1;
  end;
  FDataSource.DataSet.FieldByName('STARTTIME').Value := GetStartDatetime;
  if ComboBoxRaceType.ItemIndex >= 0 then
    FDataSource.DataSet.FieldByName('RACETYPE').Value :=
      Integer(ComboBoxRaceType.Items.Objects[ComboBoxRaceType.ItemIndex])
  else
    FDataSource.DataSet.FieldByName('RACETYPE').Value := Ord(rtCircuit);
  if CBFirstPassingCounts.Checked then
    FDataSource.DataSet.FieldByName('FIRSTPASSINGISLAP').Value := 1
  else
    FDataSource.DataSet.FieldByName('FIRSTPASSINGISLAP').Value := 0;

  lDateTime := StrToTime('00:' + EditMinLapDuration.Text);
  FDataSource.DataSet.FieldByName('MINLAPDURATION').Value := SecondOfTheDay(lDatetime);
  FDataSource.DataSet.FieldByName('STATUS').Value := FStatus;

  with FDataSource.DataSet.FieldByName('RACEID') do
    ProviderFlags := ProviderFlags + [pfInKey];

  FDataSource.DataSet.Post;
  TClientDataSet(FDataSource.DataSet).ApplyUpdates(-1);

  GSmartTimingController.LoadRaces;
  GFormMain.RefreshRacesListBox;
end;

end.
