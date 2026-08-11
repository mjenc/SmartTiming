unit SmartTiming.CorrectionRegression;

{==============================================================================
  Plan 6 step 6 — Correction / ITT regression smoke hooks.

  Pure policy checks always run. When MainDataModule has an open database,
  read-only checks run (synthetic PassingNumber, communique lookup).
  PENALTIES are not written: freitext does not affect ranking/times, and
  mutating the live event DB in a smoke test is unnecessary risk.
==============================================================================}

interface

uses
  System.SysUtils, System.Classes, Data.DB, Data.SqlExpr,
  SmartTiming.Consts, SmartTiming.PassingValidator, DecoderInterface, DataModule;

type
  TCorrectionRegression = class
  public
    class function RunSelfTests(out AReport: string): Boolean; static;
  end;

implementation

{==============================================================================}
class function TCorrectionRegression.RunSelfTests(out AReport: string): Boolean;
var
  lLines: TStringList;
  lFailed: Integer;
  lCtx: TPassingValidationContext;
  lResult: TPassingValidationResult;
  lSynth: Integer;
  lRaceId: Integer;
  lCommunique: string;
  lDataSet: TSQLDataSet;
  lDbOk: Boolean;
  lPassing: TPassing;

  procedure Pass(const AName: string);
  begin
    lLines.Add('OK  ' + AName);
  end;

  procedure Fail(const AName, ADetail: string);
  begin
    Inc(lFailed);
    lLines.Add('FAIL ' + AName + ' — ' + ADetail);
  end;

  procedure ExpectDisposition(const AName: string;
    const AContext: TPassingValidationContext;
    AExpected: TPassingDisposition; AMustInclude: TPassingValidationRules);
  var
    lRule: TPassingValidationRule;
    lOk: Boolean;
  begin
    lResult := TPassingValidator.Validate(AContext);
    lOk := lResult.Disposition = AExpected;
    for lRule := Low(TPassingValidationRule) to High(TPassingValidationRule) do
      if (lRule in AMustInclude) and not (lRule in lResult.TriggeredRules) then
        lOk := False;
    if lOk then
      Pass(AName)
    else
      Fail(AName, Format('disposition %d (expected %d); %s',
        [Ord(lResult.Disposition), Ord(AExpected), lResult.PrimaryMessage]));
  end;

begin
  lFailed := 0;
  lLines := TStringList.Create;
  try
    lLines.Add('Correction / ITT regression self-tests (Plan 6)');

    (* --- Policy: parallel conflict stays ask; manual → marked --- *)
    lCtx := TPassingValidationContext.MakeCleanLiveHit('CL-REG01',
      EncodeDate(2026, 8, 10) + EncodeTime(14, 0, 0, 0), 1, 10, 20, 0);
    lCtx.ParallelChipConflict := True;
    ExpectDisposition('parallel chip conflict → AskOperator', lCtx, pdAskOperator,
      [pvrParallelChipConflict]);

    lCtx.IsManual := True;
    ExpectDisposition('manual + parallel conflict → AcceptMarked', lCtx, pdAcceptMarked,
      [pvrParallelChipConflict]);

    (* --- Constants / contract surface used by correction UI --- *)
    if Trim(cMessagesCommuniqueHeader) <> '' then
      Pass('communique header constant')
    else
      Fail('communique header constant', 'empty');

    if Trim(cMessagesNoParticipantSelected) <> '' then
      Pass('no-selection message constant')
    else
      Fail('no-selection message constant', 'empty');

    if Trim(cMessagesPassingIsSystemMarker) <> '' then
      Pass('system-marker message constant')
    else
      Fail('system-marker message constant', 'empty');

    if Trim(cMessagesWarmUpFlagTimeFixed) <> '' then
      Pass('warm-up flag time-fixed message constant')
    else
      Fail('warm-up flag time-fixed message constant', 'empty');

    if Trim(cMessagesNewLeaderHint) <> '' then
      Pass('new-leader hint constant')
    else
      Fail('new-leader hint constant', 'empty');

    if Trim(cMessagesPointsSprintFinalLapHint) <> '' then
      Pass('points-sprint final-lap hint constant')
    else
      Fail('points-sprint final-lap hint constant', 'empty');

    (* --- Circuit/Criterium SYSTEM Hits contract (CreateSchema HITS=-2 etc.) --- *)
    if (cSystemHitsStarted = -Ord(rsStarted)) and
       (cSystemHitsWarmUp = -Ord(rsWarmUp)) and
       (cSystemHitsNewLeader = -Ord(rsNewLeader)) and
       (cSystemHitsPointsSprint = -Ord(rsPointsSprint)) then
      Pass('cSystemHits* match -Ord(TRaceStatus)')
    else
      Fail('cSystemHits* match -Ord(TRaceStatus)', 'enum/const drift');

    if (rsNewLeader in cRaceEventMarkers) and (rsPointsSprint in cRaceEventMarkers) and
       not (rsStarted in cRaceEventMarkers) then
      Pass('cRaceEventMarkers = Neue Spitze + Punkte only')
    else
      Fail('cRaceEventMarkers', 'unexpected membership');

    lPassing := Default(TPassing);
    lPassing.Flags := 2;
    lPassing.DecoderId := 'SYSTEM';
    lPassing.Hits := cSystemHitsWarmUp;
    if lPassing.IsWarmUpFlag and lPassing.IsSystemMarker then
      Pass('IsWarmUpFlag for SYSTEM Hits=-1')
    else
      Fail('IsWarmUpFlag', 'warm-up marker not detected');

    lPassing.Hits := cSystemHitsStarted;
    if (not lPassing.IsWarmUpFlag) and lPassing.IsSystemMarker then
      Pass('IsWarmUpFlag false for green start')
    else
      Fail('IsWarmUpFlag false for green start', 'misclassified');

    (* --- DB-backed smoke (read-only) --- *)
    lDbOk := (MainDataModule <> nil) and MainDataModule.SQLConnection.Connected;
    if not lDbOk then
    begin
      lLines.Add('SKIP DB tests (no connected database)');
    end
    else
    begin
      lSynth := MainDataModule.AllocateSyntheticPassingNumber;
      if lSynth < 0 then
        Pass(Format('synthetic PassingNumber is negative (%d)', [lSynth]))
      else
        Fail('synthetic PassingNumber', Format('got %d (expected < 0)', [lSynth]));

      if MainDataModule.AllocateSyntheticPassingNumber = lSynth then
        Pass('synthetic allocation is read-only until insert')
      else
        Fail('synthetic allocation', 'second call without insert changed value');

      if MainDataModule.GetPenaltyCommuniqueText(-1) = '' then
        Pass('communique empty for invalid race')
      else
        Fail('communique empty for invalid race', 'non-empty');

      (* Read-only: if any race already has penalties, communique must carry header. *)
      lRaceId := -1;
      lDataSet := MainDataModule.OpenReadOnlyQuery(
        'SELECT P.RACEID FROM PARTICIPATION P ' +
        'WHERE IFNULL(TRIM(P.PENALTIES), '''') <> '''' ' +
        'ORDER BY P.PARTICIPATIONID LIMIT 1');
      try
        if (lDataSet <> nil) and lDataSet.Active and not lDataSet.IsEmpty then
          lRaceId := lDataSet.Fields[0].AsInteger;
      finally
        FreeAndNil(lDataSet);
      end;

      if lRaceId < 0 then
        lLines.Add('SKIP communique content check (no PENALTIES in DB)')
      else
      begin
        lCommunique := MainDataModule.GetPenaltyCommuniqueText(lRaceId);
        if Pos(cMessagesCommuniqueHeader, lCommunique) > 0 then
          Pass('GetPenaltyCommuniqueText includes header for existing freitext')
        else
          Fail('GetPenaltyCommuniqueText', 'missing header for race with PENALTIES');
      end;
    end;

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
