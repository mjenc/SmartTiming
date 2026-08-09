unit FormWarmUpChipConflicts;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, SmartTiming.TransponderAssignment;

type
  TFormWarmUpChipConflicts = class(TForm)
    PanelTop: TPanel;
    LabelHint: TLabel;
    ListViewConflicts: TListView;
    PanelButtons: TPanel;
    ButtonContinue: TButton;
    ButtonCancel: TButton;
  private
    procedure LoadConflicts(const AConflicts: TArray<TAssignmentConflict>);
  public
    (* True = proceed to Warm-Up (no conflicts or operator continues). *)
    class function ConfirmProceed(AOwner: TComponent; ARaceId: Integer): Boolean; static;
  end;

implementation

{$R *.dfm}

uses
  SmartTiming.Consts, SmartTiming.Tools;

{==============================================================================}
class function TFormWarmUpChipConflicts.ConfirmProceed(AOwner: TComponent;
  ARaceId: Integer): Boolean;
var
  lConflicts: TArray<TAssignmentConflict>;
  lForm: TFormWarmUpChipConflicts;
begin
  TTransponderAssignmentService.EnsureAssignmentsFromCompetitorChips(ARaceId);
  lConflicts := TTransponderAssignmentService.FindConflictsAgainstOtherActiveRaces(ARaceId);
  if Length(lConflicts) = 0 then
    Exit(True);

  lForm := TFormWarmUpChipConflicts.Create(AOwner);
  try
    lForm.LoadConflicts(lConflicts);
    Result := lForm.ShowModal = mrYes;
  finally
    FreeAndNil(lForm);
  end;
end;

{==============================================================================}
procedure TFormWarmUpChipConflicts.LoadConflicts(
  const AConflicts: TArray<TAssignmentConflict>);
var
  i: Integer;
  lItem: TListItem;
  lConflict: TAssignmentConflict;
begin
  Caption := cMessagesWarmUpChipConflictsTitle;
  LabelHint.Caption := cMessagesWarmUpChipConflictsHint;
  ButtonContinue.Caption := cMessagesWarmUpChipConflictsContinue;
  ButtonCancel.Caption := cMessagesWarmUpChipConflictsCancel;

  ListViewConflicts.Items.BeginUpdate;
  try
    ListViewConflicts.Items.Clear;
    for i := 0 to High(AConflicts) do
    begin
      lConflict := AConflicts[i];
      lItem := ListViewConflicts.Items.Add;
      lItem.Caption := lConflict.ChipId;
      lItem.SubItems.Add(lConflict.LocalCompetitorDisplayName);
      lItem.SubItems.Add(lConflict.RaceTitle);
      lItem.SubItems.Add(lConflict.CompetitorDisplayName);
      lItem.SubItems.Add(SmartTimingTools.GetRaceStatusStringFromEnum(lConflict.RaceStatus));
    end;
  finally
    ListViewConflicts.Items.EndUpdate;
  end;
end;

end.
