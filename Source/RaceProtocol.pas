unit RaceProtocol;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.Graphics, System.Types,
  System.Generics.Collections, System.Math;

type
  TPassingType = (ptRider, ptWarmUp, ptStartRace, ptNeutralize, ptLastLap, ptFinish, ptStop, ptNewLeader);

  // Datenstruktur für einen einzelnen Eintrag (ein Kästchen)
  TPassingItem = record
    Bib: Integer;
    HasDot: Boolean; // True, wenn eine Runde verpasst wurde
    PassingType: TPassingType;
  end;

  TRiderItem = record
    Bib: Integer;
    LapCount: Integer;
    LastLap: Integer;
  end;

  // Datenstruktur für eine ganze Spalte (Runde)
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
    FLapCountingActive: boolean;

    // Design-Konstanten (könnten auch Properties sein)
    FItemWidth: Integer;
    FItemHeight: Integer;
    FHeaderHeight: Integer;
    FColMargin: Integer;

    function StartNewLap: TLapColumn;
    procedure DrawHeader(Canvas: TCanvas; Rect: TRect; LapIndex, Count: Integer);
    procedure DrawItem(Canvas: TCanvas; X, Y: Integer; Item: TPassingItem);
    procedure HandleSpecialPassings(APassingType: TPassingType);
    procedure MoveTrailingFinishFlags(AFromCol, AToCol: TLapColumn);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddPassing(ARiderNumber: Integer; APassingType: TPassingType = ptRider);
    procedure Clear;
  published
    property Align;
    property Anchors;
    property Color default clWhite;
    property Font;
    property ParentColor;
    property ParentFont;
    // Größe der Komponente explizit freigeben
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

  // Design-Einstellungen (anpassbar)
  FItemWidth := 35;
  FItemHeight := 20;
  FHeaderHeight := 30;
  FColMargin := 2; // Abstand zwischen den Kästchen

  FColumns := TObjectList<TLapColumn>.Create(True);
  FRidersLaps := TDictionary<Integer, TRiderItem>.Create;

  // Initial immer die erste Spalte (Runde 1) anlegen
  FColumns.Add(TLapColumn.Create);
  FCurrentColumnIndex := 0;
  FLapCountingActive := false;
end;

destructor TRaceProtocol.Destroy;
begin
  FRidersLaps.Free;
  FColumns.Free;
  inherited;
end;

procedure TRaceProtocol.Clear;
begin
  FColumns.Clear;
  FRidersLaps.Clear;
  FColumns.Add(TLapColumn.Create);
  FCurrentColumnIndex := 0;
  FLapCountingActive := False;
  Invalidate;
end;

function TRaceProtocol.StartNewLap: TLapColumn;
begin
  FColumns.Add(TLapColumn.Create);
  Inc(FCurrentColumnIndex);
  result := FColumns[FCurrentColumnIndex];
end;

procedure TRaceProtocol.MoveTrailingFinishFlags(AFromCol, AToCol: TLapColumn);
var
  lMoved: TList<TPassingItem>;
  lItem: TPassingItem;
  i: Integer;
begin
  if (AFromCol = nil) or (AToCol = nil) or (AFromCol = AToCol) then
    Exit;

  (* FIN is stored 1ms before the winner; when the winner opens a new column,
     pull trailing finish markers along so FIN appears before the winner. *)
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

  if APassingType <> ptRider then
  begin
    HandleSpecialPassings(APassingType);
    CurrentCol.Items.Add(Item);
    Invalidate;
    Exit;
  end;

  if FLapCountingActive then
  begin
    // Prüfen, ob Nummer schon in der aktuellen Spalte ist
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

  // Rundenrückstand prüfen (vor Inc): Spalte ist 0-basiert, LapCount =
  // bisherige Wertungsdurchfahrten. Erscheint der Fahrer in Spalte C mit
  // LapCount < C, hat er mindestens eine Spalte verpasst → überrundet.
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

  // Hinzufügen und Status aktualisieren
  CurrentCol.Items.Add(Item);

  // Neu zeichnen
  Invalidate;
end;

procedure TRaceProtocol.HandleSpecialPassings(APassingType: TPassingType);
begin
  case APassingType of
    ptWarmUp, ptNeutralize, ptStop:
      FLapCountingActive := false;
    ptStartRace:
      FLapCountingActive := true;
    ptNewLeader:
      StartNewLap;
  end;
end;

procedure TRaceProtocol.DrawHeader(Canvas: TCanvas; Rect: TRect; LapIndex, Count: Integer);
var
  Txt: string;
  CountTxt: string;
  TxtSize: TSize;
begin
  // Hintergrund Grauverlauf (simuliert)
  Canvas.Brush.Color := $00E0E0E0; // Helles Grau
  Canvas.FillRect(Rect);

  // Trennlinie rechts
  Canvas.Pen.Color := clWhite;
  Canvas.Pen.Width := 2;
  Canvas.MoveTo(Rect.Right - 1, Rect.Top);
  Canvas.LineTo(Rect.Right - 1, Rect.Bottom);

  // Große Zahl (Runde)
  Canvas.Font.Assign(Self.Font);
  Canvas.Font.Size := 14;
  Canvas.Font.Color := clWhite; // Schatten/Outline Effekt simpel
  Txt := IntToStr(LapIndex);

  // Zentriert zeichnen
  TxtSize := Canvas.TextExtent(Txt);
  Canvas.Brush.Style := bsClear;
  Canvas.Font.Color := clGray; // Schatten
  Canvas.TextOut(Rect.Left + (Rect.Width - TxtSize.cx) div 2 + 1, Rect.Top + 2 + 1, Txt);
  Canvas.Font.Color := clWhite; // Text
  Canvas.TextOut(Rect.Left + (Rect.Width - TxtSize.cx) div 2, Rect.Top + 2, Txt);

  // Kleine rote Zahl (Anzahl Passagen)
  CountTxt := IntToStr(Count);
  Canvas.Font.Size := 7;
  Canvas.Font.Color := clRed;
  TxtSize := Canvas.TextExtent(CountTxt);
  // Unten rechts im Header oder oben rechts (Bild: eher unten rechts auf der Linie)
  Canvas.TextOut(Rect.Right - TxtSize.cx - 2, Rect.Bottom - TxtSize.cy - 2, CountTxt);
end;

procedure TRaceProtocol.DrawItem(Canvas: TCanvas; X, Y: Integer; Item: TPassingItem);
var
  R: TRect;
  Txt: string;
  TxtSize: TSize;
begin
  R := Rect(X, Y, X + FItemWidth, Y + FItemHeight);
  InflateRect(R, -1, -1); // Kleiner Abstand

  // Rahmen (Grün)
  case Item.PassingType of
    ptRider:
      begin
        Canvas.Pen.Color := $00008000; // Dunkelgrün
        Txt := IntToStr(Item.Bib);
      end;
    ptWarmUp:
      begin
        Canvas.Pen.Color := clPurple;
        Txt:= 'WU';
      end;
    ptStartRace:
      begin
        Canvas.Pen.Color := clGreen;
        Txt:= 'STRT';
      end;
    ptNeutralize:
      begin
        Canvas.Pen.Color := clYellow;
        Txt:= 'NEU';
      end;
    ptLastLap:
      begin
        Canvas.Pen.Color := clWebRosyBrown;
        Txt:= 'BELL';
      end;
    ptFinish:
      begin
        Canvas.Pen.Color := clBlack;
        Txt:= 'FIN';
      end;
    ptStop:
      begin
        Canvas.Pen.Color := clRed;
        Txt:= 'STP';
      end;
    ptNewLeader:
      begin
        Canvas.Pen.Color := clWhite;
        Txt:= 'NL';
      end;
  end;
  Canvas.Pen.Width := 2;
  Canvas.Brush.Color := clWhite;
  Canvas.Brush.Style := bsSolid;
  Canvas.Rectangle(R);

  // Text (Nummer)
  Canvas.Font.Assign(Self.Font);
  Canvas.Font.Style := [fsBold];
  Canvas.Font.Color := clBlack;
  TxtSize := Canvas.TextExtent(Txt);

  // Text zentrieren
  Canvas.Brush.Style := bsClear;
  Canvas.TextOut(R.Left + (R.Width - TxtSize.cx) div 2,
                 R.Top + (R.Height - TxtSize.cy) div 2, Txt);

  // Der "schwarze Punkt" (Rundenrückstand / überrundet)
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

  // Variablen für Item Position
  ItemIdx: Integer;
  SubColIdx: Integer;
  RowIdx: Integer;
  DrawX, DrawY: Integer;
begin
  inherited;

  // Zeichenfläche löschen
  Canvas.Brush.Color := Color;
  Canvas.FillRect(ClientRect);

  TotalItemHeight := FItemHeight + FColMargin;
  // Wie viele Items passen vertikal untereinander?
  if (ClientHeight - FHeaderHeight) > TotalItemHeight then
    ItemsPerColHeight := (ClientHeight - FHeaderHeight) div TotalItemHeight
  else
    ItemsPerColHeight := 1; // Fallback

  XOffset := 0;

  // Durch alle Runden-Spalten iterieren
  for i := 0 to FColumns.Count - 1 do
  begin
    ColObj := FColumns[i];

    // Berechnen, wie breit diese Spalte sein muss (Unterspalten)
    if ColObj.Items.Count > 0 then
      SubCols := Ceil(ColObj.Items.Count / ItemsPerColHeight)
    else
      SubCols := 1;

    EffectiveColWidth := SubCols * (FItemWidth + FColMargin) + FColMargin;

    // Header Zeichnen
    DrawHeader(Canvas, Rect(XOffset, 0, XOffset + EffectiveColWidth, FHeaderHeight),
               i, ColObj.Items.Count);

    // Items Zeichnen
    for j := 0 to ColObj.Items.Count - 1 do
    begin
      // Berechnung der Position (inkl. Unterspalten-Logik)
      SubColIdx := j div ItemsPerColHeight;
      RowIdx := j mod ItemsPerColHeight;

      DrawX := XOffset + FColMargin + (SubColIdx * (FItemWidth + FColMargin));
      DrawY := FHeaderHeight + FColMargin + (RowIdx * TotalItemHeight);

      DrawItem(Canvas, DrawX, DrawY, ColObj.Items[j]);
    end;

    // Offset für die nächste Hauptspalte verschieben + Trennlinie
    // Graue Trennlinie zwischen Hauptspalten zeichnen
    Canvas.Pen.Color := clSilver;
    Canvas.Pen.Width := 1;
    Canvas.MoveTo(XOffset + EffectiveColWidth, 0);
    Canvas.LineTo(XOffset + EffectiveColWidth, ClientHeight);

    XOffset := XOffset + EffectiveColWidth + 2;
  end;
end;

end.
