unit SmartStarting.WebClient;

interface

uses
  SysUtils,
  System.Net.HttpClient, System.Net.HttpClientComponent;

type
  TSmartStartingWebClient = class
  private
    FNetHTTPClient: TNetHTTPClient;
    FNetHTTPRequest: TNetHTTPRequest;
    FServer: string;
    FPort: Integer;

  public
    constructor Create(const AServer: string; APort: Integer = 9768);
    destructor Destroy; override;
    function TestConnection(const AServer: string; APort: Integer = 9768): boolean;
    function GetListOfStarters: string;

    property Server: string read FServer write FServer;
    property Port: Integer read FPort write FPort;
  end;

implementation


{==============================================================================}
constructor TSmartStartingWebClient.Create(const AServer: string; APort: Integer = 9768);
begin
  FServer := AServer;
  FPort := APort;

  FNetHTTPClient := TNetHTTPClient.Create(nil);
  FNetHTTPRequest := TNetHTTPRequest.Create(nil);
  FNetHTTPRequest.Client := FNetHTTPClient;
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
function TSmartStartingWebClient.TestConnection(const AServer: string; APort: Integer = 9768): boolean;
var
  lResponse: IHttpResponse;
begin
  FNetHTTPRequest.URL := Format('http://%s:%d/connectiontest', [AServer, APort]);
  lResponse := FNetHTTPRequest.Execute;
  if lResponse.StatusCode <> 200 then
    Exit(false);
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
  result := lResponse.ContentAsString;
end;

end.
