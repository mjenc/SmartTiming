unit Report.ExcelTemplateFiller;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Data.SqlExpr,
  System.IOUtils, ExcelXP, Excel2010,
  SmartTiming.Event, SmartTiming.Consts, Generics.Collections;

type
  TExcelAction = (eaSave, eaPrint);

  TFNFillerOnGetFieldValue = procedure(ACol: Integer; ADataSet: TDataSet; var AValue: string) of object;
  TExcelFiller = class
  private
    FEvent: TEventDataObject;
    FRaceTitle: string;
    FExcelApp: TExcelApplication;
    FTemplateFile: string;
    FOutputFile: string;
    FCommuniqueRaceId: Integer;

  protected
    FOnGetFieldValue: TFNFillerOnGetFieldValue;
    procedure FillTitle; virtual;
    procedure GenerateRankValue(const AFieldName: string; var AValue: string);
    function IsOutputField(const AFieldName: string): boolean;
    function GetGroupedFileName(const AClass: string): string;
    procedure FillDataRows(ADataSet: TDataSet; AGroupByClass: boolean; AAction: TExcelAction);
    function GetVisibleFieldCountOfDataSet(ADataSet: TDataSet): Integer;

  public
    constructor Create(AEvent: TEventDataObject; const ARaceTitle: string);
    destructor Destroy; override;
    procedure FillDataRowsAndPrint(ADataSet: TDataSet; AGroupByClass: boolean);
    procedure FillDataRowsAndSave(const AFileName: string; ADataSet: TDataSet; AGroupByClass: boolean);

    property TemplateFile: string read FTemplateFile write FTemplateFile;
    property OnGetFieldValue: TFNFillerOnGetFieldValue read FOnGetFieldValue write FOnGetFieldValue;
    (* Race id for Kommuniqué lookup; <0 disables. Per-class when GroupByClass. *)
    property CommuniqueRaceId: Integer read FCommuniqueRaceId write FCommuniqueRaceId;
  end;

implementation

uses
  Variants, DataModule, Dialogs;

{==============================================================================}
constructor TExcelFiller.Create(AEvent: TEventDataObject; const ARaceTitle: string);
begin
  FEvent := AEvent;
  FRaceTitle := ARaceTitle;
  FCommuniqueRaceId := -1;

  FExcelApp := TExcelApplication.Create(nil);
  FExcelApp.Connect;
end;

{==============================================================================}
destructor TExcelFiller.Destroy;
begin
  FExcelApp.Disconnect;
  FreeAndNil(FExcelApp);
  inherited;
end;

{==============================================================================}
procedure TExcelFiller.FillTitle;
begin

end;

{==============================================================================}
function TExcelFiller.GetGroupedFileName(const AClass: string): string;
var
  lFileNameParts: TArray<string>;
  lExt: string;
  i: integer;
begin
  if AClass.IsEmpty then
    Exit(FOutputFile);
  lFileNameParts := FOutputFile.Split(['.']);
  lExt := lFileNameParts[High(lFileNameParts)];
  for i := 0 to High(lFileNameParts) - 1 do
    result := result + lFileNameParts[i];
  result.TrimRight(['.']);
  result := result + '-' + AClass + '.' + lExt;
end;

{==============================================================================}
procedure TExcelFiller.GenerateRankValue(const AFieldName: string; var AValue: string);
begin
  if SameText(AFieldName, 'DNS') or SameText(AFieldName, 'DNF') or SameText(AFieldName, 'DSQ') then
    AValue := AFieldName;
end;

{==============================================================================}
function TExcelFiller.IsOutputField(const AFieldName: string): boolean;
begin
  result := not (SameText(AFieldName, 'DNS') or SameText(AFieldName, 'DNF') or SameText(AFieldName, 'DSQ')  or SameText(AFieldName, 'CLASS'));
end;

{==============================================================================}
procedure TExcelFiller.FillDataRowsAndPrint(ADataSet: TDataSet; AGroupByClass: boolean);
begin
  FillDataRows(ADataSet, AGroupByClass, eaPrint);
end;

{==============================================================================}
procedure TExcelFiller.FillDataRowsAndSave(const AFileName: string; ADataSet: TDataSet; AGroupByClass: boolean);
begin
  FOutputFile := AFileName;
  FillDataRows(ADataSet, AGroupByClass, eaSave);
end;

{==============================================================================}
function TExcelFiller.GetVisibleFieldCountOfDataSet(ADataSet: TDataSet): Integer;
var
  i: integer;
begin
  result := 0;
  for i := 0 to ADataSet.FieldCount - 1 do
  begin
    if ADataSet.Fields[i].Visible and IsOutputField(ADataSet.Fields[i].FieldName) then
      Inc(result);
  end;
end;

{==============================================================================}
procedure TExcelFiller.FillDataRows(ADataSet: TDataSet; AGroupByClass: boolean; AAction: TExcelAction);
var
  lExcelWorkbook: TExcelWorkbook;
  lExcelSheet: TExcelWorksheet;
  lValue: string;
  lCurrentClass: string;
  lCenterHeaderBase: string;
  lVisibleFieldCount: integer;
  lCellRange: OleVariant;
  lStartCell: string;
  lEndCell: string;
  lRows: TList<TArray<string>>;
  lRowValues: TArray<string>;
  lCommunique: string;
const
  cDataRowStartIndex = 2; // Start from the second row assuming the first row is for headers

  procedure GetRangeCellNames(AStartField: Char; AStartRow, AFieldCount, ARecordCount: Integer; out AStartCell, AEndCell: string);
  var
    lByte: Byte;
  begin
    AStartCell := AStartField + IntToStr(AStartRow);
    lByte := Ord(AStartField) + AFieldCount - 1;
    AEndCell := Char(lByte) + IntToStr(AStartRow + ARecordCount - 1);
  end;

  procedure CloseWorkbook;
  begin
    if lExcelSheet <> nil then
    begin
      FreeAndNil(lExcelSheet);
    end;
    if lExcelWorkbook <> nil then
    begin
      lExcelWorkbook.Close(false, '', EmptyParam, 0);
      FreeAndNil(lExcelWorkbook);
    end;
  end;

  procedure OpenTemplate;
  begin
    CloseWorkbook;
    lExcelWorkbook := TExcelWorkbook.Create(nil);
    lExcelWorkbook.ConnectTo(
      FExcelApp.Workbooks.Open(FTemplateFile, EmptyParam, EmptyParam,
        EmptyParam, EmptyParam, EmptyParam,
        EmptyParam, EmptyParam, EmptyParam,
        EmptyParam, EmptyParam, EmptyParam,
        EmptyParam, EmptyParam, EmptyParam, 0)
      );
    lExcelWorkbook.Author[0] := cSmartTimingAppName + ' ' + cCopyright;
    lExcelSheet := TExcelWorksheet.Create(nil);
    lExcelSheet.ConnectTo(lExcelWorkbook.Sheets[1] as _Worksheet);
    lCenterHeaderBase := lExcelSheet.PageSetup.CenterHeader;
  end;

  procedure DoAction;
  var
    lSaveDialog: TFileSaveDialog;
  begin
    case AAction of
    eaSave:
      begin
        lSaveDialog := TFileSaveDialog.Create(nil);
        try
          lSaveDialog.FileName := GetGroupedFileName(lCurrentClass);
          lSaveDialog.DefaultFolder := ExtractFilePath(lSaveDialog.FileName);
          if lSaveDialog.Execute then
            lExcelSheet.SaveAs(lSaveDialog.FileName);
        finally
          FreeAndNil(lSaveDialog);
        end;
      end;
    eaPrint:
      begin
        FExcelApp.Visible[0] := true;
        lExcelSheet.PrintPreview;
        FExcelApp.Visible[0] := false;
      end;
    end;
  end;

  function ResolveCommunique: string;
  begin
    Result := '';
    if FCommuniqueRaceId < 0 then
      Exit;
    if AGroupByClass then
      Result := MainDataModule.GetPenaltyCommuniqueText(FCommuniqueRaceId, lCurrentClass)
    else
      Result := MainDataModule.GetPenaltyCommuniqueText(FCommuniqueRaceId);
  end;

  procedure EmitBufferedClass;
  var
    r, c: Integer;
  begin
    if (lRows = nil) or (lRows.Count = 0) then
      Exit;

    OpenTemplate;
    try
      if AGroupByClass then
        lExcelSheet.PageSetup.CenterHeader :=
          lCenterHeaderBase + CRLF + FRaceTitle + ' - ' + lCurrentClass
      else
        lExcelSheet.PageSetup.CenterHeader := lCenterHeaderBase + CRLF + FRaceTitle;

      lCellRange := VarArrayCreate([0, lRows.Count - 1, 0, lVisibleFieldCount - 1], varVariant);
      for r := 0 to lRows.Count - 1 do
      begin
        lRowValues := lRows[r];
        for c := 0 to High(lRowValues) do
          lCellRange[r, c] := lRowValues[c];
      end;

      GetRangeCellNames('A', cDataRowStartIndex, lVisibleFieldCount, lRows.Count, lStartCell, lEndCell);
      lExcelSheet.Cells.Range[lStartCell, lEndCell].Value[xlRangeValueDefault] := lCellRange;

      lCommunique := ResolveCommunique;
      if Trim(lCommunique) <> '' then
        lExcelSheet.Cells.Item[cDataRowStartIndex + lRows.Count + 1, 1].Value2 := lCommunique;

      DoAction;
    finally
      CloseWorkbook;
    end;
    lRows.Clear;
  end;

  procedure AppendCurrentDataRow;
  var
    lCol: Integer;
    lColumnIndex: Integer;
    lFieldName: string;
    lCellValue: string;
    lOutput: Boolean;
  begin
    SetLength(lRowValues, lVisibleFieldCount);
    lCol := 0;
    for lColumnIndex := 0 to ADataSet.FieldCount - 1 do
    begin
      lFieldName := ADataSet.FieldList[lColumnIndex].FieldName;
      lCellValue := ADataSet.FieldList[lColumnIndex].AsString;
      lOutput := IsOutputField(lFieldName);

      if Assigned(FOnGetFieldValue) then
      begin
        if not lOutput then
          Continue;
        FOnGetFieldValue(lColumnIndex, ADataSet, lCellValue);
      end;

      if not ADataSet.FieldList[lColumnIndex].Visible then
        Continue;
      if not lOutput then
        Continue;

      lRowValues[lCol] := lCellValue;
      Inc(lCol);
    end;
    lRows.Add(Copy(lRowValues));
  end;

begin
  ADataSet.First;
  if ADataSet.Eof then
    Exit;

  lExcelWorkbook := nil;
  lExcelSheet := nil;
  lCurrentClass := '';
  lVisibleFieldCount := GetVisibleFieldCountOfDataSet(ADataSet);
  if lVisibleFieldCount <= 0 then
    Exit;

  lRows := TList<TArray<string>>.Create;
  try
    try
      ADataSet.First;
      while not ADataSet.Eof do
      begin
        if AGroupByClass then
        begin
          lValue := ADataSet.FindField('CLASS').AsString;
          if (lRows.Count > 0) and (lValue <> lCurrentClass) then
            EmitBufferedClass;
          lCurrentClass := lValue;
        end;

        AppendCurrentDataRow;
        ADataSet.Next;
      end;

      EmitBufferedClass;
    except
      on E: Exception do
        ShowMessage(E.Message);
    end;
  finally
    CloseWorkbook;
    FreeAndNil(lRows);
  end;
end;

end.
