program SmartStarting;

{$R 'SmartStartingResource.res' 'SmartStartingResource.rc'}

uses
  Vcl.Forms,
  SmartStarting.Main in 'SmartStarting.Main.pas' {FormMain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
