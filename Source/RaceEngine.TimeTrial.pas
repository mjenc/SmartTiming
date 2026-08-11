unit RaceEngine.TimeTrial;

interface

uses
  SmartTiming.Tools,
  Classes, Controls, ComCtrls, SysUtils, Types, UITypes, Graphics, Windows, Variants,
  Winapi.Messages, Forms, DB, Data.SqlExpr, DateUtils, Generics.Collections,
  SmartTiming.Consts, DecoderInterface, SmartTiming.Cache,
  RaceEngine.Custom, DataModule, SmartTiming.Event, SmartTiming.Controller;

type
  TTimeTrialRaceEngine = class(TCustomRaceEngine)
  private
    FRankingGridFormatInitialized: boolean;
    FSQLGroupingString: string;
    FSQLSortingString: string;
  protected
    procedure UpdateParticipationTable(ACurrentPassingId: integer); override;
    procedure AfterOpenRankingResultSet(ADataSet: TDataSet); override;
    procedure SetRankingGroupedByClass(AValue: boolean); override;
    procedure OnGetResultFieldValue(ACol: Integer; ADataSet: TDataSet; var AValue: string);
    procedure OnPassingItemCompare(ASender: TObject; AItem1, AItem2: TListItem; AData: Integer; var ACompare: Integer); override;
    function GetPassingDisplay: TWinControl; override;
    procedure AssignLap(var APassing: TPassing); override;
    procedure AppendPassingListItem(const APassing: TPassing; AAutoScroll: Boolean); override;

  public
    constructor Create(AParent: TWinControl; AEvent: TEventDataObject; ARaceItem: TRaceItem); override;
    destructor Destroy; override;

    procedure AddPassingToDisplay(APassing: TPassing; AAutoScroll: boolean); override;
    procedure ClearAllPassings; override;
    procedure ReassignLapsForRace; override;

    procedure ExportParticipantsToExcelTemplate(const AOutputFile: string); override;
    procedure ExportResultsToExcelTemplate(const AOutputFile: string; AGroupByClass: boolean); override;
    procedure PrintResults(AGroupByClass: boolean); override;
  end;

implementation

uses
  Report.ExcelTemplateFiller, SmartTiming.GridFormatProvider,
  System.Generics.Defaults, SmartTiming.TransponderAssignment;

{==============================================================================}
constructor TTimeTrialRaceEngine.Create(AParent: TWinControl; AEvent: TEventDataObject; ARaceItem: TRaceItem);
begin
  FRankingSQLFormat :=
    'SELECT CURRENTRANKING, CLASS, BIB, NAME, TEAM, RANKINGTIME, GAP, ' +
    'FINISHTIME, STARTTIME, DNS, DNF, DSQ, PENALTIES, PARTICIPATIONID, COMPETITORID ' +
    'FROM RANKING_TIMETRIAL%1:s ' +
    'WHERE RACEID = %0:s %3:s ' +
    'ORDER BY %2:s DNS, DNF, DSQ, RANKINGTIME IS NULL, LAPS DESC, RANKINGTIME, STARTTIME';
  FResultSQLFormat :=
    'SELECT CURRENTRANKING, CLASS, BIB, NAME, TEAM, UCIID, RANKINGTIME, GAP, ' +
    'DNS, DNF, DSQ ' +
    'FROM RANKING_TIMETRIAL%1:s ' +
    'WHERE RACEID = %0:s ' +
    'ORDER BY %2:s DNS, DNF, DSQ, RANKINGTIME IS NULL, LAPS DESC, RANKINGTIME, STARTTIME';

  FRankingSQLClassGrouping := '_BYCLASS';
  FRankingSQLClassSorting := 'CLASS,';

  FFormatSuffix := '.TimeTrial';
  FResultsJsonFieldTitles :=
    'Platz,Klasse,Nr,Name,Team,Wertungszeit,Diff,Zielzeit,Startzeit,DNS,DNF,DSQ,Strafen';
  FDefaultListFormatRanking :=
    '{"columns":[' +
    '{"Alignment":0,"Fieldname":"CLASS","Visible":true,"Width":100,"Title":"Klasse","Index":0},' +
    '{"Alignment":0,"Fieldname":"Column0","Visible":true,"Width":30,"Title":"Platz","Index":1,"Alignment":2},' +
    '{"Alignment":1,"Fieldname":"BIB","Visible":true,"Width":35,"Title":"Start#","Index":2,"Alignment":2},' +
    '{"Alignment":0,"Fieldname":"Column3","Visible":true,"Width":130,"Title":"Name","Index":3,"Alignment":0},' +
    '{"Alignment":0,"Fieldname":"Column4","Visible":true,"Width":130,"Title":"Team","Index":4,"Alignment":0},' +
    '{"Alignment":0,"Fieldname":"RANKINGTIME","Visible":true,"Width":100,"Title":"Wertungszeit","Index":5,"Alignment":2},' +
    '{"Alignment":0,"Fieldname":"Column6","Visible":true,"Width":64,"Title":"Diff","Index":6,"Alignment":2},' +
    '{"Alignment":0,"Fieldname":"FINISHTIME","Visible":true,"Width":100,"Title":"Zielzeit","Index":7,"Alignment":2},' +
    '{"Alignment":1,"Fieldname":"STARTTIME","Visible":false,"Width":-1,"Title":"Startzeit","Index":8,"Alignment":2},' +
    '{"Alignment":1,"Fieldname":"DNS","Visible":true,"Width":30,"Index":9},' +
    '{"Alignment":1,"Fieldname":"DNF","Visible":true,"Width":30,"Index":10},' +
    '{"Alignment":1,"Fieldname":"DSQ","Visible":true,"Width":30,"Index":11},' +
    '{"Alignment":1,"Fieldname":"PENALTIES","Visible":false,"Width":-1,"Title":"Strafen","Index":12,"Alignment":0},' +
    '{"Alignment":1,"Fieldname":"PARTICIPATIONID","Visible":false,"Width":-1,"Index":13},' +
    '{"Alignment":1,"Fieldname":"COMPETITORID","Visible":false,"Width":-1,"Index":14}]}';

  inherited Create(AParent, AEvent, ARaceItem);

  FRankingQuery := GetRankingSQL(False);
  FSQLDataSetRankings.CommandText := FRankingQuery;

  FRankingGridFormatInitialized := false;
//  FSQLDataSetRankings.AfterOpen := AfterOpenRankingResultSet;
end;

{==============================================================================}
destructor TTimeTrialRaceEngine.Destroy;
begin
  try
    TGridFormatProvider.SaveSettings(FRankingGrid, FFormatSuffix);
  finally
    inherited Destroy;
  end;
end;

{==============================================================================}
procedure TTimeTrialRaceEngine.AfterOpenRankingResultSet(ADataSet: TDataSet);
begin
   if (FRankingGrid = nil) or FRankingGridFormatInitialized then
    Exit;
  if ADataSet.Fields.Count <= 1 then
    Exit;
  FRankingGridFormatInitialized := TGridFormatProvider.LoadSettings(FRankingGrid, FDefaultListFormatRanking, FFormatSuffix);
end;

{==============================================================================}
procedure TTimeTrialRaceEngine.SetRankingGroupedByClass(AValue: boolean);
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
  FRankingGridFormatInitialized := false;
  inherited SetRankingGroupedByClass(AValue);
end;
{==============================================================================}
procedure TTimeTrialRaceEngine.AddPassingToDisplay(APassing: TPassing; AAutoScroll: boolean);
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
procedure TTimeTrialRaceEngine.AppendPassingListItem(const APassing: TPassing;
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
    lListItem.MakeVisible(false);
end;

{==============================================================================}
procedure TTimeTrialRaceEngine.AssignLap(var APassing: TPassing);
var
  lList: TList<TPassing>;
  lOther: TPassing;
  lPriorValid: Integer;
  lChipKey: string;
  lCompetitorId: Integer;
  lOrdinal: Integer;
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

  lPriorValid := 0;
  lList := TList<TPassing>.Create;
  try
    TPassingStore.GetSingleton.FillPassingsForRace(FRaceItem.Id, lList);
    for i := 0 to lList.Count - 1 do
    begin
      lOther := lList[i];
      if lOther.IsSystemMarker then
        Continue;
      if lOther.PassingStatus <> Ord(psValid) then
        Continue;
      if NormalizeChipId(lOther.ChipId) <> lChipKey then
        Continue;
      if lOther.PassingTime > APassing.PassingTime then
        Continue;
      if (lOther.PassingTime = APassing.PassingTime) and
         (lOther.PassingNumber >= APassing.PassingNumber) then
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
procedure TTimeTrialRaceEngine.ReassignLapsForRace;
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
  lStartTime: TDatetime;
  lFinishTime: TDatetime;
  lRankingTime: TDatetime;
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

    (* LapIndex from AssignLap is authoritative (avoids stuck LAPS=0 when
       FirstPassingIsLap=false). *)
    lLaps := APassing.LapIndex;
    if lLaps <= 0 then
      Exit;

    MainDataModule.GetNumberOfLapsForParticipant(FRaceItem.Id, APassing.ChipId,
      APassing.PassingTime, lParticipationId, lStartTime);
    if lParticipationId < 0 then
      Exit;

    if lLaps > FRaceItem.Laps then
      Exit;

    if MainDataModule.IsParticipationFinishTimeOverridden(lParticipationId) then
    begin
      (* Manual Zielzeit: keep FINISHTIME/RANKINGTIME; still advance laps. *)
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
    lValues[1] := FormatDatetime('hh:nn:ss.zzz', lFinishTime);
    lFields[2] := 'RANKINGTIME';
    if lLaps = FRaceItem.Laps then
    begin
      lStartTime := Frac(lStartTime);
      lRankingTime := lFinishTime - lStartTime;
      lValues[2] := FormatDatetime('hh:nn:ss.zzz', lRankingTime);
    end
    else
      lValues[2] := null;

    MainDataModule.UpdateParticipationValues(lParticipationId, lFields, lValues);
  end;

begin
  (* Synthetic MANUAL numbers are outside the decoder sequence — update this hit only
     without advancing FLastConsideredPassingId (would break live decoder tracking). *)
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
procedure TTimeTrialRaceEngine.ExportParticipantsToExcelTemplate(const AOutputFile: string);
var
  lExcelFiller: TExcelFiller;
  lResultSet: TSQLDataSet;
begin
  lExcelFiller := TExcelFiller.Create(GSmartTimingController.Event, FRaceItem.Title);
  try
    lExcelFiller.TemplateFile := gStdTemplatePath + 'StartListTT.xlsx';

    lResultSet := nil;
    MainDataModule.FillReadOnlyDataSetForSQL(
      'SELECT C.BIB, C.LASTNAME || '', '' || C.FIRSTNAME NAME, C.TEAM, C.CLUB, P.STARTTIME ' +
      'FROM COMPETITORS C INNER JOIN PARTICIPATION P ON C.COMPETITORID = P.COMPETITORID ' +
      'WHERE RACEID = ' + FRaceItem.Id.ToString + ' ' +
      'ORDER BY C.BIB',
      lResultSet);

    lExcelFiller.FillDataRowsAndSave(gStdDataPath + Format('StartList-%s.xlsx', [FRaceItem.Title]),
                                     lResultSet,
                                     FRankingGroupedByClass);
  finally
    FreeAndNil(lExcelFiller);
    FreeAndNil(lResultSet);
  end;
end;

{==============================================================================}
procedure TTimeTrialRaceEngine.PrintResults(AGroupByClass: boolean);
var
  lExcelFiller: TExcelFiller;
  lResultSet: TSQLDataSet;
begin
  lExcelFiller := TExcelFiller.Create(GSmartTimingController.Event, FRaceItem.Title);
  try
    lExcelFiller.TemplateFile := gStdTemplatePath + 'ResultListTT.xlsx';
    lExcelFiller.OnGetFieldValue := OnGetResultFieldValue;
    lExcelFiller.CommuniqueRaceId := FRaceItem.Id;
    lResultSet := nil;
    MainDataModule.FillReadOnlyDataSetForSQL(GetResultSQL(AGroupByClass), lResultSet);

    lExcelFiller.FillDataRowsAndPrint(lResultSet, AGroupByClass);
  finally
    FreeAndNil(lExcelFiller);
    FreeAndNil(lResultSet);
  end;
end;

{==============================================================================}
procedure TTimeTrialRaceEngine.ExportResultsToExcelTemplate(const AOutputFile: string; AGroupByClass: boolean);
var
  lExcelFiller: TExcelFiller;
  lResultSet: TSQLDataSet;
begin
  lExcelFiller := TExcelFiller.Create(GSmartTimingController.Event, FRaceItem.Title);
  try
    lExcelFiller.TemplateFile := gStdTemplatePath + 'ResultListTT.xlsx';
    lExcelFiller.OnGetFieldValue := OnGetResultFieldValue;
    lExcelFiller.CommuniqueRaceId := FRaceItem.Id;
    lResultSet := nil;
    MainDataModule.FillReadOnlyDataSetForSQL(GetResultSQL(AGroupByClass), lResultSet);

    lExcelFiller.FillDataRowsAndSave(gStdDataPath + Format('Results-%s.xlsx', [FRaceItem.Title]),
                                     lResultSet,
                                     AGroupByClass);
  finally
    FreeAndNil(lExcelFiller);
    FreeAndNil(lResultSet);
  end;
end;

{==============================================================================}
procedure TTimeTrialRaceEngine.OnGetResultFieldValue(ACol: Integer; ADataSet: TDataSet; var AValue: string);
var
  lField: TField;
begin
  if ACol <> 0 then
    Exit;
  lField := ADataSet.FieldByName('DNS');
  if (lField <> nil) and (lField.AsInteger <> 0) then
  begin
    AValue := 'DNS';
    Exit;
  end;

  lField := ADataSet.FieldByName('DNF');
  if (lField <> nil) and (lField.AsInteger <> 0) then
  begin
    AValue := 'DNF';
    Exit;
  end;

  lField := ADataSet.FieldByName('DSQ');
  if (lField <> nil) and (lField.AsInteger <> 0) then
  begin
    AValue := 'DSQ';
    Exit;
  end;
end;

{==============================================================================}
function TTimeTrialRaceEngine.GetPassingDisplay: TWinControl;
begin
  result := inherited GetPassingDisplay;
  TListView(FPassingDisplay).SortType := stBoth;
  TListView(FPassingDisplay).OnCompare := OnPassingItemCompare;
end;

{==============================================================================}
procedure TTimeTrialRaceEngine.OnPassingItemCompare(ASender: TObject; AItem1, AItem2: TListItem; AData: Integer; var ACompare: Integer);
begin
  // Sort by passing times
  ACompare := AnsiCompareText(AItem1.SubItems[cPassingItemSubItemIdxTime], AItem2.SubItems[cPassingItemSubItemIdxTime]);
end;

end.
