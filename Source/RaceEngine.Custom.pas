unit RaceEngine.Custom;

interface

uses
  Controls, StdCtrls, SysUtils,
  DB, SQLExpr, Provider, DBClient, DBGrids,
  SmartTiming.Consts, SmartTiming.DecoderInterface;

type
  TCustomRaceEngine = class;

  TRaceItem = class
    Id: integer;
    RaceType: TRaceType;
    StartTime: TDatetime;
    Title: string;
    Laps: integer;
    Distance: double;
    FirstPassingIsLap: boolean;
    MinLapDuration: integer;
    Status: TRaceStatus;
    RaceEngine: TCustomRaceEngine;
  end;

  TCustomRaceEngine = class
  protected
    FParent: TWinControl;
    FRaceItem: TRaceItem;
    FPassingDisplay: TWinControl;
    FRankingGrid: TDBGrid;

    FSQLDataSetRankings: TSQLDataSet;
    FDataSetProviderRankings: TDataSetProvider;
    FClientDataSetRankings: TClientDataSet;
    FDataSourceRankings: TDataSource;

    function GetPassingDisplay: TWinControl; virtual;
    function GetRankingGrid: TDBGrid; virtual;
  public
    constructor Create(AParent: TWinControl; ARaceItem: TRaceItem); virtual;
    destructor Destroy; override;

    // passing display screen
    procedure AddPassingToDisplay(APassing: TMyLapsP3Passing); virtual;
    procedure ClearAllPassings; virtual;
    procedure ClearPassingNumber(APassingNumber: integer); virtual;

    property PassingDisplay: TWinControl read GetPassingDisplay;

    // ranking
    property RankingDisplay: TDBGrid read GetRankingGrid;

    // corrections

    // result
  end;

implementation

uses
  Math,
  uDataModule;

{==============================================================================}
constructor TCustomRaceEngine.Create(AParent: TWinControl; ARaceItem: TRaceItem);
begin
  FPassingDisplay := nil;
  FParent := AParent;
  FRaceItem := ARaceItem;

  FSQLDataSetRankings := TSQLDataSet.Create(nil);
  FSQLDataSetRankings.SQLConnection := MainDataModule.SQLConnection;

  FDataSetProviderRankings := TDataSetProvider.Create(nil);
  FDataSetProviderRankings.DataSet := FSQLDataSetRankings;
  FDataSetProviderRankings.Name := 'DataSetProviderRankings';

  FClientDataSetRankings := TClientDataSet.Create(nil);
  FClientDataSetRankings.ProviderName := FDataSetProviderRankings.Name;

  FDataSourceRankings := TDataSource.Create(nil);
  FDataSourceRankings.DataSet := FClientDataSetRankings;

  FSQLDataSetRankings.DataSource := FDataSourceRankings;
end;

{==============================================================================}
destructor TCustomRaceEngine.Destroy;
begin
  try
    FreeAndNil(FPassingDisplay);
    FreeAndNil(FDataSourceRankings);
    FreeAndNil(FClientDataSetRankings);
    FreeAndNil(FDataSetProviderRankings);
    FreeAndNil(FSQLDataSetRankings);
  finally
    inherited Destroy;
  end;
end;

{==============================================================================}
function TCustomRaceEngine.GetPassingDisplay: TWinControl;
begin
  if FPassingDisplay <> nil then
    Exit(FPassingDisplay);

  FPassingDisplay := TMemo.CreateParented(FParent.Handle);
  FPassingDisplay.Visible := false;
  FPassingDisplay.Align := alNone;
  result := FPassingDisplay;
end;

{==============================================================================}
function TCustomRaceEngine.GetRankingGrid: TDBGrid;
begin
  if FRankingGrid <> nil then
    Exit(FRankingGrid);

  FRankingGrid := TDBGrid.CreateParented(FParent.Handle);
  FRankingGrid.Visible := false;
  FRankingGrid.Align := alNone;
  result := FRankingGrid;
end;

{==============================================================================}
procedure TCustomRaceEngine.AddPassingToDisplay(APassing: TMyLapsP3Passing);
begin
  if (FPassingDisplay = nil) or  (not (FPassingDisplay is TMemo)) then
    Exit;
  TMemo(FPassingDisplay).Lines.Add(APassing.ToString);
end;

{==============================================================================}
procedure TCustomRaceEngine.ClearAllPassings;
begin
  if (FPassingDisplay = nil) or  (not (FPassingDisplay is TMemo)) then
    Exit;
  TMemo(FPassingDisplay).Clear;
end;

{==============================================================================}
procedure TCustomRaceEngine.ClearPassingNumber(APassingNumber: integer);
var
  i: integer;
  lSearch: string;
begin
  if (FPassingDisplay = nil) or  (not (FPassingDisplay is TMemo)) then
    Exit;

  lSearch := Format('Passing# %d,', [APassingNumber]);
  for i := 0 to TMemo(FPassingDisplay).Lines.Count - 1 do
  begin
    if not TMemo(FPassingDisplay).Lines[i].StartsWith(lSearch) then
      Continue;
    TMemo(FPassingDisplay).Lines.Delete(i);
    Exit;
  end;
end;

end.
