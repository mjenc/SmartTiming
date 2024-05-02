unit FormRankingViewerConnectionProps;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ListBox,
  FMX.StdCtrls, FMX.Controls.Presentation, SmartRankingViewer.WebClient,
  FMX.Edit, FMX.ComboEdit;

type
  TFormConnectionProperties = class(TForm)
    Label1: TLabel;
    ButtonApply: TButton;
    ComboBoxWellKnownHosts: TComboEdit;
    procedure ButtonApplyClick(Sender: TObject);
  private
    FWebClient: TSmartRankingViewWebClient;
    FSmartTimingServer: string;

  public
    property WebClient: TSmartRankingViewWebClient read FWebClient write FWebClient;
    property SmartTimingServer: string read FSmartTimingServer;
  end;

var
  FormConnectionProperties: TFormConnectionProperties;

implementation

{$R *.fmx}

procedure TFormConnectionProperties.ButtonApplyClick(Sender: TObject);
begin
  if ComboBoxWellKnownHosts.ItemIndex < 0 then
  begin
    Close;
    Exit;
  end;

  if not WebClient.TestConnection(ComboBoxWellKnownHosts.Items[ComboBoxWellKnownHosts.ItemIndex], 9768) then
    ShowMessage('Server konnte nicht erreicht werden.');
  FSmartTimingServer := ComboBoxWellKnownHosts.Items[ComboBoxWellKnownHosts.ItemIndex];

  Close;
end;

end.
