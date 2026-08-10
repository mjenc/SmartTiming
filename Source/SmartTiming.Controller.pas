unit SmartTiming.Controller;

interface

uses
  Windows, MMSystem, SysUtils, Generics.Collections, Classes, SyncObjs,
  SmartTiming.Consts, SmartTiming.DecoderEngine, DecoderInterface, SmartTiming.Tools,
  DataModule, SmartTiming.Event, SmartTiming.WebService,
  RaceEngine.Custom, SmartTiming.PassingValidator;

type
  TAmbiguousChipAssignmentEvent = procedure(const AChipId: string; APassingTime: TDateTime;
    AMatchCount: Integer) of object;

  TSmartTimingController = class
  private
    FDecoderEngine: TDecoderEngine;
    FPlayPassingSound: boolean;
    FDatabasePath: string;
    FEventDataObject: TEventDataObject;
    FRaceList: TDictionary<integer, TRaceItem>;
    FServlet: TSmartTimingServlet;
    FOnAmbiguousChipAssignment: TAmbiguousChipAssignmentEvent;
    FOnPlausibilityDecision: TPlausibilityDecisionEvent;
    FOnPlausibilityStatsChanged: TPlausibilityStatsEvent;
    FAlwaysAcceptChips: TDictionary<string, Boolean>;
    FPlausibilityStats: TPlausibilitySessionStats;
    FPlausibilityLock: TCriticalSection;
    FLastManualPassingResult: TManualPassingResult;

    procedure OnDecoderFound(ADecoder: TDecoder);
    procedure OnStatusReceived(AStatus: TDecoderStatus);
    procedure OnPassingReceived(APassing: TPassing);
    procedure CaptureManualPassingResult(const AValidation: TPassingValidationResult;
      AIsManual: Boolean);
    function GetMinLapDurationForRace(ARaceId: Integer): Integer;
    function IsAlwaysAcceptChip(const AChipId: string): Boolean;
    function IsMinLapOnlyAsk(const AValidation: TPassingValidationResult): Boolean;
    procedure NotifyPlausibilityStatsChanged;
    procedure RecordPlausibilityOutcome(const APassing: TPassing; ARaceId: Integer;
      const AValidation: TPassingValidationResult; AAlwaysAccepted: Boolean);
    function GetPlausibilityStatsSnapshot: TPlausibilitySessionStats;
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadSettings;
    procedure LoadEventData(const AEventPath: string);
    procedure LoadRaces;
    procedure SaveEvent(AEventDataObject: TEventDataObject); overload;
    procedure SaveEvent(const AOrganizer, ATitle: string; ADateFrom, ADateTo: TDatetime); overload;
    procedure RestorePassings;
    procedure UpdatePassing(APassingNumber: Integer; APassingTime: TDatetime; APassingState: TPassingState);
    procedure RemovePassing(APassingNumber: Integer);
    function AddManualPassing(var APassing: TPassing): TManualPassingResult;
    procedure ResetRacesDataSet;
    procedure ChangeRaceStatus(ARaceId: Integer; ARaceStatus: TRaceStatus);
    procedure RetryDecoderSearch;
    procedure ImportTRIATimes(const AFileName: string);
    procedure RememberAlwaysAcceptChip(const AChipId: string);
    procedure ClearAlwaysAcceptChips;
    procedure ResetPlausibilityStats;
    procedure ApplyPlausibilityAccept(APassingNumber, ARaceId: Integer);
    property Event: TEventDataObject read FEventDataObject;
    property RaceList: TDictionary<integer, TRaceItem> read FRaceList;
    property PlausibilityStats: TPlausibilitySessionStats read GetPlausibilityStatsSnapshot;
    property OnAmbiguousChipAssignment: TAmbiguousChipAssignmentEvent
      read FOnAmbiguousChipAssignment write FOnAmbiguousChipAssignment;
    property OnPlausibilityDecision: TPlausibilityDecisionEvent
      read FOnPlausibilityDecision write FOnPlausibilityDecision;
    property OnPlausibilityStatsChanged: TPlausibilityStatsEvent
      read FOnPlausibilityStatsChanged write FOnPlausibilityStatsChanged;
  end;

var
  GSmartTimingController: TSmartTimingController;

implementation

uses
  FormMain, SmartTiming.Cache, SmartTiming.TransponderAssignment, Tools.Logger;

const
  cLogger = 'SmartTiming.Controller';

{==============================================================================}
constructor TSmartTimingController.Create;
begin
  LogOnDebug(cLogger, ['Creating controller']);
  LoadSettings;

  FEventDataObject := TEventDataObject.Create;
  FAlwaysAcceptChips := TDictionary<string, Boolean>.Create;
  FPlausibilityLock := TCriticalSection.Create;
  FPlausibilityStats.Clear;

  FDecoderEngine := TDecoderEngine.GetSingleton;
  FDecoderEngine.OnDecoderFound := OnDecoderFound;
  FDecoderEngine.NewPassingReceived := OnPassingReceived;
  FDecoderEngine.NewStatusReceived := OnStatusReceived;
  FDecoderEngine.RefreshDecoderList;

  FRaceList := TDictionary<integer, TRaceItem>.Create;

  FServlet := TSmartTimingServlet.Create(cWebServicePort);
  FServlet.StartService(cWebServicePort);
end;

{==============================================================================}
destructor TSmartTimingController.Destroy;
var
  lRaceItem: TRaceItem;
begin
  try
    LogOnDebug(cLogger, ['Destroying controller']);
    FreeAndNil(FServlet);
    if FRaceList <> nil then
    begin
      for lRaceItem in FRaceList.Values do
        FreeAndNil(lRaceItem);
      FreeAndNil(FRaceList);
    end;
    FreeAndNil(FEventDataObject);
    FreeAndNil(FAlwaysAcceptChips);
    FreeAndNil(FPlausibilityLock);
  finally
    inherited Destroy;
  end;
end;

{==============================================================================}
procedure TSmartTimingController.LoadSettings;
begin
//  Sound Effect by https://pixabay.com
  FPlayPassingSound := SmartTimingTools.RegistryReadBool(HKEY_CURRENT_USER, cRegKeyPath + '\Settings', 'BeepOnPassing', true);

  LogOnDebug(cLogger, ['LoadSettings', 'PlayPassingSound=' + BoolToStr(FPlayPassingSound, true)]);
end;

{==============================================================================}
procedure TSmartTimingController.RetryDecoderSearch;
begin
  try
    LogOnDebug(cLogger, ['RetryDecoderSearch']);
    if FDecoderEngine.Connected then
    begin
      LogOnDebug(cLogger, ['Decoder already connected.']);
      Exit;
    end;
    FDecoderEngine.RefreshDecoderList;
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['RetryDecoderSearch']);
  end;
end;

{==============================================================================}
procedure TSmartTimingController.LoadEventData(const AEventPath: string);
begin
  try
    LogOnDebug(cLogger, ['LoadEventData']);
    ClearAlwaysAcceptChips;
    ResetPlausibilityStats;
    FDatabasePath := AEventPath;
    MainDataModule.OpenDatabase(FDatabasePath);
    FEventDataObject.RefreshFromDatabase;
    GFormMain.RefreshControlsFromEventDataObject(FEventDataObject);
    SaveEvent(FEventDataObject);

    MainDataModule.RefreshRacesDataSet(FEventDataObject.EventId);
    ResetRacesDataSet;
    LoadRaces;
    MainDataModule.FillTransponderAssignmentCache;
    RestorePassings;
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['LoadEventData']);
  end;
end;

{==============================================================================}
procedure TSmartTimingController.LoadRaces;
var
  lRaceItem: TRaceItem;
  lRaceId: integer;
  i: integer;
  lVisited: TList<Integer>;
  lOrphanIds: TArray<Integer>;
  lOrphanCount: Integer;
begin
  try
    LogOnDebug(cLogger, ['LoadRaces']);
    lVisited := TList<Integer>.Create;
    try
      MainDataModule.SQLDataSetRaces.Refresh;
      MainDataModule.DataSourceRaces.DataSet.Refresh;
      MainDataModule.DataSourceRaces.DataSet.First;
      while not MainDataModule.DataSourceRaces.DataSet.Eof do
      begin
        lRaceId := MainDataModule.DataSourceRaces.DataSet.FieldByName('RACEID').Value;
        if not FRaceList.TryGetValue(lRaceId, lRaceItem) then
        begin
          lRaceItem := TRaceItem.Create;
          FRaceList.Add(lRaceId, lRaceItem);
        end;

        SmartTimingTools.FillRaceItemFromDataSet(MainDataModule.DataSourceRaces.DataSet, lRaceItem);
        if lRaceItem.RaceEngine = nil then
        begin
          if not SmartTimingTools.IsRaceTypeSupported(lRaceItem.RaceType) then
            raise Exception.Create(cMessagesRaceTypeUnknown);
          lRaceItem.RaceEngine := TRaceEngineFactory.CreateRaceEngineForRaceType(
            GFormMain.GetNewPanelForPassings(lRaceId), FEventDataObject, lRaceItem);
        end;

        lVisited.Add(lRaceId);
        MainDataModule.DataSourceRaces.DataSet.Next;
      end;

      // Remove races that no longer exist in the dataset (fix: use key i, not stale lRaceItem).
      lOrphanCount := 0;
      SetLength(lOrphanIds, FRaceList.Count);
      for i in FRaceList.Keys do
      begin
        if lVisited.IndexOf(i) < 0 then
        begin
          lOrphanIds[lOrphanCount] := i;
          Inc(lOrphanCount);
        end;
      end;

      for i := 0 to lOrphanCount - 1 do
      begin
        if FRaceList.TryGetValue(lOrphanIds[i], lRaceItem) then
        begin
          FRaceList.Remove(lOrphanIds[i]);
          FreeAndNil(lRaceItem);
        end;
      end;

    finally
      FreeAndNil(lVisited);
    end;
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['LoadRaces']);
  end;
end;

{==============================================================================}
procedure TSmartTimingController.SaveEvent(AEventDataObject: TEventDataObject);
begin
  SaveEvent(AEventDataObject.Organizer, AEventDataObject.Title, AEventDataObject.DateFrom, AEventDataObject.DateTo);
end;

{==============================================================================}
procedure TSmartTimingController.SaveEvent(const AOrganizer, ATitle: string; ADateFrom, ADateTo: TDatetime);
var
  lYear: Word;
  lMonth: Word;
  lDay: Word;
begin
  try
    LogOnDebug(cLogger, ['SaveEvent']);
    FEventDataObject.Organizer := AOrganizer;
    FEventDataObject.Title := ATitle;
    FEventDataObject.DateFrom := ADateFrom;
    FEventDataObject.DateTo := ADateTo;
    FEventDataObject.SaveToDatabase;

    DecodeDate(ADateFrom, lYear, lMonth, lDay);
    MainDataModule.PushEventToHistory(Format('%d-%2d-%2d %s | %s', [lYear, lMonth, lDay, AOrganizer, ATitle]));
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['SaveEvent']);
  end;
end;

{==============================================================================}
procedure TSmartTimingController.RestorePassings;
var
  lRaceIds: TArray<integer>;
  lRaceId: integer;
  lPassings: TArray<TPassing>;
  i: integer;
  lRaceItem: TRaceItem;
begin
  try
    LogOnDebug(cLogger, ['RestorePassings']);
    TUnassignedPassingStore.GetSingleton.Clear;
    lRaceIds := GFormMain.GetAllRaceIds;
    for lRaceId in lRaceIds do
    begin
      lPassings := MainDataModule.GetAllPassingsForRaceId(lRaceId);
      for i := 0 to Length(lPassings) - 1 do
      begin
        TPassingStore.GetSingleton.AddPassing(lPassings[i]);
        GFormMain.AddPassingForRaceId(lRaceId, lPassings[i]);
      end;
    end;

    lPassings := MainDataModule.GetUnassignedPassings;
    for i := 0 to High(lPassings) do
    begin
      TPassingStore.GetSingleton.AddPassing(lPassings[i]);
      TUnassignedPassingStore.GetSingleton.AddPassing(lPassings[i]);
    end;

    for lRaceId in lRaceIds do
    begin
      if FRaceList.TryGetValue(lRaceId, lRaceItem) and (lRaceItem.RaceEngine <> nil) then
        lRaceItem.RaceEngine.ReassignLapsForRace;
    end;
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['RestorePassings']);
  end;
end;

{==============================================================================}
procedure TSmartTimingController.ResetRacesDataSet;
begin
  MainDataModule.RefreshRacesDataSet(FEventDataObject.EventId);
end;

{==============================================================================}
procedure TSmartTimingController.ChangeRaceStatus(ARaceId: Integer; ARaceStatus: TRaceStatus);
var
  lPassing: TPassing;
  lRaceItem: TRaceItem;
begin
  try
    LogOnDebug(cLogger, ['ChangeRaceStatus']);

    MainDataModule.SetRaceStatus(ARaceId, ARaceStatus);
    if FRaceList.TryGetValue(ARaceId, lRaceItem) then
      lRaceItem.Status := ARaceStatus;

    (* Terminal statuses free chips for reuse in later races. *)
    if ARaceStatus in [rsFinished, rsAborted, rsStopped] then
      MainDataModule.CloseAllOpenTransponderAssignmentsForRace(ARaceId);

    lPassing.PassingNumber := MainDataModule.AllocateSyntheticPassingNumber;
    lPassing.ChipId := '';
    lPassing.PassingTime := Now;
    lPassing.SignalStrength := 100;
    lPassing.Hits := 0 - Ord(ARaceStatus);
    lPassing.Flags := 2;
    lPassing.Sport := sSportsIdCycling;
    lPassing.DecoderId := 'SYSTEM';
    lPassing.RaceId := ARaceId;
    lPassing.PassingStatus := Ord(psValid);
    lPassing.LapIndex := -1;
    lPassing.CompetitorId := -1;

    MainDataModule.AddPassingToDatabase(lPassing, ARaceId);
    (* RecalcCountingLaps reads markers from PassingStore — keep in sync with DB. *)
    TPassingStore.GetSingleton.AddPassing(lPassing);

    GFormMain.AddPassingForRaceId(ARaceId, lPassing);
    GFormMain.RefreshFlagButtonsActive(ARaceStatus);
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['ChangeRaceStatus']);
  end;
end;

{==============================================================================}
procedure TSmartTimingController.OnDecoderFound(ADecoder: TDecoder);
begin
  GFormMain.DecoderConnected(ADecoder);
end;

{==============================================================================}
function TSmartTimingController.GetMinLapDurationForRace(ARaceId: Integer): Integer;
var
  lRaceItem: TRaceItem;
begin
  (* Prefer in-memory TRaceItem (kept in sync via LoadRaces / race details). *)
  if (ARaceId >= 0) and FRaceList.TryGetValue(ARaceId, lRaceItem) then
    Exit(lRaceItem.MinLapDuration);
  if ARaceId >= 0 then
    Exit(MainDataModule.GetRaceMinLapDuration(ARaceId));
  Result := 0;
end;

{==============================================================================}
procedure TSmartTimingController.OnStatusReceived(AStatus: TDecoderStatus);
begin
  try
    LogOnDebug(cLogger, ['OnStatusReceived']);
    GFormMain.AddDecoderStatus(AStatus);
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['OnStatusReceived']);
  end;
end;

{==============================================================================}
procedure TSmartTimingController.OnPassingReceived(APassing: TPassing);
var
  lRaceId: integer;
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
    LogOnDebug(cLogger, ['OnPassingReceived']);
    if FPlayPassingSound then
      PlaySound('PassingBeep', 0, SND_NOSTOP or SND_NOWAIT or SND_RESOURCE or SND_ASYNC or SND_NODEFAULT);

    (* System markers only from ChangeRaceStatus (DecoderId=SYSTEM); skip plausibility. *)
    if ((APassing.Flags and 2) = 2) and SameText(APassing.DecoderId, 'SYSTEM') then
    begin
      lRaceId := APassing.RaceId;
      APassing.PassingStatus := Ord(psValid);
      MainDataModule.AddPassingToDatabase(APassing, lRaceId, True);
      APassing.RaceId := lRaceId;
      TPassingStore.GetSingleton.AddPassing(APassing);
      TPassingStore.GetSingleton.UpdatePassingRaceId(APassing.PassingNumber, lRaceId);
      GFormMain.AddPassingForRaceId(lRaceId, APassing);
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
      lMinLap := GetMinLapDurationForRace(lResolution.RaceId)
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

    APassing.RaceId := lRaceId;
    MainDataModule.AddPassingToDatabase(APassing, lRaceId, True);
    APassing.RaceId := lRaceId;
    TPassingStore.GetSingleton.UpdatePassingRaceId(APassing.PassingNumber, lRaceId);
    TPassingStore.GetSingleton.UpdatePassingStatus(APassing.PassingNumber, APassing.PassingStatus);

    if (lRaceId < 0) and ((APassing.Flags and 2) <> 2) then
    begin
      TUnassignedPassingStore.GetSingleton.AddPassing(APassing);
      LogOnDebug(cLogger, ['Unassigned passing', APassing.ChipId,
        FormatDateTime('hh:nn:ss.zzz', APassing.PassingTime)]);
    end
    else
      TUnassignedPassingStore.GetSingleton.RemovePassing(APassing.PassingNumber);

    (* Display always; participation update only for accepted (engine checks status). *)
    GFormMain.AddPassingForRaceId(lRaceId, APassing);

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
          if Assigned(GSmartTimingController) and
             Assigned(GSmartTimingController.OnPlausibilityDecision) then
            GSmartTimingController.OnPlausibilityDecision(lRequest);
        end);
    end;
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['OnPassingReceived']);
  end;
end;

{==============================================================================}
procedure TSmartTimingController.CaptureManualPassingResult(
  const AValidation: TPassingValidationResult; AIsManual: Boolean);
begin
  if not AIsManual then
    Exit;
  FLastManualPassingResult.Disposition := AValidation.Disposition;
  FLastManualPassingResult.Scored := AValidation.Disposition in [pdAccept, pdAcceptMarked];
  FLastManualPassingResult.NeedsConfirmation := AValidation.Disposition = pdAskOperator;
  FLastManualPassingResult.Message := AValidation.FormatFindings;
end;

{==============================================================================}
function TSmartTimingController.AddManualPassing(var APassing: TPassing): TManualPassingResult;
begin
  try
    LogOnDebug(cLogger, ['AddManualPassing']);
    FLastManualPassingResult.Disposition := pdReject;
    FLastManualPassingResult.Scored := False;
    FLastManualPassingResult.NeedsConfirmation := False;
    FLastManualPassingResult.Message := '';

    APassing.PassingNumber := MainDataModule.AllocateSyntheticPassingNumber;
    TDecoderEngine.GetSingleton.SendSimulatedPassing(APassing);
    Result := FLastManualPassingResult;
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['AddManualPassing']);
  end;
end;

{==============================================================================}
procedure TSmartTimingController.ImportTRIATimes(const AFileName: string);
var
  lLines: TStringList;
  i: Integer;
  lBib: Integer;
  lTime: TDatetime;
  lPassing: TPassing;
begin
  lLines := TStringList.Create;
  lLines.NameValueSeparator := #9;
  lLines.LoadFromFile(AFileName);
  for i := 0 to lLines.Count - 1 do
  begin
    if lLines[i].IsEmpty then
      Continue;
     lBib := lLines.Names[i].ToInteger;
    if not TryStrToTime(lLines.ValueFromIndex[i], lTime) then
      Continue;

    lPassing.PassingNumber := i + 1;
    lPassing.PassingTime := lTime;
    lPassing.ChipId := Format('ZZ-%.4d', [lBib]);
    lPassing.SignalStrength := 123;
    lpAssing.Hits := 90;
    lPassing.Flags := 0;
    lPassing.Sport := sSportsIdCycling;
    lPassing.Voltage := 9;
    lPassing.Temperature := 20;
    lPassing.DecoderId := 'TRIA';
    TDecoderEngine.GetSingleton.SendSimulatedPassing(lPassing);
  end;
end;

{==============================================================================}
procedure TSmartTimingController.UpdatePassing(APassingNumber: Integer; APassingTime: TDatetime; APassingState: TPassingState);
begin
  try
    LogOnDebug(cLogger, ['UpdatePassing']);
    MainDataModule.UpdatePassingInDatabase(APassingNumber, APassingTime, APassingState);
    TPassingStore.GetSingleton.UpdatePassing(APassingNumber, APassingTime);
    TPassingStore.GetSingleton.UpdatePassingStatus(APassingNumber, Ord(APassingState));
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['UpdatePassing']);
  end;
end;

{==============================================================================}
procedure TSmartTimingController.RemovePassing(APassingNumber: Integer);
begin
  try
    LogOnDebug(cLogger, ['RemovePassing']);
    MainDataModule.RemovePassingFromDatabase(APassingNumber);
    TPassingStore.GetSingleton.RemovePassing(APassingNumber);
    TUnassignedPassingStore.GetSingleton.RemovePassing(APassingNumber);
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['RemovePassing']);
  end;
end;

{==============================================================================}
function TSmartTimingController.IsAlwaysAcceptChip(const AChipId: string): Boolean;
begin
  FPlausibilityLock.Enter;
  try
    Result := (FAlwaysAcceptChips <> nil) and
      FAlwaysAcceptChips.ContainsKey(NormalizeChipId(AChipId));
  finally
    FPlausibilityLock.Leave;
  end;
end;

{==============================================================================}
function TSmartTimingController.IsMinLapOnlyAsk(
  const AValidation: TPassingValidationResult): Boolean;
begin
  Result := (AValidation.Disposition = pdAskOperator) and
    (AValidation.TriggeredRules = [pvrMinLapDuration]);
end;

{==============================================================================}
procedure TSmartTimingController.RememberAlwaysAcceptChip(const AChipId: string);
var
  lKey: string;
begin
  lKey := NormalizeChipId(AChipId);
  if lKey = '' then
    Exit;
  FPlausibilityLock.Enter;
  try
    if FAlwaysAcceptChips = nil then
      Exit;
    FAlwaysAcceptChips.AddOrSetValue(lKey, True);
  finally
    FPlausibilityLock.Leave;
  end;
  LogOnInfo(cLogger, ['Always-accept chip remembered for session (MinLap)', lKey]);
end;

{==============================================================================}
procedure TSmartTimingController.ClearAlwaysAcceptChips;
begin
  FPlausibilityLock.Enter;
  try
    if FAlwaysAcceptChips <> nil then
      FAlwaysAcceptChips.Clear;
  finally
    FPlausibilityLock.Leave;
  end;
end;

{==============================================================================}
function TSmartTimingController.GetPlausibilityStatsSnapshot: TPlausibilitySessionStats;
begin
  FPlausibilityLock.Enter;
  try
    Result := FPlausibilityStats;
  finally
    FPlausibilityLock.Leave;
  end;
end;

{==============================================================================}
procedure TSmartTimingController.ResetPlausibilityStats;
begin
  FPlausibilityLock.Enter;
  try
    FPlausibilityStats.Clear;
  finally
    FPlausibilityLock.Leave;
  end;
  NotifyPlausibilityStatsChanged;
end;

{==============================================================================}
procedure TSmartTimingController.NotifyPlausibilityStatsChanged;
var
  lStats: TPlausibilitySessionStats;
begin
  if not Assigned(FOnPlausibilityStatsChanged) then
    Exit;
  lStats := GetPlausibilityStatsSnapshot;
  TThread.Queue(nil,
    procedure
    begin
      if Assigned(GSmartTimingController) and
         Assigned(GSmartTimingController.OnPlausibilityStatsChanged) then
        GSmartTimingController.OnPlausibilityStatsChanged(lStats);
    end);
end;

{==============================================================================}
procedure TSmartTimingController.RecordPlausibilityOutcome(const APassing: TPassing;
  ARaceId: Integer; const AValidation: TPassingValidationResult; AAlwaysAccepted: Boolean);
var
  lLine: string;
begin
  (* Clean accepts are silent in the status counters. *)
  if (AValidation.Disposition = pdAccept) and not AAlwaysAccepted then
    Exit;

  FPlausibilityLock.Enter;
  try
    if AAlwaysAccepted then
      Inc(FPlausibilityStats.AlwaysAccepted)
    else
      case AValidation.Disposition of
        pdAcceptMarked:
          Inc(FPlausibilityStats.AcceptedMarked);
        pdAskOperator:
          Inc(FPlausibilityStats.AskOperator);
        pdReject:
          Inc(FPlausibilityStats.Rejected);
      end;
  finally
    FPlausibilityLock.Leave;
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
procedure TSmartTimingController.ApplyPlausibilityAccept(APassingNumber, ARaceId: Integer);
var
  lPassing: TPassing;
  lRaceItem: TRaceItem;
begin
  try
    LogOnDebug(cLogger, ['ApplyPlausibilityAccept', APassingNumber.ToString, ARaceId.ToString]);
    if ARaceId < 0 then
      Exit;

    lPassing := TPassingStore.GetSingleton.GetPassing(APassingNumber);
    UpdatePassing(APassingNumber, lPassing.PassingTime, psValid);

    if FRaceList.TryGetValue(ARaceId, lRaceItem) and (lRaceItem.RaceEngine <> nil) then
    begin
      lRaceItem.RaceEngine.RecalcCountingLaps;
      lRaceItem.RaceEngine.ReassignLapsForRace;
      lRaceItem.RaceEngine.RebuildProtocolDisplay;
    end;

    FPlausibilityLock.Enter;
    try
      Inc(FPlausibilityStats.OperatorAccepted);
    finally
      FPlausibilityLock.Leave;
    end;
    LogOnInfo(cLogger, [
      Format('Plausibility OperatorAccepted chip=%s race=%d passing=%d',
        [lPassing.ChipId, ARaceId, APassingNumber])]);
    NotifyPlausibilityStatsChanged;
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['ApplyPlausibilityAccept']);
  end;
end;

end.
