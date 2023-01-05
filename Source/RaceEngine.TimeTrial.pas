unit RaceEngine.TimeTrial;

interface

uses
  Controls, ComCtrls, SysUtils,
  SmartTiming.Consts, SmartTiming.DecoderInterface,
  RaceEngine.Custom;

type
  TTimeTrialRaceEngine = class(TCustomRaceEngine)
  private
    procedure AddColumnToDisplay(const ACaption: string);

  protected
    function GetPassingDisplay: TWinControl; override;

  public
    constructor Create(AParent: TWinControl; ARaceItem: TRaceItem); override;

    procedure AddPassingToDisplay(APassing: TMyLapsP3Passing); override;
    procedure ClearAllPassings; override;
  end;

  TTeamTimeTrialRaceEngine = class(TTimeTrialRaceEngine)
  end;

implementation

{==============================================================================}
constructor TTimeTrialRaceEngine.Create(AParent: TWinControl; ARaceItem: TRaceItem);
begin
  inherited Create(AParent, ARaceItem);
  FSQLDataSetRankings.CommandText :=
    'SELECT ROW_NUMBER () OVER (PARTITION BY C.CLASS ORDER BY C.CLASS, P.RANKINGTIME IS NULL, P.RANKINGTIME, P.STARTTIME) RANKING, '+
    'C.CLASS, C.BIB, C.LASTNAME || '', '' || C.FIRSTNAME, C.TEAM, C.CLUB, P.RANKINGTIME, P.FINISHTIME, P.STARTTIME, P.DNS, P.DNF, P.DSQ, P.PENALTIES, P.PARTICIPATIONIID ' +
    'FROM COMPETITORS C INNER JOIN PARTICIPATION P ON C.COMPETITORID = P.COMPETITORID ' +
    'WHERE RACEID = ' + ARaceItem.Id.ToString + ' ' +
    'ORDER BY C.CLASS, P.RANKINGTIME IS NULL, P.RANKINGTIME, P.STARTTIME';
end;

{==============================================================================}
function TTimeTrialRaceEngine.GetPassingDisplay: TWinControl;
begin
  if FPassingDisplay <> nil then
    Exit(FPassingDisplay);

  FPassingDisplay := TListView.CreateParented(FParent.Handle);
  FPassingDisplay.Visible := false;
  FPassingDisplay.Align := alNone;

  TListView(FPassingDisplay).ViewStyle := vsReport;

  AddColumnToDisplay(cFieldTitleBib);
  AddColumnToDisplay(cFieldTitleLastName + ', ' + cFieldTitleFirstName);
  AddColumnToDisplay(cFieldTitlePassingTime);
  AddColumnToDisplay(cFieldTitleTransponder);
  AddColumnToDisplay(cFieldTitleChipID);

  result := FPassingDisplay;
end;

{==============================================================================}
procedure TTimeTrialRaceEngine.AddColumnToDisplay(const ACaption: string);
var
  lColumn: TListColumn;
begin
  lColumn := TListView(FPassingDisplay).Columns.Add;
  lColumn.Caption := ACaption;
  lColumn.AutoSize := true;
end;

{==============================================================================}
procedure TTimeTrialRaceEngine.AddPassingToDisplay(APassing: TMyLapsP3Passing);
var
  lListItem: TListItem;
begin
  lListItem := TListView(FPassingDisplay).Items.Add;
  lListItem.Caption := '<BIP>';  // TODO
  lListItem.SubItems.Add('<LASTNAME, FIRSTNAME>');
  lListItem.SubItems.Add(FormatDateTime('hh:mm:ss.zzz', APassing.PassingTime));
  lListItem.SubItems.Add(APassing.TransponderShortId.ToString);
  lListItem.SubItems.Add(APassing.ChipId);
end;

{==============================================================================}
procedure TTimeTrialRaceEngine.ClearAllPassings;
begin
  TListView(FPassingDisplay).Clear;
end;

end.
