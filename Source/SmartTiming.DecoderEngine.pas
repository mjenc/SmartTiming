unit SmartTiming.DecoderEngine;

interface

uses
  Classes, SysUtils, StrUtils, Generics.Collections,
  DateUtils, SyncObjs,
  IdTCPConnection, IdTCPClient, IdBaseComponent, IdComponent,
  IdCustomTCPServer, IdTCPServer, IdUdpServer,
  IdGlobal, IdSocketHandle,
  DecoderInterface, SmartTiming.Cache, SmartTiming.Tools;

type
  TDecoderEngine = class
  private
    FDecoder: TDecoder;
    FSearchListener: TDecoderListener;
    FListener: TDecoderListener;
    FTimingBias: integer;
    FDecoderFinder: TDecoderFinder;
    FDecoderFoundCount: integer;
    FNewStatusReceived: TDecoderStatusReceivedEvent;
    FNewPassingReceived: TDecoderPassingReceivedEvent;
    FOnDecoderFound: TDecoderFoundEvent;

  protected
    procedure OnStatusReceived(AStatus: TDecoderStatus);
    procedure OnPassingReceived(APassing: TPassing);
    procedure DecoderFound(ADecoder: TDecoder);
    function GetIsConnected: boolean;
    procedure SetActiveDecoder(ADecoder: TDecoder);
    constructor Create; reintroduce;

  public
    class function GetSingleton: TDecoderEngine;
    destructor Destroy; override;
    procedure RefreshDecoderList;
    procedure SendSimulatedPassing(APassing: TPassing);
    property Connected: boolean read GetIsConnected;
    property ActiveDecoder: TDecoder read FDecoder write SetActiveDecoder;
    property NewStatusReceived: TDecoderStatusReceivedEvent read FNewStatusReceived write FNewStatusReceived;
    property NewPassingReceived: TDecoderPassingReceivedEvent read FNewPassingReceived write FNewPassingReceived;
    property OnDecoderFound: TDecoderFoundEvent read FOnDecoderFound write FOnDecoderFound;
  end;

implementation

var
  gCriticalSection: TCriticalSection;
  gTheDecoderEngine: TDecoderEngine;

{==============================================================================}
class function TDecoderEngine.GetSingleton: TDecoderEngine;
begin
  gCriticalSection.Enter;
  try
    if gTheDecoderEngine <> nil then
      Exit(gTheDecoderEngine);
    gTheDecoderEngine := Create;
    Exit(gTheDecoderEngine);
  finally
    gCriticalSection.Leave;
  end;
end;

{==============================================================================}
constructor TDecoderEngine.Create;
begin
  FTimingBias := SmartTimingTools.ReadTimingBiasFromRegistry;

  FListener := nil;
  FSearchListener := nil;
  FDecoderFoundCount := 0;
  FDecoderFinder := TDecoderFinder.Create(DecoderFound);
end;


{==============================================================================}
destructor TDecoderEngine.Destroy;
begin
  try
    FreeAndNil(FDecoderFinder);
    if FSearchListener <> nil then
    begin
      FSearchListener.Terminate;
      FreeAndNil(FSearchListener);
    end;

    if FListener <> nil then
    begin
      FListener.Terminate;
      FreeAndNil(FListener);
    end;
  finally
    inherited Destroy;
  end;
end;

{==============================================================================}
procedure TDecoderEngine.RefreshDecoderList;
begin
  FDecoderFinder.Refresh;
  Sleep(500);
end;

{==============================================================================}
procedure TDecoderEngine.SetActiveDecoder(ADecoder: TDecoder);
begin
  if FSearchListener <> nil then
  begin
    FSearchListener.Terminate;
    while not FSearchListener.CheckTerminated do
      Sleep(100);
    FreeAndNil(FSearchListener);
  end;

  FDecoder := ADecoder;

  FListener := TDecoderListener.GetListenerForDecoder(FDecoder, OnStatusReceived, OnPassingReceived);
  FListener.Start;
end;

{==============================================================================}
function TDecoderEngine.GetIsConnected: boolean;
begin
  if FListener = nil then
    Exit(false);
  result := FListener.Started;
end;

{==============================================================================}
procedure TDecoderEngine.OnStatusReceived(AStatus: TDecoderStatus);
begin
  TStatusStore.GetSingleton.AddStatus(AStatus);
  if Assigned(FNewStatusReceived) then
    FNewStatusReceived(AStatus);
end;

{==============================================================================}
procedure TDecoderEngine.OnPassingReceived(APassing: TPassing);
begin
  APassing.TxId := TTransponderMappingStore.GetSingleton.GetShortIdFromTransponderId(APassing.ChipId);
  APassing.PassingTime.AddSecond(FTimingBias);
  TPassingStore.GetSingleton.AddPassing(APassing);
  if Assigned(FNewPassingReceived) then
    FNewPassingReceived(APassing);
end;

{==============================================================================}
procedure TDecoderEngine.SendSimulatedPassing(APassing: TPassing);
begin
  OnPassingReceived(APassing);
end;

{==============================================================================}
procedure TDecoderEngine.DecoderFound(ADecoder: TDecoder);
begin
  FDecoderFoundCount := TDecoderStore.GetSingleton.AddDecoder(ADecoder);
  SetActiveDecoder(ADecoder);
  if Assigned(FOnDecoderFound) then
    FOnDecoderFound(ADecoder);
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
