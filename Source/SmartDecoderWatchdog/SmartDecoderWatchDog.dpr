program SmartDecoderWatchDog;



{$R 'SmartTimingResource.res' '..\SmartTimingResource.rc'}

uses
  Vcl.Forms,
  FormWatchDog in 'FormWatchDog.pas' {FormDecoderWatchdog},
  ValueHistoryChart in 'ValueHistoryChart.pas',
  FormWatchDogSettings in 'FormWatchDogSettings.pas' {FormSettings};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormDecoderWatchdog, FormDecoderWatchdog);
  Application.CreateForm(TFormSettings, FormSettings);
  Application.Run;
end.
