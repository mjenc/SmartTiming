program SmartTiming;



uses
  Vcl.Forms,
  Windows,
  FormMain in 'FormMain.pas' {FormMain},
  DataModule in 'DataModule.pas' {MainDataModule: TDataModule},
  Vcl.Themes,
  Vcl.Styles,
  SmartTiming.Consts,
  SmartTiming.Tools;

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
  Application.CreateForm(TFormMain, GFormMain);
  Application.Run;
end.
