unit SmartStarting.SettingsForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ListBox,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit, FMX.Layouts, FMX.Objects;

type
  TOkMethod = procedure of object;

  TFormSettings = class(TForm)
    Label1: TLabel;
    ButtonTestServerConnection: TButton;
    ComboBoxStartInterval: TComboBox;
    Label2: TLabel;
    ButtonOK: TButton;
    ButtonCance: TButton;
    ComboBoxServer: TComboBox;
    EditServer: TEdit;
    SwitchEnableStartListServer: TSwitch;
    SwitchLastSecondsSound: TSwitch;
    Label3: TLabel;
    Label4: TLabel;
    procedure ButtonOKClick(Sender: TObject);
    procedure ButtonCanceClick(Sender: TObject);
    procedure ButtonTestServerConnectionClick(Sender: TObject);
    procedure CheckBoxLastSecondsSoundChange(Sender: TObject);
    procedure ComboBoxServerChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SwitchEnableStartListServerSwitch(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FOnOK: TOkMethod;
    procedure SetInterval(AValue: integer);
    function GetInterval: Integer;
    procedure SetStartListServer(const AValue: string);
    function GetStartListServer: string;
    procedure SetStartListServerHistory(const AValue: string);
    function GetStartListServerHistory: string;
    procedure UpdateStartListServerHistory;

  public
    property OnOK: TOkMethod read FOnOK write FOnOK;
    property Interval: Integer read GetInterval write SetInterval;
    property StartListServer: string read GetStartListServer write SetStartListServer;
    property StartListServerHistory: string read GetStartListServerHistory write SetStartListServerHistory;
  end;

var
  FormSettings: TFormSettings;

implementation

{$R *.fmx}

uses
  SmartStarting.WebClient, Tools.Dialogs;

resourcestring
  cConnectiontestSucceeded = 'Verbindungstest erfolgreich.';
  cConnectiontestFailed = 'Verbindungstest fehlgeschlagen.';
  cConnectiontestWrongConfiguration = 'Falsche Konfiguration';
  cNoServerFound = 'Kein SmartStartListServer im Netzwerk gefunden.';

{==============================================================================}
procedure TFormSettings.ButtonCanceClick(Sender: TObject);
begin
  Close;
end;

{==============================================================================}
procedure TFormSettings.ButtonOKClick(Sender: TObject);
begin
  UpdateStartListServerHistory;
  Close;
  if Assigned(FOnOK) then
    FOnOK;
end;

{==============================================================================}
procedure TFormSettings.ButtonTestServerConnectionClick(Sender: TObject);
var
  lWebClient: TSmartStartingWebClient;
  lMessage: string;
  lServerEntry: string;
  LServers: TArray<TDiscoveredStartListServer>;
begin
  lServerEntry := GetStartListServer;
  if lServerEntry.Trim = '' then
  begin
    LServers := TSmartStartingWebClient.DiscoverServers;
    if Length(LServers) = 0 then
    begin
      TApplication.InfoMessage(cNoServerFound);
      Exit;
    end;
    lServerEntry := Format('%s', [LServers[0].Address]);
    SetStartListServer(lServerEntry);
  end;
  lWebClient := TSmartStartingWebClient.Create(lServerEntry);
  try
    if lWebClient.TestConnection(lServerEntry) then
      lMessage := cConnectiontestSucceeded
    else
      lMessage := cConnectiontestFailed;
    TApplication.InfoMessage(lMessage);
  finally
    FreeAndNil(lWebClient);
  end;
end;

procedure TFormSettings.CheckBoxLastSecondsSoundChange(Sender: TObject);
begin

end;

{==============================================================================}
procedure TFormSettings.SetInterval(AValue: integer);
begin
  ComboBoxStartInterval.ItemIndex := ComboBoxStartInterval.Items.IndexOf(AValue.ToString);
end;

{==============================================================================}
function TFormSettings.GetInterval: Integer;
begin
  result := ComboBoxStartInterval.Items[ComboBoxStartInterval.ItemIndex].ToInteger;
end;

{==============================================================================}
procedure TFormSettings.SetStartListServer(const AValue: string);
var
  lIndex: Integer;
begin
  EditServer.Text := AValue;
  if AValue <> '' then
  begin
    lIndex := ComboBoxServer.Items.IndexOf(AValue);
    if lIndex < 0 then
      lIndex := ComboBoxServer.Items.Add(AValue);
    ComboBoxServer.ItemIndex := lIndex;
  end;
end;

{==============================================================================}
procedure TFormSettings.ComboBoxServerChange(Sender: TObject);
begin
  if (ComboBoxServer.ItemIndex >= 0) and (ComboBoxServer.ItemIndex < ComboBoxServer.Items.Count) then
    EditServer.Text := ComboBoxServer.Items[ComboBoxServer.ItemIndex];
end;

procedure TFormSettings.FormCreate(Sender: TObject);
begin
end;

{==============================================================================}
procedure TFormSettings.FormShow(Sender: TObject);
begin
  EditServer.Enabled := SwitchEnableStartListServer.IsChecked;
  ComboBoxServer.Enabled := SwitchEnableStartListServer.IsChecked;
  ButtonTestServerConnection.Enabled := SwitchEnableStartListServer.IsChecked;
end;

{==============================================================================}
procedure TFormSettings.SwitchEnableStartListServerSwitch(Sender: TObject);
begin
  EditServer.Enabled := SwitchEnableStartListServer.IsChecked;
  ComboBoxServer.Enabled := SwitchEnableStartListServer.IsChecked;
  ButtonTestServerConnection.Enabled := SwitchEnableStartListServer.IsChecked;
end;

{==============================================================================}
function TFormSettings.GetStartListServer: string;
begin
  Result := EditServer.Text.Trim;
  if Result = '' then
    if (ComboBoxServer.ItemIndex >= 0) and (ComboBoxServer.ItemIndex < ComboBoxServer.Items.Count) then
      Result := ComboBoxServer.Items[ComboBoxServer.ItemIndex];
end;

{==============================================================================}
procedure TFormSettings.SetStartListServerHistory(const AValue: string);
begin
  ComboBoxServer.Items.CommaText := AValue;
end;

{==============================================================================}
function TFormSettings.GetStartListServerHistory: string;
begin
  result := ComboBoxServer.Items.CommaText;
end;

{==============================================================================}
procedure TFormSettings.UpdateStartListServerHistory;
begin
  if ComboBoxServer.Items.IndexOf(EditServer.Text) >= 0 then
    Exit;
  ComboBoxServer.Items.Insert(0, EditServer.Text);
end;

end.
