unit FormAddPassing;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Mask,
  DataModule, Vcl.ComCtrls, DecoderInterface, SmartTiming.Consts;

type
  TFormManuallyAddPassing = class(TForm)
    ButtonOK: TButton;
    ButtonCancel: TButton;
    Label2: TLabel;
    EditTime: TMaskEdit;
    Label3: TLabel;
    EditBIB: TEdit;
    PanelControls: TPanel;
    PanelGrid: TPanel;
    ListViewCompetitors: TListView;
    LabelRace: TLabel;
    LabelPreview: TLabel;
    ComboBoxRace: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ButtonOKClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ListViewCompetitorsDblClick(Sender: TObject);
    procedure ListViewCompetitorsClick(Sender: TObject);
    procedure ComboBoxRaceChange(Sender: TObject);
    procedure EditBIBChange(Sender: TObject);
  private
    FHour: Word;
    FMin: Word;
    FSec: Word;
    FMs: Word;
    FUpdatingUI: Boolean;

    function TryAddPassingForBib(ABib: Integer): Boolean;
    procedure SetTime(ATime: TDatetime);
    function GetTime: TDatetime;
    function GetSelectedRaceId: Integer;
    procedure FillRaceCombo;
    procedure ReloadCompetitors;
    procedure UpdatePreview;
    procedure UpdateControlsEnabled;
    procedure SelectListItemForBib(const ABibText: string);
  end;

implementation

{$R *.dfm}

uses
  SmartTiming.Controller, SmartTiming.Tools, FormMain, RaceEngine.Custom;

{==============================================================================}
procedure TFormManuallyAddPassing.FormActivate(Sender: TObject);
begin
  if EditBIB.CanFocus then
    EditBIB.SetFocus;
end;

{==============================================================================}
procedure TFormManuallyAddPassing.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
end;

{==============================================================================}
procedure TFormManuallyAddPassing.FormCreate(Sender: TObject);
begin
  FUpdatingUI := False;
end;

{==============================================================================}
procedure TFormManuallyAddPassing.SetTime(ATime: TDatetime);
begin
  DecodeTime(ATime, FHour, FMin, FSec, FMs);
  EditTime.Text := FormatDatetime('HH:mm:ss.ms', ATime);
end;

{==============================================================================}
procedure TFormManuallyAddPassing.FormDestroy(Sender: TObject);
begin
  { no owned state }
end;

{==============================================================================}
function TFormManuallyAddPassing.GetSelectedRaceId: Integer;
begin
  Result := -1;
  if ComboBoxRace.ItemIndex < 0 then
    Exit;
  Result := Integer(ComboBoxRace.Items.Objects[ComboBoxRace.ItemIndex]);
end;

{==============================================================================}
procedure TFormManuallyAddPassing.FillRaceCombo;
var
  lRaceId: Integer;
  lRaceItem: TRaceItem;
  lDefaultRaceId: Integer;
  lText: string;
  lIndex: Integer;
  i: Integer;
begin
  lDefaultRaceId := GFormMain.GetSelectedRaceId;
  ComboBoxRace.Items.BeginUpdate;
  try
    ComboBoxRace.Items.Clear;
    for lRaceId in GSmartTimingController.RaceList.Keys do
    begin
      if not GSmartTimingController.RaceList.TryGetValue(lRaceId, lRaceItem) then
        Continue;
      if not (lRaceItem.Status in cActiveRaceStatusesForChipConflict) then
        Continue;
      lText := FormatDatetime('hh:mm', lRaceItem.StartTime) + ' - ' + lRaceItem.Title +
        ' (' + SmartTimingTools.GetRaceStatusStringFromEnum(lRaceItem.Status) + ')';
      ComboBoxRace.Items.AddObject(lText, TObject(lRaceId));
    end;
    ComboBoxRace.Sorted := True;
  finally
    ComboBoxRace.Items.EndUpdate;
  end;

  lIndex := -1;
  if lDefaultRaceId >= 0 then
    for i := 0 to ComboBoxRace.Items.Count - 1 do
      if Integer(ComboBoxRace.Items.Objects[i]) = lDefaultRaceId then
      begin
        lIndex := i;
        Break;
      end;
  if (lIndex < 0) and (ComboBoxRace.Items.Count > 0) then
    lIndex := 0;
  ComboBoxRace.ItemIndex := lIndex;
  UpdateControlsEnabled;
end;

{==============================================================================}
procedure TFormManuallyAddPassing.UpdateControlsEnabled;
var
  lHasRace: Boolean;
begin
  lHasRace := GetSelectedRaceId >= 0;
  ComboBoxRace.Enabled := ComboBoxRace.Items.Count > 0;
  EditBIB.Enabled := lHasRace;
  EditTime.Enabled := lHasRace;
  ButtonOK.Enabled := lHasRace;
  ListViewCompetitors.Enabled := lHasRace;
  if not lHasRace then
  begin
    LabelPreview.Caption := cMessagesManualPassingNoActiveRace;
    LabelPreview.Font.Color := clGrayText;
  end;
end;

{==============================================================================}
procedure TFormManuallyAddPassing.ReloadCompetitors;
begin
  MainDataModule.FillCompetitorsInRace(GetSelectedRaceId, ListViewCompetitors,
    Trim(EditBIB.Text));
  UpdatePreview;
end;

{==============================================================================}
procedure TFormManuallyAddPassing.UpdatePreview;
var
  lRaceId: Integer;
  lBib: Integer;
  lCompetitorId: Integer;
  lName, lTeam, lClass, lChipId: string;
begin
  lRaceId := GetSelectedRaceId;
  if lRaceId < 0 then
  begin
    LabelPreview.Caption := cMessagesManualPassingNoActiveRace;
    LabelPreview.Font.Color := clGrayText;
    Exit;
  end;

  if (Trim(EditBIB.Text) = '') or not TryStrToInt(Trim(EditBIB.Text), lBib) then
  begin
    LabelPreview.Caption := cMessagesManualPassingPreviewNone;
    LabelPreview.Font.Color := clGrayText;
    Exit;
  end;

  if not MainDataModule.TryGetCompetitorInRaceByBib(lRaceId, lBib, lCompetitorId,
       lName, lTeam, lClass, lChipId) then
  begin
    LabelPreview.Caption := Format(cMessagesManualPassingBibNotInRace, [lBib]);
    LabelPreview.Font.Color := clGrayText;
    Exit;
  end;

  LabelPreview.Font.Color := clWindowText;
  if lChipId = '' then
    LabelPreview.Caption := Format(cMessagesManualPassingPreviewNoChip, [lName])
  else
    LabelPreview.Caption := Format(cMessagesManualPassingPreviewFmt, [lName, lChipId]);
end;

{==============================================================================}
procedure TFormManuallyAddPassing.SelectListItemForBib(const ABibText: string);
var
  i: Integer;
  lItem: TListItem;
begin
  ListViewCompetitors.Selected := nil;
  if ABibText = '' then
    Exit;
  for i := 0 to ListViewCompetitors.Items.Count - 1 do
  begin
    lItem := ListViewCompetitors.Items[i];
    if lItem.Caption.StartsWith(ABibText) then
    begin
      lItem.Selected := True;
      lItem.MakeVisible(False);
      Exit;
    end;
  end;
end;

{==============================================================================}
procedure TFormManuallyAddPassing.FormShow(Sender: TObject);
begin
  FUpdatingUI := True;
  try
    SetTime(Now);
    EditBIB.Text := '';
    FillRaceCombo;
    ReloadCompetitors;
  finally
    FUpdatingUI := False;
  end;
  if EditBIB.CanFocus then
    EditBIB.SetFocus
  else if ButtonCancel.CanFocus then
    ButtonCancel.SetFocus;
end;

{==============================================================================}
procedure TFormManuallyAddPassing.ComboBoxRaceChange(Sender: TObject);
begin
  if FUpdatingUI then
    Exit;
  ReloadCompetitors;
end;

{==============================================================================}
procedure TFormManuallyAddPassing.EditBIBChange(Sender: TObject);
begin
  if FUpdatingUI then
    Exit;
  ReloadCompetitors;
  SelectListItemForBib(Trim(EditBIB.Text));
end;

{==============================================================================}
procedure TFormManuallyAddPassing.ButtonCancelClick(Sender: TObject);
begin
  Close;
end;

{==============================================================================}
procedure TFormManuallyAddPassing.ButtonOKClick(Sender: TObject);
var
  lBib: Integer;
  lBibText: string;
begin
  if GetSelectedRaceId < 0 then
  begin
    SmartTimingTools.ShowDialog(cMessagesManualPassingNoActiveRace, '', [tcbOk], tcbOk);
    Exit;
  end;

  lBibText := Trim(EditBIB.Text);
  if lBibText = '' then
  begin
    SmartTimingTools.ShowDialog(cMessagesManualPassingNoBib, '', [tcbOk], tcbOk);
    EditBIB.SetFocus;
    Exit;
  end;

  if not TryStrToInt(lBibText, lBib) then
  begin
    SmartTimingTools.ShowDialog(Format(cMessagesManualPassingBibInvalid, [lBibText]),
      '', [tcbOk], tcbOk);
    EditBIB.SetFocus;
    Exit;
  end;

  if not TryAddPassingForBib(lBib) then
    Exit;

  SetTime(Now);
  EditBIB.Clear;
  EditBIB.SetFocus;
end;

{==============================================================================}
function TFormManuallyAddPassing.TryAddPassingForBib(ABib: Integer): Boolean;
var
  lPassing: TPassing;
  lRaceId: Integer;
  lCompetitorId: Integer;
  lName, lTeam, lClass, lChipId: string;
begin
  Result := False;
  lRaceId := GetSelectedRaceId;
  if lRaceId < 0 then
  begin
    SmartTimingTools.ShowDialog(cMessagesManualPassingNoActiveRace, '', [tcbOk], tcbOk);
    Exit;
  end;

  if not MainDataModule.TryGetCompetitorInRaceByBib(lRaceId, ABib, lCompetitorId,
       lName, lTeam, lClass, lChipId) then
  begin
    SmartTimingTools.ShowDialog(Format(cMessagesManualPassingBibNotInRace, [ABib]),
      '', [tcbOk], tcbOk);
    Exit;
  end;

  if Trim(lChipId) = '' then
  begin
    if lName = '' then
      lName := ABib.ToString;
    SmartTimingTools.ShowDialog(Format(cMessagesManualPassingNoChip, [ABib, lName]),
      '', [tcbOk], tcbOk);
    Exit;
  end;

  lPassing.PassingNumber := 0; (* overwritten in AddManualPassing: synthetic negative id *)
  lPassing.ChipId := lChipId;
  lPassing.PassingTime := GetTime + Trunc(Now);
  lPassing.SignalStrength := 100;
  lPassing.Hits := 90;
  lPassing.Flags := 0;
  lPassing.Sport := sSportsIdCycling;
  lPassing.DecoderId := 'MANUAL';
  lPassing.RaceId := lRaceId;
  GSmartTimingController.AddManualPassing(lPassing);
  Result := True;
end;

{==============================================================================}
function TFormManuallyAddPassing.GetTime: TDatetime;
var
  lFormatSettings: TFormatSettings;
begin
  lFormatSettings.TimeSeparator := ':';
  lFormatSettings.DecimalSeparator := '.';
  lFormatSettings.LongTimeFormat := 'HH:mm:ss.zzz';
  Result := StrToTime(EditTime.Text, lFormatSettings);
end;

{==============================================================================}
procedure TFormManuallyAddPassing.ListViewCompetitorsClick(Sender: TObject);
begin
  if ListViewCompetitors.Selected = nil then
    Exit;
  FUpdatingUI := True;
  try
    EditBIB.Text := ListViewCompetitors.Selected.Caption;
  finally
    FUpdatingUI := False;
  end;
  UpdatePreview;
end;

{==============================================================================}
procedure TFormManuallyAddPassing.ListViewCompetitorsDblClick(Sender: TObject);
var
  lBib: Integer;
begin
  if ListViewCompetitors.Selected = nil then
    Exit;
  if not TryStrToInt(ListViewCompetitors.Selected.Caption, lBib) then
    Exit;
  FUpdatingUI := True;
  try
    EditBIB.Text := ListViewCompetitors.Selected.Caption;
  finally
    FUpdatingUI := False;
  end;
  if TryAddPassingForBib(lBib) then
  begin
    SetTime(Now);
    UpdatePreview;
  end;
end;

end.
