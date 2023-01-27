unit DataModule;

interface

uses
  System.SysUtils, System.Classes, Data.DbxSqlite, Data.FMTBcd, DBGrids,
  Datasnap.DBClient, Datasnap.Provider, Data.DB, Data.SqlExpr, DBCtrls,
  Graphics, Dialogs,
  SmartTiming.Consts, SmartTiming.Tools, DecoderInterface;


type
  TMainDataModule = class(TDataModule)
    SQLConnection: TSQLConnection;
    SQLDataSetCompetitors: TSQLDataSet;
    DataSourceCompetitors: TDataSource;
    DataSetProviderCompetitors: TDataSetProvider;
    ClientDataSetCompetitors: TClientDataSet;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    function GetMaxIdOf(const ATableName, AColumnName: string): Integer;
  public
    function GetMaxRaceId(AEventId: integer): integer;
    function GetMaxCompetitorId: integer;
    function GetMaxParticipationId: integer;
    procedure FillWithDistinctValues(const ATableName, AFieldName: string; AStrings: TStrings);
    procedure AssignCompetitorsToRace(AEventId, ARaceId: Integer; const ACompetitorIDs: TArray<integer>);
    function IsCompetitorAssignedToRace(ARaceId, ACompetitorId: Integer): Boolean;
    function GetRaceIdForPassing(APassing: TPassing): integer;
    procedure SetRaceStatus(ARaceId: integer; ARaceStatus: TRaceStatus);
    procedure ImportTxMapping(const AFileName: string);
    procedure ExportTxMapping(const AFileName: string);
    procedure FillTransponderMappingCache;
    procedure AddPassingToDatabase(APassing: TPassing);
  end;

var
  MainDataModule: TMainDataModule;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  SmartTiming.Cache;

{==============================================================================}
procedure TMainDataModule.DataModuleCreate(Sender: TObject);
begin
  SQLConnection.DriverName := 'Sqlite';
  SQLConnection.Params.Add('Database=' + cStdDataPath + cStdDatabaseName);
  SQLConnection.LoginPrompt := false;
  SQLConnection.Connected := true;
end;

{==============================================================================}
procedure TMainDataModule.DataModuleDestroy(Sender: TObject);
begin
  SQLConnection.Connected := false;
end;

{==============================================================================}
function TMainDataModule.GetMaxRaceId(AEventId: integer): integer;
var
  lResultSet: TDataSet;
begin
  SQLConnection.Execute('SELECT MAX(RACEID) FROM RACES WHERE EVENTID = ' + AEventId.ToString, nil, lResultSet);
  try
    if lResultSet.IsEmpty then
      Exit(1);

    if lResultSet.RecordCount < 1 then
      Exit(0);

    lResultSet.First;
    Exit(lResultSet.Fields[0].AsInteger);
  finally
    FreeAndNil(lResultSet);
  end;
end;

{==============================================================================}
function TMainDataModule.GetMaxParticipationId: integer;
begin
  result := GetMaxIdOf('PARTICIPATION', 'PARTICIPATIONID');
end;

{==============================================================================}
function TMainDataModule.GetMaxCompetitorId: integer;
begin
  result := GetMaxIdOf('COMPETITORS', 'COMPETITORID');
end;

{==============================================================================}
function TMainDataModule.GetMaxIdOf(const ATableName, AColumnName: string): Integer;
var
  lResultSet: TDataSet;
begin
  SQLConnection.Execute('SELECT MAX(' + AColumnName + ') FROM ' + ATableName, nil, lResultSet);
  try
    if lResultSet.IsEmpty then
      Exit(1);

    if lResultSet.RecordCount < 1 then
      Exit(0);

    lResultSet.First;
    Exit(lResultSet.Fields[0].AsInteger);
  finally
    FreeAndNil(lResultSet);
  end;
end;

{==============================================================================}
function TMainDataModule.IsCompetitorAssignedToRace(ARaceId, ACompetitorId: Integer): Boolean;
var
  lResultSet: TDataSet;
begin
  SQLConnection.Execute(Format('SELECT PARTICIPATIONID FROM PARTICIPATION WHERE RACEID = %d AND COMPETITORID = %d', [ARaceId, ACompetitorId]), nil, lResultSet);
  try
    if lResultSet.IsEmpty then
        Exit(false);
    lResultSet.First;
    Exit(not lResultSet.Eof);
  finally
    FreeAndNil(lResultSet);
  end;
end;

{==============================================================================}
function TMainDataModule.GetRaceIdForPassing(APassing: TPassing): integer;
var
  lResultSet: TDataSet;
begin
  SQLConnection.Execute(Format(
    'SELECT R.RACEID FROM PARTICIPATION P INNER JOIN RACES R ON P.RACEID = R.RACEID INNER JOIN COMPETITORS C ON P.COMPETITORID = C.COMPETITORID ' +
    'WHERE STATUS IN (1, 2) AND TRANSPONDERID = %d', [APassing.TxId]), nil, lResultSet);
  try
    if lResultSet.IsEmpty then
      Exit(-1);
    lResultSet.First;
    Exit(lResultSet.FieldByName('RACEID').AsInteger);
  finally
    FreeAndNil(lResultSet);
  end;
end;

{==============================================================================}
procedure TMainDataModule.FillWithDistinctValues(const ATableName, AFieldName: string; AStrings: TStrings);
var
  lResultSet: TDataSet;
  lValue: string;
begin
  AStrings.Clear;
  SQLConnection.Execute('SELECT DISTINCT ' + AFieldName + ' FROM ' + ATableName + ' ORDER BY 1', nil, lResultSet);
  try
    if lResultSet.IsEmpty then
      Exit;

    lResultSet.First;
    while not lResultSet.Eof do
    begin
      lValue := lResultSet.Fields[0].AsString;
      AStrings.Add(lValue);
      lResultSet.Next;
    end;
  finally
    FreeAndNil(lResultSet);
  end;
end;

{==============================================================================}
procedure TMainDataModule.AssignCompetitorsToRace(AEventId, ARaceId: Integer; const ACompetitorIDs: TArray<integer>);
var
  lCmd: string;
  lParticipationId: integer;
  i: integer;
begin
  lParticipationId := GetMaxParticipationId + 1;
  for i := 0 to High(ACompetitorIDs) do
  begin
    if IsCompetitorAssignedToRace(ARaceId, ACompetitorIDs[i]) then
      Continue;
    lCmd := Format('INSERT INTO PARTICIPATION (PARTICIPATIONID, RACEID, COMPETITORID, STARTTIME) SELECT %d, %d, COMPETITORID, STARTTIME FROM COMPETITORS WHERE COMPETITORID = %d', [lParticipationId, ARaceId, ACompetitorIDs[i]]);
    SQLConnection.Execute(lCmd, nil);
    Inc(lParticipationId);
  end;
end;


{==============================================================================}
procedure TMainDataModule.SetRaceStatus(ARaceId: integer; ARaceStatus: TRaceStatus);
begin
  SQLConnection.Execute('UPDATE RACES SET STATUS = ' + Ord(ARaceStatus).ToString + ' WHERE RACEID = ' + ARaceId.ToString, nil);
end;

{==============================================================================}
procedure TMainDataModule.AddPassingToDatabase(APassing: TPassing);
var
  lCmd: string;
  lTimeStr: string;
begin
  lTimeStr := FormatDatetime('yyyy-mm-dd hh:mm:ss.zzz', APassing.PassingTime).QuotedString;
  lCmd :=
        Format('INSERT INTO PASSINGS ' +
           '(PASSINGNUMBER, TRANSPONDERID, PASSINGTIME, SIGNALSTRENGTH, HITS, FLAGS, SPORT, DECODERID) VALUES ' +
           '(%d, %s, %s, %d, %d, %d, %d, %s)',
           [APassing.PassingNumber, APassing.ChipId.QuotedString, lTimeStr, APassing.SignalStrength, APassing.Hits, APassing.Flags, APassing.Sport, APassing.DecoderId.QuotedString]);
  SQLConnection.Execute(lCmd, nil);
end;

{==============================================================================}
procedure TMainDataModule.ImportTxMapping(const AFileName: string);
var
  lResultSet: TDataSet;
  lCmd: string;
  lLines: TStringList;
  i: integer;
  lShortId: integer;
  lChipId: string;
begin
  lLines := TStringList.Create;
  try
    lLines.NameValueSeparator := #9;
    lLines.LoadFromFile(AFileName);

    SQLConnection.Execute('SELECT * FROM TRANSPONDERS ORDER BY SHORTID', nil, lResultSet);
    if not lResultSet.IsEmpty then
    begin
      // Look for changes and deletions and remove them from the list
      lResultSet.First;
      while not lResultSet.Eof do
      begin
        lShortId := lResultSet.FieldByName('SHORTID').AsInteger;
        i := lLines.IndexOfName(lShortId.ToString);
        if i < 0 then
        begin
          lResultSet.Delete;
          lCmd := Format('DELETE FROM TRANSPONDERS WHERE SHORTID = %d', [lShortId]);
          SQLConnection.Execute(lCmd, nil);
          lResultSet.Next;
          Continue;
        end;

        lChipId := lLines.ValueFromIndex[i];
        if SameText(lChipId, lResultSet.FieldByName('SHORTID').AsString) then
        begin
          lLines.Delete(i);
          lResultSet.Next;
          Continue;
        end;

        lCmd := Format('UPDATE TRANSPONDERS SET CHIPID = %s, LOWBATTERYSTATUS = 0, FIRSTLOWBATTERYTIME = NULL WHERE SHORTID = %d', [lShortId]);
        SQLConnection.Execute(lCmd, nil);
        lLines.Delete(i);
        lResultSet.Next;
      end;
    end;

    // Add the remaining entries to the table
    for i  := 0 to lLines.Count - 1 do
    begin
      lShortId := lLines.KeyNames[i].ToInteger;
      lChipId := lLines.ValueFromIndex[i];
      lCmd := Format('INSERT INTO TRANSPONDERS (SHORTID, CHIPID, LOWBATTERYSTATUS, FIRSTLOWBATTERYTIME) VALUES (%d, %s, 0, NULL)', [lShortId, QuotedStr(lChipId)]);
      SQLConnection.Execute(lCmd, nil);
    end;

    FillTransponderMappingCache;
  finally
    FreeAndNil(lLines);
    FreeAndNil(lResultSet);
  end;
end;

{==============================================================================}
procedure TMainDataModule.ExportTxMapping(const AFileName: string);
var
  lResultSet: TDataSet;
  lLines: TStringList;
  lShortId: integer;
  lChipId: string;
begin
  lLines := TStringList.Create;
  try
    lLines.NameValueSeparator := #9;

    SQLConnection.Execute('SELECT SHORTID, CHIPID FROM TRANSPONDERS ORDER BY SHORTID', nil, lResultSet);
    if not lResultSet.IsEmpty then
    begin
      // Look for changes and deletions and remove them from the list
      lResultSet.First;
      while not lResultSet.Eof do
      begin
        lShortId := lResultSet.FieldByName('SHORTID').AsInteger;
        lChipId := lResultSet.FieldByName('CHIPID').AsString;
        lLines.AddPair(lShortId.ToString, lChipId);
        lResultSet.Next;
      end;
    end;
    lLines.SaveToFile(AFileName);
  finally
    FreeAndNil(lLines);
    FreeAndNil(lResultSet);
  end;
end;

{==============================================================================}
procedure TMainDataModule.FillTransponderMappingCache;
var
  lResultSet: TDataSet;
begin
  TTransponderMappingStore.GetSingleton.Clear;

  SQLConnection.Execute('SELECT SHORTID, CHIPID FROM TRANSPONDERS ORDER BY SHORTID', nil, lResultSet);
  try
    if lResultSet.IsEmpty or (lResultSet.RecordCount < 1) then
      Exit;

    lResultSet.First;
    while not lResultSet.Eof do
    begin
      TTransponderMappingStore.GetSingleton.AddTransponder(lResultSet.Fields[0].AsInteger, lResultSet.Fields[1].AsString);
      lResultSet.Next;
    end;
  finally
    FreeAndNil(lResultSet);
  end;
end;

end.
