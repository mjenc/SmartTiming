program PZFStartListServer;

uses
  Vcl.Forms,
  FormPZFStartListServer in 'FormPZFStartListServer.pas' {FormPZFStartList};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormPZFStartList, FormPZFStartList);
  Application.Run;
end.
