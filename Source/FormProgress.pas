unit FormProgress;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TFormProgressIndicator = class(TForm)
    Label1: TLabel;
    Animate: TAnimate;
    procedure FormShow(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

implementation

{$R *.dfm}

procedure TFormProgressIndicator.FormShow(Sender: TObject);
begin
  if not Animate.Visible then
    Exit;

  Animate.Active := false;
  Animate.ResName := 'GEARS';
  Animate.Active := true;
end;

end.
