unit uFormSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls,
  Registry, SmartTiming.Consts, SmartTiming.Tools, Data.DB, Vcl.Grids,
  Vcl.DBGrids, Data.FMTBcd, Data.SqlExpr, Datasnap.Provider, Datasnap.DBClient,
  uDataModule;

type
  TFormSettings = class(TForm)
    PanelButtons: TPanel;
    ButtonOK: TButton;
    ButtonCancel: TButton;
    PanelMain: TPanel;
    PageControlSettings: TPageControl;
    TabSheetCommon: TTabSheet;
    CheckBoxPassingBeep: TCheckBox;
    TabSheetCompetitorImport: TTabSheet;
    TabSheetFieldTitles: TTabSheet;
    ComboBoxTable: TComboBox;
    Label1: TLabel;
    DBGridDictionary: TDBGrid;
    ClientDataSetDictionary: TClientDataSet;
    DataSetProviderDictionary: TDataSetProvider;
    SQLQueryDictionary: TSQLQuery;
    DataSourceDictionary: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  FormSettings: TFormSettings;

implementation

{$R *.dfm}

{==============================================================================}
procedure TFormSettings.ButtonOKClick(Sender: TObject);
begin
  SmartTimingTools.RegistryWriteBool(HKEY_CURRENT_USER, cRegKeyPath + '\Settings', 'BeepOnPassing', CheckBoxPassingBeep.Checked);
end;

{==============================================================================}
procedure TFormSettings.FormCreate(Sender: TObject);
begin
  CheckBoxPassingBeep.Checked := SmartTimingTools.RegistryReadBool(HKEY_CURRENT_USER, cRegKeyPath + '\Settings', 'BeepOnPassing', false);
end;

end.
