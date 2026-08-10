unit RaceEngine.Custom;

interface

uses
  Controls, StdCtrls, ComCtrls, ExtCtrls, SysUtils, Graphics, Types, UITypes, Classes, Grids,
  Menus, DB, SQLExpr, Provider, DBClient, DBGrids, Dialogs, Windows, Winapi.Messages, ImgList,
  SmartTiming.Consts, DecoderInterface, SmartTiming.Event, Report.ExcelTemplateFiller,
  Generics.Collections;

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
    MinLapDuration: integer; (* seconds; from RACES.MINLAPDURATION via FillRaceItemFromDataSet *)
    Status: TRaceStatus;
    RaceEngine: TCustomRaceEngine;
  public
    destructor Destroy; override;
    function InfoToJSON: string;
  end;

  TCustomRaceEngine = class
  private
    function GetSelectedCompetitorIds: TArray<integer>;
    function TryGetFirstSelectedParticipationId(out AParticipationId: Integer): Boolean;
    procedure SetParticipantState(AState: TParticipantState);
    (* Plan 6: Dialog → DB/Cache already done → Recalc → UI. *)
    procedure AfterPassingCorrection(ARebuildProtocol: Boolean = True);
    procedure AfterRankingCorrection;
    procedure OnProtocolFilterChange(ASender: TObject);

  protected
    const
      cPassingItemSubItemIdxName = 0;
      cPassingItemSubItemIdxTime = 1;
      cPassingItemSubItemIdxTxId = 2;
      cPassingItemSubItemIdxChipId = 3;
      cPassingItemSubItemIdxPassingNumber = 4;

  protected
    FOwner: TComponent;
    FParent: TWinControl;
    FEvent: TEventDataObject;
    FRaceItem: TRaceItem;
    FProtocolHost: TPanel;
    FFilterPanel: TPanel;
    FFilterCombo: TComboBox;
    FPassingDisplay: TWinControl;
    FProtocolFilter: TPassingProtocolFilter;
    FRankingGrid: TDBGrid;
    FRankingGroupedByClass: boolean;
    FAvailableRaceStates: TRaceStates;
    FRankingQuery: string;
    FPopupMenuRanking: TPopupMenu;
    FPopupMenuPassings: TPopupMenu;
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
    FRankingSQLClassSorting: string;
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
    procedure OnDrawRankingColumn(Sender: TObject; const Rect: TRect; Field: TField; State: TGridDrawState);
    procedure OnColorizePodium(Sender: TObject; const Rect: TRect; Field: TField; State: TGridDrawState);
    procedure CreateAndInitializePopupMenu;
    procedure PassingCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var ACompare: Integer);

    procedure OnRemoveParticipant(ASender: TObject); virtual;
    procedure OnDNS(ASender: TObject); virtual;
    procedure OnDNF(ASender: TObject); virtual;
    procedure OnDSQ(ASender: TObject); virtual;
    procedure OnActivateParticipant(ASender: TObject); virtual;
    procedure OnPenalties(ASender: TObject); virtual;
    procedure OnEditTime(ASender: TObject); virtual;

    procedure OnInvalidatePassing(ASender: TObject);  virtual;
    procedure OnValidatePassing(ASender: TObject); virtual;
    procedure OnShowCompetitorPassings(ASender: TObject); virtual;
    procedure OnChangeCompetitorOfTransponder(ASender: TObject); virtual;
    procedure OnChangePassingTime(ASender: TObject); virtual;
    procedure OnRemovePassing(ASender: TObject); virtual;
    procedure OnUnassignChip(ASender: TObject); virtual;
    procedure OnShowAssignmentHistory(ASender: TObject); virtual;

    procedure AssignLap(var APassing: TPassing); virtual;
    function PassingImageIndex(const APassing: TPassing): Integer; virtual;
    function PassingMatchesFilter(const APassing: TPassing): Boolean; virtual;
    procedure AppendPassingListItem(const APassing: TPassing; AAutoScroll: Boolean); virtual;

    procedure OnPassingItemDragDrop(ASender, ASource: TObject; AX, AY: Integer);
    procedure OnPassingItemDragOver(ASender, ASource: TObject; AX, AY: Integer; AState: TDragState; var AAccept: Boolean);
    procedure OnPassingItemCompare(ASender: TObject; AItem1, AItem2: TListItem; AData: Integer; var ACompare: Integer); virtual; abstract;

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
    procedure RecalcCountingLaps;
    procedure RefreshPassingListStatus; virtual;
    procedure ReassignLapsForRace; virtual;
    procedure ShowCompetitorPassings(ACompetitorId: Integer); virtual;
    procedure SetPassingStatusAndRecalc(APassingNumber: Integer; AStatus: TPassingState);
    procedure RebuildProtocolDisplay; virtual;

    // Reports
    procedure ExportParticipantsToExcelTemplate(const AOutputFile: string); virtual; abstract;
    procedure ExportResultsToExcelTemplate(const AOutputFile: string; AGroupByClass: boolean); virtual; abstract;
    procedure PrintResults(AGroupByClass: boolean); virtual; abstract;
    procedure ExportResultsToCSV; virtual;
  end;

implementation

uses
  SmartTiming.Tools, Math, SmartTiming.Controller, SmartTiming.GridFormatProvider,
  DataModule, FormMain, FormCompetitorDetails, FormPenalty, FormTime,
  SmartTiming.Cache, DateUtils, FormAssignCompetitorToTransponder,
  FormCompetitorPassings, SmartTiming.TransponderAssignment, Data.DBXCommon,
  System.Generics.Defaults, System.Variants;

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
function TRaceItem.InfoToJSON: string;
var
  lFirstPassingIsLapBoolStr: string;
begin
  if FirstPassingIsLap then
    lFirstPassingIsLapBoolStr := 'true'
  else
    lFirstPassingIsLapBoolStr := 'false';

  result := Format(
    '{ "id": %d, "racetype": "%s", "starttime": "%s", "title": "%s", "laps": %d, "distance": %s, "firstpassingislap": %s, "minlapduration": %d, "status": "%s" }',
    [Id,
     SmartTimingTools.GetRaceTypeStringFromEnum(RaceType),
     StartTime.ToISO8601(false),
     Title,
     Laps,
     Distance.ToString.Replace(',','.'),
     lFirstPassingIsLapBoolStr,
     MinLapDuration,
     SmartTimingTools.GetRaceStatusStringFromEnum(Status)]);
end;

{==============================================================================}
constructor TCustomRaceEngine.Create(AParent: TWinControl; AEvent: TEventDataObject; ARaceItem: TRaceItem);
begin
  FPassingDisplay := nil;
  FProtocolHost := nil;
  FFilterPanel := nil;
  FFilterCombo := nil;
  FProtocolFilter := ppfAll;
  FOwner := AParent;
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
    (* Host owns filter panel + listview when created. *)
    if FProtocolHost <> nil then
    begin
      FPassingDisplay := nil;
      FFilterPanel := nil;
      FFilterCombo := nil;
      FreeAndNil(FProtocolHost);
    end
    else
      FreeAndNil(FPassingDisplay);
    FreeAndNil(FDataSourceRankings);
    FreeAndNil(FClientDataSetRankings);
    FreeAndNil(FDataSetProviderRankings);
    FreeAndNil(FSQLDataSetRankings);
    FreeAndNil(FPopupMenuRanking);
    FreeAndNil(FPopupMenuPassings);
  finally
    inherited Destroy;
  end;
end;

{==============================================================================}
procedure TCustomRaceEngine.CreateAndInitializePopupMenu;

  procedure AddMenuItem(AMenu: TPopupMenu; const ACaption: string; AOnClickEvent: TNotifyEvent);
  var
    lMenuItem: TMenuItem;
  begin
    lMenuItem := TMenuItem.Create(nil);
    lMenuItem.Caption := ACaption;
    lMenuItem.OnClick := AOnClickEvent;
    AMenu.Items.Add(lMenuItem);
  end;

begin
  FPopupMenuRanking := TPopupMenu.Create(nil);
  AddMenuItem(FPopupMenuRanking, 'Entfernen', OnRemoveParticipant);
  AddMenuItem(FPopupMenuRanking, 'DNS', OnDNS);
  AddMenuItem(FPopupMenuRanking, 'DNF', OnDNF);
  AddMenuItem(FPopupMenuRanking, 'DSQ', OnDSQ);
  AddMenuItem(FPopupMenuRanking, 'Reaktivieren', OnActivateParticipant);
  AddMenuItem(FPopupMenuRanking, 'Strafen', OnPenalties);
  AddMenuItem(FPopupMenuRanking, 'Zielzeit ändern', OnEditTime);
  AddMenuItem(FPopupMenuRanking, 'Chip entziehen', OnUnassignChip);
  AddMenuItem(FPopupMenuRanking, 'Chip-Historie', OnShowAssignmentHistory);
  AddMenuItem(FPopupMenuRanking, cMessagesMenuCompetitorPassings, OnShowCompetitorPassings);

  FPopupMenuPassings := TPopupMenu.Create(nil);
  AddMenuItem(FPopupMenuPassings, 'Ungültig', OnInvalidatePassing);
  AddMenuItem(FPopupMenuPassings, 'Gültig', OnValidatePassing);
  AddMenuItem(FPopupMenuPassings, cMessagesMenuCompetitorPassings, OnShowCompetitorPassings);
  AddMenuItem(FPopupMenuPassings, 'Fahrer ändern', OnChangeCompetitorOfTransponder);
  AddMenuItem(FPopupMenuPassings, 'Durchfahrtszeit ändern', OnChangePassingTime);
  AddMenuItem(FPopupMenuPassings, 'Entfernen', OnRemovePassing);
end;

{==============================================================================}
function TCustomRaceEngine.GetPassingDisplay: TWinControl;
var
  lFilterLabel: TLabel;
begin
  if FPassingDisplay <> nil then
    Exit(FPassingDisplay);

  FProtocolHost := TPanel.Create(FOwner);
  FProtocolHost.Parent := FParent;
  FProtocolHost.Align := alClient;
  FProtocolHost.BevelOuter := bvNone;
  FProtocolHost.Caption := '';

  FFilterPanel := TPanel.Create(FProtocolHost);
  FFilterPanel.Parent := FProtocolHost;
  FFilterPanel.Align := alTop;
  FFilterPanel.Height := 30;
  FFilterPanel.BevelOuter := bvNone;
  FFilterPanel.Caption := '';
  FFilterPanel.Padding.Left := 6;
  FFilterPanel.Padding.Top := 4;
  FFilterPanel.Padding.Right := 6;
  FFilterPanel.Padding.Bottom := 2;

  lFilterLabel := TLabel.Create(FFilterPanel);
  lFilterLabel.Parent := FFilterPanel;
  lFilterLabel.Align := alLeft;
  lFilterLabel.Layout := tlCenter;
  lFilterLabel.Caption := cMessagesProtocolFilterLabel;
  lFilterLabel.Width := 48;

  FFilterCombo := TComboBox.Create(FFilterPanel);
  FFilterCombo.Parent := FFilterPanel;
  FFilterCombo.Align := alLeft;
  FFilterCombo.Width := 140;
  FFilterCombo.Style := csDropDownList;
  FFilterCombo.Items.Add(cMessagesProtocolFilterAll);
  FFilterCombo.Items.Add(cMessagesProtocolFilterValid);
  FFilterCombo.Items.Add(cMessagesProtocolFilterManual);
  FFilterCombo.ItemIndex := Ord(FProtocolFilter);
  FFilterCombo.OnChange := OnProtocolFilterChange;

  FPassingDisplay := TListView.Create(FProtocolHost);
  FPassingDisplay.Parent := FProtocolHost;
  FPassingDisplay.Visible := true;
  FPassingDisplay.Align := alClient;

  TListView(FPassingDisplay).SmallImages := GFormMain.ImageListPassingStates;
  TListView(FPassingDisplay).StateImages := GFormMain.ImageListPassingStates;
  TListView(FPassingDisplay).PopupMenu := FPopupMenuPassings;
  TListView(FPassingDisplay).FullDrag := True;
  TListView(FPassingDisplay).HotTrack := True;
  TListView(FPassingDisplay).HotTrackStyles := [htHandPoint,htUnderlineHot];
  TListView(FPassingDisplay).RowSelect := True;
  TListView(FPassingDisplay).HideSelection := false;
  TListView(FPassingDisplay).DragMode := TDragMode.dmAutomatic;
  TListView(FPassingDisplay).OnDragDrop := OnPassingItemDragDrop;
  TListView(FPassingDisplay).OnDragOver := OnPassingItemDragOver;
  TListView(FPassingDisplay).OnCustomDrawItem := OnDrawListItem;
  TListView(FPassingDisplay).ViewStyle := vsReport;
  TListView(FPassingDisplay).OnCompare := PassingCompare;

  AddColumnToDisplay(cFieldTitleBib);
  AddColumnToDisplay(cFieldTitleLastName + ', ' + cFieldTitleFirstName);
  AddColumnToDisplay(cFieldTitlePassingTime);
  AddColumnToDisplay(cFieldTitleTransponder);
  AddColumnToDisplay(cFieldTitleChipID);
  AddColumnToDisplay('PassingId');

  result := FPassingDisplay;
end;

{==============================================================================}
procedure TCustomRaceEngine.PassingCompare(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var ACompare: Integer);
begin
  ACompare := AnsiCompareText(Item1.SubItems[cPassingItemSubItemIdxTime], Item2.SubItems[cPassingItemSubItemIdxTime]);
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
  lPassingNumber: Integer;
  lPassing: TPassing;
  lInvalid: Boolean;
  lImages: TCustomImageList;
  lIconLeft: Integer;

  // Fit the rect used for TextRect
  Procedure PrepareTextRect;
  begin
    rt := r;
    rt.Left := rt.Left + 5;
    rt.Top := rt.Top + 1;
  end;
begin
  lInvalid := False;
  if (AItem.SubItems.Count > cPassingItemSubItemIdxPassingNumber) and
     TryStrToInt(AItem.SubItems[cPassingItemSubItemIdxPassingNumber], lPassingNumber) then
  begin
    try
      lPassing := TPassingStore.GetSingleton.GetPassing(lPassingNumber);
      lInvalid := ((lPassing.Flags and 2) <> 2) and
        (lPassing.PassingStatus <> Ord(psValid));
    except
      lInvalid := False;
    end;
  end;

  if lInvalid then
  begin
    lBgColor := $00E8E8E8;
    lFGColor := clGray;
  end
  else
    SmartTimingTools.GetColorsForRaceStatus(TRaceStatus(AItem.Data), true, lBgColor, lFgColor);

  TListView(ASender).Canvas.Brush.Color := lBgColor;
  TListView(ASender).Canvas.Font.Color := lFGColor;
  if lInvalid then
    TListView(ASender).Canvas.Font.Style := [fsStrikeOut]
  else
    TListView(ASender).Canvas.Font.Style := [];

  r := AItem.DisplayRect(drBounds);
  ASender.Canvas.FillRect(r);

  lIconLeft := r.Left + 2;
  lImages := TListView(ASender).SmallImages;
  if (lImages <> nil) and (AItem.ImageIndex >= 0) and (AItem.ImageIndex < lImages.Count) then
  begin
    lImages.Draw(TListView(ASender).Canvas, lIconLeft, r.Top + 1, AItem.ImageIndex);
    lIconLeft := lIconLeft + lImages.Width + 2;
  end;

  r.Right := r.Left + TListView(ASender).Columns[0].Width;
  r.Left := Max(r.Left, lIconLeft);
  s := AItem.Caption;
  PrepareTextRect;
  TListView(ASender).Canvas.TextRect(rt, s, [tfSingleLine, tfEndEllipsis]);
  if TListView(ASender).ViewStyle = vsReport then
  begin // Paint the Subitems if ViewStyle = vsReport
    r.Left := AItem.DisplayRect(drBounds).Left;
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
procedure TCustomRaceEngine.OnDrawRankingColumn(Sender: TObject; const Rect: TRect; Field: TField; State: TGridDrawState);
var
  lSender: TDBGrid;
  lLeft: Integer;
begin
  try
    if not (Sender is TDBGrid) then
      Exit;
    lSender := Sender as TDBGrid;
    if Field.IsNull or (not SameText(Field.DisplayName, 'Platz')) then
      Exit;
    if lSender.DataSource.DataSet.FieldByName('DNS').AsInteger <> 0 then
    begin
      lLeft := Rect.Left + (Rect.Right - Rect.Left) div 2 - (lSender.Canvas.TextWidth('DNS') div 2);
      lSender.Canvas.TextRect(Rect, lLeft, Rect.Top + 2, 'DNS');
    end;
    if lSender.DataSource.DataSet.FieldByName('DNF').AsInteger <> 0 then
    begin
      lLeft := Rect.Left + (Rect.Right - Rect.Left) div 2 - (lSender.Canvas.TextWidth('DNF') div 2);
      lSender.Canvas.TextRect(Rect, lLeft, Rect.Top + 2, 'DNF');
    end;
    if lSender.DataSource.DataSet.FieldByName('DSQ').AsInteger <> 0 then
    begin
      lLeft := Rect.Left + (Rect.Right - Rect.Left) div 2 - (lSender.Canvas.TextWidth('DSQ') div 2);
      lSender.Canvas.TextRect(Rect, lLeft, Rect.Top + 2, 'DSQ');
    end;
  finally
    OnColorizePodium(Sender, Rect, Field, State);
  end;
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
  FRankingGrid.OnDrawDataCell := OnDrawRankingColumn;
  FRankingGrid.OnDrawColumnCell := SmartTimingTools.DBGridDrawCheckBox;

  FRankingGrid.PopupMenu := FPopupMenuRanking;
  result := FRankingGrid;
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
procedure TCustomRaceEngine.RecalcCountingLaps;
var
  lPassingList: TDictionary<TDatetime, TPassing>;
  lTime: TDatetime;
  lPassing: TPassing;
  lTimeArray: TArray<TDatetime>;
  lInActiveRaceSection: boolean;
  lTransaction: TDBXTransaction;

  function PassingIsStart: boolean;
  begin
    result :=
      (lPassing.Flags = 2)
      and
      (lPassing.Hits = 0 - Ord(rsStarted));
    if result then
      lInActiveRaceSection := true;
  end;

  // rsNotStarted = 0, rsWarmUp, rsStarted, rsNeutralized, rsFinished, rsAborted, rsStopped
  function PassingIsBreak: boolean;
  begin
    result :=
      (lPassing.Flags = 2)
      and
      ((lPassing.Hits = -Ord(rsNotStarted))
       or
       (lPassing.Hits = -Ord(rsNeutralized))
       or
       (lPassing.Hits = -Ord(rsFinished))
       or
       (lPassing.Hits = -Ord(rsStopped)));
    if result then
      lInActiveRaceSection := false;
  end;

begin
  lPassingList := TDictionary<TDatetime, TPassing>.Create;
  try
    lTransaction := MainDataModule.SQLConnection.BeginTransaction;
    try
      MainDataModule.ResetRaceParticitipations(FRaceItem.Id);
      (* Decoder-sequence cursor only — synthetic MANUAL/SYSTEM ids must not pull
         FillPassingListFrom into the negative range (double-count after Recalc). *)
      FLastConsideredPassingId := 0;

      TPassingStore.GetSingleton.FillPassingListForRaceId(FRaceItem.Id, lPassingList, true, true);
      lTimeArray := lPassingList.Keys.ToArray;
      TArray.Sort<TDatetime>(lTimeArray);

      lInActiveRaceSection := false;
      for lTime in lTimeArray do
      begin
        if not lPassingList.TryGetValue(lTime, lPassing) then
          Continue;

        if PassingIsStart then
          Continue;
        if PassingIsBreak then
          Continue;
        if not lInActiveRaceSection then
          Continue;
        (* SYSTEM markers use synthetic negative ids (Flags=2). MANUAL also uses
           negatives but must score — skip markers only. *)
        if lPassing.Flags = 2 then
          Continue;

        if lPassing.PassingNumber >= 0 then
          FLastConsideredPassingId := lPassing.PassingNumber - 1;
        UpdateParticipationTable(lPassing.PassingNumber);
      end;
      MainDataModule.SQLConnection.CommitFreeAndNil(lTransaction);
    except
      MainDataModule.SQLConnection.RollbackFreeAndNil(lTransaction);
      raise;
    end;
    RefreshRankingDisplay;

  finally
    FreeAndNil(lPassingList);
  end;
end;

{==============================================================================}
procedure TCustomRaceEngine.RefreshPassingListStatus;
begin
  if (FPassingDisplay = nil) or not (FPassingDisplay is TListView) then
    Exit;
  TListView(FPassingDisplay).Invalidate;
  TListView(FPassingDisplay).Update;
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
function TCustomRaceEngine.TryGetFirstSelectedParticipationId(
  out AParticipationId: Integer): Boolean;
var
  lIds: TArray<Integer>;
  lCompetitorId: Integer;
begin
  Result := False;
  AParticipationId := -1;
  lIds := GetSelectedCompetitorIds;
  if Length(lIds) = 0 then
    Exit;
  lCompetitorId := lIds[0];
  Result := MainDataModule.TryGetParticipationId(FRaceItem.Id, lCompetitorId, AParticipationId);
end;

{==============================================================================}
procedure TCustomRaceEngine.AfterPassingCorrection(ARebuildProtocol: Boolean);
begin
  FLastChangeTimestamp := Now;
  RecalcCountingLaps;
  ReassignLapsForRace;
  if ARebuildProtocol then
    RebuildProtocolDisplay;
  RefreshRankingDisplay;
end;

{==============================================================================}
procedure TCustomRaceEngine.AfterRankingCorrection;
begin
  FLastChangeTimestamp := Now;
  RefreshRankingDisplay;
end;

{==============================================================================}
procedure TCustomRaceEngine.SetParticipantState(AState: TParticipantState);
var
  lCompetitorIDs: TArray<integer>;
begin
  lCompetitorIDs := GetSelectedCompetitorIds;
  if Length(lCompetitorIDs) = 0 then
  begin
    SmartTimingTools.ShowDialog(cMessagesNoParticipantSelected, '', [tcbOk], tcbOk);
    Exit;
  end;
  MainDataModule.SetParticipantState(FRaceItem.Id, lCompetitorIDs, AState);
  AfterRankingCorrection;
end;

{==============================================================================}
procedure TCustomRaceEngine.OnRemoveParticipant(ASender: TObject);
var
  lCompetitorIDs: TArray<integer>;
begin
  lCompetitorIDs := GetSelectedCompetitorIds;
  if Length(lCompetitorIDs) = 0 then
  begin
    SmartTimingTools.ShowDialog(cMessagesNoParticipantSelected, '', [tcbOk], tcbOk);
    Exit;
  end;
  MainDataModule.RemoveCompetitorsFromRace(GSmartTimingController.Event.EventId, FRaceItem.Id, lCompetitorIDs);
  AfterRankingCorrection;
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
  lParticipationId: Integer;
  lText: string;
  lFields: TArray<string>;
  lValues: TArray<Variant>;
begin
  if not TryGetFirstSelectedParticipationId(lParticipationId) then
  begin
    SmartTimingTools.ShowDialog(cMessagesNoParticipantSelected, '', [tcbOk], tcbOk);
    Exit;
  end;

  lForm := TFormEditPenalty.Create(nil);
  try
    lForm.MemoPenalty.Text := MainDataModule.GetParticipationStringField(lParticipationId, 'PENALTIES');
    if lForm.ShowModal <> mrOK then
      Exit;
    lText := Trim(lForm.MemoPenalty.Text);
  finally
    FreeAndNil(lForm);
  end;

  SetLength(lFields, 1);
  SetLength(lValues, 1);
  lFields[0] := 'PENALTIES';
  if lText = '' then
    lValues[0] := Null
  else
    lValues[0] := lText;
  MainDataModule.UpdateParticipationValues(lParticipationId, lFields, lValues);
  AfterRankingCorrection;
end;

{==============================================================================}
procedure TCustomRaceEngine.OnEditTime(ASender: TObject);
var
  lForm: TFormEditTime;
  lParticipationId: Integer;
  lCurrent: string;
  lStartStr: string;
  lTime: TDateTime;
  lStartTime: TDateTime;
  lRankingTime: TDateTime;
  lFields: TArray<string>;
  lValues: TArray<Variant>;
  lFormatSettings: TFormatSettings;
  lModal: Integer;
  lOverride: Boolean;

  function TryParseParticipationTime(const AText: string; out ATime: TDateTime): Boolean;
  begin
    Result := False;
    ATime := 0;
    if Trim(AText) = '' then
      Exit;
    lFormatSettings := TFormatSettings.Create;
    lFormatSettings.TimeSeparator := ':';
    lFormatSettings.DecimalSeparator := '.';
    if TryStrToTime(AText, ATime, lFormatSettings) then
    begin
      ATime := Frac(ATime);
      Exit(True);
    end;
    Result := TryStrToDateTime(AText, ATime, lFormatSettings);
    if Result then
      ATime := Frac(ATime);
  end;

begin
  if not TryGetFirstSelectedParticipationId(lParticipationId) then
  begin
    SmartTimingTools.ShowDialog(cMessagesNoParticipantSelected, '', [tcbOk], tcbOk);
    Exit;
  end;

  lOverride := MainDataModule.IsParticipationFinishTimeOverridden(lParticipationId);
  lCurrent := Trim(MainDataModule.GetParticipationStringField(lParticipationId, 'FINISHTIME'));
  lForm := TFormEditTime.Create(nil);
  try
    lForm.OverrideActive := lOverride;
    if TryParseParticipationTime(lCurrent, lTime) then
      lForm.Time := lTime
    else
      lForm.Time := Frac(Now);
    lModal := lForm.ShowModal;
    if lModal = mrRetry then
    begin
      (* Clear override → full Recalc restores finish/ranking from passings. *)
      SetLength(lFields, 3);
      SetLength(lValues, 3);
      lFields[0] := 'FINISHTIMEOVERRIDE';
      lValues[0] := 0;
      lFields[1] := 'FINISHTIME';
      lValues[1] := Null;
      lFields[2] := 'RANKINGTIME';
      lValues[2] := Null;
      MainDataModule.UpdateParticipationValues(lParticipationId, lFields, lValues);
      RecalcCountingLaps;
      AfterRankingCorrection;
      Exit;
    end;
    if lModal <> mrOK then
      Exit;
    lTime := Frac(lForm.Time);
  finally
    FreeAndNil(lForm);
  end;

  SetLength(lFields, 3);
  SetLength(lValues, 3);
  lFields[0] := 'FINISHTIME';
  lValues[0] := FormatDateTime('hh:nn:ss.zzz', lTime);
  lFields[1] := 'FINISHTIMEOVERRIDE';
  lValues[1] := 1;
  lFields[2] := 'RANKINGTIME';
  lStartStr := Trim(MainDataModule.GetParticipationStringField(lParticipationId, 'STARTTIME'));
  if TryParseParticipationTime(lStartStr, lStartTime) then
  begin
    lRankingTime := lTime - lStartTime;
    if lRankingTime < 0 then
      lRankingTime := lRankingTime + 1; (* crossed midnight *)
    lValues[2] := FormatDateTime('hh:nn:ss.zzz', lRankingTime);
  end
  else
    lValues[2] := Null;
  MainDataModule.UpdateParticipationValues(lParticipationId, lFields, lValues);
  AfterRankingCorrection;
end;

{==============================================================================}
procedure TCustomRaceEngine.OnInvalidatePassing(ASender: TObject);
var
  lCurrentItem: TListItem;
  lListView: TListView;
  lPassingNumber: Integer;
begin
  lListView := TListView(FPassingDisplay);
  lCurrentItem := lListView.Selected;
  if lCurrentItem = nil then
    Exit;

  lPassingNumber := lCurrentItem.SubItems[cPassingItemSubItemIdxPassingNumber].ToInteger;
  SetPassingStatusAndRecalc(lPassingNumber, psInvalid);
end;

{==============================================================================}
procedure TCustomRaceEngine.OnValidatePassing(ASender: TObject);
var
  lCurrentItem: TListItem;
  lListView: TListView;
  lPassingNumber: Integer;
begin
  lListView := TListView(FPassingDisplay);
  lCurrentItem := lListView.Selected;
  if lCurrentItem = nil then
    Exit;

  lPassingNumber := lCurrentItem.SubItems[cPassingItemSubItemIdxPassingNumber].ToInteger;
  SetPassingStatusAndRecalc(lPassingNumber, psValid);
end;

{==============================================================================}
procedure TCustomRaceEngine.SetPassingStatusAndRecalc(APassingNumber: Integer;
  AStatus: TPassingState);
var
  lPassing: TPassing;
begin
  lPassing := TPassingStore.GetSingleton.GetPassing(APassingNumber);
  GSmartTimingController.UpdatePassing(APassingNumber, lPassing.PassingTime, AStatus);
  AfterPassingCorrection;
end;

{==============================================================================}
procedure TCustomRaceEngine.AssignLap(var APassing: TPassing);
begin
  APassing.LapIndex := -1;
end;

{==============================================================================}
function TCustomRaceEngine.PassingImageIndex(const APassing: TPassing): Integer;
begin
  if APassing.IsSystemMarker then
    Exit(-1);
  if APassing.PassingStatus <> Ord(psValid) then
    Exit(cPassingImageInvalid);
  if APassing.IsManual then
    Exit(cPassingImageManual);
  if APassing.Flags = 1 then
    Exit(cPassingImageFlagged);
  Result := cPassingImageValid;
end;

{==============================================================================}
function TCustomRaceEngine.PassingMatchesFilter(const APassing: TPassing): Boolean;
begin
  if APassing.IsSystemMarker then
    Exit(True);
  case FProtocolFilter of
    ppfValidOnly:
      Result := APassing.PassingStatus = Ord(psValid);
    ppfManualOnly:
      Result := APassing.IsManual;
  else
    Result := True;
  end;
end;

{==============================================================================}
procedure TCustomRaceEngine.AppendPassingListItem(const APassing: TPassing;
  AAutoScroll: Boolean);
begin
  (* Memo / non-ListView engines: no structured list item. *)
end;

{==============================================================================}
procedure TCustomRaceEngine.OnProtocolFilterChange(ASender: TObject);
begin
  if FFilterCombo = nil then
    Exit;
  if (FFilterCombo.ItemIndex < Ord(Low(TPassingProtocolFilter))) or
     (FFilterCombo.ItemIndex > Ord(High(TPassingProtocolFilter))) then
    Exit;
  FProtocolFilter := TPassingProtocolFilter(FFilterCombo.ItemIndex);
  RebuildProtocolDisplay;
end;

{==============================================================================}
procedure TCustomRaceEngine.RebuildProtocolDisplay;
var
  lList: TList<TPassing>;
  lPassing: TPassing;
  i: Integer;
begin
  if (FPassingDisplay = nil) or not (FPassingDisplay is TListView) then
    Exit;

  TListView(FPassingDisplay).Items.BeginUpdate;
  try
    TListView(FPassingDisplay).Items.Clear;
    lList := TList<TPassing>.Create;
    try
      TPassingStore.GetSingleton.FillPassingsForRace(FRaceItem.Id, lList);
      lList.Sort(
        TComparer<TPassing>.Construct(
          function(const Left, Right: TPassing): Integer
          begin
            Result := CompareDateTime(Left.PassingTime, Right.PassingTime);
            if Result = 0 then
              Result := Left.PassingNumber - Right.PassingNumber;
          end));
      for i := 0 to lList.Count - 1 do
      begin
        lPassing := lList[i];
        if not PassingMatchesFilter(lPassing) then
          Continue;
        AppendPassingListItem(lPassing, False);
      end;
    finally
      FreeAndNil(lList);
    end;
  finally
    TListView(FPassingDisplay).Items.EndUpdate;
  end;
  RefreshPassingListStatus;
end;

{==============================================================================}
procedure TCustomRaceEngine.ReassignLapsForRace;
begin
  (* Default: no lap indexing. *)
end;

{==============================================================================}
procedure TCustomRaceEngine.ShowCompetitorPassings(ACompetitorId: Integer);
begin
  if ACompetitorId < 0 then
    Exit;
  ReassignLapsForRace;
  TFormCompetitorPassings.Execute(nil, FRaceItem, ACompetitorId);
end;

{==============================================================================}
procedure TCustomRaceEngine.OnShowCompetitorPassings(ASender: TObject);
var
  lIds: TArray<Integer>;
  lPassing: TPassing;
  lCompetitorId: Integer;
  lItem: TListItem;
begin
  if (ASender is TMenuItem) and (TMenuItem(ASender).GetParentMenu = FPopupMenuRanking) then
  begin
    lIds := GetSelectedCompetitorIds;
    if Length(lIds) <> 1 then
    begin
      SmartTimingTools.ShowDialog(cMessagesCompetitorPassingsSelectOne, '', [tcbOk], tcbOk);
      Exit;
    end;
    ShowCompetitorPassings(lIds[0]);
    Exit;
  end;

  if (FPassingDisplay = nil) or not (FPassingDisplay is TListView) then
    Exit;
  lItem := TListView(FPassingDisplay).Selected;
  if lItem = nil then
    Exit;
  lPassing := TPassingStore.GetSingleton.GetPassing(
    lItem.SubItems[cPassingItemSubItemIdxPassingNumber].ToInteger);
  if lPassing.IsSystemMarker then
    Exit;
  lCompetitorId := lPassing.CompetitorId;
  if lCompetitorId < 0 then
    TTransponderAssignmentService.TryGetCompetitorForRaceChipAtTime(
      FRaceItem.Id, lPassing.ChipId, lPassing.PassingTime, lCompetitorId);
  if lCompetitorId < 0 then
  begin
    SmartTimingTools.ShowDialog(cMessagesCompetitorPassingsNone, '', [tcbOk], tcbOk);
    Exit;
  end;
  ShowCompetitorPassings(lCompetitorId);
end;

{==============================================================================}
procedure TCustomRaceEngine.OnChangeCompetitorOfTransponder(ASender: TObject);
var
  lCurrentItem: TListItem;
  lListView: TListView;
  lPassingNumber: Integer;
  lPassing: TPassing;
  lCompetitorId: Integer;
  lResult: TAssignmentOperationResult;
begin
  lListView := TListView(FPassingDisplay);
  lCurrentItem := lListView.Selected;
  if lCurrentItem = nil then
    Exit;

  lPassingNumber := lCurrentItem.SubItems[cPassingItemSubItemIdxPassingNumber].ToInteger;
  lPassing := TPassingStore.GetSingleton.GetPassing(lPassingNumber);
  if lPassing.IsSystemMarker then
  begin
    SmartTimingTools.ShowDialog(cMessagesPassingIsSystemMarker, '', [tcbOk], tcbOk);
    Exit;
  end;
  if Trim(lPassing.ChipId) = '' then
  begin
    SmartTimingTools.ShowDialog(cMessagesChangeCompetitorNoChip, '', [tcbOk], tcbOk);
    Exit;
  end;

  if not TFormAssignCompetitor.Execute(nil, FRaceItem.Id, lCompetitorId) then
    Exit;

  if not TTransponderAssignmentService.Assign(FRaceItem.Id, lCompetitorId, lPassing.ChipId,
       lResult, lPassing.PassingTime) then
  begin
    SmartTimingTools.ShowDialog(lResult.Message, '', [tcbOk], tcbOk);
    Exit;
  end;

  MainDataModule.UpdatePassingRaceIdInDatabase(lPassingNumber, FRaceItem.Id);
  TPassingStore.GetSingleton.UpdatePassingRaceId(lPassingNumber, FRaceItem.Id);
  TPassingStore.GetSingleton.UpdatePassingDomainFields(lPassingNumber, lPassing.LapIndex,
    lCompetitorId);
  AfterPassingCorrection;
end;

{==============================================================================}
procedure TCustomRaceEngine.OnChangePassingTime(ASender: TObject);
var
  lCurrentItem: TListItem;
  lListView: TListView;
  lPassingNumber: Integer;
  lPassing: TPassing;
  lForm: TFormEditTime;
  lNewTime: TDateTime;
begin
  lListView := TListView(FPassingDisplay);
  lCurrentItem := lListView.Selected;
  if lCurrentItem = nil then
    Exit;

  lPassingNumber := lCurrentItem.SubItems[cPassingItemSubItemIdxPassingNumber].ToInteger;
  lPassing := TPassingStore.GetSingleton.GetPassing(lPassingNumber);
  if lPassing.IsSystemMarker then
  begin
    SmartTimingTools.ShowDialog(cMessagesPassingIsSystemMarker, '', [tcbOk], tcbOk);
    Exit;
  end;

  lForm := TFormEditTime.Create(nil);
  try
    lForm.Time := Frac(lPassing.PassingTime);
    if lForm.ShowModal <> mrOK then
      Exit;
    lNewTime := Trunc(lPassing.PassingTime) + Frac(lForm.Time);
  finally
    FreeAndNil(lForm);
  end;

  GSmartTimingController.UpdatePassing(lPassingNumber, lNewTime, TPassingState(lPassing.PassingStatus));
  AfterPassingCorrection;
end;

{==============================================================================}
procedure TCustomRaceEngine.OnUnassignChip(ASender: TObject);
var
  lCompetitorIDs: TArray<Integer>;
  i: Integer;
  lResult: TAssignmentOperationResult;
  lFailed: string;
begin
  lCompetitorIDs := GetSelectedCompetitorIds;
  if Length(lCompetitorIDs) = 0 then
  begin
    SmartTimingTools.ShowDialog(cMessagesNoParticipantSelected, '', [tcbOk], tcbOk);
    Exit;
  end;

  if SmartTimingTools.ShowDialog(
       Format(cMessagesChipUnassignConfirm, [Length(lCompetitorIDs)]), '',
       [tcbYes, tcbNo], tcbNo) <> mrYes then
    Exit;

  lFailed := '';
  for i := 0 to High(lCompetitorIDs) do
  begin
    if not TTransponderAssignmentService.Unassign(FRaceItem.Id, lCompetitorIDs[i], lResult) then
    begin
      if lFailed <> '' then
        lFailed := lFailed + sLineBreak;
      lFailed := lFailed + lResult.Message;
    end;
  end;

  if lFailed <> '' then
    SmartTimingTools.ShowDialog(lFailed, '', [tcbOk], tcbOk);
  AfterPassingCorrection;
end;

{==============================================================================}
procedure TCustomRaceEngine.OnShowAssignmentHistory(ASender: TObject);
var
  lList: TList<TTransponderAssignment>;
  lAssignment: TTransponderAssignment;
  lLines: TStringList;
  i: Integer;
  lValidTo: string;
begin
  lList := TList<TTransponderAssignment>.Create;
  lLines := TStringList.Create;
  try
    TTransponderAssignmentStore.GetSingleton.FillAssignmentsForRace(FRaceItem.Id, lList, False);
    if lList.Count = 0 then
    begin
      SmartTimingTools.ShowDialog(cMessagesAssignmentHistoryEmpty, '', [tcbOk], tcbOk);
      Exit;
    end;

    for i := 0 to lList.Count - 1 do
    begin
      lAssignment := lList[i];
      if lAssignment.IsOpen then
        lValidTo := 'offen'
      else
        lValidTo := FormatDateTime('hh:nn:ss', lAssignment.ValidTo);
      lLines.Add(Format('%s  |  Chip %s  |  %s → %s',
        [MainDataModule.GetCompetitorDisplayName(lAssignment.CompetitorId),
         lAssignment.ChipId,
         FormatDateTime('hh:nn:ss', lAssignment.ValidFrom),
         lValidTo]));
    end;
    SmartTimingTools.ShowDialog(lLines.Text, FRaceItem.Title, [tcbOk], tcbOk);
  finally
    FreeAndNil(lLines);
    FreeAndNil(lList);
  end;
end;

{==============================================================================}
procedure TCustomRaceEngine.OnRemovePassing(ASender: TObject);
var
  lCurrentItem: TListItem;
  lListView: TListView;
  lPassingNumber: Integer;
  lPassing: TPassing;
begin
  lListView := TListView(FPassingDisplay);
  lCurrentItem := lListView.Selected;
  if lCurrentItem = nil then
    Exit;

  lPassingNumber := lCurrentItem.SubItems[cPassingItemSubItemIdxPassingNumber].ToInteger;
  lPassing := TPassingStore.GetSingleton.GetPassing(lPassingNumber);
  if lPassing.IsSystemMarker then
  begin
    SmartTimingTools.ShowDialog(cMessagesPassingIsSystemMarker, '', [tcbOk], tcbOk);
    Exit;
  end;

  if SmartTimingTools.ShowDialog(Format(cMessagesPassingDeleteConfirm,
       [lCurrentItem.SubItems[cPassingItemSubItemIdxName]]), '',
       [tcbYes, tcbNo], tcbNo) <> mrYes then
    Exit;

  GSmartTimingController.RemovePassing(lPassingNumber);
  AfterPassingCorrection;
end;

{==============================================================================}
procedure TCustomRaceEngine.OnPassingItemDragDrop(ASender, ASource: TObject; AX, AY: Integer);
var
  lDropItem, lCurrentItem, lNextItem: TListItem;
  lListView: TListView;
  lPassingNumber: Integer;
  lPassingTime: TDatetime;
  lPassing: TPassing;
  lChanged: Boolean;
begin
  if ASender <> ASource then
    Exit;

  lListView := TListView(ASender);
  lDropItem := lListView.GetItemAt(AX, AY);
  if lDropItem = nil then
    Exit;

  lChanged := False;
  lCurrentItem := lListView.Selected;
  while lCurrentItem <> nil do
  begin
    lNextItem := lListView.GetNextItem(lCurrentItem, SdAll, [IsSelected]);
    if lCurrentItem = lDropItem then
    begin
      lCurrentItem := lNextItem;
      Continue;
    end;

    lPassingNumber := lDropItem.SubItems[cPassingItemSubItemIdxPassingNumber].ToInteger;
    lPassing := TPassingStore.GetSingleton.GetPassing(lPassingNumber);
    lPassingTime := lPassing.PassingTime;
    lPassingTime := IncMilliSecond(lPassingTime, -1);

    lPassingNumber := lCurrentItem.SubItems[cPassingItemSubItemIdxPassingNumber].ToInteger;
    lPassing := TPassingStore.GetSingleton.GetPassing(lPassingNumber);
    if lPassing.IsSystemMarker then
    begin
      lCurrentItem := lNextItem;
      Continue;
    end;

    GSmartTimingController.UpdatePassing(lPassingNumber, lPassingTime,
      TPassingState(lPassing.PassingStatus));
    lChanged := True;
    lCurrentItem := lNextItem;
  end;

  if lChanged then
    AfterPassingCorrection;
end;

{==============================================================================}
procedure TCustomRaceEngine.OnPassingItemDragOver(ASender, ASource: TObject; AX, AY: Integer; AState: TDragState; var AAccept: Boolean);
begin
  AAccept := ASender = FPassingDisplay;
end;

end.
