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

uses
  Tools.Logger;

const
  cLogger = 'SmartTiming.DecoderEngine';
  cLoggerStatus = cLogger + '.Status';
  cLoggerPassing = cLogger + '.Passing';

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
  LogOnDebug(cLogger, ['Creating DecoderEngine']);
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
    LogOnDebug(cLogger, ['Destroying DecoderEngine']);
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
  try
    LogOnDebug(cLogger, ['RefreshDecoderList']);
    FDecoderFinder.Refresh;
    Sleep(500);
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['RefreshDecoderList']);
  end;
end;

{==============================================================================}
procedure TDecoderEngine.SetActiveDecoder(ADecoder: TDecoder);
begin
  try
    LogOnDebug(cLogger, ['SetActiveDecoder', ADecoder.DecoderManufacturer, ADecoder.DecoderId, ADecoder.Address]);
    if FSearchListener <> nil then
    begin
      FSearchListener.StopAndWait;
      FreeAndNil(FSearchListener);
    end;

    if FListener <> nil then
    begin
      FListener.StopAndWait;
      FreeAndNil(FListener);
    end;

    FDecoder := ADecoder;

    FListener := TDecoderListener.GetListenerForDecoder(FDecoder, OnStatusReceived, OnPassingReceived);
    FListener.Start;
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['SetActiveDecoder']);
  end;
end;

{==============================================================================}
function TDecoderEngine.GetIsConnected: boolean;
begin
  result := false;
  try
    LogOnDebug(cLogger, ['GetIsConnected']);
    if FListener = nil then
    begin
      LogOnDebug(cLogger, ['No listener.']);
      Exit(false);
    end;
    result := FListener.Started;
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['GetIsConnected']);
  end;
end;

{==============================================================================}
procedure TDecoderEngine.OnStatusReceived(AStatus: TDecoderStatus);
begin
  try
    LogOnDebug(cLoggerStatus, ['OnStatusReceived']);
    TStatusStore.GetSingleton.AddStatus(AStatus);
    if Assigned(FNewStatusReceived) then
      FNewStatusReceived(AStatus);
  except
    LogAndRaise(ExceptObject, cLoggerStatus, Tools.Logger.Error, ['OnStatusReceived']);
  end;
end;

{==============================================================================}
procedure TDecoderEngine.OnPassingReceived(APassing: TPassing);
begin
  try
    LogOnDebug(cLoggerPassing, ['OnPassingReceived']);
    APassing.TxId := TTransponderMappingStore.GetSingleton.GetShortIdFromTransponderId(APassing.ChipId);
    (* Operator-entered wall time must not get decoder timing bias. *)
    if not SameText(APassing.DecoderId, 'MANUAL') then
      APassing.PassingTime.AddSecond(FTimingBias);
    APassing.LapIndex := -1;
    APassing.CompetitorId := -1;
    TPassingStore.GetSingleton.AddPassing(APassing);
    if Assigned(FNewPassingReceived) then
      FNewPassingReceived(APassing);
  except
    LogAndRaise(ExceptObject, cLoggerPassing, Tools.Logger.Error, ['OnPassingReceived']);
  end;
end;

{==============================================================================}
procedure TDecoderEngine.SendSimulatedPassing(APassing: TPassing);
begin
  try
    LogOnDebug(cLoggerPassing, ['SendSimulatedPassing']);
    OnPassingReceived(APassing);
  except
    LogAndRaise(ExceptObject, cLoggerPassing, Tools.Logger.Error, ['SendSimulatedPassing']);
  end;
end;

{==============================================================================}
procedure TDecoderEngine.DecoderFound(ADecoder: TDecoder);
begin
  try
    LogOnDebug(cLogger, ['DecoderFound']);
    FDecoderFoundCount := TDecoderStore.GetSingleton.AddDecoder(ADecoder);
    SetActiveDecoder(ADecoder);
    if Assigned(FOnDecoderFound) then
      FOnDecoderFound(ADecoder);
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['DecoderFound']);
  end;
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
