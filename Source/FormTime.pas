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
    ButtonReset: TButton;
    EditTime: TMaskEdit;
    Label1: TLabel;
    LabelOverride: TLabel;
    procedure ButtonResetClick(Sender: TObject);

  private
    FHour: Word;
    FMin: Word;
    FSec: Word;
    FMs: Word;
    FOverrideActive: Boolean;

    procedure SetTime(ATime: TDatetime);
    function GetTime: TDatetime;
    procedure SetOverrideActive(AValue: Boolean);

  public
    property Time: TDatetime read GetTime write SetTime;
    (* True when PARTICIPATION.FINISHTIMEOVERRIDE is set — enables reset. *)
    property OverrideActive: Boolean read FOverrideActive write SetOverrideActive;
  end;

implementation

{$R *.dfm}

uses
  SmartTiming.Consts;

procedure TFormEditTime.SetOverrideActive(AValue: Boolean);
begin
  FOverrideActive := AValue;
  LabelOverride.Caption := cMessagesFinishTimeOverrideHint;
  ButtonReset.Caption := cMessagesFinishTimeReset;
  LabelOverride.Visible := AValue;
  ButtonReset.Visible := AValue;
  ButtonReset.Enabled := AValue;
end;

procedure TFormEditTime.ButtonResetClick(Sender: TObject);
begin
  ModalResult := mrRetry;
end;

procedure TFormEditTime.SetTime(ATime: TDatetime);
begin
  DecodeTime(ATime, FHour, FMin, FSec, FMs);
  EditTime.Text := FormatDatetime('hh:nn:ss.zzz', ATime);
end;

function TFormEditTime.GetTime: TDatetime;
var
  lFormatSettings: TFormatSettings;
begin
  lFormatSettings := TFormatSettings.Create;
  lFormatSettings.TimeSeparator := ':';
  lFormatSettings.DecimalSeparator := '.';
  lFormatSettings.LongTimeFormat := 'hh:nn:ss.zzz';
  result := StrToTime(EditTime.Text, lFormatSettings);
end;

end.
