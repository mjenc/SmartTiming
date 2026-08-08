unit SmartTiming.WebService;

// Diese Unit nicht in ein Package mit aufnehmen!!!!
{$DENYPACKAGEUNIT ON}

interface

uses
  Classes, SysUtils, IdHTTPServer, IdCustomHTTPServer, IdContext,
  DataModule, Data.SqlExpr;

type
  TSmartTimingServlet = class
  private
    FHTTPPort: integer;
    FHTTPServer: TIdHTTPServer;
    procedure HTTPServerCommand(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    function GetRunningState: boolean;
    function GetCurrentHTTPPort: integer;
    procedure InitHttpServer;
    procedure FillStartListResponse(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure FillResultResponse(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure GetEventInfo(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure GetRaceInfo(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  public
    constructor Create; overload;
    constructor Create(AHTTPPort: integer); overload;
    destructor Destroy; override;

    procedure StartService(AHTTPPort: integer);
    procedure StopService;
    procedure RestartService(AHTTPPort: integer);
    property Running: boolean read GetRunningState;
    property HTTPPort: integer read GetCurrentHTTPPort;
  end;

implementation

uses
  SmartTiming.Controller, RaceEngine.Custom, Tools.Logger;

const
  cLogger = 'SmartTiming.WebService';

{******************************************************************************}
constructor TSmartTimingServlet.Create;
begin
  inherited Create;
end;

{******************************************************************************}
constructor TSmartTimingServlet.Create(AHTTPPort: integer);
begin
  LogOnDebug(cLogger, ['Creating WebService', 'Port: ' + AHTTPPort.ToString]);

  inherited Create;

  FHTTPServer := nil;
  FHTTPPort := AHTTPPort;
  InitHttpServer;
end;

{******************************************************************************}
destructor TSmartTimingServlet.Destroy;
begin
  try
    LogOnDebug(cLogger, ['Destroying WebService']);
    FreeAndNil(FHTTPServer);
  finally
    inherited;
  end;
end;

{******************************************************************************}
procedure TSmartTimingServlet.InitHttpServer;
begin
  LogOnDebug(cLogger, ['InitHttpServer']);
  FHTTPServer := TIdHTTPServer.Create;
  FHTTPServer.OnCommandGet := HTTPServerCommand;
  FHTTPServer.OnCommandOther := HTTPServerCommand;
  FHTTPServer.DefaultPort := FHTTPPort;
end;

{******************************************************************************}
function TSmartTimingServlet.GetRunningState: boolean;
begin
  result := FHTTPServer.Active;
end;

{******************************************************************************}
function TSmartTimingServlet.GetCurrentHTTPPort: integer;
begin
  result := FHTTPServer.DefaultPort;
end;

{******************************************************************************}
procedure TSmartTimingServlet.StartService(AHTTPPort: integer);
begin
  LogOnDebug(cLogger, ['StartService']);
  FHTTPServer.Active := true;
end;

{******************************************************************************}
procedure TSmartTimingServlet.StopService;
begin
  LogOnDebug(cLogger, ['StopService']);
  FHTTPServer.Active := false;
end;

{******************************************************************************}
procedure TSmartTimingServlet.RestartService(AHTTPPort: integer);
begin
  LogOnDebug(cLogger, ['RestartService']);
  FHTTPPort := AHTTPPort;
  FreeAndNil(FHTTPServer);
  InitHttpServer;
end;

{******************************************************************************}
procedure TSmartTimingServlet.HTTPServerCommand(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  try
    LogOnDebug(cLogger, ['HTTPServerCommand']);

    if ARequestInfo = nil then
      raise Exception.Create('ARequestInfo = nil');

    if (ARequestInfo.Document.IsEmpty or ARequestInfo.Document.Equals('/')) then
    begin
      AResponseInfo.ResponseNo := 404;
      Exit;
    end;

    if AResponseInfo = nil then
      raise Exception.Create('AResponseInfo = nil');

    if ARequestInfo.Document.Equals('/startlist') then
    begin
      FillStartListResponse(ARequestInfo, AResponseInfo);
      Exit;
    end;

    if ARequestInfo.Document.Equals('/results') then
    begin
      FillResultResponse(ARequestInfo, AResponseInfo);
      Exit;
    end;

    if ARequestInfo.Document.Equals('/eventinfo') then
    begin
      GetEventInfo(ARequestInfo, AResponseInfo);
      Exit;
    end;

    if ARequestInfo.Document.Equals('/raceinfo') then
    begin
      GetRaceInfo(ARequestInfo, AResponseInfo);
      Exit;
    end;

    if ARequestInfo.Document.Equals('/connectiontest') then
    begin
      AResponseInfo.ResponseNo := 200;
      AResponseInfo.ContentType := 'text/json';
      AResponseInfo.ContentText := '{"test":"succeeded"}';
      Exit;
    end;
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['HTTPServerCommand']);
  end;
end;

{******************************************************************************}
procedure TSmartTimingServlet.FillStartListResponse(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  lDataSet: TSQLDataSet;
begin
  try
    LogOnDebug(cLogger, ['FillStartListResponse']);
    AResponseInfo.ResponseNo := 200;
    AResponseInfo.ContentType := 'text/json';

    lDataSet := TSQLDataSet.Create(nil);
    try
      MainDataModule.FillReadOnlyDataSetForSQL(
      'SELECT C.CLASS, C.BIB, C.FIRSTNAME, C.LASTNAME, C.CLUB, C.TEAM, C.NATIONALITY, C.UCIID, P.STARTTIME ' +
      'FROM COMPETITORS C INNER JOIN PARTICIPATION P ON C.COMPETITORID = P.COMPETITORID ' +
      'ORDER BY P.STARTTIME',
      lDataSet);
      AResponseInfo.ContentText := TMainDataModule.GetJSONFromDataSet(lDataSet, '');
    finally
      FreeAndNil(lDataSet);
    end;
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['FillStartListResponse']);
  end;
end;

{******************************************************************************}
procedure TSmartTimingServlet.FillResultResponse(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  lDataSet: TSQLDataSet;
  lRaceIdStr: string;
  lGrouped: string;
  lSorting: string;
  lFilter: string;
begin
  try
    LogOnDebug(cLogger, ['FillResultResponse']);
    AResponseInfo.ResponseNo := 204;
    AResponseInfo.ContentType := 'text/json';

    lRaceIdStr := ARequestInfo.Params.Values['raceid'];
    if lRaceIdStr.IsEmpty then
      Exit;

    if ARequestInfo.Params.Values['grouped'] = 'true' then
    begin
      lGrouped := '_BYCLASS';
      lSorting := 'CLASS,';
    end;

    if ARequestInfo.Params.Values['finishedonly'] = 'true' then
      lFilter := 'AND RANKINGTIME IS NOT NULL OR DNS != 0 OR DNF != 0 OR DSQ != 0';

    AResponseInfo.ResponseNo := 200;

    lDataSet := TSQLDataSet.Create(nil);
    try
      MainDataModule.FillReadOnlyDataSetForSQL(Format(
        'SELECT CURRENTRANKING, CLASS, BIB, NAME, TEAM, RANKINGTIME, GAP, ' +
        'FINISHTIME, STARTTIME, DNS, DNF, DSQ, PENALTIES, PARTICIPATIONID, COMPETITORID ' +
        'FROM RANKING_TIMETRIAL%1:s ' +
        'WHERE RACEID = %0:s %3:s ' +
        'ORDER BY %2:s DNS, DNF, DSQ, RANKINGTIME IS NULL, LAPS DESC, RANKINGTIME, STARTTIME',
        [lRaceIdStr, lGrouped, lSorting, lFilter]),
        lDataSet);
      AResponseInfo.ContentText := TMainDataModule.GetJSONFromDataSet(lDataSet, 'Platz,Klasse,Nr,Name,Team,Wertungszeit,Diff,Zielzeit,Startzeit,DNS,DNF,DSQ,Strafen');
    finally
      FreeAndNil(lDataSet);
    end;
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['FillResultResponse']);
  end;
end;

{******************************************************************************}
procedure TSmartTimingServlet.GetEventInfo(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  lRaceItem: TRaceItem;
  lContent: string;
begin
  try
    LogOnDebug(cLogger, ['GetEventInfo']);
    AResponseInfo.ResponseNo := 200;
    AResponseInfo.ContentType := 'text/json';
    lContent :=
      '{ "eventinfo": ' + GSmartTimingController.Event.AsJSON + ', "races": [';
    for lRaceItem in GSmartTimingController.RaceList.Values do
      lContent := lContent + lRaceItem.InfoToJSON + ',';
    lContent := lContent.TrimRight([',']);
    lContent := lContent + ']}';
    AResponseInfo.ContentText := lContent;
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['GetEventInfo']);
  end;
end;

{******************************************************************************}
procedure TSmartTimingServlet.GetRaceInfo(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  lRaceIdStr: string;
  lRaceItem: TRaceItem;
begin
  try
    LogOnDebug(cLogger, ['GetRaceInfo']);
    AResponseInfo.ResponseNo := 204;
    AResponseInfo.ContentType := 'text/json';

    lRaceIdStr := ARequestInfo.Params.Values['raceid'];
    if lRaceIdStr.IsEmpty then
      Exit;

    if not GSmartTimingController.RaceList.TryGetValue(lRaceIdStr.ToInteger, lRaceItem) then
      Exit;

    AResponseInfo.ResponseNo := 200;
    AResponseInfo.ContentText := lRaceItem.InfoToJSON;
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['GetRaceInfo']);
  end;
end;

end.
