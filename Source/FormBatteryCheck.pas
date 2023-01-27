unit FormBatteryCheck;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, MMSystem,
  Clipbrd,
  Generics.Collections, SmartTiming.Consts, SmartTiming.Cache,
  DecoderInterface, SmartTiming.DecoderEngine, System.ImageList,
  Vcl.ImgList;

type
  TFormBatteryCheck = class(TForm)
    PanelButtons: TPanel;
    ButtonOK: TButton;
    ButtonCancel: TButton;
    PanelMain: TPanel;
    ButtonStartReceiving: TButton;
    ButtonClearList: TButton;
    ListViewTransponderBatteryStatus: TListView;
    ImageListIcons: TImageList;
    LabelReadCount: TLabel;
    ButtonFillGaps: TButton;
    RadioGroup1: TRadioGroup;
    RadioButtonAll: TRadioButton;
    RadioButtonCriticals: TRadioButton;
    RadioButtonGaps: TRadioButton;
    RadioButtonWeaks: TRadioButton;
    ButtonCopyListToClipboard: TButton;
    procedure ButtonStartReceivingClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonClearListClick(Sender: TObject);
    procedure ListViewTransponderBatteryStatusCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure ButtonFillGapsClick(Sender: TObject);
    procedure RadioButtonAllClick(Sender: TObject);
    procedure ButtonCopyListToClipboardClick(Sender: TObject);
  private
    FRunning: boolean;
    FSavedPassingReceiveEvent: TDecoderPassingReceivedEvent;
    FReceivedIDs: TDictionary<integer, string>;
    FLastReceivedPassingNumber: integer;

    procedure OnReceivePassing(APassing: TPassing);
    function FindListItem(ATransponderID: integer): TListItem;
    procedure RefreshList;
  public


  end;


implementation

{$R *.dfm}


{==============================================================================}
procedure TFormBatteryCheck.ButtonStartReceivingClick(Sender: TObject);
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
    FLastReceivedPassingNumber := -1;
    FSavedPassingReceiveEvent := TDecoderEngine.GetSingleton.NewPassingReceived;
    TDecoderEngine.GetSingleton.NewPassingReceived := OnReceivePassing;
    FRunning := true;
    ButtonStartReceiving.Caption := 'Beenden';
  end;
end;

{==============================================================================}
procedure TFormBatteryCheck.FormCreate(Sender: TObject);
begin
  FRunning := false;
  FReceivedIDs := TDictionary<integer, string>.Create;
  FLastReceivedPassingNumber := -1;
end;

{==============================================================================}
procedure TFormBatteryCheck.FormDestroy(Sender: TObject);
begin
  if FRunning then
    TDecoderEngine.GetSingleton.NewPassingReceived := FSavedPassingReceiveEvent;
  FreeAndNil(FReceivedIDs);
end;

{==============================================================================}
procedure TFormBatteryCheck.ListViewTransponderBatteryStatusCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
begin
  Compare := 0;

  if (Item1.Caption.ToInteger > Item2.Caption.ToInteger) then
  begin
    Compare := 1;
    Exit;
  end;
  if (Item1.Caption.ToInteger < Item2.Caption.ToInteger) then
    Compare := -1;
end;

{==============================================================================}
function TFormBatteryCheck.FindListItem(ATransponderID: integer): TListItem;
var
  i: integer;
begin
  for i := 0 to ListViewTransponderBatteryStatus.Items.Count - 1 do
  begin
    if ListViewTransponderBatteryStatus.Items[i].Caption = ATransponderID.ToString then
      Exit(ListViewTransponderBatteryStatus.Items[i]);
  end;
  result := nil;
end;

{==============================================================================}
procedure TFormBatteryCheck.OnReceivePassing(APassing: TPassing);
  procedure AddPassingToList(AListItem: TListItem; AInternalPassing: TPassing);
  begin
    ListViewTransponderBatteryStatus.Items.BeginUpdate;
    try
      AListItem.ImageIndex := APassing.Flags;
      AListItem.Caption := APassing.TxId.ToString;
      AListItem.SubItems.Add(APassing.ChipID);
      AListItem.SubItems.Add(APassing.Flags.ToString);
      AListItem.SubItems.Add(APassing.SignalStrength.ToString);

      LabelReadCount.Caption := 'Gelesen: ' + FReceivedIDs.Count.ToString;
    finally
      ListViewTransponderBatteryStatus.Items.EndUpdate;
    end;
  end;


var
  lChipID: string;
  lListItem: TListItem;
  lPassing: TPassing;
begin
  PlaySound('PassingBeep', 0, SND_NOSTOP or SND_NOWAIT or SND_RESOURCE or SND_ASYNC or SND_NODEFAULT);

  if (FLastReceivedPassingNumber >= 0) and (FLastReceivedPassingNumber + 1 < APassing.PassingNumber) then
  begin
    lPassing.PassingNumber := FLastReceivedPassingNumber + 1;
    lPassing.ChipId := '-';
    lPassing.PassingTime := Now;
    lPassing.SignalStrength := 0;
    lPassing.Hits := 0;
    lPassing.Flags := 1;
    lPassing.Sport := 4;
    lPassing.Voltage := 0;
    lPassing.Temperature := 0;
    lPassing.DecoderId := 'MISSED';
    lPassing.TxId := -1;
    lListItem := ListViewTransponderBatteryStatus.Items.AddItem(nil);
    AddPassingToList(lListItem, APassing);
    Exit;
  end;

  if not FReceivedIDs.TryGetValue(APassing.TxId, lChipID) then
  begin
    lListItem := ListViewTransponderBatteryStatus.Items.AddItem(nil);
    FReceivedIDs.Add(APassing.TxId, APassing.ChipID);
  end
  else
    lListItem := FindListItem(APassing.TxId);
  AddPassingToList(lListItem, APassing);
end;

{==============================================================================}
procedure TFormBatteryCheck.RadioButtonAllClick(Sender: TObject);
begin
  try
    if RadioButtonAll.Checked then
    begin
      Exit;
    end;
    if RadioButtonAll.Checked then
    begin
      Exit;
    end;
    if RadioButtonAll.Checked then
    begin
      Exit;
    end;
    if RadioButtonAll.Checked then
    begin
      Exit;
    end;
  finally
    RefreshList;
  end;
end;

{==============================================================================}
procedure TFormBatteryCheck.RefreshList;
begin
  // TODO ... but what?
end;

{==============================================================================}
procedure TFormBatteryCheck.ButtonClearListClick(Sender: TObject);
begin
  ListViewTransponderBatteryStatus.Clear;
  LabelReadCount.Caption := 'Gelesen: 0';
  FReceivedIDs.Clear;
end;

{==============================================================================}
procedure TFormBatteryCheck.ButtonCopyListToClipboardClick(Sender: TObject);
var
  lText: string;
  i: integer;
begin
  lText := '';

  for i := 0 to ListViewTransponderBatteryStatus.GetCount - 1 do
    lText := lText + ListViewTransponderBatteryStatus.Items[i].Caption + #13#10;

  Clipboard.AsText := lText;
end;

{==============================================================================}
procedure TFormBatteryCheck.ButtonFillGapsClick(Sender: TObject);
var
  i: integer;
  lPred: integer;
  lActual: integer;
  lListItem: TListItem;
  lChipID: string;
begin
  i := 1;
  lPred := ListViewTransponderBatteryStatus.Items[0].Caption.ToInteger;
  while i < ListViewTransponderBatteryStatus.Items.Count do
  begin
    lActual := ListViewTransponderBatteryStatus.Items[i].Caption.ToInteger;
    while lPred + 1 < lActual do
    begin
      Inc(lPred);
      lChipID := TTransponderMappingStore.GetSingleton.GetTransponderIdFromShortId(lPred);
      if SameText(lChipID, cNotFound) then
        Continue;

      lListItem := ListViewTransponderBatteryStatus.Items.AddItem(nil);
      lListItem.ImageIndex := 1;
      lListItem.Caption := lPred.ToString;
      lListItem.SubItems.Add(lChipID);
      lListItem.SubItems.Add('-');
      lListItem.SubItems.Add('-');
      FReceivedIDs.Add(lPred, lChipID);
    end;

    lPred := ListViewTransponderBatteryStatus.Items[i].Caption.ToInteger;
    Inc(i);
  end;
end;


end.
