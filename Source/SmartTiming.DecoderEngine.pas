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
    FListener: TDecoderListener;
    FTimingBias: integer;
    FDecoderFinder: TDecoderFinder;
    FDecoderFoundCount: integer;
    FNewStatusReceived: TDecoderStatusReceivedEvent;
    FNewPassingReceived: TDecoderPassingReceivedEvent;

  protected
    procedure OnStatusReceived(AStatus: TDecoderStatus);
    procedure OnPassingReceived(APassing: TPassing);
    procedure OnDecoderFound(ADecoder: TDecoder);
    function GetIsConnected: boolean;
    procedure SetActiveDecoder(ADecoder: TDecoder);
    constructor Create(const ADatabaseName: string); reintroduce;

  public
    class function GetSingleton: TDecoderEngine;
    destructor Destroy; override;
    procedure RefreshDecoderList;
    procedure SendSimulatedPassing(APassing: TPassing);
    property Connected: boolean read GetIsConnected;
    property ActiveDecoder: TDecoder read FDecoder write SetActiveDecoder;
    property NewStatusReceived: TDecoderStatusReceivedEvent read FNewStatusReceived write FNewStatusReceived;
    property NewPassingReceived: TDecoderPassingReceivedEvent read FNewPassingReceived write FNewPassingReceived;
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
    gTheDecoderEngine := Create('Temp.db');
    Exit(gTheDecoderEngine);
  finally
    gCriticalSection.Leave;
  end;
end;

{==============================================================================}
constructor TDecoderEngine.Create(const ADatabaseName: string);
begin
  FTimingBias := SmartTimingTools.ReadTimingBiasFromRegistry;

  FListener := nil;
  FDecoderFoundCount := 0;
  FDecoderFinder := TDecoderFinder.Create(OnDecoderFound);
  RefreshDecoderList;
end;


{==============================================================================}
destructor TDecoderEngine.Destroy;
begin
  try
    FreeAndNil(FDecoderFinder);
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
  if FListener <> nil then
  begin
    FListener.Terminate;
    while not FListener.CheckTerminated do
      Sleep(100);
    FreeAndNil(FListener);
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
procedure TDecoderEngine.OnDecoderFound(ADecoder: TDecoder);
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
