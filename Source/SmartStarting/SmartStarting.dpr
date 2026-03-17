program SmartStarting;



uses
  System.StartUpCopy,
  FMX.Forms,
  SmartStarting.MainForm in 'SmartStarting.MainForm.pas' {SmartStartingForm},
  SmartStarting.SettingsForm in 'SmartStarting.SettingsForm.pas' {FormSettings},
  SmartStarting.WebClient in 'SmartStarting.WebClient.pas';

{$IFNDEF ANDROID}
  {$R 'SmartStartingResource.res' 'SmartStartingResource.rc'}
{$ENDIF}

{$R *.res}

begin
  Application.Initialize;
  Application.FormFactor.Orientations := [TFormOrientation.Landscape, TFormOrientation.InvertedLandscape];
  Application.CreateForm(TSmartStartingForm, SmartStartingForm);
  Application.Run;
end.

