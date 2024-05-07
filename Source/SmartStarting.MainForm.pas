unit SmartStarting.MainForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, Generics.Collections, FMX.Media, IOUtils,
  DateUtils, FMX.Objects, SmartTiming.Consts, SmartStarting.SettingsForm;

type
  TCompetitorInfo = record
    Bib: string;
    LastName: string;
    FirstName: string;
    TeamName: string;
    StartTime: string;
  end;

  TSmartStartingForm = class(TForm)
    LabelTime: TLabel;
    LabelCompetitorName: TLabel;
    TimerSeconds: TTimer;
    ButtonExit: TButton;
    ButtonSwitchDarkMode: TButton;
    ButtonSettings: TButton;
    ButtonImportStartingList: TButton;
    OpenDialog: TOpenDialog;
    AreaCompetitorInfo: TRectangle;
    AreaTime: TRectangle;
    LabelBib: TLabel;
    LabelCompetitorTeam: TLabel;
    AreaCompetitorDescription: TRectangle;
    AreaControls: TRectangle;
    MediaPlayerLastSeconds: TMediaPlayer;
    MediaPlayerStart: TMediaPlayer;
    procedure ButtonExitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonSwitchDarkModeClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure TimerSecondsTimer(Sender: TObject);
    procedure ButtonImportStartingListClick(Sender: TObject);
    procedure ButtonSettingsClick(Sender: TObject);
  private
    FStdFontSizeBib: integer;
    FStdFontSizeCompetitorInfo: integer;
    FStdFontSizeTime: integer;
    FStdFormWidth: integer;
    FStdFormHeight: integer;
    FStdPanelCompetitorInfoHeight: integer;
    FTimerCalibration: boolean;
    FNow: TDatetime;
    FStartSeconds: set of Byte;
    FLastSeconds: set of Byte;
    FNextCompetitorSecond: set of Byte;

    FIntervalSeconds: integer;
    FStartListServer: string;
    FPlaySound: boolean;

    FCompetitors: TDictionary<TDatetime, TCompetitorInfo>;
    FFormSettings: TFormSettings;

    procedure SaveSettings;
    procedure LoadSettings;
    procedure CalibrateTimer;
    procedure SwitchDarkMode(AOn: boolean);
    procedure DisplayNextCompetitor;
    function SaveResourceAsTempFile(const AResourceId: string): string;
    procedure PlayLastSecondsBeep;
    procedure PlayStartBeep;
    procedure GetStartListFromServer;
    function GetPureServerName: string;
  public

  end;

var
  SmartStartingForm: TSmartStartingForm;

implementation

uses
  SmartStarting.WebClient, Tools.Dialogs, Tools.Preferences,
{$IFDEF ANDROID}
  Androidapi.Helpers, Androidapi.Jni.GraphicsContentViewText,
{$ENDIF}
  XSuperObject;

resourcestring
{$IFDEF ANDROID}
  cMessageSureAboutExiting = 'App wirklich beenden?';
{$ELSE}
  cMessageSureAboutExiting = 'Programm wirklich beenden?';
{$ENDIF}
  cMessageImportDeletesActualList = 'Der Import löscht die aktuelle Starterliste. Sind Sie sicher?';

const
  cLastSeconds30 = [25,26,27,28,29,55,56,57,58,59];
  cStartSeconds30 = [0,30];
  cNextCompetitor30 = [2,32];
  cLastSeconds60 = [55,56,57,58,59];
  cStartSeconds60 = [0];
  cNextCompetitor60 = [2];

{$R *.fmx}

{==============================================================================}
procedure TSmartStartingForm.ButtonExitClick(Sender: TObject);
begin
  TApplication.Confirm(cMessageSureAboutExiting,
    procedure(AConfirmed: Boolean)
    begin
      if AConfirmed  then
        Application.Terminate;
    end
  );
end;

{==============================================================================}
function TSmartStartingForm.SaveResourceAsTempFile(const AResourceId: string): string;
var
  lFileName: string;
  lResStream: TResourceStream;
begin
  result := IOUtils.TPath.Combine(IOUtils.TPath.GetDocumentsPath, AResourceId + '.3gp');
  if IOUtils.TFile.Exists(result) then
    Exit;

  lResStream := TResourceStream.Create(HInstance, AResourceId, RT_RCDATA);
  try
    lResStream.Position := 0;
    lResStream.SaveToFile(result);
  finally
    FreeAndNil(lResStream);
  end;
end;

{==============================================================================}
procedure TSmartStartingForm.FormCreate(Sender: TObject);
var
  lFlags: Integer;
begin
  SwitchDarkMode(true);

  FStdFontSizeBib := 180;
  FStdFontSizeCompetitorInfo := 80;
  FStdFontSizeTime := 360;
  FStdFormWidth := 1440;
  FStdFormHeight := 900;
  FStdPanelCompetitorInfoHeight := 360;

  FStartSeconds := cStartSeconds60;
  FLastSeconds := cLastSeconds60;
  FNextCompetitorSecond := cNextCompetitor60;

  CalibrateTimer;
  FCompetitors := TDictionary<TDatetime, TCompetitorInfo>.Create;
//  DisplayNextCompetitor;

{$IFDEF ANDROID}
  MediaPlayerLastSeconds.FileName := SaveResourceAsTempFile('LastSecondsBeep3gp');
  MediaPlayerStart.FileName := SaveResourceAsTempFile('StartBeep3gp');
{$ELSE}
  MediaPlayerLastSeconds.FileName := 'LastSecondsBeep.wav';
  MediaPlayerStart.FileName := 'StartBeep.wav';
{$ENDIF}

  LoadSettings;

  lFlags :=
    TJWindowManager_LayoutParams.JavaClass.FLAG_TURN_SCREEN_ON or
    TJWindowManager_LayoutParams.JavaClass.FLAG_DISMISS_KEYGUARD or
    TJWindowManager_LayoutParams.JavaClass.FLAG_SHOW_WHEN_LOCKED or
    TJWindowManager_LayoutParams.JavaClass.FLAG_KEEP_SCREEN_ON;
  TAndroidHelper.Activity.getWindow.setFlags (lFlags, lFlags);

  FFormSettings := TFormSettings.Create(nil);
end;

{==============================================================================}
procedure TSmartStartingForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FFormSettings);
  FreeAndNil(FCompetitors);
end;

{==============================================================================}
procedure TSmartStartingForm.FormResize(Sender: TObject);
var
  lFactorWidth: double;
  lFactorHeight: double;
begin
  lFactorWidth := Width / FStdFormWidth;
  lFactorHeight := Height / FStdFormHeight;
  AreaCompetitorInfo.Width := Trunc(900 * lFactorWidth);
  AreaCompetitorInfo.Height :=  Trunc(FStdPanelCompetitorInfoHeight * lFactorHeight);
  LabelCompetitorName.Height := AreaCompetitorInfo.Height / 2;
  LabelCompetitorTeam.Height := LabelCompetitorName.Height;
  LabelCompetitorName.Font.Size := Trunc(FStdFontSizeCompetitorInfo * lFactorHeight);
  LabelCompetitorTeam.Font.Size := Trunc(FStdFontSizeCompetitorInfo * lFactorHeight);
  LabelBib.Font.Size := Trunc(FStdFontSizeBib * lFactorHeight);
  LabelTime.Font.Size := Trunc(FStdFontSizeTime * lFactorHeight);
end;

{==============================================================================}
procedure TSmartStartingForm.ButtonImportStartingListClick(Sender: TObject);
begin
  GetStartListFromServer;
  DisplayNextCompetitor;
end;

{==============================================================================}
function TSmartStartingForm.GetPureServerName: string;
var
  lSplitted: TArray<string>;
begin
  lSplitted := FStartListServer.Split([':']);
  if (Length(lSplitted) <> 2) or lSplitted[1].IsEmpty then
    Exit('');
  result := Trim(lSplitted[1]);
end;
{==============================================================================}
procedure TSmartStartingForm.GetStartListFromServer;
var
  lWebClient: TSmartStartingWebClient;
  lJSONString: string;
  lSO: ISuperObject;
  i: integer;

  procedure AddCompetitorInfo(ACompetitorObject: ISuperObject);
  var
    lCompetitorInfo: TCompetitorInfo;
    lTeam: string;
    lHour, lMin, lSec, lMSec: Word;
    lStartTime: TDatetime;
  begin
    lCompetitorInfo.Bib := ACompetitorObject.S['BIB'];
    lCompetitorInfo.LastName := ACompetitorObject.S['LASTNAME'];
    lCompetitorInfo.FirstName := ACompetitorObject.S['FIRSTNAME'];
    lTeam := ACompetitorObject.S['TEAM'];
    if lTeam.IsEmpty then
      lTeam := ACompetitorObject.S['CLUB'];
    lCompetitorInfo.TeamName := lTeam;
    lStartTime := ACompetitorObject.F['STARTTIME'];
    DecodeTime(lStartTime, lHour, lMin, lSec, lMSec);
    try
      lStartTime := EncodeTime(lHour, lMin, lSec, 0);
      FCompetitors.Add(lStartTime, lCompetitorInfo);
    except
      lStartTime := 0.0;
    end;
  end;

begin
  lWebClient := TSmartStartingWebClient.Create(GetPureServerName);
  try
    lJSONString := lWebClient.GetListOfStarters;
    if lJSONString.IsEmpty then
      Exit;

    FCompetitors.Clear;

    lSO := TSuperObject.Create(lJSONString);
    for i := 0 to lSO.A['list'].Length - 1 do
      AddCompetitorInfo(lSO.A['list'].O[i]);
  finally
    FreeAndNil(lWebClient);
  end;
end;

{==============================================================================}
procedure TSmartStartingForm.ButtonSettingsClick(Sender: TObject);
begin
  FFormSettings.OnOK := SaveSettings;
  FFormSettings.CheckBoxLastSecondsSound.IsChecked := FPlaySound;
  FFormSettings.Interval := FIntervalSeconds;
  FFormSettings.StartListServer := FStartListServer;
  FFormSettings.Show;
end;

{==============================================================================}
procedure TSmartStartingForm.ButtonSwitchDarkModeClick(Sender: TObject);
begin
  SwitchDarkMode(AreaTime.Fill.Color = TAlphaColors.White);
end;

{==============================================================================}
procedure TSmartStartingForm.CalibrateTimer;
var
  lYear, lMonth, lDay, lHour, lMin, lSec, lMilli: Word;
begin
  FTimerCalibration := true;
  DecodeDateTime(Now, lYear, lMonth, lDay, lHour, lMin, lSec, lMilli);
  TimerSeconds.Interval := 1000 - lMilli;
  TimerSeconds.Enabled := true;
end;

{==============================================================================}
procedure TSmartStartingForm.SaveSettings;
var
  lPref: TPreferences;
begin
  FStartListServer := FFormSettings.StartListServer;
  FPlaySound := FFormSettings.CheckBoxLastSecondsSound.IsChecked;
  FIntervalSeconds := FFormSettings.Interval;

  lPref := CreatePreferencesObject(cManufacturer, cSmartStartingAppName);
  lPref.SetInteger('IntervalSeconds', FIntervalSeconds);
  lPref.SetString('StartListServer', FStartListServer);
  lPref.GetBoolean('PlaySound', FPlaySound);
  lPref.Save;

  if FIntervalSeconds = 30 then
  begin
    FLastSeconds := cLastSeconds30;
    FStartSeconds := cStartSeconds30;
    FNextCompetitorSecond := cNextCompetitor30;
  end
  else
  begin
    FLastSeconds := cLastSeconds60;
    FStartSeconds := cStartSeconds60;
    FNextCompetitorSecond := cNextCompetitor60;
  end;
end;

{==============================================================================}
procedure TSmartStartingForm.LoadSettings;
var
  lPref: TPreferences;
begin
  lPref := CreatePreferencesObject(cManufacturer, cSmartStartingAppName);
  FIntervalSeconds := lPref.GetInteger('IntervalSeconds', 60);
  FStartListServer := lPref.GetString('StartListServer');
  FPlaySound := lPref.GetBoolean('PlaySound', true);
end;

{==============================================================================}
procedure TSmartStartingForm.SwitchDarkMode(AOn: boolean);
var
  lBgColor: TAlphaColor;
  lFgColor: TAlphaColor;
begin
  if AOn then
  begin
    lBgColor := TAlphaColors.Black;
    lFgColor := TAlphaColors.White;
  end
  else
  begin
    lBgColor := TAlphaColors.White;
    lFgColor := TAlphaColors.Black;
  end;

  Fill.Color := lBgColor;
  AreaTime.Fill.Color := lBgColor;
  AreaCompetitorInfo.Fill.Color := lBgColor;
  AreaCompetitorDescription.Fill.Color := lBgColor;
  AreaControls.Fill.Color := lBgColor;

  LabelBib.FontColor := lFgColor;
  LabelCompetitorName.FontColor := lFgColor;
  LabelCompetitorTeam.FontColor := lFgColor;
  LabelTime.FontColor := lFgColor;
end;

{==============================================================================}
procedure TSmartStartingForm.PlayLastSecondsBeep;
begin
  MediaPlayerLastSeconds.CurrentTime := 0;
  MediaPlayerLastSeconds.Play;
end;

{==============================================================================}
procedure TSmartStartingForm.PlayStartBeep;
begin
  MediaPlayerStart.CurrentTime := 0;
  MediaPlayerStart.Play;
end;

{==============================================================================}
procedure TSmartStartingForm.TimerSecondsTimer(Sender: TObject);
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
  if FPlaySound then
  begin
    if lSeconds in FLastSeconds then
      PlayLastSecondsBeep;
    if lSeconds in FStartSeconds then
      PlayStartBeep;
  end;

  LabelTime.Text := FormatDatetime('hh:mm:ss', FNow);
  if lSeconds in FNextCompetitorSecond then
    DisplayNextCompetitor;
end;

{==============================================================================}
procedure TSmartStartingForm.DisplayNextCompetitor;
var
  lHour, lMinute, lSeconds, lMSecs: Word;
  lNextStartTime: TDatetime;
  lCompetitorInfo: TCompetitorInfo;
begin
  LabelBib.Text := '';
  LabelCompetitorName.Text := '';
  LabelCompetitorTeam.Text := '';
  DecodeTime(FNow, lHour, lMinute, lSeconds, lMSecs);
  lNextStartTime := EncodeTime(lHour, lMinute, 0, 0);
  lNextStartTime.AddMinute;
  if FCompetitors.TryGetValue(lNextStartTime, lCompetitorInfo) then
  begin
    LabelBib.Text := '# ' + lCompetitorInfo.Bib;
    LabelCompetitorName.Text := lCompetitorInfo.LastName + ', ' + lCompetitorInfo.FirstName;
    LabelCompetitorTeam.Text := lCompetitorInfo.TeamName;
  end;
end;

end.
