unit FormAssignCompetitorToTransponder;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls,
  Vcl.ComCtrls;

type
  TFormAssignCompetitor = class(TForm)
    PanelControls: TPanel;
    Label3: TLabel;
    EditBIB: TEdit;
    ButtonOK: TButton;
    ButtonCancel: TButton;
    PanelGrid: TPanel;
    ListViewCompetitors: TListView;
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  FormAssignCompetitor: TFormAssignCompetitor;

implementation

{$R *.dfm}

end.
