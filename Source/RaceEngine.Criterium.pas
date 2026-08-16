unit RaceEngine.Criterium;

{==============================================================================
  Plan 1 — Kriterium (WB Straße § 11.2.3).

  Laps
  - Organizer sets a fixed race distance (RACES.LAPS), e.g. 30.
  - Winner = most laps completed; equal laps → points decide.
  - Rundengewinn is triggered only by Flagge Neue Spitze (rsNewLeader): the
    current Spitzengruppe (max laps, and only if someone is behind) becomes
    holdouts. They are not finished at Soll — the Hauptfeld rides the full
    advertised distance; gainers end with Soll+N (e.g. 31).
  - Verlustrunde: individuals / small groups who fall back and are lapped end
    with fewer laps (e.g. 29), same idea as Circuit — physical crossings when
    the Hauptfeld completes Soll; no artificial cap at Soll for anyone.
  - Lap counting: after the Hauptfeld (non-holdout peak) first reaches
    TargetLaps, a Ziel-Flagge is placed automatically 1ms before that
    crossing (still movable). The operator may also wave finish early.
    Remaining riders with fewer than TargetLaps still score one closing
    crossing, then stop. Holdouts already at/above Target keep Soll+N and
    are not incremented again.

  Points
  - Flagge Punkte (rsPointsSprint): next up to four peak passings get 5/3/2/1.
  - Schlussrunde: double if at flag time field peak >= TargetLaps-1.
  - Peak = max laps among non-holdouts. Holdouts score again only after the
    field catches their lap count.
  - CRITRANKINGVALUE = last points time (later award ranks ahead on ties).
  - One overall ranking; points are race-wide. Class results (_BYCLASS) filter
    that order by CLASS and renumber places — no new points per class.

  Start: mass start = green flag (same as Circuit).
==============================================================================}

interface

uses
  Classes, Controls, SysUtils, Variants, DateUtils, Generics.Collections,
  SmartTiming.Consts, DecoderInterface, SmartTiming.Cache, SmartTiming.Event,
  RaceEngine.Custom, RaceEngine.Circuit, DataModule;

type
  TCriteriumRaceEngine = class(TCircuitRaceEngine)
  private
    procedure ApplyCriteriumScoring;
    function IsPointsSprintMarker(const APassing: TPassing): Boolean;
    function IsNewLeaderMarker(const APassing: TPassing): Boolean;
    function IsStartMarker(const APassing: TPassing): Boolean;
    function IsBreakMarker(const APassing: TPassing): Boolean;
    function IsFinishMarker(const APassing: TPassing): Boolean;
  protected
    function SupportsNewLeaderFlag: Boolean; override;
    function SupportsPointsSprintFlag: Boolean; override;
    function CanAutoPlaceFinishFlagOnPassing(const APassing: TPassing): Boolean; override;
    procedure UpdateParticipationTable(ACurrentPassingId: integer); override;
  public
    constructor Create(AParent: TWinControl; AEvent: TEventDataObject;
      ARaceItem: TRaceItem); override;
    procedure AddPassingToDisplay(APassing: TPassing; AAutoScroll: boolean); override;
    procedure RecalcCountingLaps; override;
    procedure ReassignLapsForRace; override;
  end;

implementation

uses
  SmartTiming.TransponderAssignment, System.Generics.Defaults, Data.DBXCommon;

const
  cSprintPoints: array[0..3] of Integer = (5, 3, 2, 1);

{==============================================================================}
constructor TCriteriumRaceEngine.Create(AParent: TWinControl; AEvent: TEventDataObject;
  ARaceItem: TRaceItem);
begin
  inherited Create(AParent, AEvent, ARaceItem);

  FRankingSQLFormat :=
    'SELECT CURRENTRANKING, CLASS, BIB, NAME, TEAM, LAPS, POINTS, GAP, ' +
    'FINISHTIME, STARTTIME, DNS, DNF, DSQ, PENALTIES, PARTICIPATIONID, COMPETITORID ' +
    'FROM RANKING_CRITERIUM%1:s ' +
    'WHERE RACEID = %0:s %3:s ' +
    'ORDER BY %2:s DNS, DNF, DSQ, LAPS DESC, POINTS DESC, CRITRANKINGVALUE DESC, BIB';
  FResultSQLFormat :=
    'SELECT CURRENTRANKING, CLASS, BIB, NAME, TEAM, UCIID, LAPS, POINTS, GAP, ' +
    'DNS, DNF, DSQ ' +
    'FROM RANKING_CRITERIUM%1:s ' +
    'WHERE RACEID = %0:s ' +
    'ORDER BY %2:s DNS, DNF, DSQ, LAPS DESC, POINTS DESC, CRITRANKINGVALUE DESC, BIB';

  FRankingSQLClassGrouping := '_BYCLASS';
  FRankingSQLClassSorting := 'CLASS,';
  FFormatSuffix := '.Criterium';
  FResultsJsonFieldTitles :=
    'Platz,Klasse,Nr,Name,Team,Runden,Punkte,Diff,Zielzeit,Startzeit,DNS,DNF,DSQ,Strafen';
  FDefaultListFormatRanking :=
    '{"columns":[' +
    '{"Alignment":0,"Fieldname":"CLASS","Visible":true,"Width":100,"Title":"Klasse","Index":0},' +
    '{"Alignment":0,"Fieldname":"Column0","Visible":true,"Width":30,"Title":"Platz","Index":1,"Alignment":2},' +
    '{"Alignment":1,"Fieldname":"BIB","Visible":true,"Width":35,"Title":"Start#","Index":2,"Alignment":2},' +
    '{"Alignment":0,"Fieldname":"Column3","Visible":true,"Width":130,"Title":"Name","Index":3,"Alignment":0},' +
    '{"Alignment":0,"Fieldname":"Column4","Visible":true,"Width":130,"Title":"Team","Index":4,"Alignment":0},' +
    '{"Alignment":2,"Fieldname":"LAPS","Visible":true,"Width":50,"Title":"Runden","Index":5,"Alignment":2},' +
    '{"Alignment":2,"Fieldname":"POINTS","Visible":true,"Width":50,"Title":"Punkte","Index":6,"Alignment":2},' +
    '{"Alignment":0,"Fieldname":"Column6","Visible":true,"Width":64,"Title":"Diff","Index":7,"Alignment":2},' +
    '{"Alignment":0,"Fieldname":"FINISHTIME","Visible":true,"Width":100,"Title":"Zielzeit","Index":8,"Alignment":2},' +
    '{"Alignment":1,"Fieldname":"STARTTIME","Visible":false,"Width":-1,"Title":"Startzeit","Index":9,"Alignment":2},' +
    '{"Alignment":1,"Fieldname":"DNS","Visible":true,"Width":30,"Index":10},' +
    '{"Alignment":1,"Fieldname":"DNF","Visible":true,"Width":30,"Index":11},' +
    '{"Alignment":1,"Fieldname":"DSQ","Visible":true,"Width":30,"Index":12},' +
    '{"Alignment":1,"Fieldname":"PENALTIES","Visible":false,"Width":-1,"Title":"Strafen","Index":13,"Alignment":0},' +
    '{"Alignment":1,"Fieldname":"PARTICIPATIONID","Visible":false,"Width":-1,"Index":14},' +
    '{"Alignment":1,"Fieldname":"COMPETITORID","Visible":false,"Width":-1,"Index":15}]}';

  FRankingQuery := GetRankingSQL(False);
  FSQLDataSetRankings.CommandText := FRankingQuery;
end;

{==============================================================================}
function TCriteriumRaceEngine.SupportsNewLeaderFlag: Boolean;
begin
  Result := True;
end;

{==============================================================================}
function TCriteriumRaceEngine.SupportsPointsSprintFlag: Boolean;
begin
  Result := True;
end;

{==============================================================================}
function TCriteriumRaceEngine.CanAutoPlaceFinishFlagOnPassing(
  const APassing: TPassing): Boolean;
begin
  (* Holdouts can reach TargetLaps before the Hauptfeld; auto-finish is
     triggered from ApplyCriteriumScoring when the field peak hits Soll. *)
  Result := False;
end;

{==============================================================================}
function TCriteriumRaceEngine.IsStartMarker(const APassing: TPassing): Boolean;
begin
  Result := APassing.IsSystemMarker and (APassing.Hits = cSystemHitsStarted);
end;

{==============================================================================}
function TCriteriumRaceEngine.IsBreakMarker(const APassing: TPassing): Boolean;
begin
  Result := APassing.IsSystemMarker and
    ((APassing.Hits = cSystemHitsNotStarted) or
     (APassing.Hits = cSystemHitsNeutralized) or
     (APassing.Hits = cSystemHitsStopped));
end;

{==============================================================================}
function TCriteriumRaceEngine.IsFinishMarker(const APassing: TPassing): Boolean;
begin
  Result := APassing.IsSystemMarker and (APassing.Hits = cSystemHitsFinished);
end;

{==============================================================================}
function TCriteriumRaceEngine.IsNewLeaderMarker(const APassing: TPassing): Boolean;
begin
  Result := APassing.IsSystemMarker and (APassing.Hits = cSystemHitsNewLeader);
end;

{==============================================================================}
function TCriteriumRaceEngine.IsPointsSprintMarker(const APassing: TPassing): Boolean;
begin
  Result := APassing.IsSystemMarker and (APassing.Hits = cSystemHitsPointsSprint);
end;

{==============================================================================}
procedure TCriteriumRaceEngine.ApplyCriteriumScoring;
var
  lList: TList<TPassing>;
  lPassing: TPassing;
  lLapsByCompetitor: TDictionary<Integer, Integer>;
  lFinishByCompetitor: TDictionary<Integer, TDateTime>;
  lPointsByCompetitor: TDictionary<Integer, Integer>;
  lLastPointsTime: TDictionary<Integer, string>;
  lHoldouts: TDictionary<Integer, Boolean>;
  lAwardedThisSprint: TDictionary<Integer, Boolean>;
  lClosingDone: TDictionary<Integer, Boolean>;
  lInActive: Boolean;
  lSprintArmed: Boolean;
  lSprintDouble: Boolean;
  lFieldDistanceDone: Boolean;
  lHadFinishFlag: Boolean;
  lAutoFinishLeaderTime: TDateTime;
  lSlotsLeft: Integer;
  lCompetitorId: Integer;
  lLaps: Integer;
  lPeakLap: Integer;
  lHoldoutLap: Integer;
  lTargetLaps: Integer;
  lParticipationId: Integer;
  lFields: TArray<string>;
  lValues: TArray<Variant>;
  lPair: TPair<Integer, Integer>;
  lAward: Integer;
  lGreenFlagStart: TDateTime;
  lHasGreenFlag: Boolean;
  lFinishTime: TDateTime;
  lRankingTime: TDateTime;
  i: Integer;

  function MaxEligiblePeakLap: Integer;
  var
    lId, lLap: Integer;
  begin
    Result := -1;
    for lId in lLapsByCompetitor.Keys do
    begin
      if lHoldouts.ContainsKey(lId) then
        Continue;
      lLap := lLapsByCompetitor[lId];
      if lLap > Result then
        Result := lLap;
    end;
  end;

  procedure ClearHoldoutsCaughtByField;
  var
    lIds: TArray<Integer>;
    lId: Integer;
    lFieldPeak: Integer;
  begin
    lFieldPeak := MaxEligiblePeakLap;
    if lFieldPeak < 0 then
      Exit;
    lIds := lHoldouts.Keys.ToArray;
    for lId in lIds do
    begin
      if lLapsByCompetitor.TryGetValue(lId, lHoldoutLap) and
         (lFieldPeak >= lHoldoutLap) then
        lHoldouts.Remove(lId);
    end;
  end;

  procedure MarkCurrentPeakAsHoldouts;
  var
    lId, lLap, lMax: Integer;
    lHasFieldBehind: Boolean;
  begin
    lMax := -1;
    for lLap in lLapsByCompetitor.Values do
      if lLap > lMax then
        lMax := lLap;
    if lMax < 0 then
      Exit;
    (* Rundengewinn only when Spitze is ahead of the field. If everyone shares
       the same lap count, Neue Spitze must not hold out the entire peloton. *)
    lHasFieldBehind := False;
    for lLap in lLapsByCompetitor.Values do
      if lLap < lMax then
      begin
        lHasFieldBehind := True;
        Break;
      end;
    if not lHasFieldBehind then
      Exit;
    for lId in lLapsByCompetitor.Keys do
      if lLapsByCompetitor[lId] = lMax then
        lHoldouts.AddOrSetValue(lId, True);
  end;

begin
  lTargetLaps := FRaceItem.Laps;
  if lTargetLaps <= 0 then
    Exit;

  lHasGreenFlag := TryGetGreenFlagStartTime(lGreenFlagStart);
  lList := TList<TPassing>.Create;
  lLapsByCompetitor := TDictionary<Integer, Integer>.Create;
  lFinishByCompetitor := TDictionary<Integer, TDateTime>.Create;
  lPointsByCompetitor := TDictionary<Integer, Integer>.Create;
  lLastPointsTime := TDictionary<Integer, string>.Create;
  lHoldouts := TDictionary<Integer, Boolean>.Create;
  lAwardedThisSprint := TDictionary<Integer, Boolean>.Create;
  lClosingDone := TDictionary<Integer, Boolean>.Create;
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

    lInActive := False;
    lSprintArmed := False;
    lSprintDouble := False;
    lFieldDistanceDone := False;
    lHadFinishFlag := False;
    lAutoFinishLeaderTime := 0;
    lSlotsLeft := 0;

    for i := 0 to lList.Count - 1 do
    begin
      lPassing := lList[i];

      if IsStartMarker(lPassing) then
      begin
        lInActive := True;
        Continue;
      end;
      if IsFinishMarker(lPassing) then
      begin
        (* Early Ziel (rain) or checkered: start closing, keep scoring one more. *)
        lHadFinishFlag := True;
        if lInActive then
          lFieldDistanceDone := True;
        Continue;
      end;
      if IsBreakMarker(lPassing) then
      begin
        lInActive := False;
        lSprintArmed := False;
        Continue;
      end;
      if IsNewLeaderMarker(lPassing) then
      begin
        if lInActive then
          MarkCurrentPeakAsHoldouts;
        Continue;
      end;
      if IsPointsSprintMarker(lPassing) then
      begin
        if not lInActive then
          Continue;
        ClearHoldoutsCaughtByField;
        lPeakLap := MaxEligiblePeakLap;
        lSprintArmed := True;
        lSlotsLeft := Length(cSprintPoints);
        lAwardedThisSprint.Clear;
        (* Schlussrunde: main field already on last advertised lap. *)
        lSprintDouble := lPeakLap >= lTargetLaps - 1;
        Continue;
      end;

      if not lInActive then
        Continue;
      if lPassing.IsSystemMarker then
        Continue;
      if lPassing.PassingStatus <> Ord(psValid) then
        Continue;

      if not TTransponderAssignmentService.TryGetCompetitorForRaceChipAtTime(
           FRaceItem.Id, lPassing.ChipId, lPassing.PassingTime, lCompetitorId) then
        Continue;

      (* After Hauptfeld completes TargetLaps: one closing crossing for riders
         still below Soll, then freeze. Leader/holdouts already at/above Soll
         do not get another lap. *)
      if lFieldDistanceDone then
      begin
        if lClosingDone.ContainsKey(lCompetitorId) then
          Continue;
        if lLapsByCompetitor.TryGetValue(lCompetitorId, lLaps) and
           (lLaps >= lTargetLaps) then
          Continue;
      end;

      if not lLapsByCompetitor.TryGetValue(lCompetitorId, lLaps) then
      begin
        (* First crossing: count only when FirstPassingIsLap is set. *)
        if FRaceItem.FirstPassingIsLap then
          lLaps := 1
        else
          lLaps := 0;
      end
      else
        Inc(lLaps);
      (* WB: do not cap at TargetLaps — lap-gainers may finish with Target+N. *)
      lLapsByCompetitor.AddOrSetValue(lCompetitorId, lLaps);
      lFinishByCompetitor.AddOrSetValue(lCompetitorId, Frac(lPassing.PassingTime));
      if lFieldDistanceDone then
        lClosingDone.AddOrSetValue(lCompetitorId, True);

      ClearHoldoutsCaughtByField;
      if MaxEligiblePeakLap >= lTargetLaps then
      begin
        if not lFieldDistanceDone then
          lAutoFinishLeaderTime := lPassing.PassingTime;
        lFieldDistanceDone := True;
        lClosingDone.AddOrSetValue(lCompetitorId, True);
      end;

      if not lSprintArmed or (lSlotsLeft <= 0) then
        Continue;
      if lHoldouts.ContainsKey(lCompetitorId) then
        Continue;
      if lAwardedThisSprint.ContainsKey(lCompetitorId) then
        Continue;

      lPeakLap := MaxEligiblePeakLap;
      if (lPeakLap < 0) or (lLaps <> lPeakLap) then
        Continue;

      lAward := cSprintPoints[Length(cSprintPoints) - lSlotsLeft];
      if lSprintDouble then
        lAward := lAward * 2;

      if not lPointsByCompetitor.ContainsKey(lCompetitorId) then
        lPointsByCompetitor.AddOrSetValue(lCompetitorId, 0);
      lPointsByCompetitor[lCompetitorId] := lPointsByCompetitor[lCompetitorId] + lAward;
      lLastPointsTime.AddOrSetValue(lCompetitorId,
        FormatDateTime('yyyymmddhhnnsszzz', lPassing.PassingTime));
      lAwardedThisSprint.AddOrSetValue(lCompetitorId, True);

      Dec(lSlotsLeft);
      if lSlotsLeft <= 0 then
        lSprintArmed := False;
    end;

    MainDataModule.SQLConnection.ExecuteDirect(
      'UPDATE PARTICIPATION SET POINTS = 0, CRITRANKINGVALUE = NULL WHERE RACEID = ' +
      FRaceItem.Id.ToString);

    for lPair in lLapsByCompetitor do
    begin
      if not MainDataModule.TryGetParticipationId(FRaceItem.Id, lPair.Key, lParticipationId) then
        Continue;

      if MainDataModule.IsParticipationFinishTimeOverridden(lParticipationId) then
      begin
        SetLength(lFields, 1);
        SetLength(lValues, 1);
        lFields[0] := 'LAPS';
        lValues[0] := lPair.Value;
        MainDataModule.UpdateParticipationValues(lParticipationId, lFields, lValues);
      end
      else
      begin
        lFinishTime := 0;
        lFinishByCompetitor.TryGetValue(lPair.Key, lFinishTime);
        SetLength(lFields, 3);
        SetLength(lValues, 3);
        lFields[0] := 'LAPS';
        lValues[0] := lPair.Value;
        lFields[1] := 'FINISHTIME';
        if lFinishTime > 0 then
          lValues[1] := FormatDateTime('hh:nn:ss.zzz', lFinishTime)
        else
          lValues[1] := Null;
        lFields[2] := 'RANKINGTIME';
        if lHasGreenFlag and (lFinishTime > 0) then
        begin
          lRankingTime := lFinishTime - lGreenFlagStart;
          if lRankingTime < 0 then
            lRankingTime := lRankingTime + 1;
          lValues[2] := FormatDateTime('hh:nn:ss.zzz', lRankingTime);
        end
        else
          lValues[2] := Null;
        MainDataModule.UpdateParticipationValues(lParticipationId, lFields, lValues);
      end;

      if lPointsByCompetitor.ContainsKey(lPair.Key) then
      begin
        SetLength(lFields, 2);
        SetLength(lValues, 2);
        lFields[0] := 'POINTS';
        lFields[1] := 'CRITRANKINGVALUE';
        lValues[0] := lPointsByCompetitor[lPair.Key];
        if lLastPointsTime.ContainsKey(lPair.Key) then
          lValues[1] := lLastPointsTime[lPair.Key]
        else
          lValues[1] := Null;
        MainDataModule.UpdateParticipationValues(lParticipationId, lFields, lValues);
      end;
    end;

    (* After LAPS are persisted — avoids ranking refresh while still at 0. *)
    if (lAutoFinishLeaderTime > 0) and not lHadFinishFlag then
      PlaceAutoFinishFlagAt(lAutoFinishLeaderTime);
  finally
    FreeAndNil(lClosingDone);
    FreeAndNil(lAwardedThisSprint);
    FreeAndNil(lHoldouts);
    FreeAndNil(lLastPointsTime);
    FreeAndNil(lPointsByCompetitor);
    FreeAndNil(lFinishByCompetitor);
    FreeAndNil(lLapsByCompetitor);
    FreeAndNil(lList);
  end;
end;

{==============================================================================}
procedure TCriteriumRaceEngine.UpdateParticipationTable(ACurrentPassingId: integer);
begin
  (* One full replay per live update (not per Recalc step — see RecalcCountingLaps). *)
  if ACurrentPassingId >= 0 then
  begin
    if FLastConsideredPassingId >= ACurrentPassingId then
      Exit;
    FLastConsideredPassingId := ACurrentPassingId;
  end;
  ApplyCriteriumScoring;
end;

{==============================================================================}
procedure TCriteriumRaceEngine.RecalcCountingLaps;
var
  lTransaction: TDBXTransaction;
  lList: TList<TPassing>;
  lPassing: TPassing;
  i: Integer;
  lMaxDecoderId: Integer;
begin
  lTransaction := MainDataModule.SQLConnection.BeginTransaction;
  try
    MainDataModule.ResetRaceParticitipations(FRaceItem.Id);
    FLastConsideredPassingId := 0;
    ApplyCriteriumScoring;
    ReassignLapsForRace;

    (* Advance cursor past decoder passings so live scoring does not re-walk them. *)
    lMaxDecoderId := 0;
    lList := TList<TPassing>.Create;
    try
      TPassingStore.GetSingleton.FillPassingsForRace(FRaceItem.Id, lList);
      for i := 0 to lList.Count - 1 do
      begin
        lPassing := lList[i];
        if (lPassing.PassingNumber > lMaxDecoderId) and (lPassing.PassingNumber >= 0) then
          lMaxDecoderId := lPassing.PassingNumber;
      end;
    finally
      FreeAndNil(lList);
    end;
    FLastConsideredPassingId := lMaxDecoderId;

    MainDataModule.SQLConnection.CommitFreeAndNil(lTransaction);
  except
    MainDataModule.SQLConnection.RollbackFreeAndNil(lTransaction);
    raise;
  end;
  if FAutoFinishJustPlaced then
  begin
    FAutoFinishJustPlaced := False;
    RebuildProtocolDisplay;
  end;
  FLastChangeTimestamp := Now;
  RefreshRankingDisplay;
end;

{==============================================================================}
procedure TCriteriumRaceEngine.AddPassingToDisplay(APassing: TPassing; AAutoScroll: boolean);
begin
  inherited;
  if IsPointsSprintMarker(APassing) or IsNewLeaderMarker(APassing) or
     IsFinishMarker(APassing) then
    ApplyCriteriumScoring;
end;

{==============================================================================}
procedure TCriteriumRaceEngine.ReassignLapsForRace;
begin
  (* Protocol LapIndex only — scoring is ApplyCriteriumScoring via Recalc /
     UpdateParticipationTable / flag AddPassingToDisplay. *)
  inherited;
end;

end.
