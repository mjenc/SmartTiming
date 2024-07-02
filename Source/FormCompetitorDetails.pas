unit FormCompetitorDetails;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Mask,
  Vcl.DBCtrls, DB,  DBClient, DataModule, SmartTiming.Cache, SmartTiming.Consts;

type
  TFormCompetitorDetails = class(TForm)
    PanelMain: TPanel;
    PanelButtons: TPanel;
    ButtonOK: TButton;
    ButtonCancel: TButton;
    Label1: TLabel;
    DBComboBoxClass: TDBComboBox;
    DBCompetitorID: TDBText;
    DBEditBib: TDBEdit;
    DBEditFirstName: TDBEdit;
    DBEditLastName: TDBEdit;
    DBComboBoxClub: TDBComboBox;
    DBComboBoxTeam: TDBComboBox;
    DBComboBoxNationality: TDBComboBox;
    DBComboBoxNationalityISO: TDBComboBox;
    DBEditUCIID: TDBEdit;
    DBEditHandicapFactor: TDBEdit;
    DBEditTxId: TDBEdit;
    DBEditAddtional1: TDBEdit;
    DBEditAdditional2: TDBEdit;
    DBEditAdditional3: TDBEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    DBEditStarttime: TDBEdit;
    ButtonOkAndNext: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
    procedure ButtonOkAndNextClick(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
  private
    FDataSource: TDataSource;
    FEventId: Integer;
    FIsInsert: Boolean;
    function IsTimeValid(const AValue: string): boolean;
  public
    constructor Create(AOwner: TComponent; ADataSource: TDataSource; AEventId: integer; AIsInsert: boolean); reintroduce;
  end;


implementation

{$R *.dfm}

uses
  DateUtils, SmartTiming.Tools, FormMain;

{==============================================================================}
constructor TFormCompetitorDetails.Create(AOwner: TComponent; ADataSource: TDataSource; AEventId: integer; AIsInsert: boolean);
begin
  inherited Create(AOwner);
  FDataSource := ADataSource;
  FEventId := AEventId;
  FIsInsert := AIsInsert;
end;

{==============================================================================}
procedure TFormCompetitorDetails.FormCreate(Sender: TObject);
begin
  DBComboBoxClass.DataSource := FDataSource;

  DBComboBoxClass.DataField := 'CLASS';
  MainDataModule.FillWithDistinctValues('COMPETITORS', 'CLASS', DBComboBoxClass.Items);
  DBCompetitorID.DataSource := FDataSource;
  DBCompetitorID.DataField := 'COMPETITORID';
  DBEditBib.DataSource := FDataSource;
  DBEditBib.DataField := 'BIB';
  DBEditFirstName.DataSource := FDataSource;
  DBEditFirstName.DataField := 'FIRSTNAME';
  DBEditLastName.DataSource := FDataSource;
  DBEditLastName.DataField := 'LASTNAME';
  DBComboBoxClub.DataSource := FDataSource;
  DBComboBoxClub.DataField := 'CLUB';
  MainDataModule.FillWithDistinctValues('COMPETITORS', 'CLUB', DBComboBoxClub.Items);
  DBComboBoxTeam.DataSource := FDataSource;
  DBComboBoxTeam.DataField := 'TEAM';
  DBEditStartTime.DataSource := FDataSource;
  DBEditStartTime.DataField := 'STARTTIME';
  MainDataModule.FillWithDistinctValues('COMPETITORS', 'TEAM', DBComboBoxTeam.Items);
  DBComboBoxNationality.DataSource := FDataSource;
  DBComboBoxNationality.DataField := 'NATIONALITY';
  MainDataModule.FillWithDistinctValues('COMPETITORS', 'NATIONALITY', DBComboBoxNationality.Items);
  DBComboBoxNationalityISO.DataSource := FDataSource;
  DBComboBoxNationalityISO.DataField := 'NATIONALITYISO';
  DBEditUCIID.DataSource := FDataSource;
  DBEditUCIID.DataField := 'UCIID';
  DBEditHandicapFactor.DataSource := FDataSource;
  DBEditHandicapFactor.DataField := 'HANDICAPFACTOR';
  if FIsInsert then
    FDataSource.DataSet.FieldByName('HANDICAPFACTOR').Value := 100;

  DBEditTxId.DataSource := FDataSource;
  DBEditTxId.DataField := 'CHIPID';
  DBEditAddtional1.DataSource := FDataSource;
  DBEditAddtional1.DataField := 'ADDITIONAL1';
  DBEditAdditional2.DataSource := FDataSource;
  DBEditAdditional2.DataField := 'ADDITIONAL2';
  DBEditAdditional3.DataSource := FDataSource;
  DBEditAdditional3.DataField := 'ADDITIONAL3';
end;

{==============================================================================}
procedure TFormCompetitorDetails.FormShow(Sender: TObject);
begin
  ButtonOkAndNext.Visible := FIsInsert;
  DBEditBib.SetFocus;
end;

{==============================================================================}
function TFormCompetitorDetails.IsTimeValid(const AValue: string): boolean;
var
  lDateTime: TDatetime;
begin
  if AValue.IsEmpty then
    Exit(true);

  result := TryStrToDateTime(AValue, lDateTime);
  if not result then
  begin
    Beep;
    ShowMessage(cMessagesInvalidTimeFormat);
  end;
end;

{==============================================================================}
procedure TFormCompetitorDetails.ButtonCancelClick(Sender: TObject);
begin
  FDataSource.DataSet.Cancel;
end;

{==============================================================================}
procedure TFormCompetitorDetails.ButtonOkAndNextClick(Sender: TObject);
var
  lClass: string;
  lBib: Integer;
  lStartTime: TDatetime;
  lTimeStr: string;
begin
  lTimeStr := DBEditStarttime.Text;
  if not IsTimeValid(lTimeStr) then
  begin
    DBEditStarttime.SetFocus;
    Exit;
  end;

  lClass := DBComboBoxClass.Text;
  lBib := String(DBEditBib.Text).ToInteger;
  lStartTime := StrToDateTime(lTimeStr);

  ButtonOKClick(Sender);

  GFormMain.DataSourceCompetitors.DataSet.Append;

  DBComboBoxClass.Text := lClass;
  Inc(lBib);
  lStartTime.AddMinute(1);
  DBEditStarttime.Text := FormatDatetime('hh:mm:ss', lStarttime);
  DBEditBib.SetFocus;
  DBEditBib.Text := lBib.ToString;
end;

{==============================================================================}
procedure TFormCompetitorDetails.ButtonOKClick(Sender: TObject);
var
  lTxId: string;
begin
  if FIsInsert then
    FDataSource.DataSet.FieldByName('COMPETITORID').Value := MainDataModule.GetMaxCompetitorId + 1;

  lTxId := DBEditTxId.EditText;

  if not TTransponderMappingStore.GetSingleton.ConvertToValidChipId(lTxId) then
    ShowMessage('Keine gültige Transponder ID.');

  DBEditTxId.EditText := lTxId;

  FDataSource.DataSet.Post;
  TClientDataSet(FDataSource.DataSet).ApplyUpdates(0);
end;


end.
