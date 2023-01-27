program SmartTiming;



uses
  Vcl.Forms,
  Windows,
  uFormMain in 'uFormMain.pas' {FormMain},
  SmartTiming.DecoderEngine in 'SmartTiming.DecoderEngine.pas',
  SmartTiming.DecoderInterface in 'SmartTiming.DecoderInterface.pas',
  SmartTiming.Cache in 'SmartTiming.Cache.pas',
  SmartTiming.Tools in 'SmartTiming.Tools.pas',
  SmartTiming.Consts in 'SmartTiming.Consts.pas',
  SmartTiming.Database in 'SmartTiming.Database.pas',
  uDataModule in 'uDataModule.pas' {MainDataModule: TDataModule},
  uPassingProtocolGrid in 'uPassingProtocolGrid.pas',
  uFormRaceDetails in 'uFormRaceDetails.pas' {FormRaceDetails},
  uFormSettings in 'uFormSettings.pas' {FormSettings},
  uFormCompetitorImport in 'uFormCompetitorImport.pas' {FormCompetitorImport},
  uFormCompetitorDetails in 'uFormCompetitorDetails.pas' {FormCompetitorDetails},
  uFormPassingSimulator in 'uFormPassingSimulator.pas' {FormPassingSimulator},
  uPassingCustomProtocol in 'uPassingCustomProtocol.pas',
  RaceEngine.Custom in 'RaceEngine.Custom.pas',
  RaceEngine.TimeTrial in 'RaceEngine.TimeTrial.pas',
  Vcl.Themes,
  Vcl.Styles,
  SmartTiming.MainController in 'SmartTiming.MainController.pas';

{$R *.res}

var
  lStylename: string;
begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  lStylename := SmartTimingTools.RegistryReadString(HKEY_CURRENT_USER, cRegKeyPath + '\Settings', 'Theme');
  if (lStylename <> '') then
    TStyleManager.SetStyle(lStylename);
  Application.CreateForm(TMainDataModule, MainDataModule);
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
