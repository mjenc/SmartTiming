unit ValueHistoryChart;

interface

uses
  Classes, Controls, ExtCtrls, Graphics, SysUtils;

type
  TValueHistoryChart = class (TPanel)
  private
    FValues: TArray<Double>;
    FMaxBufferSize: Integer;
    FMinValue: Double;
    FMaxValue: Double;
    FGreenAreaFrom: Double;
    FGreenAreaTo: Double;
    FYellowAreaFrom: Double;
    FYellowAreaTo: Double;
    FRedAreaFrom: Double;
    FRedAreaTo: Double;
    FValueLabel: string;
    procedure ShiftBufferLeft(ACount: integer);
    function GetColorForValue(AValue: Double): TColor;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Paint; override;
    procedure AddValue(AValue: Double);

    property ValueLabel: string read FValueLabel write FValueLabel;
    property MaxBufferSize: integer read FMaxBufferSize write FMaxBufferSize default 120;
    property MinValue: Double read FMinValue write FMinValue;
    property MaxValue: Double read FMaxValue write FMaxValue;
    property GreenAreaFrom: Double read FGreenAreaFrom write FGreenAreaFrom;
    property GreenAreaTo: Double read FGreenAreaTo write FGreenAreaTo;
    property YellowAreaFrom: Double read FYellowAreaFrom write FYellowAreaFrom;
    property YellowAreaTo: Double read FYellowAreaTo write FYellowAreaTo;
    property RedAreaFrom: Double read FRedAreaFrom write FRedAreaFrom;
    property RedAreaTo: Double read FRedAreaTo write FRedAreaTo;
  end;


implementation

{==============================================================================}
constructor TValueHistoryChart.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMaxBufferSize := 120;

  FMinValue := 0.0;
  FMaxValue := 100.0;

  FGreenAreaFrom := FMinValue;
  FGreenAreaTo := 49.0;
  FYellowAreaFrom := 49.0;
  FYellowAreaTo := 59.0;
  FRedAreaFrom := 59.0;
  FRedAreaTo := FMaxValue;
  AddValue(0.0);
end;

{==============================================================================}
procedure TValueHistoryChart.ShiftBufferLeft(ACount: integer);
var
  i: integer;
  j: integer;
begin
  j := 0;
  for i := ACount to Length(FValues) - 1 do
  begin
    FValues[j] := FValues[i];
    Inc(j);
  end;
end;

{==============================================================================}
function TValueHistoryChart.GetColorForValue(AValue: Double): TColor;
begin
// TODO
// if (AValue >= FGreenAreaFrom) and (AValue
end;

{==============================================================================}
procedure TValueHistoryChart.AddValue(AValue: Double);
var
  lLength: Integer;
begin
  lLength := Length(FValues);
  if lLength < FMaxBufferSize then
  begin
    Inc(lLength);
    SetLength(FValues, lLength);
  end
  else
    ShiftBufferLeft(1);
  FValues[lLength - 1] := AValue;
  Invalidate;
end;

{==============================================================================}
procedure TValueHistoryChart.Paint;
var
  i: integer;
  lScale: Double;
begin
  if csDesigning in ComponentState then
  begin
    Canvas.Pen.Style := psDash;
    Canvas.Brush.Style := bsClear;
    Canvas.Rectangle(0, 0, Width, Height);
  end;

  BringToFront;
  Canvas.Brush.Color := clWhite;
  Canvas.FillRect(Rect(0, 0, Width, Height));

  lScale :=  Height / FMaxValue;
  for i := 0 to High(FValues) do
  begin
    if FValues[i] > 60 then
      Canvas.Pen.Color := clRed
    else if FValues[i] > 46 then
      Canvas.Pen.Color := clWebOrange
    else
      Canvas.Pen.Color := clGreen;
    Canvas.MoveTo(i + 1, Height);
    Canvas.LineTo(i + 1, Height - 1 - Trunc(lScale * (FValues[i] - FMinValue)));
  end;
  if Length(FValues) > 0 then
    Canvas.TextOut(2,5, FValueLabel + ' ' + FValues[High(FValues)].ToString);
end;

end.
