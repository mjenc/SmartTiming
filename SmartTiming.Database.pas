unit SmartTiming.Database;

interface

uses
  SysUtils, Classes, Data.DB, Data.SqlExpr,
  SmartTiming.Consts;

type
  TDataStore = class
  private
    FSQLConnection: TSQLConnection;

  public
    constructor Create(const ADatabaseName: string);
    destructor Destroy; override;
  end;

  TDataObject = class
  protected
    FDataStore: TDataStore;

  public
    constructor Create(ADataStore: TDataStore);
    procedure SaveToDatabase; virtual; abstract;
    procedure DeleteFromDatabase; virtual; abstract;
    procedure RefreshFromDatabase; virtual; abstract;
  end;

  TEventDataObject = class(TDataObject)
  public
    procedure SaveToDatabase; override;
    procedure DeleteFromDatabase; override;
    procedure RefreshFromDatabase; override;
  end;

  TRaceDataObject = class(TDataObject)
  private
    FRaceId: integer;
    FEventId: integer;
    FTitle: string;
    FStarttime: TDatetime;
    FRaceType: TRaceType;
    FLapCount: integer;
    FDistance: Double;
    FFirstPassingCounts: boolean;
    FMinLapDuration: TDatetime;
    FRaceStatus: TRaceStatus;
  public
    procedure SaveToDatabase; override;
    procedure DeleteFromDatabase; override;
    procedure RefreshFromDatabase; override;

    property RaceId: integer read FRaceId write FRaceId;
    property EventId: integer read FEventId write FEventId;
    property Title: string read FTitle write FTitle;
    property Starttime: TDatetime read FStarttime write FStarttime;
    property RaceType: TRaceType read FRaceType write FRaceType;
    property LapCount: integer read FLapCount write FLapCount;
    property Distance: Double read FDistance write FDistance;
    property FirstPassingCounts: boolean read FFirstPassingCounts write FFirstPassingCounts;
    property MinLapDuration: TDatetime read FMinLapDuration write FMinLapDuration;
    property RaceStatus: TRaceStatus read FRaceStatus write FRaceStatus;
  end;

  TCompetitorDataObject = class(TDataObject)
  public
    procedure SaveToDatabase; override;
    procedure DeleteFromDatabase; override;
    procedure RefreshFromDatabase; override;
  end;

implementation

{==============================================================================}
constructor TDataObject.Create(ADataStore: TDataStore);
begin
  inherited Create;
  FDataStore := ADataStore;
end;
{==============================================================================}
constructor TDataStore.Create(const ADatabaseName: string);
begin
  inherited Create;

  FSQLConnection := TSQLConnection.Create(nil);
  FSQLConnection.DriverName := 'Sqlite';
  FSQLConnection.Params.Add('Database=' + ADatabaseName);
  FSQLConnection.Connected := true;
end;

{==============================================================================}
destructor TDataStore.Destroy;
begin
  try
    FreeAndNil(FSQLConnection);
  finally
    inherited Destroy;
  end;

end;

{==============================================================================}
procedure TEventDataObject.SaveToDatabase;
begin
  // TODO
end;

{==============================================================================}
procedure TEventDataObject.DeleteFromDatabase;
begin
  // TODO
end;

{==============================================================================}
procedure TEventDataObject.RefreshFromDatabase;
begin
  // TODO
end;

{==============================================================================}
procedure TRaceDataObject.SaveToDatabase;
begin
  // TODO
end;

{==============================================================================}
procedure TRaceDataObject.DeleteFromDatabase;
begin
  // TODO
end;

{==============================================================================}
procedure TRaceDataObject.RefreshFromDatabase;
begin
  // TODO
end;

{==============================================================================}
procedure TCompetitorDataObject.SaveToDatabase;
begin
  // TODO
end;

{==============================================================================}
procedure TCompetitorDataObject.DeleteFromDatabase;
begin
  // TODO
end;

{==============================================================================}
procedure TCompetitorDataObject.RefreshFromDatabase;
begin
  // TODO
end;


end.
