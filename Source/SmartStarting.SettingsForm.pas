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
  private
    FOnOK: TOkMethod;
    procedure SetInterval(AValue: integer);
    function GetInterval: Integer;
    procedure SetStartListServer(const AValue: string);
    function GetStartListServer: string;

  public
    property OnOK: TOkMethod read FOnOK write FOnOK;
    property Interval: Integer read GetInterval write SetInterval;
    property StartListServer: string read GetStartListServer write SetStartListServer;
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

{==============================================================================}
procedure TFormSettings.ButtonCanceClick(Sender: TObject);
begin
  Close;
end;

{==============================================================================}
procedure TFormSettings.ButtonOKClick(Sender: TObject);
begin
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
  lSplitted: TArray<string>;
begin
  lServerEntry := GetStartListServer;
  lSplitted := lServerEntry.Split([':']);
  if (Length(lSplitted) <> 2) or lSplitted[1].Trim.IsEmpty then
  begin
    TApplication.InfoMessage(cConnectiontestWrongConfiguration);
    Exit;
  end;

  lWebClient := TSmartStartingWebClient.Create(lSplitted[1].Trim);
  try
    if lWebClient.TestConnection(lSplitted[1].Trim) then
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

procedure TFormSettings.FormShow(Sender: TObject);
begin
  EditServer.Enabled := SwitchEnableStartListServer.IsChecked;
  ComboBoxServer.Enabled := SwitchEnableStartListServer.IsChecked;
  ButtonTestServerConnection.Enabled := SwitchEnableStartListServer.IsChecked;
end;

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

end.
