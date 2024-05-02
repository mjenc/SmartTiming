unit SmartTiming.Controller;

interface

uses
  Windows, MMSystem, SysUtils, Generics.Collections,
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

    property Event: TEventDataObject read FEventDataObject;
    property RaceList: TDictionary<integer, TRaceItem> read FRaceList;
  end;

var
  GSmartTimingController: TSmartTimingController;

implementation

uses
  FormMain, SmartTiming.Cache;

{==============================================================================}
constructor TSmartTimingController.Create;
begin
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
end;

{==============================================================================}
procedure TSmartTimingController.LoadEventData(const AEventPath: string);
begin
  FDatabasePath := AEventPath;
  MainDataModule.OpenDatabase(FDatabasePath);
  FEventDataObject.RefreshFromDatabase;
  GFormMain.RefreshControlsFromEventDataObject(FEventDataObject);
  SaveEvent(FEventDataObject);

  MainDataModule.RefreshRacesDataSet(FEventDataObject.EventId);
  ResetRacesDataSet;
  LoadRaces;
  RestorePassings;
end;

{==============================================================================}
procedure TSmartTimingController.LoadRaces;
var
  lRaceItem: TRaceItem;
  lRaceId: integer;
  i: integer;
  lVisited: TList<string>;
begin
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
  FEventDataObject.Organizer := AOrganizer;
  FEventDataObject.Title := ATitle;
  FEventDataObject.DateFrom := ADateFrom;
  FEventDataObject.DateTo := ADateTo;
  FEventDataObject.SaveToDatabase;

  DecodeDate(ADateFrom, lYear, lMonth, lDay);
  MainDataModule.PushEventToHistory(Format('%d-%2d-%2d %s | %s', [lYear, lMonth, lDay, AOrganizer, ATitle]));
end;

{==============================================================================}
procedure TSmartTimingController.RestorePassings;
var
  lRaceIds: TArray<integer>;
  lRaceId: integer;
  lPassings: TArray<TPassing>;
  i: integer;
begin
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
end;

{==============================================================================}
procedure TSmartTimingController.OnDecoderFound(ADecoder: TDecoder);
begin
  GFormMain.DecoderConnected(ADecoder);
end;

{==============================================================================}
procedure TSmartTimingController.OnStatusReceived(AStatus: TDecoderStatus);
begin
  GFormMain.AddDecoderStatus(AStatus);
end;

{==============================================================================}
procedure TSmartTimingController.OnPassingReceived(APassing: TPassing);
var
  lRaceId: integer;
  lCompetitorId: integer;
begin
  if FPlayPassingSound then
    PlaySound('PassingBeep', 0, SND_NOSTOP or SND_NOWAIT or SND_RESOURCE or SND_ASYNC or SND_NODEFAULT);

  MainDataModule.AddPassingToDatabase(APassing, lRaceId);

  lRaceId := MainDataModule.GetRaceIdForPassing(APassing, lCompetitorId);
  GFormMain.AddPassingForRaceId(lRaceId, APassing);
end;

{==============================================================================}
procedure TSmartTimingController.AddManualPassing(APassing: TPassing);
begin
  TDecoderEngine.GetSingleton.SendSimulatedPassing(APassing);
end;

{==============================================================================}
procedure TSmartTimingController.UpdatePassing(APassingNumber: Integer; APassingTime: TDatetime; APassingState: TPassingState);
begin
  MainDataModule.UpdatePassingInDatabase(APassingNumber, APassingTime, APassingState);
  TPassingStore.GetSingleton.UpdatePassing(APassingNumber, APassingTime);
end;

{==============================================================================}
procedure TSmartTimingController.RemovePassing(APassingNumber: Integer);
begin
  MainDataModule.RemovePassingFromDatabase(APassingNumber);
  TPassingStore.GetSingleton.RemovePassing(APassingNumber);
end;

end.
