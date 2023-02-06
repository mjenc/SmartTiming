unit SmartTiming.Cache;

interface

uses
  Classes, Generics.Collections, SysUtils, Math, Variants, SyncObjs,
  Windows,
  DecoderInterface, SmartTiming.Consts;

type
  TSynchronizedObject = class
  protected
    //Synchronizer: TLightweightMREW;
    Synchronizer: TMultiReadExclusiveWriteSynchronizer;
    constructor Create; reintroduce; virtual;
  public
    destructor Destroy; override;
  end;

  TPassingStore = class(TSynchronizedObject)
  private
    FPassingList: TDictionary<integer, TPassing>;
    FMaxPassingNumber: integer;
  protected
    constructor Create; override;
  public
    class function GetSingleton : TPassingStore;
    destructor Destroy; override;

    procedure AddPassing(APassing: TPassing);
    procedure FillPassingListFrom(AStartPassingNumber: integer; AList: TDictionary<integer,TPassing>; AFilterOnTransponderIDs: TList<integer> = nil);
    property MaxPassingNumber: integer read FMaxPassingNumber;
  end;

  TStatusStore = class(TSynchronizedObject)
  private
    FStatusList: TList<TDecoderStatus>;
  protected
    constructor Create; override;
  public
    class function GetSingleton : TStatusStore;
    destructor Destroy; override;

    procedure AddStatus(AStatus: TDecoderStatus);
  end;

  TDecoderStore = class(TSynchronizedObject)
  private
    FDecoderList: TDictionary<string,TDecoder>;
  protected
    constructor Create; override;
    function GetCount: integer;
  public
    class function GetSingleton : TDecoderStore;
    destructor Destroy; override;

    function AddDecoder(ADecoder: TDecoder): integer;
    procedure FillDecoderList(AList: TList<TDecoder>);
    function GetFirstDecoder: TDecoder;

    property Count: integer read GetCount;
  end;

  TTransponderMappingStore = class(TSynchronizedObject)
  private
    FTxIdToShortId: TDictionary<string, integer>;
    FShortIdToTxId: TDictionary<integer, string>;
    FLockingThreadId: integer;

  protected
    constructor Create; override;
    function GetTxIdToShortId: TDictionary<string, integer>;
    function GetShortIdToTxId: TDictionary<integer, string>;
  public
    class function GetSingleton: TTransponderMappingStore;
    destructor Destroy; override;
    procedure Clear;

    procedure AddTransponder(AShortId: integer; const ATransponderId: string);
    procedure SetLowBatteryStatus(AShortId: integer; AStatus: boolean);
    function GetShortIdFromTransponderId(const ATransponderId: string): integer;
    function GetTransponderIdFromShortId(AShortId: integer): string;

    procedure Lock;
    procedure Unlock;

    property TxIdToShortId: TDictionary<string, integer> read GetTxIdToShortId;
    property ShortIdToTxId: TDictionary<integer, string> read GetShortIdToTxId;
  end;

implementation

var
  gPassingStore: TPassingStore;
  gStatusStore: TStatusStore;
  gDecoderStore: TDecoderStore;
  gMappingStore: TTransponderMappingStore;

  gCriticalSection: TCriticalSection;


{==============================================================================}
constructor TSynchronizedObject.Create;
begin
  inherited Create;
  Synchronizer := TMultiReadExclusiveWriteSynchronizer.Create;
end;

{==============================================================================}
destructor TSynchronizedObject.Destroy;
begin
  try
    FreeAndNil(Synchronizer);
  finally
    inherited Destroy;
  end;
end;

{==============================================================================}
constructor TPassingStore.Create;
begin
  inherited Create;
  FPassingList := TDictionary<integer, TPassing>.Create;
  FMaxPassingNumber := 0;
end;

{==============================================================================}
class function TPassingStore.GetSingleton : TPassingStore;
begin
  if gPassingStore = nil then
  begin
    gCriticalSection.Enter;
    try
      if gPassingStore = nil then
        gPassingStore := TPassingStore.Create;
    finally
      gCriticalSection.Leave;
    end;
  end;
  Result := gPassingStore;
end;

{==============================================================================}
destructor TPassingStore.Destroy;
begin
  try
    FreeAndNil(FPassingList);
  finally
    inherited Destroy;
  end;
end;

{==============================================================================}
procedure TPassingStore.AddPassing(APassing: TPassing);
begin
  Synchronizer.BeginWrite;
  try
    FPassingList.AddOrSetValue(APassing.PassingNumber, APassing);
    FMaxPassingNumber := Max(APassing.PassingNumber, FMaxPassingNumber);
  finally
    Synchronizer.EndWrite;
  end;
end;

{==============================================================================}
procedure TPassingStore.FillPassingListFrom(AStartPassingNumber: integer; AList: TDictionary<integer,TPassing>; AFilterOnTransponderIDs: TList<integer> = nil);
var
  lPassingNumber: integer;
  lPassing: TPassing;
begin
  lPassingNumber := AStartPassingNumber;

  Synchronizer.BeginWrite;
  try
    while (lPassingNumber <= FMaxPassingNumber) do
    begin
      if FPassingList.TryGetValue(lPassingNumber, lPassing) then
      begin
        if (AFilterOnTransponderIDs = nil) or AFilterOnTransponderIDs.Contains(lPassing.TxId) then
          AList.Add(lPassingNumber, lPassing);
      end;
// TODO Durchgänge wurden nicht gespeichert
//      else

      Inc(lPassingNumber);
    end;
  finally
    Synchronizer.EndWrite;
  end;
end;

{==============================================================================}
constructor TStatusStore.Create;
begin
  inherited Create;
  FStatusList := TList<TDecoderStatus>.Create;
end;

{==============================================================================}
class function TStatusStore.GetSingleton : TStatusStore;
begin
  gCriticalSection.Enter;
  try
    if gStatusStore = nil then
      gStatusStore := TStatusStore.Create;
  finally
    gCriticalSection.Leave;
  end;
  Result := gStatusStore;
end;

{==============================================================================}
destructor TStatusStore.Destroy;
begin
  try
    FreeAndNil(FStatusList);
  finally
    inherited Destroy;
  end;
end;

{==============================================================================}
procedure TStatusStore.AddStatus(AStatus: TDecoderStatus);
begin
  Synchronizer.BeginWrite;
  try
    FStatusList.Add(AStatus);
  finally
    Synchronizer.EndWrite;
  end;
end;

{==============================================================================}
constructor TDecoderStore.Create;
begin
  inherited Create;
  FDecoderList := TDictionary<string,TDecoder>.Create;
end;

{==============================================================================}
class function TDecoderStore.GetSingleton : TDecoderStore;
begin
  gCriticalSection.Enter;
  try
    if gDecoderStore = nil then
      gDecoderStore := TDecoderStore.Create;
  finally
    gCriticalSection.Leave;
  end;
  result := gDecoderStore;
end;

{==============================================================================}
destructor TDecoderStore.Destroy;
begin
  try
    FreeAndNil(FDecoderList);
  finally
    inherited Destroy;
  end;
end;

{==============================================================================}
function TDecoderStore.AddDecoder(ADecoder: TDecoder): integer;
begin
  Synchronizer.BeginWrite;
  try
    if FDecoderList.ContainsKey(ADecoder.Address) then
      Exit(FDecoderList.Count);
    FDecoderList.Add(ADecoder.Address, ADecoder);
    result := FDecoderList.Count;
  finally
    Synchronizer.EndWrite;
  end;
end;

{==============================================================================}
function TDecoderStore.GetCount: integer;
begin
  Synchronizer.BeginRead;
  try
    result := FDecoderList.Count;
  finally
    Synchronizer.EndRead;
  end;

end;

{==============================================================================}
function TDecoderStore.GetFirstDecoder: TDecoder;
var
  lDecoder: TDecoder;
begin
  Synchronizer.BeginRead;
  try
    for lDecoder in FDecoderList.Values do
    begin
      if not lDecoder.Address.IsEmpty then
        Exit(lDecoder);
    end;
  finally
    Synchronizer.EndRead;
  end;
end;

{==============================================================================}
procedure TDecoderStore.FillDecoderList(AList: TList<TDecoder>);
var
  lDecoder: TDecoder;
begin
  Synchronizer.BeginRead;
  try
    for lDecoder in FDecoderList.Values do
      AList.Add(LDecoder);
  finally
    Synchronizer.EndRead;
  end;
end;

{==============================================================================}
constructor TTransponderMappingStore.Create;
begin
  inherited Create;
  FLockingThreadId := 0;
  FTxIdToShortId := TDictionary<string, integer>.Create;
  FShortIdToTxId := TDictionary<integer, string>.Create;
end;

{==============================================================================}
class function TTransponderMappingStore.GetSingleton : TTransponderMappingStore;
begin
  gCriticalSection.Enter;
  try
    if gMappingStore = nil then
      gMappingStore := TTransponderMappingStore.Create;
  finally
    gCriticalSection.Leave;
  end;
  Result := gMappingStore;
end;

{==============================================================================}
procedure TTransponderMappingStore.Lock;
begin
  Synchronizer.BeginWrite;
  FLockingThreadId := GetCurrentThreadId;
end;

{==============================================================================}
procedure TTransponderMappingStore.Unlock;
begin
  Synchronizer.EndWrite;
  FLockingThreadId := 0;
end;

{==============================================================================}
function TTransponderMappingStore.GetTxIdToShortId: TDictionary<string, integer>;
begin
  if FLockingThreadId <> GetCurrentThreadId then
    raise Exception.Create('TransponderMappingList has not been locked before calling GetTxIdToShortId');
  result := FTxIdToShortId;
end;

{==============================================================================}
function TTransponderMappingStore.GetShortIdToTxId: TDictionary<integer, string>;
begin
  if FLockingThreadId <> GetCurrentThreadId then
    raise Exception.Create('TransponderMappingList has not been locked before calling GetShortIdToTxId');
  result := FShortIdToTxId;
end;

{==============================================================================}
destructor TTransponderMappingStore.Destroy;
begin
  try
    FreeAndNil(FTxIdToShortId);
    FreeAndNil(FShortIdToTxId);
  finally
    inherited Destroy;
  end;
end;

{==============================================================================}
procedure TTransponderMappingStore.Clear;
begin
  Synchronizer.BeginWrite;
  try
    FTxIdToShortId.Clear;
    FShortIdToTxId.Clear;
  finally
    Synchronizer.EndWrite;
  end;
end;

{==============================================================================}
procedure TTransponderMappingStore.AddTransponder(AShortId: integer; const ATransponderId: string);
begin
  Synchronizer.BeginWrite;
  try
    FTxIdToShortId.Add(ATransponderId, AShortId);
    FShortIdToTxId.Add(AShortId, ATransponderId);
  finally
    Synchronizer.EndWrite;
  end;
end;

{==============================================================================}
procedure TTransponderMappingStore.SetLowBatteryStatus(AShortId: integer; AStatus: boolean);
begin
  // TODO
end;

{==============================================================================}
function TTransponderMappingStore.GetShortIdFromTransponderId(const ATransponderId: string): integer;
begin
  Synchronizer.BeginRead;
  try
    if not FTxIdToShortId.TryGetValue(ATransponderId.Trim, result) then
      result := -1;
  finally
    Synchronizer.EndRead;
  end;
end;

{==============================================================================}
function TTransponderMappingStore.GetTransponderIdFromShortId(AShortId: integer): string;
begin
  Synchronizer.BeginRead;
  try
    if not FShortIdToTxId.TryGetValue(AShortId, result) then
      Exit(cNotFound);
  finally
    Synchronizer.EndRead;
  end;
end;

initialization
  gCriticalSection := TCriticalSection.Create;
  gPassingStore := nil;
  gStatusStore := nil;
  gDecoderStore := nil;
  gMappingStore := nil;

finalization
  try
    FreeAndNil(gDecoderStore);
    FreeAndNil(gPassingStore);
    FreeAndNil(gStatusStore);
    FreeAndNil(gMappingStore);

    gCriticalSection.Free;
  except
  end;
end.
