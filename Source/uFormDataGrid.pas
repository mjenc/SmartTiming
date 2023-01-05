unit uFormDataGrid;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  System.ImageList, Vcl.ImgList, Vcl.ComCtrls, Vcl.ToolWin, Data.DB, Vcl.Grids,
  Vcl.DBGrids, Vcl.ExtCtrls, Vcl.DBCtrls;

type
  TGridButton = (gbNew, gbEdit, gbDelete, gbPrint, gbImport, gbExport);
  TGridButtons = set of TGridButton;

  TFormDataGrid = class(TForm)
    ImageListIcons: TImageList;
    ToolBar: TToolBar;
    ToolButtonNew: TToolButton;
    ToolButtonEdit: TToolButton;
    ToolButtonDelete: TToolButton;
    ToolButtonPrint: TToolButton;
    ToolButtonImport: TToolButton;
    ToolButtonExport: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    DBGrid: TDBGrid;
    PanelDataGrid: TPanel;
    DBNavigator1: TDBNavigator;
    procedure FormShow(Sender: TObject);
  private
    FVisibleButtons: TGridButtons;

    function GetButtonControl(AButton: TGridButton): TToolButton;
    procedure RefreshToolButtons;
  public
    constructor Create(AParent: TComponent); override;
    procedure ShowInControl(APanel: TPanel);

    property VisibleButtons: TGridButtons read FVisibleButtons write FVisibleButtons;
  end;

var
  FormDataGrid: TFormDataGrid;

implementation

{$R *.dfm}

{==============================================================================}
constructor TFormDataGrid.Create(AParent: TComponent);
begin
  inherited Create(AParent);
  FVisibleButtons := [gbNew, gbEdit, gbDelete, gbPrint, gbImport, gbExport];
end;

{==============================================================================}
procedure TFormDataGrid.FormShow(Sender: TObject);
begin
  RefreshToolButtons;
end;

{==============================================================================}
procedure TFormDataGrid.ShowInControl(APanel: TPanel);
begin
  if not assigned(aPanel) then
    exit;
  Parent := aPanel;
  BorderStyle := bsNone;
  Align := alClient;

  ToolBar.Left := 0;
  ToolBar.Top := 0;
  ToolBar.Width := APanel.Width;
  Visible := true;
end;


{==============================================================================}
function TFormDataGrid.GetButtonControl(AButton: TGridButton): TToolButton;
begin
  case AButton of
  gbNew:
    result := ToolButtonNew;
  gbEdit:
    result := ToolButtonEdit;
  gbDelete:
    result := ToolButtonDelete;
  gbPrint:
    result := ToolButtonPrint;
  gbImport:
    result := ToolButtonImport;
  gbExport:
    result := ToolButtonExport;
  end;
end;

{==============================================================================}
procedure TFormDataGrid.RefreshToolButtons;
var
  i: integer;
  lToolButton: TToolButton;
  lGridButton: TGridButton;
begin
  for i := 0 to ToolBar.ButtonCount - 1 do
  begin
    lToolButton := ToolBar.Buttons[i];
    if lToolButton.Style = tbsSeparator then
      Continue;
    lToolButton.Visible := false;
    lToolButton.Enabled := false;
  end;
  for lGridButton in FVisibleButtons do
  begin
    lToolButton := GetButtonControl(lGridButton);
    lToolButton.Visible := true;
    lToolButton.Enabled := true;
  end;
end;

end.
