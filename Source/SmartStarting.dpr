program SmartStarting;

{$R *.dres}

uses
  System.StartUpCopy,
  FMX.Forms,
  SmartStarting.MainForm in 'SmartStarting.MainForm.pas' {SmartStartingForm},
  Tools.Dialogs in 'Tools.Dialogs.pas',
  SmartStarting.SettingsForm in 'SmartStarting.SettingsForm.pas' {FormSettings},
  SmartStarting.WebClient in 'SmartStarting.WebClient.pas',
  Tools.Preferences in 'Tools.Preferences.pas';

{$IFNDEF ANDROID}
  {$R 'SmartStartingResource.res' 'SmartStartingResource.rc'}
{$ENDIF}

{$R *.res}

begin
  Application.Initialize;
  Application.FormFactor.Orientations := [TFormOrientation.InvertedLandscape];
  Application.CreateForm(TSmartStartingForm, SmartStartingForm);
  Application.Run;
end.

