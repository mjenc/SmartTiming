unit SmartStartListServer.Backend;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.Win.Registry,
  IdHTTPServer,
  IdCustomHTTPServer,
  IdContext;

type
  TStartListField =
    (slfClass,
     slfBib,
     slfFirstName,
     slfLastName,
     slfClub,
     slfTeam,
     slfNationality,
     slfUciId,
     slfStartTime);

  TColumnMapping = array[TStartListField] of Integer;

  TFnLogPrcprocedure = procedure (const AMsg: string) of object;

  TStartListEntry = record
    RaceClass   : string;
    Bib         : string;
    FirstName   : string;
    LastName    : string;
    Club        : string;
    Team        : string;
    Nationality : string;
    UciId       : string;
    StartTime   : TDateTime; // Datum + Zeit (Datum z. B. 01.01.2026)
  end;

  TStartListServer = class
  private
    FHTTPServer   : TIdHTTPServer;
    FPort         : Integer;
    FCsvFileName  : string;
    FColumnMapping: TColumnMapping;
    FOnLog: TFnLogPrcprocedure;

    procedure HTTPCommand(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
    function ParseStartTimeFromCsv(const AValue: string): TDateTime;
    function FormatStartTimeForJson(AStartTime: TDateTime): string;
    function BuildStartListJson(var AIsUtf8: Boolean; var ACount: Integer): string;

    procedure InitServer;
  public
    constructor Create(AOnLog: TFnLogPrcprocedure);
    destructor Destroy; override;

    procedure Start;
    procedure Stop;

    procedure LoadMappingFromRegistry;
    procedure SaveMappingToRegistry;

    property Port: Integer read FPort write FPort;
    property CsvFileName: string read FCsvFileName write FCsvFileName;
    property ColumnMapping: TColumnMapping read FColumnMapping write FColumnMapping;
  end;

implementation

const
  cRegKeyPath = 'Software\SmartTiming\SmartStartListServer';

{ TStartListServer }

constructor TStartListServer.Create(AOnLog: TFnLogPrcprocedure);
var
  f: TStartListField;
begin
  inherited Create;
  FHTTPServer := nil;
  FPort := 9768;
  FCsvFileName := '';

  for f := Low(TStartListField) to High(TStartListField) do
    FColumnMapping[f] := -1; // -1 = nicht gemappt

  LoadMappingFromRegistry;
  InitServer;
  FOnLog := AOnLOg;
end;

destructor TStartListServer.Destroy;
begin
  Stop;
  FreeAndNil(FHTTPServer);
  inherited;
end;

procedure TStartListServer.InitServer;
begin
  if FHTTPServer <> nil then
    Exit;

  FHTTPServer := TIdHTTPServer.Create(nil);
  FHTTPServer.DefaultPort := FPort;
  FHTTPServer.OnCommandGet := HTTPCommand;
  FHTTPServer.OnCommandOther := HTTPCommand;
end;

procedure TStartListServer.Start;
begin
  if FHTTPServer = nil then
    InitServer;

  if not FHTTPServer.Active then
  begin
    FHTTPServer.DefaultPort := FPort;
    FHTTPServer.Active := True;
  end;
end;

procedure TStartListServer.Stop;
begin
  if Assigned(FHTTPServer) and FHTTPServer.Active then
    FHTTPServer.Active := False;
end;

procedure TStartListServer.LoadMappingFromRegistry;
var
  reg: TRegistry;
  function ReadIntDef(const AName: string; ADefault: Integer): Integer;
  begin
    if reg.ValueExists(AName) then
      Result := reg.ReadInteger(AName)
    else
      Result := ADefault;
  end;
begin
  reg := TRegistry.Create(KEY_READ);
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKeyReadOnly(cRegKeyPath) then
    begin
      FColumnMapping[slfClass]       := ReadIntDef('ClassCol',      -1);
      FColumnMapping[slfBib]         := ReadIntDef('BibCol',        -1);
      FColumnMapping[slfFirstName]   := ReadIntDef('FirstNameCol',  -1);
      FColumnMapping[slfLastName]    := ReadIntDef('LastNameCol',   -1);
      FColumnMapping[slfClub]        := ReadIntDef('ClubCol',       -1);
      FColumnMapping[slfTeam]        := ReadIntDef('TeamCol',       -1);
      FColumnMapping[slfNationality] := ReadIntDef('NationalityCol',-1);
      FColumnMapping[slfUciId]       := ReadIntDef('UciIdCol',      -1);
      FColumnMapping[slfStartTime]   := ReadIntDef('StartTimeCol',  -1);
    end;
  finally
    reg.Free;
  end;
end;

procedure TStartListServer.SaveMappingToRegistry;
var
  reg: TRegistry;
begin
  reg := TRegistry.Create(KEY_WRITE);
  try
    reg.RootKey := HKEY_CURRENT_USER;
    if reg.OpenKey(cRegKeyPath, True) then
    begin
      reg.WriteInteger('ClassCol',       FColumnMapping[slfClass]);
      reg.WriteInteger('BibCol',         FColumnMapping[slfBib]);
      reg.WriteInteger('FirstNameCol',   FColumnMapping[slfFirstName]);
      reg.WriteInteger('LastNameCol',    FColumnMapping[slfLastName]);
      reg.WriteInteger('ClubCol',        FColumnMapping[slfClub]);
      reg.WriteInteger('TeamCol',        FColumnMapping[slfTeam]);
      reg.WriteInteger('NationalityCol', FColumnMapping[slfNationality]);
      reg.WriteInteger('UciIdCol',       FColumnMapping[slfUciId]);
      reg.WriteInteger('StartTimeCol',   FColumnMapping[slfStartTime]);
    end;
  finally
    reg.Free;
  end;
end;

procedure TStartListServer.HTTPCommand(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  lIsUtf8: Boolean;
  lContent: String;
  lCount: Integer;
begin
  if ARequestInfo = nil then
    Exit;

  if (ARequestInfo.Document = '/') or (ARequestInfo.Document = '') then
  begin
    AResponseInfo.ResponseNo := 404;
    Exit;
  end;

  if SameText(ARequestInfo.Document, '/connectiontest') then
  begin
    AResponseInfo.ResponseNo := 200;
    AResponseInfo.ContentType := 'text/json';
    AResponseInfo.Charset := 'utf-8';
    AResponseInfo.ContentText := '{"test":"succeeded"}';
    Exit;
  end;

  if SameText(ARequestInfo.Document, '/startlist') then
  begin
    AResponseInfo.ResponseNo := 200;
    AResponseInfo.ContentType := 'text/json';
    lContent := BuildStartListJson(lIsUtf8, lCount);
    if lIsUtf8 then
      AResponseInfo.Charset := 'utf-8';
    AResponseInfo.ContentText := lContent;

    if Assigned(FOnLog) then
      FOnLog('Sending ' + lCount.ToString + ' entries to the caller.');

    Exit;
  end;

  AResponseInfo.ResponseNo := 404;
end;

function TStartListServer.ParseStartTimeFromCsv(const AValue: string): TDateTime;
var
  lTime: TDateTime;
begin
  Result := 0;
  if AValue.Trim.IsEmpty then
    Exit;
  if TryStrToDateTime(AValue.Trim, Result) then
    Exit;
  if TryStrToTime(AValue.Trim, lTime) then
    Result := EncodeDate(2026, 1, 1) + Frac(lTime);
end;

function TStartListServer.FormatStartTimeForJson(AStartTime: TDateTime): string;
begin
  if AStartTime = 0 then
    Result := ''
  else
    Result := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', Trunc(Now) + Frac(AStartTime));
end;

function TStartListServer.BuildStartListJson(var AIsUtf8: Boolean; var ACount: Integer): string;
var
  lines: TStringList;
  i: Integer;
  cols: TArray<string>;
  entries: TList<TStartListEntry>;
  entry: TStartListEntry;
  json: TStringBuilder;

  function GetSafeCol(const ACols: TArray<string>; AIndex: Integer): string;
  begin
    if (AIndex < 0) or (AIndex >= Length(ACols)) then
      Exit('');
    Result := ACols[AIndex].Trim;
  end;

  function EscapeJson(const S: string): string;
  var
    c: Char;
  begin
    Result := '"';
    for c in S do
      case c of
        '"':  Result := Result + '\"';
        '\': Result := Result + '\\';
        #8:  Result := Result + '\b';
        #9:  Result := Result + '\t';
        #10: Result := Result + '\n';
        #12: Result := Result + '\f';
        #13: Result := Result + '\r';
      else
        Result := Result + c;
      end;
    Result := Result + '"';
  end;

begin
  ACount := 0;
  Result := '{}';

  if (FCsvFileName = '') or (not FileExists(FCsvFileName)) then
    Exit;

  AIsUTF8 := false;
  lines := TStringList.Create;
  entries := TList<TStartListEntry>.Create;
  json := TStringBuilder.Create;
  try
    try
      lines.LoadFromFile(FCsvFileName, TEncoding.UTF8);
      AIsUTF8 := true;
    except
      lines.LoadFromFile(FCsvFileName);
    end;
    if lines.Count < 2 then
      Exit;

    // Zeile 0 = Header, wird ignoriert, Mapping ist bereits festgelegt
    for i := 1 to lines.Count - 1 do
    begin
      if lines[i].Trim.IsEmpty then
        Continue;

      cols := lines[i].Split([';']);

      entry.RaceClass   := GetSafeCol(cols, FColumnMapping[slfClass]);
      entry.Bib         := GetSafeCol(cols, FColumnMapping[slfBib]);
      entry.FirstName   := GetSafeCol(cols, FColumnMapping[slfFirstName]);
      entry.LastName    := GetSafeCol(cols, FColumnMapping[slfLastName]);
      entry.Club        := GetSafeCol(cols, FColumnMapping[slfClub]);
      entry.Team        := GetSafeCol(cols, FColumnMapping[slfTeam]);
      entry.Nationality := GetSafeCol(cols, FColumnMapping[slfNationality]);
      entry.UciId       := GetSafeCol(cols, FColumnMapping[slfUciId]);
      entry.StartTime   := ParseStartTimeFromCsv(GetSafeCol(cols, FColumnMapping[slfStartTime]));

      entries.Add(entry);
    end;

    json.Append('{"list":[');
    for i := 0 to entries.Count - 1 do
    begin
      if i > 0 then
        json.Append(',');

      entry := entries[i];
      json.Append('{');
      json.Append('"CLASS":').Append(EscapeJson(entry.RaceClass)).Append(',');
      json.Append('"BIB":').Append(EscapeJson(entry.Bib)).Append(',');
      json.Append('"FIRSTNAME":').Append(EscapeJson(entry.FirstName)).Append(',');
      json.Append('"LASTNAME":').Append(EscapeJson(entry.LastName)).Append(',');
      json.Append('"CLUB":').Append(EscapeJson(entry.Club)).Append(',');
      json.Append('"TEAM":').Append(EscapeJson(entry.Team)).Append(',');
      json.Append('"NATIONALITY":').Append(EscapeJson(entry.Nationality)).Append(',');
      json.Append('"UCIID":').Append(EscapeJson(entry.UciId)).Append(',');
      json.Append('"STARTTIME":').Append(EscapeJson(FormatStartTimeForJson(entry.StartTime)));
      json.Append('}');
    end;
    json.Append(']}');

    ACount := entries.Count;
    Result := json.ToString;
  finally
    json.Free;
    entries.Free;
    lines.Free;
  end;
end;

end.

