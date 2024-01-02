unit SmartStarting.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, DateUtils, MMSystem;

type
  TFormMain = class(TForm)
    PanelTime: TPanel;
    PanelCompetitorInfo: TPanel;
    PanelControls: TPanel;
    LabelCompetitorInfo: TLabel;
    ButtonExit: TButton;
    TimerSeconds: TTimer;
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonExitClick(Sender: TObject);
    procedure TimerSecondsTimer(Sender: TObject);
  private
    FStdFontSizeBib: integer;
    FStdFontSizeCompetitorInfo: integer;
    FStdFontSizeTime: integer;
    FStdFormWidth: integer;
    FStdFormHeight: integer;
    FStdPanelCompetitorInfoHeight: integer;
    FTimerCalibration: boolean;
  public
    { Public-Deklarationen }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure TFormMain.ButtonExitClick(Sender: TObject);
begin
  // TODO Show Y/N message
  Application.Terminate;
end;

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

  FTimerCalibration := true;
  var
    lYear, lMonth, lDay, lHour, lMin, lSec, lMilli: Word;
  begin
    DecodeDateTime(Now, lYear, lMonth, lDay, lHour, lMin, lSec, lMilli);
    TimerSeconds.Interval := 1000 - lMilli;
    TimerSeconds.Enabled := true;
  end;
end;

procedure TFormMain.FormResize(Sender: TObject);
var
  lFactor: double;
begin
  lFactor := Width / FStdFormWidth;
  LabelCompetitorInfo.Height :=  Trunc(FStdPanelCompetitorInfoHeight * lFactor);
  LabelCompetitorInfo.Font.Size := Trunc(FStdFontSizeCompetitorInfo * lFactor);
  PanelCompetitorInfo.Font.Size := Trunc(FStdFontSizeBib * lFactor);
  PanelTime.Font.Size := Trunc(FStdFontSizeTime * lFactor);
end;

procedure TFormMain.TimerSecondsTimer(Sender: TObject);
var
  lSeconds: Word;
  lNow: TDatetime;
begin
  if FTimerCalibration then
  begin
    TimerSeconds.Enabled := false;
    TimerSeconds.Interval := 1000;
    TimerSeconds.Enabled := true;
    FTimerCalibration := false;
    Exit;
  end;

  lNow := Now;
  lSeconds := DateUtils.SecondOfTheMinute(lNow);
  if (lSeconds = 50) or (lSeconds > 54)  then
    PlaySound('LastSecondsBeep', 0, SND_NOSTOP or SND_NOWAIT or SND_RESOURCE or SND_ASYNC or SND_NODEFAULT);
  if lSeconds = 0 then
    PlaySound('StartBeep', 0, SND_NOSTOP or SND_NOWAIT or SND_RESOURCE or SND_ASYNC or SND_NODEFAULT);
  PanelTime.Caption := FormatDatetime('hh:mm:ss', lNow);
end;

end.
