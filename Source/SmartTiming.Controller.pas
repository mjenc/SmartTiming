unit SmartTiming.Controller;

interface

uses
  Windows, MMSystem, SysUtils, Generics.Collections, Classes,
  SmartTiming.Consts, SmartTiming.DecoderEngine, DecoderInterface, SmartTiming.Tools,
  DataModule, SmartTiming.Event, SmartTiming.WebService,
  RaceEngine.Custom, SmartTiming.PassingValidator, SmartTiming.PassingService;

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
    FPassingService: TPassingService;
    FOnAmbiguousChipAssignment: TAmbiguousChipAssignmentEvent;

    procedure OnDecoderFound(ADecoder: TDecoder);
    procedure OnStatusReceived(AStatus: TDecoderStatus);
    procedure OnPassingReceived(APassing: TPassing);
    procedure OnDisplayIngestedPassing(ARaceId: Integer; const APassing: TPassing);
    function GetMinLapDurationForRace(ARaceId: Integer): Integer;
    function TryGetContextRaceIdForOrphanPassing: Integer;
    function GetPlausibilityStatsSnapshot: TPlausibilitySessionStats;
    function GetOnPlausibilityDecision: TPlausibilityDecisionEvent;
    procedure SetOnPlausibilityDecision(const AValue: TPlausibilityDecisionEvent);
    function GetOnPlausibilityStatsChanged: TPlausibilityStatsEvent;
    procedure SetOnPlausibilityStatsChanged(const AValue: TPlausibilityStatsEvent);
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
    procedure ChangeRaceStatus(ARaceId: Integer; ARaceStatus: TRaceStatus); overload;
    procedure ChangeRaceStatus(ARaceId: Integer; ARaceStatus: TRaceStatus;
      APassingTime: TDateTime); overload;
    (* Circuit/Criterium: place Ziel-Flagge 1ms before the leader's finishing
       crossing if none exists yet. Updates RACES.STATUS; flag remains movable. *)
    function EnsureFinishFlagBeforeLeader(ARaceId: Integer;
      ALeaderFinishTime: TDateTime): Boolean;
    procedure RetryDecoderSearch;
    procedure ImportTRIATimes(const AFileName: string);
    procedure RememberAlwaysAcceptChip(const AChipId: string);
    procedure ClearAlwaysAcceptChips;
    procedure ResetPlausibilityStats;
    procedure ApplyPlausibilityAccept(APassingNumber, ARaceId: Integer);
    procedure ApplyPlausibilityReject(APassingNumber, ARaceId: Integer);
    (* After chip Assign/Transfer: reattach orphans + rebuild race protocol/ranking. *)
    function AfterChipAssignedToCompetitor(ARaceId, ACompetitorId: Integer;
      const AChipId: string): Integer;
    property Event: TEventDataObject read FEventDataObject;
    property RaceList: TDictionary<integer, TRaceItem> read FRaceList;
    property PlausibilityStats: TPlausibilitySessionStats read GetPlausibilityStatsSnapshot;
    property OnAmbiguousChipAssignment: TAmbiguousChipAssignmentEvent
      read FOnAmbiguousChipAssignment write FOnAmbiguousChipAssignment;
    property OnPlausibilityDecision: TPlausibilityDecisionEvent
      read GetOnPlausibilityDecision write SetOnPlausibilityDecision;
    property OnPlausibilityStatsChanged: TPlausibilityStatsEvent
      read GetOnPlausibilityStatsChanged write SetOnPlausibilityStatsChanged;
  end;

var
  GSmartTimingController: TSmartTimingController;

implementation

uses
  FormMain, SmartTiming.Cache, SmartTiming.TransponderAssignment, Tools.Logger,
  System.DateUtils;

const
  cLogger = 'SmartTiming.Controller';

{==============================================================================}
constructor TSmartTimingController.Create;
begin
  LogOnDebug(cLogger, ['Creating controller']);
  LoadSettings;

  FEventDataObject := TEventDataObject.Create;
  FPassingService := TPassingService.Create;
  FPassingService.OnDisplayPassing := OnDisplayIngestedPassing;
  FPassingService.OnGetContextRaceId := TryGetContextRaceIdForOrphanPassing;
  FPassingService.OnGetMinLapDuration := GetMinLapDurationForRace;

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
    if FDecoderEngine <> nil then
      FDecoderEngine.NewPassingReceived := nil;
    FreeAndNil(FPassingService);
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
  lRaceItem: TRaceItem;
  i: integer;
begin
  try
    LogOnDebug(cLogger, ['RestorePassings']);
    SetLength(lRaceIds, FRaceList.Count);
    i := 0;
    for lRaceId in FRaceList.Keys do
    begin
      lRaceIds[i] := lRaceId;
      Inc(i);
    end;

    if FPassingService <> nil then
      FPassingService.RestoreFromDatabase(lRaceIds);

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
begin
  ChangeRaceStatus(ARaceId, ARaceStatus, Now);
end;

{==============================================================================}
procedure TSmartTimingController.ChangeRaceStatus(ARaceId: Integer; ARaceStatus: TRaceStatus;
  APassingTime: TDateTime);
var
  lPassing: TPassing;
  lRaceItem: TRaceItem;
  lUpdateRaceStatus: Boolean;
  lDisplayStatus: TRaceStatus;
  lList: TList<TPassing>;
  lExisting: TPassing;
  lFinishExists: Boolean;
  i: Integer;
begin
  try
    LogOnDebug(cLogger, ['ChangeRaceStatus']);

    (* Event markers (Neue Spitze, Punkte) do not change RACES.STATUS — race stays Started. *)
    lUpdateRaceStatus := not (ARaceStatus in cRaceEventMarkers);

    if lUpdateRaceStatus then
    begin
      MainDataModule.SetRaceStatus(ARaceId, ARaceStatus);
      if FRaceList.TryGetValue(ARaceId, lRaceItem) then
        lRaceItem.Status := ARaceStatus;

      (* Abort/Stop free chips for later races. Finished keeps assignments open
         so remaining riders can still score their closing lap. *)
      if ARaceStatus in [rsAborted, rsStopped] then
        MainDataModule.CloseAllOpenTransponderAssignmentsForRace(ARaceId);
    end;

    lFinishExists := False;
    if ARaceStatus = rsFinished then
    begin
      lList := TList<TPassing>.Create;
      try
        TPassingStore.GetSingleton.FillPassingsForRace(ARaceId, lList);
        for i := 0 to lList.Count - 1 do
        begin
          lExisting := lList[i];
          if lExisting.IsSystemMarker and (lExisting.Hits = cSystemHitsFinished) then
          begin
            lFinishExists := True;
            Break;
          end;
        end;
      finally
        FreeAndNil(lList);
      end;
    end;

    if not lFinishExists then
    begin
      lPassing.PassingNumber := MainDataModule.AllocateSyntheticPassingNumber;
      lPassing.ChipId := '';
      lPassing.PassingTime := APassingTime;
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
    end;

    if lUpdateRaceStatus then
      lDisplayStatus := ARaceStatus
    else if FRaceList.TryGetValue(ARaceId, lRaceItem) then
      lDisplayStatus := lRaceItem.Status
    else
      lDisplayStatus := rsStarted;
    GFormMain.RefreshFlagButtonsActive(lDisplayStatus);
    if lUpdateRaceStatus then
      GFormMain.RefreshRacesListBox;
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['ChangeRaceStatus']);
  end;
end;

{==============================================================================}
function TSmartTimingController.EnsureFinishFlagBeforeLeader(ARaceId: Integer;
  ALeaderFinishTime: TDateTime): Boolean;
var
  lList: TList<TPassing>;
  lPassing: TPassing;
  lRaceItem: TRaceItem;
  lFlagTime: TDateTime;
  i: Integer;
begin
  Result := False;
  if (ARaceId < 0) or (ALeaderFinishTime <= 0) then
    Exit;

  lList := TList<TPassing>.Create;
  try
    TPassingStore.GetSingleton.FillPassingsForRace(ARaceId, lList);
    for i := 0 to lList.Count - 1 do
    begin
      lPassing := lList[i];
      if lPassing.IsSystemMarker and (lPassing.Hits = cSystemHitsFinished) then
        Exit;
    end;
  finally
    FreeAndNil(lList);
  end;

  lFlagTime := IncMilliSecond(ALeaderFinishTime, -1);
  (* Insert marker only into DB/store; caller rebuilds the protocol so the flag
     sorts 1ms before the leader instead of appending at the list end. *)
  lPassing.PassingNumber := MainDataModule.AllocateSyntheticPassingNumber;
  lPassing.ChipId := '';
  lPassing.PassingTime := lFlagTime;
  lPassing.SignalStrength := 100;
  lPassing.Hits := cSystemHitsFinished;
  lPassing.Flags := 2;
  lPassing.Sport := sSportsIdCycling;
  lPassing.DecoderId := 'SYSTEM';
  lPassing.RaceId := ARaceId;
  lPassing.PassingStatus := Ord(psValid);
  lPassing.LapIndex := -1;
  lPassing.CompetitorId := -1;

  MainDataModule.AddPassingToDatabase(lPassing, ARaceId);
  TPassingStore.GetSingleton.AddPassing(lPassing);

  MainDataModule.SetRaceStatus(ARaceId, rsFinished);
  if FRaceList.TryGetValue(ARaceId, lRaceItem) then
    lRaceItem.Status := rsFinished;

  (* Do not RefreshRacesListBox here: ProcessMessages would refresh the ranking
     while LAPS may still be 0 (Recalc) and then skip the real refresh. *)
  if GFormMain <> nil then
    GFormMain.RefreshFlagButtonsActive(rsFinished);
  Result := True;
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
begin
  try
    LogOnDebug(cLogger, ['OnPassingReceived']);
    if FPlayPassingSound then
      PlaySound('PassingBeep', 0, SND_NOSTOP or SND_NOWAIT or SND_RESOURCE or SND_ASYNC or SND_NODEFAULT);
    if FPassingService <> nil then
      FPassingService.Ingest(APassing);
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['OnPassingReceived']);
  end;
end;

{==============================================================================}
procedure TSmartTimingController.OnDisplayIngestedPassing(ARaceId: Integer;
  const APassing: TPassing);
begin
  if GFormMain <> nil then
    GFormMain.AddPassingForRaceId(ARaceId, APassing);
end;

{==============================================================================}
function TSmartTimingController.AddManualPassing(var APassing: TPassing): TManualPassingResult;
begin
  try
    LogOnDebug(cLogger, ['AddManualPassing']);
    FPassingService.BeginManualPassing;
    APassing.PassingNumber := MainDataModule.AllocateSyntheticPassingNumber;
    TDecoderEngine.GetSingleton.SendSimulatedPassing(APassing);
    Result := FPassingService.LastManualPassingResult;
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
  if FPassingService <> nil then
    FPassingService.UpdatePassing(APassingNumber, APassingTime, APassingState);
end;

{==============================================================================}
procedure TSmartTimingController.RemovePassing(APassingNumber: Integer);
begin
  if FPassingService <> nil then
    FPassingService.RemovePassing(APassingNumber);
end;

{==============================================================================}
function TSmartTimingController.TryGetContextRaceIdForOrphanPassing: Integer;
var
  lRaceId: Integer;
  lRaceItem: TRaceItem;
  lStatus: TRaceStatus;
begin
  Result := -1;
  if GFormMain = nil then
    Exit;
  lRaceId := GFormMain.GetSelectedRaceId;
  if lRaceId < 0 then
    Exit;
  if not FRaceList.TryGetValue(lRaceId, lRaceItem) then
    Exit;
  lStatus := lRaceItem.Status;
  if lStatus = rsNotStarted then
    lStatus := MainDataModule.GetRaceStatus(lRaceId);
  if TTransponderAssignmentService.IsRaceStatusActiveForChipConflict(lStatus) then
    Result := lRaceId;
end;

{==============================================================================}
function TSmartTimingController.AfterChipAssignedToCompetitor(ARaceId, ACompetitorId: Integer;
  const AChipId: string): Integer;
var
  lRaceItem: TRaceItem;
  lEngine: TCustomRaceEngine;
  lResult: Integer;
begin
  Result := 0;
  lEngine := nil;
  if (ARaceId >= 0) and FRaceList.TryGetValue(ARaceId, lRaceItem) and
     (lRaceItem <> nil) then
    lEngine := lRaceItem.RaceEngine;

  if lEngine = nil then
  begin
    Result := TTransponderAssignmentService.ReattachOrphanPassingsForChip(
      ARaceId, ACompetitorId, AChipId);
    Exit;
  end;

  lResult := 0;
  lEngine.WithPassingListDragLocked(
    procedure
    begin
      lResult := TTransponderAssignmentService.ReattachOrphanPassingsForChip(
        ARaceId, ACompetitorId, AChipId);
      lEngine.RecalcCountingLaps;
      lEngine.ReassignLapsForRace;
      lEngine.RebuildProtocolDisplay;
      lEngine.RefreshRankingDisplay;
    end);
  Result := lResult;
end;

{==============================================================================}
procedure TSmartTimingController.RememberAlwaysAcceptChip(const AChipId: string);
begin
  if FPassingService <> nil then
    FPassingService.RememberAlwaysAcceptChip(AChipId);
end;

{==============================================================================}
procedure TSmartTimingController.ClearAlwaysAcceptChips;
begin
  if FPassingService <> nil then
    FPassingService.ClearAlwaysAcceptChips;
end;

{==============================================================================}
function TSmartTimingController.GetPlausibilityStatsSnapshot: TPlausibilitySessionStats;
begin
  if FPassingService = nil then
  begin
    Result.Clear;
    Exit;
  end;
  Result := FPassingService.GetPlausibilityStatsSnapshot;
end;

{==============================================================================}
procedure TSmartTimingController.ResetPlausibilityStats;
begin
  if FPassingService <> nil then
    FPassingService.ResetPlausibilityStats;
end;

{==============================================================================}
function TSmartTimingController.GetOnPlausibilityDecision: TPlausibilityDecisionEvent;
begin
  if FPassingService = nil then
    Exit(nil);
  Result := FPassingService.OnPlausibilityDecision;
end;

{==============================================================================}
procedure TSmartTimingController.SetOnPlausibilityDecision(
  const AValue: TPlausibilityDecisionEvent);
begin
  if FPassingService <> nil then
    FPassingService.OnPlausibilityDecision := AValue;
end;

{==============================================================================}
function TSmartTimingController.GetOnPlausibilityStatsChanged: TPlausibilityStatsEvent;
begin
  if FPassingService = nil then
    Exit(nil);
  Result := FPassingService.OnPlausibilityStatsChanged;
end;

{==============================================================================}
procedure TSmartTimingController.SetOnPlausibilityStatsChanged(
  const AValue: TPlausibilityStatsEvent);
begin
  if FPassingService <> nil then
    FPassingService.OnPlausibilityStatsChanged := AValue;
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

    FPassingService.IncrementOperatorAccepted;
    LogOnInfo(cLogger, [
      Format('Plausibility OperatorAccepted chip=%s race=%d passing=%d',
        [lPassing.ChipId, ARaceId, APassingNumber])]);
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['ApplyPlausibilityAccept']);
  end;
end;

{==============================================================================}
procedure TSmartTimingController.ApplyPlausibilityReject(APassingNumber, ARaceId: Integer);
var
  lPassing: TPassing;
  lRaceItem: TRaceItem;
begin
  try
    LogOnDebug(cLogger, ['ApplyPlausibilityReject', APassingNumber.ToString, ARaceId.ToString]);
    (* Already persisted as invalid when AskOperator was queued; keep invalid and refresh UI. *)
    lPassing := TPassingStore.GetSingleton.GetPassing(APassingNumber);
    UpdatePassing(APassingNumber, lPassing.PassingTime, psInvalid);

    if (ARaceId >= 0) and FRaceList.TryGetValue(ARaceId, lRaceItem) and
       (lRaceItem.RaceEngine <> nil) then
    begin
      lRaceItem.RaceEngine.RecalcCountingLaps;
      lRaceItem.RaceEngine.ReassignLapsForRace;
      lRaceItem.RaceEngine.RebuildProtocolDisplay;
    end;

    LogOnInfo(cLogger, [
      Format('Plausibility OperatorRejected chip=%s race=%d passing=%d',
        [lPassing.ChipId, ARaceId, APassingNumber])]);
    FPassingService.NotifyStatsChanged;
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['ApplyPlausibilityReject']);
  end;
end;

end.
