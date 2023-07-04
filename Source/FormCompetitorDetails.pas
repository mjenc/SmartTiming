unit FormCompetitorDetails;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Mask,
  Vcl.DBCtrls, DB,  DBClient, DataModule, SmartTiming.Cache;

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
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
  private
    FDataSource: TDataSource;
    FEventId: Integer;
    FIsInsert: Boolean;

  public
    constructor Create(AOwner: TComponent; ADataSource: TDataSource; AEventId: integer; AIsInsert: boolean);
  end;


implementation

{$R *.dfm}

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
  DBEditBib.SetFocus;
end;

{==============================================================================}
procedure TFormCompetitorDetails.ButtonOKClick(Sender: TObject);
var
  lTxId: string;
begin
  lTxId := DBEditTxId.EditText;
  if not TTransponderMappingStore.GetSingleton.ConvertToValidChipId(lTxId) then
    raise Exception.Create('Keine gültige Transponder ID.');
  DBEditTxId.EditText := lTxId;

  if FIsInsert then
  begin
    FDataSource.DataSet.FieldByName('COMPETITORID').Value := MainDataModule.GetMaxCompetitorId + 1;
  end;

  FDataSource.DataSet.Post;
  TClientDataSet(FDataSource.DataSet).ApplyUpdates(-1);
end;


end.
