unit SmartStarting.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, DateUtils, MMSystem,
  Generics.Collections;

type
  TCompetitorInfo = record
    Bib: string;
    LastName: string;
    FirstName: string;
    TeamName: string;
    StartTime: string;
  end;

  TFormMain = class(TForm)
    PanelTime: TPanel;
    PanelCompetitorInfo: TPanel;
    PanelControls: TPanel;
    LabelCompetitorInfo: TLabel;
    ButtonExit: TButton;
    TimerSeconds: TTimer;
    ButtonSwitchDarkMode: TButton;
    ButtonIntervalSettings: TButton;
    ButtonImportStartingList: TButton;
    FileOpenDialog: TFileOpenDialog;
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonExitClick(Sender: TObject);
    procedure TimerSecondsTimer(Sender: TObject);
    procedure ButtonSwitchDarkModeClick(Sender: TObject);
    procedure ButtonIntervalSettingsClick(Sender: TObject);
    procedure ButtonImportStartingListClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FStdFontSizeBib: integer;
    FStdFontSizeCompetitorInfo: integer;
    FStdFontSizeTime: integer;
    FStdFormWidth: integer;
    FStdFormHeight: integer;
    FStdPanelCompetitorInfoHeight: integer;
    FTimerCalibration: boolean;
    FNow: TDatetime;
    FCompetitors: TDictionary<TDatetime, TCompetitorInfo>;

    procedure CalibrateTimer;
    procedure SwitchDarkMode(AOn: boolean);
    procedure DisplayNextCompetitor;
  public
    { Public-Deklarationen }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

resourcestring
  cMessageSureAboutExiting = 'Programm wirklich beenden?';
  cMessageImportDeletesActualList = 'Der Import löscht die aktuelle Starterliste. Sind Sie sicher?';

{==============================================================================}
procedure TFormMain.ButtonExitClick(Sender: TObject);
begin
  if SmartTimingTools.ShowDialog(cMessageSureAboutExiting, 'SmartStarting', [tcbYes, tcbNo], tcbNo) = mrYes then
    Application.Terminate;
end;

{==============================================================================}
procedure TFormMain.SwitchDarkMode(AOn: boolean);
var
  lBgColor: TColor;
  lFgColor: TColor;
begin
  if AOn then
  begin
    lBgColor := clWindowText;
    lFgColor := clWindow;
  end
  else
  begin
    lBgColor := clWindow;
    lFgColor := clWindowText;
  end;

  FormMain.Color := lBgColor;
  PanelCompetitorInfo.Font.Color := lFgColor;
  LabelCompetitorInfo.Font.Color := lFgColor;
  PanelTime.Font.Color := lFgColor;
end;

{==============================================================================}
procedure TFormMain.DisplayNextCompetitor;
var
  lHour, lMinute, lSeconds, lMSecs: Word;
  lNextStartTime: TDatetime;
  lCompetitorInfo: TCompetitorInfo;
begin
  PanelCompetitorInfo.Caption := '';
  LabelCompetitorInfo.Caption := '';
  DecodeTime(FNow, lHour, lMinute, lSeconds, lMSecs);
  lNextStartTime := EncodeTime(lHour, lMinute, 0, 0);
  lNextStartTime.AddMinute;
  if FCompetitors.TryGetValue(lNextStartTime, lCompetitorInfo) then
  begin
    PanelCompetitorInfo.Caption := ' ' + lCompetitorInfo.Bib;
    LabelCompetitorInfo.Caption := lCompetitorInfo.LastName + ', ' + lCompetitorInfo.FirstName + #13#10 + lCompetitorInfo.TeamName;
  end;
end;

{==============================================================================}
procedure TFormMain.ButtonImportStartingListClick(Sender: TObject);
var
  lFileLines: TStringList;
  lFileFields: TArray<string>;
  i: integer;

  function GetFieldValue(const AFieldName: string; var AValue: string): boolean;
  var
    lFieldIndex: integer;
  begin
    result := false;
    for lFieldIndex := 0 to High(lFileFields) do
    begin
      if SameText(lFileFields[lFieldIndex], AFieldName) then
      begin
        AValue := lFileLines[i].Split([';'])[lFieldIndex];
        Exit(true);
      end;
    end;
  end;

  procedure AddCompetitorInfo(AIndex: Integer);
  var
    lCompetitorInfo: TCompetitorInfo;
    lFieldIndex: integer;
    lHour, lMin, lSec, lMSec: Word;
    lStartTime: TDatetime;
  begin
    if not GetFieldValue('No', lCompetitorInfo.Bib) then
      Exit;
    if not GetFieldValue('FirstName', lCompetitorInfo.FirstName) then
      lCompetitorInfo.FirstName := '???';
    if not GetFieldValue('LastName', lCompetitorInfo.LastName) then
      lCompetitorInfo.FirstName := '???';
    if not GetFieldValue('Additional7', lCompetitorInfo.TeamName) or lCompetitorInfo.TeamName.IsEmpty then
      GetFieldValue('Additional5', lCompetitorInfo.TeamName);
    if not GetFieldValue('Starttime', lCompetitorInfo.StartTime) then
      Exit;

    if not TryStrToDatetime(lCompetitorInfo.StartTime, lStartTime) then
      lStartTime := StrToTime(lCompetitorInfo.StartTime);
    DecodeTime(lStartTime, lHour, lMin, lSec, lMSec);
    lStartTime := 0.0;
    lStartTime := EncodeTime(lHour, lMin, lSec, 0);
    FCompetitors.Add(lStartTime, lCompetitorInfo);
  end;

begin
  if SmartTimingTools.ShowDialog(cMessageImportDeletesActualList, 'SmartStarting', [tcbYes, tcbNo], tcbNo) <> mrYes then
    Exit;

  if not FileOpenDialog.Execute then
    Exit;

  FCompetitors.Clear;

  lFileLines := TStringList.Create;
  try
    lFileLines.LoadFromFile(FileOpenDialog.FileName);
    if lFileLines.Count < 2 then
    begin
      ShowMessage('Die Datei ist leer.');
      Exit;
    end;

    lFileFields := lFileLines[0].Split([';']);
    for i := 0 to Length(lFileFields) - 1 do
      lFileFields[i] := lFileFields[i].Trim;

    for i := 1 to lFileLines.Count - 1 do
      AddCompetitorInfo(i);

  finally
    FreeAndNil(lFileLines);
  end;

  DisplayNextCompetitor;
end;

{==============================================================================}
procedure TFormMain.ButtonIntervalSettingsClick(Sender: TObject);
begin
  // TODO Open settings form
end;

{==============================================================================}
procedure TFormMain.ButtonSwitchDarkModeClick(Sender: TObject);
begin
  SwitchDarkMode(FormMain.Color = clWindow);
end;

{==============================================================================}
procedure TFormMain.FormCreate(Sender: TObject);
var
  lTimerBias: integer;
begin
  FStdFontSizeBib := 120;
  FStdFontSizeCompetitorInfo := 40;
  FStdFontSizeTime := 180;
  FStdFormWidth := 1000;
  FStdFormHeight := 614;
  FStdPanelCompetitorInfoHeight := 250;

  CalibrateTimer;
  FCompetitors := TDictionary<TDatetime, TCompetitorInfo>.Create;
  DisplayNextCompetitor;
end;

{==============================================================================}
procedure TFormMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FCompetitors);
end;

{==============================================================================}
procedure TFormMain.CalibrateTimer;
var
  lYear, lMonth, lDay, lHour, lMin, lSec, lMilli: Word;
begin
  FTimerCalibration := true;
  DecodeDateTime(Now, lYear, lMonth, lDay, lHour, lMin, lSec, lMilli);
  TimerSeconds.Interval := 1000 - lMilli;
  TimerSeconds.Enabled := true;
end;

{==============================================================================}
procedure TFormMain.FormResize(Sender: TObject);
var
  lFactor: double;
begin
  lFactor := Width / FStdFormWidth;
  LabelCompetitorInfo.Width := Trunc(600 * lFactor);
  LabelCompetitorInfo.Height :=  Trunc(FStdPanelCompetitorInfoHeight * lFactor);
  LabelCompetitorInfo.Font.Size := Trunc(FStdFontSizeCompetitorInfo * lFactor);
  PanelCompetitorInfo.Font.Size := Trunc(FStdFontSizeBib * lFactor);
  PanelTime.Font.Size := Trunc(FStdFontSizeTime * lFactor);
end;

{==============================================================================}
procedure TFormMain.TimerSecondsTimer(Sender: TObject);
var
  lSeconds: Word;
begin
  if FTimerCalibration then
  begin
    TimerSeconds.Enabled := false;
    TimerSeconds.Interval := 1000;
    TimerSeconds.Enabled := true;
    FTimerCalibration := false;
    Exit;
  end;

  FNow := Now;
  lSeconds := DateUtils.SecondOfTheMinute(FNow);
  if (lSeconds = 50) or (lSeconds > 54)  then
    PlaySound('LastSecondsBeep', 0, SND_NOSTOP or SND_NOWAIT or SND_RESOURCE or SND_ASYNC or SND_NODEFAULT);
  if lSeconds = 0 then
    PlaySound('StartBeep', 0, SND_NOSTOP or SND_NOWAIT or SND_RESOURCE or SND_ASYNC or SND_NODEFAULT);
  PanelTime.Caption := FormatDatetime('hh:mm:ss', FNow);
  if lSeconds = 2 then
    DisplayNextCompetitor;
end;

end.
