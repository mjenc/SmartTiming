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
    function ToString: string;
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

  public
    constructor Create(ADecoder: TDecoder; AServerPort: Word); reintroduce;

    class function GetListenerForDecoder(ADecoder: TDecoder): TDecoderListener;

    property ActiveDecoder: TDecoder read FDecoder;
    property OnStatusReceived: TDecoderStatusReceivedEvent read FOnStatus write FOnStatus;
    property OnPassingReceived: TDecoderPassingReceivedEvent read FOnPassing write FOnPassing;
  end;

  TDecoderFinder = class
  private
    FOnDecoderFound: TDecoderFoundEvent;
    FMyLapsFinder: TDecoderFinder;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    property OnDecoderFound: TDecoderFoundEvent read FOnDecoderFound write FOnDecoderFound;
    procedure Refresh; virtual;
  end;

implementation

uses
  DecoderInterface.MyLaps;

{==============================================================================}
function TPassing.ToString: string;
begin
  result := Format('Passing# %d, TxId: %s, TxShortId: %d, Timestamp: %s, Signal: %d, Hits: %d, Flags: %d, Sport: %d, DecoderId: %s',
    [PassingNumber, ChipId,TxId, DatetimeToStr(PassingTime), SignalStrength,Hits,Flags,Sport,DecoderId]);
end;

{==============================================================================}
constructor TDecoderListener.Create(ADecoder: TDecoder; AServerPort: Word);
begin
  inherited Create(true);
  FDecoder := ADecoder;
  FServerPort := AServerPort;
end;

{==============================================================================}
class function TDecoderListener.GetListenerForDecoder(ADecoder: TDecoder): TDecoderListener;
begin
  if ADecoder.DecoderManufacturer = cDecoderManufacturerMyLaps then
    Exit(TMyLapsP3Listener.Create(ADecoder, cMyLapsDefaultOperatingPort));

// TODO
//  if ADecoder.DecoderManufacturer = cDecoderManufacturerRaceResult then
//    Exit(TRaceResultListener.Create(ADecoder, cMyLapsDefaultOperatingPort));

  raise Exception.Create('No listener found for decoder.')
end;

{==============================================================================}
constructor TDecoderFinder.Create;
begin
  inherited;
  FOnDecoderFound := nil;

  // MyLaps
  FMyLapsFinder := TMyLapsDecoderFinder.Create;

  // TODO RaceResult
// FRaceResultFinder := TRaceResultDecoderFinder.Create;
end;

{==============================================================================}
destructor TDecoderFinder.Destroy;
begin
  try
    FreeAndNil(FMyLapsFinder);
  finally
    inherited;
  end;
end;

{==============================================================================}
procedure TDecoderFinder.Refresh;
begin
  FMyLapsFinder.Refresh;
end;


end.
