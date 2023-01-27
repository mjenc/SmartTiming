unit RaceEngine.Custom;

interface

uses
  Controls, StdCtrls, ComCtrls, SysUtils, Graphics, Types, UITypes, Classes,
  DB, SQLExpr, Provider, DBClient, DBGrids, Dialogs,
  SmartTiming.Consts, DecoderInterface;

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
    FOwner: TComponent;
    FParent: TWinControl;
    FRaceItem: TRaceItem;
    FPassingDisplay: TWinControl;
    FRankingGrid: TDBGrid;
    FAvailableRaceStates: TRaceStates;

    FSQLDataSetRankings: TSQLDataSet;
    FDataSetProviderRankings: TDataSetProvider;
    FClientDataSetRankings: TClientDataSet;
    FDataSourceRankings: TDataSource;

    function GetPassingDisplay: TWinControl; virtual;
    procedure OnDrawListItem(ASender: TCustomListView; AItem: TListItem; AState: TCustomDrawState; var ADefaultDraw: Boolean);

    procedure AddColumnToDisplay(const ACaption: string);

    function GetRankingGrid: TDBGrid; virtual;
  public
    constructor Create(AParent: TWinControl; ARaceItem: TRaceItem); virtual;
    destructor Destroy; override;

    // passing display screen
    procedure AddPassingToDisplay(APassing: TPassing); virtual;
    procedure ClearAllPassings; virtual;
    procedure ClearPassingNumber(APassingNumber: integer); virtual;

    property PassingDisplay: TWinControl read GetPassingDisplay;
    property AvailableRaceStates: TRaceStates read FAvailableRaceStates;

    // ranking
    procedure RefreshRankingDisplay;
    property RankingDisplay: TDBGrid read GetRankingGrid;

    // corrections

    // result
  end;

implementation

uses
  SmartTiming.Tools, Math,
  DataModule;

{==============================================================================}
constructor TCustomRaceEngine.Create(AParent: TWinControl; ARaceItem: TRaceItem);
begin
  FPassingDisplay := nil;
  FOwner := TComponent.Create(nil);
  FParent := AParent;
  FRaceItem := ARaceItem;
  FAvailableRaceStates := [rsNotStarted, rsWarmUp, rsStarted, rsNeutralized, rsFinished, rsAborted, rsStopped];

  FSQLDataSetRankings := TSQLDataSet.Create(FOwner);
  FSQLDataSetRankings.SQLConnection := MainDataModule.SQLConnection;

  FDataSetProviderRankings := TDataSetProvider.Create(FOwner);
  FDataSetProviderRankings.DataSet := FSQLDataSetRankings;
  FDataSetProviderRankings.Name := 'FDataSetProviderRankings';

  FClientDataSetRankings := TClientDataSet.Create(FOwner);
  FClientDataSetRankings.ProviderName := FDataSetProviderRankings.Name;

  FDataSourceRankings := TDataSource.Create(FOwner);
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
    FreeAndNil(FOwner);
  finally
    inherited Destroy;
  end;
end;

{==============================================================================}
function TCustomRaceEngine.GetPassingDisplay: TWinControl;
begin
  if FPassingDisplay <> nil then
    Exit(FPassingDisplay);

  FPassingDisplay := TListView.CreateParented(FParent.Handle);
  FPassingDisplay.Visible := false;
  FPassingDisplay.Align := alNone;
  TListView(FPassingDisplay).DragMode := TDragMode.dmAutomatic;
  TListView(FPassingDisplay).OnCustomDrawItem := OnDrawListItem;
  TListView(FPassingDisplay).ViewStyle := vsReport;

  AddColumnToDisplay(cFieldTitleBib);
  AddColumnToDisplay(cFieldTitleLastName + ', ' + cFieldTitleFirstName);
  AddColumnToDisplay(cFieldTitlePassingTime);
  AddColumnToDisplay(cFieldTitleTransponder);
  AddColumnToDisplay(cFieldTitleChipID);

  result := FPassingDisplay;
end;

{==============================================================================}
procedure TCustomRaceEngine.AddColumnToDisplay(const ACaption: string);
var
  lColumn: TListColumn;
begin
  lColumn := TListView(FPassingDisplay).Columns.Add;
  lColumn.Caption := ACaption;
  lColumn.AutoSize := true;
end;

{==============================================================================}
procedure TCustomRaceEngine.OnDrawListItem(ASender: TCustomListView; AItem: TListItem; AState: TCustomDrawState; var ADefaultDraw: Boolean);
var
  lBgColor: TColor;
  lFGColor: TColor;
  rt, r: TRect;
  s: String;
  i: Integer;

  // Fit the rect used for TextRect
  Procedure PrepareTextRect;
  begin
    rt := r;
    rt.Left := rt.Left + 5;
    rt.Top := rt.Top + 1;
  end;
begin
  SmartTimingTools.GetColorsForRaceStatus(TRaceStatus(AItem.Data), true, lBgColor, lFgColor);

  TListView(ASender).Canvas.Brush.Color := lBgColor;
  TListView(ASender).Canvas.Font.Color := lFgColor;

  r := AItem.DisplayRect(drBounds);
  ASender.Canvas.FillRect(r);

  r.Right := r.Left + TListView(ASender).Columns[0].Width;
  s := AItem.Caption;
  PrepareTextRect;
  TListView(ASender).Canvas.TextRect(rt, s, [tfSingleLine, tfEndEllipsis]);
  if TListView(ASender).ViewStyle = vsReport then
  begin // Paint the Subitems if ViewStyle = vsReport
    for i := 0 to AItem.SubItems.Count - 1 do
    begin
      r.Left := r.Left + TListView(ASender).Columns.Items[i].Width;
      r.Right := r.Left + TListView(ASender).Columns.Items[i + 1].Width;
      PrepareTextRect;
      s := AItem.SubItems[i];
      TListView(ASender).Canvas.TextRect(rt, s, [tfSingleLine, tfEndEllipsis]);
    end;
  end;
  ADefaultDraw := false;
end;

{==============================================================================}
function TCustomRaceEngine.GetRankingGrid: TDBGrid;
begin
  if FRankingGrid <> nil then
    Exit(FRankingGrid);

  FRankingGrid := TDBGrid.CreateParented(FParent.Handle);
  FRankingGrid.Visible := false;
  FRankingGrid.Align := alNone;
  FRankingGrid.DataSource := FDataSourceRankings;
  result := FRankingGrid;
end;

{==============================================================================}
procedure TCustomRaceEngine.RefreshRankingDisplay;
var
  i: integer;
  lColumn: TColumn;
  s: string;
begin
  FClientDataSetRankings.Active := false;
  FSQLDataSetRankings.Active := false;

  FSQLDataSetRankings.Active := true;
  FClientDataSetRankings.Active := True;

  for i := 0 to FRankingGrid.Columns.Count - 1 do
  begin
    lColumn := FRankingGrid.Columns[i];
    SmartTimingTools.SetColumnProperties('RANKING', lColumn);
  end;
// TODO SmartTimingTools.SortGridColumns(FRankingGrid, 'RANKING');
end;

{==============================================================================}
procedure TCustomRaceEngine.AddPassingToDisplay(APassing: TPassing);
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
