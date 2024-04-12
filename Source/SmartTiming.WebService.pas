unit SmartTiming.WebService;
{$I Compiler_Settings}

// Diese Unit nicht in die das CASablanca-Package mit aufnehmen!!!!
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

{******************************************************************************}
constructor TSmartTimingServlet.Create;
begin
  inherited Create;
end;

{******************************************************************************}
constructor TSmartTimingServlet.Create(AHTTPPort: integer);
begin
  inherited Create;

  FHTTPServer := nil;
  FHTTPPort := AHTTPPort;
  InitHttpServer;
end;

{******************************************************************************}
destructor TSmartTimingServlet.Destroy;
begin
  try
    FreeAndNil(FHTTPServer);
  finally
    inherited;
  end;
end;

{******************************************************************************}
procedure TSmartTimingServlet.InitHttpServer;
begin
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
  FHTTPServer.Active := true;
end;

{******************************************************************************}
procedure TSmartTimingServlet.StopService;
begin
  FHTTPServer.Active := false;
end;

{******************************************************************************}
procedure TSmartTimingServlet.RestartService(AHTTPPort: integer);
begin
  FHTTPPort := AHTTPPort;
  FreeAndNil(FHTTPServer);
  InitHttpServer;
end;

{******************************************************************************}
procedure TSmartTimingServlet.HTTPServerCommand(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
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

  if ARequestInfo.Document.Equals('/connectiontest') then
  begin
    AResponseInfo.ResponseNo := 200;
    AResponseInfo.ContentType := 'text/json';
    AResponseInfo.ContentText := '{"test":"succeeded"}';
    Exit;
  end;

end;

{******************************************************************************}
procedure TSmartTimingServlet.FillStartListResponse(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  lDataSet: TSQLDataSet;
begin
  AResponseInfo.ResponseNo := 200;
  AResponseInfo.ContentType := 'text/json';

  lDataSet := TSQLDataSet.Create(nil);
  try
    MainDataModule.FillReadOnlyDataSetForSQL(
    'SELECT C.CLASS, C.BIB, C.FIRSTNAME, C.LASTNAME, C.CLUB, C.TEAM, C.NATIONALITY, C.UCIID, P.STARTTIME ' +
    'FROM COMPETITORS C INNER JOIN PARTICIPATION P ON C.COMPETITORID = P.COMPETITORID ' +
    'ORDER BY P.STARTTIME',
    lDataSet);
    AResponseInfo.ContentText := TMainDataModule.GetJSONFromDataSet(lDataSet);
  finally
    FreeAndNil(lDataSet);
  end;
end;

{******************************************************************************}
procedure TSmartTimingServlet.FillResultResponse(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  lDataSet: TSQLDataSet;
begin
  AResponseInfo.ResponseNo := 200;
  AResponseInfo.ContentType := 'text/json';

  lDataSet := TSQLDataSet.Create(nil);
  try
    MainDataModule.FillReadOnlyDataSetForSQL(
      'SELECT ROW_NUMBER() OVER (PARTITION BY C.CLASS, 1 ORDER BY C.CLASS, P.RANKINGTIME IS NULL, P.RANKINGTIME, P.STARTTIME) CURRENTRANKING, '+
      'C.CLASS, C.BIB, C.LASTNAME || '', '' || C.FIRSTNAME NAME, IFNULL(C.TEAM, C.CLUB) TEAM, P.RANKINGTIME, ' +
      'STRFTIME(''%%M:%%f'',JULIANDAY(P.RANKINGTIME)- LAG(JULIANDAY(P.RANKINGTIME), 1) ' +
      'OVER (PARTITION BY C.CLASS, 1 ORDER BY C.CLASS, P.LAPS DESC, P.RANKINGTIME IS NULL, P.RANKINGTIME, P.STARTTIME))  GAP, ' +
      'P.FINISHTIME, P.STARTTIME, P.DNS, P.DNF, P.DSQ, P.PENALTIES, P.PARTICIPATIONID, P.COMPETITORID ' +
      'FROM COMPETITORS C INNER JOIN PARTICIPATION P ON C.COMPETITORID = P.COMPETITORID ' +
      'WHERE P.RANKINGTIME IS NOT NULL ' +
      'ORDER BY C.CLASS, P.RANKINGTIME IS NULL, P.LAPS DESC, P.RANKINGTIME, P.STARTTIME',
        lDataSet);
    AResponseInfo.ContentText := TMainDataModule.GetJSONFromDataSet(lDataSet);
  finally
    FreeAndNil(lDataSet);
  end;
end;

end.
