unit SmartRankingViewer.WebClient;

interface

uses
  SysUtils,
  System.Net.HttpClient, System.Net.HttpClientComponent;

type
  TSmartRankingViewWebClient = class
  private
    FNetHTTPClient: TNetHTTPClient;
    FNetHTTPRequest: TNetHTTPRequest;
    FServer: string;
    FPort: Integer;

  public
    constructor Create(const AServer: string; APort: Integer = 9768);
    destructor Destroy; override;
    function TestConnection(const AServer: string; APort: Integer = 9768): boolean;
    function GetRankings: string;

    property Server: string read FServer write FServer;
    property Port: Integer read FPort write FPort;
  end;

implementation


{==============================================================================}
constructor TSmartRankingViewWebClient.Create(const AServer: string; APort: Integer = 9768);
begin
  FServer := AServer;
  FPort := APort;

  FNetHTTPClient := TNetHTTPClient.Create(nil);
  FNetHTTPRequest := TNetHTTPRequest.Create(nil);
  FNetHTTPRequest.Client := FNetHTTPClient;
end;

{==============================================================================}
destructor TSmartRankingViewWebClient.Destroy;
begin
  try
    FreeAndNil(FNetHTTPClient);
    FreeAndNil(FNetHTTPRequest);
  finally
    inherited Destroy;
  end;
end;

{==============================================================================}
function TSmartRankingViewWebClient.TestConnection(const AServer: string; APort: Integer = 9768): boolean;
var
  lResponse: IHttpResponse;
begin
  FNetHTTPRequest.URL := Format('http://%s:%d/connectiontest', [AServer, APort]);
  lResponse := FNetHTTPRequest.Execute;
  if lResponse.StatusCode <> 200 then
    Exit(false);
end;

{==============================================================================}
function TSmartRankingViewWebClient.GetRankings: string;
var
  lResponse: IHttpResponse;
begin
  FNetHTTPRequest.URL := Format('http://%s:%d/results', [FServer, FPort]);
  lResponse := FNetHTTPRequest.Execute;
  if lResponse.StatusCode <> 200 then
    raise Exception.Create(lResponse.StatusCode.ToString + ': ' + lResponse.StatusText);
  result := lResponse.ContentAsString;
end;

end.
