unit RaceEngine.Custom;

interface

uses
  Controls, StdCtrls, ComCtrls, SysUtils, Graphics, Types, UITypes, Classes, Grids,
  Menus, DB, SQLExpr, Provider, DBClient, DBGrids, Dialogs, Windows, Winapi.Messages,
  SmartTiming.Consts, DecoderInterface, SmartTiming.Event, Report.ExcelTemplateFiller;

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
  public
    destructor Destroy; override;
  end;

  TCustomRaceEngine = class
  private
    function GetSelectedCompetitorIds: TArray<integer>;
    procedure SetParticipantState(AState: TParticipantState);

  protected
    FOwner: TComponent;
    FParent: TWinControl;
    FEvent: TEventDataObject;
    FRaceItem: TRaceItem;
    FPassingDisplay: TWinControl;
    FRankingGrid: TDBGrid;
    FRankingGroupedByClass: boolean;
    FAvailableRaceStates: TRaceStates;
    FRankingQuery: string;
    FPopupMenuRanking: TPopupMenu;

    FSQLDataSetRankings: TSQLDataSet;
    FDataSetProviderRankings: TDataSetProvider;
    FClientDataSetRankings: TClientDataSet;
    FDataSourceRankings: TDataSource;
    FLastChangeTimestamp: TDatetime;
    FLastRefreshTimestamp: TDatetime;
    FLastConsideredPassingId: integer;
    FExcelFiller: TExcelFiller;

    FRankingSQLFormat: string;
    FResultSQLFormat: string;
    FRankingSQLClassGrouping: string;
    FFormatSuffix: string;
    FDefaultListFormatRanking: string;

    function GetPassingDisplay: TWinControl; virtual;
    procedure OnDrawListItem(ASender: TCustomListView; AItem: TListItem; AState: TCustomDrawState; var ADefaultDraw: Boolean);
    procedure AddColumnToDisplay(const ACaption: string);
    function GetRankingGrid: TCustomGrid; virtual;
    function GetRankingDataSet: TDataSet; virtual;
    procedure SetRankingGroupedByClass(AValue: boolean); virtual;
    procedure UpdateParticipationTable(ACurrentPassingId: integer); virtual; abstract;
    procedure AfterOpenRankingResultSet(ADataSet: TDataSet); virtual; abstract;
    procedure OnColorizePodium(Sender: TObject; const Rect: TRect; Field: TField; State: TGridDrawState);
    procedure CreateAndInitializePopupMenu;

    procedure OnRemoveParticipant(ASender: TObject); virtual;
    procedure OnDNS(ASender: TObject); virtual;
    procedure OnDNF(ASender: TObject); virtual;
    procedure OnDSQ(ASender: TObject); virtual;
    procedure OnActivateParticipant(ASender: TObject); virtual;
    procedure OnPenalties(ASender: TObject); virtual;
    procedure OnEditTime(ASender: TObject); virtual;

  public
    constructor Create(AParent: TWinControl; AEvent: TEventDataObject; ARaceItem: TRaceItem); virtual;
    destructor Destroy; override;

    // passing display screen
    procedure AddPassingToDisplay(APassing: TPassing; AAutoScroll: boolean); virtual;
    procedure ClearAllPassings; virtual;
    procedure ClearPassingNumber(APassingNumber: integer); virtual;

    property PassingDisplay: TWinControl read GetPassingDisplay;
    property AvailableRaceStates: TRaceStates read FAvailableRaceStates;

    // ranking
    procedure RefreshRankingDisplay;
    property RankingDisplay: TCustomGrid read GetRankingGrid;
    property RankingDataSet: TDataSet read GetRankingDataSet;
    property RankingGroupedByClass: boolean read FRankingGroupedByClass write SetRankingGroupedByClass;
    // corrections

    // Reports
    procedure ExportParticipantsToExcelTemplate(const AOutputFile: string); virtual; abstract;
    procedure ExportResultsToExcelTemplate(const AOutputFile: string; AGroupByClass: boolean); virtual; abstract;
    procedure PrintResults(AGroupByClass: boolean); virtual; abstract;
    procedure ExportResultsToCSV; virtual;
  end;

implementation

uses
  SmartTiming.Tools, Math, SmartTiming.Controller, SmartTiming.GridFormatProvider,
  DataModule, FormMain, FormCompetitorDetails, FormPenalty, FormTime;

{==============================================================================}
destructor TRaceItem.Destroy;
begin
  try
    FreeAndNil(RaceEngine);
  finally
    inherited Destroy;
  end;
end;

{==============================================================================}
constructor TCustomRaceEngine.Create(AParent: TWinControl; AEvent: TEventDataObject; ARaceItem: TRaceItem);
begin
  FPassingDisplay := nil;
  FOwner := TComponent.Create(nil);
  FParent := AParent;

  FEvent := AEvent;
  FRaceItem := ARaceItem;
  FAvailableRaceStates := [rsNotStarted, rsWarmUp, rsStarted, rsNeutralized, rsFinished, rsAborted, rsStopped];

  CreateAndInitializePopupMenu;

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

  FLastChangeTimestamp := Now;
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
    FreeAndNil(FPopupMenuRanking);
  finally
    inherited Destroy;
  end;
end;

{==============================================================================}
procedure TCustomRaceEngine.CreateAndInitializePopupMenu;

  procedure AddMenuItem(const ACaption: string; AOnClickEvent: TNotifyEvent);
  var
    lMenuItem: TMenuItem;
  begin
    lMenuItem := TMenuItem.Create(nil);
    lMenuItem.Caption := ACaption;
    lMenuItem.OnClick := AOnClickEvent;
    FPopupMenuRanking.Items.Add(lMenuItem);
  end;

begin
  FPopupMenuRanking := TPopupMenu.Create(nil);

  AddMenuItem('Entfernen', OnRemoveParticipant);
  AddMenuItem('DNS', OnDNS);
  AddMenuItem('DNF', OnDNF);
  AddMenuItem('DSQ', OnDSQ);
  AddMenuItem('Reaktivieren', OnActivateParticipant);
  AddMenuItem('Strafen', OnPenalties);
  AddMenuItem('Zielzeit ändern', OnEditTime);
end;

{==============================================================================}
function TCustomRaceEngine.GetPassingDisplay: TWinControl;
begin
  if FPassingDisplay <> nil then
    Exit(FPassingDisplay);

  FPassingDisplay := TListView.CreateParented(FParent.Handle);
  FPassingDisplay.Parent := FParent;
  FPassingDisplay.Visible := true;
  FPassingDisplay.Align := alClient;
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
procedure TCustomRaceEngine.OnColorizePodium(Sender: TObject; const Rect: TRect; Field: TField; State: TGridDrawState);
var
  lBgColor: TColor;
  lFGColor: TColor;
  lSender: TDBGrid;
  lLeft: Integer;
begin
  if not (Sender is TDBGrid) then
    Exit;
  lSender := Sender as TDBGrid;
  if Field.IsNull or (not SameText(Field.DisplayName, 'Platz')) then
    Exit;
  if Field.AsInteger > 3 then
    Exit;

  SmartTimingTools.GetColorsForPodium(Field.AsInteger, lBgColor, lFgColor);

  lSender.Canvas.Brush.Color := lBgColor;
  lSender.Canvas.Font.Color := lFgColor;
  lSender.Canvas.FillRect(Rect);

  if Field.Alignment = taRightJustify then
    lLeft := Rect.Right - lSender.Canvas.TextWidth(Field.DisplayText) - 3
  else
    lLeft := Rect.Left + (Rect.Right - Rect.Left) div 2 - (lSender.Canvas.TextWidth(Field.DisplayText) div 2);
  lSender.Canvas.TextRect(Rect, lLeft, Rect.Top + 2, Field.DisplayText);
end;

{==============================================================================}
function TCustomRaceEngine.GetRankingGrid: TCustomGrid;
begin
  if FRankingGrid <> nil then
    Exit(FRankingGrid);

  FRankingGrid := TDBGrid.CreateParented(FParent.Handle);
  FRankingGrid.Name := 'DBGridRanking';
  FRankingGrid.ParentFont := false;
  FRankingGrid.Visible := false;
  FRankingGrid.Align := alNone;
  FRankingGrid.DataSource := FDataSourceRankings;
  FRankingGrid.Options := [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect,dgMultiSelect, dgTitleClick, dgTitleHotTrack];
  FRankingGrid.OnDrawDataCell := OnColorizePodium;
  FRankingGrid.PopupMenu := FPopupMenuRanking;
  result := FRankingGrid;
//  AfterOpenRankingResultSet(FSQLDataSetRankings);
end;

{==============================================================================}
function TCustomRaceEngine.GetRankingDataSet: TDataSet;
begin
  result := TDataSet(FSQLDataSetRankings);
end;

{==============================================================================}
procedure TCustomRaceEngine.SetRankingGroupedByClass(AValue: boolean);
begin
  FRankingGroupedByClass := AValue;
  FLastChangeTimestamp := Now;
  RefreshRankingDisplay;
end;

{==============================================================================}
procedure TCustomRaceEngine.RefreshRankingDisplay;
var
  i: integer;
  lColumn: TColumn;
begin
  if FLastRefreshTimestamp >= FLastChangeTimestamp then
    Exit;

  FSQLDataSetRankings.Active := false;
  FSQLDataSetRankings.CommandText := FRankingQuery;
  FSQLDataSetRankings.Active := true;

  if FClientDataSetRankings.Active then
    FClientDataSetRankings.Refresh
  else
    FClientDataSetRankings.Active := True;
  FLastRefreshTimestamp := Now;

  if FRankingGrid = nil then
    GetRankingGrid;

  for i := 0 to FRankingGrid.Columns.Count - 1 do
  begin
    lColumn := FRankingGrid.Columns[i];
    SmartTimingTools.SetColumnProperties('RANKING', lColumn);
  end;
  AfterOpenRankingResultSet(FClientDataSetRankings);
end;

{==============================================================================}
procedure TCustomRaceEngine.AddPassingToDisplay(APassing: TPassing; AAutoScroll: boolean);
begin
  if (FPassingDisplay = nil) or  (not (FPassingDisplay is TMemo)) then
    Exit;
  TMemo(FPassingDisplay).Lines.Add(APassing.ToString);
  if AAutoScroll then
    SendMessage(FPassingDisplay.Handle, EM_LINESCROLL, 0,TMemo(FPassingDisplay).Lines.Count);
  FLastChangeTimestamp := Now;
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

{==============================================================================}
procedure TCustomRaceEngine.ExportResultsToCSV;
var
  lFileName: string;
  lResultSet: TSQLDataSet;
  lFieldName: string;
  lValue: string;
  lCSVFile: TextFile;
  lField: TField;
begin
  lResultSet := nil;
  try
    MainDataModule.FillReadOnlyDataSetForSQL(
      Format(FResultSQLFormat, [FRaceItem.Id.ToString, '']),
      lResultSet);

    lResultSet.First;
    if lResultSet.Eof then
      Exit;

    AssignFile(lCSVFile, lFileName);
    try
      Rewrite(lCSVFile);

      // Write header row
      for lField in lResultSet.Fields do
      begin
        if not lField.Visible then
          continue;

        Write(lCSVFile, '"' + lField.FieldName + '"');
        if lField.Index < lResultSet.FieldCount - 1 then
          Write(lCSVFile, ',');
      end;
      Writeln(lCSVFile);

      while not lResultSet.Eof do
      begin
        for lField in lResultSet.Fields do
        begin
          if not lField.Visible then
            continue;

          lFieldName := lField.FieldName;
          lValue := lField.AsString;

          // TODO Write field value
        end;
        lResultSet.Next;
      end;
    finally
      CloseFile(lCSVFile);
    end;
  finally
    FreeAndNil(lResultSet);
  end;
end;

{==============================================================================}
function TCustomRaceEngine.GetSelectedCompetitorIds: TArray<integer>;
var
  i: Integer;
begin
  FRankingGrid.BeginUpdate;
  try
    for i := 0 to FRankingGrid.SelectedRows.Count -1 do
    begin
      SetLength(result, Length(result) + 1);
      FRankingGrid.DataSource.DataSet.GotoBookmark(TBookmark(FRankingGrid.SelectedRows[i]));
      result[High(result)] := FRankingGrid.DataSource.DataSet.FieldByName('COMPETITORID').Value;
    end;
  finally
    FRankingGrid.EndUpdate;
  end;
end;

{==============================================================================}
procedure TCustomRaceEngine.SetParticipantState(AState: TParticipantState);
var
  lCompetitorIDs: TArray<integer>;
begin
  lCompetitorIDs := GetSelectedCompetitorIds;
  MainDataModule.SetParticipantState(FRaceItem.Id, lCompetitorIDs, AState);
  FLastChangeTimestamp := Now;
  RefreshRankingDisplay;
end;

{==============================================================================}
procedure TCustomRaceEngine.OnRemoveParticipant(ASender: TObject);
var
  lCompetitorIDs: TArray<integer>;
begin
  lCompetitorIDs := GetSelectedCompetitorIds;
  MainDataModule.RemoveCompetitorsFromRace(GSmartTimingController.Event.EventId, FRaceItem.Id, lCompetitorIDs);
  FLastChangeTimestamp := Now;
  RefreshRankingDisplay;
end;

{==============================================================================}
procedure TCustomRaceEngine.OnDNS(ASender: TObject);
begin
  SetParticipantState(psDNS);
end;

{==============================================================================}
procedure TCustomRaceEngine.OnDNF(ASender: TObject);
begin
  SetParticipantState(psDNF);
end;

{==============================================================================}
procedure TCustomRaceEngine.OnDSQ(ASender: TObject);
begin
  SetParticipantState(psDSQ);
end;

{==============================================================================}
procedure TCustomRaceEngine.OnActivateParticipant(ASender: TObject);
begin
  SetParticipantState(psActive);
end;

{==============================================================================}
procedure TCustomRaceEngine.OnPenalties(ASender: TObject);
var
  lForm: TFormEditPenalty;
begin
  lForm := TFormEditPenalty.Create(nil);
  try
    lForm.MemoPenalty.Text := '';
    if not lForm.ShowModal = mrOK then
      Exit;

  finally
    FreeAndNil(lForm);
  end;
end;

{==============================================================================}
procedure TCustomRaceEngine.OnEditTime(ASender: TObject);
var
  lForm: TFormEditTime;
  lTime: TDatetime;
begin
  lForm := TFormEditTime.Create(nil);
  try
    lForm.Time := Frac(Now);
    if not lForm.ShowModal = mrOK then
      Exit;
    lTime := lForm.Time;
  finally
    FreeAndNil(lForm);
  end;
end;

end.
