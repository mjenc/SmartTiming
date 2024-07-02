unit SmartTiming.Grid;

interface

uses
  DBGrids, Data.DB, UITypes, Classes;

type
  TSmartTimingGrid = class(TDBGrid)
  private
    FViewName: string;
    FFormattedColumns: TDBGridColumns;
    procedure SelectRange;
  protected
    FIsDirty: boolean;

    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X: Integer; Y: Integer); override;

  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure ApplyFormat;
  published
    property ViewName: string read FViewName write FViewName;
  end;


implementation

uses
  SmartTiming.GridFormatProvider;

{==============================================================================}
constructor TSmartTimingGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FIsDirty := false;
//  FFormattedColumns := TDBGridColumns;
end;

{==============================================================================}
destructor TSmartTimingGrid.Destroy;
begin
  try
    if FIsDirty then
      TGridFormatProvider.SaveSettings(self);
  finally
    inherited Destroy;
  end;
end;

{==============================================================================}
procedure TSmartTimingGrid.ApplyFormat;
begin

end;

{==============================================================================}
procedure TSmartTimingGrid.SelectRange;
var
  CurrentBookMark, CursorBookMark, FirstBookMark, LastBookMark: TBookmark;
  Dir: integer;
begin
  if SelectedRows.Count <= 1 then
    exit;

  DataSource.DataSet.DisableControls;
  try
    FirstBookMark := SelectedRows.Items[0];
    LastBookMark := SelectedRows.Items[SelectedRows.Count - 1];
    SelectedRows.Clear;
    CurrentBookMark := DataSource.DataSet.GetBookmark;
    Dir := DataSource.DataSet.CompareBookmarks(FirstBookMark, CurrentBookMark);

    if Dir = 0 then
      Dir := DataSource.DataSet.CompareBookmarks(LastBookMark, CurrentBookMark);

    if Dir > 0 then
      DataSource.DataSet.GotoBookmark(LastBookMark)
    else if Dir < 0 then
      DataSource.DataSet.GotoBookmark(FirstBookMark)
    else
      Exit;

    while not DataSource.DataSet.eof do
    begin
      CursorBookMark := DataSource.DataSet.GetBookmark;
      SelectedRows.CurrentRowSelected := true;

      if DataSource.DataSet.CompareBookmarks(CurrentBookMark, CursorBookMark) = 0 then
      begin
        DataSource.DataSet.FreeBookMark(CursorBookMark);
        break;
      end;
      DataSource.DataSet.FreeBookMark(CursorBookMark);

      if Dir < 0 then
        DataSource.DataSet.Next
      else
        DataSource.DataSet.Prior;
    end;

    DataSource.DataSet.FreeBookMark(CurrentBookMark);
  finally
    DataSource.DataSet.EnableControls;
  end;
end;

{ TDBGrid }


{==============================================================================}
procedure TSmartTimingGrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if Shift = [ssCtrl, ssShift, ssLeft] then
    SelectRange;
end;

end.


