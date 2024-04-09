unit FormMain;

interface

uses
  SmartTiming.Tools,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Data.SqlExpr, Data.DbxSqlite,
  Data.FMTBcd, Datasnap.DBClient, Datasnap.Provider, Vcl.Grids, Vcl.DBGrids,
  Vcl.ComCtrls, Vcl.Menus, AdvMenus, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.WinXPickers,
  SQLite, Math, UITypes,
  MMSystem, Generics.Collections, Generics.Defaults,
  DecoderInterface, SmartTiming.DecoderEngine, Vcl.Buttons,
  FormRaceDetails, FormSettings, FormCompetitorDetails,
  FormCompetitorImport, FormPassingSimulator, FormGenerateTransponderMappings,
  SmartTiming.Consts, Vcl.DBCtrls,
  DataModule, SimpleDS, uSuperObject, System.ImageList, Vcl.ImgList,
  SmartTiming.Cache, FormBatteryCheck, RaceEngine.Custom, Vcl.Mask,
  VclTee.TeeGDIPlus, VCLTee.TeEngine, VCLTee.Series, VCLTee.TeeProcs,
  VCLTee.Chart, SmartTiming.Event, SmartTiming.GridFormatProvider,
  FormAddPassing, Vcl.WinXPanels;

type
  TFormMain = class(TForm)
    PanelTitle: TPanel;
    LabelTitle: TLabel;
    LabelOrganizer: TLabel;
    LabelDate: TLabel;
    PanelMain: TPanel;
    PanelStatus: TPanel;
    PanelDecoder: TPanel;
    LabelDecoderIpAddress: TLabel;
    LabelDecoderManufacturer: TLabel;
    MainMenu: TMainMenu;
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
    PanelRaces: TPanel;
    PanelPassings: TPanel;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    PanelStandings: TPanel;
    PanelRaceControls: TPanel;
    PanelEventDetails: TPanel;
    PanelEventRaces: TPanel;
    Label4: TLabel;
    ButtonSaveEvent: TButton;
    DBGridRaces: TDBGrid;
    TabSheetCompetitors: TTabSheet;
    PanelCompetitorFilters: TPanel;
    ComboBoxClassFilter: TComboBox;
    Label5: TLabel;
    ListBoxRaces: TListBox;
    DBGridCompetitors: TDBGrid;
    DBNavigatorCompetitors: TDBNavigator;
    BitBtnClearClassFilter: TBitBtn;
    ButtonNeutralize: TBitBtn;
    ButtonWarmUp: TBitBtn;
    ButtonStart: TBitBtn;
    ButtonAbort: TBitBtn;
    ButtonFinish: TBitBtn;
    ButtonStop: TBitBtn;
    MenuItemTools: TMenuItem;
    MenuItemFile: TMenuItem;
    MenuItemTxMapping: TMenuItem;
    MenuItemTxMappingImport: TMenuItem;
    MenuItemTxMappingExport: TMenuItem;
    MenuItemTxMappingGenerate: TMenuItem;
    MenuItemTxMappingEdit: TMenuItem;
    MenuItemSimulatePassings: TMenuItem;
    MenuItemLoadEvent: TMenuItem;
    MenuItemSettings: TMenuItem;
    MenuItemCompetitors: TMenuItem;
    MenuItemImportCompetitors: TMenuItem;
    SQLDataSetCompetitors: TSQLDataSet;
    DataSetProviderCompetitors: TDataSetProvider;
    ClientDataSetCompetitors: TClientDataSet;
    DataSourceCompetitors: TDataSource;
    ImageListButtons: TImageList;
    PopupMenuCompetitorActions: TPopupMenu;
    PopupMenuCompetitorAssignToRace: TMenuItem;
    PopupMenuCompetitorDelete: TMenuItem;
    ImageListButtons32: TImageList;
    FileOpenDialog: TFileOpenDialog;
    MenuItemCheckBatteryStatus: TMenuItem;
    Startzeiteneinlesen1: TMenuItem;
    MenuItemBackup: TMenuItem;
    EditDateFrom: TMaskEdit;
    EditDateTo: TMaskEdit;
    CheckBoxAutoScrollPassings: TCheckBox;
    PanelNoiseChart: TPanel;
    Splitter4: TSplitter;
    PanelTemperatureChart: TPanel;
    LabelDecoderNoiseLevel: TLabel;
    LabelDecoderTemperature: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    MenuItemReports: TMenuItem;
    PanelResultRaces: TPanel;
    PanelResults: TPanel;
    PanelResultControls: TPanel;
    ButtonExportToExelTemplate: TButton;
    ButtonResultExportCSV: TButton;
    ButtonResultExportHTML: TButton;
    PanelResultGrid: TPanel;
    ButtonImportCompetitors: TButton;
    PopupMenuCompetitorRemoveFromRace: TMenuItem;
    ButtonPrintParticipantList: TButton;
    DBNavigatorRaces: TDBNavigator;
    PanelRacesGridButtons: TPanel;
    PanelCompetitorsGridButtons: TPanel;
    PanelStandingsControls: TPanel;
    CheckBoxRankingGroupedByClass: TCheckBox;
    CheckBoxResultsGroupByClass: TCheckBox;
    ButtonPrintResults: TButton;
    LabelDecoderId: TLabel;
    CardPanelPassings: TCardPanel;
    ImageListPassingStates: TImageList;

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
    procedure ButtonAbortClick(Sender: TObject);
    procedure ButtonFinishClick(Sender: TObject);
    procedure ButtonStopClick(Sender: TObject);
    procedure MenuItemSimulatePassingsClick(Sender: TObject);
    procedure ListBoxRacesDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure ListBoxRacesTimingClick(Sender: TObject);
    procedure ListBoxRacesResultClick(Sender: TObject);
    procedure MenuItemTxMappingImportClick(Sender: TObject);
    procedure MenuItemTxMappingGenerateClick(Sender: TObject);
    procedure MenuItemTxMappingExportClick(Sender: TObject);
    procedure MenuItemCheckBatteryStatusClick(Sender: TObject);
    procedure MenuItemBackupClick(Sender: TObject);
    procedure ToggleAutoScrollClick(Sender: TObject);
    procedure LabelDecoderManufacturerClick(Sender: TObject);
    procedure MenuItemReportsClick(Sender: TObject);
    procedure PopupMenuCompetitorActionsPopup(Sender: TObject);
    procedure ButtonPrintParticipantListClick(Sender: TObject);
    procedure DBGridCompetitorsDblClick(Sender: TObject);
    procedure ClientDataSetCompetitorsAfterOpen(DataSet: TDataSet);
    procedure PanelCompetitorsGridButtonsClick(Sender: TObject);
    procedure CheckBoxRankingGroupedByClassClick(Sender: TObject);
    procedure ButtonExportToExelTemplateClick(Sender: TObject);
    procedure ButtonPrintResultsClick(Sender: TObject);
    procedure PopupMenuCompetitorAssignToRaceClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure StackPanel1Click(Sender: TObject);

  private
    FCurrentEventId: integer;
    FDBCheckBoxRacesFirstPassing: TDBCheckbox;
    FFormPassingSimulator: TFormPassingSimulator;
    FFormGenerateTransponderMappings: TFormGenerateTransponderMappings;
    FFormManuallyAddPassing: TFormManuallyAddPassing;

    FAutoScrollPassingList: boolean;

    procedure ReadSettings;
    procedure SetupRacesGrid;
    procedure SetupCompetitorsGrid;
    procedure SetupRankingsGrid(ARaceId: Integer);
    procedure RefreshRacesListBox;
    procedure FillClassFilterComboBox;
    procedure OnAssignCompetitorsToRace(ASender: TObject);
    procedure OnRemoveCompetitorsFromRace(ASender: TObject);
    procedure RaceButtonStatusChange(ARaceStatus: TRaceStatus);
    procedure RefreshFlagButtonsVisibility(ARaceItem: TRaceItem);
    procedure RefreshAddCompetitorToRaceMenu;
    procedure EnableResultPanelControls(AEnable: boolean);

  protected
    procedure OnGetRaceType(ASender: TField; var AText: string; ADisplayText: Boolean);

  public
    procedure AddDecoderStatus(ADecoderStatus: TDecoderStatus);
    procedure AddPassingForRaceId(ARaceId: integer; APassing: TPassing);
    procedure DecoderConnected(ADecoder: TDecoder);
    function GetAllRaceIds: TArray<integer>;
    procedure RefreshControlsFromEventDataObject(AEvent: TEventDataObject);
    function GetNewPanelForPassings(ARaceId: Integer): TWinControl;
    procedure RefreshFlagButtonsActive(ARaceStatus: TRaceStatus);
  end;


var
  GFormMain: TFormMain;

implementation

uses
  SmartTiming.Controller, Report.ExcelTemplateFiller;

{$R *.dfm}

{==============================================================================}
procedure TFormMain.CheckBoxRankingGroupedByClassClick(Sender: TObject);
var
  lRaceItem: TRaceItem;
begin
  lRaceItem := TRaceItem(ListBoxRaces.Items.Objects[ListBoxRaces.ItemIndex]);
  if lRaceItem = nil then
    Exit;
  lRaceItem.RaceEngine.RankingGroupedByClass := TCheckBox(Sender).Checked;
end;

{==============================================================================}
procedure TFormMain.ClientDataSetCompetitorsAfterOpen(DataSet: TDataSet);
var
  lField: TField;
begin
  lField := DataSet.FieldByName('COMPETITORID');
  if lField = nil then
    Exit;
  lField.ProviderFlags := [pfInKey];
end;

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
var
  lDateFrom: TDate;
  lDateTo: TDate;
begin
  lDateFrom := StrToDate(EditDateFrom.Text);
  lDateTo := StrToDate(EditDateTo.Text);

  if lDateFrom > lDateTo then
    EditDateTo.Text := DateToStr(lDateFrom);
end;

{==============================================================================}
procedure TFormMain.DBGridCompetitorsDblClick(Sender: TObject);
var
 lCompetitorDetailsForm: TFormCompetitorDetails;
begin
  DataSourceCompetitors.DataSet.Edit;

  lCompetitorDetailsForm := TFormCompetitorDetails.Create(nil, DataSourceCompetitors, FCurrentEventId, false);
  try
    if lCompetitorDetailsForm.ShowModal <> mrOK then
      Abort;
  finally
    FreeAndNil(lCompetitorDetailsForm);
  end;
end;

{==============================================================================}
procedure TFormMain.DBGridCompetitorsKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = vkDelete then
  begin
    DBNavigatorCompetitorsBeforeAction(DBNavigatorCompetitors, nbDelete);
    Exit;
  end;
  if not ((Shift = [ssCtrl]) and (Key in [Ord('A'), Ord('a')])) then
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
  SetupRankingsGrid(MainDataModule.DataSourceRaces.DataSet.FieldByName('RACEID').AsInteger);
end;

{==============================================================================}
procedure TFormMain.DBNavigatorCompetitorsBeforeAction(Sender: TObject;  Button: TNavigateBtn);
var
  lCompetitorDetailsForm: TFormCompetitorDetails;
  i: integer;
  lCompetitorIDs: TArray<Integer>;
  lCurrentRecord: Integer;
begin
  case Button of
  nbInsert:
    DataSourceCompetitors.DataSet.Append;
  nbEdit:
    DataSourceCompetitors.DataSet.Edit;
  nbDelete:
    begin
      if SmartTimingTools.ShowDialog(Format(cMessagesComptitorDeleteConfirm, [DBGridCompetitors.SelectedRows.Count]), '', [tcbYes,tcbNo], tcbNo) <> mrYes then
        Exit;
      SetLength(lCompetitorIDs, DBGridCompetitors.SelectedRows.Count);
      i := 0;
      lCurrentRecord := DBGridCompetitors.SelectedIndex;
      DBGridCompetitors.DataSource.DataSet.First;
      while not DBGridCompetitors.DataSource.DataSet.Eof do
      begin
        if DBGridCompetitors.SelectedRows.CurrentRowSelected then
        begin
          lCompetitorIDs[i] := DBGridCompetitors.DataSource.DataSet.FieldByName('COMPETITORID').AsInteger;
          Inc(i);
        end;
        DBGridCompetitors.DataSource.DataSet.Next;
      end;
      MainDataModule.RemoveCompetitors(FCurrentEventId, lCompetitorIDs);
      DBGridCompetitors.SelectedRows.Clear;
      DataSourceCompetitors.DataSet.Refresh;
      DBGridCompetitors.SelectedIndex := Min(lCurrentRecord, DBGridCompetitors.DataSource.DataSet.RecordCount);
      Exit;
    end
  else
    Abort;
  end;

  lCompetitorDetailsForm := TFormCompetitorDetails.Create(nil, DataSourceCompetitors, FCurrentEventId, Button = nbInsert);
  try
    if lCompetitorDetailsForm.ShowModal <> mrOK then;
      Abort;
  finally
    FreeAndNil(lCompetitorDetailsForm);
  end;
end;

{==============================================================================}
procedure TFormMain.RefreshAddCompetitorToRaceMenu;
var
  lMenuItemRace: TMenuItem;
  lRaceId: Integer;
  lMenuCaption: string;
begin
  PopupMenuCompetitorAssignToRace.Clear;
  PopupMenuCompetitorRemoveFromRace.Clear;

  MainDataModule.DataSourceRaces.DataSet.First;
  while not MainDataModule.DataSourceRaces.DataSet.Eof do
  begin
    lRaceId := MainDataModule.DataSourceRaces.DataSet.FieldByName('RACEID').Value;
    lMenuCaption := VarToStr(lRaceId) + ' - ' + MainDataModule.DataSourceRaces.DataSet.FieldByName('TITLE').Value;

    lMenuItemRace := TMenuItem.Create(PopupMenuCompetitorAssignToRace);
    lMenuItemRace.Tag := lRaceId;
    lMenuItemRace.OnClick := OnAssignCompetitorsToRace;
    lMenuItemRace.Caption := lMenuCaption;
    PopupMenuCompetitorAssignToRace.Add(lMenuItemRace);

    lMenuItemRace := TMenuItem.Create(PopupMenuCompetitorRemoveFromRace);
    lMenuItemRace.Tag := lRaceId;
    lMenuItemRace.OnClick := OnRemoveCompetitorsFromRace;
    lMenuItemRace.Caption := lMenuCaption;
    PopupMenuCompetitorRemoveFromRace.Add(lMenuItemRace);

    MainDataModule.DataSourceRaces.DataSet.Next;
  end;
end;

{==============================================================================}
procedure TFormMain.DBNavigatorRacesBeforeAction(Sender: TObject; Button: TNavigateBtn);

  procedure ShowRaceDetailsForm;
  var
    lRaceDetailsForm: TFormRaceDetails;
  begin
    lRaceDetailsForm := TFormRaceDetails.Create(nil, MainDataModule.DataSourceRaces, FCurrentEventId, Button = nbInsert, StrToDate(EditDateFrom.Text));
    try
      lRaceDetailsForm.ShowModal;
      Abort;
    finally
      FreeAndNil(lRaceDetailsForm);
    end;
  end;

begin
  case Button of
  nbInsert:
    begin
      MainDataModule.DataSourceRaces.DataSet.Append;
      ShowRaceDetailsForm;
    end;
  nbEdit:
    begin
      MainDataModule.DataSourceRaces.DataSet.Edit;
      ShowRaceDetailsForm;
    end;
  nbDelete:
    ;
  else
    begin
      Abort;
      Exit;
    end;
  end;
end;

{==============================================================================}
procedure TFormMain.FormCreate(Sender: TObject);
begin
  PageControlMain.ActivePage := TabSheetEvent;

  ReadSettings;

  if not MainDataModule.FillTransponderMappingCache then
  begin
    if SmartTimingTools.ShowDialog(cMessagesNoTxMapping, '', [tcbYes, tcbNo]) = mrYes then
      MenuItemTxMappingImportClick(nil);
  end;

  EditDateFrom.Text := DateToStr(Now);
  EditDateTo.Text := DateToStr(Now);

  FAutoScrollPassingList := true;
end;

{==============================================================================}
procedure TFormMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FFormManuallyAddPassing);
  FreeAndNil(FDBCheckBoxRacesFirstPassing);
  FreeAndNil(FFormPassingSimulator);
  FreeAndNil(GSmartTimingController);
end;

{==============================================================================}
procedure TFormMain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
  VK_F4:
    ButtonWarmUpClick(nil);
  VK_F5:
    ButtonStartClick(nil);
  VK_F6:
    ButtonNeutralizeClick(nil);
  VK_F7:
    ButtonAbortClick(nil);
  VK_F8:
    ButtonFinishClick(nil);
  VK_F10:
    begin
      if FFormManuallyAddPassing = nil then
        FFormManuallyAddPassing := TFormManuallyAddPassing.Create(self);
      FFormManuallyAddPassing.Show;
       Winapi.Windows.SetFocus(FFormManuallyAddPassing.EditBIB.Handle);
    end;
  end;
end;

{==============================================================================}
procedure TFormMain.FormShow(Sender: TObject);
begin
  SetupRacesGrid;
end;

{==============================================================================}
procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  TGridFormatProvider.SaveSettings(DBGridCompetitors);
  TGridFormatProvider.SaveSettings(DBGridRaces);
  ClientDataSetRacesBeforeRefresh(MainDataModule.ClientDataSetRaces);
  MainDataModule.WriteEventHistory;
end;

{==============================================================================}
procedure TFormMain.LabelDecoderManufacturerClick(Sender: TObject);
begin
  TDecoderEngine.GetSingleton.RefreshDecoderList;
end;

{==============================================================================}
procedure TFormMain.ListBoxRacesTimingClick(Sender: TObject);
var
  i: integer;
  lRaceItem: TRaceItem;
  lRankingGrid: TDBGrid;
begin
  for i := 0 to ListBoxRaces.Count - 1 do
  begin
    if i = ListBoxRaces.ItemIndex then
      continue;
    lRaceItem := TRaceItem(ListBoxRaces.Items.Objects[i]);

    lRankingGrid := TDBGrid(lRaceItem.RaceEngine.RankingDisplay);
    lRaceItem.RaceEngine.RefreshRankingDisplay;
    lRankingGrid.Visible := false;
    lRankingGrid.Align := alNone;
  end;

  if ListBoxRaces.ItemIndex < 0 then
    Exit;

  lRaceItem := TRaceItem(ListBoxRaces.Items.Objects[ListBoxRaces.ItemIndex]);

  RefreshFlagButtonsVisibility(lRaceItem);

  for i := 0 to CardPanelPassings.CardCount - 1 do
  begin
    if CardPanelPassings.Cards[i].Tag = lRaceItem.Id then
    begin
      CardPanelPassings.ActiveCardIndex := i;
      break;
    end;
  end;

  lRankingGrid := TDBGrid(lRaceItem.RaceEngine.RankingDisplay);
  lRaceItem.RaceEngine.RefreshRankingDisplay;
  lRankingGrid.Parent := PanelStandings;
  lRankingGrid.Align := alClient;
  lRankingGrid.Visible := true;
end;

{==============================================================================}
function TFormMain.GetNewPanelForPassings(ARaceId: Integer): TWinControl;
var
  lCard: TCard;
begin
  lCard := CardPanelPassings.CreateNewCard;
  lCard.Tag := ARaceId;
  Exit(lCard);
end;

{==============================================================================}
procedure TFormMain.EnableResultPanelControls(AEnable: boolean);
begin
  ButtonPrintResults.Enabled := AEnable;
  ButtonResultExportCSV.Enabled := false; // TODO
  ButtonResultExportHTML.Enabled := false; // TODO
  ButtonExportToExelTemplate.Enabled := AEnable;
  CheckBoxResultsGroupByClass.Enabled := AEnable;
end;

{==============================================================================}
procedure TFormMain.ListBoxRacesResultClick(Sender: TObject);
var
  lRaceItem: TRaceItem;
  lRankingGrid: TDBGrid;
begin
  EnableResultPanelControls(ListBoxRaces.ItemIndex >= 0);

  if ListBoxRaces.ItemIndex < 0 then
    Exit;

  lRaceItem := TRaceItem(ListBoxRaces.Items.Objects[ListBoxRaces.ItemIndex]);

  PanelResultGrid.Caption := '';

  lRankingGrid := TDBGrid(lRaceItem.RaceEngine.RankingDisplay);
  lRaceItem.RaceEngine.RefreshRankingDisplay;
  lRankingGrid.Parent := PanelResultGrid;
  lRankingGrid.Align := alClient;
  lRankingGrid.Visible := true;
end;

{==============================================================================}
procedure TFormMain.ListBoxRacesDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  lListBox: TListBox;
  lRaceItem: TRaceItem;
  lFgColor: TColor;
  lBgColor: TColor;
begin
  lListBox := TListBox(Control);
  lRaceItem := TRaceItem(lListBox.Items.Objects[Index]);
  if lRaceItem = nil then
    Exit;

  SmartTimingTools.GetColorsForRaceStatus(lRaceItem.Status, odSelected in State, lBgColor, lFgColor);
  if lBgColor = clWindow then
    Exit;
  lListBox.Canvas.Brush.Color := lBgColor;
  lListBox.Canvas.Font.Color := lFgColor;
  lListBox.Canvas.FillRect(Rect);
  lListBox.Canvas.TextRect(Rect, Rect.Left + 2, Rect.Top + 2, lListBox.Items[Index]);

  if odSelected in State then
    lListBox.Canvas.DrawFocusRect(Rect);
end;

{==============================================================================}
procedure TFormMain.SetupRacesGrid;
var
  i: integer;
  lColumn: TColumn;
begin
  MainDataModule.RefreshRacesDataSet(FCurrentEventId);

  TGridFormatProvider.LoadSettings(DBGridRaces, cDefaultListFormatRaces);
  for i := 0 to DBGridRaces.Columns.Count - 1 do
  begin
    lColumn := DBGridRaces.Columns[i];
    SmartTimingTools.SetColumnProperties('RACES', lColumn);
  end;

  FreeAndNil(FDBCheckBoxRacesFirstPassing);
  FDBCheckBoxRacesFirstPassing := TDBCheckbox.Create(nil);
  FDBCheckBoxRacesFirstPassing.DataSource := MainDataModule.DataSourceRaces;
  FDBCheckBoxRacesFirstPassing.DataField := 'FIRSTPASSINGISLAP';
  FDBCheckBoxRacesFirstPassing.Visible := False;
  FDBCheckBoxRacesFirstPassing.Color := DBGridRaces.Color;
  FDBCheckBoxRacesFirstPassing.Caption := '';

  RefreshRacesListBox;
  GSmartTimingController.RestorePassings;
  ListBoxRacesTimingClick(nil);
end;

{==============================================================================}
procedure TFormMain.RefreshRacesListBox;
var
  lText: string;
  lRaceItem: TRaceItem;
  lRaceId: integer;
  lIndex: integer;
begin
  ListBoxRaces.LockDrawing;
  try
    ListBoxRaces.Items.Clear;

    for lRaceId in GSmartTimingController.RaceList.Keys do
    begin
      if not GSmartTimingController.RaceList.TryGetValue(lRaceId, lRaceItem) then
        Continue;

      lText := FormatDatetime('hh:mm', lRaceItem.StartTime) + ' - ' + lRaceItem.Title;
      ListBoxRaces.AddItem(lText, lRaceItem);
    end;

    ListBoxRaces.Sorted := true;
    // TODO Sorting

    ListBoxRaces.Invalidate;
  finally
    ListBoxRaces.UnlockDrawing;
  end;
  Application.ProcessMessages;

  lIndex := ListBoxRaces.ItemIndex;
  ListBoxRaces.ItemIndex := -1;
  Application.ProcessMessages;
  if lIndex < 0 then
  begin
    if ListBoxRaces.Count > 0 then
      ListBoxRaces.ItemIndex := 0;
  end
  else
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
  TGridFormatProvider.LoadSettings(DBGridCompetitors, cDefaultListFormatCompetitors);
  for i := 0 to DBGridCompetitors.Columns.Count - 1 do
  begin
    lColumn := DBGridCompetitors.Columns[i];
    SmartTimingTools.SetColumnProperties('COMPETITORS', lColumn);
  end;

  FillClassFilterComboBox;
end;

{==============================================================================}
procedure TFormMain.SetupRankingsGrid(ARaceId: Integer);
begin
  TRaceItem(ListBoxRaces.Items.Objects[ListBoxRaces.ItemIndex]).RaceEngine.RefreshRankingDisplay;
end;

procedure TFormMain.StackPanel1Click(Sender: TObject);
begin

end;

{==============================================================================}
procedure TFormMain.ToggleAutoScrollClick(Sender: TObject);
begin
  FAutoScrollPassingList := not FAutoScrollPAssingList;
end;

{==============================================================================}
procedure TFormMain.ReadSettings;
begin
  SmartTimingTools.InitFieldDescriptions;
end;

{==============================================================================}
procedure TFormMain.RefreshControlsFromEventDataObject(AEvent: TEventDataObject);
begin
  FCurrentEventId := AEvent.EventId;
  EditOrganizer.Text := AEvent.Organizer;
  EditTitle.Text := AEvent.Title;
  if AEvent.DateFrom > 0 then
    EditDateFrom.Text := DateToStr(AEvent.DateFrom);
  if AEvent.DateTo > 0 then
    EditDateTo.Text := DateToStr(AEvent.DateTo);

  LabelOrganizer.Caption := AEvent.Organizer;
  LabelTitle.Caption := AEvent.Title;
  LabelDate.Caption := DateTimeToStr(AEvent.DateFrom);
  if AEvent.DateFrom < AEvent.DateTo then
    LabelDate.Caption := LabelDate.Caption + ' - ' + EditDateTo.Text;
end;

{==============================================================================}
procedure TFormMain.MenuItemBackupClick(Sender: TObject);
var
  lDay, lMonth, lYear, lHour, lMin, lSec, lMSec: Word;
begin
  FileOpenDialog.DefaultExtension := 'bak';
  FileOpenDialog.OkButtonLabel := cButtonCaptionBackup;

  DecodeDate(Now, lYear, lMonth, lDay);
  DecodeTime(Now, lHour, lMin, lSec, lMSec);
  FileOpenDialog.FileName := 'SmartTiming_' + Format('%.4d-%.2d-%.2d-%.2d-%.2d.bak', [lYear, lMonth, lDay, lHour, lMin]);
  if not FileOpenDialog.Execute then
    Exit;

  if MainDataModule.BackupDatabase(FileOpenDialog.FileName) then
    ShowMessage(cMessagesBackupSucceeded)
  else
    ShowMessage(cMessagesBackupFailed)
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
    if lFormCompetitorImport.ShowModal = mrOK then
      SetupCompetitorsGrid;
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
procedure TFormMain.MenuItemReportsClick(Sender: TObject);
begin
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
  FileOpenDialog.OkButtonLabel := cButtonCaptionExport;
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
  FileOpenDialog.OkButtonLabel := cButtonCaptionImport;
  if not FileOpenDialog.Execute then
    Exit;
  MainDataModule.ImportTxMapping(FileOpenDialog.FileName);
end;

{==============================================================================}
procedure TFormMain.ButtonSaveEventClick(Sender: TObject);
begin
  GSmartTimingController.SaveEvent(EditOrganizer.Text, EditTitle.Text, StrToDate(EditDateFrom.Text), StrToDate(EditDateTo.Text));
  GSmartTimingController.Event.SaveToDatabase;
  RefreshControlsFromEventDataObject(GSmartTimingController.Event);
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
procedure TFormMain.ButtonStopClick(Sender: TObject);
begin
  RaceButtonStatusChange(rsStopped);
end;

{==============================================================================}
procedure TFormMain.ButtonNeutralizeClick(Sender: TObject);
begin
  RaceButtonStatusChange(rsNeutralized);
end;

{==============================================================================}
procedure TFormMain.ButtonPrintParticipantListClick(Sender: TObject);
var
  lRaceItem: TRaceItem;
begin
  if (ListBoxRaces.ItemIndex < 0) or (ListBoxRaces.ItemIndex >= ListBoxRaces.Count) then
    Exit;
  lRaceItem := TRaceItem(ListBoxRaces.Items.Objects[ListBoxRaces.ItemIndex]);
  lRaceItem.RaceEngine.ExportParticipantsToExcelTemplate('');
end;

{==============================================================================}
procedure TFormMain.ButtonAbortClick(Sender: TObject);
begin
  RaceButtonStatusChange(rsAborted);
end;

{==============================================================================}
procedure TFormMain.ButtonExportToExelTemplateClick(Sender: TObject);
var
  lRaceItem: TRaceItem;
begin
  if (ListBoxRaces.ItemIndex < 0) or (ListBoxRaces.ItemIndex >= ListBoxRaces.Count) then
    Exit;
  lRaceItem := TRaceItem(ListBoxRaces.Items.Objects[ListBoxRaces.ItemIndex]);
  lRaceItem.RaceEngine.ExportResultsToExcelTemplate('', CheckBoxResultsGroupByClass.Checked);
end;

{==============================================================================}
procedure TFormMain.ButtonPrintResultsClick(Sender: TObject);
var
  lRaceItem: TRaceItem;
begin
  if (ListBoxRaces.ItemIndex < 0) or (ListBoxRaces.ItemIndex >= ListBoxRaces.Count) then
    Exit;
  lRaceItem := TRaceItem(ListBoxRaces.Items.Objects[ListBoxRaces.ItemIndex]);
  lRaceItem.RaceEngine.PrintResults(CheckBoxResultsGroupByClass.Checked);
end;

{==============================================================================}
procedure TFormMain.ButtonFinishClick(Sender: TObject);
begin
  RaceButtonStatusChange(rsFinished);
end;

{==============================================================================}
procedure TFormMain.RaceButtonStatusChange(ARaceStatus: TRaceStatus);
begin
  MainDataModule.DataSourceRaces.DataSet.RecNo := ListBoxRaces.ItemIndex + 1;
  GSmartTimingController.ChangeRaceStatus(MainDataModule.DataSourceRaces.DataSet.FieldByName('RACEID').AsInteger, ARaceStatus);
  RefreshRacesListBox;
end;

{==============================================================================}
procedure TFormMain.RefreshFlagButtonsVisibility(ARaceItem: TRaceItem);
  function GetButtonForStatus(ARaceStatus: TRaceStatus): TControl;
  begin
    case ARaceStatus of
    rsWarmUp:
      Exit(ButtonWarmUp);
    rsStarted:
      Exit(ButtonStart);
    rsNeutralized:
      Exit(ButtonNeutralize);
    rsFinished:
      Exit(ButtonFinish);
    rsAborted:
      Exit(ButtonAbort);
    rsStopped:
      Exit(ButtonStop);
    else
      Exit(nil);
    end;
  end;

var
  lRaceStates: TRaceStates;
  lRaceStatus: TRaceStatus;
  lLeftPos: Integer;
  lButton: TControl;
begin
  lRaceStates := ARaceItem.RaceEngine.AvailableRaceStates;

  lLeftPos := 16;
  for lRaceStatus := rsNotStarted to rsStopped do
  begin
    lButton := GetButtonForStatus(lRaceStatus);
    if lButton = nil then
      Continue;

    if not (lRaceStatus in lRaceStates) then
    begin
      if lButton <> nil then
        lButton.Visible := false;
      Continue;
    end;
    lButton.Visible := true;
    lButton.Left := lLeftPos;
    Inc(lLeftPos, lButton.Width + 6);
  end;
end;

{==============================================================================}
procedure TFormMain.RefreshFlagButtonsActive(ARaceStatus: TRaceStatus);
begin
  case ARaceStatus of
  rsNotStarted:
    begin
      ButtonNeutralize.Enabled := false;
      ButtonWarmUp.Enabled := true;
      ButtonStart.Enabled := true;
      ButtonAbort.Enabled := false;
      ButtonFinish.Enabled := false;
      ButtonStop.Enabled := false;
    end;
  rsWarmUp:
    begin
      ButtonNeutralize.Enabled := false;
      ButtonWarmUp.Enabled := false;
      ButtonStart.Enabled := true;
      ButtonAbort.Enabled := true;
      ButtonFinish.Enabled := false;
      ButtonStop.Enabled := true;
    end;
  rsStarted:
    begin
      ButtonNeutralize.Enabled := true;
      ButtonWarmUp.Enabled := false;
      ButtonStart.Enabled := false;
      ButtonAbort.Enabled := true;
      ButtonFinish.Enabled := true;
      ButtonStop.Enabled := true;
    end;
  rsNeutralized:
    begin
      ButtonNeutralize.Enabled := false;
      ButtonWarmUp.Enabled := false;
      ButtonStart.Enabled := true;
      ButtonAbort.Enabled := true;
      ButtonFinish.Enabled := true;
      ButtonStop.Enabled := true;
    end;
  rsFinished:
    begin
      ButtonNeutralize.Enabled := false;
      ButtonWarmUp.Enabled := false;
      ButtonStart.Enabled := true;
      ButtonAbort.Enabled := false;
      ButtonFinish.Enabled := false;
      ButtonStop.Enabled := true;
    end;
  rsAborted:
    begin
      ButtonNeutralize.Enabled := false;
      ButtonWarmUp.Enabled := true;
      ButtonStart.Enabled := true;
      ButtonAbort.Enabled := false;
      ButtonFinish.Enabled := false;
      ButtonStop.Enabled := true;
    end;
  rsStopped:
    begin
      ButtonNeutralize.Enabled := false;
      ButtonWarmUp.Enabled := true;
      ButtonStart.Enabled := true;
      ButtonAbort.Enabled := false;
      ButtonFinish.Enabled := false;
      ButtonStop.Enabled := false;
    end;
  end;
end;

{==============================================================================}
procedure TFormMain.OnGetRaceType(ASender: TField; var AText: string; ADisplayText: Boolean);
begin
  AText := SmartTimingTools.GetRaceTypeStringFromEnum(TRaceType(ASender.AsInteger));
end;

{==============================================================================}
procedure TFormMain.PageControlMainChange(Sender: TObject);
begin
  if PageControlMain.ActivePage = TabSheetEvent then
    Exit;

  if PageControlMain.ActivePage = TabSheetCompetitors then
  begin
    SetupCompetitorsGrid;
    Exit;
  end;

  if PageControlMain.ActivePage = TabSheetTiming then
  begin
    ListBoxRaces.Parent := PanelRaces;
    ListBoxRaces.OnClick := ListBoxRacesTimingClick;
  end;

  if PageControlMain.ActivePage = TabSheetResults then
  begin
    ListBoxRaces.Parent := PanelResultRaces;
    ListBoxRaces.OnClick := ListBoxRacesResultClick;
  end;

  if (ListBoxRaces.ItemIndex < 0) and (ListBoxRaces.Count > 0) then
    ListBoxRaces.ItemIndex := 0;
  ListBoxRacesTimingClick(nil);
end;

procedure TFormMain.PanelCompetitorsGridButtonsClick(Sender: TObject);
begin

end;

{==============================================================================}
procedure TFormMain.PopupMenuCompetitorActionsPopup(Sender: TObject);
begin
  RefreshAddCompetitorToRaceMenu;
end;

procedure TFormMain.PopupMenuCompetitorAssignToRaceClick(Sender: TObject);
begin

end;

{==============================================================================}
procedure TFormMain.PopupMenuCompetitorDeleteClick(Sender: TObject);
begin
   // TODO
end;

{==============================================================================}
procedure TFormMain.DecoderConnected(ADecoder: TDecoder);
begin
  LabelDecoderManufacturer.Caption := ADecoder.DecoderManufacturer;
  LabelDecoderIpAddress.Caption := ADecoder.Address;
end;

{==============================================================================}
procedure TFormMain.AddDecoderStatus(ADecoderStatus: TDecoderStatus);
begin
  LabelDecoderId.Caption := ADecoderStatus.DecoderId;
  LabelDecoderNoiseLevel.Caption := 'Störungslevel: ' + ADecoderStatus.Noise.ToString;
  LabelDecoderTemperature.Caption := 'Temperatur: ' + ADecoderStatus.Temperature.ToString;
end;

{==============================================================================}
procedure TFormMain.AddPassingForRaceId(ARaceId: integer; APassing: TPassing);
var
  i: integer;
  lRaceItem: TRaceItem;
begin
  if ARaceId < 0 then
    Exit;

  for i := 0 to ListBoxRaces.Count - 1 do
  begin
    lRaceItem := TRaceItem(ListBoxRaces.Items.Objects[i]);
    if lRaceItem.Id = ARaceId then
    begin
      APassing.RaceId := ARaceId;
      lRaceItem.RaceEngine.AddPassingToDisplay(APassing, FAutoScrollPassingList);
      lRaceItem.RaceEngine.RefreshRankingDisplay;
      Exit;
    end;
  end;
end;

{==============================================================================}
function TFormMain.GetAllRaceIds: TArray<integer>;
var
  i: integer;
  lRaceItem: TRaceItem;
begin
  SetLength(result, ListBoxRaces.Count);
  for i := 0 to ListBoxRaces.Count - 1 do
  begin
    result[i] := -1;
    lRaceItem := TRaceItem(ListBoxRaces.Items.Objects[i]);
    if lRaceItem = nil then
      Continue;
    result[i] := lRaceItem.Id;
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
  lSelected: Integer;
  lMenuItem: TMenuItem;
  lRaceId: Integer;
  lCompetitorIds: TArray<Integer>;
  lRaceItem: TRaceItem;
begin
  if not (ASender is TMenuItem) then
    Exit;

  lSelected := DBGridCompetitors.SelectedIndex;
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
  if GSmartTimingController.RaceList.TryGetValue(lRaceId, lRaceItem) then
    TDBGrid(lRaceItem.RaceEngine.RankingDisplay).DataSource.DataSet.Refresh;
  DBGridCompetitors.SelectedIndex := lSelected;
end;

{==============================================================================}
procedure TFormMain.OnRemoveCompetitorsFromRace(ASender: TObject);
var
  lSelected: Integer;
  lMenuItem: TMenuItem;
  lRaceId: Integer;
  lCompetitorIds: TArray<Integer>;
  lRaceItem: TRaceItem;
begin
  if not (ASender is TMenuItem) then
    Exit;

  lSelected := DBGridCompetitors.SelectedIndex;
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
  MainDataModule.RemoveCompetitorsFromRace(FCurrentEventId, lRaceId, lCompetitorIds);
  if GSmartTimingController.RaceList.TryGetValue(lRaceId, lRaceItem) then
    TDBGrid(lRaceItem.RaceEngine.RankingDisplay).DataSource.DataSet.Refresh;
  DBGridCompetitors.SelectedIndex := lSelected;
end;

end.
