unit FormAssignCompetitorToTransponder;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls,
  Vcl.ComCtrls, Data.DB, Data.SqlExpr, DataModule;

type
  TFormAssignCompetitor = class(TForm)
    PanelControls: TPanel;
    Label3: TLabel;
    EditBIB: TEdit;
    ButtonOK: TButton;
    ButtonCancel: TButton;
    PanelGrid: TPanel;
    ListViewCompetitors: TListView;
    procedure FormShow(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure EditBIBChange(Sender: TObject);
    procedure ListViewCompetitorsDblClick(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
  private
    FRaceId: Integer;
    FSelectedCompetitorId: Integer;
    procedure LoadCompetitors;
    procedure ApplyBibFilter;
    function TryAcceptSelection: Boolean;
  public
    class function Execute(AOwner: TComponent; ARaceId: Integer;
      out ACompetitorId: Integer): Boolean; static;
    property SelectedCompetitorId: Integer read FSelectedCompetitorId;
  end;

implementation

{$R *.dfm}

{==============================================================================}
class function TFormAssignCompetitor.Execute(AOwner: TComponent; ARaceId: Integer;
  out ACompetitorId: Integer): Boolean;
var
  lForm: TFormAssignCompetitor;
begin
  ACompetitorId := -1;
  Result := False;
  if ARaceId < 0 then
    Exit;

  lForm := TFormAssignCompetitor.Create(AOwner);
  try
    lForm.FRaceId := ARaceId;
    if lForm.ShowModal <> mrOK then
      Exit;
    ACompetitorId := lForm.SelectedCompetitorId;
    Result := ACompetitorId > 0;
  finally
    FreeAndNil(lForm);
  end;
end;

{==============================================================================}
procedure TFormAssignCompetitor.FormActivate(Sender: TObject);
begin
  EditBIB.SetFocus;
end;

{==============================================================================}
procedure TFormAssignCompetitor.FormShow(Sender: TObject);
begin
  FSelectedCompetitorId := -1;
  LoadCompetitors;
  EditBIB.Text := '';
  EditBIB.SetFocus;
end;

{==============================================================================}
procedure TFormAssignCompetitor.LoadCompetitors;
var
  lResultSet: TDataSet;
  lItem: TListItem;
  lName: string;
  lTeam: string;
begin
  ListViewCompetitors.Items.BeginUpdate;
  try
    ListViewCompetitors.Items.Clear;
    MainDataModule.SQLConnection.Execute(
      Format(
        'SELECT C.COMPETITORID, C.BIB, C.LASTNAME, C.FIRSTNAME, C.TEAM, C.CLUB, C.CLASS ' +
        'FROM COMPETITORS C INNER JOIN PARTICIPATION P ON C.COMPETITORID = P.COMPETITORID ' +
        'WHERE P.RACEID = %d ORDER BY C.BIB',
        [FRaceId]),
      nil, lResultSet);
    try
      if (lResultSet = nil) or lResultSet.IsEmpty then
        Exit;
      lResultSet.First;
      while not lResultSet.Eof do
      begin
        lItem := ListViewCompetitors.Items.Add;
        lItem.Caption := lResultSet.FieldByName('BIB').AsString;
        lName := Trim(lResultSet.FieldByName('LASTNAME').AsString + ', ' +
          lResultSet.FieldByName('FIRSTNAME').AsString);
        if lName = ',' then
          lName := '';
        lItem.SubItems.Add(lName);
        lTeam := Trim(lResultSet.FieldByName('TEAM').AsString);
        if lTeam = '' then
          lTeam := Trim(lResultSet.FieldByName('CLUB').AsString);
        lItem.SubItems.Add(lTeam);
        lItem.SubItems.Add(lResultSet.FieldByName('CLASS').AsString);
        lItem.Data := Pointer(lResultSet.FieldByName('COMPETITORID').AsInteger);
        lResultSet.Next;
      end;
    finally
      FreeAndNil(lResultSet);
    end;
  finally
    ListViewCompetitors.Items.EndUpdate;
  end;
end;

{==============================================================================}
procedure TFormAssignCompetitor.ApplyBibFilter;
var
  i: Integer;
  lFilter: string;
  lItem: TListItem;
begin
  lFilter := Trim(EditBIB.Text);
  for i := 0 to ListViewCompetitors.Items.Count - 1 do
  begin
    lItem := ListViewCompetitors.Items[i];
    lItem.Selected := False;
    if lFilter = '' then
    begin
      lItem.MakeVisible(False);
      Continue;
    end;
    if lItem.Caption.StartsWith(lFilter) then
    begin
      if ListViewCompetitors.Selected = nil then
      begin
        lItem.Selected := True;
        lItem.MakeVisible(False);
      end;
    end;
  end;
end;

{==============================================================================}
procedure TFormAssignCompetitor.EditBIBChange(Sender: TObject);
begin
  ApplyBibFilter;
end;

{==============================================================================}
function TFormAssignCompetitor.TryAcceptSelection: Boolean;
var
  lItem: TListItem;
  i: Integer;
  lBib: string;
begin
  Result := False;
  lItem := ListViewCompetitors.Selected;
  if lItem = nil then
  begin
    lBib := Trim(EditBIB.Text);
    if lBib <> '' then
      for i := 0 to ListViewCompetitors.Items.Count - 1 do
        if SameText(ListViewCompetitors.Items[i].Caption, lBib) then
        begin
          lItem := ListViewCompetitors.Items[i];
          Break;
        end;
  end;
  if lItem = nil then
    Exit;
  FSelectedCompetitorId := Integer(lItem.Data);
  Result := FSelectedCompetitorId > 0;
end;

{==============================================================================}
procedure TFormAssignCompetitor.ButtonOKClick(Sender: TObject);
begin
  if TryAcceptSelection then
    ModalResult := mrOK
  else
    ModalResult := mrNone;
end;

{==============================================================================}
procedure TFormAssignCompetitor.ListViewCompetitorsDblClick(Sender: TObject);
begin
  if TryAcceptSelection then
    ModalResult := mrOK;
end;

end.
