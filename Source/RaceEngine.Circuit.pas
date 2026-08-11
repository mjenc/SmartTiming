unit RaceEngine.Circuit;

{==============================================================================
  Plan 1 — Rundstrecke.

  Scoring:
  - All classes share the same target lap count (RACES.LAPS).
  - Race start time is the green-flag SYSTEM marker (rsStarted / F5), not RACES/
    COMPETITOR/PARTICIPATION.STARTTIME (those are ITT/TTT only). Set once per race;
    flag times (except Warm-Up) may be moved via menu or drag&drop if the operator
    was late — place the start flag before the first rider who crossed the loop
    after the gun. Warm-Up stays fixed because it activates capture.
  - When the first rider in the race reaches that count, scoring stops for
    everyone after that finish time (race closed).
  - Ranking prefers more laps (lapped riders behind), then finish time.
  - One overall ranking for the race. Class results (_BYCLASS) only filter that
    order by CLASS and renumber places — no separate scoring per class.
==============================================================================}

interface

uses
  SmartTiming.Tools,
  Classes, Controls, ComCtrls, SysUtils, Types, UITypes, Graphics, Windows, Variants,
  Winapi.Messages, Forms, DB, Data.SqlExpr, DateUtils, Generics.Collections,
  SmartTiming.Consts, DecoderInterface, SmartTiming.Cache,
  RaceEngine.Custom, DataModule, SmartTiming.Event, SmartTiming.Controller;

type
  TCircuitRaceEngine = class(TCustomRaceEngine)
  private
    FRankingGridFormatInitialized: boolean;
    FSQLGroupingString: string;
    FSQLSortingString: string;
  protected
    function TryGetGreenFlagStartTime(out AStartTime: TDateTime): Boolean;
    procedure UpdateParticipationTable(ACurrentPassingId: integer); override;
    procedure AfterOpenRankingResultSet(ADataSet: TDataSet); override;
    procedure SetRankingGroupedByClass(AValue: boolean); override;
    procedure OnPassingItemCompare(ASender: TObject; AItem1, AItem2: TListItem;
      AData: Integer; var ACompare: Integer); override;
    function GetPassingDisplay: TWinControl; override;
    procedure AssignLap(var APassing: TPassing); override;
    procedure AppendPassingListItem(const APassing: TPassing; AAutoScroll: Boolean); override;
  public
    constructor Create(AParent: TWinControl; AEvent: TEventDataObject;
      ARaceItem: TRaceItem); override;
    destructor Destroy; override;

    procedure AddPassingToDisplay(APassing: TPassing; AAutoScroll: boolean); override;
    procedure ClearAllPassings; override;
    procedure ReassignLapsForRace; override;

    procedure ExportParticipantsToExcelTemplate(const AOutputFile: string); override;
    procedure ExportResultsToExcelTemplate(const AOutputFile: string;
      AGroupByClass: boolean); override;
    procedure PrintResults(AGroupByClass: boolean); override;
  end;

implementation

uses
  SmartTiming.GridFormatProvider, System.Generics.Defaults,
  SmartTiming.TransponderAssignment, Vcl.Dialogs;

{==============================================================================}
constructor TCircuitRaceEngine.Create(AParent: TWinControl; AEvent: TEventDataObject;
  ARaceItem: TRaceItem);
begin
  FRankingSQLFormat :=
    'SELECT CURRENTRANKING, CLASS, BIB, NAME, TEAM, LAPS, RANKINGTIME, GAP, ' +
    'FINISHTIME, STARTTIME, DNS, DNF, DSQ, PENALTIES, PARTICIPATIONID, COMPETITORID ' +
    'FROM RANKING_CIRCUIT%1:s ' +
    'WHERE RACEID = %0:s %3:s ' +
    'ORDER BY %2:s DNS, DNF, DSQ, LAPS DESC, FINISHTIME IS NULL, FINISHTIME, BIB';
  FResultSQLFormat :=
    'SELECT CURRENTRANKING, CLASS, BIB, NAME, TEAM, UCIID, LAPS, RANKINGTIME, GAP, ' +
    'DNS, DNF, DSQ ' +
    'FROM RANKING_CIRCUIT%1:s ' +
    'WHERE RACEID = %0:s ' +
    'ORDER BY %2:s DNS, DNF, DSQ, LAPS DESC, FINISHTIME IS NULL, FINISHTIME, BIB';

  FRankingSQLClassGrouping := '_BYCLASS';
  FRankingSQLClassSorting := 'CLASS,';
  FFormatSuffix := '.Circuit';
  FResultsJsonFieldTitles :=
    'Platz,Klasse,Nr,Name,Team,Runden,Wertungszeit,Diff,Zielzeit,Startzeit,DNS,DNF,DSQ,Strafen';
  FDefaultListFormatRanking :=
    '{"columns":[' +
    '{"Alignment":0,"Fieldname":"CLASS","Visible":true,"Width":100,"Title":"Klasse","Index":0},' +
    '{"Alignment":0,"Fieldname":"Column0","Visible":true,"Width":30,"Title":"Platz","Index":1,"Alignment":2},' +
    '{"Alignment":1,"Fieldname":"BIB","Visible":true,"Width":35,"Title":"Start#","Index":2,"Alignment":2},' +
    '{"Alignment":0,"Fieldname":"Column3","Visible":true,"Width":130,"Title":"Name","Index":3,"Alignment":0},' +
    '{"Alignment":0,"Fieldname":"Column4","Visible":true,"Width":130,"Title":"Team","Index":4,"Alignment":0},' +
    '{"Alignment":2,"Fieldname":"LAPS","Visible":true,"Width":50,"Title":"Runden","Index":5,"Alignment":2},' +
    '{"Alignment":0,"Fieldname":"RANKINGTIME","Visible":true,"Width":100,"Title":"Wertungszeit","Index":6,"Alignment":2},' +
    '{"Alignment":0,"Fieldname":"Column6","Visible":true,"Width":64,"Title":"Diff","Index":7,"Alignment":2},' +
    '{"Alignment":0,"Fieldname":"FINISHTIME","Visible":true,"Width":100,"Title":"Zielzeit","Index":8,"Alignment":2},' +
    '{"Alignment":1,"Fieldname":"STARTTIME","Visible":false,"Width":-1,"Title":"Startzeit","Index":9,"Alignment":2},' +
    '{"Alignment":1,"Fieldname":"DNS","Visible":true,"Width":30,"Index":10},' +
    '{"Alignment":1,"Fieldname":"DNF","Visible":true,"Width":30,"Index":11},' +
    '{"Alignment":1,"Fieldname":"DSQ","Visible":true,"Width":30,"Index":12},' +
    '{"Alignment":1,"Fieldname":"PENALTIES","Visible":false,"Width":-1,"Title":"Strafen","Index":13,"Alignment":0},' +
    '{"Alignment":1,"Fieldname":"PARTICIPATIONID","Visible":false,"Width":-1,"Index":14},' +
    '{"Alignment":1,"Fieldname":"COMPETITORID","Visible":false,"Width":-1,"Index":15}]}';

  inherited Create(AParent, AEvent, ARaceItem);
  (* Custom default already allows all race states. *)

  FRankingQuery := GetRankingSQL(False);
  FSQLDataSetRankings.CommandText := FRankingQuery;
  FRankingGridFormatInitialized := False;
end;

{==============================================================================}
destructor TCircuitRaceEngine.Destroy;
begin
  try
    TGridFormatProvider.SaveSettings(FRankingGrid, FFormatSuffix);
  finally
    inherited Destroy;
  end;
end;

{==============================================================================}
function TCircuitRaceEngine.TryGetGreenFlagStartTime(out AStartTime: TDateTime): Boolean;
var
  lList: TList<TPassing>;
  lPassing: TPassing;
  i: Integer;
begin
  Result := False;
  AStartTime := 0;
  lList := TList<TPassing>.Create;
  try
    TPassingStore.GetSingleton.FillPassingsForRace(FRaceItem.Id, lList);
    for i := 0 to lList.Count - 1 do
    begin
      lPassing := lList[i];
      if not lPassing.IsSystemMarker then
        Continue;
      if lPassing.Hits <> cSystemHitsStarted then
        Continue;
      if (not Result) or (CompareDateTime(lPassing.PassingTime, AStartTime) < 0) then
      begin
        AStartTime := lPassing.PassingTime;
        Result := True;
      end;
    end;
  finally
    FreeAndNil(lList);
  end;
  if Result then
    AStartTime := Frac(AStartTime);
end;

{==============================================================================}
procedure TCircuitRaceEngine.AfterOpenRankingResultSet(ADataSet: TDataSet);
begin
  if (FRankingGrid = nil) or FRankingGridFormatInitialized then
    Exit;
  if ADataSet.Fields.Count <= 1 then
    Exit;
  FRankingGridFormatInitialized :=
    TGridFormatProvider.LoadSettings(FRankingGrid, FDefaultListFormatRanking, FFormatSuffix);
end;

{==============================================================================}
procedure TCircuitRaceEngine.SetRankingGroupedByClass(AValue: boolean);
begin
  if AValue = FRankingGroupedByClass then
    Exit;

  if AValue then
  begin
    FSQLGroupingString := FRankingSQLClassGrouping;
    FSQLSortingString := FRankingSQLClassSorting;
  end
  else
  begin
    FSQLGroupingString := '';
    FSQLSortingString := '';
  end;

  FRankingQuery := GetRankingSQL(AValue);
  FRankingGridFormatInitialized := False;
  inherited SetRankingGroupedByClass(AValue);
end;

{==============================================================================}
procedure TCircuitRaceEngine.AddPassingToDisplay(APassing: TPassing; AAutoScroll: boolean);
begin
  if not APassing.IsSystemMarker then
  begin
    AssignLap(APassing);
    TPassingStore.GetSingleton.UpdatePassingDomainFields(
      APassing.PassingNumber, APassing.LapIndex, APassing.CompetitorId);
    UpdateParticipationTable(APassing.PassingNumber);
    FLastChangeTimestamp := Now;
  end;

  if not PassingMatchesFilter(APassing) then
    Exit;

  AppendPassingListItem(APassing, AAutoScroll);
end;

{==============================================================================}
procedure TCircuitRaceEngine.AppendPassingListItem(const APassing: TPassing;
  AAutoScroll: Boolean);
var
  lListItem: TListItem;
  lBIB: integer;
  lName: string;
  lTeamClub: string;
begin
  lListItem := TListItem.Create(TListView(PassingDisplay).Items);
  if APassing.IsSystemMarker then
  begin
    lListItem.Caption := '';
    lListItem.SubItems.Add(SmartTimingTools.GetFlagNameFromRaceStatus(TRaceStatus(-APassing.Hits)));
    lListItem.SubItems.Add(FormatDateTime('hh:nn:ss.zzz', APassing.PassingTime));
    lListItem.SubItems.Add('');
    lListItem.SubItems.Add('');
    lListItem.SubItems.Add(APassing.PassingNumber.ToString);
    lListItem.Data := Pointer(-APassing.Hits);
    TListView(FPassingDisplay).Items.AddItem(lListItem);
    lListItem.ImageIndex := -1;
    Exit;
  end;

  MainDataModule.GetCompetitorInfoForPassing(APassing, lBIB, lName, lTeamClub);
  lListItem.Caption := lBIB.ToString;
  lListItem.SubItems.Add(lName);
  lListItem.SubItems.Add(FormatDateTime('hh:nn:ss.zzz', APassing.PassingTime));
  lListItem.SubItems.Add(APassing.TxId.ToString);
  lListItem.SubItems.Add(APassing.ChipId);
  lListItem.SubItems.Add(APassing.PassingNumber.ToString);
  TListView(FPassingDisplay).Items.AddItem(lListItem);
  lListItem.ImageIndex := PassingImageIndex(APassing);
  TListView(FPassingDisplay).Refresh;

  if AAutoScroll then
    lListItem.MakeVisible(False);
end;

{==============================================================================}
procedure TCircuitRaceEngine.AssignLap(var APassing: TPassing);
var
  lList: TList<TPassing>;
  lOther: TPassing;
  lPriorValid: Integer;
  lChipKey: string;
  lCompetitorId: Integer;
  lOrdinal: Integer;
  lGreenFlagStart: TDateTime;
  lHasGreenFlag: Boolean;
  i: Integer;
begin
  APassing.LapIndex := -1;
  if APassing.IsSystemMarker then
    Exit;

  lCompetitorId := APassing.CompetitorId;
  if lCompetitorId < 0 then
  begin
    if TTransponderAssignmentService.TryGetCompetitorForRaceChipAtTime(
         FRaceItem.Id, APassing.ChipId, APassing.PassingTime, lCompetitorId) then
      APassing.CompetitorId := lCompetitorId;
  end;

  if APassing.PassingStatus <> Ord(psValid) then
    Exit;

  lChipKey := NormalizeChipId(APassing.ChipId);
  if lChipKey = '' then
    Exit;

  (* Mass start: only count passings at/after the green flag. *)
  lHasGreenFlag := TryGetGreenFlagStartTime(lGreenFlagStart);
  if lHasGreenFlag and (Frac(APassing.PassingTime) < lGreenFlagStart) then
    Exit;

  lPriorValid := 0;
  lList := TList<TPassing>.Create;
  try
    TPassingStore.GetSingleton.FillPassingsForRace(FRaceItem.Id, lList);
    for i := 0 to lList.Count - 1 do
    begin
      lOther := lList[i];
      if lOther.PassingNumber = APassing.PassingNumber then
        Continue;
      if lOther.IsSystemMarker then
        Continue;
      if lOther.PassingStatus <> Ord(psValid) then
        Continue;
      if NormalizeChipId(lOther.ChipId) <> lChipKey then
        Continue;
      if lHasGreenFlag and (Frac(lOther.PassingTime) < lGreenFlagStart) then
        Continue;
      if CompareDateTime(lOther.PassingTime, APassing.PassingTime) > 0 then
        Continue;
      if (CompareDateTime(lOther.PassingTime, APassing.PassingTime) = 0) and
         (lOther.PassingNumber > APassing.PassingNumber) then
        Continue;
      Inc(lPriorValid);
    end;
  finally
    FreeAndNil(lList);
  end;

  lOrdinal := lPriorValid + 1;
  if FRaceItem.FirstPassingIsLap then
    APassing.LapIndex := lOrdinal
  else
    APassing.LapIndex := lOrdinal - 1;
end;

{==============================================================================}
procedure TCircuitRaceEngine.ReassignLapsForRace;
var
  lList: TList<TPassing>;
  lPassing: TPassing;
  i: Integer;
begin
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
    for i := 0 to lList.Count - 1 do
    begin
      lPassing := lList[i];
      AssignLap(lPassing);
      TPassingStore.GetSingleton.UpdatePassingDomainFields(
        lPassing.PassingNumber, lPassing.LapIndex, lPassing.CompetitorId);
    end;
  finally
    FreeAndNil(lList);
  end;
end;

{==============================================================================}
procedure TCircuitRaceEngine.ClearAllPassings;
begin
  TListView(FPassingDisplay).Clear;
end;

{==============================================================================}
procedure TCircuitRaceEngine.UpdateParticipationTable(ACurrentPassingId: integer);
var
  lPassingList: TDictionary<integer, TPassing>;
  lPassing: TPassing;
  lLaps: integer;
  lParticipationId: integer;
  lFields: TArray<string>;
  lValues: TArray<Variant>;
  lIgnoredStartTime: TDatetime;
  lFinishTime: TDatetime;
  lRankingTime: TDatetime;
  lRaceFinishTime: TDatetime;
  lRaceAlreadyFinished: Boolean;
  lTargetLaps: Integer;
  lGreenFlagStart: TDateTime;
  lHasGreenFlag: Boolean;
  lSorted: TList<TPassing>;
  i: Integer;

  procedure ApplyPassingToParticipation(const APassing: TPassing);
  begin
    if APassing.RaceId < 0 then
      Exit;
    if APassing.RaceId <> FRaceItem.Id then
      Exit;
    if APassing.PassingStatus <> Ord(psValid) then
      Exit;
    if APassing.IsSystemMarker then
      Exit;

    lTargetLaps := FRaceItem.Laps;
    if lTargetLaps <= 0 then
      Exit;

    (* LapIndex from AssignLap is authoritative (avoids stuck LAPS=0 when
       FirstPassingIsLap=false). LapIndex 0 = first approach, not yet a lap. *)
    lLaps := APassing.LapIndex;
    if lLaps <= 0 then
      Exit;

    lRaceAlreadyFinished := MainDataModule.TryGetRaceFinishTimeByTargetLaps(
      FRaceItem.Id, lTargetLaps, lRaceFinishTime);

    MainDataModule.GetNumberOfLapsForParticipant(FRaceItem.Id, APassing.ChipId,
      APassing.PassingTime, lParticipationId, lIgnoredStartTime);
    if lParticipationId < 0 then
      Exit;

    (* After the race leader finished target laps, later passings do not score. *)
    if lRaceAlreadyFinished and (Frac(APassing.PassingTime) > lRaceFinishTime) then
      Exit;

    if lLaps > lTargetLaps then
      lLaps := lTargetLaps;

    if MainDataModule.IsParticipationFinishTimeOverridden(lParticipationId) then
    begin
      SetLength(lFields, 1);
      SetLength(lValues, 1);
      lFields[0] := 'LAPS';
      lValues[0] := lLaps;
      MainDataModule.UpdateParticipationValues(lParticipationId, lFields, lValues);
      Exit;
    end;

    lFinishTime := Frac(APassing.PassingTime);
    SetLength(lFields, 3);
    SetLength(lValues, 3);
    lFields[0] := 'LAPS';
    lValues[0] := lLaps;
    lFields[1] := 'FINISHTIME';
    lValues[1] := FormatDateTime('hh:nn:ss.zzz', lFinishTime);
    lFields[2] := 'RANKINGTIME';
    (* Mass start: green flag (rsStarted SYSTEM marker) is the common start. *)
    if lHasGreenFlag then
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

begin
  lHasGreenFlag := TryGetGreenFlagStartTime(lGreenFlagStart);

  if ACurrentPassingId < 0 then
  begin
    try
      lPassing := TPassingStore.GetSingleton.GetPassing(ACurrentPassingId);
    except
      Exit;
    end;
    ApplyPassingToParticipation(lPassing);
    Exit;
  end;

  if FLastConsideredPassingId >= ACurrentPassingId then
    Exit;

  lPassingList := TDictionary<integer, TPassing>.Create;
  lSorted := TList<TPassing>.Create;
  try
    TPassingStore.GetSingleton.FillPassingListRange(
      FLastConsideredPassingId + 1, ACurrentPassingId, lPassingList);
    for lPassing in lPassingList.Values do
      lSorted.Add(lPassing);
    lSorted.Sort(
      TComparer<TPassing>.Construct(
        function(const Left, Right: TPassing): Integer
        begin
          Result := CompareDateTime(Left.PassingTime, Right.PassingTime);
          if Result = 0 then
            Result := Left.PassingNumber - Right.PassingNumber;
        end));
    for i := 0 to lSorted.Count - 1 do
      ApplyPassingToParticipation(lSorted[i]);
    FLastConsideredPassingId := ACurrentPassingId;
  finally
    FreeAndNil(lSorted);
    FreeAndNil(lPassingList);
  end;
end;

{==============================================================================}
procedure TCircuitRaceEngine.ExportParticipantsToExcelTemplate(const AOutputFile: string);
begin
  SmartTimingTools.ShowDialog(cMessagesRaceEngineSkeletonExport, '', [tcbOk], tcbOk);
end;

{==============================================================================}
procedure TCircuitRaceEngine.ExportResultsToExcelTemplate(const AOutputFile: string;
  AGroupByClass: boolean);
begin
  SmartTimingTools.ShowDialog(cMessagesRaceEngineSkeletonExport, '', [tcbOk], tcbOk);
end;

{==============================================================================}
procedure TCircuitRaceEngine.PrintResults(AGroupByClass: boolean);
begin
  SmartTimingTools.ShowDialog(cMessagesRaceEngineSkeletonExport, '', [tcbOk], tcbOk);
end;

{==============================================================================}
function TCircuitRaceEngine.GetPassingDisplay: TWinControl;
begin
  Result := inherited GetPassingDisplay;
end;

{==============================================================================}
procedure TCircuitRaceEngine.OnPassingItemCompare(ASender: TObject;
  AItem1, AItem2: TListItem; AData: Integer; var ACompare: Integer);
begin
  ACompare := AnsiCompareText(AItem1.SubItems[cPassingItemSubItemIdxTime],
    AItem2.SubItems[cPassingItemSubItemIdxTime]);
end;

end.
