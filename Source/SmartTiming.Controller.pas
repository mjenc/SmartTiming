unit SmartTiming.Controller;

interface

uses
  Windows, MMSystem, SysUtils, Generics.Collections, Classes,
  SmartTiming.Consts, SmartTiming.DecoderEngine, DecoderInterface, SmartTiming.Tools,
  DataModule, SmartTiming.Event, SmartTiming.WebService,
  RaceEngine.Custom;

type
  TSmartTimingController = class
  private
    FDecoderEngine: TDecoderEngine;
    FPlayPassingSound: boolean;
    FDatabasePath: string;
    FEventDataObject: TEventDataObject;
    FRaceList: TDictionary<integer, TRaceItem>;
    FServlet: TSmartTimingServlet;

    procedure OnDecoderFound(ADecoder: TDecoder);
    procedure OnStatusReceived(AStatus: TDecoderStatus);
    procedure OnPassingReceived(APassing: TPassing);
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
  end;

var
  GSmartTimingController: TSmartTimingController;

implementation

uses
  FormMain, SmartTiming.Cache, Tools.Logger;

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
  lVisited: TList<string>;
begin
  try
    LogOnDebug(cLogger, ['LoadRaces']);
    lVisited := TList<string>.Create;
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
          lRaceItem.RaceEngine := TRaceEngineFactory.CreateRaceEngineForRaceType(GFormMain.GetNewPanelForPassings(lRaceId), FEventDataObject, lRaceItem);

        lVisited.Add(lRaceItem.Id.ToString);
        MainDataModule.DataSourceRaces.DataSet.Next;
      end;

      for i in FRaceList.Keys do
      begin
        if lVisited.IndexOf(lRaceItem.Id.ToString) >= 0 then
          Continue;
        FRaceList.Remove(i);
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
begin
  try
    LogOnDebug(cLogger, ['ChangeRaceStatus']);

    MainDataModule.SetRaceStatus(ARaceId, ARaceStatus);
    lPassing.PassingNumber := MainDataModule.GetMinPassingNumber - 1;
    lPassing.ChipId := '';
    lPassing.PassingTime := Now;
    lPassing.SignalStrength := 100;
    lPassing.Hits := 0 - Ord(ARaceStatus);
    lPassing.Flags := 2;
    lPassing.Sport := sSportsIdCycling;
    lPassing.DecoderId := 'SYSTEM';
    lPassing.RaceId := ARaceId;

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
  lCompetitorId: integer;
begin
  try
    LogOnDebug(cLogger, ['OnPassingReceived']);
    if FPlayPassingSound then
      PlaySound('PassingBeep', 0, SND_NOSTOP or SND_NOWAIT or SND_RESOURCE or SND_ASYNC or SND_NODEFAULT);

    MainDataModule.AddPassingToDatabase(APassing, lRaceId);

    lRaceId := MainDataModule.GetRaceIdForPassing(APassing, lCompetitorId);
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
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['RemovePassing']);
  end;
end;

end.
