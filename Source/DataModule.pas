unit DataModule;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, Data.DbxSqlite, Data.FMTBcd, DBGrids,
  Datasnap.DBClient, Datasnap.Provider, Data.DB, Data.SqlExpr, DBCtrls,
  Graphics, Dialogs, Registry, Windows, JclFileUtils, Variants, Vcl.ComCtrls, System.Math,
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
    function BuildPenaltyCommuniqueText(ARaceId: Integer; AFilterByClass: Boolean;
      const AClass: string): string;
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
    function OpenReadOnlyQuery(const ASQL: string): TSQLDataSet;
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
    function GetRaceMinLapDuration(ARaceId: Integer): Integer;
    function GetCompetitorChipId(ACompetitorId: Integer): string;
    procedure SetCompetitorChipId(ACompetitorId: Integer; const AChipId: string);
    function GetCompetitorDisplayName(ACompetitorId: Integer): string;
    function GetCompetitorIdsForRace(ARaceId: Integer): TArray<Integer>;
    function GetMaxPassingNumber: integer;
    function GetMinPassingNumber: integer;
    function AllocateSyntheticPassingNumber: Integer;

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
    function TryGetCompetitorInRaceByBib(ARaceId, ABib: Integer; out ACompetitorId: Integer;
      out AName, ATeam, AClass, AChipId: string): Boolean;
    procedure FillCompetitorsInRace(ARaceId: Integer; AList: TListView;
      const ABibFilter: string = '');

    procedure SetParticipantState(ARaceId: Integer; ACompetitorIDs: TArray<Integer>; AParticipantState: TParticipantState);

    procedure ResetRaceParticitipations(ARaceId: Integer);
    function GetNumberOfLapsForParticipant(ARaceId: integer; const AChipId: string;
      APassingTime: TDateTime; var AParticipationId: integer; var AStartTime: TDatetime): integer;
    function TryGetRaceFinishTimeByTargetLaps(ARaceId, ATargetLaps: Integer;
      out AFinishTime: TDateTime): Boolean;
    procedure UpdateParticipationValues(AParticipationId: integer; const AFields: TArray<string>; const AValues: TArray<Variant>);
    function TryGetParticipationId(ARaceId, ACompetitorId: Integer; out AParticipationId: Integer): Boolean;
    function GetParticipationStringField(AParticipationId: Integer; const AFieldName: string): string;
    function IsParticipationFinishTimeOverridden(AParticipationId: Integer): Boolean;
    function GetPenaltyCommuniqueText(ARaceId: Integer): string; overload;
    function GetPenaltyCommuniqueText(ARaceId: Integer; const AClass: string): string; overload;
    procedure EnsureFinishTimeOverrideColumn;

    function ImportTxMapping(const AFileName: string): integer;
    procedure ExportTxMapping(const AFileName: string);
    function FillTransponderMappingCache: Integer;
    procedure SaveTransponderMappingCache;
    function FillTransponderAssignmentCache: Integer;

    procedure AddPassingToDatabase(APassing: TPassing; var ARaceId: integer;
      ASkipResolve: Boolean = False);
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
  EnsureFinishTimeOverrideColumn;
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
function TMainDataModule.OpenReadOnlyQuery(const ASQL: string): TSQLDataSet;
begin
  Result := nil;
  FillReadOnlyDataSetForSQL(ASQL, Result);
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
  lDataSet: TSQLDataSet;
begin
  lDataSet := OpenReadOnlyQuery('SELECT MAX(RACEID) FROM RACES WHERE EVENTID = ' + AEventId.ToString);
  try
    if (lDataSet = nil) or not lDataSet.Active or lDataSet.IsEmpty then
      Exit(1);
    if lDataSet.Fields[0].IsNull then
      Exit(0);
    Exit(lDataSet.Fields[0].AsInteger);
  finally
    FreeAndNil(lDataSet);
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
  lDataSet: TSQLDataSet;
begin
  Result := rsNotStarted;
  lDataSet := OpenReadOnlyQuery(Format('SELECT STATUS FROM RACES WHERE RACEID = %d', [ARaceId]));
  try
    if (lDataSet <> nil) and lDataSet.Active and not lDataSet.IsEmpty then
      Result := TRaceStatus(lDataSet.FieldByName('STATUS').AsInteger);
  finally
    FreeAndNil(lDataSet);
  end;
end;

{==============================================================================}
function TMainDataModule.GetRaceTitle(ARaceId: Integer): string;
var
  lDataSet: TSQLDataSet;
begin
  Result := ARaceId.ToString;
  lDataSet := OpenReadOnlyQuery(Format('SELECT TITLE FROM RACES WHERE RACEID = %d', [ARaceId]));
  try
    if (lDataSet <> nil) and lDataSet.Active and not lDataSet.IsEmpty then
      Result := lDataSet.FieldByName('TITLE').AsString;
  finally
    FreeAndNil(lDataSet);
  end;
end;

{==============================================================================}
function TMainDataModule.GetRaceMinLapDuration(ARaceId: Integer): Integer;
var
  lDataSet: TSQLDataSet;
begin
  Result := 0;
  lDataSet := OpenReadOnlyQuery(
    Format('SELECT MINLAPDURATION FROM RACES WHERE RACEID = %d', [ARaceId]));
  try
    if (lDataSet <> nil) and lDataSet.Active and not lDataSet.IsEmpty and
       not lDataSet.FieldByName('MINLAPDURATION').IsNull then
      Result := lDataSet.FieldByName('MINLAPDURATION').AsInteger;
  finally
    FreeAndNil(lDataSet);
  end;
end;

{==============================================================================}
function TMainDataModule.GetCompetitorChipId(ACompetitorId: Integer): string;
var
  lDataSet: TSQLDataSet;
begin
  Result := '';
  lDataSet := OpenReadOnlyQuery(
    Format('SELECT CHIPID FROM COMPETITORS WHERE COMPETITORID = %d', [ACompetitorId]));
  try
    if (lDataSet <> nil) and lDataSet.Active and not lDataSet.IsEmpty then
      Result := Trim(lDataSet.FieldByName('CHIPID').AsString);
  finally
    FreeAndNil(lDataSet);
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
  lDataSet: TSQLDataSet;
  lBib: Integer;
  lName: string;
begin
  Result := ACompetitorId.ToString;
  lDataSet := OpenReadOnlyQuery(
    Format('SELECT BIB, LASTNAME, FIRSTNAME FROM COMPETITORS WHERE COMPETITORID = %d',
      [ACompetitorId]));
  try
    if (lDataSet = nil) or not lDataSet.Active or lDataSet.IsEmpty then
      Exit;
    lBib := lDataSet.FieldByName('BIB').AsInteger;
    lName := Trim(lDataSet.FieldByName('LASTNAME').AsString + ', ' +
      lDataSet.FieldByName('FIRSTNAME').AsString);
    if lName = ',' then
      lName := '';
    if lName <> '' then
      Result := Format('#%d %s', [lBib, lName])
    else
      Result := Format('#%d', [lBib]);
  finally
    FreeAndNil(lDataSet);
  end;
end;

{==============================================================================}
function TMainDataModule.GetCompetitorIdsForRace(ARaceId: Integer): TArray<Integer>;
var
  lDataSet: TSQLDataSet;
  lList: TList<Integer>;
begin
  SetLength(Result, 0);
  lList := TList<Integer>.Create;
  try
    lDataSet := OpenReadOnlyQuery(
      Format('SELECT COMPETITORID FROM PARTICIPATION WHERE RACEID = %d ORDER BY COMPETITORID',
        [ARaceId]));
    try
      if (lDataSet = nil) or not lDataSet.Active or lDataSet.IsEmpty then
        Exit;
      lDataSet.First;
      while not lDataSet.Eof do
      begin
        lList.Add(lDataSet.Fields[0].AsInteger);
        lDataSet.Next;
      end;
    finally
      FreeAndNil(lDataSet);
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
  lDataSet: TSQLDataSet;
  lList: TList<Integer>;
begin
  lList := TList<Integer>.Create;
  try
    lDataSet := OpenReadOnlyQuery(
      Format('SELECT RACEID FROM PARTICIPATION WHERE COMPETITORID = %d ORDER BY RACEID',
        [ACompetitorId]));
    try
      if (lDataSet = nil) or not lDataSet.Active or lDataSet.IsEmpty then
        Exit(nil);
      lDataSet.First;
      while not lDataSet.Eof do
      begin
        lList.Add(lDataSet.Fields[0].AsInteger);
        lDataSet.Next;
      end;
    finally
      FreeAndNil(lDataSet);
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
function TMainDataModule.AllocateSyntheticPassingNumber: Integer;
begin
  (* SYSTEM markers and MANUAL passings must not occupy the decoder sequence:
     gaps in positive PassingNumbers signal network loss / reload candidates.
     Stay strictly negative (never 0 / never MAX+1). *)
  Result := Min(0, GetMinPassingNumber) - 1;
end;

{==============================================================================}
function TMainDataModule.GetMaxCompetitorId: integer;
begin
  result := GetMaxIdOf('COMPETITORS', 'COMPETITORID');
end;

{==============================================================================}
function TMainDataModule.GetMinIdOf(const ATableName, AColumnName: string): Integer;
var
  lDataSet: TSQLDataSet;
begin
  lDataSet := OpenReadOnlyQuery('SELECT MIN(' + AColumnName + ') FROM ' + ATableName);
  try
    if (lDataSet = nil) or not lDataSet.Active or lDataSet.IsEmpty then
      Exit(1);
    if lDataSet.Fields[0].IsNull then
      Exit(0);
    Exit(lDataSet.Fields[0].AsInteger);
  finally
    FreeAndNil(lDataSet);
  end;
end;

{==============================================================================}
function TMainDataModule.GetMaxIdOf(const ATableName, AColumnName: string): Integer;
var
  lDataSet: TSQLDataSet;
begin
  lDataSet := OpenReadOnlyQuery('SELECT MAX(' + AColumnName + ') FROM ' + ATableName);
  try
    if (lDataSet = nil) or not lDataSet.Active or lDataSet.IsEmpty then
      Exit(1);
    if lDataSet.Fields[0].IsNull then
      Exit(0);
    Exit(lDataSet.Fields[0].AsInteger);
  finally
    FreeAndNil(lDataSet);
  end;
end;

{==============================================================================}
function TMainDataModule.IsCompetitorAssignedToRace(ARaceId, ACompetitorId: Integer): Boolean;
var
  lDataSet: TSQLDataSet;
begin
  lDataSet := OpenReadOnlyQuery(Format(
    'SELECT PARTICIPATIONID FROM PARTICIPATION WHERE RACEID = %d AND COMPETITORID = %d',
    [ARaceId, ACompetitorId]));
  try
    Exit((lDataSet <> nil) and lDataSet.Active and not lDataSet.IsEmpty);
  finally
    FreeAndNil(lDataSet);
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
  lDataSet: TSQLDataSet;
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

  lDataSet := OpenReadOnlyQuery(Format(
    'SELECT P.RACEID, P.COMPETITORID, C.CHIPID FROM ' +
    'COMPETITORS C INNER JOIN PARTICIPATION P ON C.COMPETITORID = P.COMPETITORID ' +
    'INNER JOIN RACES R ON P.RACEID = R.RACEID ' +
    'WHERE R.STATUS IN (%s) AND C.BIB = %d',
    [lStatusList, ABib]));
  try
    if (lDataSet = nil) or not lDataSet.Active or lDataSet.IsEmpty then
      Exit;
    lDataSet.First;
    while not lDataSet.Eof do
    begin
      lRaceId := lDataSet.FieldByName('RACEID').AsInteger;
      lCompetitorId := lDataSet.FieldByName('COMPETITORID').AsInteger;
      if TTransponderAssignmentStore.GetSingleton.TryGetActiveByRaceAndCompetitor(
           lRaceId, lCompetitorId, lAssignment) then
        lChipId := lAssignment.ChipId
      else
        lChipId := Trim(lDataSet.FieldByName('CHIPID').AsString);

      if lChipId <> '' then
      begin
        if (APreferredRaceId >= 0) and (lRaceId = APreferredRaceId) then
          Exit(lChipId);
        if lFallback = '' then
          lFallback := lChipId;
      end;
      lDataSet.Next;
    end;
    Result := lFallback;
  finally
    FreeAndNil(lDataSet);
  end;
end;

{==============================================================================}
function TMainDataModule.TryGetCompetitorInRaceByBib(ARaceId, ABib: Integer;
  out ACompetitorId: Integer; out AName, ATeam, AClass, AChipId: string): Boolean;
var
  lDataSet: TSQLDataSet;
  lAssignment: TTransponderAssignment;
begin
  Result := False;
  ACompetitorId := -1;
  AName := '';
  ATeam := '';
  AClass := '';
  AChipId := '';
  if (ARaceId < 0) or (ABib <= 0) then
    Exit;

  lDataSet := OpenReadOnlyQuery(Format(
    'SELECT C.COMPETITORID, C.LASTNAME, C.FIRSTNAME, C.TEAM, C.CLASS, C.CHIPID ' +
    'FROM COMPETITORS C INNER JOIN PARTICIPATION P ON C.COMPETITORID = P.COMPETITORID ' +
    'WHERE P.RACEID = %d AND C.BIB = %d',
    [ARaceId, ABib]));
  try
    if (lDataSet = nil) or not lDataSet.Active or lDataSet.IsEmpty then
      Exit;
    ACompetitorId := lDataSet.FieldByName('COMPETITORID').AsInteger;
    AName := Trim(lDataSet.FieldByName('LASTNAME').AsString + ', ' +
      lDataSet.FieldByName('FIRSTNAME').AsString);
    if AName = ',' then
      AName := '';
    ATeam := lDataSet.FieldByName('TEAM').AsString;
    AClass := lDataSet.FieldByName('CLASS').AsString;
    if TTransponderAssignmentStore.GetSingleton.TryGetActiveByRaceAndCompetitor(
         ARaceId, ACompetitorId, lAssignment) then
      AChipId := lAssignment.ChipId
    else
      AChipId := Trim(lDataSet.FieldByName('CHIPID').AsString);
    Result := True;
  finally
    FreeAndNil(lDataSet);
  end;
end;

{==============================================================================}
procedure TMainDataModule.FillCompetitorsInRace(ARaceId: Integer; AList: TListView;
  const ABibFilter: string);
var
  lDataSet: TSQLDataSet;
  lItem: TListItem;
  lBib: Integer;
  lFilter: string;
  lAssignment: TTransponderAssignment;
  lCompetitorId: Integer;
  lChipId: string;
  lName: string;
begin
  if AList = nil then
    Exit;
  AList.Items.BeginUpdate;
  try
    AList.Items.Clear;
    if ARaceId < 0 then
      Exit;

    lFilter := Trim(ABibFilter);
    lDataSet := OpenReadOnlyQuery(Format(
      'SELECT C.COMPETITORID, C.BIB, C.LASTNAME, C.FIRSTNAME, C.TEAM, C.CLASS, C.CHIPID ' +
      'FROM COMPETITORS C INNER JOIN PARTICIPATION P ON C.COMPETITORID = P.COMPETITORID ' +
      'WHERE P.RACEID = %d ORDER BY C.BIB',
      [ARaceId]));
    try
      if (lDataSet = nil) or not lDataSet.Active or lDataSet.IsEmpty then
        Exit;
      lDataSet.First;
      while not lDataSet.Eof do
      begin
        lBib := lDataSet.FieldByName('BIB').AsInteger;
        if (lFilter <> '') and not lBib.ToString.StartsWith(lFilter) then
        begin
          lDataSet.Next;
          Continue;
        end;

        lCompetitorId := lDataSet.FieldByName('COMPETITORID').AsInteger;
        if TTransponderAssignmentStore.GetSingleton.TryGetActiveByRaceAndCompetitor(
             ARaceId, lCompetitorId, lAssignment) then
          lChipId := lAssignment.ChipId
        else
          lChipId := Trim(lDataSet.FieldByName('CHIPID').AsString);

        lName := Trim(lDataSet.FieldByName('LASTNAME').AsString + ', ' +
          lDataSet.FieldByName('FIRSTNAME').AsString);
        if lName = ',' then
          lName := '';
        lItem := AList.Items.Add;
        lItem.Caption := lBib.ToString;
        lItem.SubItems.Add(lName);
        lItem.SubItems.Add(lDataSet.FieldByName('TEAM').AsString);
        lItem.SubItems.Add(lChipId);
        lItem.SubItems.Add(lDataSet.FieldByName('CLASS').AsString);
        lItem.Data := Pointer(lCompetitorId);
        lDataSet.Next;
      end;
    finally
      FreeAndNil(lDataSet);
    end;
  finally
    AList.Items.EndUpdate;
  end;
end;

{==============================================================================}
function TMainDataModule.GetAllPassingsForRaceId(ARaceId: Integer; AOnlyActive: boolean = false): TArray<TPassing>;
var
  lOnlyActive: string;
  lDataSet: TSQLDataSet;
  i: integer;
begin
  lOnlyActive := '';
  if AOnlyActive then
    lOnlyActive := 'AND PASSINGSTATUS = ' + Ord(psValid).ToString;

  lDataSet := OpenReadOnlyQuery(Format(
    'SELECT * FROM PASSINGS WHERE RACEID = %d %s ORDER BY PASSINGTIME', [ARaceId, lOnlyActive]));
  try
    if (lDataSet = nil) or not lDataSet.Active or lDataSet.IsEmpty then
      Exit(nil);

    SetLength(result, lDataSet.RecordCount);
    i := 0;
    lDataSet.First;
    while not lDataSet.Eof do
    begin
      result[i].PassingNumber := lDataSet.FieldByName('PASSINGNUMBER').AsInteger;
      result[i].ChipId := lDataSet.FieldByName('CHIPID').AsString;
      result[i].PassingTime := SmartTimingTools.GetFieldAsDatetime(lDataSet.FieldByName('PASSINGTIME'), 0.0);
      result[i].SignalStrength := lDataSet.FieldByName('SIGNALSTRENGTH').AsInteger;
      result[i].Hits := lDataSet.FieldByName('HITS').AsInteger;
      result[i].Flags := lDataSet.FieldByName('FLAGS').AsInteger;
      result[i].Sport := lDataSet.FieldByName('SPORT').AsInteger;
      result[i].Voltage := 0;
      result[i].Temperature := 0;
      result[i].DecoderId := lDataSet.FieldByName('DECODERID').AsString;
      result[i].TxId := TTransponderMappingStore.GetSingleton.GetShortIdFromTransponderId(result[i].ChipId);
      result[i].RaceId := ARaceId;
      if lDataSet.FindField('PASSINGSTATUS') <> nil then
        result[i].PassingStatus := lDataSet.FieldByName('PASSINGSTATUS').AsInteger
      else
        result[i].PassingStatus := Ord(psValid);
      result[i].LapIndex := -1;
      result[i].CompetitorId := -1;
      Inc(i);
      lDataSet.Next;
    end;
  finally
    FreeAndNil(lDataSet);
  end;
end;

{==============================================================================}
function TMainDataModule.GetUnassignedPassings: TArray<TPassing>;
var
  lDataSet: TSQLDataSet;
  i: Integer;
begin
  SetLength(Result, 0);
  lDataSet := OpenReadOnlyQuery(
    'SELECT * FROM PASSINGS WHERE RACEID < 0 AND IFNULL(FLAGS, 0) <> 2 ' +
    'ORDER BY PASSINGTIME, PASSINGNUMBER');
  try
    if (lDataSet = nil) or not lDataSet.Active or lDataSet.IsEmpty then
      Exit;

    SetLength(Result, lDataSet.RecordCount);
    i := 0;
    lDataSet.First;
    while not lDataSet.Eof do
    begin
      Result[i].PassingNumber := lDataSet.FieldByName('PASSINGNUMBER').AsInteger;
      Result[i].ChipId := lDataSet.FieldByName('CHIPID').AsString;
      Result[i].PassingTime := SmartTimingTools.GetFieldAsDatetime(lDataSet.FieldByName('PASSINGTIME'), 0.0);
      Result[i].SignalStrength := lDataSet.FieldByName('SIGNALSTRENGTH').AsInteger;
      Result[i].Hits := lDataSet.FieldByName('HITS').AsInteger;
      Result[i].Flags := lDataSet.FieldByName('FLAGS').AsInteger;
      Result[i].Sport := lDataSet.FieldByName('SPORT').AsInteger;
      Result[i].Voltage := 0;
      Result[i].Temperature := 0;
      Result[i].DecoderId := lDataSet.FieldByName('DECODERID').AsString;
      Result[i].TxId := TTransponderMappingStore.GetSingleton.GetShortIdFromTransponderId(Result[i].ChipId);
      Result[i].RaceId := lDataSet.FieldByName('RACEID').AsInteger;
      if lDataSet.FindField('PASSINGSTATUS') <> nil then
        Result[i].PassingStatus := lDataSet.FieldByName('PASSINGSTATUS').AsInteger
      else
        Result[i].PassingStatus := Ord(psValid);
      Result[i].LapIndex := -1;
      Result[i].CompetitorId := -1;
      Inc(i);
      lDataSet.Next;
    end;
  finally
    FreeAndNil(lDataSet);
  end;
end;

{==============================================================================}
procedure TMainDataModule.GetCompetitorInfoForPassing(APassing: TPassing; var ABIB: integer; var AName, AClubTeam: string);
var
  lDataSet: TSQLDataSet;
  lField: TField;
  lCompetitorId: Integer;
begin
  ABIB := 0;
  AName := '?';
  AClubTeam := '?';

  if not TTransponderAssignmentService.TryGetCompetitorForRaceChipAtTime(
       APassing.RaceId, APassing.ChipId, APassing.PassingTime, lCompetitorId) then
    Exit;

  lDataSet := OpenReadOnlyQuery(Format(
    'SELECT C.BIB, C.LASTNAME, C.FIRSTNAME, C.CLUB, C.TEAM FROM COMPETITORS C ' +
    'WHERE C.COMPETITORID = %d',
    [lCompetitorId]));
  try
    if (lDataSet = nil) or not lDataSet.Active or lDataSet.IsEmpty then
      Exit;
    ABIB := lDataSet.FieldByName('BIB').AsInteger;
    lField := lDataSet.FieldByName('LASTNAME');
    if not lField.IsNull then
      AName := lField.AsString;
    AName := AName + ', ';
    lField := lDataSet.FieldByName('FIRSTNAME');
    if lField.IsNull then
      AName := AName + '?'
    else
      AName := AName + lField.AsString;
    lField := lDataSet.FieldByName('TEAM');
    if lField.IsNull or lField.AsString.IsEmpty then
    begin
      lField := lDataSet.FieldByName('CLUB');
      if not lField.IsNull then
        AClubTeam := lField.AsString;
    end
    else
      AClubTeam := lField.AsString;
  finally
    FreeAndNil(lDataSet);
  end;
end;

{==============================================================================}
procedure TMainDataModule.ResetRaceParticitipations(ARaceId: Integer);
begin
  (* Keep manual finish / ranking times when FINISHTIMEOVERRIDE is set. *)
  SQLConnection.ExecuteDirect(
    'UPDATE PARTICIPATION SET LAPS = 0, CURRENTRANKING = NULL, POINTS = 0, CRITRANKINGVALUE = NULL, ' +
    'FINISHTIME = CASE WHEN IFNULL(FINISHTIMEOVERRIDE, 0) <> 0 THEN FINISHTIME ELSE NULL END, ' +
    'RANKINGTIME = CASE WHEN IFNULL(FINISHTIMEOVERRIDE, 0) <> 0 THEN RANKINGTIME ELSE NULL END ' +
    'WHERE RACEID = ' + ARaceId.ToString);
end;

{==============================================================================}
function TMainDataModule.GetNumberOfLapsForParticipant(ARaceId: integer; const AChipId: string;
  APassingTime: TDateTime; var AParticipationId: integer; var AStartTime: TDatetime): integer;
var
  lDataSet: TSQLDataSet;
  lCompetitorId: Integer;
begin
  Result := 0;
  AParticipationId := -1;

  if not TTransponderAssignmentService.TryGetCompetitorForRaceChipAtTime(
       ARaceId, AChipId, APassingTime, lCompetitorId) then
    Exit;

  lDataSet := OpenReadOnlyQuery(Format(
    'SELECT LAPS, PARTICIPATIONID, P.STARTTIME FROM PARTICIPATION P ' +
    'WHERE P.RACEID = %d AND P.COMPETITORID = %d',
    [ARaceId, lCompetitorId]));
  try
    if (lDataSet = nil) or not lDataSet.Active or lDataSet.IsEmpty then
      Exit;

    if lDataSet.Fields[0].IsNull then
      Result := 0
    else
      Result := lDataSet.Fields[0].AsInteger;
    if not lDataSet.Fields[1].IsNull then
      AParticipationId := lDataSet.Fields[1].AsInteger;
    AStartTime := SmartTimingTools.GetFieldAsDatetime(lDataSet.Fields[2], 0);
  finally
    FreeAndNil(lDataSet);
  end;
end;

{==============================================================================}
function TMainDataModule.TryGetRaceFinishTimeByTargetLaps(ARaceId, ATargetLaps: Integer;
  out AFinishTime: TDateTime): Boolean;
var
  lDataSet: TSQLDataSet;
  lText: string;
  lFormatSettings: TFormatSettings;
begin
  Result := False;
  AFinishTime := 0;
  if (ARaceId < 0) or (ATargetLaps <= 0) then
    Exit;

  lDataSet := OpenReadOnlyQuery(Format(
    'SELECT MIN(FINISHTIME) FROM PARTICIPATION ' +
    'WHERE RACEID = %d AND IFNULL(LAPS, 0) >= %d ' +
    'AND IFNULL(TRIM(FINISHTIME), '''') <> ''''',
    [ARaceId, ATargetLaps]));
  try
    if (lDataSet = nil) or not lDataSet.Active or lDataSet.IsEmpty or
       lDataSet.Fields[0].IsNull then
      Exit;
    lText := Trim(lDataSet.Fields[0].AsString);
    if lText = '' then
      Exit;
    lFormatSettings := TFormatSettings.Create;
    lFormatSettings.TimeSeparator := ':';
    lFormatSettings.DecimalSeparator := '.';
    if TryStrToTime(lText, AFinishTime, lFormatSettings) then
    begin
      AFinishTime := Frac(AFinishTime);
      Exit(True);
    end;
    Result := TryStrToDateTime(lText, AFinishTime, lFormatSettings);
    if Result then
      AFinishTime := Frac(AFinishTime);
  finally
    FreeAndNil(lDataSet);
  end;
end;

{==============================================================================}
function TMainDataModule.GetSQLValueFromVariant(AValue: Variant): string;
begin
  case VarType(AValue) of
  varNull, varEmpty:
    result := 'NULL';
  varDate:
    result := FormatDatetime('yyyy-mm-dd hh:nn:ss.zzz', AValue).QuotedString;
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
function TMainDataModule.TryGetParticipationId(ARaceId, ACompetitorId: Integer;
  out AParticipationId: Integer): Boolean;
var
  lDataSet: TSQLDataSet;
begin
  Result := False;
  AParticipationId := -1;
  if (ARaceId < 0) or (ACompetitorId <= 0) then
    Exit;
  lDataSet := OpenReadOnlyQuery(Format(
    'SELECT PARTICIPATIONID FROM PARTICIPATION WHERE RACEID = %d AND COMPETITORID = %d',
    [ARaceId, ACompetitorId]));
  try
    if (lDataSet = nil) or not lDataSet.Active or lDataSet.IsEmpty then
      Exit;
    AParticipationId := lDataSet.Fields[0].AsInteger;
    Result := AParticipationId > 0;
  finally
    FreeAndNil(lDataSet);
  end;
end;

{==============================================================================}
function TMainDataModule.GetParticipationStringField(AParticipationId: Integer;
  const AFieldName: string): string;
var
  lDataSet: TSQLDataSet;
begin
  Result := '';
  if (AParticipationId <= 0) or (Trim(AFieldName) = '') then
    Exit;
  lDataSet := OpenReadOnlyQuery(Format(
    'SELECT %s FROM PARTICIPATION WHERE PARTICIPATIONID = %d',
    [AFieldName, AParticipationId]));
  try
    if (lDataSet = nil) or not lDataSet.Active or lDataSet.IsEmpty then
      Exit;
    Result := lDataSet.Fields[0].AsString;
  finally
    FreeAndNil(lDataSet);
  end;
end;

{==============================================================================}
function TMainDataModule.IsParticipationFinishTimeOverridden(
  AParticipationId: Integer): Boolean;
var
  lDataSet: TSQLDataSet;
begin
  Result := False;
  if AParticipationId <= 0 then
    Exit;
  lDataSet := OpenReadOnlyQuery(Format(
    'SELECT IFNULL(FINISHTIMEOVERRIDE, 0) FROM PARTICIPATION WHERE PARTICIPATIONID = %d',
    [AParticipationId]));
  try
    if (lDataSet = nil) or not lDataSet.Active or lDataSet.IsEmpty then
      Exit;
    Result := lDataSet.Fields[0].AsInteger <> 0;
  finally
    FreeAndNil(lDataSet);
  end;
end;

{==============================================================================}
procedure TMainDataModule.EnsureFinishTimeOverrideColumn;
var
  lDataSet: TSQLDataSet;
  lHasColumn: Boolean;
begin
  if not SQLConnection.Connected then
    Exit;
  lHasColumn := False;
  lDataSet := OpenReadOnlyQuery('PRAGMA table_info(PARTICIPATION)');
  try
    if (lDataSet = nil) or not lDataSet.Active then
      Exit;
    lDataSet.First;
    while not lDataSet.Eof do
    begin
      if SameText(lDataSet.Fields[1].AsString, 'FINISHTIMEOVERRIDE') then
      begin
        lHasColumn := True;
        Break;
      end;
      lDataSet.Next;
    end;
  finally
    FreeAndNil(lDataSet);
  end;
  if not lHasColumn then
    SQLConnection.ExecuteDirect(
      'ALTER TABLE PARTICIPATION ADD COLUMN FINISHTIMEOVERRIDE BOOLEAN NOT NULL DEFAULT 0');
end;

{==============================================================================}
function TMainDataModule.BuildPenaltyCommuniqueText(ARaceId: Integer;
  AFilterByClass: Boolean; const AClass: string): string;
var
  lDataSet: TSQLDataSet;
  lLines: TStringList;
  lText: string;
  lSql: string;
begin
  Result := '';
  if ARaceId < 0 then
    Exit;
  lLines := TStringList.Create;
  try
    lSql :=
      'SELECT P.PENALTIES FROM PARTICIPATION P ' +
      'INNER JOIN COMPETITORS C ON C.COMPETITORID = P.COMPETITORID ' +
      'WHERE P.RACEID = ' + ARaceId.ToString +
      ' AND IFNULL(TRIM(P.PENALTIES), '''') <> '''' ';
    if AFilterByClass then
      lSql := lSql + ' AND IFNULL(C.CLASS, '''') = ' + AClass.QuotedString;
    lSql := lSql + ' ORDER BY C.BIB, P.PARTICIPATIONID';

    lDataSet := OpenReadOnlyQuery(lSql);
    try
      if (lDataSet = nil) or not lDataSet.Active or lDataSet.IsEmpty then
        Exit;
      lDataSet.First;
      while not lDataSet.Eof do
      begin
        lText := Trim(lDataSet.Fields[0].AsString);
        if lText <> '' then
          lLines.Add(lText);
        lDataSet.Next;
      end;
    finally
      FreeAndNil(lDataSet);
    end;
    if lLines.Count = 0 then
      Exit;
    Result := cMessagesCommuniqueHeader + sLineBreak + sLineBreak + lLines.Text;
  finally
    FreeAndNil(lLines);
  end;
end;

{==============================================================================}
function TMainDataModule.GetPenaltyCommuniqueText(ARaceId: Integer): string;
begin
  Result := BuildPenaltyCommuniqueText(ARaceId, False, '');
end;

{==============================================================================}
function TMainDataModule.GetPenaltyCommuniqueText(ARaceId: Integer;
  const AClass: string): string;
begin
  Result := BuildPenaltyCommuniqueText(ARaceId, True, AClass);
end;

{==============================================================================}
procedure TMainDataModule.FillWithDistinctValues(const ATableName, AFieldName: string; AStrings: TStrings);
var
  lDataSet: TSQLDataSet;
  lValue: string;
begin
  AStrings.Clear;
  lDataSet := OpenReadOnlyQuery(
    'SELECT DISTINCT ' + AFieldName + ' FROM ' + ATableName + ' ORDER BY 1');
  try
    if (lDataSet = nil) or not lDataSet.Active or lDataSet.IsEmpty then
      Exit;

    lDataSet.First;
    while not lDataSet.Eof do
    begin
      lValue := lDataSet.Fields[0].AsString;
      AStrings.Add(lValue);
      lDataSet.Next;
    end;
  finally
    FreeAndNil(lDataSet);
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
procedure TMainDataModule.AddPassingToDatabase(APassing: TPassing; var ARaceId: integer;
  ASkipResolve: Boolean);
var
  lCmd: string;
  lTimeStr: string;
  lCompetitorId: integer;
  lStatus: Integer;
begin
  if APassing.Flags = 2 then
    ARaceId := APassing.RaceId
  else if ASkipResolve then
    ARaceId := APassing.RaceId
  else
  begin
    ARaceId := GetRaceIdForPassing(APassing, lCompetitorId);
    APassing.RaceId := ARaceId;
  end;

  lStatus := APassing.PassingStatus;
  lTimeStr := FormatDatetime('yyyy-mm-dd hh:nn:ss.zzz', APassing.PassingTime).QuotedString;
  lCmd :=
    Format('INSERT INTO PASSINGS ' +
           '(PASSINGNUMBER, CHIPID, PASSINGTIME, SIGNALSTRENGTH, HITS, FLAGS, SPORT, DECODERID, RACEID, PASSINGSTATUS) VALUES ' +
           '(%d, %s, %s, %d, %d, %d, %d, %s, %d, %d)',
           [APassing.PassingNumber, APassing.ChipId.QuotedString, lTimeStr,
            APassing.SignalStrength, APassing.Hits, APassing.Flags, APassing.Sport,
            APassing.DecoderId.QuotedString, APassing.RaceId, lStatus]);
  SQLConnection.Execute(lCmd, nil);
end;

{==============================================================================}
procedure TMainDataModule.UpdatePassingInDatabase(APassingNumber: Integer; APassingTime: TDatetime; APassingState: TPassingState);
var
  lCmd: string;
  lTimeStr: string;
begin
  lTimeStr := FormatDatetime('yyyy-mm-dd hh:nn:ss.zzz', APassingTime).QuotedString;
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
  lDataSet: TSQLDataSet;
  lLines: TStringList;
  lShortId: integer;
  lChipId: string;
begin
  lLines := TStringList.Create;
  try
    lLines.NameValueSeparator := #9;

    lDataSet := OpenReadOnlyQuery('SELECT SHORTID, CHIPID FROM TRANSPONDERS ORDER BY SHORTID');
    try
      if (lDataSet <> nil) and lDataSet.Active and not lDataSet.IsEmpty then
      begin
        lDataSet.First;
        while not lDataSet.Eof do
        begin
          lShortId := lDataSet.FieldByName('SHORTID').AsInteger;
          lChipId := lDataSet.FieldByName('CHIPID').AsString;
          lLines.AddPair(lShortId.ToString, lChipId);
          lDataSet.Next;
        end;
      end;
    finally
      FreeAndNil(lDataSet);
    end;
    lLines.SaveToFile(AFileName);
  finally
    FreeAndNil(lLines);
  end;
end;

{==============================================================================}
function TMainDataModule.FillTransponderMappingCache: Integer;
var
  lDataSet: TSQLDataSet;
begin
  TTransponderMappingStore.GetSingleton.Clear;
  result := 0;

  lDataSet := OpenReadOnlyQuery('SELECT SHORTID, CHIPID FROM TRANSPONDERS ORDER BY SHORTID');
  try
    if (lDataSet = nil) or not lDataSet.Active or lDataSet.IsEmpty then
      Exit;

    result := lDataSet.RecordCount;
    lDataSet.First;
    while not lDataSet.Eof do
    begin
      TTransponderMappingStore.GetSingleton.AddTransponder(
        lDataSet.Fields[0].AsInteger, lDataSet.Fields[1].AsString);
      lDataSet.Next;
    end;
  finally
    FreeAndNil(lDataSet);
  end;
end;

{==============================================================================}
function TMainDataModule.FillTransponderAssignmentCache: Integer;
var
  lDataSet: TSQLDataSet;
  lAssignment: TTransponderAssignment;
  lValidToField: TField;
begin
  TTransponderAssignmentStore.GetSingleton.Clear;
  Result := 0;

  lDataSet := OpenReadOnlyQuery(
    'SELECT ASSIGNMENTID, CHIPID, COMPETITORID, VALIDFROM, VALIDTO, RACEID ' +
    'FROM TRANSPONDERASSIGNMENTS ORDER BY ASSIGNMENTID');
  try
    if (lDataSet = nil) or not lDataSet.Active or lDataSet.IsEmpty then
      Exit;

    Result := lDataSet.RecordCount;
    lDataSet.First;
    while not lDataSet.Eof do
    begin
      lAssignment.AssignmentId := lDataSet.FieldByName('ASSIGNMENTID').AsInteger;
      lAssignment.ChipId := NormalizeChipId(lDataSet.FieldByName('CHIPID').AsString);
      lAssignment.CompetitorId := lDataSet.FieldByName('COMPETITORID').AsInteger;
      lAssignment.RaceId := lDataSet.FieldByName('RACEID').AsInteger;
      lAssignment.ValidFrom := SmartTimingTools.GetFieldAsDatetime(
        lDataSet.FieldByName('VALIDFROM'), 0);
      lValidToField := lDataSet.FieldByName('VALIDTO');
      if lValidToField.IsNull then
        lAssignment.ValidTo := 0
      else
        lAssignment.ValidTo := SmartTimingTools.GetFieldAsDatetime(lValidToField, 0);
      TTransponderAssignmentStore.GetSingleton.Upsert(lAssignment);
      lDataSet.Next;
    end;
  finally
    FreeAndNil(lDataSet);
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
