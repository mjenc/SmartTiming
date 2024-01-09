unit RaceEngine.TimeTrial;

interface

uses
  Classes, Controls, ComCtrls, SysUtils, Types, UITypes, Graphics, Windows, Variants,
  Winapi.Messages, Forms, DB, Data.SqlExpr, DateUtils, Generics.Collections,
  SmartTiming.Consts, DecoderInterface, SmartTiming.Tools, SmartTiming.Cache,
  RaceEngine.Custom, DataModule, SmartTiming.Event, SmartTiming.Controller;

type
  TTimeTrialRaceEngine = class(TCustomRaceEngine)
  private
    FRankingGridFormatInitialized: boolean;
    FSQLGroupingString: string;

    const
      cRankingSQLFormat =
        'SELECT ROW_NUMBER() OVER (PARTITION BY %1:s 1 ORDER BY %1:s P.RANKINGTIME IS NULL, P.RANKINGTIME, P.STARTTIME) CURRENTRANKING, '+
        'C.CLASS, C.BIB, C.LASTNAME || '', '' || C.FIRSTNAME NAME, IFNULL(C.TEAM, C.CLUB) TEAM, P.RANKINGTIME, ' +
        'STRFTIME(''%%M:%%f'',JULIANDAY(P.RANKINGTIME)- LAG(JULIANDAY(P.RANKINGTIME), 1) ' +
        'OVER (PARTITION BY %1:s 1 ORDER BY %1:s P.LAPS DESC, P.RANKINGTIME IS NULL, P.RANKINGTIME, P.STARTTIME))  GAP, ' +
        'P.FINISHTIME, P.STARTTIME, P.DNS, P.DNF, P.DSQ, P.PENALTIES, P.PARTICIPATIONID ' +
        'FROM COMPETITORS C INNER JOIN PARTICIPATION P ON C.COMPETITORID = P.COMPETITORID ' +
        'WHERE RACEID = %0:s ' +
        'ORDER BY %1:s P.RANKINGTIME IS NULL, P.LAPS DESC, P.RANKINGTIME, P.STARTTIME';
      cRankingSQLClassGrouping = 'C.CLASS,';

      cFormatSuffix = '.TimeTrial';
      cDefaultListFormatRanking =
        '{"columns":[' +
        '{"Alignment":0,"Fieldname":"CLASS","Visible":1,"Width":100,"Title":"Klasse","Index":0},' +
        '{"Alignment":0,"Fieldname":"Column0","Visible":1,"Width":30,"Title":"Platz","Index":1,"Alignment":2},' +
        '{"Alignment":1,"Fieldname":"BIB","Visible":1,"Width":35,"Title":"Start#","Index":2,"Alignment":2},' +
        '{"Alignment":0,"Fieldname":"Column3","Visible":1,"Width":130,"Title":"Name","Index":3,"Alignment":0},' +
        '{"Alignment":0,"Fieldname":"Column4","Visible":1,"Width":130,"Title":"Team","Index":4,"Alignment":0},' +
        '{"Alignment":0,"Fieldname":"RANKINGTIME","Visible":1,"Width":100,"Title":"Wertungszeit","Index":5,"Alignment":2},' +
        '{"Alignment":0,"Fieldname":"Column6","Visible":1,"Width":64,"Title":"Diff","Index":6,"Alignment":2},' +
        '{"Alignment":0,"Fieldname":"FINISHTIME","Visible":1,"Width":100,"Title":"Zielzeit","Index":7,"Alignment":2},' +
        '{"Alignment":1,"Fieldname":"STARTTIME","Visible":0,"Width":-1,"Title":"Startzeit","Index":8,"Alignment":2},' +
        '{"Alignment":1,"Fieldname":"DNS","Visible":1,"Width":30,"Index":9},' +
        '{"Alignment":1,"Fieldname":"DNF","Visible":1,"Width":30,"Index":10},' +
        '{"Alignment":1,"Fieldname":"DSQ","Visible":1,"Width":30,"Index":11},' +
        '{"Alignment":1,"Fieldname":"PENALTIES","Visible":0,"Width":-1,"Title":"Strafen","Index":12,"Alignment":0},' +
        '{"Alignment":1,"Fieldname":"PARTICIPATIONID","Visible":0,"Width":-1,"Index":13}]}';

  protected
    procedure UpdateParticipationTable(ACurrentPassingId: integer); override;
    procedure AfterOpenRankingResultSet(ADataSet: TDataSet); override;
    procedure SetRankingGroupedByClass(AValue: boolean); override;

  public
    constructor Create(AParent: TWinControl; AEvent: TEventDataObject; ARaceItem: TRaceItem); override;
    destructor Destroy; override;

    procedure AddPassingToDisplay(APassing: TPassing; AAutoScroll: boolean); override;
    procedure ClearAllPassings; override;

    procedure ExportParticipantsToExcelTemplate(const AOutputFile: string); override;
    procedure ExportResultsToExcelTemplate(const AOutputFile: string); override;
  end;

  TTeamTimeTrialRaceEngine = class(TTimeTrialRaceEngine)
  end;

implementation

uses
  Report.ExcelTemplateFiller, SmartTiming.GridFormatProvider;

{==============================================================================}
constructor TTimeTrialRaceEngine.Create(AParent: TWinControl; AEvent: TEventDataObject; ARaceItem: TRaceItem);
begin
  inherited Create(AParent, AEvent, ARaceItem);

  FAvailableRaceStates := [rsNotStarted, rsWarmUp, rsStarted, rsStopped];

  FRankingQuery := Format(cRankingSQLFormat, [ARaceItem.Id.ToString, '']);
  FSQLDataSetRankings.CommandText := Format(cRankingSQLFormat, [ARaceItem.Id.ToString, '']);

  FRankingGridFormatInitialized := false;
  FSQLDataSetRankings.AfterOpen := AfterOpenRankingResultSet;
end;

{==============================================================================}
destructor TTimeTrialRaceEngine.Destroy;
begin
  try
    TGridFormatProvider.SaveSettings(FRankingGrid, cFormatSuffix);
  finally
    inherited Destroy;
  end;
end;

{==============================================================================}
procedure TTimeTrialRaceEngine.AfterOpenRankingResultSet(ADataSet: TDataSet);
begin
  if (FRankingGrid = nil) or FRankingGridFormatInitialized then
    Exit;
  if FRankingGrid.Columns.Count <= 1 then
    Exit;
  FRankingGridFormatInitialized := TGridFormatProvider.LoadSettings(FRankingGrid, cDefaultListFormatRanking, cFormatSuffix);
end;

{==============================================================================}
procedure TTimeTrialRaceEngine.SetRankingGroupedByClass(AValue: boolean);
begin
  if AValue = FRankingGroupedByClass then
    Exit;

  if AValue then
    FSQLGroupingString := cRankingSQLClassGrouping
  else
    FSQLGroupingString := '';

  FRankingQuery := Format(cRankingSQLFormat, [FRaceItem.Id.ToString, FSQLGroupingString]);
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
    lExcelFiller.TemplateFile := cStdTemplatePath + 'StartListTT.xlsx';
    lExcelFiller.OutputFile := cStdDataPath + Format('StartList-%s.xlsx', [FRaceItem.Title]);

    lResultSet := nil;
    MainDataModule.FillReadOnlyDataSetForSQL(
      'SELECT C.BIB, C.LASTNAME || '', '' || C.FIRSTNAME NAME, C.TEAM, C.CLUB, P.STARTTIME ' +
      'FROM COMPETITORS C INNER JOIN PARTICIPATION P ON C.COMPETITORID = P.COMPETITORID ' +
      'WHERE RACEID = ' + FRaceItem.Id.ToString + ' ' +
      'ORDER BY C.BIB',
      lResultSet);

    lExcelFiller.FillDataRows(lResultSet);
  finally
    FreeAndNil(lExcelFiller);
    FreeAndNil(lResultSet);
  end;
end;

{==============================================================================}
procedure TTimeTrialRaceEngine.ExportResultsToExcelTemplate(const AOutputFile: string);
begin
  inherited;
end;

end.
