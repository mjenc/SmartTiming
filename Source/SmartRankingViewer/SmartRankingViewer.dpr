program SmartRankingViewer;

uses
  System.StartUpCopy,
  FMX.Forms,
  FormSmartRankingViewer in 'FormSmartRankingViewer.pas' {FormRankingViewer},
  SmartRankingViewer.WebClient in 'SmartRankingViewer.WebClient.pas',
  FormRankingViewerConnectionProps in 'FormRankingViewerConnectionProps.pas' {FormConnectionProperties};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormRankingViewer, FormRankingViewer);
  Application.Run;
end.
