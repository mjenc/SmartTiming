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

  public
    constructor Create(AParent: TWinControl; AEvent: TEventDataObject; ARaceItem: TRaceItem); override;
    destructor Destroy; override;

    procedure AddPassingToDisplay(APassing: TPassing; AAutoScroll: boolean); override;
    procedure ClearAllPassings; override;

    procedure ExportParticipantsToExcelTemplate(const AOutputFile: string); override;
    procedure ExportResultsToExcelTemplate(const AOutputFile: string; AGroupByClass: boolean); override;
    procedure PrintResults(AGroupByClass: boolean); override;
  end;

  TTeamTimeTrialRaceEngine = class(TTimeTrialRaceEngine)
  end;

implementation

uses
  Report.ExcelTemplateFiller, SmartTiming.GridFormatProvider;

{==============================================================================}
constructor TTimeTrialRaceEngine.Create(AParent: TWinControl; AEvent: TEventDataObject; ARaceItem: TRaceItem);
begin
  FRankingSQLFormat :=
    'SELECT CURRENTRANKING, CLASS, BIB, NAME, TEAM, RANKINGTIME, GAP, ' +
    'FINISHTIME, STARTTIME, DNS, DNF, DSQ, PENALTIES, PARTICIPATIONID, COMPETITORID ' +
    'FROM RANKING_TIMETRIAL%1:s ' +
    'WHERE RACEID = %0:s ' +
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

  FAvailableRaceStates := [rsNotStarted, rsWarmUp, rsStarted, rsStopped];

  FRankingQuery := Format(FRankingSQLFormat, [ARaceItem.Id.ToString, '', '']);
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

  FRankingQuery := Format(FRankingSQLFormat, [FRaceItem.Id.ToString, FSQLGroupingString, FSQLSortingString]);
  FRankingGridFormatInitialized := false;
  inherited SetRankingGroupedByClass(AValue);
end;
{==============================================================================}
procedure TTimeTrialRaceEngine.AddPassingToDisplay(APassing: TPassing; AAutoScroll: boolean);
var
  lListItem: TListItem;
  lBIB: integer;
  lName: string;
  lTeamClub: string;
begin
  lListItem := TListItem.Create(TListView(PassingDisplay).Items);
  if (APassing.Flags and 2) = 2 then
  begin
    lListItem.Caption := '';
    lListItem.SubItems.Add(SmartTimingTools.GetFlagNameFromRaceStatus(TRaceStatus(-APassing.Hits)));
    lListItem.SubItems.Add(FormatDateTime('hh:mm:ss.zzz', APassing.PassingTime));
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
  lListItem.SubItems.Add(FormatDateTime('hh:mm:ss.zzz', APassing.PassingTime));
  lListItem.SubItems.Add(APassing.TxId.ToString);
  lListItem.SubItems.Add(APassing.ChipId);
  lListItem.SubItems.Add(APassing.PassingNumber.ToString);
  TListView(FPassingDisplay).Items.AddItem(lListItem);
  if APassing.Flags = 1 then
    lListItem.ImageIndex := 3
  else
    lListItem.ImageIndex := 0;
  TListView(FPassingDisplay).Refresh;

  if AAutoScroll then
    lListItem.MakeVisible(false);

  UpdateParticipationTable(APassing.PassingNumber);
//  if MilliSecondsBetween(Now, FLastChangeTimestamp) > cRecalcRankingMilliSeconds then
  begin
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
  lStartTime: TDatetime;
  lFinishTime: TDatetime;
  lRankingTime: TDatetime;
begin
  if FLastConsideredPassingId >= ACurrentPassingId then
    Exit;

  lPassingList := TDictionary<integer, TPassing>.Create;
  try
    TPassingStore.GetSingleton.FillPassingListFrom(FLastConsideredPassingId + 1, lPassingList);

    for lPassing in lPassingList.Values do
    begin
      lLaps := MainDataModule.GetNumberOfLapsForParticipant(FRaceItem.Id, lPassing.ChipId, lParticipationId, lStartTime);
      if lParticipationId < 0 then
        Continue;

      if lLaps + 1 > FRaceItem.Laps then
        Continue;

      if (lLaps > 0) or (lLaps = 0) and FRaceItem.FirstPassingIsLap then
        Inc(lLaps);

      lFinishTime := Frac(lPassing.PassingTime);
      SetLength(lFields, 3);
      SetLength(lValues, 3);
      lFields[0] := 'LAPS';
      lValues[0] := lLaps;
      lFields[1] := 'FINISHTIME';
      lValues[1] :=  FormatDatetime('hh:mm:ss.zzz', lFinishTime);
      lFields[2] := 'RANKINGTIME';
      if lLaps = FRaceItem.Laps then
      begin
        lStartTime := Frac(lStartTime);
        lRankingTime := lFinishTime - lStartTime;
        lValues[2] := FormatDatetime('hh:mm:ss.zzz', lRankingTime);
      end
      else
        lValues[2] := null;

      MainDataModule.UpdateParticipationValues(lParticipationId, lFields, lValues);
    end;
    FLastConsideredPassingId := ACurrentPassingId;
  finally
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
  lGroupByClassString: string;
begin
  lExcelFiller := TExcelFiller.Create(GSmartTimingController.Event, FRaceItem.Title);
  try
    lExcelFiller.TemplateFile := gStdTemplatePath + 'ResultListTT.xlsx';
    lExcelFiller.OnGetFieldValue := OnGetResultFieldValue;
    lResultSet := nil;
    if AGroupByClass then
      lGroupByClassString := FRankingSQLClassGrouping
    else
      lGroupByClassString := '';
    MainDataModule.FillReadOnlyDataSetForSQL(
      Format(FResultSQLFormat, [FRaceItem.Id.ToString, lGroupByClassString]),
      lResultSet);

    lExcelFiller.FillDataRowsAndPrint(lResultSet, FRankingGroupedByClass);
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
  lGroupByClassString: string;
  lSQLSortingString: string;
  lSQL: string;
begin
  lExcelFiller := TExcelFiller.Create(GSmartTimingController.Event, FRaceItem.Title);
  try
    lExcelFiller.TemplateFile := gStdTemplatePath + 'ResultListTT.xlsx';
    lExcelFiller.OnGetFieldValue := OnGetResultFieldValue;
    lResultSet := nil;
    if AGroupByClass then
    begin
      lGroupByClassString := FRankingSQLClassGrouping;
      lSQLSortingString := FSQLSortingString;
    end
    else
    begin
      lGroupByClassString := '';
      lSQLSortingString := '';
    end;
    lSQL := Format(FResultSQLFormat, [FRaceItem.Id.ToString, lGroupByClassString, lSQLSortingString]);
    MainDataModule.FillReadOnlyDataSetForSQL(lSQL, lResultSet);

    lExcelFiller.FillDataRowsAndSave(gStdDataPath + Format('Results-%s.xlsx', [FRaceItem.Title]),
                                     lResultSet,
                                     FRankingGroupedByClass);
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
