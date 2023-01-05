unit uPassingCustomProtocol;

interface

uses
  Classes, Controls, VCL.Grids, Generics.Collections, SysUtils, Types,
  SmartTiming.DecoderInterface;

type
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
  FTransponderPassing.Add(APassing.TransponderShortId.ToString);
  Add(FTransponderPassing.Count - 1, APassing);
end;

{==============================================================================}
procedure TPassingList.DoClear;
begin
  Clear;
  FTransponderPassing.Clear;
end;

end.
