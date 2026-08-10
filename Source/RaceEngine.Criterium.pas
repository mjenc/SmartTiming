unit RaceEngine.Criterium;

{==============================================================================
  Plan 1 — Kriterium skeleton (scoring later).
==============================================================================}

interface

uses
  Classes, Controls, RaceEngine.Skeleton, RaceEngine.Custom, SmartTiming.Event;

type
  TCriteriumRaceEngine = class(TSkeletonRaceEngine)
  public
    constructor Create(AParent: TWinControl; AEvent: TEventDataObject;
      ARaceItem: TRaceItem); override;
  end;

implementation

{==============================================================================}
constructor TCriteriumRaceEngine.Create(AParent: TWinControl; AEvent: TEventDataObject;
  ARaceItem: TRaceItem);
begin
  ApplySkeletonFormats('.Criterium');
  inherited Create(AParent, AEvent, ARaceItem);
end;

end.
