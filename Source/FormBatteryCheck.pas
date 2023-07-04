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
    ButtonCopyListToClipboard: TButton;
    CheckBoxCopyGaps: TCheckBox;
    CheckBoxWeak: TCheckBox;
    CheckBoxHealthy: TCheckBox;
    Button1: TButton;
    procedure ButtonStartReceivingClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonClearListClick(Sender: TObject);
    procedure ListViewTransponderBatteryStatusCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure ButtonFillGapsClick(Sender: TObject);
    procedure ButtonCopyListToClipboardClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    FRunning: boolean;
    FSavedPassingReceiveEvent: TDecoderPassingReceivedEvent;
    FReceivedIDs: TDictionary<integer, string>;
    FLastReceivedPassingNumber: integer;

    procedure OnReceivePassing(APassing: TPassing);
    function FindListItem(ATransponderID: integer): TListItem;
  public


  end;


implementation

{$R *.dfm}


resourcestring
  cGapNotFunctional = 'Lücken / Ohne Funktion';
  cWeak = 'Schwacher Batteriestatus';
  cHealthy = 'Gesund';

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
procedure TFormBatteryCheck.Button1Click(Sender: TObject);
type
  TReportStep = (rsGaps, rsWeak, rsHealthy);
var
  lText: string;
  i: integer;
  lStep: TReportStep;
  lGapCount: integer;
  lWeakCount: integer;
  lHealthyCount: integer;
begin
  ButtonFillGapsClick(Sender);

  lText := '';
  lGapCount := 0;
  lWeakCount := 0;
  lHealthyCount := 0;

  for lStep := rsGaps to rsHealthy do
  begin
    if lStep = rsGaps then
      lText := lText + cGapNotFunctional + #13#10
    else if lStep = rsWeak then
      lText := lText + cWeak + #13#10
    else if lStep = rsHealthy then
      lText := lText + cHealthy + #13#10;

    for i := 0 to ListViewTransponderBatteryStatus.GetCount - 1 do
    begin
      if (lStep = rsGaps) and (ListViewTransponderBatteryStatus.Items[i].SubItems[1] = '-') then
      begin
        Inc(lGapCount);
        lText := lText + ListViewTransponderBatteryStatus.Items[i].Caption + #13#10;
        Continue;
      end;
      if (lStep = rsWeak) and (ListViewTransponderBatteryStatus.Items[i].SubItems[1] = '1') then
      begin
        Inc(lWeakCount);
        lText := lText + ListViewTransponderBatteryStatus.Items[i].Caption + #13#10;
        Continue;
      end;
      if (lStep = rsHealthy)  and  (ListViewTransponderBatteryStatus.Items[i].SubItems[1] = '0') then
      begin
        Inc(lHealthyCount);
        lText := lText + ListViewTransponderBatteryStatus.Items[i].Caption + #13#10;
      end;
    end;

     lText := lText + '************************************' + #13#10;
  end;

  lText := lText + 'Zusammenfassung'#13#10;
  lText := lText + '==============='#13#10;
  lText := lText + cGapNotFunctional + ': ' +lGapCount.ToString + #13#10;
  lText := lText + cWeak + ': ' +lWeakCount.ToString + #13#10;
  lText := lText + cHealthy + ': ' +lHealthyCount.ToString + #13#10;
  Clipboard.AsText := lText;
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
  begin
    if CheckBoxCopyGaps.Checked and (ListViewTransponderBatteryStatus.Items[i].SubItems[1] = '-') then
    begin
      lText := lText + ListViewTransponderBatteryStatus.Items[i].Caption + #13#10;
      Continue;
    end;
    if CheckBoxWeak.Checked and (ListViewTransponderBatteryStatus.Items[i].SubItems[1] = '1') then
    begin
      lText := lText + ListViewTransponderBatteryStatus.Items[i].Caption + #13#10;
      Continue;
    end;
    if CheckBoxHealthy.Checked and  (ListViewTransponderBatteryStatus.Items[i].SubItems[1] = '0') then
      lText := lText + ListViewTransponderBatteryStatus.Items[i].Caption + #13#10;
  end;

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
