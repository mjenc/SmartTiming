unit SmartTiming.PassingService;

{==============================================================================
  Plan 8b — Passing ingress.

  Live decoder hits, simulated/manual passings and SYSTEM markers share Ingest.
  Restore / Update / Remove also live here so DB and cache stay in one place.
  Controller remains the decoder adapter and supplies race/UI callbacks.
  No VCL / FormMain dependency.
==============================================================================}

interface

uses
  System.SysUtils, System.Classes, System.SyncObjs, System.Generics.Collections,
  DecoderInterface, SmartTiming.Consts, SmartTiming.PassingValidator;

type
  TPassingDisplayEvent = procedure(ARaceId: Integer; const APassing: TPassing) of object;
  TPassingGetIntegerEvent = function: Integer of object;
  TPassingGetMinLapEvent = function(ARaceId: Integer): Integer of object;

  TPassingService = class
  private
    FOnDisplayPassing: TPassingDisplayEvent;
    FOnGetContextRaceId: TPassingGetIntegerEvent;
    FOnGetMinLapDuration: TPassingGetMinLapEvent;
    FOnPlausibilityDecision: TPlausibilityDecisionEvent;
    FOnPlausibilityStatsChanged: TPlausibilityStatsEvent;
    FAlwaysAcceptChips: TDictionary<string, Boolean>;
    FLock: TCriticalSection;
    FStats: TPlausibilitySessionStats;
    FLastManualResult: TManualPassingResult;

    function IsAlwaysAcceptChip(const AChipId: string): Boolean;
    function IsMinLapOnlyAsk(const AValidation: TPassingValidationResult): Boolean;
    function TryGetContextRaceId: Integer;
    function GetMinLapDuration(ARaceId: Integer): Integer;
    procedure CaptureManualPassingResult(const AValidation: TPassingValidationResult;
      AIsManual: Boolean);
    procedure NotifyPlausibilityStatsChanged;
    procedure RecordPlausibilityOutcome(const APassing: TPassing; ARaceId: Integer;
      const AValidation: TPassingValidationResult; AAlwaysAccepted: Boolean);
    procedure DisplayPassing(ARaceId: Integer; const APassing: TPassing);
    procedure IngestSystemMarker(var APassing: TPassing);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Ingest(APassing: TPassing);
    procedure BeginManualPassing;
    function LastManualPassingResult: TManualPassingResult;

    (* Load passings for races + unassigned into cache/UI (no re-validation). *)
    procedure RestoreFromDatabase(const ARaceIds: TArray<Integer>);
    procedure UpdatePassing(APassingNumber: Integer; APassingTime: TDateTime;
      APassingState: TPassingState);
    procedure RemovePassing(APassingNumber: Integer);

    procedure RememberAlwaysAcceptChip(const AChipId: string);
    procedure ClearAlwaysAcceptChips;
    procedure ResetPlausibilityStats;
    function GetPlausibilityStatsSnapshot: TPlausibilitySessionStats;
    procedure IncrementOperatorAccepted;
    procedure NotifyStatsChanged;

    property OnDisplayPassing: TPassingDisplayEvent read FOnDisplayPassing
      write FOnDisplayPassing;
    property OnGetContextRaceId: TPassingGetIntegerEvent read FOnGetContextRaceId
      write FOnGetContextRaceId;
    property OnGetMinLapDuration: TPassingGetMinLapEvent read FOnGetMinLapDuration
      write FOnGetMinLapDuration;
    property OnPlausibilityDecision: TPlausibilityDecisionEvent
      read FOnPlausibilityDecision write FOnPlausibilityDecision;
    property OnPlausibilityStatsChanged: TPlausibilityStatsEvent
      read FOnPlausibilityStatsChanged write FOnPlausibilityStatsChanged;
  end;

implementation

uses
  DataModule, SmartTiming.Cache, SmartTiming.TransponderAssignment, Tools.Logger;

const
  cLogger = 'SmartTiming.PassingService';

{==============================================================================}
constructor TPassingService.Create;
begin
  inherited Create;
  FAlwaysAcceptChips := TDictionary<string, Boolean>.Create;
  FLock := TCriticalSection.Create;
  FStats.Clear;
end;

{==============================================================================}
destructor TPassingService.Destroy;
begin
  FreeAndNil(FAlwaysAcceptChips);
  FreeAndNil(FLock);
  inherited Destroy;
end;

{==============================================================================}
procedure TPassingService.DisplayPassing(ARaceId: Integer; const APassing: TPassing);
begin
  if Assigned(FOnDisplayPassing) then
    FOnDisplayPassing(ARaceId, APassing);
end;

{==============================================================================}
function TPassingService.TryGetContextRaceId: Integer;
begin
  Result := -1;
  if Assigned(FOnGetContextRaceId) then
    Result := FOnGetContextRaceId();
end;

{==============================================================================}
function TPassingService.GetMinLapDuration(ARaceId: Integer): Integer;
begin
  Result := 0;
  if Assigned(FOnGetMinLapDuration) then
    Result := FOnGetMinLapDuration(ARaceId);
end;

{==============================================================================}
function TPassingService.IsAlwaysAcceptChip(const AChipId: string): Boolean;
begin
  FLock.Enter;
  try
    Result := (FAlwaysAcceptChips <> nil) and
      FAlwaysAcceptChips.ContainsKey(NormalizeChipId(AChipId));
  finally
    FLock.Leave;
  end;
end;

{==============================================================================}
function TPassingService.IsMinLapOnlyAsk(
  const AValidation: TPassingValidationResult): Boolean;
begin
  Result := (AValidation.Disposition = pdAskOperator) and
    (AValidation.TriggeredRules = [pvrMinLapDuration]);
end;

{==============================================================================}
procedure TPassingService.CaptureManualPassingResult(
  const AValidation: TPassingValidationResult; AIsManual: Boolean);
begin
  if not AIsManual then
    Exit;
  FLastManualResult.Disposition := AValidation.Disposition;
  FLastManualResult.Scored := AValidation.Disposition in [pdAccept, pdAcceptMarked];
  FLastManualResult.NeedsConfirmation := AValidation.Disposition = pdAskOperator;
  FLastManualResult.Message := AValidation.FormatFindings;
end;

{==============================================================================}
procedure TPassingService.BeginManualPassing;
begin
  FLastManualResult.Disposition := pdReject;
  FLastManualResult.Scored := False;
  FLastManualResult.NeedsConfirmation := False;
  FLastManualResult.Message := '';
end;

{==============================================================================}
function TPassingService.LastManualPassingResult: TManualPassingResult;
begin
  Result := FLastManualResult;
end;

{==============================================================================}
procedure TPassingService.RememberAlwaysAcceptChip(const AChipId: string);
var
  lKey: string;
begin
  lKey := NormalizeChipId(AChipId);
  if lKey = '' then
    Exit;
  FLock.Enter;
  try
    if FAlwaysAcceptChips = nil then
      Exit;
    FAlwaysAcceptChips.AddOrSetValue(lKey, True);
  finally
    FLock.Leave;
  end;
  LogOnInfo(cLogger, ['Always-accept chip remembered for session (MinLap)', lKey]);
end;

{==============================================================================}
procedure TPassingService.ClearAlwaysAcceptChips;
begin
  FLock.Enter;
  try
    if FAlwaysAcceptChips <> nil then
      FAlwaysAcceptChips.Clear;
  finally
    FLock.Leave;
  end;
end;

{==============================================================================}
function TPassingService.GetPlausibilityStatsSnapshot: TPlausibilitySessionStats;
begin
  FLock.Enter;
  try
    Result := FStats;
  finally
    FLock.Leave;
  end;
end;

{==============================================================================}
procedure TPassingService.ResetPlausibilityStats;
begin
  FLock.Enter;
  try
    FStats.Clear;
  finally
    FLock.Leave;
  end;
  NotifyPlausibilityStatsChanged;
end;

{==============================================================================}
procedure TPassingService.IncrementOperatorAccepted;
begin
  FLock.Enter;
  try
    Inc(FStats.OperatorAccepted);
  finally
    FLock.Leave;
  end;
  NotifyPlausibilityStatsChanged;
end;

{==============================================================================}
procedure TPassingService.NotifyStatsChanged;
begin
  NotifyPlausibilityStatsChanged;
end;

{==============================================================================}
procedure TPassingService.NotifyPlausibilityStatsChanged;
var
  lStats: TPlausibilitySessionStats;
begin
  if not Assigned(FOnPlausibilityStatsChanged) then
    Exit;
  lStats := GetPlausibilityStatsSnapshot;
  TThread.Queue(nil,
    procedure
    begin
      if Assigned(FOnPlausibilityStatsChanged) then
        FOnPlausibilityStatsChanged(lStats);
    end);
end;

{==============================================================================}
procedure TPassingService.RecordPlausibilityOutcome(const APassing: TPassing;
  ARaceId: Integer; const AValidation: TPassingValidationResult; AAlwaysAccepted: Boolean);
var
  lLine: string;
begin
  (* Clean accepts are silent in the status counters. *)
  if (AValidation.Disposition = pdAccept) and not AAlwaysAccepted then
    Exit;

  FLock.Enter;
  try
    if AAlwaysAccepted then
      Inc(FStats.AlwaysAccepted)
    else
      case AValidation.Disposition of
        pdAcceptMarked:
          Inc(FStats.AcceptedMarked);
        pdAskOperator:
          Inc(FStats.AskOperator);
        pdReject:
          Inc(FStats.Rejected);
      end;
  finally
    FLock.Leave;
  end;

  lLine := Format('Plausibility %s chip=%s race=%d rules=[%s] msg=%s',
    [DispositionDisplayName(AValidation.Disposition), APassing.ChipId, ARaceId,
     FormatTriggeredRules(AValidation.TriggeredRules), AValidation.PrimaryMessage]);
  if AAlwaysAccepted then
    lLine := lLine + ' (always-accept)';

  if AValidation.Disposition = pdReject then
    LogOnWarn(cLogger, [lLine])
  else
    LogOnInfo(cLogger, [lLine]);

  NotifyPlausibilityStatsChanged;
end;

{==============================================================================}
procedure TPassingService.IngestSystemMarker(var APassing: TPassing);
var
  lRaceId: Integer;
begin
  lRaceId := APassing.RaceId;
  APassing.PassingStatus := Ord(psValid);
  MainDataModule.AddPassingToDatabase(APassing, lRaceId, True);
  APassing.RaceId := lRaceId;
  TPassingStore.GetSingleton.AddPassing(APassing);
  TPassingStore.GetSingleton.UpdatePassingRaceId(APassing.PassingNumber, lRaceId);
  DisplayPassing(lRaceId, APassing);
end;

{==============================================================================}
procedure TPassingService.Ingest(APassing: TPassing);
var
  lRaceId: Integer;
  lContextRaceId: Integer;
  lResolution: TPassingAssignmentResolution;
  lContext: TPassingValidationContext;
  lValidation: TPassingValidationResult;
  lMinLap: Integer;
  lIsManual: Boolean;
  lAskOperator: Boolean;
  lAlwaysAccepted: Boolean;
  lRequest: TPlausibilityDecisionRequest;
begin
  try
    LogOnDebug(cLogger, ['Ingest']);

    (* System markers only from ChangeRaceStatus (DecoderId=SYSTEM); skip plausibility. *)
    if ((APassing.Flags and 2) = 2) and SameText(APassing.DecoderId, 'SYSTEM') then
    begin
      IngestSystemMarker(APassing);
      Exit;
    end;

    lIsManual := SameText(APassing.DecoderId, 'MANUAL');
    if lIsManual and (APassing.RaceId >= 0) then
      TTransponderAssignmentService.ResolvePassing(APassing.ChipId, APassing.PassingTime,
        lResolution, APassing.RaceId)
    else
      TTransponderAssignmentService.ResolvePassing(APassing.ChipId, APassing.PassingTime,
        lResolution);

    if lResolution.IsUnique then
      lMinLap := GetMinLapDuration(lResolution.RaceId)
    else
      lMinLap := 0;

    lContext := TPassingValidator.BuildLiveContext(APassing, lResolution, lMinLap, lIsManual);
    lValidation := TPassingValidator.Validate(lContext);
    lAskOperator := False;
    lAlwaysAccepted := False;

    if (lValidation.Disposition = pdAskOperator) and lResolution.IsUnique and
       IsMinLapOnlyAsk(lValidation) and IsAlwaysAcceptChip(APassing.ChipId) then
    begin
      (* Session override: MinLap-only AskOperator auto-accept for remembered chips. *)
      APassing.PassingStatus := Ord(psValid);
      lRaceId := lResolution.RaceId;
      lAlwaysAccepted := True;
    end
    else if lValidation.Disposition = pdAccept then
    begin
      APassing.PassingStatus := Ord(psValid);
      if lResolution.IsUnique then
        lRaceId := lResolution.RaceId
      else
        lRaceId := -1;
    end
    else if lValidation.Disposition = pdAcceptMarked then
    begin
      (* Marked accept: score for now; Plan 3 can surface the mark. *)
      APassing.PassingStatus := Ord(psValid);
      if lResolution.IsUnique then
        lRaceId := lResolution.RaceId
      else
        lRaceId := -1;
    end
    else if lValidation.Disposition = pdAskOperator then
    begin
      (* Persist invalid first; operator dialog is queued (no decoder-thread block). *)
      APassing.PassingStatus := Ord(psInvalid);
      if lResolution.IsUnique then
        lRaceId := lResolution.RaceId
      else
        lRaceId := -1;
      lAskOperator := True;
    end
    else
    begin
      (* pdReject: do not score. *)
      APassing.PassingStatus := Ord(psInvalid);
      if lResolution.IsUnique then
        lRaceId := lResolution.RaceId
      else
        lRaceId := -1;
    end;

    (* Unknown chip (no assignment): still show in the selected active race protocol. *)
    if (lRaceId < 0) and (lResolution.MatchCount = 0) then
    begin
      lContextRaceId := TryGetContextRaceId;
      if lContextRaceId >= 0 then
      begin
        lRaceId := lContextRaceId;
        APassing.PassingStatus := Ord(psInvalid);
        APassing.CompetitorId := -1;
      end;
    end;

    APassing.RaceId := lRaceId;
    if (lRaceId >= 0) and lResolution.IsUnique then
      APassing.CompetitorId := lResolution.CompetitorId
    else if lRaceId >= 0 then
      APassing.CompetitorId := -1;

    MainDataModule.AddPassingToDatabase(APassing, lRaceId, True);
    APassing.RaceId := lRaceId;
    TPassingStore.GetSingleton.UpdatePassingRaceId(APassing.PassingNumber, lRaceId);
    TPassingStore.GetSingleton.UpdatePassingStatus(APassing.PassingNumber, APassing.PassingStatus);
    TPassingStore.GetSingleton.UpdatePassingDomainFields(APassing.PassingNumber,
      APassing.LapIndex, APassing.CompetitorId);

    if (lRaceId < 0) and ((APassing.Flags and 2) <> 2) then
    begin
      TUnassignedPassingStore.GetSingleton.AddPassing(APassing);
      LogOnDebug(cLogger, ['Unassigned passing', APassing.ChipId,
        FormatDateTime('hh:nn:ss.zzz', APassing.PassingTime)]);
    end
    else
      TUnassignedPassingStore.GetSingleton.RemovePassing(APassing.PassingNumber);

    (* Display always; participation update only for accepted (engine checks status). *)
    DisplayPassing(lRaceId, APassing);

    RecordPlausibilityOutcome(APassing, lRaceId, lValidation, lAlwaysAccepted);
    CaptureManualPassingResult(lValidation, lIsManual);

    if lAskOperator and Assigned(FOnPlausibilityDecision) then
    begin
      lRequest.PassingNumber := APassing.PassingNumber;
      lRequest.ChipId := APassing.ChipId;
      lRequest.RaceId := lRaceId;
      lRequest.PassingTime := APassing.PassingTime;
      lRequest.CanScore := lRaceId >= 0;
      lRequest.AllowAlwaysAccept := IsMinLapOnlyAsk(lValidation);
      lRequest.Message := Format(cMessagesPlausibilityHeader,
        [APassing.ChipId, FormatDateTime('hh:nn:ss.zzz', APassing.PassingTime),
         lValidation.FormatFindings]);
      TThread.Queue(nil,
        procedure
        begin
          if Assigned(FOnPlausibilityDecision) then
            FOnPlausibilityDecision(lRequest);
        end);
    end;
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['Ingest']);
  end;
end;

{==============================================================================}
procedure TPassingService.RestoreFromDatabase(const ARaceIds: TArray<Integer>);
var
  lRaceId: Integer;
  lPassings: TArray<TPassing>;
  i: Integer;
begin
  try
    LogOnDebug(cLogger, ['RestoreFromDatabase']);
    TUnassignedPassingStore.GetSingleton.Clear;

    for lRaceId in ARaceIds do
    begin
      if lRaceId < 0 then
        Continue;
      lPassings := MainDataModule.GetAllPassingsForRaceId(lRaceId);
      for i := 0 to Length(lPassings) - 1 do
      begin
        TPassingStore.GetSingleton.AddPassing(lPassings[i]);
        DisplayPassing(lRaceId, lPassings[i]);
      end;
    end;

    lPassings := MainDataModule.GetUnassignedPassings;
    for i := 0 to High(lPassings) do
    begin
      TPassingStore.GetSingleton.AddPassing(lPassings[i]);
      TUnassignedPassingStore.GetSingleton.AddPassing(lPassings[i]);
    end;
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['RestoreFromDatabase']);
  end;
end;

{==============================================================================}
procedure TPassingService.UpdatePassing(APassingNumber: Integer; APassingTime: TDateTime;
  APassingState: TPassingState);
begin
  try
    LogOnDebug(cLogger, ['UpdatePassing', APassingNumber.ToString]);
    MainDataModule.UpdatePassingInDatabase(APassingNumber, APassingTime, APassingState);
    TPassingStore.GetSingleton.UpdatePassing(APassingNumber, APassingTime, Ord(APassingState));
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['UpdatePassing']);
  end;
end;

{==============================================================================}
procedure TPassingService.RemovePassing(APassingNumber: Integer);
begin
  try
    LogOnDebug(cLogger, ['RemovePassing', APassingNumber.ToString]);
    MainDataModule.RemovePassingFromDatabase(APassingNumber);
    TPassingStore.GetSingleton.RemovePassing(APassingNumber);
    TUnassignedPassingStore.GetSingleton.RemovePassing(APassingNumber);
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['RemovePassing']);
  end;
end;

end.
