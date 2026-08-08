unit DecoderInterface.RaceResult;

(*==============================================================================
  RaceResult Ubidium adapter via local JSON-Lines bridge (TCP).

  Protocol: one JSON object per line, UTF-8, LF-terminated.

  Delphi -> Bridge:
    {"type":"ping"}
    {"type":"discover"}
    {"type":"connect","address":"<ip>","device_id":"<U-xxxxx>"}
    {"type":"disconnect"}

  Bridge -> Delphi:
    {"type":"pong"}
    {"type":"decoder_found", ...}
    {"type":"connected","device_id":"..."}
    {"type":"disconnected","device_id":"..."}
    {"type":"error","message":"..."}
    {"type":"passing","passing_number":1,"chip_id":"...","passing_time":"...Z","signal":-45,"decoder_id":"..."}
    {"type":"status","noise":0,"gps":true,"temperature":35.0,"input_voltage":12.0,"decoder_id":"..."}
==============================================================================*)

interface

uses
  Classes, SysUtils, DateUtils, SyncObjs,
  System.JSON,
  IdTCPClient, IdGlobal,
  DecoderInterface;

const
  cUbidiumBridgeDefaultHost = '127.0.0.1';
  cUbidiumBridgeDefaultPort = 19503;

  cBridgeMsgPing = 'ping';
  cBridgeMsgPong = 'pong';
  cBridgeMsgDiscover = 'discover';
  cBridgeMsgConnect = 'connect';
  cBridgeMsgDisconnect = 'disconnect';
  cBridgeMsgDecoderFound = 'decoder_found';
  cBridgeMsgConnected = 'connected';
  cBridgeMsgDisconnected = 'disconnected';
  cBridgeMsgError = 'error';
  cBridgeMsgPassing = 'passing';
  cBridgeMsgStatus = 'status';

type
  TBridgeStateEvent = procedure(const AEventType: string; const AMessage: string) of object;

  TUbidiumBridgeMessageParser = class
  private
    FOnStatus: TDecoderStatusReceivedEvent;
    FOnPassing: TDecoderPassingReceivedEvent;
    FOnDecoderFound: TDecoderFoundEvent;
    FOnBridgeState: TBridgeStateEvent;
    function JsonString(AObj: TJSONObject; const AName: string; const ADefault: string = ''): string;
    function JsonInt(AObj: TJSONObject; const AName: string; ADefault: Integer = 0): Integer;
    function JsonFloat(AObj: TJSONObject; const AName: string; ADefault: Double = 0): Double;
    function JsonBool(AObj: TJSONObject; const AName: string; ADefault: Boolean = False): Boolean;
    function ParsePassingTime(const AValue: string): TDateTime;
    procedure HandleDecoderFound(AObj: TJSONObject);
    procedure HandlePassing(AObj: TJSONObject);
    procedure HandleStatus(AObj: TJSONObject);
  public
    procedure ProcessLine(const ALine: string);
    property OnStatusReceived: TDecoderStatusReceivedEvent read FOnStatus write FOnStatus;
    property OnPassingReceived: TDecoderPassingReceivedEvent read FOnPassing write FOnPassing;
    property OnDecoderFound: TDecoderFoundEvent read FOnDecoderFound write FOnDecoderFound;
    property OnBridgeState: TBridgeStateEvent read FOnBridgeState write FOnBridgeState;
  end;

  TUbidiumListener = class(TDecoderListener)
  private
    FTcpClient: TIdTCPClient;
    FParser: TUbidiumBridgeMessageParser;
    FBridgeHost: string;
    FBridgePort: Word;
    FLine: string;
    FSessionConnected: Integer;
    FTcpLock: TCriticalSection;
    procedure PostLine;
    procedure SendCommand(const AJson: string);
    function BuildConnectCommand: string;
    procedure SetSessionConnected(AValue: Boolean);
    procedure HandleBridgeState(const AEventType, AMessage: string);
    procedure SafeDisconnect;
    function EnsureTcpConnected: Boolean;
    function TryReadLine(out ALine: string): Boolean;
  protected
    function GetConnected: Boolean; override;
    procedure UnblockIO; override;
  public
    constructor Create(ADecoder: TDecoder; AOnStatus: TDecoderStatusReceivedEvent;
      AOnPassing: TDecoderPassingReceivedEvent); reintroduce;
    destructor Destroy; override;
    procedure Execute; override;
    procedure StopAndWait; override;
  end;

  TUbidiumDecoderFinder = class(TDecoderFinder)
  private
    FOnDecoderFound: TDecoderFoundEvent;
    FBridgeHost: string;
    FBridgePort: Word;
    FWakeEvent: TEvent;
    FWorker: TThread;
    FPendingDecoder: TDecoder;
    FFoundDecoders: TArray<TDecoder>;
    FFoundCount: Integer;
    FWorkerStop: Boolean;
    procedure WorkerExecute;
    procedure SyncDecoderFound;
    procedure CollectDecoderFound(ADecoder: TDecoder);
    procedure RunDiscover;
  public
    constructor Create(AOnDecoderFound: TDecoderFoundEvent); reintroduce;
    destructor Destroy; override;
    procedure Refresh; override;
    property OnDecoderFound: TDecoderFoundEvent read FOnDecoderFound write FOnDecoderFound;
  end;

implementation

type
  TUbidiumFinderWorker = class(TThread)
  private
    FOwner: TUbidiumDecoderFinder;
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TUbidiumDecoderFinder);
  end;

{ TUbidiumBridgeMessageParser }

function TUbidiumBridgeMessageParser.JsonString(AObj: TJSONObject; const AName, ADefault: string): string;
var
  V: TJSONValue;
begin
  V := AObj.Values[AName];
  if (V = nil) or (V is TJSONNull) then
    Exit(ADefault);
  Result := V.Value;
end;

function TUbidiumBridgeMessageParser.JsonInt(AObj: TJSONObject; const AName: string; ADefault: Integer): Integer;
var
  V: TJSONValue;
begin
  V := AObj.Values[AName];
  if V = nil then
    Exit(ADefault);
  try
    Result := Trunc(V.AsType<Double>);
  except
    Result := ADefault;
  end;
end;

function TUbidiumBridgeMessageParser.JsonFloat(AObj: TJSONObject; const AName: string; ADefault: Double): Double;
var
  V: TJSONValue;
begin
  V := AObj.Values[AName];
  if V = nil then
    Exit(ADefault);
  try
    Result := V.AsType<Double>;
  except
    Result := ADefault;
  end;
end;

function TUbidiumBridgeMessageParser.JsonBool(AObj: TJSONObject; const AName: string; ADefault: Boolean): Boolean;
var
  V: TJSONValue;
begin
  V := AObj.Values[AName];
  if V = nil then
    Exit(ADefault);
  if V is TJSONBool then
    Exit(TJSONBool(V).AsBoolean);
  Result := SameText(V.Value, 'true') or (V.Value = '1');
end;

function TUbidiumBridgeMessageParser.ParsePassingTime(const AValue: string): TDateTime;
begin
  if AValue = '' then
    Exit(Now);
  try
    Result := ISO8601ToDate(AValue, False);
  except
    Result := Now;
  end;
end;

procedure TUbidiumBridgeMessageParser.HandleDecoderFound(AObj: TJSONObject);
var
  LDecoder: TDecoder;
begin
  LDecoder := Default(TDecoder);
  LDecoder.DecoderId := JsonString(AObj, 'device_id');
  LDecoder.Address := JsonString(AObj, 'address');
  LDecoder.FirmwareVersion := JsonString(AObj, 'firmware');
  LDecoder.DecoderType := JsonString(AObj, 'decoder_type', 'Ubidium');
  LDecoder.DecoderManufacturer := cDecoderManufacturerRaceResult;
  if Assigned(FOnDecoderFound) then
    FOnDecoderFound(LDecoder);
end;

procedure TUbidiumBridgeMessageParser.HandlePassing(AObj: TJSONObject);
var
  LPassing: TPassing;
begin
  LPassing := Default(TPassing);
  LPassing.PassingNumber := JsonInt(AObj, 'passing_number');
  LPassing.ChipId := JsonString(AObj, 'chip_id');
  if LPassing.ChipId = '' then
    Exit;
  LPassing.PassingTime := ParsePassingTime(JsonString(AObj, 'passing_time'));
  LPassing.SignalStrength := JsonInt(AObj, 'signal');
  LPassing.DecoderId := JsonString(AObj, 'decoder_id');
  if Assigned(FOnPassing) then
    FOnPassing(LPassing);
end;

procedure TUbidiumBridgeMessageParser.HandleStatus(AObj: TJSONObject);
var
  LStatus: TDecoderStatus;
begin
  LStatus := Default(TDecoderStatus);
  LStatus.Noise := JsonInt(AObj, 'noise');
  LStatus.Gps := JsonBool(AObj, 'gps');
  LStatus.Temperature := JsonFloat(AObj, 'temperature');
  LStatus.InputVoltage := JsonFloat(AObj, 'input_voltage');
  LStatus.DecoderId := JsonString(AObj, 'decoder_id');
  if Assigned(FOnStatus) then
    FOnStatus(LStatus);
end;

procedure TUbidiumBridgeMessageParser.ProcessLine(const ALine: string);
var
  LTrimmed: string;
  LValue: TJSONValue;
  LObj: TJSONObject;
  LType: string;
  LMessage: string;
begin
  LTrimmed := Trim(ALine);
  if LTrimmed = '' then
    Exit;

  LValue := TJSONObject.ParseJSONValue(LTrimmed);
  if LValue = nil then
    Exit;
  try
    if not (LValue is TJSONObject) then
      Exit;
    LObj := TJSONObject(LValue);
    LType := JsonString(LObj, 'type');
    if LType = cBridgeMsgDecoderFound then
      HandleDecoderFound(LObj)
    else if LType = cBridgeMsgPassing then
      HandlePassing(LObj)
    else if LType = cBridgeMsgStatus then
      HandleStatus(LObj)
    else if (LType = cBridgeMsgConnected) or (LType = cBridgeMsgDisconnected) or
      (LType = cBridgeMsgError) then
    begin
      LMessage := JsonString(LObj, 'message');
      if LMessage = '' then
        LMessage := JsonString(LObj, 'device_id');
      if Assigned(FOnBridgeState) then
        FOnBridgeState(LType, LMessage);
    end;
  finally
    LValue.Free;
  end;
end;

{ TUbidiumListener }

constructor TUbidiumListener.Create(ADecoder: TDecoder; AOnStatus: TDecoderStatusReceivedEvent;
  AOnPassing: TDecoderPassingReceivedEvent);
begin
  inherited Create(ADecoder, AOnStatus, AOnPassing);
  FBridgeHost := cUbidiumBridgeDefaultHost;
  FBridgePort := cUbidiumBridgeDefaultPort;
  FSessionConnected := 0;
  FTcpLock := TCriticalSection.Create;
  FParser := TUbidiumBridgeMessageParser.Create;
  FParser.OnStatusReceived := AOnStatus;
  FParser.OnPassingReceived := AOnPassing;
  FParser.OnBridgeState := HandleBridgeState;
  FTcpClient := TIdTCPClient.Create(nil);
  FTcpClient.ReadTimeout := 1000;
  FTcpClient.ConnectTimeout := 2000;
end;

destructor TUbidiumListener.Destroy;
begin
  StopAndWait;
  FreeAndNil(FTcpClient);
  FreeAndNil(FParser);
  FreeAndNil(FTcpLock);
  inherited;
end;

procedure TUbidiumListener.SetSessionConnected(AValue: Boolean);
begin
  if AValue then
    TInterlocked.Exchange(FSessionConnected, 1)
  else
    TInterlocked.Exchange(FSessionConnected, 0);
end;

function TUbidiumListener.GetConnected: Boolean;
begin
  Result := TInterlocked.CompareExchange(FSessionConnected, 0, 0) = 1;
end;

procedure TUbidiumListener.HandleBridgeState(const AEventType, AMessage: string);
begin
  if AEventType = cBridgeMsgConnected then
    SetSessionConnected(True)
  else if (AEventType = cBridgeMsgDisconnected) or (AEventType = cBridgeMsgError) then
    SetSessionConnected(False);
end;

procedure TUbidiumListener.SafeDisconnect;
begin
  if FTcpLock = nil then
    Exit;
  FTcpLock.Enter;
  try
    if (FTcpClient <> nil) and FTcpClient.Connected then
    begin
      try
        FTcpClient.Disconnect;
      except
      end;
    end;
  finally
    FTcpLock.Leave;
  end;
  SetSessionConnected(False);
end;

procedure TUbidiumListener.UnblockIO;
begin
  SafeDisconnect;
end;

procedure TUbidiumListener.StopAndWait;
begin
  if Finished then
    Exit;
  Terminate;
  UnblockIO;
  if Started then
    WaitFor;
end;

function TUbidiumListener.BuildConnectCommand: string;
var
  LObj: TJSONObject;
  LAddress: string;
  LDeviceId: string;
begin
  if FDecoder.Address <> '' then
    LAddress := FDecoder.Address
  else
    LAddress := '127.0.0.1';
  if FDecoder.DecoderId <> '' then
    LDeviceId := FDecoder.DecoderId
  else
    LDeviceId := 'U-UNKNOWN';

  LObj := TJSONObject.Create;
  try
    LObj.AddPair('type', cBridgeMsgConnect);
    LObj.AddPair('address', LAddress);
    LObj.AddPair('device_id', LDeviceId);
    Result := LObj.ToJSON;
  finally
    LObj.Free;
  end;
end;

procedure TUbidiumListener.SendCommand(const AJson: string);
begin
  if FTcpLock = nil then
    Exit;
  FTcpLock.Enter;
  try
    if (FTcpClient = nil) or not FTcpClient.Connected then
      Exit;
    FTcpClient.IOHandler.WriteLn(AJson, IndyTextEncoding_UTF8);
  finally
    FTcpLock.Leave;
  end;
end;

procedure TUbidiumListener.PostLine;
begin
  if FParser = nil then
    Exit;
  FParser.ProcessLine(FLine);
  FLine := '';
end;

function TUbidiumListener.EnsureTcpConnected: Boolean;
begin
  Result := False;
  FTcpLock.Enter;
  try
    if FTcpClient = nil then
      Exit;
    if not FTcpClient.Connected then
    begin
      FTcpClient.Host := FBridgeHost;
      FTcpClient.Port := FBridgePort;
      FTcpClient.Connect;
      FTcpClient.IOHandler.WriteLn(BuildConnectCommand, IndyTextEncoding_UTF8);
    end;
    Result := FTcpClient.Connected;
  finally
    FTcpLock.Leave;
  end;
end;

function TUbidiumListener.TryReadLine(out ALine: string): Boolean;
begin
  Result := False;
  ALine := '';
  FTcpLock.Enter;
  try
    if (FTcpClient = nil) or not FTcpClient.Connected then
      Exit;
    if FTcpClient.IOHandler.InputBufferIsEmpty then
      FTcpClient.IOHandler.CheckForDataOnSource(200);
    if FTcpClient.IOHandler.InputBufferIsEmpty then
      Exit;
    ALine := FTcpClient.IOHandler.ReadLn(IndyTextEncoding_UTF8);
    Result := ALine <> '';
  finally
    FTcpLock.Leave;
  end;
end;

procedure TUbidiumListener.Execute;
begin
  repeat
    try
      if not EnsureTcpConnected then
      begin
        Sleep(500);
        Continue;
      end;

      if TryReadLine(FLine) then
        Synchronize(PostLine)
      else
        Sleep(50);
    except
      on E: Exception do
      begin
        if SameText(E.ClassName, 'EIdReadTimeout') then
          Continue;

        SetSessionConnected(False);
        SafeDisconnect;
        if not Terminated then
          Sleep(500);
      end;
    end;
  until Terminated;

  try
    SendCommand(Format('{"type":"%s"}', [cBridgeMsgDisconnect]));
  except
  end;
  SafeDisconnect;
end;

{ TUbidiumFinderWorker }

constructor TUbidiumFinderWorker.Create(AOwner: TUbidiumDecoderFinder);
begin
  inherited Create(True);
  FOwner := AOwner;
  FreeOnTerminate := False;
end;

procedure TUbidiumFinderWorker.Execute;
begin
  FOwner.WorkerExecute;
end;

{ TUbidiumDecoderFinder }

constructor TUbidiumDecoderFinder.Create(AOnDecoderFound: TDecoderFoundEvent);
begin
  // Do not call inherited Create: TDecoderFinder is the composite owner.
  FOnDecoderFound := AOnDecoderFound;
  FBridgeHost := cUbidiumBridgeDefaultHost;
  FBridgePort := cUbidiumBridgeDefaultPort;
  FWorkerStop := False;
  FFoundCount := 0;
  FWakeEvent := TEvent.Create(nil, False, False, '');
  FWorker := TUbidiumFinderWorker.Create(Self);
  FWorker.Start;
end;

destructor TUbidiumDecoderFinder.Destroy;
begin
  FWorkerStop := True;
  if FWakeEvent <> nil then
    FWakeEvent.SetEvent;
  if FWorker <> nil then
  begin
    FWorker.Terminate;
    if FWakeEvent <> nil then
      FWakeEvent.SetEvent;
    FWorker.WaitFor;
    FreeAndNil(FWorker);
  end;
  FreeAndNil(FWakeEvent);
  // Leaf finder: skip TDecoderFinder.Destroy child cleanup (fields are nil).
  // Still run TObject finalization via inherited.
  inherited;
end;

procedure TUbidiumDecoderFinder.SyncDecoderFound;
begin
  if Assigned(FOnDecoderFound) then
    FOnDecoderFound(FPendingDecoder);
end;

procedure TUbidiumDecoderFinder.CollectDecoderFound(ADecoder: TDecoder);
begin
  if FFoundCount >= Length(FFoundDecoders) then
    SetLength(FFoundDecoders, FFoundCount + 4);
  FFoundDecoders[FFoundCount] := ADecoder;
  Inc(FFoundCount);
end;

procedure TUbidiumDecoderFinder.RunDiscover;
var
  LClient: TIdTCPClient;
  LParser: TUbidiumBridgeMessageParser;
  LDeadline: TDateTime;
  LLine: string;
  I: Integer;
begin
  LClient := TIdTCPClient.Create(nil);
  LParser := TUbidiumBridgeMessageParser.Create;
  try
    LClient.Host := FBridgeHost;
    LClient.Port := FBridgePort;
    LClient.ConnectTimeout := 500;
    LClient.ReadTimeout := 300;

    FFoundCount := 0;
    SetLength(FFoundDecoders, 0);
    LParser.OnDecoderFound := CollectDecoderFound;

    try
      LClient.Connect;
      LClient.IOHandler.WriteLn(
        Format('{"type":"%s"}', [cBridgeMsgDiscover]), IndyTextEncoding_UTF8);

      LDeadline := Now + (800 * OneMillisecond);
      while (Now < LDeadline) and not FWorkerStop do
      begin
        if LClient.IOHandler.InputBufferIsEmpty then
          LClient.IOHandler.CheckForDataOnSource(100);
        if LClient.IOHandler.InputBufferIsEmpty then
          Continue;
        LLine := LClient.IOHandler.ReadLn(IndyTextEncoding_UTF8);
        if LLine <> '' then
          LParser.ProcessLine(LLine);
      end;
    except
      // Bridge unreachable - optional search, fail quietly.
    end;

    for I := 0 to FFoundCount - 1 do
    begin
      if FWorkerStop then
        Break;
      FPendingDecoder := FFoundDecoders[I];
      TThread.Synchronize(nil, SyncDecoderFound);
    end;
  finally
    try
      if LClient.Connected then
        LClient.Disconnect;
    except
    end;
    FreeAndNil(LParser);
    FreeAndNil(LClient);
  end;
end;

procedure TUbidiumDecoderFinder.WorkerExecute;
begin
  while not FWorkerStop do
  begin
    case FWakeEvent.WaitFor(500) of
      wrSignaled:
        if not FWorkerStop then
          RunDiscover;
      wrTimeout:
        ;
    else
      Break;
    end;
  end;
end;

procedure TUbidiumDecoderFinder.Refresh;
begin
  if FWakeEvent <> nil then
    FWakeEvent.SetEvent;
end;

end.
