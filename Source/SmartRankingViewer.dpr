program SmartRankingViewer;

uses
  System.StartUpCopy,
  FMX.Forms,
  FormSmartRankingViewer in 'FormSmartRankingViewer.pas' {TabbedwithNavigationForm},
  SmartRankingViewer.WebClient in 'SmartRankingViewer.WebClient.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TTabbedwithNavigationForm, TabbedwithNavigationForm);
  Application.Run;
end.
