unit FormWatchDogSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.MMSystem, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TFormSettings = class(TForm)
    PanelButtons: TPanel;
    ButtonOK: TButton;
    ButtonCancel: TButton;
    PanelTemperatureSettings: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    EditTemperatureThresholdYellow: TEdit;
    EditTemperatureThresholdRed: TEdit;
    Label3: TLabel;
    CheckBoxTemperatureSoundOnYellow: TCheckBox;
    CheckBoxTemperatureSoundOnRed: TCheckBox;
    CheckBoxTemperatureDialogOnYellow: TCheckBox;
    CheckBoxTemperatureDialogOnRed: TCheckBox;
    Panel1: TPanel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    EditNoiseThresholdYellow: TEdit;
    EditNoiseThresholdRed: TEdit;
    CheckBoxNoiseSoundOnYellow: TCheckBox;
    CheckBoxNoiseSoundOnRed: TCheckBox;
    CheckBoxNoiseDialogOnYellow: TCheckBox;
    CheckBoxNoiseDialogOnRed: TCheckBox;
    Panel2: TPanel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    EditVoltageThresholdYellow: TEdit;
    EditVoltageThresholdRed: TEdit;
    CheckBoxVoltageSoundOnYellow: TCheckBox;
    CheckBoxVoltageSoundOnRed: TCheckBox;
    CheckBoxVoltageDialogOnYellow: TCheckBox;
    CheckBoxVoltageDialogOnRed: TCheckBox;
    Panel3: TPanel;
    ButtonPlayWarnSound: TButton;
    ButtonPlayAlertSound: TButton;
    procedure ButtonPlayWarnSoundClick(Sender: TObject);
    procedure ButtonPlayAlertSoundClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FAlertIsPlaying: boolean;
    FWarnIsPlaying: boolean;

    procedure StopAllSounds;
  public
    { Public-Deklarationen }
  end;

var
  FormSettings: TFormSettings;

implementation

{$R *.dfm}

{==============================================================================}
procedure TFormSettings.FormShow(Sender: TObject);
begin
  FAlertIsPlaying := false;
  FWarnIsPlaying := false;
end;

{==============================================================================}
procedure TFormSettings.StopAllSounds;
var
  lOptions: Cardinal;
begin
  lOptions := SND_RESOURCE or SND_ASYNC;
  PlaySound('PassingBeep', 0, lOptions);
  FAlertIsPlaying := false;
  FWarnIsPlaying := false;
end;

{==============================================================================}
procedure TFormSettings.ButtonPlayWarnSoundClick(Sender: TObject);
var
  lOptions: Cardinal;
begin
  lOptions := SND_RESOURCE or SND_ASYNC or SND_NODEFAULT;
  FWarnIsPlaying := PlaySound('WarnSound', 0, lOptions);
end;

{==============================================================================}
procedure TFormSettings.ButtonPlayAlertSoundClick(Sender: TObject);
var
  lOptions: Cardinal;
begin
  if FAlertIsPlaying then
  begin
    lOptions := SND_RESOURCE or SND_ASYNC;
    PlaySound('PassingBeep', 0, lOptions);
    FAlertIsPlaying := false;
    Exit;
  end;
  lOptions := SND_LOOP or SND_RESOURCE or SND_ASYNC or SND_NODEFAULT;
  FAlertIsPlaying := PlaySound('AlertSound', 0, lOptions);
end;

end.
