unit FormCompetitorImport;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids,
  SmartTiming.Consts, DataModule, DB, Vcl.ComCtrls, Data.FMTBcd, Data.SqlExpr,
  Data.DbxSqlite, Datasnap.DBClient, Datasnap.Provider, SqlTimSt,
  SmartTiming.Cache;

type
  TFormCompetitorImport = class(TForm)
    PanelButtons: TPanel;
    ButtonOK: TButton;
    ButtonCancel: TButton;
    PanelMappings: TPanel;
    StringGridFieldMapping: TStringGrid;
    ComboBoxFileColumns: TComboBox;
    FileOpenDialog: TFileOpenDialog;
    Label1: TLabel;
    PanelGrid: TPanel;
    StringGridPreview: TStringGrid;
    Label2: TLabel;
    ProgressBar: TProgressBar;
    LabelProgress: TLabel;
    procedure StringGridFieldMappingGetEditText(Sender: TObject; ACol,
      ARow: Integer; var Value: string);
    procedure FormCreate(Sender: TObject);
    procedure ComboBoxFileColumnsExit(Sender: TObject);
    procedure StringGridFieldMappingSelectCell(Sender: TObject; ACol,
      ARow: Integer; var CanSelect: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
  private
    FFileLines: TStringList;
    FFileFields: TArray<string>;
    FDelimiter: Char;

    procedure CMDialogKey(var msg: TCMDialogKey); message CM_DIALOGKEY;
    procedure LoadFile;
    procedure TryApplyStandardMapping;
    procedure RefreshPreview;
    function GetFileFieldIndex(const ATitle: string): integer;
    function GetFileFieldIndexFromColumn(const AColumn: string): integer;
    function GetIntegerValueFromFileLines(ACol, ARow: integer): Variant;
    function GetStringValueFromFileLines(ACol, ARow: integer): Variant;
    function GetStarttimeValueFromFileLines(ACol, ARow: integer): Variant;
    function GetChipIdValueFromFileLines(ACol, ARow: integer): Variant;
    function GetMaxCompetitorId: integer;
  public
    { Public-Deklarationen }
  end;

  TFnReadFunction = function(ACol, ARow: integer): Variant of object;

var
  GFormCompetitorImport: TFormCompetitorImport;

implementation

{$R *.dfm}


{==============================================================================}
procedure TFormCompetitorImport.FormCreate(Sender: TObject);
begin
  FFileLines := TStringList.Create;

  ComboBoxFileColumns.Parent := StringGridFieldMapping;
  ComboBoxFileColumns.Visible := false;

  StringGridFieldMapping.RowCount := 10;
  StringGridFieldMapping.Cells[0, 0] := cFieldTitleBib;
  StringGridFieldMapping.Cells[0, 1] := cFieldTitleClass;
  StringGridFieldMapping.Cells[0, 2] := cFieldTitleFirstName;
  StringGridFieldMapping.Cells[0, 3] := cFieldTitleLastName;
  StringGridFieldMapping.Cells[0, 4] := cFieldTitleClub;
  StringGridFieldMapping.Cells[0, 5] := cFieldTitleTeam;
  StringGridFieldMapping.Cells[0, 6] := cFieldTitleNationality;
  StringGridFieldMapping.Cells[0, 7] := cFieldTitleUCIID;
  StringGridFieldMapping.Cells[0, 8] := cFieldTitleStarttime;
  StringGridFieldMapping.Cells[0, 9] := cFieldTitleTransponder;

  StringGridPreview.ColCount := 10;
  StringGridPreview.Cells[0, 0] := cFieldTitleBib;
  StringGridPreview.Cells[1, 0] := cFieldTitleClass;
  StringGridPreview.Cells[2, 0] := cFieldTitleFirstName;
  StringGridPreview.Cells[3, 0] := cFieldTitleLastName;
  StringGridPreview.Cells[4, 0] := cFieldTitleClub;
  StringGridPreview.Cells[5, 0] := cFieldTitleTeam;
  StringGridPreview.Cells[6, 0] := cFieldTitleNationality;
  StringGridPreview.Cells[7, 0] := cFieldTitleUCIID;
  StringGridPreview.Cells[8, 0] := cFieldTitleStarttime;
  StringGridPreview.Cells[9, 0] := cFieldTitleTransponder;

  if FileOpenDialog.Execute then
  begin
    LoadFile;
    TryApplyStandardMapping;
    RefreshPreview;
  end;
end;

{==============================================================================}
procedure TFormCompetitorImport.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FFileLines);
end;

{==============================================================================}
procedure TFormCompetitorImport.LoadFile;
var
  i: integer;
begin
  ComboBoxFileColumns.Clear;
  FFileLines.Clear;
  FFileLines.LoadFromFile(FileOpenDialog.FileName);
  if FFileLines.Count < 2 then
  begin
    ShowMessage('Die Datei ist leer.');
    Close;
  end;

  if FFileLines[0].Contains(';') then
    FDelimiter := ';'
  else
    FDelimiter := ',';
  FFileFields := FFileLines[0].Split([FDelimiter]);
  for i := 0 to Length(FFileFields) - 1 do
  begin
    FFileFields[i] := FFileFields[i].Trim;
    ComboBoxFileColumns.Items.Add(FFileFields[i]);
  end;
end;

{==============================================================================}
function TFormCompetitorImport.GetMaxCompetitorId: integer;
var
  lDataSet: TSQLDataSet;
begin
  lDataSet := MainDataModule.OpenReadOnlyQuery('SELECT MAX(COMPETITORID) FROM COMPETITORS');
  try
    if (lDataSet = nil) or not lDataSet.Active or lDataSet.IsEmpty or
       lDataSet.Fields[0].IsNull then
      Exit(1);
    Exit(lDataSet.Fields[0].AsInteger);
  finally
    FreeAndNil(lDataSet);
  end;
end;

{==============================================================================}
function TFormCompetitorImport.GetFileFieldIndex(const ATitle: string): integer;
begin
  for result := 0 to Length(FFileFields) - 1 do
  begin
    if SameText(FFileFields[result], ATitle) then
      Exit;
  end;
  result := -1;
end;

{==============================================================================}
function TFormCompetitorImport.GetFileFieldIndexFromColumn(const AColumn: string): integer;
var
  i: integer;
begin
  for i := 0 to StringGridFieldMapping.RowCount - 1 do
  begin
    if not SameText(StringGridFieldMapping.Cells[0, i], AColumn) then
      Continue;
    Exit(i);
  end;
  Exit(-1);
end;

{==============================================================================}
function TFormCompetitorImport.GetIntegerValueFromFileLines(ACol, ARow: integer): Variant;
var
  lStringValue: string;
begin
  if ACol < 0 then
    Exit(0);
  lStringValue := StringGridPreview.Cells[ACol, ARow];
  if lStringValue.IsEmpty then
    Exit(0);
  result := lStringValue.ToInteger;
end;

{==============================================================================}
function TFormCompetitorImport.GetChipIdValueFromFileLines(ACol, ARow: integer): Variant;
var
  lStringValue: string;
begin
  if ACol < 0 then
    Exit('');
  lStringValue := StringGridPreview.Cells[ACol, ARow];
  if lStringValue.IsEmpty then
    Exit('');
  if CharInSet(lStringValue[1], ['0'..'9']) then
    Exit(TTransponderMappingStore.GetSingleton.GetTransponderIdFromShortId(lStringValue.ToInteger));
  Exit(lStringValue);
end;

{==============================================================================}
function TFormCompetitorImport.GetStringValueFromFileLines(ACol, ARow: integer): Variant;
begin
  Exit(StringGridPreview.Cells[ACol, ARow]);
end;

{==============================================================================}
function TFormCompetitorImport.GetStarttimeValueFromFileLines(ACol, ARow: integer): Variant;
var
  lHour, lMin, lSec, lMSec: Word;
  lDatetime: TDatetime;
begin
  if not TryStrToDatetime(StringGridPreview.Cells[ACol, ARow], lDatetime) then
    result := StrToTime(StringGridPreview.Cells[ACol, ARow]);

  DecodeTime(lDatetime, lHour, lMin, lSec, lMSec);
  result := 0.0;
  result := EncodeTime(lHour, lMin, lSec, 0);
end;

{==============================================================================}
procedure TFormCompetitorImport.TryApplyStandardMapping;
  function TryToMap(ALine: integer; const AGridFieldName: string; const ATryFieldNames: TArray<string>): boolean;
  var
    i, j: integer;
  begin
    result := false;
    if not SameText(StringGridFieldMapping.Cells[0, ALine], AGridFieldName) then
      Exit;
    for i := 0 to Length(ATryFieldNames) - 1 do
    begin
      for j := 0 to Length(FFileFields) - 1 do
      begin
        if not SameText(FFileFields[j], ATryFieldNames[i]) then
          Continue;

        StringGridFieldMapping.Cells[1, ALine] := FFileFields[j];
        Exit(true);
      end;
    end;
  end;

var
  i: integer;
begin
  for i := 0 to StringGridFieldMapping.RowCount - 1 do
  begin
    if TryToMap(i, cFieldTitleBib, ['No','Nr','Nummer','Number']) then
      Continue;
    if TryToMap(i, cFieldTitleClass, ['Class','Klasse']) then
      Continue;
    if TryToMap(i, cFieldTitleFirstName, ['FirstName','Vorname']) then
      Continue;
    if TryToMap(i, cFieldTitleLastName, ['LastName','Nachname']) then
      Continue;
    if TryToMap(i, cFieldTitleClub, ['Club','Verein','Additional5']) then
      Continue;
    if TryToMap(i, cFieldTitleTeam, ['Team','Additional7']) then
      Continue;
    if TryToMap(i, cFieldTitleUCIID, ['UCIID','UCI-ID','Additional2']) then
      Continue;
    if TryToMap(i, cFieldTitleTransponder, ['Transponder','Transponder1']) then
      Continue;
    if TryToMap(i, cFieldTitleStartTime, ['Starttime']) then
      Continue;
  end;
end;

{==============================================================================}
procedure TFormCompetitorImport.RefreshPreview;
var
  lRow: integer;
  lCol: integer;
  lFileFieldName: string;
  lFileFieldIndex: integer;
  lLine: TArray<string>;
begin
  StringGridPreview.RowCount := FFileLines.Count;
  for lRow := 1 to FFileLines.Count - 1 do
  begin
    for lCol := 0 to StringGridFieldMapping.RowCount - 1 do
    begin
      lFileFieldName := StringGridFieldMapping.Cells[1, lCol];
      if lFileFieldName.IsEmpty then
        Continue;
      lFileFieldIndex := GetFileFieldIndex(lFileFieldName);
      if lFileFieldIndex < 0 then
        Continue;
      lLine := FFileLines[lRow].Split([FDelimiter]);
      StringGridPreview.Cells[lCol, lRow] := lLine[lFileFieldIndex];
    end;
  end;
end;

{==============================================================================}
procedure TFormCompetitorImport.ComboBoxFileColumnsExit(Sender: TObject);
begin
  TComboBox(Sender).Hide;
  if TComboBox(Sender).ItemIndex < 0 then
    Exit;
  StringGridFieldMapping.Cells[StringGridFieldMapping.col, StringGridFieldMapping.row] := TComboBox(Sender).Items[TComboBox(Sender).ItemIndex];
  RefreshPreview;
end;

{==============================================================================}
procedure TFormCompetitorImport.ButtonOKClick(Sender: TObject);
const
  cSQLFormat =
    'INSERT INTO COMPETITORS (CLASS,BIB,FIRSTNAME,LASTNAME,CLUB,TEAM,NATIONALITY,UCIID,TRANSPONDERID) ' +
    'VALUES (%s,%d,%s,%s,%s,%s,%s,%s,%d)';
var
  i: integer;
  lCompetitorId: integer;

  procedure FillValue(const AFieldName, AFieldTitle: string; AReadFunction: TFnReadFunction; ADefault: Variant);
  var
    lCol: integer;
  begin
    lCol := GetFileFieldIndexFromColumn(AFieldTitle);
    if (lCol < 0) or StringGridPreview.Cells[lCol, i].IsEmpty then
    begin
      MainDataModule.ClientDataSetCompetitors.FieldByName(AFieldName).Value := ADefault;
      Exit;
    end;
    MainDataModule.ClientDataSetCompetitors.FieldByName(AFieldName).Value := AReadFunction(lCol, i);
  end;

begin
  ProgressBar.Visible := true;
  ProgressBar.Max := FFileLines.Count;
  lCompetitorId := GetMaxCompetitorId;
  TTransponderMappingStore.GetSingleton;

  MainDataModule.ClientDataSetCompetitors.Active := false;
  MainDataModule.SQLDataSetCompetitors.Active := false;
  MainDataModule.SQLDataSetCompetitors.CommandText :=
    'SELECT * FROM COMPETITORS ORDER BY COMPETITORID';
  MainDataModule.SQLDataSetCompetitors.Active := true;
  MainDataModule.EnsureProviderKeyField(MainDataModule.SQLDataSetCompetitors, 'COMPETITORID');
  MainDataModule.ClientDataSetCompetitors.Active := true;
  MainDataModule.EnsureProviderKeyField(MainDataModule.ClientDataSetCompetitors, 'COMPETITORID');

  MainDataModule.ClientDataSetCompetitors.DisableControls;
  try
    for i := 1 to FFileLines.Count - 1 do
    begin
      if FFileLines[i].Trim.IsEmpty then
        Continue;
      MainDataModule.ClientDataSetCompetitors.Append;
      MainDataModule.ClientDataSetCompetitors.FieldByName('COMPETITORID').Value := lCompetitorId + i;
      FillValue('CLASS', cFieldTitleClass, GetStringValueFromFileLines, 'Unbekannt');
      FillValue('BIB', cFieldTitleBib, GetIntegerValueFromFileLines, -1);
      FillValue('FIRSTNAME', cFieldTitleFirstName, GetStringValueFromFileLines, null);
      FillValue('LASTNAME', cFieldTitleLastName, GetStringValueFromFileLines, null);
      FillValue('CLUB', cFieldTitleClub, GetStringValueFromFileLines, null);
      FillValue('TEAM', cFieldTitleTeam, GetStringValueFromFileLines, null);
      FillValue('NATIONALITY', cFieldTitleNationality, GetStringValueFromFileLines, null);
      FillValue('UCIID', cFieldTitleUCIID, GetStringValueFromFileLines, null);
      FillValue('STARTTIME',cFieldTitleStarttime, GetStarttimeValueFromFileLines, 0);
      FillValue('CHIPID', cFieldTitleTransponder, GetChipIdValueFromFileLines, -1);
      FillValue('HANDICAPFACTOR', cFieldTitleHandicapFactor, GetIntegerValueFromFileLines, 100);
      MainDataModule.ClientDataSetCompetitors.Post;
      LabelProgress.Caption := Format('%d von %d importiert', [i, FFileLines.Count]);
      ProgressBar.StepIt;
    end;
    MainDataModule.PostAndApplyClientDataSet(MainDataModule.ClientDataSetCompetitors,
      'COMPETITORID', MainDataModule.SQLDataSetCompetitors);
  finally
    MainDataModule.ClientDataSetCompetitors.EnableControls;
  end;
end;

{==============================================================================}
procedure TFormCompetitorImport.CMDialogKey(var msg: TCMDialogKey);
begin
  if (ActiveControl = ComboBoxFileColumns) and (msg.CharCode = VK_TAB) then
  begin
    StringGridFieldMapping.SetFocus;
    StringGridFieldMapping.Perform(WM_KEYDOWN, msg.CharCode, msg.KeyData);
    msg.Result := 1;
  end
  else
    inherited;
end;

{==============================================================================}
procedure TFormCompetitorImport.StringGridFieldMappingGetEditText(Sender: TObject; ACol, ARow: Integer; var Value: string);
begin
  if ACol = 0 then
  begin
    case ARow of
    0: Value := 'StartNr';
    1: Value := 'Klasse';
    2: Value := 'Vorname';
    3: Value := 'Nachname';
    4: Value := 'Verein';
    5: Value := 'Team';
    6: Value := 'UCI-ID';
    7: Value := 'Transponder';
    end;
  end;
end;

{==============================================================================}
procedure TFormCompetitorImport.StringGridFieldMappingSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
var
  R: TRect;
  org: TPoint;
begin
  if (ACol = 1) and (ARow >= StringGridFieldMapping.FixedRows) then begin
    StringGridFieldMapping.Perform(WM_CANCELMODE, 0, 0);
    R := StringGridFieldMapping.CellRect(ACol, ARow);
    org := self.ScreenToClient(self.ClientToScreen(R.TopLeft));
    ComboBoxFileColumns.SetBounds(org.X, org.Y, R.Right-R.Left, StringGridFieldMapping.Height);
    ComboBoxFileColumns.ItemIndex := ComboBoxFileColumns.Items.IndexOf(StringGridFieldMapping.Cells[ACol, ARow]);
    ComboBoxFileColumns.Show;
    ComboBoxFileColumns.BringToFront;
    ComboBoxFileColumns.SetFocus;
    ComboBoxFileColumns.DroppedDown := true;
  end;
end;


end.
