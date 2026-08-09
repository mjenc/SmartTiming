unit FormAddPassing;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Mask,
  Data.SqlExpr, DataModule, Vcl.ComCtrls, Generics.Collections,
  DecoderInterface, SmartTiming.Consts, SmartTiming.Cache;

type
  TFormManuallyAddPassing = class(TForm)
    ButtonOK: TButton;
    ButtonCancel: TButton;
    Label2: TLabel;
    EditTime: TMaskEdit;
    Label3: TLabel;
    EditBIB: TEdit;
    PanelControls: TPanel;
    PanelGrid: TPanel;
    ListViewCompetitors: TListView;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ButtonOKClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ListViewCompetitorsDblClick(Sender: TObject);
  private
    FSQLDataSet: TSQLDataSet;
    FHour: Word;
    FMin: Word;
    FSec: Word;
    FMs: Word;
    FRecentlyUsed: TList<Integer>;

    procedure AddPassingForBib(ABib: Integer);
    procedure SetTime(ATime: TDatetime);
    function GetTime: TDatetime;
  end;

implementation

{$R *.dfm}

uses
  SmartTiming.Controller, FormMain;

{==============================================================================}
procedure TFormManuallyAddPassing.FormActivate(Sender: TObject);
begin
  EditBIB.SetFocus;
end;

procedure TFormManuallyAddPassing.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeAndNil(FSQLDataSet);
  Action := caHide;
end;

{==============================================================================}
procedure TFormManuallyAddPassing.FormCreate(Sender: TObject);
begin
  FRecentlyUsed := TList<Integer>.Create;
end;

{==============================================================================}
procedure TFormManuallyAddPassing.SetTime(ATime: TDatetime);
begin
  DecodeTime(ATime, FHour, FMin, FSec, FMs);
  EditTime.Text := FormatDatetime('HH:mm:ss.ms', ATime);
end;

{==============================================================================}
procedure TFormManuallyAddPassing.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FRecentlyUsed);
end;

{==============================================================================}
procedure TFormManuallyAddPassing.FormShow(Sender: TObject);
var
  lItem: TListItem;
  lBib: Integer;
begin
  SetTime(Now);

  ListViewCompetitors.Items.Clear;
  for lBib in FRecentlyUsed do
  begin
    lItem := ListViewCompetitors.Items.Add;
    lItem.Caption := lBib.ToString;
  end;

  EditBib.SetFocus;
end;

{==============================================================================}
procedure TFormManuallyAddPassing.ButtonCancelClick(Sender: TObject);
begin
  Close;
end;

{==============================================================================}
procedure TFormManuallyAddPassing.ButtonOKClick(Sender: TObject);
var
  lBib: Integer;
begin
  if EditBib.Text = '' then
  begin
    Close;
    Exit;
  end;

  lBib := StrToInt(EditBib.Text);
  if not FRecentlyUsed.Contains(lBib) then
    FRecentlyUsed.Insert(0, lBib);
  AddPassingForBib(lBib);
  SetTime(Now);
end;

{==============================================================================}
procedure TFormManuallyAddPassing.AddPassingForBib(ABib: Integer);
var
  lPassing: TPassing;
begin
  lPassing.PassingNumber := 0;
  lPassing.ChipId := MainDataModule.GetActiveTransponderIdForBib(ABib,
    GFormMain.GetSelectedRaceId);
  lPassing.PassingTime := GetTime + Trunc(Now);
  lPassing.SignalStrength := 100;
  lPassing.Hits := 90;
  lPassing.Flags := 0;
  lPassing.Sport := sSportsIdCycling;
  lPassing.DecoderId := 'MANUAL';
  lPassing.RaceId := 0;
  GSmartTimingController.AddManualPassing(lPassing);
end;

{==============================================================================}
function TFormManuallyAddPassing.GetTime: TDatetime;
var
  lFormatSettings: TFormatSettings;
begin
  lFormatSettings.TimeSeparator := ':';
  lFormatSettings.DecimalSeparator := '.';
  lFormatSettings.LongTimeFormat := 'HH:mm:ss.zzz';
  result := StrToTime(EditTime.Text, lFormatSettings);
end;

{==============================================================================}
procedure TFormManuallyAddPassing.ListViewCompetitorsDblClick(Sender: TObject);
begin
  AddPassingForBib(StrToInt(ListViewCompetitors.Selected.Caption));
  SetTime(Now);
end;

end.
