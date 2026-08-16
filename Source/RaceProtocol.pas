unit RaceProtocol;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms, Vcl.Graphics, System.Types,
  System.Generics.Collections, System.Math;

type
  TPassingType = (ptRider, ptWarmUp, ptStartRace, ptNeutralize, ptLastLap, ptFinish, ptStop, ptNewLeader);

  TRaceProtocolLayoutMode = (rplCompact, rplSingleColumn);

  TPassingItem = record
    Bib: Integer;
    HasDot: Boolean;
    PassingType: TPassingType;
  end;

  TRiderItem = record
    Bib: Integer;
    LapCount: Integer;
    LastLap: Integer;
  end;

  TLapColumn = class
  private
    FItems: TList<TPassingItem>;
  public
    constructor Create;
    destructor Destroy; override;
    property Items: TList<TPassingItem> read FItems;
  end;

  TRaceProtocol = class(TCustomControl)
  private
    FColumns: TObjectList<TLapColumn>;
    FRidersLaps: TDictionary<Integer, TRiderItem>;
    FCurrentColumnIndex: Integer;
    FLapCountingActive: Boolean;
    FAllowOneMoreColumnBreak: Boolean;
    FLayoutMode: TRaceProtocolLayoutMode;
    FAutoScroll: Boolean;

    FItemWidth: Integer;
    FItemHeight: Integer;
    FHeaderHeight: Integer;
    FColMargin: Integer;

    function StartNewLap: TLapColumn;
    procedure DrawHeader(Canvas: TCanvas; Rect: TRect; LapIndex, Count: Integer);
    procedure DrawItem(Canvas: TCanvas; X, Y: Integer; Item: TPassingItem);
    procedure HandleSpecialPassings(APassingType: TPassingType);
    procedure MoveTrailingFinishFlags(AFromCol, AToCol: TLapColumn);
    procedure AddFinishFlag(const AItem: TPassingItem);
    procedure FreezeLapColumns;
    function GetViewportSize(out AWidth, AHeight: Integer): Boolean;
    function GetItemsPerColumnHeight(AViewportHeight: Integer): Integer;
    function CalcColumnWidth(AItemCount, AItemsPerColHeight: Integer): Integer;
    procedure CalcContentSize(out AWidth, AHeight: Integer);
    function ColumnLeft(AColumnIndex: Integer; AItemsPerColHeight: Integer): Integer;
    procedure SetLayoutMode(AValue: TRaceProtocolLayoutMode);
    procedure SetAutoScrollEnabled(AValue: Boolean);
    procedure ScrollIntoViewLatest;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddPassing(ARiderNumber: Integer; APassingType: TPassingType = ptRider);
    procedure Clear;
    procedure UpdateContentSize;

    property LayoutMode: TRaceProtocolLayoutMode read FLayoutMode write SetLayoutMode;
    property AutoScroll: Boolean read FAutoScroll write SetAutoScrollEnabled;
  published
    property Align;
    property Anchors;
    property Color default clWhite;
    property Font;
    property ParentColor;
    property ParentFont;
    property Height;
    property Width;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TRaceProtocol]);
end;

{ TLapColumn }

constructor TLapColumn.Create;
begin
  FItems := TList<TPassingItem>.Create;
end;

destructor TLapColumn.Destroy;
begin
  FItems.Free;
  inherited;
end;

{ TRaceProtocol }

constructor TRaceProtocol.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  DoubleBuffered := True;
  Color := clWhite;
  Width := 600;
  Height := 400;

  FItemWidth := 35;
  FItemHeight := 20;
  FHeaderHeight := 30;
  FColMargin := 2;

  FColumns := TObjectList<TLapColumn>.Create(True);
  FRidersLaps := TDictionary<Integer, TRiderItem>.Create;

  FColumns.Add(TLapColumn.Create);
  FCurrentColumnIndex := 0;
  FLapCountingActive := False;
  FAllowOneMoreColumnBreak := False;
  FLayoutMode := rplCompact;
  FAutoScroll := True;
end;

destructor TRaceProtocol.Destroy;
begin
  FRidersLaps.Free;
  FColumns.Free;
  inherited;
end;

procedure TRaceProtocol.SetLayoutMode(AValue: TRaceProtocolLayoutMode);
begin
  if FLayoutMode = AValue then
    Exit;
  FLayoutMode := AValue;
  UpdateContentSize;
  if Parent <> nil then
    Invalidate;
end;

procedure TRaceProtocol.SetAutoScrollEnabled(AValue: Boolean);
begin
  FAutoScroll := AValue;
end;

function TRaceProtocol.GetViewportSize(out AWidth, AHeight: Integer): Boolean;
begin
  Result := False;
  AWidth := ClientWidth;
  AHeight := ClientHeight;
  if (Parent <> nil) and (Parent is TScrollBox) then
  begin
    AWidth := TScrollBox(Parent).ClientWidth;
    AHeight := TScrollBox(Parent).ClientHeight;
    Result := True;
  end
  else if Parent <> nil then
  begin
    AWidth := Parent.ClientWidth;
    AHeight := Parent.ClientHeight;
    Result := True;
  end;
  if AWidth < 1 then
    AWidth := 1;
  if AHeight < 1 then
    AHeight := 1;
end;

function TRaceProtocol.GetItemsPerColumnHeight(AViewportHeight: Integer): Integer;
var
  lTotalItemHeight: Integer;
begin
  if FLayoutMode = rplSingleColumn then
    Exit(MaxInt);

  lTotalItemHeight := FItemHeight + FColMargin;
  if (AViewportHeight - FHeaderHeight) > lTotalItemHeight then
    Result := (AViewportHeight - FHeaderHeight) div lTotalItemHeight
  else
    Result := 1;
end;

function TRaceProtocol.CalcColumnWidth(AItemCount, AItemsPerColHeight: Integer): Integer;
var
  lSubCols: Integer;
begin
  if AItemCount <= 0 then
    lSubCols := 1
  else if FLayoutMode = rplSingleColumn then
    lSubCols := 1
  else
    lSubCols := Ceil(AItemCount / AItemsPerColHeight);
  Result := lSubCols * (FItemWidth + FColMargin) + FColMargin;
end;

function TRaceProtocol.ColumnLeft(AColumnIndex: Integer; AItemsPerColHeight: Integer): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to AColumnIndex - 1 do
    Result := Result + CalcColumnWidth(FColumns[i].Items.Count, AItemsPerColHeight) + 2;
end;

procedure TRaceProtocol.CalcContentSize(out AWidth, AHeight: Integer);
var
  i: Integer;
  lViewportW, lViewportH: Integer;
  lItemsPerCol: Integer;
  lColWidth: Integer;
  lMaxItems: Integer;
  lTotalItemHeight: Integer;
begin
  GetViewportSize(lViewportW, lViewportH);
  lItemsPerCol := GetItemsPerColumnHeight(lViewportH);
  lTotalItemHeight := FItemHeight + FColMargin;

  AWidth := 0;
  lMaxItems := 0;
  for i := 0 to FColumns.Count - 1 do
  begin
    lColWidth := CalcColumnWidth(FColumns[i].Items.Count, lItemsPerCol);
    AWidth := AWidth + lColWidth + 2;
    if FColumns[i].Items.Count > lMaxItems then
      lMaxItems := FColumns[i].Items.Count;
  end;
  if AWidth < lViewportW then
    AWidth := lViewportW;

  if FLayoutMode = rplSingleColumn then
    AHeight := FHeaderHeight + FColMargin + Max(1, lMaxItems) * lTotalItemHeight
  else
    AHeight := lViewportH;
  if AHeight < lViewportH then
    AHeight := lViewportH;
end;

procedure TRaceProtocol.UpdateContentSize;
var
  lWidth, lHeight: Integer;
begin
  if Parent = nil then
    Exit;
  CalcContentSize(lWidth, lHeight);
  if (Width <> lWidth) or (Height <> lHeight) then
  begin
    SetBounds(Left, Top, lWidth, lHeight);
    if Parent is TScrollBox then
      TScrollBox(Parent).Realign;
  end;
end;

procedure TRaceProtocol.ScrollIntoViewLatest;
var
  lScrollBox: TScrollBox;
  lViewportW, lViewportH: Integer;
  lItemsPerCol: Integer;
  lLeft: Integer;
  lColWidth: Integer;
  lTarget: Integer;
  lItemCount: Integer;
  lTotalItemHeight: Integer;
  lBottom: Integer;
begin
  if not FAutoScroll then
    Exit;
  if not (Parent is TScrollBox) then
    Exit;
  lScrollBox := TScrollBox(Parent);

  GetViewportSize(lViewportW, lViewportH);
  lItemsPerCol := GetItemsPerColumnHeight(lViewportH);
  lLeft := ColumnLeft(FCurrentColumnIndex, lItemsPerCol);
  lColWidth := CalcColumnWidth(FColumns[FCurrentColumnIndex].Items.Count, lItemsPerCol);

  lTarget := lLeft + lColWidth - lViewportW;
  if lTarget < 0 then
    lTarget := 0;
  lScrollBox.HorzScrollBar.Position := lTarget;

  if FLayoutMode = rplSingleColumn then
  begin
    lTotalItemHeight := FItemHeight + FColMargin;
    lItemCount := FColumns[FCurrentColumnIndex].Items.Count;
    lBottom := FHeaderHeight + FColMargin + lItemCount * lTotalItemHeight;
    lTarget := lBottom - lViewportH;
    if lTarget < 0 then
      lTarget := 0;
    lScrollBox.VertScrollBar.Position := lTarget;
  end;
end;

procedure TRaceProtocol.Clear;
begin
  FColumns.Clear;
  FRidersLaps.Clear;
  FColumns.Add(TLapColumn.Create);
  FCurrentColumnIndex := 0;
  FLapCountingActive := False;
  FAllowOneMoreColumnBreak := False;
  UpdateContentSize;
  if Parent <> nil then
    Invalidate;
end;

function TRaceProtocol.StartNewLap: TLapColumn;
begin
  FColumns.Add(TLapColumn.Create);
  Inc(FCurrentColumnIndex);
  Result := FColumns[FCurrentColumnIndex];
end;

procedure TRaceProtocol.MoveTrailingFinishFlags(AFromCol, AToCol: TLapColumn);
var
  lMoved: TList<TPassingItem>;
  lItem: TPassingItem;
  i: Integer;
begin
  if (AFromCol = nil) or (AToCol = nil) or (AFromCol = AToCol) then
    Exit;

  lMoved := TList<TPassingItem>.Create;
  try
    while AFromCol.Items.Count > 0 do
    begin
      lItem := AFromCol.Items[AFromCol.Items.Count - 1];
      if lItem.PassingType <> ptFinish then
        Break;
      lMoved.Insert(0, lItem);
      AFromCol.Items.Delete(AFromCol.Items.Count - 1);
    end;
    for i := 0 to lMoved.Count - 1 do
      AToCol.Items.Add(lMoved[i]);
  finally
    lMoved.Free;
  end;
end;

procedure TRaceProtocol.FreezeLapColumns;
begin
  FLapCountingActive := False;
  FAllowOneMoreColumnBreak := False;
end;

procedure TRaceProtocol.AddFinishFlag(const AItem: TPassingItem);
var
  CurrentCol: TLapColumn;
begin
  if FLayoutMode = rplSingleColumn then
  begin
    (* Own column for FIN, then a fresh column for finishers. *)
    if FColumns[FCurrentColumnIndex].Items.Count > 0 then
      StartNewLap;
    CurrentCol := FColumns[FCurrentColumnIndex];
    CurrentCol.Items.Add(AItem);
    StartNewLap;
    FreezeLapColumns;
    Exit;
  end;

  (* Compact: keep FIN in the current column; allow one more rider-driven
     column break so MoveTrailingFinishFlags can place FIN before the winner,
     then freeze further lap columns. *)
  CurrentCol := FColumns[FCurrentColumnIndex];
  CurrentCol.Items.Add(AItem);
  if FLapCountingActive then
    FAllowOneMoreColumnBreak := True
  else
    FreezeLapColumns;
end;

procedure TRaceProtocol.AddPassing(ARiderNumber: Integer; APassingType: TPassingType = ptRider);
var
  CurrentCol: TLapColumn;
  PreviousCol: TLapColumn;
  Item: TPassingItem;
  CurrentRider: TRiderItem;
  i: Integer;
begin
  CurrentCol := FColumns[FCurrentColumnIndex];
  Item.Bib := ARiderNumber;
  Item.HasDot := False;
  Item.PassingType := APassingType;

  if APassingType = ptFinish then
  begin
    AddFinishFlag(Item);
    UpdateContentSize;
    if Parent <> nil then
      Invalidate;
    ScrollIntoViewLatest;
    Exit;
  end;

  if APassingType <> ptRider then
  begin
    HandleSpecialPassings(APassingType);
    CurrentCol := FColumns[FCurrentColumnIndex];
    CurrentCol.Items.Add(Item);
    UpdateContentSize;
    if Parent <> nil then
      Invalidate;
    ScrollIntoViewLatest;
    Exit;
  end;

  if FLapCountingActive then
  begin
    for i := 0 to CurrentCol.Items.Count - 1 do
    begin
      if CurrentCol.Items[i].Bib = ARiderNumber then
      begin
        PreviousCol := CurrentCol;
        CurrentCol := StartNewLap;
        MoveTrailingFinishFlags(PreviousCol, CurrentCol);
        Break;
      end;
    end;
  end;

  if not FRidersLaps.TryGetValue(ARiderNumber, CurrentRider) then
  begin
    CurrentRider.Bib := ARiderNumber;
    CurrentRider.LapCount := 0;
    CurrentRider.LastLap := 0;
  end;

  Item.HasDot := FLapCountingActive and
    (CurrentRider.LapCount < FCurrentColumnIndex);
  if FLapCountingActive then
    Inc(CurrentRider.LapCount);

  FRidersLaps.AddOrSetValue(ARiderNumber, CurrentRider);
  CurrentCol.Items.Add(Item);

  (* After FIN: freeze once the finish column is settled (with or without a break). *)
  if FAllowOneMoreColumnBreak then
    FreezeLapColumns;

  UpdateContentSize;
  if Parent <> nil then
    Invalidate;
  ScrollIntoViewLatest;
end;

procedure TRaceProtocol.HandleSpecialPassings(APassingType: TPassingType);
begin
  (* New lap columns only while counting is active: after Start, before Finish.
     Finish is handled in AddFinishFlag (layout-specific). *)
  case APassingType of
    ptWarmUp, ptNeutralize, ptStop:
      FreezeLapColumns;
    ptStartRace:
      begin
        FLapCountingActive := True;
        FAllowOneMoreColumnBreak := False;
      end;
    ptNewLeader:
      if FLapCountingActive and not FAllowOneMoreColumnBreak then
        StartNewLap;
  end;
end;

procedure TRaceProtocol.DrawHeader(Canvas: TCanvas; Rect: TRect; LapIndex, Count: Integer);
var
  Txt: string;
  CountTxt: string;
  TxtSize: TSize;
begin
  Canvas.Brush.Color := $00E0E0E0;
  Canvas.FillRect(Rect);

  Canvas.Pen.Color := clWhite;
  Canvas.Pen.Width := 2;
  Canvas.MoveTo(Rect.Right - 1, Rect.Top);
  Canvas.LineTo(Rect.Right - 1, Rect.Bottom);

  Canvas.Font.Assign(Self.Font);
  Canvas.Font.Size := 14;
  Txt := IntToStr(LapIndex);

  TxtSize := Canvas.TextExtent(Txt);
  Canvas.Brush.Style := bsClear;
  Canvas.Font.Color := clGray;
  Canvas.TextOut(Rect.Left + (Rect.Width - TxtSize.cx) div 2 + 1, Rect.Top + 2 + 1, Txt);
  Canvas.Font.Color := clWhite;
  Canvas.TextOut(Rect.Left + (Rect.Width - TxtSize.cx) div 2, Rect.Top + 2, Txt);

  CountTxt := IntToStr(Count);
  Canvas.Font.Size := 7;
  Canvas.Font.Color := clRed;
  TxtSize := Canvas.TextExtent(CountTxt);
  Canvas.TextOut(Rect.Right - TxtSize.cx - 2, Rect.Bottom - TxtSize.cy - 2, CountTxt);
end;

procedure TRaceProtocol.DrawItem(Canvas: TCanvas; X, Y: Integer; Item: TPassingItem);
var
  R: TRect;
  Txt: string;
  TxtSize: TSize;
begin
  R := Rect(X, Y, X + FItemWidth, Y + FItemHeight);
  InflateRect(R, -1, -1);

  case Item.PassingType of
    ptRider:
      begin
        Canvas.Pen.Color := $00008000;
        Txt := IntToStr(Item.Bib);
      end;
    ptWarmUp:
      begin
        Canvas.Pen.Color := clPurple;
        Txt := 'WU';
      end;
    ptStartRace:
      begin
        Canvas.Pen.Color := clGreen;
        Txt := 'STRT';
      end;
    ptNeutralize:
      begin
        Canvas.Pen.Color := clYellow;
        Txt := 'NEU';
      end;
    ptLastLap:
      begin
        Canvas.Pen.Color := clWebRosyBrown;
        Txt := 'BELL';
      end;
    ptFinish:
      begin
        Canvas.Pen.Color := clBlack;
        Txt := 'FIN';
      end;
    ptStop:
      begin
        Canvas.Pen.Color := clRed;
        Txt := 'STP';
      end;
    ptNewLeader:
      begin
        Canvas.Pen.Color := clWhite;
        Txt := 'NL';
      end;
  end;
  Canvas.Pen.Width := 2;
  Canvas.Brush.Color := clWhite;
  Canvas.Brush.Style := bsSolid;
  Canvas.Rectangle(R);

  Canvas.Font.Assign(Self.Font);
  Canvas.Font.Style := [fsBold];
  Canvas.Font.Color := clBlack;
  TxtSize := Canvas.TextExtent(Txt);

  Canvas.Brush.Style := bsClear;
  Canvas.TextOut(R.Left + (R.Width - TxtSize.cx) div 2,
                 R.Top + (R.Height - TxtSize.cy) div 2, Txt);

  if Item.HasDot then
  begin
    Canvas.Brush.Color := clBlack;
    Canvas.Pen.Color := clBlack;
    Canvas.Rectangle(R.Right - 5, R.Top + 2, R.Right - 2, R.Top + 5);
  end;
end;

procedure TRaceProtocol.Paint;
var
  i, j: Integer;
  ColObj: TLapColumn;
  XOffset: Integer;
  EffectiveColWidth: Integer;
  ItemsPerColHeight: Integer;
  SubCols: Integer;
  TotalItemHeight: Integer;
  SubColIdx: Integer;
  RowIdx: Integer;
  DrawX, DrawY: Integer;
  lViewportW, lViewportH: Integer;
begin
  inherited;

  Canvas.Brush.Color := Color;
  Canvas.FillRect(ClientRect);

  GetViewportSize(lViewportW, lViewportH);
  TotalItemHeight := FItemHeight + FColMargin;
  ItemsPerColHeight := GetItemsPerColumnHeight(lViewportH);

  XOffset := 0;
  for i := 0 to FColumns.Count - 1 do
  begin
    ColObj := FColumns[i];

    if FLayoutMode = rplSingleColumn then
      SubCols := 1
    else if ColObj.Items.Count > 0 then
      SubCols := Ceil(ColObj.Items.Count / ItemsPerColHeight)
    else
      SubCols := 1;

    EffectiveColWidth := SubCols * (FItemWidth + FColMargin) + FColMargin;

    DrawHeader(Canvas, Rect(XOffset, 0, XOffset + EffectiveColWidth, FHeaderHeight),
               i, ColObj.Items.Count);

    for j := 0 to ColObj.Items.Count - 1 do
    begin
      if FLayoutMode = rplSingleColumn then
      begin
        SubColIdx := 0;
        RowIdx := j;
      end
      else
      begin
        SubColIdx := j div ItemsPerColHeight;
        RowIdx := j mod ItemsPerColHeight;
      end;

      DrawX := XOffset + FColMargin + (SubColIdx * (FItemWidth + FColMargin));
      DrawY := FHeaderHeight + FColMargin + (RowIdx * TotalItemHeight);
      DrawItem(Canvas, DrawX, DrawY, ColObj.Items[j]);
    end;

    Canvas.Pen.Color := clSilver;
    Canvas.Pen.Width := 1;
    Canvas.MoveTo(XOffset + EffectiveColWidth, 0);
    Canvas.LineTo(XOffset + EffectiveColWidth, ClientHeight);

    XOffset := XOffset + EffectiveColWidth + 2;
  end;
end;

end.
