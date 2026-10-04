unit SmartTiming.MyLapsFakeDecoder;

{==============================================================================
  Plan 9 Phase B: loopback MyLaps P3 TCP server on 127.0.0.1:5403.
  Speaks the same framing as a real decoder so TMyLapsP3Listener can connect.
==============================================================================}

interface

uses
  System.SysUtils, System.Classes, System.SyncObjs,
  IdTCPServer, IdContext, IdGlobal,
  DecoderInterface, DecoderInterface.MyLaps;

type
  TMyLapsP3FakeDecoder = class
  private
    FServer: TIdTCPServer;
    FParser: TMyLapsP3MessageParser;
    FLock: TCriticalSection;
    FClientCount: Integer;
    procedure OnConnect(AContext: TIdContext);
    procedure OnDisconnect(AContext: TIdContext);
    procedure OnExecute(AContext: TIdContext);
    function HexToBytes(const AHex: string): TIdBytes;
    function GetActive: Boolean;
    function GetHasClient: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Start(APort: Word = cMyLapsDefaultOperatingPort);
    procedure Stop;
    function WaitForClient(ATimeoutMs: Integer): Boolean;
    procedure SendPassing(const APassing: TPassing);
    property Active: Boolean read GetActive;
    property HasClient: Boolean read GetHasClient;
  end;

implementation

uses
  System.StrUtils;

{==============================================================================}
constructor TMyLapsP3FakeDecoder.Create;
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FParser := TMyLapsP3MessageParser.Create;
  FClientCount := 0;

  FServer := TIdTCPServer.Create(nil);
  FServer.OnConnect := OnConnect;
  FServer.OnDisconnect := OnDisconnect;
  FServer.OnExecute := OnExecute;
end;

{==============================================================================}
destructor TMyLapsP3FakeDecoder.Destroy;
begin
  Stop;
  FreeAndNil(FServer);
  FreeAndNil(FParser);
  FreeAndNil(FLock);
  inherited Destroy;
end;

{==============================================================================}
function TMyLapsP3FakeDecoder.GetActive: Boolean;
begin
  Result := (FServer <> nil) and FServer.Active;
end;

{==============================================================================}
function TMyLapsP3FakeDecoder.GetHasClient: Boolean;
begin
  FLock.Enter;
  try
    Result := FClientCount > 0;
  finally
    FLock.Leave;
  end;
end;

{==============================================================================}
procedure TMyLapsP3FakeDecoder.Start(APort: Word);
begin
  if GetActive then
    Exit;

  FServer.Bindings.Clear;
  with FServer.Bindings.Add do
  begin
    IP := '127.0.0.1';
    Port := APort;
  end;
  FServer.Active := True;
end;

{==============================================================================}
procedure TMyLapsP3FakeDecoder.Stop;
begin
  if FServer = nil then
    Exit;
  try
    if FServer.Active then
      FServer.Active := False;
  except
    // ignore shutdown races
  end;
  FServer.Bindings.Clear;
  FLock.Enter;
  try
    FClientCount := 0;
  finally
    FLock.Leave;
  end;
end;

{==============================================================================}
procedure TMyLapsP3FakeDecoder.OnConnect(AContext: TIdContext);
begin
  FLock.Enter;
  try
    Inc(FClientCount);
  finally
    FLock.Leave;
  end;
end;

{==============================================================================}
procedure TMyLapsP3FakeDecoder.OnDisconnect(AContext: TIdContext);
begin
  FLock.Enter;
  try
    if FClientCount > 0 then
      Dec(FClientCount);
  finally
    FLock.Leave;
  end;
end;

{==============================================================================}
procedure TMyLapsP3FakeDecoder.OnExecute(AContext: TIdContext);
begin
  (* Keep the listener socket alive; ignore resend/RTC queries for the simulator. *)
  if AContext.Connection.IOHandler.InputBufferIsEmpty then
  begin
    AContext.Connection.IOHandler.CheckForDataOnSource(100);
    AContext.Connection.IOHandler.CheckForDisconnect;
  end
  else
    AContext.Connection.IOHandler.InputBuffer.Clear;
end;

{==============================================================================}
function TMyLapsP3FakeDecoder.HexToBytes(const AHex: string): TIdBytes;
var
  i, l: Integer;
  s: string;
begin
  l := Length(AHex) div 2;
  SetLength(Result, l);
  for i := 0 to l - 1 do
  begin
    s := MidStr(AHex, 2 * i + 1, 2);
    Result[i] := StrToInt('$' + s);
  end;
end;

{==============================================================================}
function TMyLapsP3FakeDecoder.WaitForClient(ATimeoutMs: Integer): Boolean;
var
  lElapsed: Integer;
begin
  lElapsed := 0;
  while (not GetHasClient) and (lElapsed < ATimeoutMs) do
  begin
    Sleep(50);
    Inc(lElapsed, 50);
  end;
  Result := GetHasClient;
end;

{==============================================================================}
procedure TMyLapsP3FakeDecoder.SendPassing(const APassing: TPassing);
var
  lPhrase: string;
  lBytes: TIdBytes;
  lList: TList;
  i: Integer;
  lContext: TIdContext;
begin
  if not GetActive then
    raise Exception.Create('MyLaps P3 fake decoder is not running.');

  lPhrase := FParser.GetPassingPhrase(APassing);
  lBytes := HexToBytes(lPhrase);

  lList := FServer.Contexts.LockList;
  try
    if lList.Count = 0 then
      raise Exception.Create('MyLaps P3 fake decoder has no connected listener.');

    for i := 0 to lList.Count - 1 do
    begin
      lContext := TIdContext(lList[i]);
      if (lContext <> nil) and lContext.Connection.Connected then
        lContext.Connection.IOHandler.Write(lBytes);
    end;
  finally
    FServer.Contexts.UnlockList;
  end;
end;

end.
