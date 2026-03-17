unit SmartStarting.WebClient;

interface

uses
  SysUtils,
  System.Net.HttpClient, System.Net.HttpClientComponent,
  System.Classes, System.DateUtils, Generics.Collections, IdUDPClient, IdGlobal;

type
  TDiscoveredStartListServer = record
    Address: string;
    Port: Integer;
  end;

  TSmartStartingWebClient = class
  private
    FNetHTTPClient: TNetHTTPClient;
    FNetHTTPRequest: TNetHTTPRequest;
    FServer: string;
    FPort: Integer;

    procedure ParseServerAndPort(const AServer: string; ADefaultPort: Integer);

  public
    constructor Create(const AServer: string; APort: Integer = 9768);
    destructor Destroy; override;
    function TestConnection(const AServer: string; APort: Integer = 9768): boolean;
    function GetListOfStarters: string;
    class function DiscoverServers(ATimeoutMs: Integer = 1000): TArray<TDiscoveredStartListServer>; static;

    property Server: string read FServer write FServer;
    property Port: Integer read FPort write FPort;
  end;

implementation


const
  cTimeout = 3000;
  cDiscoveryPort = 9767;
  cDiscoveryRequest = 'SMARTSTARTLIST_DISCOVER';
  cDiscoveryResponsePrefix = 'SMARTSTARTLIST_SERVER;';

{==============================================================================}
constructor TSmartStartingWebClient.Create(const AServer: string; APort: Integer = 9768);
begin
  ParseServerAndPort(AServer, APort);

  FNetHTTPClient := TNetHTTPClient.Create(nil);
  FNetHTTPRequest := TNetHTTPRequest.Create(nil);
  FNetHTTPRequest.Client := FNetHTTPClient;
  FNetHTTPRequest.ConnectionTimeout := cTimeout;
  FNetHTTPRequest.ResponseTimeout := cTimeout;
  FNetHTTPRequest.SendTimeout := cTimeout;
  FNetHTTPClient.ConnectionTimeout := cTimeout;
  FNetHTTPClient.ResponseTimeout := cTimeout;
  FNetHTTPClient.SendTimeout := cTimeout;
end;

destructor TSmartStartingWebClient.Destroy;
begin
  try
    FreeAndNil(FNetHTTPClient);
    FreeAndNil(FNetHTTPRequest);
  finally
    inherited Destroy;
  end;
end;

{==============================================================================}
procedure TSmartStartingWebClient.ParseServerAndPort(const AServer: string; ADefaultPort: Integer);
var
  LPos: Integer;
  LPortStr: string;
begin
  FServer := AServer.Trim;
  FPort := ADefaultPort;

  if FServer = '' then
    Exit;

  LPos := FServer.LastIndexOf(':');
  if LPos > 0 then
  begin
    LPortStr := FServer.Substring(LPos + 1);
    if TryStrToInt(LPortStr, FPort) then
      FServer := FServer.Substring(0, LPos)
    else
      FPort := ADefaultPort;
  end;
end;

{==============================================================================}
function TSmartStartingWebClient.TestConnection(const AServer: string; APort: Integer = 9768): boolean;
var
  lResponse: IHttpResponse;
begin
  FNetHTTPRequest.URL := Format('http://%s:%d/connectiontest', [AServer, APort]);
  lResponse := FNetHTTPRequest.Execute;
  if lResponse.StatusCode <> 200 then
    Exit(false);
  result := true;
end;

{==============================================================================}
function TSmartStartingWebClient.GetListOfStarters: string;
var
  lResponse: IHttpResponse;
begin
  FNetHTTPRequest.URL := Format('http://%s:%d/startlist', [FServer, FPort]);
  lResponse := FNetHTTPRequest.Execute;
  if lResponse.StatusCode <> 200 then
    raise Exception.Create(lResponse.StatusCode.ToString + ': ' + lResponse.StatusText);
  if SameText(lResponse.ContentCharSet, 'utf-8')then
    result := lResponse.ContentAsString(TEncoding.UTF8)
  else
    result := lResponse.ContentAsString
end;

{==============================================================================}
class function TSmartStartingWebClient.DiscoverServers(ATimeoutMs: Integer): TArray<TDiscoveredStartListServer>;
var
  LClient: TIdUDPClient;
  LStartTime, LNow: TDateTime;
  LPeerIP: string;
  LPeerPort: TIdPort;
  LResponse: string;
  LServer: TDiscoveredStartListServer;
  LList: TList<TDiscoveredStartListServer>;
  LTimeout: Integer;
begin
  Result := nil;
  if ATimeoutMs <= 0 then
    ATimeoutMs := 1000;

  LClient := TIdUDPClient.Create(nil);
  LList := TList<TDiscoveredStartListServer>.Create;
  try
    LClient.BroadcastEnabled := True;
    LClient.Port := cDiscoveryPort;
    LClient.Host := '255.255.255.255';

    LClient.Send(cDiscoveryRequest);

    LStartTime := Now;
    repeat
      LNow := Now;
      LTimeout := ATimeoutMs - MilliSecondsBetween(LNow, LStartTime);
      if LTimeout <= 0 then
        Break;
      try
        LResponse := LClient.ReceiveString(LPeerIP, LPeerPort, LTimeout{$IFDEF STRING_IS_ANSI}, IndyTextEncoding_UTF8{$ENDIF});
      except
        on E: Exception do
        begin
          if SameText(E.ClassName, 'EIdReadTimeout') then
            Break
          else
            raise;
        end;
      end;

      if LResponse.StartsWith(cDiscoveryResponsePrefix) then
      begin
        LServer.Address := LPeerIP;
        LServer.Port := StrToIntDef(Copy(LResponse, Length(cDiscoveryResponsePrefix) + 1, MaxInt), 9768);
        LList.Add(LServer);
      end;
    until False;

    if LList.Count > 0 then
      Result := LList.ToArray;
  finally
    LList.Free;
    LClient.Free;
  end;
end;

end.
