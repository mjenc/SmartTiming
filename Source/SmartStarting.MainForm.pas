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
    procedure FormShow(Sender: TObject);
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
    FUseStartListServer: boolean;
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
  end;

var
  SmartStartingForm: TSmartStartingForm;

implementation

uses
  System.Threading, SmartStarting.WebClient, Tools.Dialogs, Tools.Preferences,
{$IFDEF ANDROID}
  Androidapi.Helpers, Androidapi.Jni.GraphicsContentViewText, Androidapi.JNI.App,
{$ENDIF}
  Tools.SuperObject;

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

var
  gWebClient: TSmartStartingWebClient;

{$R *.fmx}

{==============================================================================}
function GetWebClient(const AServerName: string): TSmartStartingWebClient;
begin
  if gWebClient = nil then
    gWebClient := TSmartStartingWebClient.Create(AServerName);
  result := gWebClient;
end;

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
  FUseStartListServer := false;

  CalibrateTimer;
  FCompetitors := TDictionary<TDatetime, TCompetitorInfo>.Create;

{$IFDEF ANDROID}
  MediaPlayerLastSeconds.FileName := SaveResourceAsTempFile('LastSecondsBeep3gp');
  MediaPlayerStart.FileName := SaveResourceAsTempFile('StartBeep3gp');
{$ELSE}
  MediaPlayerLastSeconds.FileName := 'LastSecondsBeep.wav';
  MediaPlayerStart.FileName := 'StartBeep.wav';
{$ENDIF}

  LoadSettings;

{$IFDEF ANDROID}
  lFlags :=
    TJWindowManager_LayoutParams.JavaClass.FLAG_TURN_SCREEN_ON or
    TJWindowManager_LayoutParams.JavaClass.FLAG_DISMISS_KEYGUARD or
    TJWindowManager_LayoutParams.JavaClass.FLAG_SHOW_WHEN_LOCKED or
    TJWindowManager_LayoutParams.JavaClass.FLAG_KEEP_SCREEN_ON;
  TAndroidHelper.Activity.getWindow.setFlags (lFlags, lFlags);
{$ENDIF}

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
procedure TSmartStartingForm.FormShow(Sender: TObject);
begin
  if not FUseStartListServer then
  begin
    LabelBib.Text := '';
    LabelCompetitorName.Text := '';
    LabelCompetitorTeam.Text := '';
    ButtonImportStartingList.Enabled := false;
  end
  else
    ButtonImportStartingList.Enabled := True;
end;

{==============================================================================}
procedure TSmartStartingForm.ButtonImportStartingListClick(Sender: TObject);
begin
  if not FUseStartListServer then
    Exit;
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
begin
  try
    TTask.Run(
      procedure
      var
        lJSONString: string;
        lCompetitorObject: ISuperObject;
      begin
        lJSONString := GetWebClient(GetPureServerName).GetListOfStarters;
        if lJSONString.IsEmpty then
          Exit;

        TThread.Queue(nil,
          procedure
          var
            lSO: ISuperObject;
            i: integer;
            lCompetitorInfo: TCompetitorInfo;
            lTeam: string;
            lHour, lMin, lSec, lMSec: Word;
            lStartTime: TDatetime;
          begin
            FCompetitors.Clear;

            lSO := TSuperObject.Create(lJSONString);
            for i := 0 to lSO.A['list'].Length - 1 do
            begin
              try
                lCompetitorObject := lSO.A['list'].O[i];
                lCompetitorInfo.Bib := lCompetitorObject.S['BIB'];
                lCompetitorInfo.LastName := lCompetitorObject.S['LASTNAME'];
                lCompetitorInfo.FirstName := lCompetitorObject.S['FIRSTNAME'];
                lTeam := lCompetitorObject.S['TEAM'];
                if lTeam.IsEmpty then
                  lTeam := lCompetitorObject.S['CLUB'];
                lCompetitorInfo.TeamName := lTeam;
                lStartTime := 0;
                if lCompetitorObject.D['STARTTIME'] <> 0 then
                  lStartTime := lCompetitorObject.D['STARTTIME']
                else if not lCompetitorObject.S['STARTTIME'].IsEmpty then
                  TryStrToDateTime(lCompetitorObject.S['STARTTIME'].Replace('T', ' '), lStartTime);
                DecodeTime(lStartTime, lHour, lMin, lSec, lMSec);
                lStartTime := EncodeTime(lHour, lMin, lSec, 0);
                FCompetitors.Add(lStartTime, lCompetitorInfo);
              except
              end;
            end;
          end);
      end);
  except
  end;
end;

{==============================================================================}
procedure TSmartStartingForm.ButtonSettingsClick(Sender: TObject);
begin
  FFormSettings.OnOK := SaveSettings;
  FFormSettings.SwitchEnableStartListServer.IsChecked := FUseStartListServer;
  FFormSettings.SwitchLastSecondsSound.IsChecked := FPlaySound;
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
  FUseStartListServer := FFormSettings.SwitchEnableStartListServer.IsChecked;
  FStartListServer := FFormSettings.StartListServer;
  FPlaySound := FFormSettings.SwitchLastSecondsSound.IsChecked;
  FIntervalSeconds := FFormSettings.Interval;

  lPref := CreatePreferencesObject(cManufacturer, cSmartStartingAppName);
  lPref.SetBoolean('UseStartListServer', FUseStartListServer);
  lPref.SetInteger('IntervalSeconds', FIntervalSeconds);
  lPref.SetString('StartListServer', FStartListServer);
  lPref.SetBoolean('PlaySound', FPlaySound);
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
  FormShow(nil);
end;

{==============================================================================}
procedure TSmartStartingForm.LoadSettings;
var
  lPref: TPreferences;
begin
  lPref := CreatePreferencesObject(cManufacturer, cSmartStartingAppName);
  FUseStartListServer := lPref.GetBoolean('UseStartListServer', false);
  FIntervalSeconds := lPref.GetInteger('IntervalSeconds', 60);
  FStartListServer := lPref.GetString('StartListServer');
  if FStartListServer.IsEmpty then
    FStartListServer := 'MJ-SmartTiming-1: 192.168.100.20';  // Default IP-Address of Server in MJ-SmartTiming environment.
  FPlaySound := lPref.GetBoolean('PlaySound', true);
  FormShow(nil);
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
  if FUseStartListServer and (lSeconds in FNextCompetitorSecond) then
    DisplayNextCompetitor;
end;

{==============================================================================}
procedure TSmartStartingForm.DisplayNextCompetitor;
var
  lHour, lMinute, lSeconds, lMSecs: Word;
  lNextStartTime: TDatetime;
  lCompetitorInfo: TCompetitorInfo;
begin
  GetStartListFromServer;
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

initialization
  gWebClient := nil;

finalization
  FreeAndNil(gWebClient);

end.
