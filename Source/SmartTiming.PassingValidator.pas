unit SmartTiming.PassingValidator;

{==============================================================================
  Plan 4 — Plausibility rule catalog (step 1).

  Pure evaluation against TPassingValidationContext (no UI).
  Live pipeline: BuildLiveContext + Validate in Controller after resolve,
  before participation update (Plan 4 step 2). Operator dialog is step 4.

  Rule catalog (minimum):
    pvrUnknownChip          Chip not in Tx mapping
    pvrNotAssigned          No unique race/competitor assignment
    pvrRaceNotAccepting     Resolved race not in scoring status
    pvrMinLapDuration       Δt to last valid passing < MinLapDuration
    pvrDoubleHit            Identical (or zero-Δt) hit vs last valid
    pvrAmbiguousAssignment  >1 assignment match at passing time
    pvrParallelChipConflict Chip open-assigned in another active race

  Default dispositions (cautious; settings later):
    Unknown / NotAssigned / RaceNotAccepting / DoubleHit → Reject
    MinLapDuration / Ambiguous / ParallelConflict       → AskOperator
==============================================================================}

interface

uses
  System.SysUtils, System.Classes, System.DateUtils,
  SmartTiming.Consts, DecoderInterface, SmartTiming.TransponderAssignment;

type
  TPassingValidationRule = (
    pvrUnknownChip,
    pvrNotAssigned,
    pvrRaceNotAccepting,
    pvrMinLapDuration,
    pvrDoubleHit,
    pvrAmbiguousAssignment,
    pvrParallelChipConflict
  );

  TPassingValidationRules = set of TPassingValidationRule;

  (* What the pipeline should do with the passing (before participation update). *)
  TPassingDisposition = (
    pdAccept,        (* score as valid *)
    pdAcceptMarked,  (* score, but mark suspicious / invalid flag optional later *)
    pdAskOperator,   (* block for confirmation on main thread *)
    pdReject         (* do not score; may keep as invalid / unassigned *)
  );

  TPassingValidationSeverity = (pvsInfo, pvsWarning, pvsError);

  TPassingValidationFinding = record
    Rule: TPassingValidationRule;
    Severity: TPassingValidationSeverity;
    Disposition: TPassingDisposition;
    Message: string;
  end;

  TPassingValidationResult = record
    Disposition: TPassingDisposition;
    Findings: TArray<TPassingValidationFinding>;
    TriggeredRules: TPassingValidationRules;
    function IsAccepted: Boolean;
    function NeedsOperator: Boolean;
    function PrimaryMessage: string;
  end;

  (* All inputs for rules — filled by caller (tests or future pipeline adapter). *)
  TPassingValidationContext = record
    ChipId: string;
    PassingTime: TDateTime;
    IsManual: Boolean;
    ChipKnownInMapping: Boolean;
    AssignmentMatchCount: Integer;     (* 0 / 1 / >1 from ResolvePassing *)
    ResolvedRaceId: Integer;           (* -1 if none *)
    ResolvedCompetitorId: Integer;     (* -1 if none *)
    RaceStatus: TRaceStatus;           (* meaningful if ResolvedRaceId >= 0 *)
    RaceAcceptsPassings: Boolean;      (* typically Status in cRaceStatusesAcceptingPassings *)
    MinLapDurationSeconds: Integer;    (* from TRaceItem.MinLapDuration *)
    LastValidPassingTime: TDateTime;   (* 0 = none yet for this competitor/race *)
    ParallelChipConflict: Boolean;     (* open assignment of chip in other active race *)
    class function MakeCleanLiveHit(const AChipId: string; APassingTime: TDateTime;
      ARaceId, ACompetitorId: Integer; AMinLapSeconds: Integer;
      ALastValidPassingTime: TDateTime = 0): TPassingValidationContext; static;
  end;

  TPassingValidator = class
  private
    class function DispositionForRule(ARule: TPassingValidationRule): TPassingDisposition; static;
    class function SeverityForDisposition(ADisposition: TPassingDisposition): TPassingValidationSeverity; static;
    class function WorseDisposition(A, B: TPassingDisposition): TPassingDisposition; static;
    class function RuleDisplayName(ARule: TPassingValidationRule): string; static;
    class procedure AddFinding(var AResult: TPassingValidationResult; ARule: TPassingValidationRule;
      const AMessage: string); static;
    class function SecondsBetweenPassings(AEarlier, ALater: TDateTime): Double; static;
  public
    class function Validate(const AContext: TPassingValidationContext): TPassingValidationResult; static;

    (* Build context after assignment resolve; AMinLapDurationSeconds from TRaceItem when known. *)
    class function BuildLiveContext(const APassing: TPassing;
      const AResolution: TPassingAssignmentResolution; AMinLapDurationSeconds: Integer;
      AIsManual: Boolean = False): TPassingValidationContext; static;

    (* Fake-context scenarios; returns True if all expectations match. *)
    class function RunCatalogSelfTests(out AReport: string): Boolean; static;
  end;

implementation

uses
  SmartTiming.Cache, DataModule, SmartTiming.Tools;

{==============================================================================}
function TPassingValidationResult.IsAccepted: Boolean;
begin
  Result := Disposition in [pdAccept, pdAcceptMarked];
end;

{==============================================================================}
function TPassingValidationResult.NeedsOperator: Boolean;
begin
  Result := Disposition = pdAskOperator;
end;

{==============================================================================}
function TPassingValidationResult.PrimaryMessage: string;
begin
  if Length(Findings) = 0 then
    Exit('');
  Result := Findings[0].Message;
end;

{==============================================================================}
class function TPassingValidationContext.MakeCleanLiveHit(const AChipId: string;
  APassingTime: TDateTime; ARaceId, ACompetitorId: Integer; AMinLapSeconds: Integer;
  ALastValidPassingTime: TDateTime): TPassingValidationContext;
begin
  Result.ChipId := AChipId;
  Result.PassingTime := APassingTime;
  Result.IsManual := False;
  Result.ChipKnownInMapping := True;
  Result.AssignmentMatchCount := 1;
  Result.ResolvedRaceId := ARaceId;
  Result.ResolvedCompetitorId := ACompetitorId;
  Result.RaceStatus := rsStarted;
  Result.RaceAcceptsPassings := True;
  Result.MinLapDurationSeconds := AMinLapSeconds;
  Result.LastValidPassingTime := ALastValidPassingTime;
  Result.ParallelChipConflict := False;
end;

{==============================================================================}
class function TPassingValidator.DispositionForRule(ARule: TPassingValidationRule): TPassingDisposition;
begin
  case ARule of
    pvrUnknownChip,
    pvrNotAssigned,
    pvrRaceNotAccepting,
    pvrDoubleHit:
      Result := pdReject;
    pvrMinLapDuration,
    pvrAmbiguousAssignment,
    pvrParallelChipConflict:
      Result := pdAskOperator;
  else
    Result := pdReject;
  end;
end;

{==============================================================================}
class function TPassingValidator.SeverityForDisposition(
  ADisposition: TPassingDisposition): TPassingValidationSeverity;
begin
  case ADisposition of
    pdAccept:
      Result := pvsInfo;
    pdAcceptMarked:
      Result := pvsWarning;
    pdAskOperator:
      Result := pvsWarning;
    pdReject:
      Result := pvsError;
  else
    Result := pvsError;
  end;
end;

{==============================================================================}
class function TPassingValidator.WorseDisposition(A, B: TPassingDisposition): TPassingDisposition;
begin
  if Ord(A) >= Ord(B) then
    Result := A
  else
    Result := B;
end;

{==============================================================================}
class function TPassingValidator.RuleDisplayName(ARule: TPassingValidationRule): string;
begin
  case ARule of
    pvrUnknownChip:
      Result := 'UnknownChip';
    pvrNotAssigned:
      Result := 'NotAssigned';
    pvrRaceNotAccepting:
      Result := 'RaceNotAccepting';
    pvrMinLapDuration:
      Result := 'MinLapDuration';
    pvrDoubleHit:
      Result := 'DoubleHit';
    pvrAmbiguousAssignment:
      Result := 'AmbiguousAssignment';
    pvrParallelChipConflict:
      Result := 'ParallelChipConflict';
  else
    Result := 'UnknownRule';
  end;
end;

{==============================================================================}
class procedure TPassingValidator.AddFinding(var AResult: TPassingValidationResult;
  ARule: TPassingValidationRule; const AMessage: string);
var
  lFinding: TPassingValidationFinding;
  n: Integer;
begin
  lFinding.Rule := ARule;
  lFinding.Disposition := DispositionForRule(ARule);
  lFinding.Severity := SeverityForDisposition(lFinding.Disposition);
  lFinding.Message := AMessage;

  n := Length(AResult.Findings);
  SetLength(AResult.Findings, n + 1);
  AResult.Findings[n] := lFinding;
  Include(AResult.TriggeredRules, ARule);
  AResult.Disposition := WorseDisposition(AResult.Disposition, lFinding.Disposition);
end;

{==============================================================================}
class function TPassingValidator.SecondsBetweenPassings(AEarlier, ALater: TDateTime): Double;
begin
  Result := (ALater - AEarlier) * SecsPerDay;
end;

{==============================================================================}
class function TPassingValidator.Validate(
  const AContext: TPassingValidationContext): TPassingValidationResult;
var
  lDeltaSec: Double;
begin
  Result.Disposition := pdAccept;
  SetLength(Result.Findings, 0);
  Result.TriggeredRules := [];

  if not AContext.ChipKnownInMapping then
    AddFinding(Result, pvrUnknownChip,
      Format('Chip %s ist im Transponder-Mapping unbekannt.', [AContext.ChipId]));

  if AContext.AssignmentMatchCount > 1 then
    AddFinding(Result, pvrAmbiguousAssignment,
      Format('Chip %s hat %d Zuordnungen zur Passagenzeit.',
        [AContext.ChipId, AContext.AssignmentMatchCount]));

  if AContext.ParallelChipConflict then
    AddFinding(Result, pvrParallelChipConflict,
      Format('Chip %s ist parallel in einem anderen aktiven Rennen zugeordnet.',
        [AContext.ChipId]));

  if AContext.AssignmentMatchCount = 0 then
    AddFinding(Result, pvrNotAssigned,
      Format('Chip %s ist keinem wertenden Rennen/Teilnehmer zugeordnet.', [AContext.ChipId]));

  if (AContext.AssignmentMatchCount = 1) and (AContext.ResolvedRaceId >= 0) and
     (not AContext.RaceAcceptsPassings) then
    AddFinding(Result, pvrRaceNotAccepting,
      Format('Rennen %d akzeptiert keine Wertungs-Passagen (Status %d).',
        [AContext.ResolvedRaceId, Ord(AContext.RaceStatus)]));

  if (AContext.AssignmentMatchCount = 1) and (AContext.LastValidPassingTime > 0) and
     (AContext.PassingTime >= AContext.LastValidPassingTime) then
  begin
    lDeltaSec := SecondsBetweenPassings(AContext.LastValidPassingTime, AContext.PassingTime);

    if lDeltaSec <= 0 then
      AddFinding(Result, pvrDoubleHit,
        Format('Doppelhit für Chip %s (Δt = %.3f s).', [AContext.ChipId, lDeltaSec]))
    else if (AContext.MinLapDurationSeconds > 0) and
            (lDeltaSec < AContext.MinLapDurationSeconds) then
      AddFinding(Result, pvrMinLapDuration,
        Format('Rundenzeit %.1f s unter MinLapDuration %d s (Chip %s).',
          [lDeltaSec, AContext.MinLapDurationSeconds, AContext.ChipId]));
  end;
end;

{==============================================================================}
class function TPassingValidator.BuildLiveContext(const APassing: TPassing;
  const AResolution: TPassingAssignmentResolution; AMinLapDurationSeconds: Integer;
  AIsManual: Boolean): TPassingValidationContext;
var
  lConflicts: TArray<TAssignmentConflict>;
  lExcludeRaceId: Integer;
  lExcludeCompetitorId: Integer;
  lShortId: Integer;
begin
  Result.ChipId := APassing.ChipId;
  Result.PassingTime := APassing.PassingTime;
  Result.IsManual := AIsManual;
  Result.AssignmentMatchCount := AResolution.MatchCount;
  Result.ResolvedRaceId := AResolution.RaceId;
  Result.ResolvedCompetitorId := AResolution.CompetitorId;
  Result.MinLapDurationSeconds := AMinLapDurationSeconds;
  Result.ParallelChipConflict := False;
  Result.LastValidPassingTime := 0;
  Result.RaceStatus := rsNotStarted;
  Result.RaceAcceptsPassings := False;

  lShortId := TTransponderMappingStore.GetSingleton.GetShortIdFromTransponderId(APassing.ChipId);
  Result.ChipKnownInMapping := (Trim(APassing.ChipId) <> '') and (lShortId >= 0) and
    not SameText(APassing.ChipId, cNotFound);

  if AResolution.MatchCount = 1 then
  begin
    Result.RaceStatus := MainDataModule.GetRaceStatus(AResolution.RaceId);
    Result.RaceAcceptsPassings :=
      TTransponderAssignmentService.IsRaceStatusAcceptingPassings(Result.RaceStatus);
    Result.LastValidPassingTime := TPassingStore.GetSingleton.GetLastValidPassingTime(
      AResolution.RaceId, APassing.ChipId, APassing.PassingTime);
  end;

  if AResolution.IsUnique then
  begin
    lExcludeRaceId := AResolution.RaceId;
    lExcludeCompetitorId := AResolution.CompetitorId;
  end
  else
  begin
    lExcludeRaceId := -1;
    lExcludeCompetitorId := -1;
  end;
  lConflicts := TTransponderAssignmentService.FindOpenConflictsForChip(
    APassing.ChipId, lExcludeRaceId, lExcludeCompetitorId, True);
  Result.ParallelChipConflict := Length(lConflicts) > 0;
end;

{==============================================================================}
class function TPassingValidator.RunCatalogSelfTests(out AReport: string): Boolean;
var
  lLines: TStringList;
  lFailed: Integer;
  lCtx: TPassingValidationContext;
  lT0, lT1: TDateTime;

  procedure Expect(const AName: string; const AContext: TPassingValidationContext;
    AExpectedDisposition: TPassingDisposition; AMustInclude: TPassingValidationRules;
    AMustExclude: TPassingValidationRules = []);
  var
    lResult: TPassingValidationResult;
    lRule: TPassingValidationRule;
    lOk: Boolean;
    lTriggered: string;
  begin
    lResult := Validate(AContext);
    lOk := lResult.Disposition = AExpectedDisposition;
    for lRule := Low(TPassingValidationRule) to High(TPassingValidationRule) do
    begin
      if (lRule in AMustInclude) and not (lRule in lResult.TriggeredRules) then
        lOk := False;
      if (lRule in AMustExclude) and (lRule in lResult.TriggeredRules) then
        lOk := False;
    end;

    if lOk then
      lLines.Add('OK  ' + AName)
    else
    begin
      Inc(lFailed);
      lTriggered := '';
      for lRule := Low(TPassingValidationRule) to High(TPassingValidationRule) do
        if lRule in lResult.TriggeredRules then
        begin
          if lTriggered <> '' then
            lTriggered := lTriggered + ',';
          lTriggered := lTriggered + RuleDisplayName(lRule);
        end;
      lLines.Add(Format(
        'FAIL %s — disposition %d (expected %d); rules=[%s]; %s',
        [AName, Ord(lResult.Disposition), Ord(AExpectedDisposition),
         lTriggered, lResult.PrimaryMessage]));
    end;
  end;

begin
  lFailed := 0;
  lLines := TStringList.Create;
  try
    lLines.Add('PassingValidator catalog self-tests');
    lT0 := EncodeDate(2026, 8, 9) + EncodeTime(12, 0, 0, 0);
    lT1 := lT0 + (30 / SecsPerDay);

    lCtx := TPassingValidationContext.MakeCleanLiveHit('CL-11540', lT0, 1, 10, 20, 0);
    Expect('clean first hit', lCtx, pdAccept, [],
      [pvrUnknownChip, pvrNotAssigned, pvrRaceNotAccepting, pvrMinLapDuration,
       pvrDoubleHit, pvrAmbiguousAssignment, pvrParallelChipConflict]);

    lCtx := TPassingValidationContext.MakeCleanLiveHit('CL-11540', lT1, 1, 10, 20, lT0);
    Expect('clean hit after MinLap', lCtx, pdAccept, []);

    lCtx := TPassingValidationContext.MakeCleanLiveHit('XX-00000', lT0, -1, -1, 20, 0);
    lCtx.ChipKnownInMapping := False;
    lCtx.AssignmentMatchCount := 0;
    Expect('unknown chip', lCtx, pdReject, [pvrUnknownChip, pvrNotAssigned]);

    lCtx := TPassingValidationContext.MakeCleanLiveHit('CL-11540', lT0, -1, -1, 20, 0);
    lCtx.AssignmentMatchCount := 0;
    Expect('not assigned', lCtx, pdReject, [pvrNotAssigned], [pvrUnknownChip]);

    lCtx := TPassingValidationContext.MakeCleanLiveHit('CL-11540', lT0, 1, 10, 20, 0);
    lCtx.RaceStatus := rsFinished;
    lCtx.RaceAcceptsPassings := False;
    Expect('race not accepting', lCtx, pdReject, [pvrRaceNotAccepting]);

    lCtx := TPassingValidationContext.MakeCleanLiveHit('CL-11540',
      lT0 + (5 / SecsPerDay), 1, 10, 20, lT0);
    Expect('min lap duration', lCtx, pdAskOperator, [pvrMinLapDuration], [pvrDoubleHit]);

    lCtx := TPassingValidationContext.MakeCleanLiveHit('CL-11540', lT0, 1, 10, 20, lT0);
    Expect('double hit', lCtx, pdReject, [pvrDoubleHit], [pvrMinLapDuration]);

    lCtx := TPassingValidationContext.MakeCleanLiveHit('CL-11540', lT0, -1, -1, 20, 0);
    lCtx.AssignmentMatchCount := 2;
    Expect('ambiguous assignment', lCtx, pdAskOperator, [pvrAmbiguousAssignment],
      [pvrNotAssigned]);

    lCtx := TPassingValidationContext.MakeCleanLiveHit('CL-11540', lT0, 1, 10, 20, 0);
    lCtx.ParallelChipConflict := True;
    Expect('parallel chip conflict', lCtx, pdAskOperator, [pvrParallelChipConflict]);

    Result := lFailed = 0;
    if Result then
      lLines.Add('ALL PASSED')
    else
      lLines.Add(Format('%d FAILED', [lFailed]));
    AReport := lLines.Text;
  finally
    FreeAndNil(lLines);
  end;
end;

end.
