unit DecoderInterface;

interface

uses
  Classes, SysUtils, StrUtils,
  IdTCPConnection, IdTCPClient, IdBaseComponent, IdComponent, IdCustomTCPServer, IdTCPServer, IdUdpServer,
  IdGlobal, IdSocketHandle;

const
  cDecoderManufacturerMyLaps = 'MyLaps';
  cDecoderManufacturerRaceResult = 'RaceResult';

type
  TPassing = record
    PassingNumber: integer;
    ChipId: string;
    TxId: integer;
    PassingTime: TDateTime;
    SignalStrength: integer;
    Hits: integer;
    Flags: integer;
    Sport: byte;
    Voltage: Double;
    Temperature: integer;
    DecoderId: string;
    RaceId: integer;
    (* Ord(TPassingState): 0 = valid, 1 = invalid (Plan 4). *)
    PassingStatus: integer;
    (* Plan 3: in-memory domain fields (not persisted). -1 = unset / none. *)
    LapIndex: integer;
    CompetitorId: integer;
    function ToString: string;
    function IsManual: Boolean;
    function IsSystemMarker: Boolean;
    (* Warm-Up flag (F4 / rsWarmUp): activates capture — time must not be moved. *)
    function IsWarmUpFlag: Boolean;
  end;

  TDecoderStatus = record
    Noise: integer;
    Gps: boolean;
    Temperature: double;
    InputVoltage: double;
    DecoderId: string;
  end;

  TDecoder = record
    DecoderId: string;
    DecoderManufacturer: string;
    Address: string;
    FirmwareVersion: string;
    DecoderType: string;
  end;

  TDecoderStatusReceivedEvent = procedure (Status: TDecoderStatus) of object;
  TDecoderPassingReceivedEvent = procedure (Passing: TPassing) of object;
  TDecoderFoundEvent = procedure (ADecoder: TDecoder) of object;

  TDecoderListener = class (TThread)
  protected
    FDecoder: TDecoder;
    FServerPort: Word;
    FOnStatus: TDecoderStatusReceivedEvent;
    FOnPassing: TDecoderPassingReceivedEvent;
    function GetConnected: Boolean; virtual;
    procedure UnblockIO; virtual;

  public
    constructor Create(ADecoder: TDecoder; AOnStatus: TDecoderStatusReceivedEvent; AOnPassing: TDecoderPassingReceivedEvent); reintroduce;

    class function GetListenerForDecoder(ADecoder: TDecoder; AOnStatus: TDecoderStatusReceivedEvent; AOnPassing: TDecoderPassingReceivedEvent): TDecoderListener;

    /// <summary>Terminate, unblock I/O, wait until the worker thread has finished.</summary>
    procedure StopAndWait; virtual;

    property ActiveDecoder: TDecoder read FDecoder;
    property Connected: Boolean read GetConnected;
  end;

  TDecoderFinder = class
  private
    FOnDecoderFound: TDecoderFoundEvent;
    FMyLapsFinder: TDecoderFinder;
    FRaceResultFinder: TDecoderFinder;
    FSearchRaceResult: Boolean;
    procedure SetSearchRaceResult(AValue: Boolean);
    procedure EnsureRaceResultFinder;
  public
    constructor Create(AOnDecoderFound: TDecoderFoundEvent); virtual;
    destructor Destroy; override;
    procedure Refresh; virtual;
    /// <summary>When False (default), only MyLaps is searched. Enable to include RaceResult/Ubidium bridge.</summary>
    property SearchRaceResult: Boolean read FSearchRaceResult write SetSearchRaceResult;
  end;

implementation

uses
  DecoderInterface.MyLaps,
  DecoderInterface.RaceResult;

{==============================================================================}
function TPassing.ToString: string;
begin
  result := Format('Passing# %d, TxId: %s, TxShortId: %d, Timestamp: %s, Signal: %d, Hits: %d, Flags: %d, Sport: %d, DecoderId: %s',
    [PassingNumber, ChipId,TxId, DatetimeToStr(PassingTime), SignalStrength,Hits,Flags,Sport,DecoderId]);
end;

{==============================================================================}
function TPassing.IsManual: Boolean;
begin
  Result := SameText(DecoderId, 'MANUAL');
end;

{==============================================================================}
function TPassing.IsSystemMarker: Boolean;
begin
  Result := ((Flags and 2) = 2) or SameText(DecoderId, 'SYSTEM');
end;

{==============================================================================}
function TPassing.IsWarmUpFlag: Boolean;
begin
  (* Hits = -Ord(rsWarmUp); Ord(rsWarmUp)=1 — keep in sync with TRaceStatus. *)
  Result := IsSystemMarker and (Hits = -1);
end;

{==============================================================================}
constructor TDecoderListener.Create(ADecoder: TDecoder; AOnStatus: TDecoderStatusReceivedEvent; AOnPassing: TDecoderPassingReceivedEvent);
begin
  inherited Create(true);
  FDecoder := ADecoder;
  FOnStatus := AOnStatus;
  FOnPassing := AOnPassing;
end;

{==============================================================================}
function TDecoderListener.GetConnected: Boolean;
begin
  Result := Started and not CheckTerminated;
end;

{==============================================================================}
procedure TDecoderListener.UnblockIO;
begin
  // descendants disconnect sockets / close handles
end;

{==============================================================================}
procedure TDecoderListener.StopAndWait;
begin
  if Finished then
    Exit;

  Terminate;
  UnblockIO;
  if Started then
    WaitFor;
end;

{==============================================================================}
class function TDecoderListener.GetListenerForDecoder(ADecoder: TDecoder; AOnStatus: TDecoderStatusReceivedEvent; AOnPassing: TDecoderPassingReceivedEvent): TDecoderListener;
begin
  if ADecoder.DecoderManufacturer = cDecoderManufacturerMyLaps then
    Exit(TMyLapsP3Listener.Create(ADecoder, AOnStatus, AOnPassing));

  if ADecoder.DecoderManufacturer = cDecoderManufacturerRaceResult then
    Exit(TUbidiumListener.Create(ADecoder, AOnStatus, AOnPassing));

  raise Exception.Create('No listener found for decoder.')
end;

{==============================================================================}
constructor TDecoderFinder.Create(AOnDecoderFound: TDecoderFoundEvent);
begin
  FOnDecoderFound := AOnDecoderFound;
  FSearchRaceResult := False;
  FMyLapsFinder := TMyLapsDecoderFinder.Create(AOnDecoderFound);
  FRaceResultFinder := nil;
end;

{==============================================================================}
destructor TDecoderFinder.Destroy;
begin
  try
    FreeAndNil(FMyLapsFinder);
    FreeAndNil(FRaceResultFinder);
  finally
    inherited;
  end;
end;

{==============================================================================}
procedure TDecoderFinder.EnsureRaceResultFinder;
begin
  if FRaceResultFinder = nil then
    FRaceResultFinder := TUbidiumDecoderFinder.Create(FOnDecoderFound);
end;

{==============================================================================}
procedure TDecoderFinder.SetSearchRaceResult(AValue: Boolean);
begin
  if FSearchRaceResult = AValue then
    Exit;
  FSearchRaceResult := AValue;
  if FSearchRaceResult then
    EnsureRaceResultFinder;
end;

{==============================================================================}
procedure TDecoderFinder.Refresh;
begin
  if FMyLapsFinder <> nil then
    FMyLapsFinder.Refresh;
  if FSearchRaceResult then
  begin
    EnsureRaceResultFinder;
    FRaceResultFinder.Refresh;
  end;
end;


end.
