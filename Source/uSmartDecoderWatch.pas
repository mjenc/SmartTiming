unit uSmartDecoderWatch;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.ImageList, Vcl.ImgList,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Menus, Vcl.StdCtrls,
  Registry, SmartTiming.DecoderInterface, SmartTiming.DecoderEngine;


type
  TForm1 = class(TForm)
    TrayIcon1: TTrayIcon;
    ImageList1: TImageList;
    PopupMenu1: TPopupMenu;
    MenuShowHistory: TMenuItem;
    MenuSettings: TMenuItem;
    PageControl1: TPageControl;
    TabSheetHistory: TTabSheet;
    TabSheetSettings: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    EditThresholdYellow: TEdit;
    EditThresholdOrange: TEdit;
    EditThresholdRed: TEdit;
    MemoHistory: TMemo;
    Button1: TButton;
    Edit1: TEdit;
    ButtonSave: TButton;
    procedure MenuShowHistoryClick(Sender: TObject);
    procedure MenuSettingsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);

  private
    FThresholdYellow: integer;
    FThresholdOrange: integer;
    FThresholdRed: integer;

    FDecoder: TMyLapsP3Decoder;
    FListener: TMyLapsP3Listener;
    FMessageParser: TMyLapsP3MessageParser;
    FDecoderFinder: TMyLapsDecoderFinder;
    FDecoderFound: boolean;

    procedure ReadRegistryValues;
    procedure WriteRegistryValues;

    procedure OnStatusReceived(Status: TMyLapsP3Status);
    procedure OnDecoderFound(ADecoder: TMyLapsP3Decoder);
    procedure SetStatus(ATemp: integer);
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{==============================================================================}
procedure TForm1.FormCreate(Sender: TObject);
begin
  Form1.Hide;
  ReadRegistryValues;

  FMessageParser := TMyLapsP3MessageParser.Create;
  FMessageParser.OnStatusReceived := OnStatusReceived;

  FDecoderFinder := TMyLapsDecoderFinder.Create;
  FDecoderFinder.OnDecoderFound := OnDecoderFound;

  FDecoderFound := false;
  while not FDecoderFound do
  begin
    FDecoderFinder.Update;
    Sleep(3000);
  end;
end;

{==============================================================================}
procedure TForm1.MenuSettingsClick(Sender: TObject);
begin
  Form1.PageControl1.ActivePage := TabSheetSettings;
  Form1.Show;
end;

{==============================================================================}
procedure TForm1.MenuShowHistoryClick(Sender: TObject);
begin
  Form1.PageControl1.ActivePage := TabSheetHistory;
  Form1.Show;
end;

{==============================================================================}
procedure TForm1.ReadRegistryValues;
var
  lReg : TRegistry;
begin
  FThresholdYellow := 30;
  FThresholdOrange := 35;
  FThresholdRed := 39;

  lReg := TRegistry.Create(KEY_QUERY_VALUE);
  try
    lReg.RootKey := HKEY_CURRENT_USER;
    if not lReg.OpenKey('SOFTWARE\MJ\SmartTiming', true) then
      Exit;

    if lReg.ValueExists('ThresholdYellow') then
      FThresholdYellow := lReg.ReadInteger('ThresholdYellow');
    if lReg.ValueExists('ThresholdOrange') then
      FThresholdOrange := lReg.ReadInteger('ThresholdOrange');
    if lReg.ValueExists('ThresholdRed') then
      FThresholdOrange := lReg.ReadInteger('ThresholdRed');
  finally
    FreeAndNil(lReg);
  end;
end;

{==============================================================================}
procedure TForm1.WriteRegistryValues;
var
  lReg : TRegistry;
begin
  lReg := TRegistry.Create;
  try
    lReg.RootKey := HKEY_CURRENT_USER;
    if not lReg.OpenKey('SOFTWARE\MJ\SmartTiming', true) then
      Exit;

    lReg.WriteInteger('ThresholdYellow', FThresholdYellow);
    lReg.WriteInteger('ThresholdOrange', FThresholdOrange);
    lReg.WriteInteger('ThresholdRed', FThresholdRed);
  finally
    FreeAndNil(lReg);
  end;
end;

{==============================================================================}
procedure TForm1.OnStatusReceived(Status: TMyLapsP3Status);
begin
  MemoHistory.Lines.Add(Format('%s: DecoderId: %s Noise: %d Temperature: %d', [FormatDatetime('YYYY-MM-DD HH:MM:SS', Now), Status.DecoderId, Status.Noise, Round(Status.Temperature)]));
  SetStatus(Round(Status.Temperature));
end;

{==============================================================================}
procedure TForm1.OnDecoderFound(ADecoder: TMyLapsP3Decoder);
begin
  FDecoderFound := true;
  FDecoder := ADecoder;
  FListener := TMyLapsP3Listener.Create(FDecoder,5403);
  Flistener.MyLapsP3MessageParser := FMessageParser;
  FListener.Start;
end;

{==============================================================================}
procedure TForm1.SetStatus(ATemp: integer);
begin
  TrayIcon1.Hint := ATemp.ToString + '° C';
  if ATemp >= FThresholdRed then
  begin
    TrayIcon1.IconIndex := 4;
    Exit;
  end;
  if ATemp >= FThresholdOrange then
  begin
    TrayIcon1.IconIndex := 3;
    Exit;
  end;
  if ATemp >= FThresholdYellow then
  begin
    TrayIcon1.IconIndex := 2;
    Exit;
  end;
  TrayIcon1.IconIndex := 1;
end;

procedure TForm1.TrayIcon1DblClick(Sender: TObject);
begin
  if WindowState = wsMinimized then
    WindowState := wsNormal;

  Application.Restore;
  SetForegroundWindow(Handle);
end;

end.
