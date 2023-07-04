program SmartTiming;

{$R 'SmartTimingResource.res' 'SmartTimingResource.rc'}

uses
  Vcl.Forms,
  Controls,
  Windows,
  SysUtils,
  FormMain in 'FormMain.pas' {FormMain: TDataModule},
  DataModule in 'DataModule.pas' {MainDataModule: TDataModule},
  Vcl.Themes,
  Vcl.Styles,
  SmartTiming.Consts in 'SmartTiming.Consts.pas',
  SmartTiming.Tools in 'SmartTiming.Tools.pas',
  SmartTiming.Controller in 'SmartTiming.Controller.pas',
  FormSmartTimingLauncher in 'FormSmartTimingLauncher.pas',
  DecoderInterface.MyLaps in 'DecoderInterface.MyLaps.pas',
  DecoderInterface in 'DecoderInterface.pas',
  FormBatteryCheck in 'FormBatteryCheck.pas' {FormBatteryCheck},
  FormCompetitorDetails in 'FormCompetitorDetails.pas' {FormCompetitorDetails},
  FormCompetitorImport in 'FormCompetitorImport.pas' {FormCompetitorImport},
  FormGenerateTransponderMappings in 'FormGenerateTransponderMappings.pas' {FormGenerateTransponderMappings},
  FormPassingSimulator in 'FormPassingSimulator.pas' {FormPassingSimulator},
  FormRaceDetails in 'FormRaceDetails.pas' {FormRaceDetails},
  FormSettings in 'FormSettings.pas' {FormSettings},
  SmartTiming.DecoderEngine in 'SmartTiming.DecoderEngine.pas',
  RaceEngine.Custom in 'RaceEngine.Custom.pas',
  RaceEngine.TimeTrial in 'RaceEngine.TimeTrial.pas',
  SmartTiming.Cache in 'SmartTiming.Cache.pas',
  Report.ExcelTemplateFiller in 'Report.ExcelTemplateFiller.pas',
  SmartTiming.Event in 'SmartTiming.Event.pas';

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
