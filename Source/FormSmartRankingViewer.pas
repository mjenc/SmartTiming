unit FormSmartRankingViewer;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl, FMX.StdCtrls, FMX.Controls.Presentation,
  FMX.Gestures, System.Actions, FMX.ActnList, System.Rtti, FMX.Grid.Style,
  FMX.ScrollBox, FMX.Grid, System.ImageList, FMX.ImgList,
  SmartRankingViewer.WebClient, Generics.Collections, XSuperObject,
  FMX.WebBrowser;

type
  TFormRankingViewer = class(TForm)
    TabControlRaces: TTabControl;
    TimerRefresh: TTimer;
    PanelTitleBar: TPanel;
    LabelEventTitle: TLabel;
    LabelOrganizer: TLabel;
    ImageList: TImageList;
    ImageControl1: TImageControl;
    SwitchGrouped: TSwitch;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DoRefresh(Sender: TObject);
  private
    FSmartRankingViewWebClient: TSmartRankingViewWebClient;
    FSmartTimingServer: string;
    FRacesList: TDictionary<integer, TSRVRaceItem>;
    FTitlesToShow: TStringList;

    FOrganizer: string;
    FTitle: string;
    FDateFrom: TDatetime;
    FDateTo: TDatetime;

    procedure SetupWebClient;
    procedure GetConnectionSettings;
    procedure GenerateNeededTabs;
    procedure FillResultsIntoHtml(var AHtml: string; ASuperObject: ISuperObject);
    function GetRealRank(ARow: ISuperObject): string;
  public
    property Organizer: string read FOrganizer write FOrganizer;
    property Title: string read FTitle write FTitle;
    property DateFrom: TDatetime read FDateFrom write FDateFrom;
    property DateTo: TDatetime read FDateTo write FDateTo;
    property RacesList: TDictionary<integer, TSRVRaceItem> read FRacesList;
  end;

var
  FormRankingViewer: TFormRankingViewer;

implementation

{$R *.fmx}

uses
  FormRankingViewerConnectionProps;

const
  cStyle =
    'table.resultList {' + #13#10 +
    '    font-family: Arial, Helvetica, sans-serif;' + #13#10 +
    '    width: 100%;' + #13#10 +
    '    text-align: left;' + #13#10 +
    '    border-collapse: collapse;' + #13#10 +
    '  }' + #13#10 +
    '  table.resultList td, table.resultList th {' + #13#10 +
    '    padding: 5px 4px;' + #13#10 +
    '  }' + #13#10 +
    '  table.resultList tbody td {' + #13#10 +
    '    font-size: 13px;' + #13#10 +
    '  }' + #13#10 +
    '  table.resultList tr:nth-child(even) {' + #13#10 +
    '    background: #EBEBEB;' + #13#10 +
    '  }' + #13#10 +
    '  table.resultList thead {' + #13#10 +
    '    background: #9A9A9A;' + #13#10 +
    '    background: -moz-linear-gradient(top, #b3b3b3 0%, #a4a4a4 66%, #9A9A9A 100%);' + #13#10 +
    '    background: -webkit-linear-gradient(top, #b3b3b3 0%, #a4a4a4 66%, #9A9A9A 100%);' + #13#10 +
    '    background: linear-gradient(to bottom, #b3b3b3 0%, #a4a4a4 66%, #9A9A9A 100%);' + #13#10 +
    '  }' + #13#10 +
    '  table.resultList thead th {' + #13#10 +
    '    font-size: 15px;' + #13#10 +
    '    font-weight: normal;' + #13#10 +
    '    color: #FFFFFF;' + #13#10 +
    '    text-align: left;' + #13#10 +
    '  }' + #13#10 +
    '  table.resultList tfoot td {' + #13#10 +
    '    font-size: 14px;' + #13#10 +
    '  }';

  cRankingHtml =
    '<!DOCTYPE html><html>' + #13#10 +
    '<head><style>' +cStyle + '</style></head>' + #13#10 +
    '<body>' + #13#10 +
    '    <table class="resultList">' + #13#10 +
    '    %%%TABLE_HEADER%%%' + #13#10 +
    '    %%%TABLE_BODY%%%' + #13#10 +
    '    </table>' + #13#10 +
    '</body>' + #13#10 +
    '</html>';

  cTitlesToShow = 'Platz,Klasse,Nr,Name,Team,Wertungszeit,Diff';

//        <thead>
//            <tr>
//                <th>head1</th>
//                <th>head2</th>
//                <th>head3</th>
//                <th>head4</th>
//                <th>head5</th>
//            </tr>
//        </thead>

//        <tbody>
//            <tr>
//                <td>cell1_1</td>
//                <td>cell2_1</td>
//                <td>cell3_1</td>
//                <td>cell4_1</td>
//                <td>cell5_1</td>
//            </tr>
//        </tbody>

{==============================================================================}
procedure TFormRankingViewer.FormCreate(Sender: TObject);
begin
  FTitlesToShow := TStringList.Create;
  FTitlesToShow.CommaText := cTitlesToShow;

  FormConnectionProperties := TFormConnectionProperties.Create(nil);

  FRacesList := TDictionary<integer, TSRVRaceItem>.Create;
  FOrganizer := 'Nicht mit SmartTiming Server verbunden';
  LabelOrganizer.Text := FOrganizer;
  LabelEventTitle.Text := FTitle;
end;

{==============================================================================}
procedure TFormRankingViewer.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FSmartRankingViewWebClient);
  FreeAndNil(FRacesList);
  FreeAndNil(FormConnectionProperties);
end;

{==============================================================================}
procedure TFormRankingViewer.GetConnectionSettings;
begin
  FormConnectionProperties.WebClient := FSmartRankingViewWebClient;
//  FormConnectionProperties.Show;
  FSmartTimingServer := 'CAS-N04798';// FormConnectionProperties.SmartTimingServer;
end;

{==============================================================================}
procedure TFormRankingViewer.SetupWebClient;
begin
  FSmartRankingViewWebClient := TSmartRankingViewWebClient.Create(FSmartTimingServer);
  try
    GetConnectionSettings;
    FSmartRankingViewWebClient.FillEventInfo(TForm(self));
    GenerateNeededTabs;
  except
    FOrganizer := 'Nicht mit SmartTiming Server verbunden';
  end;
end;

{==============================================================================}
procedure TFormRankingViewer.DoRefresh(Sender: TObject);
var
  lJSON: string;
  lSuperObject: ISuperObject;
  i: integer;
  lHtml: string;
  lTabItem: TTabItem;
begin
  if FSmartRankingViewWebClient = nil then
  begin
    GetConnectionSettings;
    SetupWebClient;
    LabelOrganizer.Text := FOrganizer;
    LabelEventTitle.Text := FTitle;
    Exit;
  end;

  if TabControlRaces.ActiveTab = nil then
    Exit;

  lTabItem := TabControlRaces.ActiveTab;
  lJSON := FSmartRankingViewWebClient.GetRankings(lTabItem.Tag, SwitchGrouped.IsChecked);
  lSuperObject := TSuperObject.Create(PWideChar(lJSON));

  lHtml := cRankingHtml;
  FillResultsIntoHtml(lHtml, lSuperObject);

  for i := 0 to lTabItem.ComponentCount do
  begin
    if lTabItem.Components[i] is TWebBrowser then
    begin
      TWebBrowser(lTabItem.Components[i]).LoadFromStrings(lHtml, '');
      Exit;
    end;
  end;
end;

{==============================================================================}
procedure TFormRankingViewer.GenerateNeededTabs;
var
  lTabItem: TTabItem;
  lRaceItem: TSRVRaceItem;
  lWebBrowser: TWebBrowser;
begin
  TabControlRaces.BeginUpdate;
  try
    for lRaceItem in RacesList.Values do
    begin
      lTabItem := TabControlRaces.Add;
      lTabItem.Tag := lRaceItem.Id;
      lTabItem.Text := lRaceItem.Title;
      lWebBrowser := TWebBrowser.Create(lTabItem);
      lWebBrowser.Parent := lTabItem;
      lWebBrowser.Align := TAlignLayout.Client;
      lWebBrowser.WindowsEngine := TWindowsEngine.EdgeIfAvailable;
    end;
  finally
    TabControlRaces.EndUpdate;
  end;
end;

{==============================================================================}
function TFormRankingViewer.GetRealRank(ARow: ISuperObject): string;
begin
  result := ARow.S['Platz'];
  if ARow.Contains('DNS') and (ARow.S['DNS'].ToInteger = 1) then
    Exit('DNS');
  if ARow.Contains('DNF') and (ARow.S['DNF'].ToInteger = 1) then
    Exit('DNF');
  if ARow.Contains('DSQ') and (ARow.S['DSQ'].ToInteger = 1) then
    Exit('DSQ');
end;

{==============================================================================}
procedure TFormRankingViewer.FillResultsIntoHtml(var AHtml: string; ASuperObject: ISuperObject);
var
  lHeaderHtml: string;
  lBodyHtml: string;
  lRows: ISuperArray;
  lRow: ISuperObject;
  lColIdx: Integer;
  lRowIdx: Integer;
  lValueStr: string;
  lTd: string;
begin
  lHeaderHtml := '<thead><tr>';
  for lColIdx := 0 to FTitlesToShow.Count - 1 do
    lHeaderHtml := lHeaderHtml + '<th>' + FTitlesToShow[lColIdx] + '</th>';
  lHeaderHtml := lHeaderHtml + '</tr></thead>';
  AHtml := StringReplace(AHtml, '%%%TABLE_HEADER%%%', lHeaderHtml, []);

  lBodyHtml := '<tbody>';
  lRows := ASuperObject.A['list'];
  if (lRows <> nil) and (lRows.Length <> 0) then
  begin
    for lRowIdx := 0 to lRows.Length - 1 do
    begin
      lRow := lRows.O[lRowIdx];
      lBodyHtml := lBodyHtml + '<tr>';
      for lColIdx := 0 to FTitlesToShow.Count - 1 do
      begin
        lTd := '<td>';
        if not lRow.Contains(FTitlesToShow[lColIdx]) then
        begin
          lBodyHtml := lBodyHtml + '</td>';
          Continue;
        end;

        lValueStr := lRow.S[FTitlesToShow[lColIdx]];
        if SameText(FTitlesToShow[lColIdx], 'Platz') then
        begin
          case lValueStr.ToInteger of
          1:
            lTd := '<td style="background-color:#d4af37">';
          2:
            lTd := '<td style="background-color:silver">';
          3:
            lTd := '<td style="background-color:#cd7f32">';
          end;
          lValueStr := GetRealRank(lRow);
        end;

        lBodyHtml := lBodyHtml + lTd;
        lBodyHtml := lBodyHtml + lValueStr + '</td>';
      end;
      lBodyHtml := lBodyHtml + '</tr>';
    end;
  end
  else
    lBodyHtml := lBodyHtml + '<tr><td>Keine Ergebnisse vorhanden.</td></tr>';
  lBodyHtml := lBodyHtml + '</tbody>';
  AHtml := StringReplace(AHtml, '%%%TABLE_BODY%%%', lBodyHtml, []);
end;


end.

