unit FormUnassignedPassings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, System.DateUtils,
  System.Generics.Collections, System.Generics.Defaults,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, DecoderInterface;

type
  TFormUnassignedPassings = class(TForm)
    PanelTop: TPanel;
    ButtonAssign: TButton;
    ButtonDelete: TButton;
    ButtonClose: TButton;
    ButtonRefresh: TButton;
    ListViewPassings: TListView;
    LabelHint: TLabel;
    procedure FormShow(Sender: TObject);
    procedure ButtonRefreshClick(Sender: TObject);
    procedure ButtonCloseClick(Sender: TObject);
    procedure ButtonDeleteClick(Sender: TObject);
    procedure ButtonAssignClick(Sender: TObject);
    procedure ListViewPassingsDblClick(Sender: TObject);
  private
    procedure ReloadList;
    function GetSelectedPassing: TPassing;
    function HasSelection: Boolean;
    procedure AssignSelected;
  end;

implementation

{$R *.dfm}

uses
  SmartTiming.Cache, SmartTiming.Consts, SmartTiming.Tools, SmartTiming.Controller,
  SmartTiming.TransponderAssignment, FormAssignCompetitorToTransponder, FormMain,
  DataModule;

{==============================================================================}
procedure TFormUnassignedPassings.FormShow(Sender: TObject);
begin
  ReloadList;
end;

{==============================================================================}
procedure TFormUnassignedPassings.ReloadList;
var
  lList: TList<TPassing>;
  lPassing: TPassing;
  lItem: TListItem;
  i: Integer;
begin
  ListViewPassings.Items.BeginUpdate;
  try
    ListViewPassings.Items.Clear;
    lList := TList<TPassing>.Create;
    try
      TUnassignedPassingStore.GetSingleton.FillList(lList);
      lList.Sort(
        TComparer<TPassing>.Construct(
          function(const Left, Right: TPassing): Integer
          begin
            Result := CompareDateTime(Left.PassingTime, Right.PassingTime);
            if Result = 0 then
              Result := Left.PassingNumber - Right.PassingNumber;
          end));
      for i := 0 to lList.Count - 1 do
      begin
        lPassing := lList[i];
        lItem := ListViewPassings.Items.Add;
        lItem.Caption := lPassing.ChipId;
        lItem.SubItems.Add(FormatDateTime('hh:nn:ss.zzz', lPassing.PassingTime));
        lItem.SubItems.Add(lPassing.SignalStrength.ToString);
        lItem.SubItems.Add(lPassing.PassingNumber.ToString);
        lItem.Data := Pointer(lPassing.PassingNumber);
      end;
    finally
      FreeAndNil(lList);
    end;
  finally
    ListViewPassings.Items.EndUpdate;
  end;
  Caption := Format('Nicht zugeordnete Transponder (%d)',
    [TUnassignedPassingStore.GetSingleton.Count]);
end;

{==============================================================================}
function TFormUnassignedPassings.HasSelection: Boolean;
begin
  Result := ListViewPassings.Selected <> nil;
end;

{==============================================================================}
function TFormUnassignedPassings.GetSelectedPassing: TPassing;
var
  lPassingNumber: Integer;
begin
  if not HasSelection then
    raise Exception.Create('No unassigned passing selected');
  lPassingNumber := Integer(ListViewPassings.Selected.Data);
  Result := TPassingStore.GetSingleton.GetPassing(lPassingNumber);
end;

{==============================================================================}
procedure TFormUnassignedPassings.ButtonRefreshClick(Sender: TObject);
begin
  ReloadList;
end;

{==============================================================================}
procedure TFormUnassignedPassings.ButtonCloseClick(Sender: TObject);
begin
  Close;
end;

{==============================================================================}
procedure TFormUnassignedPassings.ButtonDeleteClick(Sender: TObject);
var
  lPassing: TPassing;
begin
  if not HasSelection then
    Exit;
  lPassing := GetSelectedPassing;
  if SmartTimingTools.ShowDialog(
       Format(cMessagesPassingDeleteConfirm, [lPassing.ChipId]), '',
       [tcbYes, tcbNo], tcbNo) <> mrYes then
    Exit;
  GSmartTimingController.RemovePassing(lPassing.PassingNumber);
  ReloadList;
end;

{==============================================================================}
procedure TFormUnassignedPassings.AssignSelected;
var
  lPassing: TPassing;
  lRaceId: Integer;
  lCompetitorId: Integer;
  lResult: TAssignmentOperationResult;
begin
  if not HasSelection then
    Exit;

  lRaceId := GFormMain.GetSelectedRaceId;
  if lRaceId < 0 then
  begin
    SmartTimingTools.ShowDialog(cMessagesNoRaceSelectedForAssign, '', [tcbOk], tcbOk);
    Exit;
  end;

  lPassing := GetSelectedPassing;
  if not TFormAssignCompetitor.Execute(Self, lRaceId, lCompetitorId) then
    Exit;

  if not TTransponderAssignmentService.Assign(lRaceId, lCompetitorId, lPassing.ChipId, lResult) then
  begin
    SmartTimingTools.ShowDialog(lResult.Message, '', [tcbOk], tcbOk);
    Exit;
  end;

  MainDataModule.UpdatePassingRaceIdInDatabase(lPassing.PassingNumber, lRaceId);
  TPassingStore.GetSingleton.UpdatePassingRaceId(lPassing.PassingNumber, lRaceId);
  TUnassignedPassingStore.GetSingleton.RemovePassing(lPassing.PassingNumber);
  lPassing.RaceId := lRaceId;
  GFormMain.AddPassingForRaceId(lRaceId, lPassing);
  ReloadList;
end;

{==============================================================================}
procedure TFormUnassignedPassings.ButtonAssignClick(Sender: TObject);
begin
  AssignSelected;
end;

{==============================================================================}
procedure TFormUnassignedPassings.ListViewPassingsDblClick(Sender: TObject);
begin
  AssignSelected;
end;

end.
