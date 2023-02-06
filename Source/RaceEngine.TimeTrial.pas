unit RaceEngine.TimeTrial;

interface

uses
  Controls, ComCtrls, SysUtils, Types, UITypes, Graphics,
  SmartTiming.Consts, DecoderInterface, SmartTiming.Tools,
  RaceEngine.Custom;

type
  TTimeTrialRaceEngine = class(TCustomRaceEngine)
  public
    constructor Create(AParent: TWinControl; ARaceItem: TRaceItem); override;

    procedure AddPassingToDisplay(APassing: TPassing); override;
    procedure ClearAllPassings; override;
  end;

  TTeamTimeTrialRaceEngine = class(TTimeTrialRaceEngine)
  end;

implementation

{==============================================================================}
constructor TTimeTrialRaceEngine.Create(AParent: TWinControl; ARaceItem: TRaceItem);
begin
  inherited Create(AParent, ARaceItem);

  FAvailableRaceStates := [rsNotStarted, rsWarmUp, rsStarted, rsStopped];

  FSQLDataSetRankings.CommandText :=
    'SELECT ROW_NUMBER() OVER (PARTITION BY C.CLASS ORDER BY C.CLASS, P.RANKINGTIME IS NULL, P.RANKINGTIME, P.STARTTIME) AS RANKING, '+
    'C.CLASS, C.BIB, C.LASTNAME || '', '' || C.FIRSTNAME NAME, C.TEAM, C.CLUB, P.RANKINGTIME, P.FINISHTIME, P.STARTTIME, P.DNS, P.DNF, P.DSQ, P.PENALTIES, P.PARTICIPATIONID ' +
    'FROM COMPETITORS C INNER JOIN PARTICIPATION P ON C.COMPETITORID = P.COMPETITORID ' +
    'WHERE RACEID = ' + ARaceItem.Id.ToString + ' ' +
    'ORDER BY C.CLASS, P.RANKINGTIME IS NULL, P.RANKINGTIME, P.STARTTIME';
end;

{==============================================================================}
procedure TTimeTrialRaceEngine.AddPassingToDisplay(APassing: TPassing);
var
  lListItem: TListItem;
begin
  lListItem := TListView(FPassingDisplay).Items.Add;
  if (APassing.Flags and 2) = 2 then
  begin
    lListItem.Caption := '';
    lListItem.SubItems.Add(SmartTimingTools.GetFlagNameFromRaceStatus(TRaceStatus(-APassing.TxId)));
    lListItem.SubItems.Add(FormatDateTime('hh:mm:ss.zzz', APassing.PassingTime));
    lListItem.SubItems.Add('');
    lListItem.SubItems.Add('');
    lListItem.Data := Pointer(-APassing.TxId);
    Exit;
  end;

  lListItem.Caption := '<BIP>';  // TODO
  lListItem.SubItems.Add('<LASTNAME, FIRSTNAME>');
  lListItem.SubItems.Add(FormatDateTime('hh:mm:ss.zzz', APassing.PassingTime));
  lListItem.SubItems.Add(APassing.TxId.ToString);
  lListItem.SubItems.Add(APassing.ChipId);
  TListView(FPassingDisplay).Refresh;
end;

{==============================================================================}
procedure TTimeTrialRaceEngine.ClearAllPassings;
begin
  TListView(FPassingDisplay).Clear;
end;

end.
