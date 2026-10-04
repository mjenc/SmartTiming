unit FormPassingSimulator;

{==============================================================================
  Decoder simulator (Plan 9):
  Phase A — In-Process via SendSimulatedPassing
  Phase B — MyLaps P3 loopback via local FakeDecoder + TMyLapsP3Listener
==============================================================================}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Mask,
  SmartTiming.Consts, SmartTiming.Cache, DecoderInterface, SmartTiming.DecoderEngine,
  SmartTiming.MyLapsFakeDecoder;

type
  TFormPassingSimulator = class(TForm)
    PanelTop: TPanel;
    LabelHint: TLabel;
    RadioGroupMode: TRadioGroup;
    PanelInputs: TPanel;
    LabelShortId: TLabel;
    EditShortId: TEdit;
    LabelChip: TLabel;
    LabelChipPreview: TLabel;
    LabelTime: TLabel;
    EditTime: TMaskEdit;
    LabelSignal: TLabel;
    EditSignal: TEdit;
    LabelHits: TLabel;
    EditHits: TEdit;
    ButtonSend: TButton;
    ButtonUseNow: TButton;
    PanelMapping: TPanel;
    LabelMappingStatus: TLabel;
    ButtonImportMapping: TButton;
    ButtonRunRuleTests: TButton;
    ButtonRunCorrectionTests: TButton;
    ListViewLog: TListView;
    PanelButtons: TPanel;
    ButtonClose: TButton;
    OpenDialogMapping: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ButtonCloseClick(Sender: TObject);
    procedure ButtonSendClick(Sender: TObject);
    procedure ButtonUseNowClick(Sender: TObject);
    procedure ButtonImportMappingClick(Sender: TObject);
    procedure ButtonRunRuleTestsClick(Sender: TObject);
    procedure ButtonRunCorrectionTestsClick(Sender: TObject);
    procedure EditShortIdChange(Sender: TObject);
    procedure RadioGroupModeClick(Sender: TObject);
  private
    FNextPassingNumber: Integer;
    FFakeDecoder: TMyLapsP3FakeDecoder;
    function UseP3Loopback: Boolean;
    procedure RefreshModeHint;
    procedure RefreshMappingStatus;
    procedure RefreshChipPreview;
    procedure SyncNextPassingNumber;
    procedure SetTimeEdit(ATime: TDateTime);
    function TryGetPassingTime(out ATime: TDateTime): Boolean;
    function TryResolveShortId(out AShortId: Integer; out AChipId: string): Boolean;
    procedure AppendLog(APassingNumber, AShortId: Integer; const AChipId: string;
      APassingTime: TDateTime; ASignal: Integer; const AChannel: string);
    function BuildPassing(AShortId: Integer; const AChipId: string;
      ATime: TDateTime; ASignal, AHits: Integer): TPassing;
    function EnsureP3Loopback: Boolean;
    procedure SendPassing;
  end;

implementation

{$R *.dfm}

uses
  DataModule, SmartTiming.Tools, SmartTiming.PassingValidator,
  SmartTiming.CorrectionRegression, System.DateUtils;

{==============================================================================}
procedure TFormPassingSimulator.FormCreate(Sender: TObject);
begin
  Caption := cMessagesSimulatorCaption;
  ButtonSend.Caption := cMessagesSimulatorSend;
  ButtonImportMapping.Caption := cMessagesSimulatorImportMapping;
  ButtonRunCorrectionTests.Caption := cMessagesSimulatorRunCorrectionTests;
  (* Create before ItemIndex — setting ItemIndex fires OnClick. *)
  FFakeDecoder := TMyLapsP3FakeDecoder.Create;
  RadioGroupMode.Items.Clear;
  RadioGroupMode.Items.Add(cMessagesSimulatorModeInProcess);
  RadioGroupMode.Items.Add(cMessagesSimulatorModeP3);
  RadioGroupMode.ItemIndex := 0;
  SyncNextPassingNumber;
  SetTimeEdit(Now);
  RefreshModeHint;
end;

{==============================================================================}
procedure TFormPassingSimulator.FormDestroy(Sender: TObject);
begin
  if FFakeDecoder <> nil then
    FFakeDecoder.Stop;
  FreeAndNil(FFakeDecoder);
end;

{==============================================================================}
procedure TFormPassingSimulator.FormShow(Sender: TObject);
begin
  RefreshMappingStatus;
  SyncNextPassingNumber;
  EditShortId.SetFocus;
end;

{==============================================================================}
procedure TFormPassingSimulator.ButtonCloseClick(Sender: TObject);
begin
  Close;
end;

{==============================================================================}
function TFormPassingSimulator.UseP3Loopback: Boolean;
begin
  Result := RadioGroupMode.ItemIndex = 1;
end;

{==============================================================================}
procedure TFormPassingSimulator.RefreshModeHint;
begin
  if UseP3Loopback then
    LabelHint.Caption := cMessagesSimulatorHintP3
  else
    LabelHint.Caption := cMessagesSimulatorHintInProcess;
end;

{==============================================================================}
procedure TFormPassingSimulator.RadioGroupModeClick(Sender: TObject);
begin
  RefreshModeHint;
  if (not UseP3Loopback) and (FFakeDecoder <> nil) then
    FFakeDecoder.Stop;
end;

{==============================================================================}
procedure TFormPassingSimulator.SyncNextPassingNumber;
begin
  FNextPassingNumber := Max(MainDataModule.GetMaxPassingNumber,
    TPassingStore.GetSingleton.MaxPassingNumber) + 1;
end;

{==============================================================================}
procedure TFormPassingSimulator.RefreshMappingStatus;
var
  lCount: Integer;
begin
  lCount := TTransponderMappingStore.GetSingleton.Count;
  if lCount = 0 then
    LabelMappingStatus.Caption := cMessagesSimulatorMappingNone
  else
    LabelMappingStatus.Caption := Format(cMessagesSimulatorMappingCount, [lCount]);
  RefreshChipPreview;
end;

{==============================================================================}
procedure TFormPassingSimulator.SetTimeEdit(ATime: TDateTime);
begin
  EditTime.Text := FormatDateTime('hh:nn:ss.zzz', ATime);
end;

{==============================================================================}
procedure TFormPassingSimulator.ButtonUseNowClick(Sender: TObject);
begin
  SetTimeEdit(Now);
end;

{==============================================================================}
function TFormPassingSimulator.TryGetPassingTime(out ATime: TDateTime): Boolean;
var
  lFormatSettings: TFormatSettings;
  lFrac: TDateTime;
begin
  lFormatSettings := TFormatSettings.Create;
  lFormatSettings.TimeSeparator := ':';
  lFormatSettings.DecimalSeparator := '.';
  lFormatSettings.LongTimeFormat := 'hh:nn:ss.zzz';
  Result := TryStrToTime(Trim(EditTime.Text), lFrac, lFormatSettings);
  if Result then
    ATime := Trunc(Now) + Frac(lFrac)
  else
    ATime := Now;
end;

{==============================================================================}
procedure TFormPassingSimulator.RefreshChipPreview;
var
  lShortId: Integer;
  lChipId: string;
begin
  if not TryStrToInt(Trim(EditShortId.Text), lShortId) or (lShortId <= 0) then
  begin
    LabelChipPreview.Caption := '-';
    Exit;
  end;
  lChipId := TTransponderMappingStore.GetSingleton.GetTransponderIdFromShortId(lShortId);
  if SameText(lChipId, cNotFound) or (lChipId = '') then
    LabelChipPreview.Caption := '?'
  else
    LabelChipPreview.Caption := lChipId;
end;

{==============================================================================}
procedure TFormPassingSimulator.EditShortIdChange(Sender: TObject);
begin
  RefreshChipPreview;
end;

{==============================================================================}
procedure TFormPassingSimulator.ButtonImportMappingClick(Sender: TObject);
var
  lFileName: string;
  lCount: Integer;
begin
  lFileName := gStdDataPath + 'TxMapping.txt';
  if FileExists(lFileName) then
    OpenDialogMapping.FileName := lFileName
  else
    OpenDialogMapping.InitialDir := gStdDataPath;

  if not OpenDialogMapping.Execute then
    Exit;

  lCount := MainDataModule.ImportTxMapping(OpenDialogMapping.FileName);
  RefreshMappingStatus;
  SmartTimingTools.ShowDialog(Format(cMessagesTxMappingLoaded, [lCount]), '', [tcbOk], tcbOk);
end;

{==============================================================================}
procedure TFormPassingSimulator.ButtonRunRuleTestsClick(Sender: TObject);
var
  lReport: string;
begin
  TPassingValidator.RunCatalogSelfTests(lReport);
  SmartTimingTools.ShowDialog(lReport, cMessagesSimulatorCaption, [tcbOk], tcbOk);
end;

{==============================================================================}
procedure TFormPassingSimulator.ButtonRunCorrectionTestsClick(Sender: TObject);
var
  lReport: string;
begin
  TCorrectionRegression.RunSelfTests(lReport);
  SmartTimingTools.ShowDialog(lReport, cMessagesSimulatorCaption, [tcbOk], tcbOk);
end;

{==============================================================================}
function TFormPassingSimulator.TryResolveShortId(out AShortId: Integer;
  out AChipId: string): Boolean;
begin
  Result := False;
  AShortId := 0;
  AChipId := '';

  if TTransponderMappingStore.GetSingleton.Count = 0 then
  begin
    SmartTimingTools.ShowDialog(cMessagesSimulatorMappingEmpty, '', [tcbOk], tcbOk);
    Exit;
  end;

  if not TryStrToInt(Trim(EditShortId.Text), AShortId) or (AShortId <= 0) then
  begin
    SmartTimingTools.ShowDialog(cMessagesSimulatorShortIdInvalid, '', [tcbOk], tcbOk);
    Exit;
  end;

  AChipId := TTransponderMappingStore.GetSingleton.GetTransponderIdFromShortId(AShortId);
  if SameText(AChipId, cNotFound) or (AChipId = '') then
  begin
    SmartTimingTools.ShowDialog(Format(cMessagesSimulatorShortIdUnknown, [AShortId]),
      '', [tcbOk], tcbOk);
    Exit;
  end;
  Result := True;
end;

{==============================================================================}
procedure TFormPassingSimulator.AppendLog(APassingNumber, AShortId: Integer;
  const AChipId: string; APassingTime: TDateTime; ASignal: Integer;
  const AChannel: string);
var
  lItem: TListItem;
begin
  lItem := ListViewLog.Items.Insert(0);
  lItem.Caption := APassingNumber.ToString;
  lItem.SubItems.Add(AShortId.ToString);
  lItem.SubItems.Add(AChipId);
  lItem.SubItems.Add(FormatDateTime('hh:nn:ss.zzz', APassingTime));
  lItem.SubItems.Add(ASignal.ToString);
  lItem.SubItems.Add(AChannel);
end;

{==============================================================================}
function TFormPassingSimulator.BuildPassing(AShortId: Integer; const AChipId: string;
  ATime: TDateTime; ASignal, AHits: Integer): TPassing;
begin
  Result := Default(TPassing);
  Result.PassingNumber := FNextPassingNumber;
  Result.ChipId := AChipId;
  Result.PassingTime := ATime;
  Result.SignalStrength := ASignal;
  Result.Hits := AHits;
  Result.Flags := 0;
  Result.Sport := sSportsIdCycling;
  Result.Voltage := 0;
  Result.Temperature := 0;
  Result.TxId := AShortId;
  Result.RaceId := -1;
  Result.LapIndex := -1;
  Result.CompetitorId := -1;
  if UseP3Loopback then
    Result.DecoderId := cSimulatorP3DecoderId
  else
    Result.DecoderId := 'STSIM';
end;

{==============================================================================}
function TFormPassingSimulator.EnsureP3Loopback: Boolean;
var
  lDecoder: TDecoder;
  lEngine: TDecoderEngine;
begin
  Result := False;
  try
    FFakeDecoder.Start;
  except
    on E: Exception do
    begin
      SmartTimingTools.ShowDialog(
        cMessagesSimulatorP3ConnectFailed + #13#10 + E.Message,
        cMessagesSimulatorCaption, [tcbOk], tcbOk);
      Exit;
    end;
  end;

  lEngine := TDecoderEngine.GetSingleton;
  if not (lEngine.Connected and SameText(lEngine.ActiveDecoder.Address, '127.0.0.1')
    and SameText(lEngine.ActiveDecoder.DecoderManufacturer, cDecoderManufacturerMyLaps)) then
  begin
    lDecoder := Default(TDecoder);
    lDecoder.DecoderId := cSimulatorP3DecoderId;
    lDecoder.DecoderManufacturer := cDecoderManufacturerMyLaps;
    lDecoder.Address := '127.0.0.1';
    lDecoder.FirmwareVersion := 'SIM';
    lDecoder.DecoderType := 'FakeP3';
    lEngine.ActiveDecoder := lDecoder;
  end;

  if not FFakeDecoder.WaitForClient(3000) then
  begin
    SmartTimingTools.ShowDialog(cMessagesSimulatorP3ConnectFailed,
      cMessagesSimulatorCaption, [tcbOk], tcbOk);
    Exit;
  end;
  Result := True;
end;

{==============================================================================}
procedure TFormPassingSimulator.SendPassing;
var
  lShortId: Integer;
  lChipId: string;
  lPassing: TPassing;
  lSignal: Integer;
  lHits: Integer;
  lTime: TDateTime;
  lChannel: string;
begin
  if not TryResolveShortId(lShortId, lChipId) then
    Exit;

  SyncNextPassingNumber;
  if not TryGetPassingTime(lTime) then
    lTime := Now;
  if not TryStrToInt(Trim(EditSignal.Text), lSignal) then
    lSignal := 100;
  if not TryStrToInt(Trim(EditHits.Text), lHits) then
    lHits := 90;

  lPassing := BuildPassing(lShortId, lChipId, lTime, lSignal, lHits);

  if UseP3Loopback then
  begin
    if not EnsureP3Loopback then
      Exit;
    try
      FFakeDecoder.SendPassing(lPassing);
    except
      on E: Exception do
      begin
        SmartTimingTools.ShowDialog(
          cMessagesSimulatorP3ConnectFailed + #13#10 + E.Message,
          cMessagesSimulatorCaption, [tcbOk], tcbOk);
        Exit;
      end;
    end;
    lChannel := 'P3';
  end
  else
  begin
    TDecoderEngine.GetSingleton.SendSimulatedPassing(lPassing);
    lChannel := 'InProc';
  end;

  AppendLog(lPassing.PassingNumber, lShortId, lChipId, lPassing.PassingTime, lSignal, lChannel);
  Inc(FNextPassingNumber);
  SetTimeEdit(IncMilliSecond(lTime, 500));

  EditShortId.SelectAll;
  EditShortId.SetFocus;
end;

{==============================================================================}
procedure TFormPassingSimulator.ButtonSendClick(Sender: TObject);
begin
  SendPassing;
end;

end.
