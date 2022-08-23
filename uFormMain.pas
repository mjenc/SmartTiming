unit uFormMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Data.SqlExpr, Data.DbxSqlite,
  Data.FMTBcd, Datasnap.DBClient, Datasnap.Provider, Vcl.Grids, Vcl.DBGrids,
  Vcl.ComCtrls, Vcl.Menus, AdvMenus, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.WinXPickers,
  SmartTiming.DecoderEngine, SmartTIming.DecoderInterface, Vcl.Buttons,
  uFormDataGrid, uPassingProtocolGrid, uFormRaceDetails;

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
    LabelDecoderId: TLabel;
    LabelDecoderTemperature: TLabel;
    LabelDecoderNoiseLevel: TLabel;
    MainMenu: TMainMenu;
    ools1: TMenuItem;
    Datei1: TMenuItem;
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
    ButtonSaveEvent: TButton;
    PanelRaces: TPanel;
    PanelPassings: TPanel;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    ListBox1: TListBox;
    PanelStandings: TPanel;
    PanelRaceControls: TPanel;
    PanelPassingGrid: TPanel;
    PanelEventDetails: TPanel;
    PanelEventRaces: TPanel;
    Label4: TLabel;
    procedure DatePickerFromChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Splitter2CanResize(Sender: TObject; var NewSize: Integer;
      var Accept: Boolean);
    procedure FormShow(Sender: TObject);

  private
    FStandingsGrid: TFormDataGrid;
    FEventRacesGrid: TFormDataGrid;

  protected
    procedure OnNewRaceClick(ASender: TObject);
    procedure OnEditRaceClick(ASender: TObject);
    procedure OnDeleteRaceClick(ASender: TObject);

    procedure OnStatusReceived(AStatus: TMyLapsP3Status);
    procedure OnPassingReceived(Passing: TMyLapsP3Passing);

  public
    { Public-Deklarationen }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

{==============================================================================}
procedure TFormMain.DatePickerFromChange(Sender: TObject);
begin
  if DatePickerFrom.Date > DatePickerTo.Date then
    DatePickerTo.Date := DatePickerFrom.Date;
end;

{==============================================================================}
procedure TFormMain.FormCreate(Sender: TObject);
var
  lDecoderEngine: TMyLapsDecoderEngine;
begin
  lDecoderEngine := TMyLapsDecoderEngine.GetSingleton;
  lDecoderEngine.NewPassingReceived := OnPassingReceived;
  lDecoderEngine.NewStatusReceived := OnStatusReceived;

  FStandingsGrid := nil;
end;

{==============================================================================}
procedure TFormMain.FormShow(Sender: TObject);
begin
  if FStandingsGrid = nil then
  begin
    FStandingsGrid := TFormDataGrid.Create(nil);
    FStandingsGrid.ShowInControl(PanelStandings);
  end;

  if FEventRacesGrid = nil then
  begin
    FEventRacesGrid := TFormDataGrid.Create(nil);
    FEventRacesGrid.VisibleButtons := [gbNew, gbEdit, gbDelete];
    FEventRacesGrid.ToolButtonNew.OnClick := OnNewRaceClick;
    FEventRacesGrid.ToolButtonEdit.OnClick := OnEditRaceClick;
    FEventRacesGrid.ToolButtonDelete.OnClick := OnDeleteRaceClick;
    FEventRacesGrid.ShowInControl(PanelEventRaces);
  end;
end;

{==============================================================================}
procedure TFormMain.OnNewRaceClick(ASender: TObject);
var
  lRaceDetailsForm: TFormRaceDetails;
begin
  lRaceDetailsForm := TFormRaceDetails.Create(nil);
  try
    if lRaceDetailsForm.ShowModal = mrCancel then
      Exit;

    // TODO
  finally
    FreeAndNil(lRaceDetailsForm);
  end;
end;

{==============================================================================}
procedure TFormMain.OnEditRaceClick(ASender: TObject);
begin
  // TODO
end;

{==============================================================================}
procedure TFormMain.OnDeleteRaceClick(ASender: TObject);
begin
  // TODO
end;

{==============================================================================}
procedure TFormMain.OnStatusReceived(AStatus: TMyLapsP3Status);
begin
  LabelDecoderNoiseLevel.Caption := 'Störungslevel: ' + AStatus.Noise.ToString;
  LabelDecoderTemperature.Caption := 'Temperatur: ' + AStatus.Temperature.ToString;
end;

procedure TFormMain.Splitter2CanResize(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
begin
end;

{==============================================================================}
procedure TFormMain.OnPassingReceived(Passing: TMyLapsP3Passing);
begin
  // TODO
end;


end.
