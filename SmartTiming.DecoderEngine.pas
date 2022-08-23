unit SmartTiming.DecoderEngine;

interface

uses
  Classes, SysUtils, StrUtils, ComCtrls, StdCtrls, ExtCtrls, Generics.Collections,
  DateUtils, SyncObjs,
  IdTCPConnection, IdTCPClient, IdBaseComponent, IdComponent,
  IdCustomTCPServer, IdTCPServer, IdUdpServer,
  IdGlobal, IdSocketHandle,
  SmartTiming.DecoderInterface, SmartTiming.Cache, SmartTiming.Tools;

type
  TMyLapsDecoderEngine = class
  private
    FDecoder: TMyLapsP3Decoder;
    FListener: TMyLapsP3Listener;
    FMessageParser: TMyLapsP3MessageParser;
    FTimingBias: integer;
    FDecoderFinder: TMyLapsDecoderFinder;
    FDecoderFoundCount: integer;
    FNewStatusReceived: TDecoderStatusReceivedEvent;
    FNewPassingReceived: TDecoderPassingReceivedEvent;

  protected
    procedure OnStatusReceived(AStatus: TMyLapsP3Status);
    procedure OnPassingReceived(APassing: TMyLapsP3Passing);
    procedure OnDecoderFound(ADecoder: TMyLapsP3Decoder);
    function GetIsConnected: boolean;
    procedure SetActiveDecoder(ADecoder: TMyLapsP3Decoder);
    constructor Create(const ADatabaseName: string); reintroduce;

  public
    class function GetSingleton: TMyLapsDecoderEngine;
    destructor Destroy; override;
    procedure RefreshDecoderList;
    procedure SendSimulatedPassing(APassing: TMyLapsP3Passing);
    property Connected: boolean read GetIsConnected;
    property ActiveDecoder: TMyLapsP3Decoder read FDecoder write SetActiveDecoder;
    property NewStatusReceived: TDecoderStatusReceivedEvent read FNewStatusReceived write FNewStatusReceived;
    property NewPassingReceived: TDecoderPassingReceivedEvent read FNewPassingReceived write FNewPassingReceived;
  end;

implementation

var
  gCriticalSection: TCriticalSection;
  gTheDecoderEngine: TMyLapsDecoderEngine;

{==============================================================================}
class function TMyLapsDecoderEngine.GetSingleton: TMyLapsDecoderEngine;
begin
  gCriticalSection.Enter;
  try
    if gTheDecoderEngine <> nil then
      Exit(gTheDecoderEngine);
    gTheDecoderEngine := Create('Temp.db');
    Exit(gTheDecoderEngine);
  finally
    gCriticalSection.Leave;
  end;
end;

{==============================================================================}
constructor TMyLapsDecoderEngine.Create(const ADatabaseName: string);
begin
  FMessageParser := TMyLapsP3MessageParser.Create;
  FMessageParser.OnStatusReceived := OnStatusReceived;
  FMessageParser.OnPassingReceived := OnPassingReceived;

  FTimingBias := SmartTimingTools.ReadTimingBiasFromRegistry;

  FListener := nil;
  FDecoderFoundCount := 0;
  FDecoderFinder := TMyLapsDecoderFinder.Create;
  FDecoderFinder.OnDecoderFound := OnDecoderFound;
  RefreshDecoderList;
end;


{==============================================================================}
destructor TMyLapsDecoderEngine.Destroy;
begin
  try
    FreeAndNil(FDecoderFinder);
    if FListener <> nil then
    begin
      FListener.Terminate;
      FreeAndNil(FListener);
    end;
    FreeAndNil(FMessageParser);
  finally
    inherited Destroy;
  end;
end;

{==============================================================================}
procedure TMyLapsDecoderEngine.RefreshDecoderList;
begin
  FDecoderFinder.Update;
  Sleep(500);
end;

{==============================================================================}
procedure TMyLapsDecoderEngine.SetActiveDecoder(ADecoder: TMyLapsP3Decoder);
begin
  if FListener <> nil then
  begin
    FListener.Terminate;
    while not FListener.CheckTerminated do
      Sleep(100);
    FreeAndNil(FListener);
  end;

  FDecoder := ADecoder;
  FListener := TMyLapsP3Listener.Create(FDecoder,5403);
  Flistener.MyLapsP3MessageParser := FMessageParser;
  FListener.Start;
end;

{==============================================================================}
function TMyLapsDecoderEngine.GetIsConnected: boolean;
begin
  if FListener = nil then
    Exit(false);
  result := FListener.Started;
end;

{==============================================================================}
procedure TMyLapsDecoderEngine.OnStatusReceived(AStatus: TMyLapsP3Status);
begin
  TStatusStore.GetSingleton.AddStatus(AStatus);
  if Assigned(FNewStatusReceived) then
    FNewStatusReceived(AStatus);
end;

{==============================================================================}
procedure TMyLapsDecoderEngine.OnPassingReceived(APassing: TMyLapsP3Passing);
begin
  APassing.TransponderShortId := TTransponderMappingStore.GetSingleton.GetShortIdFromTransponderId(APassing.TransponderId);
  APassing.PassingTime.AddSecond(FTimingBias);
  TPassingStore.GetSingleton.AddPassing(APassing);
  if Assigned(FNewPassingReceived) then
    FNewPassingReceived(APassing);
end;

{==============================================================================}
procedure TMyLapsDecoderEngine.SendSimulatedPassing(APassing: TMyLapsP3Passing);
begin
  OnPassingReceived(APassing);
end;

{==============================================================================}
procedure TMyLapsDecoderEngine.OnDecoderFound(ADecoder: TMyLapsP3Decoder);
begin
  FDecoderFoundCount := TDecoderStore.GetSingleton.AddDecoder(ADecoder);
  SetActiveDecoder(ADecoder);
end;


initialization
  gCriticalSection := TCriticalSection.Create;
  gTheDecoderEngine := nil;

finalization
  try
    FreeAndNil(gTheDecoderEngine);
    FreeAndNil(gCriticalSection);
  except
  end;

end.
