program SmartTiming;

{$R 'SmartTimingResource.res' 'SmartTimingResource.rc'}

uses
  SmartTiming.Tools,
  Vcl.Forms,
  Controls,
  Windows,
  SysUtils,
  FormMain in 'FormMain.pas' {FormMain: TDataModule},
  DataModule in 'DataModule.pas' {MainDataModule: TDataModule},
  Vcl.Themes,
  Vcl.Styles,
  SmartTiming.Consts in 'SmartTiming.Consts.pas',
  SmartTiming.Controller in 'SmartTiming.Controller.pas',
  FormSmartTimingLauncher in 'FormSmartTimingLauncher.pas',
  DecoderInterface.MyLaps in 'DecoderInterface.MyLaps.pas',
  DecoderInterface.RaceResult in 'DecoderInterface.RaceResult.pas',
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
  SmartTiming.TransponderAssignment in 'SmartTiming.TransponderAssignment.pas',
  SmartTiming.PassingValidator in 'SmartTiming.PassingValidator.pas',
  Report.ExcelTemplateFiller in 'Report.ExcelTemplateFiller.pas',
  SmartTiming.Event in 'SmartTiming.Event.pas',
  SmartTiming.WebService in 'SmartTiming.WebService.pas',
  SmartTiming.GridFormatProvider in 'SmartTiming.GridFormatProvider.pas',
  FormPenalty in 'FormPenalty.pas' {FormEditPenalty},
  FormTime in 'FormTime.pas' {FormEditTime},
  FormAddPassing in 'FormAddPassing.pas' {FormManuallyAddPassing},
  Tools.DBGrid in 'Tools.DBGrid.pas',
  FormAssignCompetitorToTransponder in 'FormAssignCompetitorToTransponder.pas' {FormAssignCompetitor},
  FormUnassignedPassings in 'FormUnassignedPassings.pas' {FormUnassignedPassings},
  FormWarmUpChipConflicts in 'FormWarmUpChipConflicts.pas' {FormWarmUpChipConflicts},
  FormPlausibilityDecision in 'FormPlausibilityDecision.pas' {FormPlausibilityDecision},
  FormCompetitorPassings in 'FormCompetitorPassings.pas' {FormCompetitorPassings},
  Tools.Logger in 'Tools.Logger.pas';

{$R *.res}

const
  cLogger = 'SmartTiming';

var
  lStylename: string;
  lResult: Integer;

begin
  LogOnInfo(cLogger, ['Startup SmartTiming']);

  Application.Initialize;
  Application.MainFormOnTaskbar := True;

  lStylename := SmartTimingTools.RegistryReadString(HKEY_CURRENT_USER, cRegKeyPath + '\Settings', 'Theme');
  if (lStylename <> '') then
  begin
    LogOnDebug(cLogger, ['Setting style: ' + lStylename]);
    TStyleManager.SetStyle(lStylename);
  end;

  Application.CreateForm(TMainDataModule, MainDataModule);
  FormAppLauncher := TFormAppLauncher.Create(nil);
  try
    lResult := FormAppLauncher.ShowModal;
    if (lResult = mrCancel) then
    begin
      LogOnInfo(cLogger, ['Shutdown SmartTiming', 'Launcher was cancelled.']);
      Exit;
    end;
  finally
    FreeAndNil(FormAppLauncher);
  end;

  GSmartTimingController := nil;
  GSmartTimingController := TSmartTimingController.Create;
  Application.CreateForm(TFormMain, GFormMain);
  GSmartTimingController.LoadEventData(MainDataModule.DatabasePathAndName);

  Application.Run;
end.
