unit FormTime;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Mask;

type
  TFormEditTime = class(TForm)
    PanelButtons: TPanel;
    ButtonOK: TButton;
    ButtonCancel: TButton;
    EditTime: TMaskEdit;
    Label1: TLabel;

  private
    FHour: Word;
    FMin: Word;
    FSec: Word;
    FMs: Word;

    procedure SetTime(ATime: TDatetime);
    function GetTime: TDatetime;

  public
    property Time: TDatetime read GetTime write SetTime;
  end;

implementation

{$R *.dfm}

procedure TFormEditTime.SetTime(ATime: TDatetime);
begin
  DecodeTime(ATime, FHour, FMin, FSec, FMs);
  EditTime.Text := FormatDatetime('HH:mm:ss.zzz', ATime);
end;

function TFormEditTime.GetTime: TDatetime;
var
  lFormatSettings: TFormatSettings;
begin
  lFormatSettings.TimeSeparator := ':';
  lFormatSettings.DecimalSeparator := '.';
  lFormatSettings.LongTimeFormat := 'HH:mm:ss.zzz';
  result := StrToTime(EditTime.Text, lFormatSettings);
end;

end.
