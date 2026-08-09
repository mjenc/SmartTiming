unit SmartTiming.Controller;

interface

uses
  Windows, MMSystem, SysUtils, Generics.Collections, Classes,
  SmartTiming.Consts, SmartTiming.DecoderEngine, DecoderInterface, SmartTiming.Tools,
  DataModule, SmartTiming.Event, SmartTiming.WebService,
  RaceEngine.Custom;

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

    procedure OnDecoderFound(ADecoder: TDecoder);
    procedure OnStatusReceived(AStatus: TDecoderStatus);
    procedure OnPassingReceived(APassing: TPassing);
    function GetMinLapDurationForRace(ARaceId: Integer): Integer;
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
    procedure AddManualPassing(APassing: TPassing);
    procedure ResetRacesDataSet;
    procedure ChangeRaceStatus(ARaceId: Integer; ARaceStatus: TRaceStatus);
    procedure RetryDecoderSearch;
    procedure ImportTRIATimes(const AFileName: string);
    property Event: TEventDataObject read FEventDataObject;
    property RaceList: TDictionary<integer, TRaceItem> read FRaceList;
    property OnAmbiguousChipAssignment: TAmbiguousChipAssignmentEvent
      read FOnAmbiguousChipAssignment write FOnAmbiguousChipAssignment;
  end;

var
  GSmartTimingController: TSmartTimingController;

implementation

uses
  FormMain, SmartTiming.Cache, SmartTiming.TransponderAssignment,
  SmartTiming.PassingValidator, Tools.Logger;

const
  cLogger = 'SmartTiming.Controller';

{==============================================================================}
constructor TSmartTimingController.Create;
begin
  LogOnDebug(cLogger, ['Creating controller']);
  LoadSettings;

  FEventDataObject := TEventDataObject.Create;

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
          begin
            LogOnDebug(cLogger, ['Unsupported race type locked; using ITT engine',
              lRaceId.ToString, Ord(lRaceItem.RaceType).ToString]);
            // Keep stored RaceType for display; factory only accepts supported types.
            lRaceItem.RaceType := rtIndividualTimeTrial;
            lRaceItem.RaceEngine := TRaceEngineFactory.CreateRaceEngineForRaceType(
              GFormMain.GetNewPanelForPassings(lRaceId), FEventDataObject, lRaceItem);
            SmartTimingTools.FillRaceItemFromDataSet(MainDataModule.DataSourceRaces.DataSet, lRaceItem);
          end
          else
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
        GFormMain.AddPassingForRaceId(lRaceId, lPassings[i]);
        TPassingStore.GetSingleton.AddPassing(lPassings[i]);
      end;
    end;

    lPassings := MainDataModule.GetUnassignedPassings;
    for i := 0 to High(lPassings) do
    begin
      TPassingStore.GetSingleton.AddPassing(lPassings[i]);
      TUnassignedPassingStore.GetSingleton.AddPassing(lPassings[i]);
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

    lPassing.PassingNumber := MainDataModule.GetMinPassingNumber - 1;
    lPassing.ChipId := '';
    lPassing.PassingTime := Now;
    lPassing.SignalStrength := 100;
    lPassing.Hits := 0 - Ord(ARaceStatus);
    lPassing.Flags := 2;
    lPassing.Sport := sSportsIdCycling;
    lPassing.DecoderId := 'SYSTEM';
    lPassing.RaceId := ARaceId;
    lPassing.PassingStatus := Ord(psValid);

    MainDataModule.AddPassingToDatabase(lPassing, ARaceId);

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
  lChipId: string;
  lPassingTime: TDateTime;
  lMatchCount: Integer;
  lContext: TPassingValidationContext;
  lValidation: TPassingValidationResult;
  lMinLap: Integer;
  lIsManual: Boolean;
begin
  try
    LogOnDebug(cLogger, ['OnPassingReceived']);
    if FPlayPassingSound then
      PlaySound('PassingBeep', 0, SND_NOSTOP or SND_NOWAIT or SND_RESOURCE or SND_ASYNC or SND_NODEFAULT);

    (* System markers (race status) skip plausibility. *)
    if (APassing.Flags and 2) = 2 then
    begin
      APassing.PassingStatus := Ord(psValid);
      MainDataModule.AddPassingToDatabase(APassing, lRaceId, True);
      APassing.RaceId := lRaceId;
      TPassingStore.GetSingleton.UpdatePassingRaceId(APassing.PassingNumber, lRaceId);
      GFormMain.AddPassingForRaceId(lRaceId, APassing);
      Exit;
    end;

    TTransponderAssignmentService.ResolvePassing(APassing.ChipId, APassing.PassingTime, lResolution);

    if lResolution.IsUnique then
      lMinLap := GetMinLapDurationForRace(lResolution.RaceId)
    else
      lMinLap := 0;

    lIsManual := SameText(APassing.DecoderId, 'MANUAL');
    lContext := TPassingValidator.BuildLiveContext(APassing, lResolution, lMinLap, lIsManual);
    lValidation := TPassingValidator.Validate(lContext);

    if lValidation.Disposition = pdAccept then
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
      LogOnWarn(cLogger, ['Passing accepted marked', APassing.ChipId, lValidation.PrimaryMessage]);
    end
    else
    begin
      (* Reject and AskOperator (no dialog yet, step 4): do not score. *)
      APassing.PassingStatus := Ord(psInvalid);
      if lResolution.IsUnique then
        lRaceId := lResolution.RaceId
      else
        lRaceId := -1;
      LogOnWarn(cLogger, [
        Format('Passing not scored (%s): %s',
          [lValidation.PrimaryMessage, APassing.ChipId])]);
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

      if lResolution.IsAmbiguous and Assigned(FOnAmbiguousChipAssignment) then
      begin
        lChipId := APassing.ChipId;
        lPassingTime := APassing.PassingTime;
        lMatchCount := lResolution.MatchCount;
        TThread.Queue(nil,
          procedure
          begin
            if Assigned(GSmartTimingController) and
               Assigned(GSmartTimingController.OnAmbiguousChipAssignment) then
              GSmartTimingController.OnAmbiguousChipAssignment(
                lChipId, lPassingTime, lMatchCount);
          end);
      end;
    end
    else
      TUnassignedPassingStore.GetSingleton.RemovePassing(APassing.PassingNumber);

    (* Display always; participation update only for accepted (engine checks status). *)
    GFormMain.AddPassingForRaceId(lRaceId, APassing);
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['OnPassingReceived']);
  end;
end;

{==============================================================================}
procedure TSmartTimingController.AddManualPassing(APassing: TPassing);
begin
  try
    LogOnDebug(cLogger, ['AddManualPassing']);
    TDecoderEngine.GetSingleton.SendSimulatedPassing(APassing);
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

end.
