program SmartTiming;



uses
  Vcl.Forms, Controls, Windows, SysUtils,
  FormMain,
  DataModule in 'DataModule.pas' {MainDataModule: TDataModule},
  Vcl.Themes,
  Vcl.Styles,
  SmartTiming.Consts,
  SmartTiming.Tools,
  SmartTiming.Controller in 'SmartTiming.Controller.pas',
  FormSmartTimingLauncher;

{$R *.res}

var
  lStylename: string;
  lResult: Integer;
begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;

  lStylename := SmartTimingTools.RegistryReadString(HKEY_CURRENT_USER, cRegKeyPath + '\Settings', 'Theme');
  if (lStylename <> '') then
    TStyleManager.SetStyle(lStylename);

  Application.CreateForm(TMainDataModule, MainDataModule);

  FormAppLauncher := TFormAppLauncher.Create(nil);
  try
    lResult := FormAppLauncher.ShowModal;
    if (lResult = mrCancel) then
      Exit;
  finally
    FreeAndNil(FormAppLauncher);
  end;

  GSmartTimingController := TSmartTimingController.Create;
  Application.CreateForm(TFormMain, GFormMain);
  GSmartTimingController.LoadEventData(MainDataModule.DatabasePathAndName);

  Application.Run;
end.
