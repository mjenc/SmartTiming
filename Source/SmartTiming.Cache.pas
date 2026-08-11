unit SmartTiming.Cache;

interface

uses
  Classes, Generics.Collections, SysUtils, Math, Variants, SyncObjs,
  Windows, System.Character,
  DecoderInterface, SmartTiming.Consts;

(* Canonical chip key for indexes and conflict checks. *)
function NormalizeChipId(const AChipId: string): string;

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
    function GetPassing(APassingId: Integer): TPassing;
    procedure UpdatePassing(APassingNumber: Integer; APassingTime: TDatetime);
    procedure UpdatePassingRaceId(APassingNumber: Integer; ARaceId: Integer);
    procedure UpdatePassingStatus(APassingNumber: Integer; APassingStatus: Integer);
    procedure UpdatePassingDomainFields(APassingNumber: Integer; ALapIndex, ACompetitorId: Integer);
    procedure RemovePassing(APassingNumber: Integer);
    procedure FillPassingListFrom(AStartPassingNumber: integer; AList: TDictionary<integer,TPassing>; AFilterOnTransponderIDs: TList<integer> = nil);
    (* Inclusive range [AStart .. AEnd]; empty if AEnd < AStart. *)
    procedure FillPassingListRange(AStartPassingNumber, AEndPassingNumber: integer;
      AList: TDictionary<integer, TPassing>);
    procedure FillPassingListForRaceId(ARaceId: integer; AList: TDictionary<TDatetime, TPassing>; AOnlyActivePassings, ATimeFractionOnly: Boolean);
    procedure FillPassingsForRace(ARaceId: Integer; AList: TList<TPassing>);
    function GetLastValidPassingTime(ARaceId: Integer; const AChipId: string;
      ABeforeTime: TDateTime): TDateTime;
    (* Last hit for MinLap/DoubleHit — includes invalid/pending so AskOperator blocks the timeline.
       AExcludePassingNumber skips the hit currently being validated (already in the store). *)
    function GetLastPassingTimeForChip(ARaceId: Integer; const AChipId: string;
      ABeforeTime: TDateTime; AExcludePassingNumber: Integer = -1): TDateTime;
    property MaxPassingNumber: integer read FMaxPassingNumber;
  end;

  (* Passings that did not resolve to exactly one race (training / unknown chips). *)
  TUnassignedPassingStore = class(TSynchronizedObject)
  private
    FPassingList: TDictionary<Integer, TPassing>;
  protected
    constructor Create; override;
  public
    class function GetSingleton: TUnassignedPassingStore;
    destructor Destroy; override;
    procedure Clear;
    procedure AddPassing(APassing: TPassing);
    procedure RemovePassing(APassingNumber: Integer);
    function Contains(APassingNumber: Integer): Boolean;
    function Count: Integer;
    procedure FillList(AList: TList<TPassing>);
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
    FLockingThreadId: Cardinal;

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
    function ConvertToValidChipId(var AID: string): boolean;
    function Count: Integer;
    procedure Lock;
    procedure Unlock;

    property TxIdToShortId: TDictionary<string, integer> read GetTxIdToShortId;
    property ShortIdToTxId: TDictionary<integer, string> read GetShortIdToTxId;
  end;

  (* Race-scoped chip assignment. ValidTo = 0 means open (VALIDTO IS NULL in DB). *)
  TTransponderAssignment = record
    AssignmentId: Integer;
    ChipId: string;
    CompetitorId: Integer;
    RaceId: Integer;
    ValidFrom: TDateTime;
    ValidTo: TDateTime;
    function IsOpen: Boolean;
    function CoversTime(ATime: TDateTime): Boolean;
  end;

  TTransponderAssignmentStore = class(TSynchronizedObject)
  private
    FById: TDictionary<Integer, TTransponderAssignment>;
    FActiveByChip: TDictionary<string, Integer>;
    FActiveByRaceCompetitor: TDictionary<string, Integer>;
    class function RaceCompetitorKey(ARaceId, ACompetitorId: Integer): string; static;
    procedure IndexOpenAssignment(const AAssignment: TTransponderAssignment);
    procedure UnindexOpenAssignment(const AAssignment: TTransponderAssignment);
  protected
    constructor Create; override;
  public
    class function GetSingleton: TTransponderAssignmentStore;
    destructor Destroy; override;
    procedure Clear;

    procedure Upsert(const AAssignment: TTransponderAssignment);
    procedure CloseAssignment(AAssignmentId: Integer; AValidTo: TDateTime);
    procedure CloseAssignmentsForCompetitors(ARaceId: Integer;
      const ACompetitorIDs: TArray<Integer>; AValidTo: TDateTime);
    procedure CloseAllOpenForRace(ARaceId: Integer; AValidTo: TDateTime);

    function TryGetById(AAssignmentId: Integer; out AAssignment: TTransponderAssignment): Boolean;
    function TryGetActiveByChip(const AChipId: string; out AAssignment: TTransponderAssignment): Boolean;
    function TryGetActiveByRaceAndCompetitor(ARaceId, ACompetitorId: Integer;
      out AAssignment: TTransponderAssignment): Boolean;
    function FindAssignmentsForChipAtTime(const AChipId: string; APassingTime: TDateTime;
      AList: TList<TTransponderAssignment>): Integer;
    procedure FillAssignmentsForRace(ARaceId: Integer; AList: TList<TTransponderAssignment>;
      AOpenOnly: Boolean = False);
  end;

implementation

var
  gPassingStore: TPassingStore;
  gUnassignedPassingStore: TUnassignedPassingStore;
  gStatusStore: TStatusStore;
  gDecoderStore: TDecoderStore;
  gMappingStore: TTransponderMappingStore;
  gAssignmentStore: TTransponderAssignmentStore;

  gCriticalSection: TCriticalSection;


{==============================================================================}
function NormalizeChipId(const AChipId: string): string;
begin
  Result := AnsiUpperCase(Trim(AChipId));
end;

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
function TPassingStore.GetPassing(APassingId: Integer): TPassing;
begin
  Synchronizer.BeginRead;
  try
    if not FPassingList.TryGetValue(APassingId, result) then
      raise Exception.Create('Internal error Passing not found in Cache');
  finally
    Synchronizer.EndRead;
  end;
end;

{==============================================================================}
procedure TPassingStore.UpdatePassing(APassingNumber: Integer; APassingTime: TDatetime);
var
  lPassing: TPassing;
begin
  Synchronizer.BeginWrite;
  try
    if not FPassingList.TryGetValue(APassingNumber, lPassing) then
      raise Exception.Create('Internal error Passing not found in Cache');
    lPassing.PassingTime := APassingTime;
    FPassingList.AddOrSetValue(APassingNumber, lPassing);
  finally
    Synchronizer.EndWrite;
  end;
end;

{==============================================================================}
procedure TPassingStore.UpdatePassingRaceId(APassingNumber: Integer; ARaceId: Integer);
var
  lPassing: TPassing;
begin
  Synchronizer.BeginWrite;
  try
    if not FPassingList.TryGetValue(APassingNumber, lPassing) then
      Exit;
    lPassing.RaceId := ARaceId;
    FPassingList.AddOrSetValue(APassingNumber, lPassing);
  finally
    Synchronizer.EndWrite;
  end;
end;

{==============================================================================}
procedure TPassingStore.UpdatePassingStatus(APassingNumber: Integer; APassingStatus: Integer);
var
  lPassing: TPassing;
begin
  Synchronizer.BeginWrite;
  try
    if not FPassingList.TryGetValue(APassingNumber, lPassing) then
      Exit;
    lPassing.PassingStatus := APassingStatus;
    FPassingList.AddOrSetValue(APassingNumber, lPassing);
  finally
    Synchronizer.EndWrite;
  end;
end;

{==============================================================================}
procedure TPassingStore.UpdatePassingDomainFields(APassingNumber: Integer;
  ALapIndex, ACompetitorId: Integer);
var
  lPassing: TPassing;
begin
  Synchronizer.BeginWrite;
  try
    if not FPassingList.TryGetValue(APassingNumber, lPassing) then
      Exit;
    lPassing.LapIndex := ALapIndex;
    lPassing.CompetitorId := ACompetitorId;
    FPassingList.AddOrSetValue(APassingNumber, lPassing);
  finally
    Synchronizer.EndWrite;
  end;
end;

{==============================================================================}
procedure TPassingStore.RemovePassing(APassingNumber: Integer);
begin
  Synchronizer.BeginWrite;
  try
    FPassingList.Remove(APassingNumber);
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
procedure TPassingStore.FillPassingListRange(AStartPassingNumber, AEndPassingNumber: integer;
  AList: TDictionary<integer, TPassing>);
var
  lPassingNumber: integer;
  lPassing: TPassing;
begin
  if (AList = nil) or (AEndPassingNumber < AStartPassingNumber) then
    Exit;

  Synchronizer.BeginRead;
  try
    for lPassingNumber := AStartPassingNumber to AEndPassingNumber do
      if FPassingList.TryGetValue(lPassingNumber, lPassing) then
        AList.AddOrSetValue(lPassingNumber, lPassing);
  finally
    Synchronizer.EndRead;
  end;
end;

{==============================================================================}
procedure TPassingStore.FillPassingListForRaceId(ARaceId: integer; AList: TDictionary<TDatetime, TPassing>; AOnlyActivePassings, ATimeFractionOnly: Boolean);
var
  lPassing: TPassing;
begin
  Synchronizer.BeginRead;
  try
    for lPassing in FPassingList.Values do
    begin
      if lPassing.RaceId <> ARaceId then
        Continue;
      if AOnlyActivePassings and (lPassing.PassingStatus <> Ord(psValid)) then
        Continue;
      if ATimeFractionOnly then
        AList.AddOrSetValue(Frac(lPassing.PassingTime), lPassing)
      else
        AList.AddOrSetValue(lPassing.PassingTime, lPassing);
    end;
  finally
    Synchronizer.EndRead;
  end;
end;

{==============================================================================}
procedure TPassingStore.FillPassingsForRace(ARaceId: Integer; AList: TList<TPassing>);
var
  lPassing: TPassing;
begin
  Synchronizer.BeginRead;
  try
    for lPassing in FPassingList.Values do
    begin
      if lPassing.RaceId <> ARaceId then
        Continue;
      AList.Add(lPassing);
    end;
  finally
    Synchronizer.EndRead;
  end;
end;

{==============================================================================}
function TPassingStore.GetLastValidPassingTime(ARaceId: Integer; const AChipId: string;
  ABeforeTime: TDateTime): TDateTime;
var
  lPassing: TPassing;
  lChipKey: string;
begin
  Result := 0;
  lChipKey := NormalizeChipId(AChipId);
  if (ARaceId < 0) or (lChipKey = '') then
    Exit;

  Synchronizer.BeginRead;
  try
    for lPassing in FPassingList.Values do
    begin
      if lPassing.RaceId <> ARaceId then
        Continue;
      if lPassing.PassingStatus <> Ord(psValid) then
        Continue;
      if (lPassing.Flags and 2) = 2 then
        Continue;
      if NormalizeChipId(lPassing.ChipId) <> lChipKey then
        Continue;
      if (lPassing.PassingTime >= ABeforeTime) then
        Continue;
      if lPassing.PassingTime > Result then
        Result := lPassing.PassingTime;
    end;
  finally
    Synchronizer.EndRead;
  end;
end;

{==============================================================================}
function TPassingStore.GetLastPassingTimeForChip(ARaceId: Integer; const AChipId: string;
  ABeforeTime: TDateTime; AExcludePassingNumber: Integer): TDateTime;
var
  lPassing: TPassing;
  lChipKey: string;
begin
  Result := 0;
  lChipKey := NormalizeChipId(AChipId);
  if (ARaceId < 0) or (lChipKey = '') then
    Exit;

  Synchronizer.BeginRead;
  try
    for lPassing in FPassingList.Values do
    begin
      if (AExcludePassingNumber >= 0) and
         (lPassing.PassingNumber = AExcludePassingNumber) then
        Continue;
      if lPassing.RaceId <> ARaceId then
        Continue;
      if (lPassing.Flags and 2) = 2 then
        Continue;
      if NormalizeChipId(lPassing.ChipId) = '' then
        Continue;
      if NormalizeChipId(lPassing.ChipId) <> lChipKey then
        Continue;
      (* Include equal timestamps from earlier hits; exclude only strictly later. *)
      if lPassing.PassingTime > ABeforeTime then
        Continue;
      if lPassing.PassingTime > Result then
        Result := lPassing.PassingTime;
    end;
  finally
    Synchronizer.EndRead;
  end;
end;

{==============================================================================}
constructor TUnassignedPassingStore.Create;
begin
  inherited Create;
  FPassingList := TDictionary<Integer, TPassing>.Create;
end;

{==============================================================================}
class function TUnassignedPassingStore.GetSingleton: TUnassignedPassingStore;
begin
  gCriticalSection.Enter;
  try
    if gUnassignedPassingStore = nil then
      gUnassignedPassingStore := TUnassignedPassingStore.Create;
  finally
    gCriticalSection.Leave;
  end;
  Result := gUnassignedPassingStore;
end;

{==============================================================================}
destructor TUnassignedPassingStore.Destroy;
begin
  try
    FreeAndNil(FPassingList);
  finally
    inherited Destroy;
  end;
end;

{==============================================================================}
procedure TUnassignedPassingStore.Clear;
begin
  Synchronizer.BeginWrite;
  try
    FPassingList.Clear;
  finally
    Synchronizer.EndWrite;
  end;
end;

{==============================================================================}
procedure TUnassignedPassingStore.AddPassing(APassing: TPassing);
begin
  if APassing.RaceId >= 0 then
    Exit;
  if (APassing.Flags and 2) = 2 then
    Exit;
  if Trim(APassing.ChipId) = '' then
    Exit;

  Synchronizer.BeginWrite;
  try
    FPassingList.AddOrSetValue(APassing.PassingNumber, APassing);
  finally
    Synchronizer.EndWrite;
  end;
end;

{==============================================================================}
procedure TUnassignedPassingStore.RemovePassing(APassingNumber: Integer);
begin
  Synchronizer.BeginWrite;
  try
    FPassingList.Remove(APassingNumber);
  finally
    Synchronizer.EndWrite;
  end;
end;

{==============================================================================}
function TUnassignedPassingStore.Contains(APassingNumber: Integer): Boolean;
begin
  Synchronizer.BeginRead;
  try
    Result := FPassingList.ContainsKey(APassingNumber);
  finally
    Synchronizer.EndRead;
  end;
end;

{==============================================================================}
function TUnassignedPassingStore.Count: Integer;
begin
  Synchronizer.BeginRead;
  try
    Result := FPassingList.Count;
  finally
    Synchronizer.EndRead;
  end;
end;

{==============================================================================}
procedure TUnassignedPassingStore.FillList(AList: TList<TPassing>);
var
  lPassing: TPassing;
begin
  if AList = nil then
    Exit;
  Synchronizer.BeginRead;
  try
    for lPassing in FPassingList.Values do
      AList.Add(lPassing);
  finally
    Synchronizer.EndRead;
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

{==============================================================================}
function TTransponderMappingStore.ConvertToValidChipId(var AID: string): boolean;

  function IsNumber(const AStr: string): boolean;
  var
    i: integer;
  begin
    for i := 1 to Length(AStr) do
    begin
      if not AStr[i].IsDigit then
        Exit(false);
    end;
    result := true;
  end;

var
  lTemp: string;
begin
  if AID.IsEmpty then
    Exit(false);

  if not IsNumber(AID) then
    Exit(true);

  Synchronizer.BeginRead;
  try
    if not FShortIdToTxId.TryGetValue(AID.ToInteger, lTemp) then
      Exit(false);
    AID := lTemp;
    result := true;
  finally
    Synchronizer.EndRead;
  end;
end;

{==============================================================================}
function TTransponderMappingStore.Count: Integer;
begin
  Synchronizer.BeginRead;
  try
    Result := FShortIdToTxId.Count;
  finally
    Synchronizer.EndRead;
  end;
end;

{==============================================================================}
function TTransponderAssignment.IsOpen: Boolean;
begin
  Result := ValidTo = 0;
end;

{==============================================================================}
function TTransponderAssignment.CoversTime(ATime: TDateTime): Boolean;
begin
  Result := (ValidFrom <= ATime) and (IsOpen or (ValidTo >= ATime));
end;

{==============================================================================}
constructor TTransponderAssignmentStore.Create;
begin
  inherited Create;
  FById := TDictionary<Integer, TTransponderAssignment>.Create;
  FActiveByChip := TDictionary<string, Integer>.Create;
  FActiveByRaceCompetitor := TDictionary<string, Integer>.Create;
end;

{==============================================================================}
class function TTransponderAssignmentStore.GetSingleton: TTransponderAssignmentStore;
begin
  gCriticalSection.Enter;
  try
    if gAssignmentStore = nil then
      gAssignmentStore := TTransponderAssignmentStore.Create;
  finally
    gCriticalSection.Leave;
  end;
  Result := gAssignmentStore;
end;

{==============================================================================}
destructor TTransponderAssignmentStore.Destroy;
begin
  try
    FreeAndNil(FById);
    FreeAndNil(FActiveByChip);
    FreeAndNil(FActiveByRaceCompetitor);
  finally
    inherited Destroy;
  end;
end;

{==============================================================================}
class function TTransponderAssignmentStore.RaceCompetitorKey(ARaceId, ACompetitorId: Integer): string;
begin
  Result := Format('%d:%d', [ARaceId, ACompetitorId]);
end;

{==============================================================================}
procedure TTransponderAssignmentStore.IndexOpenAssignment(const AAssignment: TTransponderAssignment);
begin
  if not AAssignment.IsOpen then
    Exit;
  FActiveByChip.AddOrSetValue(NormalizeChipId(AAssignment.ChipId), AAssignment.AssignmentId);
  FActiveByRaceCompetitor.AddOrSetValue(
    RaceCompetitorKey(AAssignment.RaceId, AAssignment.CompetitorId),
    AAssignment.AssignmentId);
end;

{==============================================================================}
procedure TTransponderAssignmentStore.UnindexOpenAssignment(const AAssignment: TTransponderAssignment);
var
  lId: Integer;
  lChipKey: string;
begin
  lChipKey := NormalizeChipId(AAssignment.ChipId);
  if FActiveByChip.TryGetValue(lChipKey, lId) and (lId = AAssignment.AssignmentId) then
    FActiveByChip.Remove(lChipKey);
  if FActiveByRaceCompetitor.TryGetValue(
       RaceCompetitorKey(AAssignment.RaceId, AAssignment.CompetitorId), lId) and
     (lId = AAssignment.AssignmentId) then
    FActiveByRaceCompetitor.Remove(RaceCompetitorKey(AAssignment.RaceId, AAssignment.CompetitorId));
end;

{==============================================================================}
procedure TTransponderAssignmentStore.Clear;
begin
  Synchronizer.BeginWrite;
  try
    FById.Clear;
    FActiveByChip.Clear;
    FActiveByRaceCompetitor.Clear;
  finally
    Synchronizer.EndWrite;
  end;
end;

{==============================================================================}
procedure TTransponderAssignmentStore.Upsert(const AAssignment: TTransponderAssignment);
var
  lExisting: TTransponderAssignment;
  lNormalized: TTransponderAssignment;
begin
  lNormalized := AAssignment;
  lNormalized.ChipId := NormalizeChipId(AAssignment.ChipId);
  Synchronizer.BeginWrite;
  try
    if FById.TryGetValue(lNormalized.AssignmentId, lExisting) then
      UnindexOpenAssignment(lExisting);
    FById.AddOrSetValue(lNormalized.AssignmentId, lNormalized);
    IndexOpenAssignment(lNormalized);
  finally
    Synchronizer.EndWrite;
  end;
end;

{==============================================================================}
procedure TTransponderAssignmentStore.CloseAssignment(AAssignmentId: Integer; AValidTo: TDateTime);
var
  lAssignment: TTransponderAssignment;
begin
  Synchronizer.BeginWrite;
  try
    if not FById.TryGetValue(AAssignmentId, lAssignment) then
      Exit;
    if not lAssignment.IsOpen then
      Exit;
    UnindexOpenAssignment(lAssignment);
    lAssignment.ValidTo := AValidTo;
    FById.AddOrSetValue(AAssignmentId, lAssignment);
  finally
    Synchronizer.EndWrite;
  end;
end;

{==============================================================================}
procedure TTransponderAssignmentStore.CloseAssignmentsForCompetitors(ARaceId: Integer;
  const ACompetitorIDs: TArray<Integer>; AValidTo: TDateTime);
var
  i: Integer;
  lAssignment: TTransponderAssignment;
  lId: Integer;
begin
  Synchronizer.BeginWrite;
  try
    for i := 0 to High(ACompetitorIDs) do
    begin
      if not FActiveByRaceCompetitor.TryGetValue(
           RaceCompetitorKey(ARaceId, ACompetitorIDs[i]), lId) then
        Continue;
      if not FById.TryGetValue(lId, lAssignment) then
        Continue;
      UnindexOpenAssignment(lAssignment);
      lAssignment.ValidTo := AValidTo;
      FById.AddOrSetValue(lId, lAssignment);
    end;
  finally
    Synchronizer.EndWrite;
  end;
end;

{==============================================================================}
procedure TTransponderAssignmentStore.CloseAllOpenForRace(ARaceId: Integer; AValidTo: TDateTime);
var
  lPair: TPair<Integer, TTransponderAssignment>;
  lAssignment: TTransponderAssignment;
  lToClose: TList<Integer>;
  i: Integer;
begin
  lToClose := TList<Integer>.Create;
  try
    Synchronizer.BeginWrite;
    try
      for lPair in FById do
        if (lPair.Value.RaceId = ARaceId) and lPair.Value.IsOpen then
          lToClose.Add(lPair.Key);
      for i := 0 to lToClose.Count - 1 do
      begin
        if not FById.TryGetValue(lToClose[i], lAssignment) then
          Continue;
        UnindexOpenAssignment(lAssignment);
        lAssignment.ValidTo := AValidTo;
        FById.AddOrSetValue(lToClose[i], lAssignment);
      end;
    finally
      Synchronizer.EndWrite;
    end;
  finally
    FreeAndNil(lToClose);
  end;
end;

{==============================================================================}
function TTransponderAssignmentStore.TryGetById(AAssignmentId: Integer;
  out AAssignment: TTransponderAssignment): Boolean;
begin
  Synchronizer.BeginRead;
  try
    Result := FById.TryGetValue(AAssignmentId, AAssignment);
  finally
    Synchronizer.EndRead;
  end;
end;

{==============================================================================}
function TTransponderAssignmentStore.TryGetActiveByChip(const AChipId: string;
  out AAssignment: TTransponderAssignment): Boolean;
var
  lId: Integer;
begin
  Synchronizer.BeginRead;
  try
    Result := FActiveByChip.TryGetValue(NormalizeChipId(AChipId), lId) and
              FById.TryGetValue(lId, AAssignment);
  finally
    Synchronizer.EndRead;
  end;
end;

{==============================================================================}
function TTransponderAssignmentStore.TryGetActiveByRaceAndCompetitor(ARaceId, ACompetitorId: Integer;
  out AAssignment: TTransponderAssignment): Boolean;
var
  lId: Integer;
begin
  Synchronizer.BeginRead;
  try
    Result := FActiveByRaceCompetitor.TryGetValue(RaceCompetitorKey(ARaceId, ACompetitorId), lId) and
              FById.TryGetValue(lId, AAssignment);
  finally
    Synchronizer.EndRead;
  end;
end;

{==============================================================================}
function TTransponderAssignmentStore.FindAssignmentsForChipAtTime(const AChipId: string;
  APassingTime: TDateTime; AList: TList<TTransponderAssignment>): Integer;
var
  lPair: TPair<Integer, TTransponderAssignment>;
  lChipKey: string;
begin
  Result := 0;
  if AList = nil then
    Exit;
  lChipKey := NormalizeChipId(AChipId);
  if lChipKey = '' then
    Exit;

  Synchronizer.BeginRead;
  try
    for lPair in FById do
    begin
      if NormalizeChipId(lPair.Value.ChipId) <> lChipKey then
        Continue;
      if not lPair.Value.CoversTime(APassingTime) then
        Continue;
      AList.Add(lPair.Value);
      Inc(Result);
    end;
  finally
    Synchronizer.EndRead;
  end;
end;

{==============================================================================}
procedure TTransponderAssignmentStore.FillAssignmentsForRace(ARaceId: Integer;
  AList: TList<TTransponderAssignment>; AOpenOnly: Boolean);
var
  lPair: TPair<Integer, TTransponderAssignment>;
begin
  if AList = nil then
    Exit;

  Synchronizer.BeginRead;
  try
    for lPair in FById do
    begin
      if lPair.Value.RaceId <> ARaceId then
        Continue;
      if AOpenOnly and not lPair.Value.IsOpen then
        Continue;
      AList.Add(lPair.Value);
    end;
  finally
    Synchronizer.EndRead;
  end;
end;

initialization
  gCriticalSection := TCriticalSection.Create;
  gPassingStore := nil;
  gUnassignedPassingStore := nil;
  gStatusStore := nil;
  gDecoderStore := nil;
  gMappingStore := nil;
  gAssignmentStore := nil;

finalization
  try
    FreeAndNil(gDecoderStore);
    FreeAndNil(gPassingStore);
    FreeAndNil(gUnassignedPassingStore);
    FreeAndNil(gStatusStore);
    FreeAndNil(gMappingStore);
    FreeAndNil(gAssignmentStore);

    gCriticalSection.Free;
  except
  end;
end.
