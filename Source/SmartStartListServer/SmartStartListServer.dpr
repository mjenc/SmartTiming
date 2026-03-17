program SmartStartListServer;

uses
  Vcl.Forms,
  SmartStartListServer.MainForm in 'SmartStartListServer.MainForm.pas' {FormSmartStartListServer};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormSmartStartListServer, FormSmartStartListServer);
  Application.Run;
end.

