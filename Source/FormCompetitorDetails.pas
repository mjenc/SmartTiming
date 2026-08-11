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
    function SyncChipAssignments(ACompetitorId: Integer; const AChipId: string): Boolean;
  public
    constructor Create(AOwner: TComponent; ADataSource: TDataSource; AEventId: integer; AIsInsert: boolean); reintroduce;
  end;


implementation

{$R *.dfm}

uses
  SmartTiming.Consts, SmartTiming.Tools, SmartTiming.TransponderAssignment;

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
function TFormCompetitorDetails.SyncChipAssignments(ACompetitorId: Integer;
  const AChipId: string): Boolean;
var
  lRaceIds: TArray<Integer>;
  lRaceId: Integer;
  lResult: TAssignmentOperationResult;
  lAssignment: TTransponderAssignment;
  lHasOpen: Boolean;
  lStatus: TRaceStatus;
  i: Integer;
begin
  Result := True;
  lRaceIds := MainDataModule.GetRaceIdsForCompetitor(ACompetitorId);
  for i := 0 to High(lRaceIds) do
  begin
    lRaceId := lRaceIds[i];
    lHasOpen := TTransponderAssignmentStore.GetSingleton.TryGetActiveByRaceAndCompetitor(
      lRaceId, ACompetitorId, lAssignment);
    lStatus := MainDataModule.GetRaceStatus(lRaceId);

    if AChipId = '' then
    begin
      if lHasOpen then
      begin
        if not TTransponderAssignmentService.Unassign(lRaceId, ACompetitorId, lResult) then
        begin
          SmartTimingTools.ShowDialog(lResult.Message, '', [tcbOk], tcbOk);
          Exit(False);
        end;
      end;
      Continue;
    end;

    (* Only touch open assignments or races that already block chip reuse. *)
    if (not lHasOpen) and
       (not TTransponderAssignmentService.IsRaceStatusActiveForChipConflict(lStatus)) then
      Continue;

    if not TTransponderAssignmentService.Assign(lRaceId, ACompetitorId, AChipId, lResult) then
    begin
      SmartTimingTools.ShowDialog(lResult.Message, '', [tcbOk], tcbOk);
      Exit(False);
    end;
  end;
end;

{==============================================================================}
procedure TFormCompetitorDetails.ButtonOKClick(Sender: TObject);
var
  lTxId: string;
  lCompetitorId: Integer;
begin
  ModalResult := mrNone;

  if FIsInsert then
    FDataSource.DataSet.FieldByName('COMPETITORID').Value := MainDataModule.GetMaxCompetitorId + 1;

  lTxId := Trim(DBEditTxId.EditText);
  if lTxId <> '' then
  begin
    if not TTransponderMappingStore.GetSingleton.ConvertToValidChipId(lTxId) then
    begin
      ShowMessage('Keine gültige Transponder ID.');
      Exit;
    end;
    lTxId := NormalizeChipId(lTxId);
  end;
  DBEditTxId.EditText := lTxId;
  FDataSource.DataSet.FieldByName('CHIPID').AsString := lTxId;

  (* Ensure PK is marked for DataSetProvider (upWhereKeyOnly / poAutoRefresh). *)
  with FDataSource.DataSet.FieldByName('COMPETITORID') do
    ProviderFlags := ProviderFlags + [pfInKey];

  FDataSource.DataSet.Post;
  TClientDataSet(FDataSource.DataSet).ApplyUpdates(0);

  lCompetitorId := FDataSource.DataSet.FieldByName('COMPETITORID').AsInteger;
  if not SyncChipAssignments(lCompetitorId, lTxId) then
    Exit;

  ModalResult := mrOk;
end;

end.
