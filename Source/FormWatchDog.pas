unit FormWatchDog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, System.ImageList,
  Vcl.ImgList, Vcl.StdCtrls, Vcl.Imaging.pngimage,
  DecoderInterface, VclTee.TeeGDIPlus, VCLTee.TeEngine, VCLTee.TeeProcs,
  VCLTee.Chart, ValueHistoryChart, Vcl.Menus, Registry,
  SmartTiming.Consts, SmartTiming.Tools;

type
  TStatus = (tsUnknown, tsNormal, tsWarning, tsAlert);
  TValueType = (vtTemperature, vtNoise, vtVoltage);

  TFormDecoderWatchdog = class(TForm)
    TrayIcon1: TTrayIcon;
    PanelTitle: TPanel;
    PanelTemperature: TPanel;
    PanelNoise: TPanel;
    ImageList: TImageList;
    ImageDecoder: TImage;
    LabelDecoder1: TLabel;
    Label3: TLabel;
    LabelTemp: TLabel;
    PopupMenu1: TPopupMenu;
    MenuConnectDecoderManually: TMenuItem;
    MenuSettings: TMenuItem;
    MenuExit: TMenuItem;
    N1: TMenuItem;
    TrayIcon: TTrayIcon;
    PanelTemperatureGraph: TPanel;
    PanelNoiseGraph: TPanel;
    LabelNoise: TLabel;
    Label4: TLabel;
    LabelDecoder2: TLabel;
    PanelVoltage: TPanel;
    Label1: TLabel;
    LabelVoltage: TLabel;
    PanelVoltageGraph: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure MenuExitClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SetStatusIcon(AIconname: PWideChar);
    procedure SetStatus(AStatus: TStatus);
    procedure MenuSettingsClick(Sender: TObject);
  private
    FDecoderFinder: TDecoderFinder;
    FDecoder: TDecoder;
    FListener: TDecoderListener;
    FTemperatureChart: TValueHistoryChart;
    FNoiseChart: TValueHistoryChart;
    FVoltageChart: TValueHistoryChart;

    FWarnThreshold: array[vtTemperature..vtVoltage] of Double;
    FAlertThreshold: array[vtTemperature..vtVoltage] of Double;
    FWarnSound: array[vtTemperature..vtVoltage] of boolean;
    FAlertSound: array[vtTemperature..vtVoltage] of boolean;
    FWarnDialog: array[vtTemperature..vtVoltage] of boolean;
    FAlertDialog: array[vtTemperature..vtVoltage] of boolean;

    FDefaultWarnThreshold: array[vtTemperature..vtVoltage] of Double;
    FDefaultAlertThreshold: array[vtTemperature..vtVoltage] of Double;
    FDefaultWarnSound: array[vtTemperature..vtVoltage] of boolean;
    FDefaultAlertSound: array[vtTemperature..vtVoltage] of boolean;
    FDefaultWarnDialog: array[vtTemperature..vtVoltage] of boolean;
    FDefaultAlertDialog: array[vtTemperature..vtVoltage] of boolean;

    procedure FillDefaultSettings;
    function ValueTypeToString(AValueType: TValueType): string;
    function ReadDoubleValueTypeSettingFromRegistry(AValueType: TValueType; const AName: string; ADefault: Double): Double;
    function ReadBooleanValueTypeSettingFromRegistry(AValueType: TValueType; const AName: string; ADefault: Boolean): Boolean;
    procedure WriteDoubleValueTypeSettingFromRegistry(AValueType: TValueType; const AName: string; AValue: Double);
    procedure WriteBooleanValueTypeSettingFromRegistry(AValueType: TValueType; const AName: string; AValue: Boolean);

    procedure OnDecoderFound(ADecoder: TDecoder);
    procedure OnStatusReceived(AStatus: TDecoderStatus);

    procedure LoadSettings;
    procedure SaveSettings;

  public
    { Public-Deklarationen }
  end;

var
  FormDecoderWatchdog: TFormDecoderWatchdog;

implementation

{$R *.dfm}

uses
  FormWatchDogSettings;

{==============================================================================}
procedure TFormDecoderWatchdog.FormCreate(Sender: TObject);
begin
  FDecoderFinder := TDecoderFinder.Create(OnDecoderFound);
  FDecoderFinder.Refresh;
  Sleep(500);

  FillDefaultSettings;
  FTemperatureChart := TValueHistoryChart.Create(self);
  begin
    FTemperatureChart.MaxBufferSize := PanelTemperatureGraph.Width;
    FTemperatureChart.GreenAreaTo := FDefaultWarnThreshold[vtTemperature];
    FTemperatureChart.YellowAreaFrom := FDefaultWarnThreshold[vtTemperature];
    FTemperatureChart.RedAreaFrom := FDefaultAlertThreshold[vtTemperature];
    FTemperatureChart.Parent := PanelTemperatureGraph;
    FTemperatureChart.Align := alClient;
  end;

  FNoiseChart := TValueHistoryChart.Create(self);
  begin
    FNoiseChart.MaxBufferSize := PanelNoiseGraph.Width;
    FNoiseChart.GreenAreaTo := 39.0;
    FNoiseChart.YellowAreaFrom := 39.0;
    FNoiseChart.Parent := PanelNoiseGraph;
    FNoiseChart.Align := alClient;
  end;

  FVoltageChart := TValueHistoryChart.Create(self);
  begin
    FVoltageChart.MaxBufferSize := PanelVoltageGraph.Width;
    FVoltageChart.MaxValue := 30.0;
    FVoltageChart.GreenAreaFrom := 10.0;
    FVoltageChart.GreenAreaTo := 20.0;
    FVoltageChart.YellowAreaFrom := 0.0;
    FVoltageChart.YellowAreaTo := 10.0;
    FVoltageChart.RedAreaFrom := 20.0;
    FVoltageChart.RedAreaTo := FVoltageChart.MinValue;
    FVoltageChart.Parent := PanelVoltageGraph;
    FVoltageChart.Align := alClient;
  end;
end;

{==============================================================================}
procedure TFormDecoderWatchdog.FillDefaultSettings;
begin
  FDefaultWarnThreshold[vtTemperature] := 49.0;
  FDefaultAlertThreshold[vtTemperature] := 59.0;
  FDefaultWarnSound[vtTemperature] := true;
  FDefaultAlertSound[vtTemperature] := true;
  FDefaultWarnDialog[vtTemperature] := false;
  FDefaultAlertDialog[vtTemperature] := true;

  FDefaultWarnThreshold[vtNoise] := 39.0;
  FDefaultAlertThreshold[vtNoise] := 80.0;
  FDefaultWarnSound[vtNoise] := true;
  FDefaultAlertSound[vtNoise] := true;
  FDefaultWarnDialog[vtNoise] := false;
  FDefaultAlertDialog[vtNoise] := true;

  FDefaultWarnThreshold[vtVoltage] := 10.0;
  FDefaultAlertThreshold[vtVoltage] := 20.0;
  FDefaultWarnSound[vtVoltage] := true;
  FDefaultAlertSound[vtVoltage] := true;
  FDefaultWarnDialog[vtVoltage] := true;
  FDefaultAlertDialog[vtVoltage] := true;

end;

{==============================================================================}
procedure TFormDecoderWatchdog.MenuExitClick(Sender: TObject);
begin
  FreeAndNil(FListener);
  Application.Terminate;
end;

{==============================================================================}
procedure TFormDecoderWatchdog.MenuSettingsClick(Sender: TObject);
begin
  FormSettings.Show;
end;

{==============================================================================}
procedure TFormDecoderWatchdog.FormShow(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_HIDE);
  SetWindowLongPtr(Application.Handle, GWL_EXSTYLE, GetWindowLongPtr(Application.Handle, GWL_EXSTYLE) and not WS_EX_APPWINDOW or WS_EX_TOOLWINDOW);
//  ShowWindow(Application.Handle, SW_SHOW);
end;

{==============================================================================}
procedure TFormDecoderWatchdog.SetStatusIcon(AIconname: PWideChar);
begin
  Self.Icon.Handle := LoadIconW(HInstance, AIconname);
  Application.Icon.Handle := LoadIconW(HInstance, AIconname);
  TrayIcon.Icon.Handle := LoadIconW(HInstance, AIconname);
end;

{==============================================================================}
procedure TFormDecoderWatchdog.SetStatus(AStatus: TStatus);
var
  lHint: string;
  lIconIndex: integer;
  lBalloonFlags: TBalloonFlags;
begin
  case AStatus of
  tsNormal:
    begin
      lBalloonFlags := bfNone;
    end;
  tsWarning:
    begin
      lBalloonFlags := bfWarning;
    end;
  tsAlert:
    begin
      lBalloonFlags := bfError;
    end
  else
    begin
      lBalloonFlags := bfInfo;
    end;
  end;

  TrayIcon.Hint := lHint;
  TrayIcon.IconIndex := lIconIndex;

  if AStatus in [tsWarning, tsAlert] then
  begin
    TrayIcon.BalloonTitle := 'Hinweis';
    TrayICON.BalloonHint  := lHint;
    TrayIcon.BalloonFlags := lBalloonFlags;
    TrayIcon.BalloonTimeout := 1000*60*60*24;
    TrayIcon.ShowBalloonHint;
  end;

end;

{==============================================================================}
function TFormDecoderWatchdog.ValueTypeToString(AValueType: TValueType): string;
begin
  case AValueType of
  vtTemperature:
    result := 'Temperature';
  vtNoise:
    result := 'Noise';
  vtVoltage:
    result := 'Voltage';
  end;
end;

{==============================================================================}
function TFormDecoderWatchdog.ReadDoubleValueTypeSettingFromRegistry(AValueType: TValueType; const AName: string; ADefault: Double): Double;
var
  lReg : TRegistry;
  lValueName: string;
begin
  result := ADefault;
  lReg := TRegistry.Create;
  try
    lReg.RootKey := HKEY_CURRENT_USER;
    if lReg.OpenKey(cRegKeyPath + '\WatchDogSettings', true) then
    begin
      lValueName := ValueTypeToString(AValueType) + AName;
      if not lReg.ValueExists(lValueName) then
        Exit(ADefault);
      result := lReg.ReadFloat(lValueName);
    end;
  finally
    FreeAndNil(lReg);
  end;
end;

{==============================================================================}
function TFormDecoderWatchdog.ReadBooleanValueTypeSettingFromRegistry(AValueType: TValueType; const AName: string; ADefault: Boolean): Boolean;
var
  lReg : TRegistry;
  lValueName: string;
begin
  result := ADefault;
  lReg := TRegistry.Create;
  try
    lReg.RootKey := HKEY_CURRENT_USER;
    if lReg.OpenKey(cRegKeyPath + '\WatchDogSettings', true) then
    begin
      lValueName := ValueTypeToString(AValueType) + AName;
      if not lReg.ValueExists(lValueName) then
        Exit(ADefault);
      result := lReg.ReadBool(lValueName);
    end;
  finally
    FreeAndNil(lReg);
  end;
end;

{==============================================================================}
procedure TFormDecoderWatchdog.WriteDoubleValueTypeSettingFromRegistry(AValueType: TValueType; const AName: string; AValue: Double);
var
  lReg : TRegistry;
begin
  lReg := TRegistry.Create;
  try
    lReg.RootKey := HKEY_CURRENT_USER;
    if lReg.OpenKey(cRegKeyPath + '\WatchDogSettings', true) then
      lReg.WriteFloat(ValueTypeToString(AValueType) + AName, AValue);
  finally
    FreeAndNil(lReg);
  end;
end;

{==============================================================================}
procedure TFormDecoderWatchdog.WriteBooleanValueTypeSettingFromRegistry(AValueType: TValueType; const AName: string; AValue: Boolean);
var
  lReg : TRegistry;
begin
  lReg := TRegistry.Create;
  try
    lReg.RootKey := HKEY_CURRENT_USER;
    if lReg.OpenKey(cRegKeyPath + '\WatchDogSettings', true) then
      lReg.WriteBool(ValueTypeToString(AValueType) + AName, AValue);
  finally
    FreeAndNil(lReg);
  end;
end;

{==============================================================================}
procedure TFormDecoderWatchdog.LoadSettings;
var
  lValueType: TValueType;
begin
  for lValueType := vtTemperature to vtVoltage do
  begin
    FWarnThreshold[lValueType] := ReadDoubleValueTypeSettingFromRegistry(lValueType, 'WarnThreshold', FDefaultWarnThreshold[lValueType]);
    FAlertThreshold[lValueType] := ReadDoubleValueTypeSettingFromRegistry(lValueType, 'AlertThreshold', FDefaultAlertThreshold[lValueType]);
    FWarnSound[lValueType] := ReadBooleanValueTypeSettingFromRegistry(lValueType, 'WarnSound', FDefaultWarnSound[lValueType]);
    FAlertSound[lValueType] := ReadBooleanValueTypeSettingFromRegistry(lValueType, 'AlertSound', FDefaultAlertSound[lValueType]);
    FWarnDialog[lValueType] := ReadBooleanValueTypeSettingFromRegistry(lValueType, 'WarnDialog', FDefaultWarnDialog[lValueType]);
    FAlertDialog[lValueType] := ReadBooleanValueTypeSettingFromRegistry(lValueType, 'AlertDialog', FDefaultAlertDialog[lValueType]);
  end;
end;

{==============================================================================}
procedure TFormDecoderWatchdog.SaveSettings;
var
  lValueType: TValueType;
begin
  for lValueType := vtTemperature to vtVoltage do
  begin
    WriteDoubleValueTypeSettingFromRegistry(lValueType, 'WarnThreshold', FWarnThreshold[lValueType]);
    WriteDoubleValueTypeSettingFromRegistry(lValueType, 'AlertThreshold', FAlertThreshold[lValueType]);
    WriteBooleanValueTypeSettingFromRegistry(lValueType, 'WarnSound', FWarnSound[lValueType]);
    WriteBooleanValueTypeSettingFromRegistry(lValueType, 'AlertSound', FAlertSound[lValueType]);
    WriteBooleanValueTypeSettingFromRegistry(lValueType, 'WarnDialog', FWarnDialog[lValueType]);
    WriteBooleanValueTypeSettingFromRegistry(lValueType, 'AlertDialog', FAlertDialog[lValueType]);
  end;
end;

{==============================================================================}
procedure TFormDecoderWatchdog.OnDecoderFound(ADecoder: TDecoder);
begin
  if FListener <> nil then
    FreeAndNil(FListener);

  FDecoder := ADecoder;

  LabelDecoder1.Caption :=
    'Manufacturer:     ' + FDecoder.DecoderManufacturer + #13#10 +
    'DecoderId:        ' + FDecoder.DecoderId + #13#10 +
    'Firmware Version: ' + FDecoder.FirmwareVersion;
  LabelDecoder2.Caption :=
    'IP Address  : ' + FDecoder.Address + #13#10 +
    'Decoder Type: ' + FDecoder.DecoderType;

  FListener := TDecoderListener.GetListenerForDecoder(FDecoder, OnStatusReceived, nil);
  FListener.Start;

  ImageDecoder.Picture.Bitmap.LoadFromResourceName(HInstance, 'MyLapsDecoderActive');
  ImageDecoder.Picture.Bitmap.TransparentColor := clWhite;
  ImageDecoder.Picture.Bitmap.Transparent := true;
end;

{==============================================================================}
procedure TFormDecoderWatchdog.OnStatusReceived(AStatus: TDecoderStatus);
begin
  LabelTemp.Caption := AStatus.Temperature.ToString;
  FTemperatureChart.AddValue(AStatus.Temperature);
  FTemperatureChart.Paint;

  LabelNoise.Caption := AStatus.Noise.ToString;
  FNoiseChart.AddValue(AStatus.Noise.ToDouble);
  FNoiseChart.Paint;
end;

end.
