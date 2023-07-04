unit RaceEngine.TimeTrial;

interface

uses
  Controls, ComCtrls, SysUtils, Types, UITypes, Graphics, Windows,
  Winapi.Messages, Forms, DB, Data.SqlExpr, DateUtils, Generics.Collections,
  SmartTiming.Consts, DecoderInterface, SmartTiming.Tools, SmartTiming.Cache,
  RaceEngine.Custom, DataModule, SmartTiming.Event, SmartTiming.Controller;

type
  TTimeTrialRaceEngine = class(TCustomRaceEngine)
  protected
    procedure UpdateParticipationTable(ACurrentPassingId: integer); override;

  public
    constructor Create(AParent: TWinControl; AEvent: TEventDataObject; ARaceItem: TRaceItem); override;

    procedure AddPassingToDisplay(APassing: TPassing; AAutoScroll: boolean); override;
    procedure ClearAllPassings; override;

    procedure ExportParticipantsToExcelTemplate(const AOutputFile: string); override;
    procedure ExportResultsToExcelTemplate(const AOutputFile: string); override;
  end;

  TTeamTimeTrialRaceEngine = class(TTimeTrialRaceEngine)
  end;

implementation

uses
  Report.ExcelTemplateFiller;

{==============================================================================}
constructor TTimeTrialRaceEngine.Create(AParent: TWinControl; AEvent: TEventDataObject; ARaceItem: TRaceItem);
begin
  inherited Create(AParent, AEvent, ARaceItem);

  FAvailableRaceStates := [rsNotStarted, rsWarmUp, rsStarted, rsStopped];

  FSQLDataSetRankings.CommandText :=
    'SELECT ROW_NUMBER() OVER (PARTITION BY C.CLASS ORDER BY C.CLASS, P.RANKINGTIME IS NULL, P.RANKINGTIME, P.STARTTIME) AS RANKING, '+
    'C.CLASS, C.BIB, C.LASTNAME || '', '' || C.FIRSTNAME NAME, C.TEAM, C.CLUB, P.RANKINGTIME, P.FINISHTIME, P.STARTTIME, P.DNS, P.DNF, P.DSQ, P.PENALTIES, P.PARTICIPATIONID ' +
    'FROM COMPETITORS C INNER JOIN PARTICIPATION P ON C.COMPETITORID = P.COMPETITORID ' +
    'WHERE RACEID = ' + ARaceItem.Id.ToString + ' ' +
    'ORDER BY C.CLASS, P.RANKINGTIME IS NULL, P.RANKINGTIME, P.STARTTIME';
end;

{==============================================================================}
procedure TTimeTrialRaceEngine.AddPassingToDisplay(APassing: TPassing; AAutoScroll: boolean);
var
  lListItem: TListItem;
  lBIB: integer;
  lName: string;
  lTeamClub: string;
begin
  lListItem := TListView(PassingDisplay).Items.Add;
  if (APassing.Flags and 2) = 2 then
  begin
    lListItem.Caption := '';
    lListItem.SubItems.Add(SmartTimingTools.GetFlagNameFromRaceStatus(TRaceStatus(-APassing.Hits)));
    lListItem.SubItems.Add(FormatDateTime('hh:mm:ss.zzz', APassing.PassingTime));
    lListItem.SubItems.Add('');
    lListItem.SubItems.Add('');
    lListItem.Data := Pointer(-APassing.Hits);
    Exit;
  end;

  MainDataModule.GetCompetitorInfoForPassing(APassing, lBIB, lName, lTeamClub);

  lListItem.Caption := lBIB.ToString;
  lListItem.SubItems.Add(lName);
  lListItem.SubItems.Add(FormatDateTime('hh:mm:ss.zzz', APassing.PassingTime));
  lListItem.SubItems.Add(APassing.TxId.ToString);
  lListItem.SubItems.Add(APassing.ChipId);
  TListView(FPassingDisplay).Refresh;

  if AAutoScroll then
    lListItem.MakeVisible(false);

  if MilliSecondsBetween(Now, FLastChangeTimestamp) > cRecalcRankingMilliSeconds then
  begin
    UpdateParticipationTable(APassing.PassingNumber);
    FLastChangeTimestamp := Now;
  end;
end;

{==============================================================================}
procedure TTimeTrialRaceEngine.ClearAllPassings;
begin
  TListView(FPassingDisplay).Clear;
end;

{==============================================================================}
procedure TTimeTrialRaceEngine.UpdateParticipationTable(ACurrentPassingId: integer);
var
  lPassingList: TDictionary<integer, TPassing>;
  lPassing: TPassing;
  lLaps: integer;
  lParticipationId: integer;
  lFields: TArray<string>;
  lValues: TArray<Variant>;
begin
  if FLastConsideredPassingId >= ACurrentPassingId then
    Exit;

  lPassingList := TDictionary<integer, TPassing>.Create;
  try
    TPassingStore.GetSingleton.FillPassingListFrom(FLastConsideredPassingId + 1, lPassingList);

    for lPassing in lPassingList.Values do
    begin
      lLaps := MainDataModule.GetNumberOfLapsForParticipant(FRaceItem.Id, lPassing.ChipId, lParticipationId);
      if lParticipationId < 0 then
        Continue;

      if lLaps + 1 > FRaceItem.Laps then
        Continue;

      Inc(lLaps);

      SetLength(lFields, 2);
      SetLength(lValues, 2);
      lFields[0] := 'LAPS';
      lFields[1] := 'FINISHTIME';
      lValues[0] := lLaps;
      lValues[1] := lPassing.PassingTime;
      MainDataModule.UpdateParticipantValues(lParticipationId, lFields, lValues);
    end;
    FLastConsideredPassingId := ACurrentPassingId;
  finally
    FreeAndNil(lPassingList);
  end;
end;

{==============================================================================}
procedure TTimeTrialRaceEngine.ExportParticipantsToExcelTemplate(const AOutputFile: string);
begin
  inherited;
end;

{==============================================================================}
procedure TTimeTrialRaceEngine.ExportResultsToExcelTemplate(const AOutputFile: string);
begin

end;


end.
