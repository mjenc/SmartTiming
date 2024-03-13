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
  private
    FDataSource: TDataSource;
    FEventId: integer;
    FIsInsert: Boolean;
    FEventDate: TDatetime;
    FStatus: integer;
    function GetStartDatetime: TDatetime;
  public
    constructor Create(AOwner: TComponent; ADataSource: TDataSource; AEventId: integer; AIsInsert: boolean; AEventDate: TDatetime); reintroduce;
  end;

var
  GFormRaceDetails: TFormRaceDetails;

implementation

{$R *.dfm}

uses
  FormMain;

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
    EditTime.Text := FormatDatetime('hh:mm:00', Now);
  end
  else
  begin
    lDateTime := SmartTimingTools.GetFieldAsDatetime(FDataSource.DataSet.FieldByName('STARTTIME'), FEventDate);
    EditDate.Text := DateToStr(lDateTime);
    EditTime.Text := FormatDatetime('hh:mm:ss', lDateTime);
  end;

  if FIsInsert then
    FStatus := 0
  else
    FStatus := FDataSource.DataSet.FieldByName('STATUS').AsInteger;

  for lRaceType := rtUnknown to rtIndividualTimeTrial do
    ComboBoxRaceType.Items.Add(SmartTimingTools.GetRaceTypeStringFromEnum(lRaceType));
  if FIsInsert then
    ComboBoxRaceType.ItemIndex := 0
  else
    ComboBoxRaceType.ItemIndex := FDataSource.DataSet.FieldByName('RACETYPE').AsInteger;

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
  if FIsInsert then
  begin
    FDataSource.DataSet.FieldByName('EVENTID').Value := FEventId;
    FDataSource.DataSet.FieldByName('RACEID').Value := MainDataModule.GetMaxRaceId(FEventId) + 1;
  end;
  FDataSource.DataSet.FieldByName('STARTTIME').Value := GetStartDatetime;
  FDataSource.DataSet.FieldByName('RACETYPE').Value := ComboBoxRaceType.ItemIndex;
  if CBFirstPassingCounts.Checked then
    FDataSource.DataSet.FieldByName('FIRSTPASSINGISLAP').Value := 1
  else
    FDataSource.DataSet.FieldByName('FIRSTPASSINGISLAP').Value := 0;

  lDateTime := StrToTime('00:' + EditMinLapDuration.Text);
  FDataSource.DataSet.FieldByName('MINLAPDURATION').Value := SecondOfTheDay(lDatetime);
  FDataSource.DataSet.FieldByName('STATUS').Value := FStatus;
  FDataSource.DataSet.Post;
  TClientDataSet(FDataSource.DataSet).ApplyUpdates(-1);
end;

end.
