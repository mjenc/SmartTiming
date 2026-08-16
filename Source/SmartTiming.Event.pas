unit SmartTiming.Event;

interface

uses
  SysUtils, Data.DB, Data.SqlExpr;


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
    function AsJSON: string;

    property EventId: integer read FEventId write FEventId;
    property Organizer: string read FOrganizer write FOrganizer;
    property Title: string read FTitle write FTitle;
    property DateFrom: TDatetime read FDateFrom write FDateFrom;
    property DateTo: TDatetime read FDateTo write FDateTo;
  end;

implementation

uses
  DataModule, DateUtils, Tools.Logger, SmartTiming.Tools;

const
  cLogger = 'SmartTiming.Event';

{==============================================================================}
function TEventDataObject.Exists(AEventId: integer): boolean;
var
  lDataSet: TSQLDataSet;
begin
  try
    LogOnDebug(cLogger, ['Exists', 'EventId = ' + AEventId.ToString]);
    lDataSet := MainDataModule.OpenReadOnlyQuery(
      'SELECT EVENTID FROM EVENTS WHERE EVENTID = ' + AEventId.ToString);
    try
      Result := (lDataSet <> nil) and lDataSet.Active and not lDataSet.IsEmpty;
    finally
      FreeAndNil(lDataSet);
    end;
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['Exists', 'EventId = ' + AEventId.ToString]);
  end;
end;

{==============================================================================}
procedure TEventDataObject.SaveToDatabase;
var
  lCmd: string;
  lFormatSettings: TFormatSettings;
begin
  try
    LogOnDebug(cLogger, ['SaveToDatabase', 'EventId = ' + FEventId.ToString]);
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
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['SaveToDatabase', 'EventId = ' + FEventId.ToString]);
  end;
end;

{==============================================================================}
procedure TEventDataObject.DeleteFromDatabase;
var
  lParams: TParams;
  lValue: TParam;
begin
  try
    LogOnDebug(cLogger, ['DeleteFromDatabase', 'EventId = ' + FEventId.ToString]);
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
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['DeleteFromDatabase', 'EventId = ' + FEventId.ToString]);
  end;
end;

{==============================================================================}
procedure TEventDataObject.RefreshFromDatabase;
var
  lDataSet: TSQLDataSet;
begin
  try
    LogOnDebug(cLogger, ['RefreshFromDatabase', 'EventId = ' + FEventId.ToString]);
    if Exists(FEventId) then
      lDataSet := MainDataModule.OpenReadOnlyQuery(
        'SELECT * FROM EVENTS WHERE EVENTID = ' + FEventId.ToString)
    else
      (* EventId may still be unset after open; take the first (usually only) row. *)
      lDataSet := MainDataModule.OpenReadOnlyQuery(
        'SELECT * FROM EVENTS ORDER BY EVENTID LIMIT 1');
    try
      if (lDataSet = nil) or not lDataSet.Active or lDataSet.IsEmpty then
        Exit;

      FEventId := lDataSet.FieldByName('EVENTID').AsInteger;
      FOrganizer := lDataSet.FieldByName('ORGANIZER').AsString;
      FTitle := lDataSet.FieldByName('TITLE').AsString;
      FDateFrom := SmartTimingTools.GetFieldAsDatetime(lDataSet.FieldByName('DATEFROM'), 0);
      FDateTo := SmartTimingTools.GetFieldAsDatetime(lDataSet.FieldByName('DATETO'), 0);
    finally
      FreeAndNil(lDataSet);
    end;
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['RefreshFromDatabase', 'EventId = ' + FEventId.ToString]);
  end;
end;

{==============================================================================}
function TEventDataObject.AsJSON: string;
begin
  result := Format(
    '{ "id": %d, "organizer": "%s", "title": "%s", "datefrom": "%s", "dateto": "%s"}',
    [FEventId, FOrganizer, FTitle, FDateFrom.ToISO8601(false), FDateTo.ToISO8601(false)]);
end;

end.
