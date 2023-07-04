unit Report.ExcelTemplateFiller;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Data.SqlExpr,
  System.IOUtils, ExcelXP, Excel2010,
  SmartTiming.Event, SmartTiming.Consts, Generics.Collections;

type
  TExcelFiller = class
  private
    FEvent: TEventDataObject;
    FRaceTitle: string;
    FExcelApp: TExcelApplication;
    FTemplateFile: string;
    FOutputFile: string;

  protected
    procedure FillTitle; virtual;

  public
    constructor Create(AEvent: TEventDataObject; const ARaceTitle: string);
    destructor Destroy; override;
    procedure FillDataRows(ADataSet: TDataSet);

    property TemplateFile: string read FTemplateFile write FTemplateFile;
    property OutputFile: string read FOutputFile write FOutputFile;
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
procedure TExcelFiller.FillDataRows(ADataSet: TDataSet);
var
  lExcelWorkbook: _Workbook;
  lExcelSheet: _Worksheet;
  lRowIndex: Integer;
  lColumnIndex: integer;
  lColumnName: string;
begin
  ADataSet.First;
  if ADataSet.Eof then
    Exit;

  try
    lExcelWorkbook := FExcelApp.Workbooks.Open(FTemplateFile, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, EmptyParam, EmptyParam, 0);

//    lExcelWorkbook := FExcelApp.Workbooks.Open(FTemplateFile, false, false,
//      EmptyParam, EmptyParam, EmptyParam,
//      EmptyParam, EmptyParam, EmptyParam,
//      true, false, EmptyParam, true, true, true, 0);

  //    function Open(const Filename: WideString; UpdateLinks: OleVariant; ReadOnly: OleVariant;
  //                  Format: OleVariant; Password: OleVariant; WriteResPassword: OleVariant;
  //                  IgnoreReadOnlyRecommended: OleVariant; Origin: OleVariant; Delimiter: OleVariant;
  //                  Editable: OleVariant; Notify: OleVariant; Converter: OleVariant;
  //                  AddToMru: OleVariant; Local: OleVariant; CorruptLoad: OleVariant; lcid: Integer): ExcelWorkbook; safecall;

    lExcelSheet := lExcelWorkbook.Sheets[1] as _Worksheet;

    lRowIndex := 2; // Start from the second row assuming the first row is for headers
    while not ADataSet.Eof do
    begin
      for lColumnIndex := 0 to ADataSet.FieldCount - 1 do
        lExcelSheet.Cells.Item[lRowIndex, lColumnIndex + 1].Value := ADataSet.FieldList[lColumnIndex].AsString;

      Inc(lRowIndex);
      ADataSet.Next;
    end;

    lExcelWorkbook.SaveAs(FOutputFile, EmptyParam, EmptyParam, EmptyParam, EmptyParam,
      EmptyParam, xlNoChange, EmptyParam, EmptyParam, EmptyParam, EmptyParam, EmptyParam, 0);
  except
    on E: Exception do
      ShowMessage(E.Message);
  end;
end;

end.
