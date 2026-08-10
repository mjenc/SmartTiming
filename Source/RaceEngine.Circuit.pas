unit RaceEngine.Circuit;

{==============================================================================
  Plan 1 — Rundstrecke skeleton (scoring later).
==============================================================================}

interface

uses
  Classes, Controls, RaceEngine.Skeleton, RaceEngine.Custom, SmartTiming.Event;

type
  TCircuitRaceEngine = class(TSkeletonRaceEngine)
  public
    constructor Create(AParent: TWinControl; AEvent: TEventDataObject;
      ARaceItem: TRaceItem); override;
  end;

implementation

{==============================================================================}
constructor TCircuitRaceEngine.Create(AParent: TWinControl; AEvent: TEventDataObject;
  ARaceItem: TRaceItem);
begin
  ApplySkeletonFormats('.Circuit');
  inherited Create(AParent, AEvent, ARaceItem);
end;

end.
