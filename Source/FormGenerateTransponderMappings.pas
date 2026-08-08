unit FormGenerateTransponderMappings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Data.DB, Generics.Collections,
  Vcl.Grids, Vcl.DBGrids, Vcl.ComCtrls, MMSystem, SmartTiming.Cache, SmartTiming.DecoderEngine,
  DecoderInterface, SmartTiming.Consts;

type
  TFormGenerateTransponderMappings = class(TForm)
    PanelButtons: TPanel;
    ButtonOK: TButton;
    ButtonCancel: TButton;
    PanelMain: TPanel;
    CheckBoxClearExisiting: TCheckBox;
    EditStartingNumber: TEdit;
    Label1: TLabel;
    CheckBoxFillGaps: TCheckBox;
    MemoLog: TMemo;
    ButtonStartReceiving: TButton;
    procedure CheckBoxClearExisitingClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CheckBoxFillGapsClick(Sender: TObject);
    procedure ButtonStartReceivingClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
  private
    FRunning: boolean;
    FFirstGap: Integer;
    FSavedPassingReceiveEvent: TDecoderPassingReceivedEvent;

    procedure FindFirstGap;
    procedure FindLastEntry;
    procedure OnReceivePassing(APassing: TPassing);
    procedure CreateNewMappingFor(const AChipCode: string);
  public
    { Public-Deklarationen }
  end;

implementation

{$R *.dfm}

uses
  FormMain, DataModule;

{==============================================================================}
procedure TFormGenerateTransponderMappings.ButtonOKClick(Sender: TObject);
begin
  MainDataModule.SaveTransponderMappingCache;

  gFormMain.FileOpenDialog.DefaultExtension := 'txt';
  gFormMain.FileOpenDialog.OkButtonLabel := cButtonCaptionExport;
  if not gFormMain.FileOpenDialog.Execute then
    Exit;
  MainDataModule.ExportTxMapping(gFormMain.FileOpenDialog.FileName);
end;

{==============================================================================}
procedure TFormGenerateTransponderMappings.ButtonStartReceivingClick(Sender: TObject);
begin
  if FRunning then
  begin
    TDecoderEngine.GetSingleton.NewPassingReceived := FSavedPassingReceiveEvent;
    FRunning := false;
    ButtonStartReceiving.Caption := 'Starten';
    Exit;
  end
  else
  begin
    FSavedPassingReceiveEvent := TDecoderEngine.GetSingleton.NewPassingReceived;
    TDecoderEngine.GetSingleton.NewPassingReceived := OnReceivePassing;
    if CheckBoxClearExisiting.Checked then
      TTransponderMappingStore.GetSingleton.Clear;
    FRunning := true;
    ButtonStartReceiving.Caption := 'Beenden';
  end;
end;

{==============================================================================}
procedure TFormGenerateTransponderMappings.CreateNewMappingFor(const AChipCode: string);
var
  lShortId: integer;
begin
  lShortId := TTransponderMappingStore.GetSingleton.GetShortIdFromTransponderId(AChipCode);
  if lShortId >= 0 then
  begin
    MemoLog.Lines.Add('Warnung: Übersetzung für ' + AChipCode + ' bereits vorhanden (' + lShortId.ToString + ')');
    Exit;
  end;

  if CheckBoxFillGaps.Checked then
    FindFirstGap
  else
    FindLastEntry;
  TTransponderMappingStore.GetSingleton.AddTransponder(FFirstGap, AChipCode);
  MemoLog.Lines.Add('Übersetzung erzeugt für: ' + AChipCode + ': ' + FFirstGap.ToString);
end;

{==============================================================================}
procedure TFormGenerateTransponderMappings.OnReceivePassing(APassing: TPassing);
begin
  PlaySound('PassingBeep', 0, SND_NOSTOP or SND_NOWAIT or SND_RESOURCE or SND_ASYNC or SND_NODEFAULT);
  CreateNewMappingFor(APassing.ChipId);
end;

{==============================================================================}
procedure TFormGenerateTransponderMappings.CheckBoxClearExisitingClick(Sender: TObject);
begin
  if CheckBoxClearExisiting.Checked then
  begin
    CheckBoxFillGaps.Checked := false;
    CheckBoxFillGaps.Enabled := false;
    EditStartingNumber.Text := '1';
    FFirstGap := 1;
  end
  else
  begin
    CheckBoxFillGaps.Checked := true;
    CheckBoxFillGaps.Enabled := true;
    FindFirstGap;
  end;
end;

{==============================================================================}
procedure TFormGenerateTransponderMappings.FormCreate(Sender: TObject);
begin
  FindFirstGap;
  FRunning := false;
end;

{==============================================================================}
procedure TFormGenerateTransponderMappings.FormDestroy(Sender: TObject);
begin
  if FRunning then
    TDecoderEngine.GetSingleton.NewPassingReceived := FSavedPassingReceiveEvent;
end;

{==============================================================================}
procedure TFormGenerateTransponderMappings.CheckBoxFillGapsClick(Sender: TObject);
begin
  if CheckBoxFillGaps.Checked then
    FindFirstGap
  else
    FindLastEntry;
end;

{==============================================================================}
procedure TFormGenerateTransponderMappings.FindFirstGap;
var
  lSearchIndex: integer;
  lMappingCache: TTransponderMappingStore;
  lShortIdList: TDictionary<integer, string>;
begin
  lMappingCache := TTransponderMappingStore.GetSingleton;
  lMappingCache.Lock;
  lShortIdList := lMappingCache.ShortIdToTxId;
  try
    FFirstGap := lShortIdList.Count + 1;
    for lSearchIndex := 1 to lShortIdList.Count do
    begin
      if not lShortIdList.ContainsKey(lSearchIndex) then
      begin
        FFirstGap := lSearchIndex;
        break;
      end;
    end;
    EditStartingNumber.Text := FFirstGap.ToString;
  finally
    lMappingCache.Unlock;
  end;
end;

{==============================================================================}
procedure TFormGenerateTransponderMappings.FindLastEntry;
var
  lListId: integer;
  lMappingCache: TTransponderMappingStore;
  lShortIdList: TDictionary<integer, string>;
begin
  lMappingCache := TTransponderMappingStore.GetSingleton;
  lMappingCache.Lock;
  lShortIdList := lMappingCache.ShortIdToTxId;
  try
    FFirstGap := String(EditStartingNumber.Text).ToInteger;
    for lListId in lShortIdList.Keys do
    begin
      if lListId >= FFirstGap then
        FFirstGap := lListId + 1;
    end;
    EditStartingNumber.Text := FFirstGap.ToString;
  finally
    lMappingCache.Unlock;
  end;
end;

end.
