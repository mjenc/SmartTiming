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
    TabSheetGridFormatEditor: TTabSheet;
    ComboBoxGridFormats: TComboBox;
    MemoConfig: TMemo;
    ButtonResetFormatToStandard: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
    procedure ComboBoxStyleChange(Sender: TObject);
    procedure ComboBoxTableChange(Sender: TObject);
    procedure PageControlSettingsChange(Sender: TObject);
    procedure ComboBoxGridFormatsChange(Sender: TObject);
    procedure ButtonResetFormatToStandardClick(Sender: TObject);

  private
    FCurrentFormat: string;

    procedure FillComboBoxGridFormats;
    procedure SaveCurrentFormat;
  end;

var
  GFormSettings: TFormSettings;

implementation

{$R *.dfm}

uses
  SmartTiming.GridFormatProvider;

{==============================================================================}
procedure TFormSettings.FormCreate(Sender: TObject);
var
  lStylename: string;
begin
  FCurrentFormat := '';

  CheckBoxPassingBeep.Checked := SmartTimingTools.RegistryReadBool(HKEY_CURRENT_USER, cRegKeyPath + '\Settings', 'BeepOnPassing', false);

  for lStylename in TStyleManager.StyleNames do
    ComboBoxStyle.Items.Add(lStylename);

  ComboBoxStyle.Text := TStyleManager.ActiveStyle.Name;
end;

{==============================================================================}
procedure TFormSettings.PageControlSettingsChange(Sender: TObject);
begin
  if PageControlSettings.ActivePage = TabSheetGridFormatEditor then
    FillComboBoxGridFormats;
end;

{==============================================================================}
procedure TFormSettings.ButtonOKClick(Sender: TObject);
begin
  SaveCurrentFormat;
  SmartTimingTools.RegistryWriteBool(HKEY_CURRENT_USER, cRegKeyPath + '\Settings', 'BeepOnPassing', CheckBoxPassingBeep.Checked);
  SmartTimingTools.RegistryWriteString(HKEY_CURRENT_USER, cRegKeyPath + '\Settings', 'Theme', ComboBoxStyle.Text);
end;

{==============================================================================}
procedure TFormSettings.ComboBoxStyleChange(Sender: TObject);
begin
  TStyleManager.SetStyle(ComboBoxStyle.Items[ComboBoxStyle.ItemIndex]);
end;

{==============================================================================}
procedure TFormSettings.ComboBoxTableChange(Sender: TObject);
begin

end;

{==============================================================================}
procedure TFormSettings.FillComboBoxGridFormats;
var
  lReg: TRegistry;
  lRegPath: string;
begin
  ComboBoxGridFormats.Items.Clear;
  lReg := TRegistry.Create;
  try
    if not lReg.OpenKey(TGridFormatProvider.RegPath, false) then
      Exit;
    lReg.GetKeyNames(ComboBoxGridFormats.Items);
  finally
    FreeAndNil(lReg);
  end;
end;

{==============================================================================}
procedure TFormSettings.SaveCurrentFormat;
var
  lReg: TRegistry;
  lRegPath: string;
begin
  if FCurrentFormat.IsEmpty then
    Exit;

  lReg := TRegistry.Create;
  try
    lReg.RootKey := HKEY_CURRENT_USER;
    if not lReg.OpenKey(TGridFormatProvider.RegPath + '\' + FCurrentFormat, true) then
      Exit;

    lReg.WriteString('Columns', MemoConfig.Text);
  finally
    FreeAndNil(lReg);
  end;
end;

{==============================================================================}
procedure TFormSettings.ButtonResetFormatToStandardClick(Sender: TObject);
begin
  // TODO
end;

{==============================================================================}
procedure TFormSettings.ComboBoxGridFormatsChange(Sender: TObject);
var
  lReg: TRegistry;
  lRegPath: string;
begin
  SaveCurrentFormat;
  MemoConfig.Clear;
  FCurrentFormat := ComboBoxGridFormats.Text;
  if FCurrentFormat.IsEmpty then
    Exit;

  lReg := TRegistry.Create;
  try
    lReg.RootKey := HKEY_CURRENT_USER;
    if not lReg.OpenKey(TGridFormatProvider.RegPath + '\' + ComboBoxGridFormats.Text, false) then
      Exit;
    MemoConfig.Text := lReg.ReadString('Columns');
  finally
    FreeAndNil(lReg);
  end;
end;

end.
