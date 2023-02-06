unit DataModule;

interface

uses
  System.SysUtils, System.Classes, Data.DbxSqlite, Data.FMTBcd, DBGrids,
  Datasnap.DBClient, Datasnap.Provider, Data.DB, Data.SqlExpr, DBCtrls,
  Graphics, Dialogs, Registry, Windows, JclFileUtils,
  SmartTiming.Consts, SmartTiming.Tools, DecoderInterface;


type
  TMainDataModule = class(TDataModule)
    SQLConnection: TSQLConnection;
    SQLDataSetCompetitors: TSQLDataSet;
    DataSourceCompetitors: TDataSource;
    DataSetProviderCompetitors: TDataSetProvider;
    ClientDataSetCompetitors: TClientDataSet;
    SQLDataSetRaces: TSQLDataSet;
    DataSetProviderRaces: TDataSetProvider;
    ClientDataSetRaces: TClientDataSet;
    DataSourceRaces: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FEventHistory: TStringList;
    FDatabaseName: string;

    function GetMaxIdOf(const ATableName, AColumnName: string): Integer;

  public
    procedure LoadEventHistory(AStrings: TStrings);
    procedure PushEventToHistory(const ATitle: string);
    procedure WriteEventHistory;

    function GetNewDatabaseFileName(const APath: string = cStdDataPath; const AFileName: string = cStdDatabaseName): string;
    procedure OpenDatabase(const ADatabaseName: string);
    procedure CreateNewDatabase(const APath: string = cStdDataPath; const AFileName: string = cStdDatabaseName);
    function BackupDatabase(const ATo: string): boolean;
    procedure RestoreDatabase(const AFrom: string; const ATo: string = '');

    procedure RefreshRacesDataSet(AEventId: integer);

    function GetMaxRaceId(AEventId: integer): integer;
    function GetMaxCompetitorId: integer;
    function GetMaxParticipationId: integer;

    procedure FillWithDistinctValues(const ATableName, AFieldName: string; AStrings: TStrings);
    procedure AssignCompetitorsToRace(AEventId, ARaceId: Integer; const ACompetitorIDs: TArray<integer>);
    function IsCompetitorAssignedToRace(ARaceId, ACompetitorId: Integer): Boolean;
    function GetRaceIdForPassing(APassing: TPassing): integer;
    function GetAllPassingsForRaceId(ARaceId: Integer): TArray<TPassing>;
    procedure SetRaceStatus(ARaceId: integer; ARaceStatus: TRaceStatus);

    procedure ImportTxMapping(const AFileName: string);
    procedure ExportTxMapping(const AFileName: string);
    function FillTransponderMappingCache: boolean;
    procedure SaveTransponderMappingCache;

    procedure AddPassingToDatabase(APassing: TPassing; var ARaceId: integer);

    property DatabasePathAndName: string read FDatabaseName;
  end;

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
  FEventHistory := TStringList.Create;
  FEventHistory.Sorted := false;

  SQLConnection.DriverName := 'Sqlite';
end;

{==============================================================================}
function TMainDataModule.GetNewDatabaseFileName(const APath: string = cStdDataPath; const AFileName: string = cStdDatabaseName): string;

  function CutNumberedFilename(const AFileNameOnly: string): string;
  var
    i: Integer;
  begin
    if AFileNameOnly[AFileNameOnly.Length - 4] <> '_' then
      Exit(AFileNameOnly);
    result := Copy(AFileNameOnly, 1, AFileNameOnly.Length - 5);
  end;

var
  lFileNameAndPath: string;
  lDrive, lPath, lFileName, lExt: string;
  i: integer;
begin
  lFileNameAndPath := APath;
  if not lFileNameAndPath.EndsWith('\') then
    lFileNameAndPath := lFileNameAndPath + '\';
  lFileNameAndPath := lFileNameAndPath + AFileName;

  i := 0;
  while FileExists(lFileNameAndPath) do
  begin
    Inc(i);
    PathExtractElements(lFileNameandPath, lDrive, lPath, lFileName, lExt);
    lFileName := CutNumberedFilename(lFileName);
    lFileNameandPath := Format('%s%s\%s_%.4d%s', [lDrive, lPath, lFileName, i, lExt]);
  end;
  Exit(lFileNameAndPath);
end;

{==============================================================================}
procedure TMainDataModule.OpenDatabase(const ADatabaseName: string);
begin
  FDatabaseName := ADatabaseName;
  SQLConnection.Params.Add('Database=' + ADatabaseName);
  SQLConnection.Connected := true;
end;

{==============================================================================}
procedure TMainDataModule.CreateNewDatabase(const APath: string = cStdDataPath; const AFileName: string = cStdDatabaseName);

  function GetNextCommandOfScript(var AScript: string): string;
  var
    i: Integer;
    lInQuotes: boolean;
    lInDoubleQuotes: boolean;
  begin
    AScript := AScript.Trim([#10,#13,' ']);
    if AScript.IsEmpty then
      Exit('');

    result := AScript;
    i := 0;
    lInQuotes := false;
    lInDoubleQuotes := false;
    while i < AScript.Length do
    begin
      Inc(i);
      case AScript[i] of
      '''':
        if not lInDoubleQuotes then
          lInQuotes := not lInQuotes;
      '"':
        if not lInQuotes then
          lInDoubleQuotes := not lInDoubleQuotes;
      ';':
        begin
          if lInQuotes or lInDoubleQuotes then
            Continue;

          result := Copy(AScript, 1, i);
          if i = AScript.Length then
            AScript := ''
          else
            AScript := Copy(AScript, i + 1, MAXINT);
          Exit;
        end;
      end;
    end;
    AScript := '';
  end;

var
  lScriptLines: TStringList;
  lScriptText: string;
  lCommand: string;
begin
  FDatabaseName := GetNewDatabaseFileName(APath, AFileName);
  CreateEmptyFile(FDatabaseName);
  SQLConnection.Params.Add('Database=' + FDatabaseName);
  SQLConnection.Connected := true;

  lScriptLines := TStringList.Create;
  try
    lScriptLines.LoadFromFile(cStdDataPath + cCreateSchemaScriptName);
    lScriptText := lScriptLines.Text;
    while not lScriptText.IsEmpty do
    begin
      lCommand := GetNextCommandOfScript(lScriptText);
      if not lCommand.IsEmpty then
        SQLConnection.ExecuteDirect(lCommand);
    end;
  finally
    FreeAndNil(lScriptLines);
  end;
end;

{==============================================================================}
function TMainDataModule.BackupDatabase(const ATo: string): boolean;
begin
  result := FileCopy(FDatabaseName, ATo);
end;

{==============================================================================}
procedure TMainDataModule.RestoreDatabase(const AFrom: string; const ATo: string = '');
begin
  if ATo.IsEmpty then
    FDatabaseName := GetNewDatabaseFileName
  else
    FDatabaseName := ATo;
  FileCopy(AFrom, FDatabaseName);
  OpenDatabase(FDatabaseName);
end;

{==============================================================================}
procedure TMainDataModule.DataModuleDestroy(Sender: TObject);
begin
  SQLConnection.Connected := false;
  FreeAndNil(FEventHistory);
end;

{==============================================================================}
procedure TMainDataModule.LoadEventHistory(AStrings: TStrings);
var
  lReg : TRegistry;
  lRegKey: string;
  lKeys: TStringList;
  i: integer;
  lTitle: string;
begin
  lReg := TRegistry.Create;
  try
    lReg.RootKey := HKEY_CURRENT_USER;
    lRegKey := cRegKeyPath + '\RecentlyUsed';
    if not lReg.OpenKey(lRegKey, false) then
      Exit;

    lKeys := TStringList.Create;
    try
      lReg.GetKeyNames(lKeys);
      for i := 0 to lKeys.Count - 1 do
      begin
        lReg.CloseKey;
        if not lReg.OpenKey(lRegKey + '\' + lKeys[i], false) then
          Continue;
        lTitle := lReg.ReadString('Title');
        AStrings.AddPair(lReg.ReadString('Path'), lTitle);
      end;
    finally
      FEventHistory.AddStrings(AStrings);
      FreeAndNil(lKeys);
    end;
  finally
    FreeAndNil(lReg);
  end;
end;

{==============================================================================}
procedure TMainDataModule.PushEventToHistory(const ATitle: string);
var
  lPos: integer;
  lTempList: TStringList;
begin
  lPos := FEventHistory.IndexOfName(FDatabaseName);
  if lPos >= 0 then
    FEventHistory.Delete(lPos);
  lTempList := TStringList.Create;
  try
    lTempList.AddPair(FDatabaseName, ATitle);
    lTempList.AddStrings(FEventHistory);
  finally
    FreeAndNil(FEventHistory);
    FEventHistory := lTempList;
  end;
end;

{==============================================================================}
procedure TMainDataModule.WriteEventHistory;
var
  lReg : TRegistry;
  lRegKey: string;
  i: integer;
begin
  lReg := TRegistry.Create;
  try
    lReg.RootKey := HKEY_CURRENT_USER;
    lRegKey := cRegKeyPath + '\RecentlyUsed';
    if not lReg.OpenKey(lRegKey, true) then
      Exit;

    for i := 0 to FEventHistory.Count - 1 do
    begin
      if i >= 20 then
        Exit;
      lReg.CloseKey;
      if not lReg.OpenKey(Format('%s\#%.2d', [lRegKey, i]), true) then
        Continue;
      lReg.WriteString('Path', FEventHistory.Names[i]);
      lReg.WriteString('Title', FEventHistory.ValueFromIndex[i]);
    end;
  finally
    FreeAndNil(lReg);
  end;
end;

{==============================================================================}
procedure TMainDataModule.RefreshRacesDataSet(AEventId: integer);
begin
  ClientDataSetRaces.Active := false;
  SQLDataSetRaces.Active := false;
  SQLDataSetRaces.CommandText := 'SELECT * FROM RACES WHERE EVENTID = ' + AEventId.ToString;
  SQLDataSetRaces.Active := true;
  ClientDataSetRaces.Active := True;
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
function TMainDataModule.GetAllPassingsForRaceId(ARaceId: Integer): TArray<TPassing>;
var
  lResultSet: TDataSet;
  i: integer;
begin
  SQLConnection.Execute(Format(
    '', [ARaceId]), nil, lResultSet);
  try
    if lResultSet.IsEmpty then
      Exit(nil);

    i := 0;
    lResultSet.First;
    while not lResultSet.Eof do
    begin
      raise Exception.Create('Not implemented yet.');
      Inc(i);
      lResultSet.Next;
    end;
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
procedure TMainDataModule.AddPassingToDatabase(APassing: TPassing; var ARaceId: integer);
var
  lCmd: string;
  lTimeStr: string;
begin
  if APassing.Flags <> 2 then
  begin
    ARaceId := GetRaceIdForPassing(APassing);
    APassing.RaceId := ARaceId;
  end;

  lTimeStr := FormatDatetime('yyyy-mm-dd hh:mm:ss.zzz', APassing.PassingTime).QuotedString;
  lCmd :=
        Format('INSERT INTO PASSINGS ' +
           '(PASSINGNUMBER, TRANSPONDERID, PASSINGTIME, SIGNALSTRENGTH, HITS, FLAGS, SPORT, DECODERID, RACEID) VALUES ' +
           '(%d, %s, %s, %d, %d, %d, %d, %s, %d)',
           [APassing.PassingNumber, APassing.ChipId.QuotedString, lTimeStr, APassing.SignalStrength, APassing.Hits, APassing.Flags, APassing.Sport, APassing.DecoderId.QuotedString,
            APassing.RaceId]);
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
function TMainDataModule.FillTransponderMappingCache: boolean;
var
  lResultSet: TDataSet;
begin
  TTransponderMappingStore.GetSingleton.Clear;
  result := false;

  SQLConnection.Execute('SELECT SHORTID, CHIPID FROM TRANSPONDERS ORDER BY SHORTID', nil, lResultSet);
  try
    if lResultSet.IsEmpty or (lResultSet.RecordCount < 1) then
      Exit;

    result := true;
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

{==============================================================================}
procedure TMainDataModule.SaveTransponderMappingCache;
var
  lMappingStore: TTransponderMappingStore;
  lCmd: string;
  lShortId: integer;
  lTxId: string;
begin
  lMappingStore := TTransponderMappingStore.GetSingleton;
  lMappingStore.Lock;
  try
    SQLConnection.Execute('DELETE FROM TRANSPONDERS', nil);

    for lShortId in lMappingStore.ShortIdToTxId.Keys do
    begin
      if not lMappingStore.ShortIdToTxId.TryGetValue(lShortId, lTxId) then
        Continue;

      lCmd := Format('INSERT INTO TRANSPONDERS (SHORTID, CHIPID, LOWBATTERYSTATUS, FIRSTLOWBATTERYTIME) VALUES (%d, %s, 0, NULL)', [lShortId, QuotedStr(lTxId)]);
      SQLConnection.Execute(lCmd, nil);
    end;
  finally
    lMappingStore.Unlock;
  end;
end;

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
