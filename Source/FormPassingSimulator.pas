unit FormPassingSimulator;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Data.DB,
  Vcl.Grids, Vcl.DBGrids, Vcl.ComCtrls, Data.FMTBcd, Datasnap.DBClient,
  Datasnap.Provider, Data.SqlExpr,
  SmartTiming.Consts, SmartTiming.Cache, DecoderInterface, SmartTiming.DecoderEngine;

type
  TFormPassingSimulator = class(TForm)
    PanelButtons: TPanel;
    ButtonClose: TButton;
    PageControlSimulator: TPageControl;
    TabSheetSinglePassings: TTabSheet;
    TabSheetSingleSimulateRace: TTabSheet;
    SQLDataSetCompetitorsInRace: TSQLDataSet;
    DataSetProviderCompetitorsInRace: TDataSetProvider;
    ClientDataSetCompetitorsInRace: TClientDataSet;
    DataSourceCompetitorsInRace: TDataSource;
    StringGridCompetitorsInRace: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure StringGridCompetitorsInRaceCellClick(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure ButtonCloseClick(Sender: TObject);
  private
    FPassingNumber: integer;
    procedure SetupCompetitorsInRaceGrid;
  public
    { Public-Deklarationen }
  end;

var
  GFormPassingSimulator: TFormPassingSimulator;

implementation

{$R *.dfm}

uses
  DataModule;

{==============================================================================}
procedure TFormPassingSimulator.ButtonCloseClick(Sender: TObject);
begin
  Close;
end;

{==============================================================================}
procedure TFormPassingSimulator.FormCreate(Sender: TObject);
begin
  FPassingNumber := MainDataModule.GetMaxPassingNumber + 1;
  SetupCompetitorsInRaceGrid;
end;

{==============================================================================}
procedure TFormPassingSimulator.SetupCompetitorsInRaceGrid;
var
  i: integer;
begin
  ClientDataSetCompetitorsInRace.Active := false;
  SQLDataSetCompetitorsInRace.Active := false;
  SQLDataSetCompetitorsInRace.CommandText :=
    'SELECT C.BIB, C.FIRSTNAME, C.LASTNAME, C.CHIPID, C.CLUB ' +
    'FROM ' +
    'PARTICIPATION P ' +
    'INNER JOIN COMPETITORS C ON P.COMPETITORID = C.COMPETITORID ' +
    'INNER JOIN RACES R ON P.RACEID = R.RACEID ' +
    'WHERE R.STATUS IN (1,2) ' +
    'ORDER BY BIB';
  SQLDataSetCompetitorsInRace.Active := true;
  ClientDataSetCompetitorsInRace.Active := True;

  StringGridCompetitorsInRace.RowCount := ClientDataSetCompetitorsInRace.RecordCount;
  i := 0;
  ClientDataSetCompetitorsInRace.First;
  while not ClientDataSetCompetitorsInRace.Eof do
  begin
    StringGridCompetitorsInRace.Cells[0, i] := ClientDataSetCompetitorsInRace.FieldByName('BIB').AsString;
    StringGridCompetitorsInRace.Cells[1, i] := ClientDataSetCompetitorsInRace.FieldByName('CHIPID').AsString;
    StringGridCompetitorsInRace.Cells[2, i] := ClientDataSetCompetitorsInRace.FieldByName('FIRSTNAME').AsString;
    StringGridCompetitorsInRace.Cells[3, i] := ClientDataSetCompetitorsInRace.FieldByName('LASTNAME').AsString;
    StringGridCompetitorsInRace.Cells[4, i] := ClientDataSetCompetitorsInRace.FieldByName('CLUB').AsString;
    ClientDataSetCompetitorsInRace.Next;
    Inc(i);
  end;
end;

{==============================================================================}
procedure TFormPassingSimulator.StringGridCompetitorsInRaceCellClick(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
var
  lPassing: TPassing;
begin
  CanSelect := true;

  lPassing.PassingNumber := FPassingNumber;
  Inc(FPassingNumber);
  lPassing.ChipId := StringGridCompetitorsInRace.Cells[1, ARow];
  lPassing.PassingTime := Now;
  lPassing.SignalStrength := 123;
  lpAssing.Hits := 90;
  lPassing.Flags := 0;
  lPassing.Sport := 4;
  lPassing.Voltage := 9;
  lPassing.Temperature := 20;
  lPassing.DecoderId := 'STSIM';
  TDecoderEngine.GetSingleton.SendSimulatedPassing(lPassing);
end;


end.
