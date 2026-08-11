unit RaceEngine.TeamTimeTrial;

{==============================================================================
  Plan 1 — Mannschaftszeitfahren skeleton (no longer empty ITT subclass).
  Scoring / team rules later (Plan 1 step 4+, Plan 8e).
==============================================================================}

interface

uses
  Classes, Controls, RaceEngine.Skeleton, RaceEngine.Custom, SmartTiming.Event,
  SmartTiming.Consts;

type
  TTeamTimeTrialRaceEngine = class(TSkeletonRaceEngine)
  public
    constructor Create(AParent: TWinControl; AEvent: TEventDataObject;
      ARaceItem: TRaceItem); override;
  end;

implementation

{==============================================================================}
constructor TTeamTimeTrialRaceEngine.Create(AParent: TWinControl;
  AEvent: TEventDataObject; ARaceItem: TRaceItem);
begin
  ApplySkeletonFormats('.TeamTimeTrial');
  inherited Create(AParent, AEvent, ARaceItem);
end;

end.
