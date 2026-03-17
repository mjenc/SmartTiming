unit SmartStartListServer.MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Samples.Spin,
  SmartStartListServer.Backend;

type
  TFormSmartStartListServer = class(TForm)
    PanelTop: TPanel;
    LabelCsv: TLabel;
    EditCsv: TEdit;
    ButtonBrowse: TButton;
    LabelPort: TLabel;
    SpinEditPort: TSpinEdit;
    ButtonStart: TButton;
    ButtonStop: TButton;
    ButtonSaveMapping: TButton;
    ButtonLoadMapping: TButton;
    OpenDialogCsv: TOpenDialog;
    GroupBoxMapping: TGroupBox;
    LabelClass: TLabel;
    LabelBib: TLabel;
    LabelFirstName: TLabel;
    LabelLastName: TLabel;
    LabelClub: TLabel;
    LabelTeam: TLabel;
    LabelNationality: TLabel;
    LabelUciId: TLabel;
    LabelStartTime: TLabel;
    ComboClass: TComboBox;
    ComboBib: TComboBox;
    ComboFirstName: TComboBox;
    ComboLastName: TComboBox;
    ComboClub: TComboBox;
    ComboTeam: TComboBox;
    ComboNationality: TComboBox;
    ComboUciId: TComboBox;
    ComboStartTime: TComboBox;
    MemoLog: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonBrowseClick(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
    procedure ButtonStopClick(Sender: TObject);
    procedure ButtonSaveMappingClick(Sender: TObject);
    procedure ButtonLoadMappingClick(Sender: TObject);
  private
    FServer: TStartListServer;
    procedure LoadHeaderColumnsToCombos;
    procedure MappingToUI;
    procedure UIToMapping;
    procedure Log(const AMsg: string);
  public
  end;

var
  FormSmartStartListServer: TFormSmartStartListServer;

implementation

{$R *.dfm}

procedure TFormSmartStartListServer.FormCreate(Sender: TObject);
begin
  FServer := TStartListServer.Create(Log);
  SpinEditPort.Value := FServer.Port;
  EditCsv.Text := FServer.CsvFileName;
  UIToMapping;
end;

procedure TFormSmartStartListServer.FormDestroy(Sender: TObject);
begin
  FServer.Free;
end;

procedure TFormSmartStartListServer.Log(const AMsg: string);
begin
  MemoLog.Lines.Add(FormatDateTime('hh:nn:ss', Now) + ' ' + AMsg);
end;

procedure TFormSmartStartListServer.ButtonBrowseClick(Sender: TObject);
begin
  if OpenDialogCsv.Execute then
  begin
    EditCsv.Text := OpenDialogCsv.FileName;
    FServer.CsvFileName := EditCsv.Text;
    LoadHeaderColumnsToCombos;
    ButtonLoadMappingClick(nil);
  end;
end;

procedure TFormSmartStartListServer.LoadHeaderColumnsToCombos;
var
  lines: TStringList;
  header: TArray<string>;

  procedure FillCombo(ACombo: TComboBox);
  var
    i: Integer;
  begin
    ACombo.Items.BeginUpdate;
    try
      ACombo.Items.Clear;
      ACombo.Items.Add('(keine)');
      for i := 0 to Length(header) - 1 do
        ACombo.Items.Add(Format('%d: %s', [i, header[i].Trim]));
      ACombo.ItemIndex := 0;
    finally
      ACombo.Items.EndUpdate;
    end;
  end;

begin
  if not FileExists(EditCsv.Text) then
    Exit;

  lines := TStringList.Create;
  try
    lines.LoadFromFile(EditCsv.Text); //, TEncoding.UTF8);
    if lines.Count = 0 then
      Exit;

    header := lines[0].Split([';']);

    FillCombo(ComboClass);
    FillCombo(ComboBib);
    FillCombo(ComboFirstName);
    FillCombo(ComboLastName);
    FillCombo(ComboClub);
    FillCombo(ComboTeam);
    FillCombo(ComboNationality);
    FillCombo(ComboUciId);
    FillCombo(ComboStartTime);
  finally
    lines.Free;
  end;
end;

procedure TFormSmartStartListServer.MappingToUI;

  procedure SetComboFromIndex(ACombo: TComboBox; AIndex: Integer);
  begin
    if ACombo.Items.Count = 0 then
      Exit;
    if AIndex < 0 then
      ACombo.ItemIndex := 0 // (keine)
    else if AIndex + 1 < ACombo.Items.Count then
      ACombo.ItemIndex := AIndex + 1;
  end;

begin
  SetComboFromIndex(ComboClass,       FServer.ColumnMapping[slfClass]);
  SetComboFromIndex(ComboBib,         FServer.ColumnMapping[slfBib]);
  SetComboFromIndex(ComboFirstName,   FServer.ColumnMapping[slfFirstName]);
  SetComboFromIndex(ComboLastName,    FServer.ColumnMapping[slfLastName]);
  SetComboFromIndex(ComboClub,        FServer.ColumnMapping[slfClub]);
  SetComboFromIndex(ComboTeam,        FServer.ColumnMapping[slfTeam]);
  SetComboFromIndex(ComboNationality, FServer.ColumnMapping[slfNationality]);
  SetComboFromIndex(ComboUciId,       FServer.ColumnMapping[slfUciId]);
  SetComboFromIndex(ComboStartTime,   FServer.ColumnMapping[slfStartTime]);
end;

procedure TFormSmartStartListServer.UIToMapping;

  function GetIndexFromCombo(ACombo: TComboBox): Integer;
  begin
    if ACombo.ItemIndex <= 0 then
      Result := -1
    else
      Result := ACombo.ItemIndex - 1;
  end;

var
  m: TColumnMapping;
begin
  m := FServer.ColumnMapping;
  m[slfClass]       := GetIndexFromCombo(ComboClass);
  m[slfBib]         := GetIndexFromCombo(ComboBib);
  m[slfFirstName]   := GetIndexFromCombo(ComboFirstName);
  m[slfLastName]    := GetIndexFromCombo(ComboLastName);
  m[slfClub]        := GetIndexFromCombo(ComboClub);
  m[slfTeam]        := GetIndexFromCombo(ComboTeam);
  m[slfNationality] := GetIndexFromCombo(ComboNationality);
  m[slfUciId]       := GetIndexFromCombo(ComboUciId);
  m[slfStartTime]   := GetIndexFromCombo(ComboStartTime);
  FServer.ColumnMapping := m;
end;

procedure TFormSmartStartListServer.ButtonStartClick(Sender: TObject);
begin
  UIToMapping;
  FServer.Port := SpinEditPort.Value;
  FServer.CsvFileName := EditCsv.Text;
  FServer.Start;
  Log(Format('Server gestartet auf Port %d, Datei: %s', [FServer.Port, FServer.CsvFileName]));
end;

procedure TFormSmartStartListServer.ButtonStopClick(Sender: TObject);
begin
  FServer.Stop;
  Log('Server gestoppt');
end;

procedure TFormSmartStartListServer.ButtonSaveMappingClick(Sender: TObject);
begin
  UIToMapping;
  FServer.SaveMappingToRegistry;
  Log('Spaltenmapping in der Registry gespeichert.');
end;

procedure TFormSmartStartListServer.ButtonLoadMappingClick(Sender: TObject);
begin
  FServer.LoadMappingFromRegistry;
  MappingToUI;
  Log('Spaltenmapping aus der Registry geladen.');
end;

end.

