program SmartTiming;

uses
  Vcl.Forms,
  uFormMain in 'uFormMain.pas' {FormMain},
  SmartTiming.DecoderEngine in 'SmartTiming.DecoderEngine.pas',
  SmartTiming.DecoderInterface in 'SmartTiming.DecoderInterface.pas',
  SmartTiming.Cache in 'SmartTiming.Cache.pas',
  SmartTiming.Tools in 'SmartTiming.Tools.pas',
  SmartTiming.Consts in 'SmartTiming.Consts.pas',
  SmartTiming.Database in 'SmartTiming.Database.pas',
  uDataModule in 'uDataModule.pas' {DataModule1: TDataModule},
  uFormDataGrid in 'uFormDataGrid.pas' {FormDataGrid},
  uPassingProtocolGrid in 'uPassingProtocolGrid.pas',
  Classification in 'Classification.pas',
  Classification.ITT in 'Classification.ITT.pas',
  uFormRaceDetails in 'uFormRaceDetails.pas' {FormRaceDetails};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TDataModule1, DataModule1);
  Application.CreateForm(TFormDataGrid, FormDataGrid);
  Application.Run;
end.
