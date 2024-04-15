unit FormSmartRankingViewer;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl, FMX.StdCtrls, FMX.Controls.Presentation,
  FMX.Gestures, System.Actions, FMX.ActnList, System.Rtti, FMX.Grid.Style,
  FMX.ScrollBox, FMX.Grid, System.ImageList, FMX.ImgList,
  SmartRankingViewer.WebClient, Generics.Collections, Tools.SuperObject;

type
  TTabbedwithNavigationForm = class(TForm)
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabItem3: TTabItem;
    TabItem4: TTabItem;
    TimerRefresh: TTimer;
    Panel1: TPanel;
    ImageControl1: TImageControl;
    Label1: TLabel;
    StringGrid1: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DoRefresh(Sender: TObject);
  private
    FSmartRankingViewWebClient: TSmartRankingViewWebClient;
    FRaceIdList: TDictionary<integer, TStringGrid>;

    procedure GenerateNeededTabs(ASuperObject: ISuperObject);
    procedure FillStringGridFromResults(const ARaceId: integer; AGrid: TStringGrid; ASuperObject: ISuperObject);
  public
    { Public declarations }
  end;

var
  TabbedwithNavigationForm: TTabbedwithNavigationForm;

implementation

{$R *.fmx}

{==============================================================================}
procedure TTabbedwithNavigationForm.FormCreate(Sender: TObject);
begin
  TabControl1.ActiveTab := TabItem1;

  FRaceIdList := TDictionary<integer, TStringGrid>.Create;
  FSmartRankingViewWebClient := TSmartRankingViewWebClient.Create('localhost');
end;

{==============================================================================}
procedure TTabbedwithNavigationForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FSmartRankingViewWebClient);
  FreeAndNil(FRaceIdList);
end;

{==============================================================================}
procedure TTabbedwithNavigationForm.DoRefresh(Sender: TObject);
var
  lJSON: string;
  lSuperObject: ISuperObject;
  i: integer;
  lStringGrid: TStringGrid;
begin
  lJSON := FSmartRankingViewWebClient.GetRankings;
  lSuperObject := TSuperObject.ParseString(PWideChar(lJSON), true);

  GenerateNeededTabs(lSuperObject);

  for i in FRaceIdList.Keys do
  begin
    if not FRaceIdList.TryGetValue(i, lStringGrid) then
      Continue;
    FillStringGridFromResults(i, lStringGrid, lSuperObject);
  end;
end;

{==============================================================================}
procedure TTabbedwithNavigationForm.GenerateNeededTabs(ASuperObject: ISuperObject);
begin
  // TODO
end;

{==============================================================================}
procedure TTabbedwithNavigationForm.FillStringGridFromResults(const ARaceId: integer; AGrid: TStringGrid; ASuperObject: ISuperObject);
begin
  // TODO
end;

end.

