unit uPassingProtocolGrid;

interface

uses
  Classes, Controls, VCL.Grids, Generics.Collections, SysUtils, Types,
  SmartTiming.DecoderInterface;

type
  TFNOnNewLap = procedure(ALapNumber: integer) of object;
  TFNIsKnownPassing = function(APassing: TMyLapsP3Passing): boolean of object;
  TFNOnTextToShow = procedure(APassing: TMyLapsP3Passing; var AText: string) of object;

  TPassingList = class(TDictionary<integer, TMyLapsP3Passing>)
  private
    FTransponderPassing: TList<string>;
  public
    constructor Create;
    destructor Destroy; override;

    function IsInPassingList(const ATransponderId: string): boolean;
    procedure AddPassing(APassing: TMyLapsP3Passing);
    procedure DoClear;
  end;


  TPassingProtocolGrid = class(TDrawGrid)
  private
    FLaps: TArray<TPassingList>;
    FCurrentLap: integer;
    FOnNewLap: TFNOnNewLap;
    FOnIsKnownPassing: TFNIsKnownPassing;
    FOnGetTextToShow: TFNOnTextToShow;
    procedure ClearLaps;

  protected
    procedure OnDrawPassing(ASender: TObject; ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState);

  public
    constructor Create(AOwner: TComponent); override;
    procedure Initialize(ALapCount: integer);
    function AddPassing(APassing: TMyLapsP3Passing): boolean;

    property OnNewLap: TFNOnNewLap read FOnNewLap write FOnNewLap;
    property OnIsKnownPassing: TFNIsKnownPassing read FOnIsKnownPassing write FOnIsKnownPassing;
    property OnGetTextToShow: TFNOnTextToShow read FOnGetTextToShow write FOnGetTextToShow;
  end;

implementation

{==============================================================================}
constructor TPassingList.Create;
begin
  inherited Create;
  FTransponderPassing := TList<string>.Create;
end;

{==============================================================================}
destructor TPassingList.Destroy;
begin
  try
    FreeAndNil(FTransponderPassing);
  finally
    inherited Destroy;
  end;
end;

{==============================================================================}
function TPassingList.IsInPassingList(const ATransponderId: string): boolean;
begin
  result := FTransponderPassing.Contains(ATransponderId);
end;

{==============================================================================}
procedure TPassingList.AddPassing(APassing: TMyLapsP3Passing);
begin
  FTransponderPassing.Add(APassing.TransponderId);
  Add(FTransponderPassing.Count - 1, APassing);
end;

{==============================================================================}
procedure TPassingList.DoClear;
begin
  Clear;
  FTransponderPassing.Clear;
end;

{==============================================================================}
constructor TPassingProtocolGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  if not (AOwner is TWinControl) then
    Exit;
  Parent := TWinControl(AOwner);
  Align := alClient;
  FixedCols := 0;
  FixedRows := 1;
  ColCount := 0;
  RowCount := 1;
  DefaultColAlignment := taCenter;
  OnDrawCell := OnDrawPassing;
  FOnNewLap := nil;
end;


{==============================================================================}
procedure TPassingProtocolGrid.Initialize(ALapCount: integer);
var
  i: integer;
begin
  ClearLaps;
  ColCount := ALapCount + 1;
  RowCount := 1;

  SetLength(FLaps, ColCount);
  for i := 0 to High(FLaps) do
    FLaps[i] := TPassingList.Create;
  FCurrentLap := 0;
end;

{==============================================================================}
procedure TPassingProtocolGrid.ClearLaps;
var
  lPassingList: TPassingList;
begin
  for lPassingList in FLaps do
    FreeAndNil(lPassingList);
end;

{==============================================================================}
function TPassingProtocolGrid.AddPassing(APassing: TMyLapsP3Passing): boolean;
var
  lPassingList: TPassingList;
begin
  if FCurrentLap >= Length(FLaps) then
    Exit(false);
  lPassingList := FLaps[FCurrentLap];
  if lPassingList.IsInPassingList(APassing.TransponderId) then
    Exit(false);
//  begin
//    Inc(FCurrentLap);
//    if assigned(FOnNewLap) then
//      FOnNewLap(FCurrentLap);
//    lPassingList := FLaps[FCurrentLap];
//  end;
  result := true;
  lPassingList.AddPassing(APassing);
  if lPassingList.Count >= RowCount then
    RowCount := lPassingList.Count + 1;
  InvalidateCell(ColCount - 1, RowCount - 1);
end;

{==============================================================================}
procedure TPassingProtocolGrid.OnDrawPassing(ASender: TObject; ACol, ARow: Longint; ARect: TRect; AState: TGridDrawState);
var
  lPassingList: TPassingList;
  lPassing: TMyLapsP3Passing;
  x, y : Integer;
  lText: string;
  lIsKnown: boolean;
begin
  if (ACol < 0) or (ACol > High(FLaps)) then
    Exit;

  lPassingList := FLaps[ACol];
  if lPassingList = nil then
    Exit;

  if ARow > lPassingList.Count + 1 then
    Exit;

  if not lPassingList.TryGetValue(ARow - 1, lPassing) then
    Exit;

  lIsKnown := true;
  if Assigned(FOnIsKnownPassing) then
    lIsKnown := FOnIsKnownPassing(lPassing);
  if lIsKnown then
  begin
    lText := lPassing.TransponderShortId.ToString;
    if Assigned(FOnGetTextToShow) then
      FOnGetTextToShow(lPassing, lText);
  end
  else
    lText := '???';

  x := ARect.Left + (ARect.Right - ARect.Left - Canvas.TextWidth(lText)) div 2;
  y := ARect.Top + (ARect.Bottom - ARect.Top - Canvas.TextHeight(lText)) div 2;
  Canvas.TextOut(x, y, lText);
end;


end.
