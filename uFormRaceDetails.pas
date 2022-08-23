unit uFormRaceDetails;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Mask,
  Vcl.ExtCtrls,
  SmartTiming.Database, SmartTiming.Consts, SmartTiming.Tools;
type
  TFormRaceDetails = class(TForm)
    PanelButtons: TPanel;
    ButtonOK: TButton;
    ButtonCancel: TButton;
    PanelMain: TPanel;
    EditTitle: TEdit;
    Bezeichnung: TLabel;
    Label1: TLabel;
    EditTime: TMaskEdit;
    ComboBoxRaceType: TComboBox;
    Label2: TLabel;
    EditLapCount: TEdit;
    LabelLapCount: TLabel;
    CBFirstPassingCounts: TCheckBox;
    EditDistance: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    EditMinLapDuration: TMaskEdit;
    EditDate: TMaskEdit;
    procedure ButtonOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FRaceDataObject: TRaceDataObject;
    function GetStartDatetime: TDatetime;
  public
    property RaceDataObject: TRaceDataObject read FRaceDataObject write FRaceDataObject;
  end;

var
  FormRaceDetails: TFormRaceDetails;

implementation

{$R *.dfm}

{==============================================================================}
procedure TFormRaceDetails.FormCreate(Sender: TObject);
var
  lRaceType: TRaceType;
begin
  FRaceDataObject := nil;
  for lRaceType := rtUnknown to rtIndividualTimeTrial do
    ComboBoxRaceType.Items.Add(SmartTimingTools.GetRaceTypeStringFromEnum(lRaceType));
  EditDate.Text := FormatDatetime('dd.mm.yy', Now);
  EditTime.Text := FormatDatetime('hh:mm:ss', Now);
end;

{==============================================================================}
function TFormRaceDetails.GetStartDatetime: TDatetime;
var
  lDateString: string;
  lTimeString: string;
begin
  lDateString := EditDate.Text;
  result := StrToDate(lDateString);
  lTimeString := EditTime.Text;
  result := result + StrToTime(lTimeString);
end;

{==============================================================================}

{==============================================================================}
procedure TFormRaceDetails.ButtonOKClick(Sender: TObject);
begin
  if FRaceDataObject = nil then
    FRaceDataObject := TRaceDataObject.Create(nil);
  FRaceDataObject.Title := EditTitle.Text;
  FRaceDataObject.Starttime := GetStartDatetime;
  FRaceDataObject.RaceType := SmartTimingTools.GetRaceTypeEnumFromString(ComboBoxRaceType.Text);
  FRaceDataObject.LapCount := StrToInt(EditLapCount.Text);
  FRaceDataObject.Distance := StrToFloat(EditDistance.Text);
  FRaceDataObject.FirstPassingCounts := CBFirstPassingCounts.Checked;
  FRaceDataObject.MinLapDuration := StrToTime(EditMinLapDuration.Text) / 60;
//  FRaceDataObject.RaceStatus := SmartTimingTools
end;

end.
