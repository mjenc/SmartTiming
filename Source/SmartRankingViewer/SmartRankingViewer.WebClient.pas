unit SmartRankingViewer.WebClient;

interface

uses
  SysUtils, DateUtils, FMX.Forms,
  System.Net.HttpClient, System.Net.HttpClientComponent,
  Tools.SuperObject;

type
  TSRVRaceItem = class
    Id: integer;
    StartTime: TDatetime;
    Title: string;
    Laps: integer;
    Distance: double;
  end;


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
    function GetRankings(ARaceId: Integer; AGrouped: boolean): string;
    procedure FillEventInfo(AForm: TForm);

    property Server: string read FServer write FServer;
    property Port: Integer read FPort write FPort;
  end;

implementation

uses
  FormSmartRankingViewer;

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
  result := true;
end;

{==============================================================================}
procedure TSmartRankingViewWebClient.FillEventInfo(AForm: TForm);
var
  lResponse: IHttpResponse;
  lSO: ISuperObject;
  lISODatetime: string;
  lEventInfo: ISuperObject;
  lRaceObject: ISuperObject;
  lRacesArray: ISuperArray;
  lRaceItem: TSRVRaceItem;
  i: Integer;
  lDatetimeStr: string;
  lForm: TFormRankingViewer;
begin
  FNetHTTPRequest.URL := Format('http://%s:%d/eventinfo', [FServer, FPort]);
  lResponse := FNetHTTPRequest.Execute;
  if lResponse.StatusCode <> 200 then
    raise Exception.Create(lResponse.StatusCode.ToString + ': ' + lResponse.StatusText);
  lSO := TSuperObject.Create(PWideChar(lResponse.ContentAsString));
  try
    lForm := TFormRankingViewer(AForm);

    lEventInfo := lSO.O['eventinfo'];
    lForm.Organizer := lEventInfo.S['organizer'];
    lForm.Title := lEventInfo.S['title'];
    lISODatetime := lEventInfo.S['datefrom'];
    if lISODatetime.IsEmpty then
      lForm.DateFrom := Now
    else
      lForm.DateFrom := ISO8601ToDateExt(lISODatetime, []);

    lISODatetime := lEventInfo.S['dateto'];
    if lISODatetime.IsEmpty then
      lForm.DateTo := Now
    else
      lForm.DateTo := ISO8601ToDateExt(lISODatetime, []);

    lRacesArray := lSO.A['races'];
    for i := 0 to lRacesArray.Length - 1 do
    begin
      lRaceObject := lRacesArray.O[i];

      lRaceItem := TSRVRaceItem.Create;
      lRaceItem.Id := lRaceObject.I['id'];
      lDatetimeStr := lRaceObject.S['starttime'];
      lRaceItem.StartTime := ISO8601ToDateExt(lDatetimeStr, []);
      lRaceItem.Title := lRaceObject.S['title'];
      lRaceItem.Laps := lRaceObject.I['laps'];
      lRaceItem.Distance := lRaceObject.F['distance'];

      lForm.RacesList.Add(lRaceItem.Id, lRaceItem);
    end;
  except
    // TODO Only log the error
  end;
end;

{==============================================================================}
function TSmartRankingViewWebClient.GetRankings(ARaceId: Integer; AGrouped: boolean): string;
var
  lResponse: IHttpResponse;
  lBoolStr: string;
begin
  if AGrouped then
    lBoolStr := 'true'
  else
    lBoolStr := 'false';

  FNetHTTPRequest.URL := Format('http://%s:%d/results?raceid=%d&grouped=%s&finishedonly=true', [FServer, FPort, ARaceId, lBoolStr]);
  lResponse := FNetHTTPRequest.Execute;
  if lResponse.StatusCode <> 200 then
    raise Exception.Create(lResponse.StatusCode.ToString + ': ' + lResponse.StatusText);
  result := lResponse.ContentAsString;
end;

end.
