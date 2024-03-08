unit SmartTiming.GridFormatProvider;

interface

uses
  Classes, SysUtils, Windows, DBGrids, DBCtrls, SmartTiming.Consts, Tools.SuperObject;

type
  TGridFormatProvider = class
  private
    class function ColumnToSO(AColumn: TColumn): ISuperObject;
    class function GridColumnsToSO(AGrid: TDBGrid): ISuperObject;
    class function GetComponentNamePath(AComponent: TComponent): string;
    class procedure ApplyColumnSetting(AColumns: TDBGridColumns; ASOColumn: ISuperObject);
  public
    const
      RegPath = cRegKeyPath + '\Settings\GridFormats';

    class function LoadSettings(AGrid: TDBGrid; const ADefaultFormat: string; const AFormatSuffix: string = ''): boolean;
    class procedure SaveSettings(AGrid: TDBGrid; const AFormatSuffix: string = '');
  end;

const
  cGridFormatApplied = 123;

implementation

uses
  Registry;

{==============================================================================}
class function TGridFormatProvider.ColumnToSO(AColumn: TColumn): ISuperObject;
var
  lJSONStr: string;
begin
  if AColumn = nil then
    Exit(nil);

  lJSONStr := Format('{"Fieldname":"%s","Visible":%d,"Alignment":%d,"Width":%d,"Index":%d',
                     [AColumn.FieldName,
                      AColumn.Visible.ToInteger,
                      Ord(AColumn.Alignment),
                      AColumn.Width,
                      AColumn.Index]);

  if (AColumn.Title <> nil) and (AColumn.Title.Caption <> '') then
    lJSONStr := lJSONStr + Format(',"Title":"%s"', [AColumn.Title.Caption]);

  lJSONStr := lJSONStr + '}';
  result := TSuperObject.ParseString(PChar(lJSONStr), true);
end;

{==============================================================================}
class function TGridFormatProvider.GridColumnsToSO(AGrid: TDBGrid): ISuperObject;
var
  i: integer;
begin
  if AGrid = nil then
    Exit(nil);
  result := TSuperObject.ParseString('{"columns":[]}', true);

  for i := 0 to AGrid.Columns.Count - 1 do
    result.A['columns'].Add(ColumnToSO(AGrid.Columns[i]));
end;

{==============================================================================}
class procedure TGridFormatProvider.ApplyColumnSetting(AColumns: TDBGridColumns; ASOColumn: ISuperObject);
var
  i: integer;
  lFieldName: string;
  lColumn: TColumn;
begin
  lFieldName := ASOColumn.S['Fieldname'];
  for i := 0 to AColumns.Count - 1 do
  begin
    if not SameText(lFieldName, AColumns[i].FieldName) then
      Continue;
    lColumn := AColumns[i];
    lColumn.Visible := ASOColumn.B['Visible'];
    lColumn.Alignment := TAlignment(ASOColumn.I['Alignment']);
    lColumn.Width := ASOColumn.I['Width'];
    lColumn.Title.Caption := ASOColumn.S['Title'];
    lColumn.Index := ASOColumn.I['Index'];
  end;
end;

{==============================================================================}
class function TGridFormatProvider.LoadSettings(AGrid: TDBGrid; const ADefaultFormat: string; const AFormatSuffix: string = ''): boolean;
var
  i: Integer;
  lRegPath: string;
  lReg : TRegistry;
  lText: string;
  lBinaryStream: TMemoryStream;
  lStringStream: TStringStream;
  lSO: ISuperObject;
  lColumnsArray: TSuperArray;
begin
  result := true;
  if AGrid = nil then
    Exit(false);

  lReg := TRegistry.Create;
  try
    lReg.RootKey := HKEY_CURRENT_USER;

    if AFormatSuffix.IsEmpty then
      lRegPath := RegPath + '\' + GetComponentNamePath(AGrid)
    else
      lRegPath := RegPath + '\' + AGrid.Name + AFormatSuffix;

    if lReg.OpenKey(lRegPath, false) then
      lText := lReg.ReadString('ColumnsJSON');

    if lText.IsEmpty then
      lText := ADefaultFormat;

    lSO := TSuperObject.ParseString(PChar(lText), true);
    lColumnsArray := lSO.A['columns'];
    if lColumnsArray = nil then
      Exit;

    for i := 0 to lColumnsArray.Length - 1 do
      ApplyColumnSetting(AGrid.Columns, lColumnsArray.O[i]);

    AGrid.Tag := cGridFormatApplied;
  finally
    FreeAndNil(lReg);
  end;
end;

{==============================================================================}
class procedure TGridFormatProvider.SaveSettings(AGrid: TDBGrid; const AFormatSuffix: string = '');
var
  i: Integer;
  lRegPath: string;
  lReg : TRegistry;
  lStringStream: TStringStream;
  lBinaryStream: TMemoryStream;
  lText: string;
begin
  if AGrid = nil then
    Exit;

  if not (AGrid.Tag = cGridFormatApplied) then
    Exit;

  if AFormatSuffix.IsEmpty then
    lRegPath := RegPath + '\' + GetComponentNamePath(AGrid)
  else
    lRegPath := RegPath + '\' + AGrid.Name + AFormatSuffix;

  lBinaryStream := TMemoryStream.Create;
  lStringStream := TStringStream.Create(lText);
  lReg := TRegistry.Create;
  try
    lReg.RootKey := HKEY_CURRENT_USER;
    if not lReg.OpenKey(lRegPath, true) then
      raise Exception('Registry is not writable.' + lRegPath);

    lReg.WriteString('ColumnsJSON', GridColumnsToSO(AGrid).AsJSon);
  finally
    FreeAndNil(lReg);
    FreeAndNil(lBinaryStream);
    FreeAndNil(lStringStream);
  end;
end;

{==============================================================================}
class function TGridFormatProvider.GetComponentNamePath(AComponent: TComponent): string;
var
  lComponent: TComponent;
begin
  lComponent := AComponent;
  result := '';

  while lComponent <> nil do
  begin
    if result.IsEmpty then
      result := lComponent.Name
    else
      result := lComponent.Name + '.' + result;
    lComponent := lComponent.GetParentComponent;
  end;
end;

end.
