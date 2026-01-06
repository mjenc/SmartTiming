program RaceProtocolTest;

uses
  Vcl.Forms,
  TestRaceProtocol in 'TestRaceProtocol.pas' {FormLapProtocolTest},
  RaceProtocol in 'RaceProtocol.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormLapProtocolTest, FormLapProtocolTest);
  Application.Run;
end.
