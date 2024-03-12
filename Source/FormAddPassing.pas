unit FormAddPassing;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Mask,
  Data.SqlExpr, DataModule, Vcl.ComCtrls, Generics.Collections;

type
  TFormManuallyAddPassing = class(TForm)
    PanelButtons: TPanel;
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
  private
    FSQLDataSet: TSQLDataSet;
    FHour: Word;
    FMin: Word;
    FSec: Word;
    FMs: Word;
    FRecentlyUsed: TList<Integer>;

    procedure SetTime(ATime: TDatetime);
    function GetTime: TDatetime;

  public
    procedure Reset;
  end;

implementation

{$R *.dfm}

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
begin
  SetTime(Now);
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
procedure TFormManuallyAddPassing.Reset;
var
  i: integer;
begin
  FSQLDataSet.Active := false;
  MainDataModule.FillReadOnlyDataSetForSQL(
    'SELECT COUNT(*) ' +
    'FROM PARTICIPATION P ' +
    'INNER JOIN COMPETITORS C ON P.COMPETITORID = C.COMPETITORID ' +
    'INNER JOIN RACES R ON P.RACEID = R.RACEID ' +
    'WHERE R.STATUS IN (1,2) ' +
    'ORDER BY BIB', FSQLDataSet);
  FSQLDataSet.First;
//  ListViewCompetitors.RowCount := FSQLDataSet.FieldList[0].AsInteger;
  FSQLDataSet.Active := false;

  MainDataModule.FillReadOnlyDataSetForSQL(
    'SELECT C.BIB, C.FIRSTNAME, C.LASTNAME, C.CHIPID, C.CLUB ' +
    'FROM PARTICIPATION P ' +
    'INNER JOIN COMPETITORS C ON P.COMPETITORID = C.COMPETITORID ' +
    'INNER JOIN RACES R ON P.RACEID = R.RACEID ' +
    'WHERE R.STATUS IN (1,2) ' +
    'ORDER BY BIB', FSQLDataSet);

  i := 0;
  FSQLDataSet.First;
  while not FSQLDataSet.Eof do
  begin
//    StringGridCompetitorsInRace.Cells[0, i] := FSQLDataSet.FieldByName('BIB').AsString;
//    StringGridCompetitorsInRace.Cells[1, i] := FSQLDataSet.FieldByName('CHIPID').AsString;
//    StringGridCompetitorsInRace.Cells[2, i] := FSQLDataSet.FieldByName('FIRSTNAME').AsString;
//    StringGridCompetitorsInRace.Cells[3, i] := FSQLDataSet.FieldByName('LASTNAME').AsString;
//    StringGridCompetitorsInRace.Cells[4, i] := FSQLDataSet.FieldByName('CLUB').AsString;
    FSQLDataSet.Next;
    Inc(i);
  end;
end;

end.
