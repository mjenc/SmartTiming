unit FormCompetitorPassings;

{==============================================================================
  Plan 3 step 3: per-competitor lap protocol (chronological passings + Δt).
==============================================================================}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.DateUtils,
  System.Generics.Collections, System.Generics.Defaults,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, DecoderInterface, SmartTiming.Consts, RaceEngine.Custom;

type
  TFormCompetitorPassings = class(TForm)
    PanelTop: TPanel;
    LabelCompetitor: TLabel;
    ButtonInvalidate: TButton;
    ButtonValidate: TButton;
    ButtonClose: TButton;
    ListViewPassings: TListView;
    procedure FormShow(Sender: TObject);
    procedure ButtonCloseClick(Sender: TObject);
    procedure ButtonInvalidateClick(Sender: TObject);
    procedure ButtonValidateClick(Sender: TObject);
  private
    FRaceItem: TRaceItem;
    FCompetitorId: Integer;
    procedure ReloadList;
    function GetSelectedPassingNumber: Integer;
    procedure SetSelectedStatus(AStatus: TPassingState);
  public
    class function Execute(AOwner: TComponent; ARaceItem: TRaceItem;
      ACompetitorId: Integer): Boolean; static;
  end;

implementation

{$R *.dfm}

uses
  SmartTiming.Cache, SmartTiming.Tools, DataModule, FormMain;

{==============================================================================}
class function TFormCompetitorPassings.Execute(AOwner: TComponent;
  ARaceItem: TRaceItem; ACompetitorId: Integer): Boolean;
var
  lForm: TFormCompetitorPassings;
begin
  Result := False;
  if (ARaceItem = nil) or (ACompetitorId < 0) then
    Exit;

  lForm := TFormCompetitorPassings.Create(AOwner);
  try
    lForm.FRaceItem := ARaceItem;
    lForm.FCompetitorId := ACompetitorId;
    lForm.Caption := Format(cMessagesCompetitorPassingsTitle,
      [MainDataModule.GetCompetitorDisplayName(ACompetitorId)]);
    lForm.ShowModal;
    Result := True;
  finally
    FreeAndNil(lForm);
  end;
end;

{==============================================================================}
procedure TFormCompetitorPassings.FormShow(Sender: TObject);
begin
  LabelCompetitor.Caption := MainDataModule.GetCompetitorDisplayName(FCompetitorId);
  if GFormMain <> nil then
    ListViewPassings.SmallImages := GFormMain.ImageListPassingStates;
  ReloadList;
end;

{==============================================================================}
procedure TFormCompetitorPassings.ReloadList;
var
  lList: TList<TPassing>;
  lPassing: TPassing;
  lItem: TListItem;
  i: Integer;
  lPrevValidTime: TDateTime;
  lLapTime: string;
  lLapLabel: string;
  lDelta: Double;
begin
  ListViewPassings.Items.BeginUpdate;
  try
    ListViewPassings.Items.Clear;
    lList := TList<TPassing>.Create;
    try
      TPassingStore.GetSingleton.FillPassingsForRace(FRaceItem.Id, lList);
      lList.Sort(
        TComparer<TPassing>.Construct(
          function(const Left, Right: TPassing): Integer
          begin
            Result := CompareDateTime(Left.PassingTime, Right.PassingTime);
            if Result = 0 then
              Result := Left.PassingNumber - Right.PassingNumber;
          end));

      lPrevValidTime := 0;
      for i := 0 to lList.Count - 1 do
      begin
        lPassing := lList[i];
        if lPassing.IsSystemMarker then
          Continue;
        if lPassing.CompetitorId <> FCompetitorId then
          Continue;

        lLapTime := '';
        if (lPassing.PassingStatus = Ord(psValid)) and (lPrevValidTime > 0) then
        begin
          lDelta := (lPassing.PassingTime - lPrevValidTime) * SecsPerDay;
          lLapTime := Format('%.3f s', [lDelta]);
        end;

        if lPassing.PassingStatus <> Ord(psValid) then
          lLapLabel := '—'
        else if (not FRaceItem.FirstPassingIsLap) and (lPassing.LapIndex = 0) then
          lLapLabel := cMessagesPassingLapStart
        else if lPassing.LapIndex >= 0 then
          lLapLabel := lPassing.LapIndex.ToString
        else
          lLapLabel := '—';

        lItem := ListViewPassings.Items.Add;
        lItem.Caption := lLapLabel;
        lItem.SubItems.Add(FormatDateTime('hh:nn:ss.zzz', lPassing.PassingTime));
        lItem.SubItems.Add(lLapTime);
        if lPassing.PassingStatus = Ord(psValid) then
          lItem.SubItems.Add(cMessagesPassingStatusValid)
        else
          lItem.SubItems.Add(cMessagesPassingStatusInvalid);
        if lPassing.IsManual then
          lItem.SubItems.Add(cMessagesPassingSourceManual)
        else
          lItem.SubItems.Add(cMessagesPassingSourceDecoder);
        lItem.SubItems.Add(lPassing.ChipId);
        lItem.SubItems.Add(lPassing.PassingNumber.ToString);
        lItem.Data := Pointer(lPassing.PassingNumber);
        if lPassing.PassingStatus <> Ord(psValid) then
          lItem.ImageIndex := cPassingImageInvalid
        else if lPassing.IsManual then
          lItem.ImageIndex := cPassingImageManual
        else
          lItem.ImageIndex := cPassingImageValid;

        if lPassing.PassingStatus = Ord(psValid) then
          lPrevValidTime := lPassing.PassingTime;
      end;
    finally
      FreeAndNil(lList);
    end;
  finally
    ListViewPassings.Items.EndUpdate;
  end;

  if ListViewPassings.Items.Count = 0 then
    LabelCompetitor.Caption := LabelCompetitor.Caption + ' — ' + cMessagesCompetitorPassingsNone;
end;

{==============================================================================}
function TFormCompetitorPassings.GetSelectedPassingNumber: Integer;
begin
  Result := -1;
  if ListViewPassings.Selected = nil then
    Exit;
  Result := Integer(ListViewPassings.Selected.Data);
end;

{==============================================================================}
procedure TFormCompetitorPassings.SetSelectedStatus(AStatus: TPassingState);
var
  lPassingNumber: Integer;
begin
  lPassingNumber := GetSelectedPassingNumber;
  if lPassingNumber < 0 then
    Exit;
  if FRaceItem.RaceEngine = nil then
    Exit;
  FRaceItem.RaceEngine.SetPassingStatusAndRecalc(lPassingNumber, AStatus);
  ReloadList;
end;

{==============================================================================}
procedure TFormCompetitorPassings.ButtonInvalidateClick(Sender: TObject);
begin
  SetSelectedStatus(psInvalid);
end;

{==============================================================================}
procedure TFormCompetitorPassings.ButtonValidateClick(Sender: TObject);
begin
  SetSelectedStatus(psValid);
end;

{==============================================================================}
procedure TFormCompetitorPassings.ButtonCloseClick(Sender: TObject);
begin
  Close;
end;

end.
