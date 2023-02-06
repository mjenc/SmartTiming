unit SmartTiming.Controller;

interface

uses
  Windows, MMSystem, SysUtils,
  SmartTiming.Consts, SmartTiming.DecoderEngine, DecoderInterface, SmartTiming.Tools,
  DataModule,
  RaceEngine.Custom;

type
  TSmartTimingController = class
  private
    FDecoderEngine: TDecoderEngine;
    FPlayPassingSound: boolean;
    FDatabasePath: string;
    FEventDataObject: TEventDataObject;

    procedure OnStatusReceived(AStatus: TDecoderStatus);
    procedure OnPassingReceived(APassing: TPassing);
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadSettings;
    procedure LoadEventData(const AEventPath: string);
    procedure SaveEvent(AEventDataObject: TEventDataObject); overload;
    procedure SaveEvent(const AOrganizer, ATitle: string; ADateFrom, ADateTo: TDatetime); overload;
    procedure RestorePassings;

    procedure ResetRacesDataSet;
    procedure ChangeRaceStatus(ARaceId: Integer; ARaceStatus: TRaceStatus);

    property Event: TEventDataObject read FEventDataObject;
  end;

var
  GSmartTimingController: TSmartTimingController;

implementation

uses
  FormMain;

{==============================================================================}
constructor TSmartTimingController.Create;
begin
  FEventDataObject := TEventDataObject.Create;

  FDecoderEngine := TDecoderEngine.GetSingleton;
  FDecoderEngine.NewPassingReceived := OnPassingReceived;
  FDecoderEngine.NewStatusReceived := OnStatusReceived;

  LoadSettings;
end;

{==============================================================================}
destructor TSmartTimingController.Destroy;
begin
  try
    FreeAndNil(FEventDataObject);
  finally
    inherited Destroy;
  end;
end;

{==============================================================================}
procedure TSmartTimingController.LoadSettings;
begin
//  Sound Effect by <a href="https://pixabay.com/users/edr-1177074/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=music&amp;utm_content=8333">EdR</a> from <a href="https://pixabay.com//?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=music&amp;utm_content=8333">Pixabay</a>
//  Sound Effect by <a href="https://pixabay.com/users/irinairinafomicheva-25140203/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=music&amp;utm_content=13691">irinairinafomicheva</a> from <a href="https://pixabay.com//?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=music&amp;utm_content=13691">Pixabay</a>
//  Sound Effect from <a href="https://pixabay.com/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=music&amp;utm_content=86247">Pixabay</a>
  FPlayPassingSound := SmartTimingTools.RegistryReadBool(HKEY_CURRENT_USER, cRegKeyPath + '\Settings', 'BeepOnPassing', true);
end;

{==============================================================================}
procedure TSmartTimingController.LoadEventData(const AEventPath: string);
begin
  FDatabasePath := AEventPath;
  MainDataModule.OpenDatabase(FDatabasePath);
  FEventDataObject.RefreshFromDatabase;
  GFormMain.RefreshControlsFromEventDataObject(FEventDataObject);
  ResetRacesDataSet;
  SaveEvent(FEventDataObject);
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
  lPassing: TPassing;
begin
  lRaceIds := GFormMain.GetAllRaceIds;
  for lRaceId in lRaceIds do
  begin
    lPassings := MainDataModule.GetAllPassingsForRaceId(lRaceId);

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
  MainDataModule.SetRaceStatus(ARaceId, ARaceStatus);

  lPassing.PassingNumber := 0;
  lPassing.ChipId := '';
  lPassing.TxId := 0 - Ord(ARaceStatus);
  lPassing.PassingTime := Now;
  lPassing.SignalStrength := 100;
  lPassing.Hits := 1;
  lPassing.Flags := 2;
  lPassing.Sport := sSportsIdCycling;
  lPassing.DecoderId := 'SYSTEM';
  lPassing.RaceId := ARaceId;

  MainDataModule.AddPassingToDatabase(lPassing, ARaceId);

  GFormMain.AddPassingForRaceId(ARaceId, lPassing);
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
begin
  if FPlayPassingSound then
    PlaySound('PassingBeep', 0, SND_NOSTOP or SND_NOWAIT or SND_RESOURCE or SND_ASYNC or SND_NODEFAULT);

  MainDataModule.AddPassingToDatabase(APassing, lRaceId);

  lRaceId := MainDataModule.GetRaceIdForPassing(APassing);
  GFormMain.AddPassingForRaceId(lRaceId, APassing);
end;


end.
