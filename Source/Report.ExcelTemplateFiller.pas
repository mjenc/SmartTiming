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

  protected
    FOnGetFieldValue: TFNFillerOnGetFieldValue;
    procedure FillTitle; virtual;
    procedure GenerateRankValue(const AFieldName: string; var AValue: string);
    function IsOutputField(const AFieldName: string): boolean;
    function GetGroupedFileName(const AClass: string): string;
    procedure FillDataRows(ADataSet: TDataSet; AGroupByClass: boolean; AAction: TExcelAction);
    function GetRecordCountOfDataSet(ADataSet: TDataSet): Integer;
    function GetVisibleFieldCountOfDataSet(ADataSet: TDataSet): Integer;

  public
    constructor Create(AEvent: TEventDataObject; const ARaceTitle: string);
    destructor Destroy; override;
    procedure FillDataRowsAndPrint(ADataSet: TDataSet; AGroupByClass: boolean);
    procedure FillDataRowsAndSave(const AFileName: string; ADataSet: TDataSet; AGroupByClass: boolean);

    property TemplateFile: string read FTemplateFile write FTemplateFile;
    property OnGetFieldValue: TFNFillerOnGetFieldValue read FOnGetFieldValue write FOnGetFieldValue;
  end;

implementation

uses
  Variants, DataModule, Dialogs;

{==============================================================================}
constructor TExcelFiller.Create(AEvent: TEventDataObject; const ARaceTitle: string);
begin
  FEvent := AEvent;
  FRaceTitle := ARaceTitle;

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
  lPrefix: string;
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
function TExcelFiller.GetRecordCountOfDataSet(ADataSet: TDataSet): Integer;
begin
  result := 0;
  ADataSet.First;
  while not ADataSet.Eof do
  begin
    Inc(result);
    ADataSet.Next;
  end;
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
  lRowIndex: Integer;
  lColumnIndex: integer;
  lFieldName: string;
  lValue: string;
  lCurrentClass: string;
  lCenterHeaderBase: string;
  lOutput: boolean;
  lCellColIdx: Integer;
  lRecordCount: integer;
  lVisibleFieldCount: integer;
  lCellRange: OleVariant;
  lStartCell: string;
  lEndCell: string;
const
  cDataRowStartIndex = 2; // Start from the second row assuming the first row is for headers

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
        lExcelSheet.PrintPreview; // PrintOut(EmptyParam, EmptyParam, EmptyParam, True, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, 0);
        FExcelApp.Visible[0] := false;
      end;
    end;
  end;

  procedure GetRangeCellNames(AStartField: Char; AStartRow, AFieldCount, ARecordCount: Integer; out AStartCell, AEndCell: string);
  var
    lByte: Byte;
  begin
    AStartCell := AStartField + IntToStr(AStartRow);

    lByte := Ord(AStartField) + AFieldCount - 1;
    AEndCell := Char(lByte) + IntToStr(AStartRow + ARecordCount - 1);
  end;
begin
  ADataSet.First;
  if ADataSet.Eof then
    Exit;

  try
    lExcelWorkbook := TExcelWorkbook.Create(nil);
    try
      lExcelWorkbook.ConnectTo(
        FExcelApp.Workbooks.Open(FTemplateFile, EmptyParam, EmptyParam,
          EmptyParam, EmptyParam, EmptyParam,
          EmptyParam, EmptyParam, EmptyParam,
          EmptyParam, EmptyParam, EmptyParam,
          EmptyParam, EmptyParam, EmptyParam, 0)
        );

      try
        lExcelWorkbook.Author[0] := cSmartTimingAppName + ' ' + cCopyright;

        lExcelSheet := TExcelWorksheet.Create(nil);
        lExcelSheet.ConnectTo(lExcelWorkbook.Sheets[1] as _Worksheet);
        lCenterHeaderBase := lExcelSheet.PageSetup.CenterHeader;
        lExcelSheet.PageSetup.CenterHeader := lCenterHeaderBase + CRLF + FRaceTitle;
        lCurrentClass := '';
        lRowIndex := 0;

        lRecordCount := GetRecordCountOfDataSet(ADataSet);
        lVisibleFieldCount := GetVisibleFieldCountOfDataSet(ADataSet);

        lCellRange := VarArrayCreate([0, lRecordCount - 1, 0, lVisibleFieldCount - 1], varVariant);

        ADataSet.First;
        while not ADataSet.Eof do
        begin
          lCellColIdx := 0;

          if AGroupByClass then
          begin
            lValue := ADataSet.FindField('CLASS').AsString;
             if not lCurrentClass.IsEmpty and (lValue <> lCurrentClass) then
             begin
               lExcelSheet.PageSetup.CenterHeader := lCenterHeaderBase + CRLF + FRaceTitle + ' - ' + lValue;

               // Save the file so far and clear it a new one
               DoAction;
               lExcelSheet.Cells.Clear;
               lRowIndex := cDataRowStartIndex;
             end;
            lCurrentClass := lValue;
          end;

          for lColumnIndex := 0 to ADataSet.FieldCount - 1 do
          begin
            lFieldName := ADataSet.FieldList[lColumnIndex].FieldName;
            lValue := ADataSet.FieldList[lColumnIndex].AsString;
            lOutput := IsOutputField(lFieldName);

            if Assigned(FOnGetFieldValue) then
            begin
              if not lOutput then
                Continue;
              FOnGetFieldValue(lColumnIndex, ADataSet, lValue);
            end;

            if not ADataSet.FieldList[lColumnIndex].Visible then
              Continue;
            if not lOutput then
              Continue;

            lCellRange[lRowIndex, lCellColIdx] := lValue;
            Inc(lCellColIdx);
          end;

          Inc(lRowIndex);
          ADataSet.Next;
        end;

        GetRangeCellNames('A', 2, lVisibleFieldCount, lRecordCount, lStartCell, lEndCell);
        lExcelSheet.Cells.Range[lStartCell, lEndCell].Value[xlRangeValueDefault] := lCellRange;

        if AGroupByClass then
          lExcelSheet.PageSetup.CenterHeader := lCenterHeaderBase + CRLF + FRaceTitle + ' - ' + lCurrentClass;

        DoAction;
      finally
        lExcelWorkbook.Close(false, '', EmptyParam, 0);
      end;
    finally
      FreeAndNil(lExcelWorkbook);
    end;
  except
    on E: Exception do
      ShowMessage(E.Message);
  end;
end;

end.
