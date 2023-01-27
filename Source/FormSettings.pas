unit FormSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls,
  Registry, SmartTiming.Consts, SmartTiming.Tools, Data.DB, Vcl.Grids, Themes,
  Vcl.DBGrids, Data.FMTBcd, Data.SqlExpr, Datasnap.Provider, Datasnap.DBClient,
  DataModule;

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
    ComboBoxStyle: TComboBox;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
    procedure ComboBoxStyleChange(Sender: TObject);
  end;

var
  GFormSettings: TFormSettings;

implementation

{$R *.dfm}

{==============================================================================}
procedure TFormSettings.FormCreate(Sender: TObject);
var
  lStylename: string;
begin
  CheckBoxPassingBeep.Checked := SmartTimingTools.RegistryReadBool(HKEY_CURRENT_USER, cRegKeyPath + '\Settings', 'BeepOnPassing', false);

  for lStylename in TStyleManager.StyleNames do
    ComboBoxStyle.Items.Add(lStylename);

  ComboBoxStyle.Text := TStyleManager.ActiveStyle.Name;
end;

{==============================================================================}
procedure TFormSettings.ButtonOKClick(Sender: TObject);
begin
  SmartTimingTools.RegistryWriteBool(HKEY_CURRENT_USER, cRegKeyPath + '\Settings', 'BeepOnPassing', CheckBoxPassingBeep.Checked);
  SmartTimingTools.RegistryWriteString(HKEY_CURRENT_USER, cRegKeyPath + '\Settings', 'Theme', ComboBoxStyle.Text);
end;

{==============================================================================}
procedure TFormSettings.ComboBoxStyleChange(Sender: TObject);
begin
  TStyleManager.SetStyle(ComboBoxStyle.Items[ComboBoxStyle.ItemIndex]);
end;

end.
