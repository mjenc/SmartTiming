unit FormPassingSimulator;

{==============================================================================
  Decoder simulator (Plan 9 Phase A): enter short IDs, resolve via Tx mapping,
  inject passings through TDecoderEngine.SendSimulatedPassing.
==============================================================================}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.Mask,
  SmartTiming.Consts, SmartTiming.Cache, DecoderInterface, SmartTiming.DecoderEngine;

type
  TFormPassingSimulator = class(TForm)
    PanelTop: TPanel;
    LabelHint: TLabel;
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
    ListViewLog: TListView;
    PanelButtons: TPanel;
    ButtonClose: TButton;
    OpenDialogMapping: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ButtonCloseClick(Sender: TObject);
    procedure ButtonSendClick(Sender: TObject);
    procedure ButtonUseNowClick(Sender: TObject);
    procedure ButtonImportMappingClick(Sender: TObject);
    procedure EditShortIdChange(Sender: TObject);
  private
    FNextPassingNumber: Integer;
    procedure RefreshMappingStatus;
    procedure RefreshChipPreview;
    procedure SyncNextPassingNumber;
    procedure SetTimeEdit(ATime: TDateTime);
    function TryGetPassingTime(out ATime: TDateTime): Boolean;
    function TryResolveShortId(out AShortId: Integer; out AChipId: string): Boolean;
    procedure AppendLog(APassingNumber, AShortId: Integer; const AChipId: string;
      APassingTime: TDateTime; ASignal: Integer);
    procedure SendPassing;
  end;

implementation

{$R *.dfm}

uses
  DataModule, SmartTiming.Tools;

{==============================================================================}
procedure TFormPassingSimulator.FormCreate(Sender: TObject);
begin
  Caption := cMessagesSimulatorCaption;
  ButtonSend.Caption := cMessagesSimulatorSend;
  ButtonImportMapping.Caption := cMessagesSimulatorImportMapping;
  SyncNextPassingNumber;
  SetTimeEdit(Now);
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
  const AChipId: string; APassingTime: TDateTime; ASignal: Integer);
var
  lItem: TListItem;
begin
  lItem := ListViewLog.Items.Insert(0);
  lItem.Caption := APassingNumber.ToString;
  lItem.SubItems.Add(AShortId.ToString);
  lItem.SubItems.Add(AChipId);
  lItem.SubItems.Add(FormatDateTime('hh:nn:ss.zzz', APassingTime));
  lItem.SubItems.Add(ASignal.ToString);
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

  lPassing.PassingNumber := FNextPassingNumber;
  lPassing.ChipId := lChipId;
  lPassing.PassingTime := lTime;
  lPassing.SignalStrength := lSignal;
  lPassing.Hits := lHits;
  lPassing.Flags := 0;
  lPassing.Sport := sSportsIdCycling;
  lPassing.Voltage := 0;
  lPassing.Temperature := 0;
  lPassing.DecoderId := 'STSIM';
  lPassing.TxId := lShortId;
  lPassing.RaceId := -1;

  TDecoderEngine.GetSingleton.SendSimulatedPassing(lPassing);
  AppendLog(lPassing.PassingNumber, lShortId, lChipId, lPassing.PassingTime, lSignal);
  Inc(FNextPassingNumber);

  EditShortId.SelectAll;
  EditShortId.SetFocus;
end;

{==============================================================================}
procedure TFormPassingSimulator.ButtonSendClick(Sender: TObject);
begin
  SendPassing;
end;

end.
