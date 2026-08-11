unit RaceEngine.Skeleton;

{==============================================================================
  Plan 1 — Shared skeleton for non-ITT disciplines until scoring (step 4+) lands.
  Placeholder ranking from PARTICIPATION/COMPETITORS; no scoring, no Excel.
==============================================================================}

interface

uses
  Classes, Controls, ComCtrls, SysUtils, Types, UITypes, Graphics, Forms, DB,
  SmartTiming.Consts, DecoderInterface, RaceEngine.Custom, SmartTiming.Event;

type
  TSkeletonRaceEngine = class(TCustomRaceEngine)
  protected
    procedure UpdateParticipationTable(ACurrentPassingId: integer); override;
    procedure AfterOpenRankingResultSet(ADataSet: TDataSet); override;
    procedure OnPassingItemCompare(ASender: TObject; AItem1, AItem2: TListItem;
      AData: Integer; var ACompare: Integer); override;
    procedure ApplySkeletonFormats(const AFormatSuffix: string); virtual;
  public
    constructor Create(AParent: TWinControl; AEvent: TEventDataObject;
      ARaceItem: TRaceItem); override;

    procedure ExportParticipantsToExcelTemplate(const AOutputFile: string); override;
    procedure ExportResultsToExcelTemplate(const AOutputFile: string;
      AGroupByClass: boolean); override;
    procedure PrintResults(AGroupByClass: boolean); override;
  end;

implementation

uses
  Vcl.Dialogs, SmartTiming.Tools;

{==============================================================================}
procedure TSkeletonRaceEngine.ApplySkeletonFormats(const AFormatSuffix: string);
begin
  (* %1:s kept for GetRankingSQL signature compatibility (unused here). *)
  FRankingSQLFormat :=
    'SELECT NULL AS CURRENTRANKING, C.CLASS, C.BIB, ' +
    'C.LASTNAME || '', '' || C.FIRSTNAME AS NAME, IFNULL(C.TEAM, C.CLUB) AS TEAM, ' +
    'NULL AS RANKINGTIME, NULL AS GAP, NULL AS FINISHTIME, P.STARTTIME, ' +
    'P.DNS, P.DNF, P.DSQ, P.PENALTIES, P.PARTICIPATIONID, P.COMPETITORID ' +
    'FROM COMPETITORS C INNER JOIN PARTICIPATION P ON C.COMPETITORID = P.COMPETITORID ' +
    'WHERE P.RACEID = %0:s %3:s ' +
    'ORDER BY %2:s C.BIB';
  FResultSQLFormat :=
    'SELECT NULL AS CURRENTRANKING, C.CLASS, C.BIB, ' +
    'C.LASTNAME || '', '' || C.FIRSTNAME AS NAME, IFNULL(C.TEAM, C.CLUB) AS TEAM, ' +
    'C.UCIID, NULL AS RANKINGTIME, NULL AS GAP, P.DNS, P.DNF, P.DSQ ' +
    'FROM COMPETITORS C INNER JOIN PARTICIPATION P ON C.COMPETITORID = P.COMPETITORID ' +
    'WHERE P.RACEID = %0:s ' +
    'ORDER BY %2:s C.BIB';
  FRankingSQLClassGrouping := '';
  FRankingSQLClassSorting := 'C.CLASS, ';
  FFormatSuffix := AFormatSuffix;
  FResultsJsonFieldTitles :=
    'Platz,Klasse,Nr,Name,Team,Wertungszeit,Diff,Zielzeit,Startzeit,DNS,DNF,DSQ,Strafen';
  FDefaultListFormatRanking := '';
end;

{==============================================================================}
constructor TSkeletonRaceEngine.Create(AParent: TWinControl; AEvent: TEventDataObject;
  ARaceItem: TRaceItem);
begin
  if FRankingSQLFormat = '' then
    ApplySkeletonFormats('.Skeleton');
  inherited Create(AParent, AEvent, ARaceItem);
  FAvailableRaceStates :=
    [rsNotStarted, rsWarmUp, rsStarted, rsNeutralized, rsFinished, rsAborted, rsStopped];
  FRankingQuery := GetRankingSQL(False);
  FSQLDataSetRankings.CommandText := FRankingQuery;
end;

{==============================================================================}
procedure TSkeletonRaceEngine.UpdateParticipationTable(ACurrentPassingId: integer);
begin
  (* Scoring comes in Plan 1 step 4+. *)
end;

{==============================================================================}
procedure TSkeletonRaceEngine.AfterOpenRankingResultSet(ADataSet: TDataSet);
begin
  (* No grid-format registry until discipline scoring exists. *)
end;

{==============================================================================}
procedure TSkeletonRaceEngine.OnPassingItemCompare(ASender: TObject;
  AItem1, AItem2: TListItem; AData: Integer; var ACompare: Integer);
begin
  ACompare := 0;
end;

{==============================================================================}
procedure TSkeletonRaceEngine.ExportParticipantsToExcelTemplate(const AOutputFile: string);
begin
  SmartTimingTools.ShowDialog(cMessagesRaceEngineSkeletonExport, '', [tcbOk], tcbOk);
end;

{==============================================================================}
procedure TSkeletonRaceEngine.ExportResultsToExcelTemplate(const AOutputFile: string;
  AGroupByClass: boolean);
begin
  SmartTimingTools.ShowDialog(cMessagesRaceEngineSkeletonExport, '', [tcbOk], tcbOk);
end;

{==============================================================================}
procedure TSkeletonRaceEngine.PrintResults(AGroupByClass: boolean);
begin
  SmartTimingTools.ShowDialog(cMessagesRaceEngineSkeletonExport, '', [tcbOk], tcbOk);
end;

end.
