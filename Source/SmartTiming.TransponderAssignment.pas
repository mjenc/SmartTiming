unit SmartTiming.TransponderAssignment;

{==============================================================================
  Race-scoped chip assignment API (Plan 2 step 3).

  Assign / Unassign / Transfer always require RaceId and enforce:
  at most one open assignment per chip (across all races).
==============================================================================}

interface

uses
  System.SysUtils, System.Generics.Collections,
  SmartTiming.Consts, SmartTiming.Cache;

type
  TAssignmentConflict = record
    ChipId: string;
    AssignmentId: Integer;
    RaceId: Integer;
    CompetitorId: Integer;
    RaceTitle: string;
    RaceStatus: TRaceStatus;
    CompetitorDisplayName: string;
    (* Set by Warm-Up scan: competitor in the race being activated. *)
    LocalCompetitorId: Integer;
    LocalCompetitorDisplayName: string;
    function IsInActiveRace: Boolean;
    function FormatMessage: string;
  end;

  TAssignmentOperationResult = record
    Success: Boolean;
    Message: string;
    AssignmentId: Integer;
    Conflicts: TArray<TAssignmentConflict>;
  end;

  TPassingAssignmentResolution = record
    RaceId: Integer;
    CompetitorId: Integer;
    MatchCount: Integer;
    function IsUnique: Boolean;
    function IsAmbiguous: Boolean;
  end;

  TTransponderAssignmentService = class
  private
    class function MakeEmptyResult: TAssignmentOperationResult; static;
    class function ConflictFromAssignment(const AAssignment: TTransponderAssignment): TAssignmentConflict; static;
    class function CollectOpenConflictsForChip(const AChipId: string;
      AExcludeRaceId, AExcludeCompetitorId: Integer;
      AActiveRacesOnly: Boolean): TArray<TAssignmentConflict>; static;
    class function PersistOpenAssignment(ARaceId, ACompetitorId: Integer;
      const AChipId: string; AValidFrom: TDateTime): Integer; static;
    class procedure SyncCompetitorChipId(ACompetitorId: Integer; const AChipId: string); static;
  public
    class function IsRaceStatusActiveForChipConflict(AStatus: TRaceStatus): Boolean; static;
    class function IsRaceStatusAcceptingPassings(AStatus: TRaceStatus): Boolean; static;

    (* All open assignments for chip (optional: only races in active status set). *)
    class function FindOpenConflictsForChip(const AChipId: string;
      AExcludeRaceId: Integer = -1; AExcludeCompetitorId: Integer = -1;
      AActiveRacesOnly: Boolean = False): TArray<TAssignmentConflict>; static;

    (* Chips of ARaceId that are open-assigned in another active race (Warm-Up check). *)
    class function FindConflictsAgainstOtherActiveRaces(ARaceId: Integer): TArray<TAssignmentConflict>; static;
    class procedure EnsureAssignmentsFromCompetitorChips(ARaceId: Integer); static;

    (* Chip + time → unique assignment (any race status); MatchCount 0/>1 → RaceId -1.
       Scoring still requires RaceAcceptsPassings (validator / participation). *)
    class function ResolvePassing(const AChipId: string; APassingTime: TDateTime;
      out AResolution: TPassingAssignmentResolution): Boolean; static;

    (* Competitor owning chip in a given race at APassingTime (assignment window). *)
    class function TryGetCompetitorForRaceChipAtTime(ARaceId: Integer; const AChipId: string;
      APassingTime: TDateTime; out ACompetitorId: Integer): Boolean; static;

    class function Assign(ARaceId, ACompetitorId: Integer; const AChipId: string;
      out AResult: TAssignmentOperationResult; AValidFrom: TDateTime = 0): Boolean; static;

    (* Participation helper: use COMPETITORS.CHIPID; skip quietly on empty/conflict. *)
    class function AssignFromCompetitorChip(ARaceId, ACompetitorId: Integer): Boolean; static;

    class function Unassign(ARaceId, ACompetitorId: Integer;
      out AResult: TAssignmentOperationResult): Boolean; static;

    (* Close current open assignment for race+competitor (if any), then Assign new chip. *)
    class function Transfer(ARaceId, ACompetitorId: Integer; const ANewChipId: string;
      out AResult: TAssignmentOperationResult; AValidFrom: TDateTime = 0): Boolean; static;
  end;

implementation

uses
  DataModule, SmartTiming.Tools;

{==============================================================================}
function TAssignmentConflict.IsInActiveRace: Boolean;
begin
  Result := TTransponderAssignmentService.IsRaceStatusActiveForChipConflict(RaceStatus);
end;

{==============================================================================}
function TAssignmentConflict.FormatMessage: string;
begin
  Result := Format(cMessagesChipAssignConflict,
    [ChipId, RaceTitle, CompetitorDisplayName,
     SmartTimingTools.GetRaceStatusStringFromEnum(RaceStatus)]);
end;

{==============================================================================}
class function TTransponderAssignmentService.MakeEmptyResult: TAssignmentOperationResult;
begin
  Result.Success := False;
  Result.Message := '';
  Result.AssignmentId := -1;
  SetLength(Result.Conflicts, 0);
end;

{==============================================================================}
class function TTransponderAssignmentService.IsRaceStatusActiveForChipConflict(
  AStatus: TRaceStatus): Boolean;
begin
  Result := AStatus in cActiveRaceStatusesForChipConflict;
end;

{==============================================================================}
class function TTransponderAssignmentService.IsRaceStatusAcceptingPassings(
  AStatus: TRaceStatus): Boolean;
begin
  Result := AStatus in cRaceStatusesAcceptingPassings;
end;

{==============================================================================}
function TPassingAssignmentResolution.IsUnique: Boolean;
begin
  Result := MatchCount = 1;
end;

{==============================================================================}
function TPassingAssignmentResolution.IsAmbiguous: Boolean;
begin
  Result := MatchCount > 1;
end;

{==============================================================================}
class function TTransponderAssignmentService.ResolvePassing(const AChipId: string;
  APassingTime: TDateTime; out AResolution: TPassingAssignmentResolution): Boolean;
var
  lMatches: TList<TTransponderAssignment>;
  lCandidates: TList<TTransponderAssignment>;
  lAssignment: TTransponderAssignment;
  i: Integer;
  lChipId: string;
begin
  AResolution.RaceId := -1;
  AResolution.CompetitorId := -1;
  AResolution.MatchCount := 0;
  Result := False;

  lChipId := NormalizeChipId(AChipId);
  if lChipId = '' then
    Exit;

  lMatches := TList<TTransponderAssignment>.Create;
  lCandidates := TList<TTransponderAssignment>.Create;
  try
    TTransponderAssignmentStore.GetSingleton.FindAssignmentsForChipAtTime(
      lChipId, APassingTime, lMatches);

    (* Unique race assignment (any status) drives RaceNotAccepting vs NotAssigned.
       Scoring still requires RaceAcceptsPassings in the validator/controller. *)
    for i := 0 to lMatches.Count - 1 do
    begin
      lAssignment := lMatches[i];
      if not MainDataModule.IsCompetitorAssignedToRace(lAssignment.RaceId, lAssignment.CompetitorId) then
        Continue;
      lCandidates.Add(lAssignment);
    end;

    AResolution.MatchCount := lCandidates.Count;
    if lCandidates.Count = 1 then
    begin
      AResolution.RaceId := lCandidates[0].RaceId;
      AResolution.CompetitorId := lCandidates[0].CompetitorId;
      Result := True;
    end;
  finally
    FreeAndNil(lCandidates);
    FreeAndNil(lMatches);
  end;
end;

{==============================================================================}
class function TTransponderAssignmentService.TryGetCompetitorForRaceChipAtTime(ARaceId: Integer;
  const AChipId: string; APassingTime: TDateTime; out ACompetitorId: Integer): Boolean;
var
  lMatches: TList<TTransponderAssignment>;
  lAssignment: TTransponderAssignment;
  i: Integer;
  lChipId: string;
begin
  ACompetitorId := -1;
  Result := False;
  lChipId := NormalizeChipId(AChipId);
  if (ARaceId < 0) or (lChipId = '') then
    Exit;

  lMatches := TList<TTransponderAssignment>.Create;
  try
    TTransponderAssignmentStore.GetSingleton.FindAssignmentsForChipAtTime(
      lChipId, APassingTime, lMatches);
    for i := 0 to lMatches.Count - 1 do
    begin
      lAssignment := lMatches[i];
      if lAssignment.RaceId <> ARaceId then
        Continue;
      if not MainDataModule.IsCompetitorAssignedToRace(ARaceId, lAssignment.CompetitorId) then
        Continue;
      ACompetitorId := lAssignment.CompetitorId;
      Exit(True);
    end;
  finally
    FreeAndNil(lMatches);
  end;
end;

{==============================================================================}
class function TTransponderAssignmentService.ConflictFromAssignment(
  const AAssignment: TTransponderAssignment): TAssignmentConflict;
begin
  Result.ChipId := AAssignment.ChipId;
  Result.AssignmentId := AAssignment.AssignmentId;
  Result.RaceId := AAssignment.RaceId;
  Result.CompetitorId := AAssignment.CompetitorId;
  Result.RaceTitle := MainDataModule.GetRaceTitle(AAssignment.RaceId);
  Result.RaceStatus := MainDataModule.GetRaceStatus(AAssignment.RaceId);
  Result.CompetitorDisplayName := MainDataModule.GetCompetitorDisplayName(AAssignment.CompetitorId);
  Result.LocalCompetitorId := 0;
  Result.LocalCompetitorDisplayName := '';
end;

{==============================================================================}
class function TTransponderAssignmentService.CollectOpenConflictsForChip(
  const AChipId: string; AExcludeRaceId, AExcludeCompetitorId: Integer;
  AActiveRacesOnly: Boolean): TArray<TAssignmentConflict>;
var
  lStore: TTransponderAssignmentStore;
  lAssignment: TTransponderAssignment;
  lConflict: TAssignmentConflict;
  lList: TList<TAssignmentConflict>;
  lMatches: TList<TTransponderAssignment>;
  i: Integer;
begin
  lList := TList<TAssignmentConflict>.Create;
  try
    lStore := TTransponderAssignmentStore.GetSingleton;

    (* Fast path: one open assignment per chip (unique index / store invariant). *)
    if lStore.TryGetActiveByChip(AChipId, lAssignment) then
    begin
      if not ((lAssignment.RaceId = AExcludeRaceId) and
              (lAssignment.CompetitorId = AExcludeCompetitorId)) then
      begin
        lConflict := ConflictFromAssignment(lAssignment);
        if (not AActiveRacesOnly) or lConflict.IsInActiveRace then
          lList.Add(lConflict);
      end;
    end
    else
    begin
      (* Defensive: scan history for open-at-now windows if index missed. *)
      lMatches := TList<TTransponderAssignment>.Create;
      try
        lStore.FindAssignmentsForChipAtTime(AChipId, Now, lMatches);
        for i := 0 to lMatches.Count - 1 do
        begin
          lAssignment := lMatches[i];
          if not lAssignment.IsOpen then
            Continue;
          if (lAssignment.RaceId = AExcludeRaceId) and
             (lAssignment.CompetitorId = AExcludeCompetitorId) then
            Continue;
          lConflict := ConflictFromAssignment(lAssignment);
          if (not AActiveRacesOnly) or lConflict.IsInActiveRace then
            lList.Add(lConflict);
        end;
      finally
        FreeAndNil(lMatches);
      end;
    end;

    Result := lList.ToArray;
  finally
    FreeAndNil(lList);
  end;
end;

{==============================================================================}
class function TTransponderAssignmentService.FindOpenConflictsForChip(
  const AChipId: string; AExcludeRaceId, AExcludeCompetitorId: Integer;
  AActiveRacesOnly: Boolean): TArray<TAssignmentConflict>;
begin
  if NormalizeChipId(AChipId) = '' then
  begin
    SetLength(Result, 0);
    Exit;
  end;
  Result := CollectOpenConflictsForChip(NormalizeChipId(AChipId), AExcludeRaceId,
    AExcludeCompetitorId, AActiveRacesOnly);
end;

{==============================================================================}
class function TTransponderAssignmentService.FindConflictsAgainstOtherActiveRaces(
  ARaceId: Integer): TArray<TAssignmentConflict>;
var
  lList: TList<TAssignmentConflict>;
  lCompetitorIds: TArray<Integer>;
  lChipId: string;
  lAssignment: TTransponderAssignment;
  lConflicts: TArray<TAssignmentConflict>;
  lConflict: TAssignmentConflict;
  lLocalName: string;
  i, j: Integer;
begin
  lList := TList<TAssignmentConflict>.Create;
  try
    lCompetitorIds := MainDataModule.GetCompetitorIdsForRace(ARaceId);
    for i := 0 to High(lCompetitorIds) do
    begin
      if TTransponderAssignmentStore.GetSingleton.TryGetActiveByRaceAndCompetitor(
           ARaceId, lCompetitorIds[i], lAssignment) then
        lChipId := NormalizeChipId(lAssignment.ChipId)
      else
        lChipId := NormalizeChipId(MainDataModule.GetCompetitorChipId(lCompetitorIds[i]));

      if lChipId = '' then
        Continue;

      lLocalName := MainDataModule.GetCompetitorDisplayName(lCompetitorIds[i]);
      lConflicts := CollectOpenConflictsForChip(lChipId, ARaceId, lCompetitorIds[i], True);
      for j := 0 to High(lConflicts) do
      begin
        lConflict := lConflicts[j];
        lConflict.LocalCompetitorId := lCompetitorIds[i];
        lConflict.LocalCompetitorDisplayName := lLocalName;
        lList.Add(lConflict);
      end;
    end;
    Result := lList.ToArray;
  finally
    FreeAndNil(lList);
  end;
end;

{==============================================================================}
class procedure TTransponderAssignmentService.EnsureAssignmentsFromCompetitorChips(
  ARaceId: Integer);
var
  lCompetitorIds: TArray<Integer>;
  i: Integer;
begin
  lCompetitorIds := MainDataModule.GetCompetitorIdsForRace(ARaceId);
  for i := 0 to High(lCompetitorIds) do
    AssignFromCompetitorChip(ARaceId, lCompetitorIds[i]);
end;

{==============================================================================}
class function TTransponderAssignmentService.PersistOpenAssignment(ARaceId, ACompetitorId: Integer;
  const AChipId: string; AValidFrom: TDateTime): Integer;
var
  lAssignment: TTransponderAssignment;
begin
  Result := MainDataModule.InsertOpenTransponderAssignment(ARaceId, ACompetitorId, AChipId, AValidFrom);
  lAssignment.AssignmentId := Result;
  lAssignment.ChipId := AChipId;
  lAssignment.CompetitorId := ACompetitorId;
  lAssignment.RaceId := ARaceId;
  lAssignment.ValidFrom := AValidFrom;
  lAssignment.ValidTo := 0;
  TTransponderAssignmentStore.GetSingleton.Upsert(lAssignment);
end;

{==============================================================================}
class procedure TTransponderAssignmentService.SyncCompetitorChipId(ACompetitorId: Integer;
  const AChipId: string);
begin
  MainDataModule.SetCompetitorChipId(ACompetitorId, AChipId);
end;

{==============================================================================}
class function TTransponderAssignmentService.Assign(ARaceId, ACompetitorId: Integer;
  const AChipId: string; out AResult: TAssignmentOperationResult;
  AValidFrom: TDateTime): Boolean;
var
  lChipId: string;
  lExisting: TTransponderAssignment;
  lValidFrom: TDateTime;
begin
  AResult := MakeEmptyResult;
  lChipId := NormalizeChipId(AChipId);
  if lChipId = '' then
  begin
    AResult.Message := cMessagesChipIdEmpty;
    Exit(False);
  end;

  if TTransponderAssignmentStore.GetSingleton.TryGetActiveByRaceAndCompetitor(
       ARaceId, ACompetitorId, lExisting) then
  begin
    if NormalizeChipId(lExisting.ChipId) = lChipId then
    begin
      AResult.Success := True;
      AResult.AssignmentId := lExisting.AssignmentId;
      AResult.Message := Format(cMessagesChipAssignOk, [lChipId]);
      Exit(True);
    end;
    (* Different chip for same race+competitor → transfer. *)
    Exit(Transfer(ARaceId, ACompetitorId, lChipId, AResult, AValidFrom));
  end;

  AResult.Conflicts := CollectOpenConflictsForChip(lChipId, ARaceId, ACompetitorId, False);
  if Length(AResult.Conflicts) > 0 then
  begin
    AResult.Message := AResult.Conflicts[0].FormatMessage;
    Exit(False);
  end;

  if AValidFrom > 0 then
    lValidFrom := AValidFrom
  else
    lValidFrom := Now;
  AResult.AssignmentId := PersistOpenAssignment(ARaceId, ACompetitorId, lChipId, lValidFrom);
  SyncCompetitorChipId(ACompetitorId, lChipId);
  AResult.Success := True;
  AResult.Message := Format(cMessagesChipAssignOk, [lChipId]);
  Result := True;
end;

{==============================================================================}
class function TTransponderAssignmentService.AssignFromCompetitorChip(ARaceId,
  ACompetitorId: Integer): Boolean;
var
  lChipId: string;
  lResult: TAssignmentOperationResult;
begin
  lChipId := NormalizeChipId(MainDataModule.GetCompetitorChipId(ACompetitorId));
  if lChipId = '' then
    Exit(False);
  Result := Assign(ARaceId, ACompetitorId, lChipId, lResult);
end;

{==============================================================================}
class function TTransponderAssignmentService.Unassign(ARaceId, ACompetitorId: Integer;
  out AResult: TAssignmentOperationResult): Boolean;
var
  lExisting: TTransponderAssignment;
  lIds: TArray<Integer>;
begin
  AResult := MakeEmptyResult;
  if not TTransponderAssignmentStore.GetSingleton.TryGetActiveByRaceAndCompetitor(
           ARaceId, ACompetitorId, lExisting) then
  begin
    AResult.Message := cMessagesChipUnassignNone;
    Exit(False);
  end;

  SetLength(lIds, 1);
  lIds[0] := ACompetitorId;
  MainDataModule.CloseTransponderAssignmentsForCompetitors(ARaceId, lIds);
  (* CloseTransponderAssignmentsForCompetitors already syncs the store.
     COMPETITORS.CHIPID stays as seed for later races / Ensure. *)

  AResult.Success := True;
  AResult.AssignmentId := lExisting.AssignmentId;
  AResult.Message := cMessagesChipUnassignOk;
  Result := True;
end;

{==============================================================================}
class function TTransponderAssignmentService.Transfer(ARaceId, ACompetitorId: Integer;
  const ANewChipId: string; out AResult: TAssignmentOperationResult;
  AValidFrom: TDateTime): Boolean;
var
  lChipId: string;
  lExisting: TTransponderAssignment;
  lIds: TArray<Integer>;
  lValidFrom: TDateTime;
begin
  AResult := MakeEmptyResult;
  lChipId := NormalizeChipId(ANewChipId);
  if lChipId = '' then
  begin
    AResult.Message := cMessagesChipIdEmpty;
    Exit(False);
  end;

  if TTransponderAssignmentStore.GetSingleton.TryGetActiveByRaceAndCompetitor(
       ARaceId, ACompetitorId, lExisting) and
     (NormalizeChipId(lExisting.ChipId) = lChipId) then
  begin
    AResult.Success := True;
    AResult.AssignmentId := lExisting.AssignmentId;
    AResult.Message := Format(cMessagesChipTransferOk, [lChipId]);
    Exit(True);
  end;

  AResult.Conflicts := CollectOpenConflictsForChip(lChipId, ARaceId, ACompetitorId, False);
  if Length(AResult.Conflicts) > 0 then
  begin
    AResult.Message := AResult.Conflicts[0].FormatMessage;
    Exit(False);
  end;

  if TTransponderAssignmentStore.GetSingleton.TryGetActiveByRaceAndCompetitor(
       ARaceId, ACompetitorId, lExisting) then
  begin
    SetLength(lIds, 1);
    lIds[0] := ACompetitorId;
    MainDataModule.CloseTransponderAssignmentsForCompetitors(ARaceId, lIds);
  end;

  if AValidFrom > 0 then
    lValidFrom := AValidFrom
  else
    lValidFrom := Now;
  AResult.AssignmentId := PersistOpenAssignment(ARaceId, ACompetitorId, lChipId, lValidFrom);
  SyncCompetitorChipId(ACompetitorId, lChipId);
  AResult.Success := True;
  AResult.Message := Format(cMessagesChipTransferOk, [lChipId]);
  Result := True;
end;

end.
