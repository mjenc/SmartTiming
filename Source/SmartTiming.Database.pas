unit SmartTiming.Database;

interface

uses
  SysUtils, Classes, Data.DB, Data.SqlExpr, Datasnap.Provider, Datasnap.DBClient,
  SmartTiming.Consts, DataModule;

type
  TTableField = record
    FieldName: string;
    FieldType: TFieldType;
  end;

const
  cCompetitorFields: array[0..13] of TTableField =
    ((FieldName: 'CLASS'; FieldType: ftString),
     (FieldName: 'BIB'; FieldType: ftInteger),
     (FieldName: 'FIRSTNAME'; FieldType: ftString),
     (FieldName: 'LASTNAME'; FieldType: ftString),
     (FieldName: 'CLUB'; FieldType: ftString),
     (FieldName: 'TEAM'; FieldType: ftString),
     (FieldName: 'NATIONALITY'; FieldType: ftString),
     (FieldName: 'NATIONALITYISO'; FieldType: ftString),
     (FieldName: 'UCIID'; FieldType: ftString),
     (FieldName: 'HANDICAPFACTOR'; FieldType: ftFloat),
     (FieldName: 'ADDITIONAL1'; FieldType: ftString),
     (FieldName: 'ADDITIONAL2'; FieldType: ftString),
     (FieldName: 'ADDITIONAL3'; FieldType: ftString),
     (FieldName: 'TRANSPONDERID'; FieldType: ftInteger));

type
  TDataObject = class
  protected

  public
    procedure SaveToDatabase; virtual; abstract;
    procedure DeleteFromDatabase; virtual; abstract;
    procedure RefreshFromDatabase; virtual; abstract;
  end;

  TEventDataObject = class(TDataObject)
  private
    FEventId: integer;
    FOrganizer: string;
    FTitle: string;
    FDateFrom: TDatetime;
    FDateTo: TDatetime;

    function Exists(AEventId: integer): boolean;

  public

    procedure SaveToDatabase; override;
    procedure DeleteFromDatabase; override;
    procedure RefreshFromDatabase; override;

    property EventId: integer read FEventId write FEventId;
    property Organizer: string read FOrganizer write FOrganizer;
    property Title: string read FTitle write FTitle;
    property DateFrom: TDatetime read FDateFrom write FDateFrom;
    property DateTo: TDatetime read FDateTo write FDateTo;
  end;

  TRaceDataObject = class(TDataObject)
  private
    FRaceId: integer;
    FEventId: integer;
    FTitle: string;
    FStarttime: TDatetime;
    FRaceType: TRaceType;
    FLapCount: integer;
    FDistance: Double;
    FFirstPassingCounts: boolean;
    FMinLapDuration: TDatetime;
    FRaceStatus: TRaceStatus;
  public
    constructor Create;
    procedure SaveToDatabase; override;
    procedure DeleteFromDatabase; override;
    procedure RefreshFromDatabase; override;

    property RaceId: integer read FRaceId write FRaceId;
    property EventId: integer read FEventId write FEventId;
    property Title: string read FTitle write FTitle;
    property Starttime: TDatetime read FStarttime write FStarttime;
    property RaceType: TRaceType read FRaceType write FRaceType;
    property LapCount: integer read FLapCount write FLapCount;
    property Distance: Double read FDistance write FDistance;
    property FirstPassingCounts: boolean read FFirstPassingCounts write FFirstPassingCounts;
    property MinLapDuration: TDatetime read FMinLapDuration write FMinLapDuration;
    property RaceStatus: TRaceStatus read FRaceStatus write FRaceStatus;
  end;

  TCompetitorDataObject = class(TDataObject)
  public
    procedure SaveToDatabase; override;
    procedure DeleteFromDatabase; override;
    procedure RefreshFromDatabase; override;
  end;

implementation


{==============================================================================}
function TEventDataObject.Exists(AEventId: integer): boolean;
var
  lResultSet: TDataSet;
begin
  MainDataModule.SQLConnection.Execute('SELECT EVENTID FROM EVENTS WHERE EVENTID = ' + AEventId.ToString, nil, lResultSet);
  if lResultSet = nil then
    Exit(false);
  try
    result := lResultSet.RecordCount > 0;
  finally
    FreeAndNil(lResultSet);
  end;
end;

{==============================================================================}
procedure TEventDataObject.SaveToDatabase;
var
  lCmd: string;
  lFormatSettings: TFormatSettings;
begin
  lFormatSettings := TFormatSettings.Create;
  lFormatSettings.DecimalSeparator := '.';
  lFormatSettings.ThousandSeparator := #0;
  if Exists(FEventId) then
    lCmd :=
      Format('UPDATE EVENTS SET ORGANIZER = %s, TITLE = %s, DATEFROM = %f, DATETO = %f WHERE EVENTID = %d',
        [QuotedStr(FOrganizer),
         QuotedStr(FTitle),
         FDateFrom,
         FDateTo,
         FEventId], lFormatSettings)
  else
    lCmd :=
      Format('INSERT INTO EVENTS (ORGANIZER, TITLE, DATEFROM, DATETO, EVENTID) VALUES (%s, %s, %f, %f, %d)',
        [QuotedStr(FOrganizer),
         QuotedStr(FTitle),
         FDateFrom,
         FDateTo,
         FEventId], lFormatSettings);

  MainDataModule.SQLConnection.ExecuteDirect(lCmd);
end;

{==============================================================================}
procedure TEventDataObject.DeleteFromDatabase;
var
  lParams: TParams;
  lValue: TParam;
begin
  if not Exists(FEventId) then
    Exit;

  lParams := TParams.Create;
  try
    lValue := lParams.AddParameter;
    lValue.AsInteger := FEventId;
    MainDataModule.SQLConnection.Execute('DELETE FROM EVENTS WHERE EVENTID = ?', lParams);
  finally
    FreeAndNil(lParams);
  end;
end;

{==============================================================================}
procedure TEventDataObject.RefreshFromDatabase;
var
  lResultSet: TDataSet;
begin
  if not Exists(FEventId) then
    Exit;

  MainDataModule.SQLConnection.Execute('SELECT * FROM EVENTS WHERE EVENTID = ' + FEventId.ToString, nil, lResultSet);
  if (lResultSet = nil) or (lResultSet.RecordCount = 0) then
    Exit;

  lResultSet.First;

  FOrganizer := lResultSet.FieldByName('ORGANIZER').AsString;
  FTitle := lResultSet.FieldByName('TITLE').AsString;
  FDateFrom := lResultSet.FieldByName('DATEFROM').AsFloat;
  FDateTo := lResultSet.FieldByName('DATETO').AsFloat;
end;

{==============================================================================}
constructor TRaceDataObject.Create;
begin
  inherited;
  FRaceStatus := rsNotStarted;
end;

{==============================================================================}
procedure TRaceDataObject.SaveToDatabase;
begin
  // TODO
end;

{==============================================================================}
procedure TRaceDataObject.DeleteFromDatabase;
begin
  // TODO
end;

{==============================================================================}
procedure TRaceDataObject.RefreshFromDatabase;
begin
  // TODO
end;

{==============================================================================}
procedure TCompetitorDataObject.SaveToDatabase;
begin
  // TODO
end;

{==============================================================================}
procedure TCompetitorDataObject.DeleteFromDatabase;
begin
  // TODO
end;

{==============================================================================}
procedure TCompetitorDataObject.RefreshFromDatabase;
begin
  // TODO
end;


end.
