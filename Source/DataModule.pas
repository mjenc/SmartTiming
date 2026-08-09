unit DataModule;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, Data.DbxSqlite, Data.FMTBcd, DBGrids,
  Datasnap.DBClient, Datasnap.Provider, Data.DB, Data.SqlExpr, DBCtrls,
  Graphics, Dialogs, Registry, Windows, JclFileUtils, Variants,
  SmartTiming.Consts, SmartTiming.Tools, DecoderInterface, DateUtils,
  StrUtils;

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
    DataSourceResults: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FEventHistory: TStringList;
    FDatabaseName: string;

    function GetMinIdOf(const ATableName, AColumnName: string): Integer;
    function GetMaxIdOf(const ATableName, AColumnName: string): Integer;
    function GetSQLValueFromVariant(AValue: Variant): string;
  public
    procedure LoadEventHistory(AStrings: TStrings);
    procedure PushEventToHistory(const ATitle: string);
    procedure WriteEventHistory;

    function GetNewDatabaseFileName(const APath: string; const AFileName: string): string;
    procedure OpenDatabase(const ADatabaseName: string);
    procedure CreateNewDatabase(const APath: string; const AFileName: string);
    function BackupDatabase(const ATo: string): boolean;
    procedure RestoreDatabase(const AFrom: string; const ATo: string = '');

    procedure FillReadOnlyDataSetForSQL(const ASQL: string; var ADataSet: TSQLDataSet);
    procedure RefreshRacesDataSet(AEventId: integer);

    function GetMaxRaceId(AEventId: integer): integer;
    function GetMaxCompetitorId: integer;
    function GetMaxParticipationId: integer;
    function GetMaxTransponderAssignmentId: integer;
    function InsertOpenTransponderAssignment(ARaceId, ACompetitorId: Integer;
      const AChipId: string; AValidFrom: TDateTime): Integer;
    procedure CreateTransponderAssignmentFromCompetitorChip(ARaceId, ACompetitorId: Integer);
    procedure CloseTransponderAssignmentsForCompetitors(ARaceId: Integer; const ACompetitorIDs: TArray<integer>);
    procedure CloseAllOpenTransponderAssignmentsForRace(ARaceId: Integer);
    function GetRaceIdsForCompetitor(ACompetitorId: Integer): TArray<Integer>;
    function GetRaceStatus(ARaceId: Integer): TRaceStatus;
    function GetRaceTitle(ARaceId: Integer): string;
    function GetCompetitorChipId(ACompetitorId: Integer): string;
    procedure SetCompetitorChipId(ACompetitorId: Integer; const AChipId: string);
    function GetCompetitorDisplayName(ACompetitorId: Integer): string;
    function GetCompetitorIdsForRace(ARaceId: Integer): TArray<Integer>;
    function GetMaxPassingNumber: integer;
    function GetMinPassingNumber: integer;

    procedure FillWithDistinctValues(const ATableName, AFieldName: string; AStrings: TStrings);

    procedure AssignCompetitorsToRace(AEventId, ARaceId: Integer; const ACompetitorIDs: TArray<integer>);
    procedure RemoveCompetitorsFromRace(AEventId, ARaceId: Integer; const ACompetitorIDs: TArray<integer>);
    procedure RemoveCompetitors(AEventId: Integer; const ACompetitorIDs: TArray<Integer>);
    function IsCompetitorAssignedToRace(ARaceId, ACompetitorId: Integer): Boolean;
    function GetCompetitorID(ARaceId: integer; AChipId: string; APassingTime: TDateTime = 0): integer;
    function GetRaceIdForPassing(APassing: TPassing; var ACompetitorId: integer): integer;
    function GetAllPassingsForRaceId(ARaceId: Integer; AOnlyActive: boolean = false): TArray<TPassing>;
    function GetUnassignedPassings: TArray<TPassing>;
    procedure SetRaceStatus(ARaceId: integer; ARaceStatus: TRaceStatus);
    procedure GetCompetitorInfoForPassing(APassing: TPassing; var ABIB: integer; var AName, AClubTeam: string);
    function GetActiveTransponderIdForBib(ABib: integer; APreferredRaceId: Integer = -1): string;

    procedure SetParticipantState(ARaceId: Integer; ACompetitorIDs: TArray<Integer>; AParticipantState: TParticipantState);

    procedure ResetRaceParticitipations(ARaceId: Integer);
    function GetNumberOfLapsForParticipant(ARaceId: integer; const AChipId: string;
      APassingTime: TDateTime; var AParticipationId: integer; var AStartTime: TDatetime): integer;
    procedure UpdateParticipationValues(AParticipationId: integer; const AFields: TArray<string>; const AValues: TArray<Variant>);

    function ImportTxMapping(const AFileName: string): integer;
    procedure ExportTxMapping(const AFileName: string);
    function FillTransponderMappingCache: Integer;
    procedure SaveTransponderMappingCache;
    function FillTransponderAssignmentCache: Integer;

    procedure AddPassingToDatabase(APassing: TPassing; var ARaceId: integer);
    procedure UpdatePassingInDatabase(APassingNumber: Integer; APassingTime: TDatetime; APassingState: TPassingState);
    procedure UpdatePassingRaceIdInDatabase(APassingNumber: Integer; ARaceId: Integer);
    procedure RemovePassingFromDatabase(APassingNumber: Integer);

    class function GetJSONFromDataSet(ADataSet: TDataSet; const AFieldTitles: string): string;
    property DatabasePathAndName: string read FDatabaseName;
  end;

var
  MainDataModule: TMainDataModule;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  SmartTiming.Cache, Tools.SuperObject, SmartTiming.Controller, FormMain,
  SmartTiming.TransponderAssignment, Tools.Logger;

{==============================================================================}
procedure TMainDataModule.DataModuleCreate(Sender: TObject);
begin
  FEventHistory := TStringList.Create;
  FEventHistory.Sorted := false;

  SQLConnection.DriverName := 'Sqlite';
end;

{==============================================================================}
function TMainDataModule.GetNewDatabaseFileName(const APath: string; const AFileName: string): string;

  function CutNumberedFilename(const AFileNameOnly: string): string;
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
procedure TMainDataModule.CreateNewDatabase(const APath: string; const AFileName: string);

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
    lScriptLines.LoadFromFile(gStdDataPath + cCreateSchemaScriptName);
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
    FDatabaseName := GetNewDatabaseFileName(gStdDataPath, cStdDatabaseName)
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
procedure TMainDataModule.FillReadOnlyDataSetForSQL(const ASQL: string; var ADataSet: TSQLDataSet);
begin
  if ADataSet = nil then
    ADataSet := TSQLDataSet.Create(nil);
  ADataSet.SQLConnection := SQLConnection;
  ADataSet.CommandText := ASQL;
  ADataSet.CommandType := ctQuery;
  ADataSet.Active := true;
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
function TMainDataModule.GetMaxTransponderAssignmentId: integer;
begin
  result := GetMaxIdOf('TRANSPONDERASSIGNMENTS', 'ASSIGNMENTID');
end;

{==============================================================================}
{==============================================================================}
function TMainDataModule.InsertOpenTransponderAssignment(ARaceId, ACompetitorId: Integer;
  const AChipId: string; AValidFrom: TDateTime): Integer;
var
  lValidFrom: string;
  lCmd: string;
begin
  Result := GetMaxTransponderAssignmentId + 1;
  lValidFrom := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', AValidFrom).QuotedString;
  lCmd := Format(
    'INSERT INTO TRANSPONDERASSIGNMENTS ' +
    '(ASSIGNMENTID, CHIPID, COMPETITORID, VALIDFROM, VALIDTO, RACEID) VALUES ' +
    '(%d, %s, %d, %s, NULL, %d)',
    [Result, QuotedStr(AChipId), ACompetitorId, lValidFrom, ARaceId]);
  SQLConnection.Execute(lCmd, nil);
end;

{==============================================================================}
procedure TMainDataModule.CreateTransponderAssignmentFromCompetitorChip(ARaceId, ACompetitorId: Integer);
begin
  TTransponderAssignmentService.AssignFromCompetitorChip(ARaceId, ACompetitorId);
end;

{==============================================================================}
function TMainDataModule.GetRaceStatus(ARaceId: Integer): TRaceStatus;
var
  lResultSet: TCustomSQLDataSet;
begin
  Result := rsNotStarted;
  SQLConnection.Execute(
    Format('SELECT STATUS FROM RACES WHERE RACEID = %d', [ARaceId]),
    nil, lResultSet);
  try
    if (lResultSet <> nil) and not lResultSet.Eof then
      Result := TRaceStatus(lResultSet.FieldByName('STATUS').AsInteger);
  finally
    FreeAndNil(lResultSet);
  end;
end;

{==============================================================================}
function TMainDataModule.GetRaceTitle(ARaceId: Integer): string;
var
  lResultSet: TCustomSQLDataSet;
begin
  Result := ARaceId.ToString;
  SQLConnection.Execute(
    Format('SELECT TITLE FROM RACES WHERE RACEID = %d', [ARaceId]),
    nil, lResultSet);
  try
    if (lResultSet <> nil) and not lResultSet.Eof then
      Result := lResultSet.FieldByName('TITLE').AsString;
  finally
    FreeAndNil(lResultSet);
  end;
end;

{==============================================================================}
function TMainDataModule.GetCompetitorChipId(ACompetitorId: Integer): string;
var
  lResultSet: TCustomSQLDataSet;
begin
  Result := '';
  SQLConnection.Execute(
    Format('SELECT CHIPID FROM COMPETITORS WHERE COMPETITORID = %d', [ACompetitorId]),
    nil, lResultSet);
  try
    if (lResultSet <> nil) and not lResultSet.Eof then
      Result := Trim(lResultSet.FieldByName('CHIPID').AsString);
  finally
    FreeAndNil(lResultSet);
  end;
end;

{==============================================================================}
procedure TMainDataModule.SetCompetitorChipId(ACompetitorId: Integer; const AChipId: string);
var
  lCmd: string;
begin
  if AChipId = '' then
    lCmd := Format('UPDATE COMPETITORS SET CHIPID = NULL WHERE COMPETITORID = %d', [ACompetitorId])
  else
    lCmd := Format('UPDATE COMPETITORS SET CHIPID = %s WHERE COMPETITORID = %d',
      [QuotedStr(AChipId), ACompetitorId]);
  SQLConnection.Execute(lCmd, nil);
end;

{==============================================================================}
function TMainDataModule.GetCompetitorDisplayName(ACompetitorId: Integer): string;
var
  lResultSet: TCustomSQLDataSet;
  lBib: Integer;
  lName: string;
begin
  Result := ACompetitorId.ToString;
  SQLConnection.Execute(
    Format('SELECT BIB, LASTNAME, FIRSTNAME FROM COMPETITORS WHERE COMPETITORID = %d',
      [ACompetitorId]),
    nil, lResultSet);
  try
    if (lResultSet = nil) or lResultSet.Eof then
      Exit;
    lBib := lResultSet.FieldByName('BIB').AsInteger;
    lName := Trim(lResultSet.FieldByName('LASTNAME').AsString + ', ' +
      lResultSet.FieldByName('FIRSTNAME').AsString);
    if lName = ',' then
      lName := '';
    if lName <> '' then
      Result := Format('#%d %s', [lBib, lName])
    else
      Result := Format('#%d', [lBib]);
  finally
    FreeAndNil(lResultSet);
  end;
end;

{==============================================================================}
function TMainDataModule.GetCompetitorIdsForRace(ARaceId: Integer): TArray<Integer>;
var
  lResultSet: TCustomSQLDataSet;
  lList: TList<Integer>;
begin
  SetLength(Result, 0);
  lList := TList<Integer>.Create;
  try
    SQLConnection.Execute(
      Format('SELECT COMPETITORID FROM PARTICIPATION WHERE RACEID = %d ORDER BY COMPETITORID',
        [ARaceId]),
      nil, lResultSet);
    try
      if lResultSet = nil then
        Exit;
      while not lResultSet.Eof do
      begin
        lList.Add(lResultSet.FieldByName('COMPETITORID').AsInteger);
        lResultSet.Next;
      end;
    finally
      FreeAndNil(lResultSet);
    end;
    Result := lList.ToArray;
  finally
    FreeAndNil(lList);
  end;
end;

{==============================================================================}
procedure TMainDataModule.CloseTransponderAssignmentsForCompetitors(ARaceId: Integer;
  const ACompetitorIDs: TArray<integer>);
var
  i: Integer;
  lIDs: TStringList;
  lCmd: string;
  lValidToDt: TDateTime;
  lValidTo: string;
begin
  if Length(ACompetitorIDs) = 0 then
    Exit;

  lIDs := TStringList.Create;
  try
    for i := 0 to High(ACompetitorIDs) do
      lIDs.Add(ACompetitorIDs[i].ToString);
    lValidToDt := Now;
    lValidTo := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', lValidToDt).QuotedString;
    lCmd := Format(
      'UPDATE TRANSPONDERASSIGNMENTS SET VALIDTO = %s ' +
      'WHERE RACEID = %d AND COMPETITORID IN (%s) AND VALIDTO IS NULL',
      [lValidTo, ARaceId, lIDs.CommaText]);
    SQLConnection.Execute(lCmd, nil);
    TTransponderAssignmentStore.GetSingleton.CloseAssignmentsForCompetitors(
      ARaceId, ACompetitorIDs, lValidToDt);
  finally
    FreeAndNil(lIDs);
  end;
end;

{==============================================================================}
procedure TMainDataModule.CloseAllOpenTransponderAssignmentsForRace(ARaceId: Integer);
var
  lValidToDt: TDateTime;
  lValidTo: string;
begin
  lValidToDt := Now;
  lValidTo := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', lValidToDt).QuotedString;
  SQLConnection.Execute(Format(
    'UPDATE TRANSPONDERASSIGNMENTS SET VALIDTO = %s ' +
    'WHERE RACEID = %d AND VALIDTO IS NULL',
    [lValidTo, ARaceId]), nil);
  TTransponderAssignmentStore.GetSingleton.CloseAllOpenForRace(ARaceId, lValidToDt);
end;

{==============================================================================}
function TMainDataModule.GetRaceIdsForCompetitor(ACompetitorId: Integer): TArray<Integer>;
var
  lResultSet: TDataSet;
  lList: TList<Integer>;
begin
  lList := TList<Integer>.Create;
  try
    SQLConnection.Execute(
      Format('SELECT RACEID FROM PARTICIPATION WHERE COMPETITORID = %d ORDER BY RACEID',
        [ACompetitorId]),
      nil, lResultSet);
    try
      if lResultSet = nil then
        Exit(nil);
      while not lResultSet.Eof do
      begin
        lList.Add(lResultSet.FieldByName('RACEID').AsInteger);
        lResultSet.Next;
      end;
    finally
      FreeAndNil(lResultSet);
    end;
    Result := lList.ToArray;
  finally
    FreeAndNil(lList);
  end;
end;

{==============================================================================}
function TMainDataModule.GetMinPassingNumber: integer;
begin
  result := GetMinIdOf('PASSINGS', 'PASSINGNUMBER');
end;

{==============================================================================}
function TMainDataModule.GetMaxPassingNumber: integer;
begin
  result := GetMaxIdOf('PASSINGS', 'PASSINGNUMBER');
end;

{==============================================================================}
function TMainDataModule.GetMaxCompetitorId: integer;
begin
  result := GetMaxIdOf('COMPETITORS', 'COMPETITORID');
end;

{==============================================================================}
function TMainDataModule.GetMinIdOf(const ATableName, AColumnName: string): Integer;
var
  lResultSet: TDataSet;
begin
  SQLConnection.Execute('SELECT MIN(' + AColumnName + ') FROM ' + ATableName, nil, lResultSet);
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
function TMainDataModule.GetCompetitorID(ARaceId: integer; AChipId: string;
  APassingTime: TDateTime): integer;
var
  lTime: TDateTime;
begin
  if APassingTime = 0 then
    lTime := Now
  else
    lTime := APassingTime;
  if TTransponderAssignmentService.TryGetCompetitorForRaceChipAtTime(ARaceId, AChipId, lTime, Result) then
    Exit;
  Result := -1;
end;

{==============================================================================}
function TMainDataModule.GetRaceIdForPassing(APassing: TPassing; var ACompetitorId: integer): integer;
var
  lResolution: TPassingAssignmentResolution;
begin
  ACompetitorId := -1;
  Result := -1;

  if not TTransponderAssignmentService.ResolvePassing(APassing.ChipId, APassing.PassingTime, lResolution) then
  begin
    if lResolution.IsAmbiguous then
      LogOnWarn('SmartTiming.Passing', [
        Format(cMessagesPassingAmbiguousAssignment,
          [APassing.ChipId, FormatDateTime('hh:nn:ss.zzz', APassing.PassingTime),
           lResolution.MatchCount])]);
    Exit;
  end;

  ACompetitorId := lResolution.CompetitorId;
  Result := lResolution.RaceId;
end;

{==============================================================================}
function TMainDataModule.GetActiveTransponderIdForBib(ABib: integer;
  APreferredRaceId: Integer): string;
var
  lResultSet: TDataSet;
  lRaceId: Integer;
  lCompetitorId: Integer;
  lAssignment: TTransponderAssignment;
  lStatusList: string;
  lStatus: TRaceStatus;
  lChipId: string;
  lFallback: string;
begin
  Result := '';
  lFallback := '';
  lStatusList := '';
  for lStatus in cRaceStatusesAcceptingPassings do
  begin
    if lStatusList <> '' then
      lStatusList := lStatusList + ',';
    lStatusList := lStatusList + Ord(lStatus).ToString;
  end;

  SQLConnection.Execute(Format(
    'SELECT P.RACEID, P.COMPETITORID, C.CHIPID FROM ' +
    'COMPETITORS C INNER JOIN PARTICIPATION P ON C.COMPETITORID = P.COMPETITORID ' +
    'INNER JOIN RACES R ON P.RACEID = R.RACEID ' +
    'WHERE R.STATUS IN (%s) AND C.BIB = %d',
    [lStatusList, ABib]), nil, lResultSet);
  try
    if (lResultSet = nil) or lResultSet.IsEmpty then
      Exit;
    lResultSet.First;
    while not lResultSet.Eof do
    begin
      lRaceId := lResultSet.FieldByName('RACEID').AsInteger;
      lCompetitorId := lResultSet.FieldByName('COMPETITORID').AsInteger;
      if TTransponderAssignmentStore.GetSingleton.TryGetActiveByRaceAndCompetitor(
           lRaceId, lCompetitorId, lAssignment) then
        lChipId := lAssignment.ChipId
      else
        lChipId := Trim(lResultSet.FieldByName('CHIPID').AsString);

      if lChipId <> '' then
      begin
        if (APreferredRaceId >= 0) and (lRaceId = APreferredRaceId) then
          Exit(lChipId);
        if lFallback = '' then
          lFallback := lChipId;
      end;
      lResultSet.Next;
    end;
    Result := lFallback;
  finally
    FreeAndNil(lResultSet);
  end;
end;

{==============================================================================}
function TMainDataModule.GetAllPassingsForRaceId(ARaceId: Integer; AOnlyActive: boolean = false): TArray<TPassing>;
var
  lOnlyActive: string;
  lResultSet: TDataSet;
  i: integer;
begin
  if AOnlyActive then
    lOnlyActive := 'AND PASSINGSTATUS = ' + Ord(psValid).ToString;

  SQLConnection.Execute(Format(
    'SELECT * FROM PASSINGS WHERE RACEID = %d %s ORDER BY PASSINGTIME', [ARaceId, lOnlyActive]), nil, lResultSet);
  try
    if lResultSet.IsEmpty then
      Exit(nil);

    SetLength(result, lResultSet.RecordCount);
    i := 0;
    lResultSet.First;
    while not lResultSet.Eof do
    begin
      result[i].PassingNumber := lResultSet.FieldByName('PASSINGNUMBER').AsInteger;
      result[i].ChipId := lResultSet.FieldByName('CHIPID').AsString;
      result[i].PassingTime := SmartTimingTools.GetFieldAsDatetime(lResultSet.FieldByName('PASSINGTIME'), 0.0);
      result[i].SignalStrength := lResultSet.FieldByName('SIGNALSTRENGTH').AsInteger;
      result[i].Hits := lResultSet.FieldByName('HITS').AsInteger;
      result[i].Flags := lResultSet.FieldByName('FLAGS').AsInteger;
      result[i].Sport := lResultSet.FieldByName('SPORT').AsInteger;
      result[i].Voltage := 0;
      result[i].Temperature := 0;
      result[i].DecoderId := lResultSet.FieldByName('DECODERID').AsString;
      result[i].TxId := TTransponderMappingStore.GetSingleton.GetShortIdFromTransponderId(result[i].ChipId);
      result[i].RaceId := ARaceId;
      Inc(i);
      lResultSet.Next;
    end;
  finally
    FreeAndNil(lResultSet);
  end;
end;

{==============================================================================}
function TMainDataModule.GetUnassignedPassings: TArray<TPassing>;
var
  lResultSet: TDataSet;
  i: Integer;
begin
  SetLength(Result, 0);
  SQLConnection.Execute(
    'SELECT * FROM PASSINGS WHERE RACEID < 0 AND IFNULL(FLAGS, 0) <> 2 ' +
    'ORDER BY PASSINGTIME, PASSINGNUMBER',
    nil, lResultSet);
  try
    if (lResultSet = nil) or lResultSet.IsEmpty then
      Exit;

    SetLength(Result, lResultSet.RecordCount);
    i := 0;
    lResultSet.First;
    while not lResultSet.Eof do
    begin
      Result[i].PassingNumber := lResultSet.FieldByName('PASSINGNUMBER').AsInteger;
      Result[i].ChipId := lResultSet.FieldByName('CHIPID').AsString;
      Result[i].PassingTime := SmartTimingTools.GetFieldAsDatetime(lResultSet.FieldByName('PASSINGTIME'), 0.0);
      Result[i].SignalStrength := lResultSet.FieldByName('SIGNALSTRENGTH').AsInteger;
      Result[i].Hits := lResultSet.FieldByName('HITS').AsInteger;
      Result[i].Flags := lResultSet.FieldByName('FLAGS').AsInteger;
      Result[i].Sport := lResultSet.FieldByName('SPORT').AsInteger;
      Result[i].Voltage := 0;
      Result[i].Temperature := 0;
      Result[i].DecoderId := lResultSet.FieldByName('DECODERID').AsString;
      Result[i].TxId := TTransponderMappingStore.GetSingleton.GetShortIdFromTransponderId(Result[i].ChipId);
      Result[i].RaceId := lResultSet.FieldByName('RACEID').AsInteger;
      Inc(i);
      lResultSet.Next;
    end;
  finally
    FreeAndNil(lResultSet);
  end;
end;

{==============================================================================}
procedure TMainDataModule.GetCompetitorInfoForPassing(APassing: TPassing; var ABIB: integer; var AName, AClubTeam: string);
var
  lResultSet: TDataSet;
  lField: TField;
  lCompetitorId: Integer;
begin
  ABIB := 0;
  AName := '?';
  AClubTeam := '?';

  if not TTransponderAssignmentService.TryGetCompetitorForRaceChipAtTime(
       APassing.RaceId, APassing.ChipId, APassing.PassingTime, lCompetitorId) then
    Exit;

  SQLConnection.Execute(
    Format(
      'SELECT C.BIB, C.LASTNAME, C.FIRSTNAME, C.CLUB, C.TEAM FROM COMPETITORS C ' +
      'WHERE C.COMPETITORID = %d',
      [lCompetitorId]),
    nil, lResultSet);
  try
    if (lResultSet = nil) or lResultSet.IsEmpty then
      Exit;
    lResultSet.First;
    ABIB := lResultSet.FieldByName('BIB').AsInteger;
    lField := lResultSet.FieldByName('LASTNAME');
    if not lField.IsNull then
      AName := lField.AsString;
    AName := AName + ', ';
    lField := lResultSet.FieldByName('FIRSTNAME');
    if lField.IsNull then
      AName := AName + '?'
    else
      AName := AName + lField.AsString;
    lField := lResultSet.FieldByName('TEAM');
    if lField.IsNull or lField.AsString.IsEmpty then
    begin
      lField := lResultSet.FieldByName('CLUB');
      if not lField.IsNull then
        AClubTeam := lField.AsString;
    end
    else
      AClubTeam := lField.AsString;
  finally
    FreeAndNil(lResultSet);
  end;
end;

{==============================================================================}
procedure TMainDataModule.ResetRaceParticitipations(ARaceId: Integer);
begin
  SQLConnection.ExecuteDirect('UPDATE PARTICIPATION SET LAPS = 0, RANKINGTIME = NULL, FINISHTIME = NULL, CURRENTRANKING = NULL, POINTS = 0, CRITRANKINGVALUE = NULL WHERE RACEID = ' + ARaceId.ToString);
end;

{==============================================================================}
function TMainDataModule.GetNumberOfLapsForParticipant(ARaceId: integer; const AChipId: string;
  APassingTime: TDateTime; var AParticipationId: integer; var AStartTime: TDatetime): integer;
var
  lResultSet: TDataSet;
  lCompetitorId: Integer;
begin
  Result := 0;
  AParticipationId := -1;

  if not TTransponderAssignmentService.TryGetCompetitorForRaceChipAtTime(
       ARaceId, AChipId, APassingTime, lCompetitorId) then
    Exit;

  SQLConnection.Execute(Format(
    'SELECT LAPS, PARTICIPATIONID, P.STARTTIME FROM PARTICIPATION P ' +
    'WHERE P.RACEID = %d AND P.COMPETITORID = %d',
    [ARaceId, lCompetitorId]), nil, lResultSet);
  try
    if (lResultSet = nil) or lResultSet.IsEmpty then
      Exit;

    lResultSet.First;
    if lResultSet.Eof then
      Exit;

    if lResultSet.Fields[0].IsNull then
      Result := 0
    else
      Result := lResultSet.Fields[0].AsInteger;
    if not lResultSet.Fields[1].IsNull then
      AParticipationId := lResultSet.Fields[1].AsInteger;
    AStartTime := SmartTimingTools.FieldAsDatetime(lResultSet.Fields[2]);
  finally
    FreeAndNil(lResultSet);
  end;
end;

{==============================================================================}
function TMainDataModule.GetSQLValueFromVariant(AValue: Variant): string;
begin
  case VarType(AValue) of
  varNull, varEmpty:
    result := 'NULL';
  varDate:
    result := FormatDatetime('yyyy-mm-dd hh:mm:ss.zzz', AValue).QuotedString;
  else
    result := VarToStr(AValue).QuotedString;
  end;

end;

{==============================================================================}
procedure TMainDataModule.UpdateParticipationValues(AParticipationId: integer; const AFields: TArray<string>; const AValues: TArray<Variant>);
var
  i: integer;
  lCmd: string;
begin
  if length(AFields) = 0 then
    Exit;

  lCmd := 'UPDATE PARTICIPATION SET ';
  for i := 0 to High(AFields) do
  begin
    lCmd := lCmd +
      AFields[i] + ' = ' + GetSQLValueFromVariant(AValues[i]) + ',';
  end;
  lCmd[Length(lCmd)] := ' ';
  lCmd := lCmd + ' WHERE PARTICIPATIONID = ' + AParticipationId.ToString;
  MainDataModule.SQLConnection.Execute(lCmd, nil);
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
    lCmd := Format(
      'INSERT INTO PARTICIPATION (PARTICIPATIONID, RACEID, COMPETITORID, STARTTIME) ' +
      'SELECT %d, %d, COMPETITORID, STARTTIME FROM COMPETITORS WHERE COMPETITORID = %d',
      [lParticipationId, ARaceId, ACompetitorIDs[i]]);
    SQLConnection.Execute(lCmd, nil);
    CreateTransponderAssignmentFromCompetitorChip(ARaceId, ACompetitorIDs[i]);
    Inc(lParticipationId);
  end;
end;

{==============================================================================}
procedure TMainDataModule.RemoveCompetitorsFromRace(AEventId, ARaceId: Integer; const ACompetitorIDs: TArray<integer>);
var
  lCmd: string;
  i: integer;
  lIDs: TStringList;
begin
  if Length(ACompetitorIDs) = 0 then
    Exit;

  CloseTransponderAssignmentsForCompetitors(ARaceId, ACompetitorIDs);

  lIDs := TStringList.Create;
  try
    for i := 0 to High(ACompetitorIDs) do
      lIDs.Add(ACompetitorIDs[i].ToString);
    lCmd := Format('DELETE FROM PARTICIPATION WHERE RACEID = %d AND COMPETITORID IN (%s)', [ARaceId, lIDs.CommaText]);
  finally
    FreeAndNil(lIDs);
  end;
  SQLConnection.Execute(lCmd, nil);
end;

{==============================================================================}
procedure TMainDataModule.SetParticipantState(ARaceId: Integer; ACompetitorIDs: TArray<Integer>; AParticipantState: TParticipantState);
var
  lCmd: string;
  i: integer;
  lIDs: TStringList;
  lSet: String;
begin
  if Length(ACompetitorIDs) = 0 then
    Exit;

  case AParticipantState of
  psActive:
    lSet := 'DNS = 0,DNF = 0,DSQ = 0';
  psDNS:
    lSet := 'DNS = 1,DNF = 0,DSQ = 0';
  psDNF:
    lSet := 'DNS = 0,DNF = 1,DSQ = 0';
  psDSQ:
    lSet := 'DNS = 0,DNF = 0,DSQ = 1';
  else
    Exit;
  end;

  lIDs := TStringList.Create;
  try
    for i := 0 to High(ACompetitorIDs) do
      lIDs.Add(ACompetitorIDs[i].ToString);
    lCmd := Format('UPDATE PARTICIPATION SET %s WHERE RACEID = %d AND COMPETITORID IN (%s)', [lSet, ARaceId, lIDs.CommaText]);
  finally
    FreeAndNil(lIDs);
  end;
  SQLConnection.Execute(lCmd, nil);
end;

{==============================================================================}
procedure TMainDataModule.RemoveCompetitors(AEventId: Integer; const ACompetitorIDs: TArray<Integer>);
var
  lCmd: string;
  i: integer;
  lIDs: TStringList;
begin
  if Length(ACompetitorIDs) = 0 then
    Exit;

  lIDs := TStringList.Create;
  try
    for i := 0 to High(ACompetitorIDs) do
      lIDs.Add(ACompetitorIDs[i].ToString);
    lCmd := Format(
      'UPDATE TRANSPONDERASSIGNMENTS SET VALIDTO = %s ' +
      'WHERE COMPETITORID IN (%s) AND VALIDTO IS NULL',
      [FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now).QuotedString, lIDs.CommaText]);
    SQLConnection.Execute(lCmd, nil);
    lCmd := Format('DELETE FROM PARTICIPATION WHERE COMPETITORID IN (%s)', [lIDs.CommaText]);
    SQLConnection.Execute(lCmd, nil);
    lCmd := Format('DELETE FROM TEAMMEMBERS WHERE COMPETITORID IN (%s)', [lIDs.CommaText]);
    SQLConnection.Execute(lCmd, nil);
    lCmd := Format('DELETE FROM COMPETITORS WHERE COMPETITORID IN (%s)', [lIDs.CommaText]);
    SQLConnection.Execute(lCmd, nil);
  finally
    FreeAndNil(lIDs);
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
  lCompetitorId: integer;
begin
  if APassing.Flags <> 2 then
  begin
    ARaceId := GetRaceIdForPassing(APassing, lCompetitorId);
    APassing.RaceId := ARaceId;
  end;

  lTimeStr := FormatDatetime('yyyy-mm-dd hh:mm:ss.zzz', APassing.PassingTime).QuotedString;
  lCmd :=
    Format('INSERT INTO PASSINGS ' +
           '(PASSINGNUMBER, CHIPID, PASSINGTIME, SIGNALSTRENGTH, HITS, FLAGS, SPORT, DECODERID, RACEID) VALUES ' +
           '(%d, %s, %s, %d, %d, %d, %d, %s, %d)',
           [APassing.PassingNumber, APassing.ChipId.QuotedString, lTimeStr, APassing.SignalStrength, APassing.Hits, APassing.Flags, APassing.Sport, APassing.DecoderId.QuotedString,
            APassing.RaceId]);
  SQLConnection.Execute(lCmd, nil);
end;

{==============================================================================}
procedure TMainDataModule.UpdatePassingInDatabase(APassingNumber: Integer; APassingTime: TDatetime; APassingState: TPassingState);
var
  lCmd: string;
  lTimeStr: string;
begin
  lTimeStr := FormatDatetime('yyyy-mm-dd hh:mm:ss.zzz', APassingTime).QuotedString;
  lCmd :=
    Format('UPDATE PASSINGS SET PASSINGTIME = %s, PASSINGSTATUS = %d WHERE PASSINGNUMBER = %d',
           [lTimeStr, Ord(APassingState), APassingNumber]);
  SQLConnection.Execute(lCmd, nil);
end;

{==============================================================================}
procedure TMainDataModule.UpdatePassingRaceIdInDatabase(APassingNumber: Integer; ARaceId: Integer);
begin
  SQLConnection.Execute(
    Format('UPDATE PASSINGS SET RACEID = %d WHERE PASSINGNUMBER = %d',
      [ARaceId, APassingNumber]), nil);
end;

{==============================================================================}
procedure TMainDataModule.RemovePassingFromDatabase(APassingNumber: Integer);
var
  lCmd: string;
begin
  lCmd := Format('DELETE FROM PASSINGS WHERE PASSINGNUMBER = %d', [APassingNumber]);
  SQLConnection.Execute(lCmd, nil);
end;

{==============================================================================}
function TMainDataModule.ImportTxMapping(const AFileName: string): Integer;
var
  lCmd: string;
  lLines: TStringList;
  i: integer;
  lShortId: integer;
  lChipId: string;
begin
  result := 0;
  lLines := TStringList.Create;
  try
    lLines.NameValueSeparator := #9;
    lLines.LoadFromFile(AFileName);

    SQLConnection.ExecuteDirect('DELETE FROM TRANSPONDERS');

    // Add the entries to the table
    for i  := 0 to lLines.Count - 1 do
    begin
      lShortId := lLines.KeyNames[i].ToInteger;
      lChipId := lLines.ValueFromIndex[i];
      lCmd := Format('INSERT INTO TRANSPONDERS (SHORTID, CHIPID, LOWBATTERYSTATUS, FIRSTLOWBATTERYTIME) VALUES (%d, %s, 0, NULL)', [lShortId, QuotedStr(lChipId)]);
      SQLConnection.Execute(lCmd, nil);
    end;

    result := FillTransponderMappingCache;
  finally
    FreeAndNil(lLines);
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
function TMainDataModule.FillTransponderMappingCache: Integer;
var
  lResultSet: TDataSet;
begin
  TTransponderMappingStore.GetSingleton.Clear;
  result := 0;

  SQLConnection.Execute('SELECT SHORTID, CHIPID FROM TRANSPONDERS ORDER BY SHORTID', nil, lResultSet);
  try
    if lResultSet.IsEmpty or (lResultSet.RecordCount < 1) then
      Exit;

    result := lResultSet.RecordCount;
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
function TMainDataModule.FillTransponderAssignmentCache: Integer;
var
  lResultSet: TDataSet;
  lAssignment: TTransponderAssignment;
  lValidToField: TField;
begin
  TTransponderAssignmentStore.GetSingleton.Clear;
  Result := 0;

  SQLConnection.Execute(
    'SELECT ASSIGNMENTID, CHIPID, COMPETITORID, VALIDFROM, VALIDTO, RACEID ' +
    'FROM TRANSPONDERASSIGNMENTS ORDER BY ASSIGNMENTID',
    nil, lResultSet);
  try
    if (lResultSet = nil) or lResultSet.IsEmpty then
      Exit;

    Result := lResultSet.RecordCount;
    lResultSet.First;
    while not lResultSet.Eof do
    begin
      lAssignment.AssignmentId := lResultSet.FieldByName('ASSIGNMENTID').AsInteger;
      lAssignment.ChipId := NormalizeChipId(lResultSet.FieldByName('CHIPID').AsString);
      lAssignment.CompetitorId := lResultSet.FieldByName('COMPETITORID').AsInteger;
      lAssignment.RaceId := lResultSet.FieldByName('RACEID').AsInteger;
      lAssignment.ValidFrom := lResultSet.FieldByName('VALIDFROM').AsDateTime;
      lValidToField := lResultSet.FieldByName('VALIDTO');
      if lValidToField.IsNull then
        lAssignment.ValidTo := 0
      else
        lAssignment.ValidTo := lValidToField.AsDateTime;
      TTransponderAssignmentStore.GetSingleton.Upsert(lAssignment);
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
class function TMainDataModule.GetJSONFromDataSet(ADataSet: TDataSet; const AFieldTitles: string): string;
var
  lColIdx: Integer;
  lRow: ISuperObject;
  lField: TField;
  lFieldTitles: TStringList;
  lTitle: string;
begin
  lFieldTitles := TStringList.Create;
  try
    lFieldTitles.CommaText := AFieldTitles;
    result := '{"list":[';

    ADataSet.First;
    while not ADataSet.Eof do
    begin
      lRow := TSuperObject.Create;
      for lColIdx := 0 to ADataSet.FieldCount - 1 do
      begin
        lField := ADataSet.FieldList[lColIdx];
        if (lFieldTitles.Count > 0) and (lColIdx < lFieldTitles.Count) then
          lTitle := lFieldTitles[lColIdx]
        else
          lTitle := lField.FieldName;
        if SameText(lTitle, 'STARTTIME') then
          lRow.D[lTitle] := SmartTimingTools.GetFieldAsDatetime(lField, 0)
        else
          lRow.S[lTitle] := lField.AsString;
      end;
      result := result + lRow.AsJSon;
      ADataSet.Next;
      if not ADataSet.Eof then
        result := result + ',';
    end;
    result := result + ']}';
  finally
    FreeAndNil(lFieldTitles);
  end;
end;

end.
