unit uFormBatteryCheck;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, MMSystem,
  Generics.Collections, SmartTiming.Consts, SmartTiming.Cache,
  SmartTiming.DecoderInterface, SmartTiming.DecoderEngine, System.ImageList,
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
    procedure ButtonStartReceivingClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonClearListClick(Sender: TObject);
    procedure ListViewTransponderBatteryStatusCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure ButtonFillGapsClick(Sender: TObject);
  private
    FRunning: boolean;
    FSavedPassingReceiveEvent: TDecoderPassingReceivedEvent;
    FReceivedIDs: TDictionary<integer, string>;
    procedure OnReceivePassing(APassing: TMyLapsP3Passing);
    function FindListItem(ATransponderID: integer): TListItem;
  public
    { Public-Deklarationen }
  end;


implementation

{$R *.dfm}


{==============================================================================}
procedure TFormBatteryCheck.ButtonStartReceivingClick(Sender: TObject);
begin
  if FRunning then
  begin
    TMyLapsDecoderEngine.GetSingleton.NewPassingReceived := FSavedPassingReceiveEvent;
    FRunning := false;
    ButtonStartReceiving.Caption := 'Starten';
    Exit;
  end
  else
  begin
    FSavedPassingReceiveEvent := TMyLapsDecoderEngine.GetSingleton.NewPassingReceived;
    TMyLapsDecoderEngine.GetSingleton.NewPassingReceived := OnReceivePassing;
    FRunning := true;
    ButtonStartReceiving.Caption := 'Beenden';
  end;
end;

{==============================================================================}
procedure TFormBatteryCheck.FormCreate(Sender: TObject);
begin
  FRunning := false;
  FReceivedIDs := TDictionary<integer, string>.Create;
end;

{==============================================================================}
procedure TFormBatteryCheck.FormDestroy(Sender: TObject);
begin
  if FRunning then
    TMyLapsDecoderEngine.GetSingleton.NewPassingReceived := FSavedPassingReceiveEvent;
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
end;

{==============================================================================}
procedure TFormBatteryCheck.OnReceivePassing(APassing: TMyLapsP3Passing);
var
  lChipID: string;
  lListItem: TListItem;
begin
  PlaySound('PassingBeep', 0, SND_NOSTOP or SND_NOWAIT or SND_RESOURCE or SND_ASYNC or SND_NODEFAULT);

  if not FReceivedIDs.TryGetValue(APassing.TransponderShortId, lChipID) then
  begin
    lListItem := ListViewTransponderBatteryStatus.Items.AddItem(nil);
    FReceivedIDs.Add(APassing.TransponderShortId, APassing.ChipID);
  end
  else
    lListItem := FindListItem(APassing.TransponderShortId);

  ListViewTransponderBatteryStatus.Items.BeginUpdate;
  try
    lListItem.ImageIndex := APassing.Flags;
    lListItem.Caption := APassing.TransponderShortId.ToString;
    lListItem.SubItems.Add(APassing.ChipID);
    lListItem.SubItems.Add(APassing.Flags.ToString);
    lListItem.SubItems.Add(APassing.SignalStrength.ToString);

    LabelReadCount.Caption := 'Gelesen: ' + FReceivedIDs.Count.ToString;
  finally
    ListViewTransponderBatteryStatus.Items.EndUpdate;
  end;
end;

{==============================================================================}
procedure TFormBatteryCheck.ButtonClearListClick(Sender: TObject);
begin
  ListViewTransponderBatteryStatus.Clear;
  LabelReadCount.Caption := 'Gelesen: 0';
  FReceivedIDs.Clear;
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
