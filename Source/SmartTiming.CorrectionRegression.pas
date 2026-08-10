unit SmartTiming.CorrectionRegression;

{==============================================================================
  Plan 6 step 6 — Correction / ITT regression smoke hooks.

  Pure policy checks always run. When MainDataModule has an open database,
  participation PENALTIES round-trip and synthetic PassingNumber allocation
  are exercised (values restored after the test).
==============================================================================}

interface

uses
  System.SysUtils, System.Classes, System.Variants, Data.DB,
  SmartTiming.Consts, SmartTiming.PassingValidator, DataModule;

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
  lPartId, lRaceId: Integer;
  lOldPenalties, lCommunique, lMarker: string;
  lResultSet: TDataSet;
  lFields: TArray<string>;
  lValues: TArray<Variant>;
  lDbOk: Boolean;

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

    (* --- DB-backed smoke (optional) --- *)
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

      lPartId := 0;
      lRaceId := -1;
      lOldPenalties := '';
      MainDataModule.SQLConnection.Execute(
        'SELECT PARTICIPATIONID, RACEID, IFNULL(PENALTIES, '''') FROM PARTICIPATION ' +
        'ORDER BY PARTICIPATIONID LIMIT 1',
        nil, lResultSet);
      try
        if (lResultSet <> nil) and not lResultSet.IsEmpty then
        begin
          lPartId := lResultSet.Fields[0].AsInteger;
          lRaceId := lResultSet.Fields[1].AsInteger;
          lOldPenalties := lResultSet.Fields[2].AsString;
        end;
      finally
        FreeAndNil(lResultSet);
      end;

      if lPartId <= 0 then
        lLines.Add('SKIP PENALTIES round-trip (no PARTICIPATION row)')
      else
      begin
        lMarker := Format('ST-CORR-REG %s', [FormatDateTime('yyyymmddhhnnss', Now)]);
        SetLength(lFields, 1);
        SetLength(lValues, 1);
        lFields[0] := 'PENALTIES';
        lValues[0] := lMarker;
        try
          MainDataModule.UpdateParticipationValues(lPartId, lFields, lValues);
          if SameText(Trim(MainDataModule.GetParticipationStringField(lPartId, 'PENALTIES')),
            lMarker) then
            Pass('PENALTIES persist via UpdateParticipationValues')
          else
            Fail('PENALTIES persist', 'read-back mismatch');

          lCommunique := MainDataModule.GetPenaltyCommuniqueText(lRaceId);
          if (Pos(cMessagesCommuniqueHeader, lCommunique) > 0) and
             (Pos(lMarker, lCommunique) > 0) then
            Pass('GetPenaltyCommuniqueText includes header + freitext')
          else
            Fail('GetPenaltyCommuniqueText', 'missing header or freitext');
        finally
          lValues[0] := lOldPenalties;
          MainDataModule.UpdateParticipationValues(lPartId, lFields, lValues);
        end;

        if SameText(Trim(MainDataModule.GetParticipationStringField(lPartId, 'PENALTIES')),
          Trim(lOldPenalties)) then
          Pass('PENALTIES restored after smoke')
        else
          Fail('PENALTIES restore', 'original value not restored');
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
