unit uFormMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Data.SqlExpr, Data.DbxSqlite,
  Data.FMTBcd, Datasnap.DBClient, Datasnap.Provider, Vcl.Grids, Vcl.DBGrids,
  Vcl.ComCtrls, Vcl.Menus, AdvMenus, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.WinXPickers,
  MMSystem, Generics.Collections, Generics.Defaults,
  SmartTiming.DecoderEngine, SmartTIming.DecoderInterface, Vcl.Buttons,
  uPassingProtocolGrid, uFormRaceDetails, uFormSettings, uFormCompetitorDetails,
  uFormCompetitorImport, uFormPassingSimulator, uFormGenerateTransponderMappings,
  SmartTiming.Consts, SmartTiming.Database, SmartTiming.Tools, Vcl.DBCtrls,
  uDataModule, SimpleDS, uSuperObject, System.ImageList, Vcl.ImgList,
  SmartTiming.Cache, uFormBatteryCheck;

type
  TMyDBNavigator = class(TDBNavigator);

  TFormMain = class(TForm)
    PanelTitle: TPanel;
    LabelTitle: TLabel;
    LabelOrganizer: TLabel;
    LabelDate: TLabel;
    PanelMain: TPanel;
    PanelStatus: TPanel;
    PanelDecoder: TPanel;
    LabelDecoderIpAddress: TLabel;
    LabelDecoderId: TLabel;
    LabelDecoderTemperature: TLabel;
    LabelDecoderNoiseLevel: TLabel;
    MainMenu: TMainMenu;
    MenuItemTools: TMenuItem;
    MenuItemFile: TMenuItem;
    MenuItemTxMapping: TMenuItem;
    MenuItemTxMappingImport: TMenuItem;
    MenuItemTxMappingExport: TMenuItem;
    MenuItemTxMappingGenerate: TMenuItem;
    MenuItemTxMappingEdit: TMenuItem;
    MenuItemSimulatePassings: TMenuItem;
    PageControlMain: TPageControl;
    TabSheetEvent: TTabSheet;
    TabSheetTiming: TTabSheet;
    TabSheetResults: TTabSheet;
    PanelEventInfo: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label8: TLabel;
    EditOrganizer: TEdit;
    EditTitle: TEdit;
    DatePickerFrom: TDatePicker;
    DatePickerTo: TDatePicker;
    PanelRaces: TPanel;
    PanelPassings: TPanel;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    PanelStandings: TPanel;
    PanelRaceControls: TPanel;
    PanelPassingGrid: TPanel;
    PanelEventDetails: TPanel;
    PanelEventRaces: TPanel;
    Label4: TLabel;
    MenuItemLoadEvent: TMenuItem;
    ButtonSaveEvent: TButton;
    MenuItemSettings: TMenuItem;
    DBNavigatorRaces: TDBNavigator;
    DBGridRaces: TDBGrid;
    SQLDataSetRaces: TSQLDataSet;
    DataSourceRaces: TDataSource;
    DataSetProviderRaces: TDataSetProvider;
    ClientDataSetRaces: TClientDataSet;
    MenuItemCompetitors: TMenuItem;
    MenuItemImportCompetitors: TMenuItem;
    TabSheetCompetitors: TTabSheet;
    PanelCompetitorFilters: TPanel;
    ComboBoxClassFilter: TComboBox;
    Label5: TLabel;
    DBGridCompetitors: TDBGrid;
    DBNavigatorCompetitors: TDBNavigator;
    SQLDataSetCompetitors: TSQLDataSet;
    DataSetProviderCompetitors: TDataSetProvider;
    ClientDataSetCompetitors: TClientDataSet;
    DataSourceCompetitors: TDataSource;
    BitBtnClearClassFilter: TBitBtn;
    ImageListButtons: TImageList;
    PopupMenuCompetitorActions: TPopupMenu;
    PopupMenuCompetitorAssignToRace: TMenuItem;
    PopupMenuCompetitorDelete: TMenuItem;
    SQLDataSetRankings: TSQLDataSet;
    DataSetProviderRankings: TDataSetProvider;
    ClientDataSetRankings: TClientDataSet;
    DataSourceRankings: TDataSource;
    DBGridRankings: TDBGrid;
    ButtonNeutralize: TBitBtn;
    ButtonWarmUp: TBitBtn;
    ButtonStart: TBitBtn;
    ButtonFinish: TBitBtn;
    ImageListButtons32: TImageList;
    ListBoxRaces: TListBox;
    FileOpenDialog: TFileOpenDialog;
    MenuItemCheckBatteryStatus: TMenuItem;
    Startzeiteneinlesen1: TMenuItem;
    procedure DatePickerFromChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ButtonSaveEventClick(Sender: TObject);
    procedure MenuItemLoadEventClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MenuItemSettingsClick(Sender: TObject);
    procedure DBGridDrawCheckBox(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure DBNavigatorRacesBeforeAction(Sender: TObject; Button: TNavigateBtn);
    procedure MenuItemImportCompetitorsClick(Sender: TObject);
    procedure PageControlMainChange(Sender: TObject);
    procedure ClientDataSetRacesBeforeRefresh(DataSet: TDataSet);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ComboBoxClassFilterSelect(Sender: TObject);
    procedure DBNavigatorCompetitorsBeforeAction(Sender: TObject; Button: TNavigateBtn);
    procedure BitBtnClearClassFilterClick(Sender: TObject);
    procedure DBGridCompetitorsKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PopupMenuCompetitorDeleteClick(Sender: TObject);
    procedure DBGridRacesShortCellClick(Column: TColumn);
    procedure ButtonStartClick(Sender: TObject);
    procedure ButtonWarmUpClick(Sender: TObject);
    procedure ButtonNeutralizeClick(Sender: TObject);
    procedure ButtonFinishClick(Sender: TObject);
    procedure MenuItemSimulatePassingsClick(Sender: TObject);
    procedure ListBoxRacesDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ListBoxRacesClick(Sender: TObject);
    procedure MenuItemTxMappingImportClick(Sender: TObject);
    procedure MenuItemTxMappingGenerateClick(Sender: TObject);
    procedure MenuItemTxMappingExportClick(Sender: TObject);
    procedure MenuItemCheckBatteryStatusClick(Sender: TObject);

  private
    FCurrentEventId: integer;
    FEventDataObject: TEventDataObject;
    FBeepOnPassing: boolean;
    FDBCheckBoxRacesFirstPassing: TDBCheckbox;
    FFieldDescriptionsSuperObject: ISuperObject;
    FFormPassingSimulator: TFormPassingSimulator;
    FFormGenerateTransponderMappings: TFormGenerateTransponderMappings;
//    FPassingProtocolGrid: TPassingProtocolGrid;

    procedure ReadSettings;
    procedure RefreshControlsFromEventDataObject;
    procedure SetupRacesGrid;
    procedure SetupCompetitorsGrid;
    procedure SetupRankingsGrid(ARaceId: Integer);
    procedure SetColumnProperties(const ATable: string; AColumn: TColumn);
    procedure SortGridColumns(ADBGrid: TDBGrid; const ATableName: string);
    procedure RefreshRacesListBox;
    procedure FillClassFilterComboBox;
    procedure OnAssignCompetitorsToRace(ASender: TObject);
    procedure RaceButtonStatusChange(ARaceStatus: TRaceStatus);

  protected
    procedure OnGetDefaultColumnText(ASender: TField; var AText: string; ADisplayText: Boolean);
    procedure OnGetDateTimeFromValue(ASender: TField; var AText: string; ADisplayText: Boolean);
    procedure OnGetTimeFromValue(ASender: TField; var AText: string; ADisplayText: Boolean);
    procedure OnGetRaceType(ASender: TField; var AText: string; ADisplayText: Boolean);
    procedure OnGetRaceStatus(ASender: TField; var AText: string; ADisplayText: Boolean);

    procedure OnStatusReceived(AStatus: TMyLapsP3Status);
    procedure OnPassingReceived(APassing: TMyLapsP3Passing);

  public
    { Public-Deklarationen }
  end;

//  Sound Effect by <a href="https://pixabay.com/users/edr-1177074/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=music&amp;utm_content=8333">EdR</a> from <a href="https://pixabay.com//?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=music&amp;utm_content=8333">Pixabay</a>
//  Sound Effect by <a href="https://pixabay.com/users/irinairinafomicheva-25140203/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=music&amp;utm_content=13691">irinairinafomicheva</a> from <a href="https://pixabay.com//?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=music&amp;utm_content=13691">Pixabay</a>
//  Sound Effect from <a href="https://pixabay.com/?utm_source=link-attribution&amp;utm_medium=referral&amp;utm_campaign=music&amp;utm_content=86247">Pixabay</a>


var
  FormMain: TFormMain;

implementation

uses
  RaceEngine.Custom;

{$R *.dfm}

{==============================================================================}
procedure TFormMain.ClientDataSetRacesBeforeRefresh(DataSet: TDataSet);
begin
  If DataSet = nil Then
    Abort;
  If TClientDataSet(DataSet).Active = False Then
    Abort;
  If TClientDataSet(DataSet).ChangeCount > 0 Then
    TClientDataSet(DataSet).ApplyUpdates(-1);
end;

{==============================================================================}
procedure TFormMain.ComboBoxClassFilterSelect(Sender: TObject);
begin
  ClientDataSetCompetitors.Filter := 'CLASS = ' + QuotedStr(ComboBoxClassFilter.Text);
  ClientDataSetCompetitors.Filtered := true;
end;

{==============================================================================}
procedure TFormMain.BitBtnClearClassFilterClick(Sender: TObject);
begin
  ClientDataSetCompetitors.Filtered := false;
end;
{==============================================================================}
procedure TFormMain.DatePickerFromChange(Sender: TObject);
begin
  if DatePickerFrom.Date > DatePickerTo.Date then
    DatePickerTo.Date := DatePickerFrom.Date;
end;

{==============================================================================}
procedure TFormMain.DBGridCompetitorsKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Shift <> [ssCtrl]) or not (Key in [Ord('A'), Ord('a')]) then
    Exit;

  DBGridCompetitors.DataSource.DataSet.DisableControls;
  try
    DBGridCompetitors.SelectedRows.Clear;
    DBGridCompetitors.DataSource.DataSet.First;
    while not DBGridCompetitors.DataSource.DataSet.Eof do
    begin
      DBGridCompetitors.SelectedRows.CurrentRowSelected := true;
      DBGridCompetitors.DataSource.DataSet.Next;
    end;
  finally
    DBGridCompetitors.DataSource.DataSet.EnableControls;
  end;
  DBGridCompetitors.Refresh;
end;

{==============================================================================}
procedure TFormMain.DBGridDrawCheckBox(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  if (not SameText(Column.Field.FieldName, 'FIRSTPASSINGISLAP'))
     and (not SameText(Column.Field.FieldName, 'DNS'))
     and (not SameText(Column.Field.FieldName, 'DNF'))
     and (not SameText(Column.Field.FieldName, 'DSQ')) then
    Exit;

  TDBGrid(Sender).Canvas.FillRect(Rect) ;
  if VarIsNull(Column.Field.Value) then
  begin
    DrawFrameControl(TDBGrid(Sender).Canvas.Handle,Rect, DFC_BUTTON, DFCS_BUTTONCHECK or DFCS_INACTIVE); {grayed}
    Exit;
  end;

  if Column.Field.AsInteger <> 0 then
    DrawFrameControl(TDBGrid(Sender).Canvas.Handle,Rect, DFC_BUTTON, DFCS_BUTTONCHECK or DFCS_CHECKED)
  else
    DrawFrameControl(TDBGrid(Sender).Canvas.Handle,Rect, DFC_BUTTON, DFCS_BUTTONCHECK);
end;

{==============================================================================}
procedure TFormMain.DBGridRacesShortCellClick(Column: TColumn);
begin
  SetupRankingsGrid(DataSourceRaces.DataSet.FieldByName('RACEID').AsInteger);
end;

{==============================================================================}
procedure TFormMain.DBNavigatorCompetitorsBeforeAction(Sender: TObject;  Button: TNavigateBtn);
var
  lCompetitorDetailsForm: TFormCompetitorDetails;
begin
  case Button of
  nbInsert:
    DataSourceCompetitors.DataSet.Append;
  nbEdit:
    DataSourceCompetitors.DataSet.Edit;
  nbDelete:
    Exit;
  else
    Abort;
  end;

  lCompetitorDetailsForm := TFormCompetitorDetails.Create(nil, DataSourceCompetitors, FCurrentEventId, Button = nbInsert);
  try
    lCompetitorDetailsForm.ShowModal;
    Abort;
  finally
    FreeAndNil(lCompetitorDetailsForm);
  end;
end;

{==============================================================================}
procedure TFormMain.DBNavigatorRacesBeforeAction(Sender: TObject; Button: TNavigateBtn);
var
  lRaceDetailsForm: TFormRaceDetails;
begin
  case Button of
  nbInsert:
    DataSourceRaces.DataSet.Append;
  nbEdit:
    DataSourceRaces.DataSet.Edit;
  nbDelete:
    Exit;
  else
    Abort;
  end;

  lRaceDetailsForm := TFormRaceDetails.Create(nil, DataSourceRaces, FCurrentEventId, Button = nbInsert, DatePickerFrom.Date);
  try
    lRaceDetailsForm.ShowModal;
    Abort;
  finally
    FreeAndNil(lRaceDetailsForm);
  end;
end;

{==============================================================================}
procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ClientDataSetRacesBeforeRefresh(ClientDataSetRaces);
end;

{==============================================================================}
procedure TFormMain.FormCreate(Sender: TObject);
var
  lDecoderEngine: TMyLapsDecoderEngine;
begin
  lDecoderEngine := TMyLapsDecoderEngine.GetSingleton;
  lDecoderEngine.NewPassingReceived := OnPassingReceived;
  lDecoderEngine.NewStatusReceived := OnStatusReceived;

  FEventDataObject := TEventDataObject.Create;

  PageControlMain.ActivePage := TabSheetEvent;

  ReadSettings;

  MainDataModule.FillTransponderMappingCache;

//
//  FPassingProtocolGrid := TPassingProtocolGrid.CreateParented(PanelPassingGrid.Handle);
//  FPassingProtocolGrid.Initialize(1);
//  FPassingProtocolGrid.Align := alClient;
end;

{==============================================================================}
procedure TFormMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FDBCheckBoxRacesFirstPassing);
  FreeAndNil(FFormPassingSimulator);
end;

{==============================================================================}
procedure TFormMain.FormShow(Sender: TObject);
begin
  RefreshControlsFromEventDataObject;
  SetupRacesGrid;
end;

{==============================================================================}
procedure TFormMain.ListBoxRacesClick(Sender: TObject);
var
  i: integer;
  lPassingDisplay: TWinControl;
  lRaceItem: TRaceItem;
begin
  for i := 0 to ListBoxRaces.Count - 1 do
  begin
    if i = ListBoxRaces.ItemIndex then
      continue;
    lRaceItem := TRaceItem(ListBoxRaces.Items.Objects[i]);
    lRaceItem.RaceEngine.PassingDisplay.Visible := false;
    lRaceItem.RaceEngine.PassingDisplay.Align := alNone;
  end;

  if ListBoxRaces.ItemIndex < 0 then
    Exit;

  lPassingDisplay := TRaceItem(ListBoxRaces.Items.Objects[ListBoxRaces.ItemIndex]).RaceEngine.PassingDisplay;

  lPassingDisplay.Parent := PanelPassingGrid;
  lPassingDisplay.Align := alClient;
  lPassingDisplay.Visible := true;
end;

{==============================================================================}
procedure TFormMain.ListBoxRacesDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  lListBox: TListBox;
  lRaceItem: TRaceItem;
begin
  if odSelected in State then
    Exit;

  lListBox := TListBox(Control);
  lRaceItem := TRaceItem(lListBox.Items.Objects[Index]);
  if lRaceItem = nil then
    Exit;

  lListBox.Canvas.Brush.Color := SmartTimingTools.GetColorForRaceStatus(lRaceItem.Status);
  lListBox.Canvas.Font.Color := lListBox.Font.Color;
  lListBox.Canvas.FillRect(Rect);
  lListBox.Canvas.TextRect(Rect, Rect.Left + 2, Rect.Top + 2, lListBox.Items[Index]);

  if (odFocused in State) and not (odNoFocusRect in State) then
    lListBox.Canvas.DrawFocusRect(Rect);
end;

{==============================================================================}
procedure TFormMain.SetupRacesGrid;
var
  i: integer;
  lColumn: TColumn;
  lMenuItemRace: TMenuItem;
begin
  ClientDataSetRaces.Active := false;
  SQLDataSetRaces.Active := false;
  SQLDataSetRaces.CommandText := 'SELECT * FROM RACES WHERE EVENTID = ' + FCurrentEventId.ToString;
  SQLDataSetRaces.Active := true;
  ClientDataSetRaces.Active := True;
  for i := 0 to DBGridRaces.Columns.Count - 1 do
  begin
    lColumn := DBGridRaces.Columns[i];
    SetColumnProperties('RACES', lColumn);
  end;

  FreeAndNil(FDBCheckBoxRacesFirstPassing);
  FDBCheckBoxRacesFirstPassing := TDBCheckbox.Create(nil);
  FDBCheckBoxRacesFirstPassing.DataSource := DataSourceRaces;
  FDBCheckBoxRacesFirstPassing.DataField := 'FIRSTPASSINGISLAP';
  FDBCheckBoxRacesFirstPassing.Visible := False;
  FDBCheckBoxRacesFirstPassing.Color := DBGridRaces.Color;
  FDBCheckBoxRacesFirstPassing.Caption := '';

  PopupMenuCompetitorAssignToRace.Clear;
  DataSourceRaces.DataSet.First;
  while not DataSourceRaces.DataSet.Eof do
  begin
    lMenuItemRace := TMenuItem.Create(PopupMenuCompetitorAssignToRace);
    lMenuItemRace.Tag := DataSourceRaces.DataSet.FieldByName('RACEID').Value;
    lMenuItemRace.OnClick := OnAssignCompetitorsToRace;
    lMenuItemRace.Caption :=
      VarToStr(lMenuItemRace.Tag) + ' - ' + DataSourceRaces.DataSet.FieldByName('TITLE').Value;
    PopupMenuCompetitorAssignToRace.Add(lMenuItemRace);
    DataSourceRaces.DataSet.Next;
  end;
  RefreshRacesListBox;
end;

{==============================================================================}
procedure TFormMain.RefreshRacesListBox;
var
  lText: string;
  lRaceItem: TRaceItem;
  lRaceId: integer;
  i: integer;
  lVisited: TList<string>;
  lIndex: integer;
begin
  lVisited := TList<string>.Create;
  ListBoxRaces.LockDrawing;
  try
    SQLDataSetRaces.Refresh;
    DataSourceRaces.DataSet.Refresh;
    DataSourceRaces.DataSet.First;
    while not DataSourceRaces.DataSet.Eof do
    begin
      lRaceItem := nil;
      lRaceId := DataSourceRaces.DataSet.FieldByName('RACEID').Value;
      for i := ListBoxRaces.Items.Count - 1 downto 0 do
      begin
        lRaceItem := TRaceItem(ListBoxRaces.Items.Objects[i]);
        if lRaceItem = nil then
        begin
          ListBoxRaces.Items.Delete(i);
          Continue;
        end;
        if lRaceItem.Id = lRaceId then
          break;
        lRaceItem := nil;
      end;

      lText :=
        FormatDatetime('hh:mm', DataSourceRaces.DataSet.FieldByName('STARTTIME').Value)
        + ' - ' + DataSourceRaces.DataSet.FieldByName('TITLE').Value;

      if lRaceItem = nil then
      begin
        lRaceItem := TRaceItem.Create;
        ListBoxRaces.AddItem(lText, lRaceItem);
      end;
      SmartTimingTools.FillRaceItemFromDataSet(PanelPassingGrid, DataSourceRaces.DataSet, lRaceItem);
      lVisited.Add(lRaceItem.Id.ToString);
      DataSourceRaces.DataSet.Next;
    end;

    for i := ListBoxRaces.Items.Count - 1 downto 0 do
    begin
      lRaceItem := TRaceItem(ListBoxRaces.Items.Objects[i]);
      if lRaceItem = nil then
      begin
        ListBoxRaces.Items.Delete(i);
        Continue;
      end;
      if lVisited.IndexOf(lRaceItem.Id.ToString) >= 0 then
        Continue;
      ListBoxRaces.Items.Delete(i);
    end;

    // TODO Sorting

    ListBoxRaces.Invalidate;

  finally
    ListBoxRaces.UnlockDrawing;
    FreeAndNil(lVisited);
  end;
  Application.ProcessMessages;

  lIndex := ListBoxRaces.ItemIndex;
  ListBoxRaces.ItemIndex := -1;
  Application.ProcessMessages;
  ListBoxRaces.ItemIndex := lIndex;
end;

{==============================================================================}
procedure TFormMain.SetupCompetitorsGrid;
var
  i: integer;
  lColumn: TColumn;
begin
  ClientDataSetCompetitors.Active := false;
  SQLDataSetCompetitors.Active := false;
  SQLDataSetCompetitors.CommandText := 'SELECT * FROM COMPETITORS ORDER BY CLASS, BIB';
  SQLDataSetCompetitors.Active := true;
  ClientDataSetCompetitors.Active := True;
  for i := 0 to DBGridCompetitors.Columns.Count - 1 do
  begin
    lColumn := DBGridCompetitors.Columns[i];
    SetColumnProperties('COMPETITORS', lColumn);
  end;

  FillClassFilterComboBox;
end;

{==============================================================================}
procedure TFormMain.SetupRankingsGrid(ARaceId: Integer);
var
  i: integer;
  lColumn: TColumn;
begin
  ClientDataSetRankings.Active := false;
  SQLDataSetRankings.Active := false;
  SQLDataSetRankings.CommandText :=
    'SELECT P.*, C.* FROM PARTICIPATION P INNER JOIN COMPETITORS C ON P.COMPETITORID = C.COMPETITORID ' +
    'WHERE RACEID = ' + ARaceId.ToString;
  SQLDataSetRankings.Active := true;
  ClientDataSetRankings.Active := True;
  for i := 0 to DBGridRankings.Columns.Count - 1 do
  begin
    lColumn := DBGridRankings.Columns[i];
    SetColumnProperties('RANKING', lColumn);
  end;
  SortGridColumns(DBGridRankings, 'RANKING');
end;


{==============================================================================}
procedure TFormMain.SortGridColumns(ADBGrid: TDBGrid; const ATableName: string);
var
  lTables: TSuperArray;
  lColumns: TSuperArray;
  i: integer;
  j: integer;
  k: integer;
  lGridColumn: TColumn;
begin
  lTables := FFieldDescriptionsSuperObject.A['tables'];
  if lTables = nil then
    Exit;

  for i := 0 to lTables.Length - 1 do
  begin
    if lTables.O[i].S['tablename'] <> ATableName then
      Continue;

    lColumns := lTables.O[i].A['columns'];
    if lColumns = nil then
      Exit;

    for j := ADBGrid.Columns.Count - 1 downto 0 do
    begin
      lGridColumn := ADBGrid.Columns[j];
      for k := 0 to lColumns.Length - 1 do
      begin
        if SameText(lColumns.O[k].S['columnname'], lGridColumn.FieldName) then
        begin
          lGridColumn.Index := lColumns.O[k].I['position'];
          break;
        end;
      end;
    end;
  end;
end;

{==============================================================================}
procedure TFormMain.ReadSettings;
var
  lJSON: TStringList;
begin
  FBeepOnPassing := SmartTimingTools.RegistryReadBool(HKEY_CURRENT_USER, cRegKeyPath + '\Settings', 'BeepOnPassing', false);

  lJSON := TStringList.Create;
  try
    lJSON.LoadFromFile(cStdDataPath + '\TableColumnDescriptions.json');
    FFieldDescriptionsSuperObject := TSuperObject.ParseString(PChar(lJSON.Text), false);
  finally
    FreeAndNil(lJSON);
  end;
end;

{==============================================================================}
procedure TFormMain.RefreshControlsFromEventDataObject;
begin
  FEventDataObject.EventId := 0;   // TODO Dynamic eventid
  FEventDataObject.RefreshFromDatabase;
  FCurrentEventId := FEventDataObject.EventId;
  EditOrganizer.Text := FEventDataObject.Organizer;
  EditTitle.Text := FEventDataObject.Title;
  DatePickerFrom.Date := FEventDataObject.DateFrom;
  DatePickerTo.Date := FEventDataObject.DateTo;

  LabelOrganizer.Caption := FEventDataObject.Organizer;
  LabelTitle.Caption := FEventDataObject.Title;
  LabelDate.Caption := DateTimeToStr(FEventDataObject.DateFrom);
  if FEventDataObject.DateFrom < FEventDataObject.DateTo then
    LabelDate.Caption := LabelDate.Caption + ' - ' + DateTimeToStr(DatePickerTo.Date);
end;

{==============================================================================}
procedure TFormMain.MenuItemCheckBatteryStatusClick(Sender: TObject);
var
  lFormBatteryCheck: TFormBatteryCheck;
begin
  lFormBatteryCheck := TFormBatteryCheck.Create(nil);
  try
    lFormBatteryCheck.ShowModal;
  finally
    FreeAndNil(lFormBatteryCheck);
  end;
end;

{==============================================================================}
procedure TFormMain.MenuItemImportCompetitorsClick(Sender: TObject);
var
  lFormCompetitorImport: TFormCompetitorImport;
begin
  lFormCompetitorImport := TFormCompetitorImport.Create(nil);
  try
    lFormCompetitorImport.ShowModal;
  finally
    FreeAndNil(lFormCompetitorImport);
  end;
end;

{==============================================================================}
procedure TFormMain.MenuItemLoadEventClick(Sender: TObject);
begin
  ShowMessage('Not implemented yet.');
end;

{==============================================================================}
procedure TFormMain.MenuItemSettingsClick(Sender: TObject);
var
  lFormSettings: TFormSettings;
begin
  lFormSettings := TFormSettings.Create(nil);
  try
    if lFormSettings.ShowModal = mrOK then
      ReadSettings;
  finally
    FreeAndNil(lFormSettings);
  end;
end;

{==============================================================================}
procedure TFormMain.MenuItemSimulatePassingsClick(Sender: TObject);
begin
  FreeAndNil(FFormPassingSimulator);
  FFormPassingSimulator := TFormPassingSimulator.Create(self);
  FFormPassingSimulator.Show;
end;

{==============================================================================}
procedure TFormMain.MenuItemTxMappingExportClick(Sender: TObject);
begin
  FileOpenDialog.DefaultExtension := 'txt';
  if not FileOpenDialog.Execute then
    Exit;
  MainDataModule.ExportTxMapping(FileOpenDialog.FileName);
end;

{==============================================================================}
procedure TFormMain.MenuItemTxMappingGenerateClick(Sender: TObject);
begin
  FreeAndNil(FFormGenerateTransponderMappings);
  FFormGenerateTransponderMappings := TFormGenerateTransponderMappings.Create(self);
  if (FFormPassingSimulator <> nil) and FFormPassingSimulator.Showing then
    FFormGenerateTransponderMappings.Show
  else
    FFormGenerateTransponderMappings.ShowModal;
end;

{==============================================================================}
procedure TFormMain.MenuItemTxMappingImportClick(Sender: TObject);
begin
  FileOpenDialog.DefaultExtension := 'txt';
  if not FileOpenDialog.Execute then
    Exit;
  MainDataModule.ImportTxMapping(FileOpenDialog.FileName);
end;

{==============================================================================}
procedure TFormMain.ButtonSaveEventClick(Sender: TObject);
begin
  FEventDataObject.Organizer := EditOrganizer.Text;
  FEventDataObject.Title := EditTitle.Text;
  FEventDataObject.DateFrom := DatePickerFrom.Date;
  FEventDataObject.DateTo := DatePickerTo.Date;
  FEventDataObject.SaveToDatabase;
  RefreshControlsFromEventDataObject;
end;

{==============================================================================}
procedure TFormMain.ButtonWarmUpClick(Sender: TObject);
begin
  RaceButtonStatusChange(rsWarmUp);
  RefreshRacesListBox;
end;

{==============================================================================}
procedure TFormMain.ButtonStartClick(Sender: TObject);
begin
  RaceButtonStatusChange(rsStarted);
end;

{==============================================================================}
procedure TFormMain.ButtonNeutralizeClick(Sender: TObject);
begin
  RaceButtonStatusChange(rsNeutralized);
end;

{==============================================================================}
procedure TFormMain.ButtonFinishClick(Sender: TObject);
begin
  RaceButtonStatusChange(rsFinished);
end;

{==============================================================================}
procedure TFormMain.RaceButtonStatusChange(ARaceStatus: TRaceStatus);
begin
  DataSourceRaces.DataSet.RecNo := ListBoxRaces.ItemIndex + 1;
  MainDataModule.SetRaceStatus(DataSourceRaces.DataSet.FieldByName('RACEID').AsInteger, ARaceStatus);
  RefreshRacesListBox;
end;
{==============================================================================}
procedure TFormMain.OnGetDateTimeFromValue(ASender: TField; var AText: string; ADisplayText: Boolean);
begin
  AText := DateTimeToStr(ASender.AsFloat);
end;

{==============================================================================}
procedure TFormMain.OnGetTimeFromValue(ASender: TField; var AText: string; ADisplayText: Boolean);
begin
  if ASender.IsNull then
    AText := ''
  else
    AText := TimeToStr(ASender.AsFloat);
end;

{==============================================================================}
procedure TFormMain.OnGetDefaultColumnText(ASender: TField; var AText: string; ADisplayText: Boolean);
begin
  AText := ASender.AsString;
end;

{==============================================================================}
procedure TFormMain.OnGetRaceType(ASender: TField; var AText: string; ADisplayText: Boolean);
begin
  AText := SmartTimingTools.GetRaceTypeStringFromEnum(TRaceType(ASender.AsInteger));
end;

{==============================================================================}
procedure TFormMain.OnGetRaceStatus(ASender: TField; var AText: string; ADisplayText: Boolean);
begin
  AText := SmartTimingTools.GetRaceStatusStringFromEnum(TRaceStatus(ASender.AsInteger));
end;

{==============================================================================}
procedure TFormMain.OnStatusReceived(AStatus: TMyLapsP3Status);
begin
  LabelDecoderNoiseLevel.Caption := 'Störungslevel: ' + AStatus.Noise.ToString;
  LabelDecoderTemperature.Caption := 'Temperatur: ' + AStatus.Temperature.ToString;
end;

{==============================================================================}
procedure TFormMain.PageControlMainChange(Sender: TObject);
begin
  if PageControlMain.ActivePage = TabSheetCompetitors then
    SetupCompetitorsGrid;
end;

{==============================================================================}
procedure TFormMain.PopupMenuCompetitorDeleteClick(Sender: TObject);
begin
   // TODO
end;

{==============================================================================}
procedure TFormMain.OnPassingReceived(APassing: TMyLapsP3Passing);
var
  lRaceId: integer;
  i: integer;
  lRaceItem: TRaceItem;
begin
  PlaySound('PassingBeep', 0, SND_NOSTOP or SND_NOWAIT or SND_RESOURCE or SND_ASYNC or SND_NODEFAULT);
  lRaceId := MainDataModule.GetRaceIdForPassing(APassing);
  if lRaceId < 0 then
    Exit;

  MainDataModule.AddPassingToDatabase(APassing);

  for i := 0 to ListBoxRaces.Count - 1 do
  begin
    lRaceItem := TRaceItem(ListBoxRaces.Items.Objects[i]);
    if lRaceItem.Id = lRaceId then
    begin
      lRaceItem.RaceEngine.AddPassingToDisplay(APassing);
      break;
    end;
  end;
end;

{==============================================================================}
procedure TFormMain.SetColumnProperties(const ATable: string; AColumn: TColumn);
  function GetAlignmentFromString(const AString: string): TAlignment;
  begin
    if SameText(AString, 'taLeftJustify') then
      Exit(taLeftJustify);
    if SameText(AString, 'taRightJustify') then
      Exit(taRightJustify);
    if SameText(AString, 'taCenter') then
      Exit(taCenter);
    result := taRightJustify;
  end;

  function GetFieldTypeFromString(const AString: string): TFieldType;
  begin
    if SameText(AString, 'ftString') then
      Exit(ftString);
    Exit(ftUnknown);
  end;

var
  lTables: TSuperArray;
  i: integer;
  lColumns: TSuperArray;
  j: integer;
  lColumn: ISuperObject;
  lFieldType: TFieldType;
  lMethodName: string;
begin
  if AColumn.Field.DataType = ftWideMemo then
    AColumn.Field.OnGetText := OnGetDefaultColumnText;
  lTables := FFieldDescriptionsSuperObject.A['tables'];
  for i := 0 to lTables.Length - 1 do
  begin
    if lTables.O[i].S['tablename'] <> ATable then
      Continue;

    lColumns := lTables.O[i].A['columns'];
    for j := 0 to lColumns.Length - 1 do
    begin
      if lColumns.O[j].S['columnname'] <> AColumn.FieldName then
        Continue;

      lColumn := lColumns.O[j];
      AColumn.Visible := not lColumn.B['invisible'];
      AColumn.Title.Caption := lColumn.S['caption'];
      if Length(AColumn.Title.Caption) = 0 then
        AColumn.Title.Caption := AColumn.FieldName;
      AColumn.Width := lColumn.I['width'];
      AColumn.Alignment := GetAlignmentFromString(lColumn.S['align']);
      lFieldType := GetFieldTypeFromString('fieldtype');
      if lFieldType <> ftUnknown then
        AColumn.Field.SetFieldType(lFieldType);

      lMethodName := lColumn.S['ongettext'];
      if not lMethodName.IsEmpty then
      begin
        if SameText(lMethodName, 'OnGetDateTimeFromValue') then
          AColumn.Field.OnGetText := OnGetDateTimeFromValue
        else if SameText(lMethodName, 'OnGetTimeFromValue') then
          AColumn.Field.OnGetText := OnGetTimeFromValue
        else if SameText(lMethodName, 'OnGetRaceStatus') then
          AColumn.Field.OnGetText := OnGetRaceStatus;
      end;
    end;
  end;
end;

{==============================================================================}
procedure TFormMain.FillClassFilterComboBox;
var
  lValue: string;
begin
  ComboBoxClassFilter.Items.Clear;
  SQLDataSetCompetitors.First;
  while not SQLDataSetCompetitors.Eof do
  begin
    lValue := SQLDataSetCompetitors.FieldByName('CLASS').AsString;
    if ComboBoxClassFilter.Items.IndexOf(lValue) < 0 then
      ComboBoxClassFilter.Items.Add(lValue);
    SQLDataSetCompetitors.Next;
  end;
end;

{==============================================================================}
procedure TFormMain.OnAssignCompetitorsToRace(ASender: TObject);
var
  lMenuItem: TMenuItem;
  lRaceId: Integer;
  lCompetitorIds: TArray<Integer>;
begin
  if not (ASender is TMenuItem) then
    Exit;

  lMenuItem := TMenuItem(ASender);
  lRaceId := lMenuItem.Tag;

  DBGridCompetitors.DataSource.DataSet.First;
  while not DBGridCompetitors.DataSource.DataSet.Eof do
  begin
    if DBGridCompetitors.SelectedRows.CurrentRowSelected then
    begin
      SetLength(lCompetitorIds, Length(lCompetitorIds) + 1);
      lCompetitorIds[High(lCompetitorIds)] := DBGridCompetitors.DataSource.DataSet.FieldByName('COMPETITORID').Value;
    end;
    DBGridCompetitors.DataSource.DataSet.Next;
  end;
  MainDataModule.AssignCompetitorsToRace(FCurrentEventId, lRaceId, lCompetitorIds);
end;

end.
