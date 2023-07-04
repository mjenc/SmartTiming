unit SmartTiming.Event;

interface

uses
  SysUtils, Data.DB;


type
  TEventDataObject = class
  private
    FEventId: integer;
    FOrganizer: string;
    FTitle: string;
    FDateFrom: TDatetime;
    FDateTo: TDatetime;

    function Exists(AEventId: integer): boolean;

  public
    procedure SaveToDatabase;
    procedure DeleteFromDatabase;
    procedure RefreshFromDatabase;

    property EventId: integer read FEventId write FEventId;
    property Organizer: string read FOrganizer write FOrganizer;
    property Title: string read FTitle write FTitle;
    property DateFrom: TDatetime read FDateFrom write FDateFrom;
    property DateTo: TDatetime read FDateTo write FDateTo;
  end;

implementation

uses
  DataModule;

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


end.
