unit TestRaceProtocol;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, RaceProtocol;

type
  TFormLapProtocolTest = class(TForm)
    PanelLapProtocol: TPanel;
    PanelAddPassings: TPanel;
    EditBib: TEdit;
    ButtonAddPassing: TButton;
    ButtonClearAll: TButton;
    ButtonAddSeries: TButton;
    ButtonWarmUp: TButton;
    ButtonStartRace: TButton;
    ButtonNeutralize: TButton;
    ButtonFinalLap: TButton;
    ButtonFinish: TButton;
    ButtonStop: TButton;
    ButtonNewLeader: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ButtonAddPassingClick(Sender: TObject);
    procedure ButtonAddSeriesClick(Sender: TObject);
    procedure ButtonClearAllClick(Sender: TObject);
    procedure ButtonWarmUpClick(Sender: TObject);
    procedure ButtonStartRaceClick(Sender: TObject);
    procedure ButtonNeutralizeClick(Sender: TObject);
    procedure ButtonFinalLapClick(Sender: TObject);
    procedure ButtonFinishClick(Sender: TObject);
    procedure ButtonStopClick(Sender: TObject);
    procedure ButtonNewLeaderClick(Sender: TObject);
  private
    FRaceProtocol: TRaceProtocol;
  public
    { Public-Deklarationen }
  end;

var
  FormLapProtocolTest: TFormLapProtocolTest;

implementation

{$R *.dfm}



procedure TFormLapProtocolTest.ButtonAddPassingClick(Sender: TObject);
begin
  if EditBib.Text = '' then
    Exit;
  FRaceProtocol.AddPassing(StrToInt(EditBib.Text));
end;

procedure TFormLapProtocolTest.ButtonAddSeriesClick(Sender: TObject);
begin
  // 1. Runde
  FRaceProtocol.AddPassing(12);
  FRaceProtocol.AddPassing(1);
  FRaceProtocol.AddPassing(5);
  FRaceProtocol.AddPassing(9);
  FRaceProtocol.AddPassing(10);
  FRaceProtocol.AddPassing(11);
  FRaceProtocol.AddPassing(3);
  FRaceProtocol.AddPassing(2);
  FRaceProtocol.AddPassing(6);
  FRaceProtocol.AddPassing(7);
  FRaceProtocol.AddPassing(4);
  FRaceProtocol.AddPassing(8);

  // 2. Runde
  FRaceProtocol.AddPassing(12);
  FRaceProtocol.AddPassing(1);
  FRaceProtocol.AddPassing(5);
  FRaceProtocol.AddPassing(9);
  FRaceProtocol.AddPassing(3);
  FRaceProtocol.AddPassing(2);
  FRaceProtocol.AddPassing(10);
  FRaceProtocol.AddPassing(11);
  FRaceProtocol.AddPassing(6);
  FRaceProtocol.AddPassing(7);
  FRaceProtocol.AddPassing(4);

  // 3. Runde (#8 überrundet)
  FRaceProtocol.AddPassing(12);
  FRaceProtocol.AddPassing(1);
  FRaceProtocol.AddPassing(8);
  FRaceProtocol.AddPassing(5);
  FRaceProtocol.AddPassing(3);
  FRaceProtocol.AddPassing(2);
  FRaceProtocol.AddPassing(9);
  FRaceProtocol.AddPassing(10);
  FRaceProtocol.AddPassing(11);
  FRaceProtocol.AddPassing(6);
  FRaceProtocol.AddPassing(7);

  // 4. Runde (#4 überrundet)
  FRaceProtocol.AddPassing(12);
  FRaceProtocol.AddPassing(4);
  FRaceProtocol.AddPassing(1);
  FRaceProtocol.AddPassing(5);
  FRaceProtocol.AddPassing(3);
  FRaceProtocol.AddPassing(2);
  FRaceProtocol.AddPassing(8);
  FRaceProtocol.AddPassing(9);
  FRaceProtocol.AddPassing(10);
  FRaceProtocol.AddPassing(11);
  FRaceProtocol.AddPassing(6);
  FRaceProtocol.AddPassing(7);

  // 5. Runde
  FRaceProtocol.AddPassing(12);
  FRaceProtocol.AddPassing(1);
  FRaceProtocol.AddPassing(5);
  FRaceProtocol.AddPassing(3);
  FRaceProtocol.AddPassing(2);
  FRaceProtocol.AddPassing(9);
  FRaceProtocol.AddPassing(10);
  FRaceProtocol.AddPassing(11);
  FRaceProtocol.AddPassing(4);
  FRaceProtocol.AddPassing(6);
  FRaceProtocol.AddPassing(8);
  FRaceProtocol.AddPassing(7);

  // 6. Runde
  FRaceProtocol.AddPassing(12);
  FRaceProtocol.AddPassing(1);
  FRaceProtocol.AddPassing(5);
  FRaceProtocol.AddPassing(3);
  FRaceProtocol.AddPassing(2);
  FRaceProtocol.AddPassing(9);
  FRaceProtocol.AddPassing(10);
  FRaceProtocol.AddPassing(11);
  FRaceProtocol.AddPassing(6);
  FRaceProtocol.AddPassing(7);

  // 7. Runde #8 und #4 wieder überrundet
  FRaceProtocol.AddPassing(12);
  FRaceProtocol.AddPassing(4);
  FRaceProtocol.AddPassing(1);
  FRaceProtocol.AddPassing(8);
  FRaceProtocol.AddPassing(5);
  FRaceProtocol.AddPassing(3);
  FRaceProtocol.AddPassing(2);
  FRaceProtocol.AddPassing(9);
  FRaceProtocol.AddPassing(10);
  FRaceProtocol.AddPassing(11);
  FRaceProtocol.AddPassing(6);
  FRaceProtocol.AddPassing(7);
end;

procedure TFormLapProtocolTest.ButtonClearAllClick(Sender: TObject);
begin
  FRaceProtocol.Clear;
end;

procedure TFormLapProtocolTest.ButtonFinalLapClick(Sender: TObject);
begin
  FRaceProtocol.AddPassing(0, ptLastLap);
end;

procedure TFormLapProtocolTest.ButtonFinishClick(Sender: TObject);
begin
  FRaceProtocol.AddPassing(0, ptFinish);
end;

procedure TFormLapProtocolTest.ButtonNeutralizeClick(Sender: TObject);
begin
  FRaceProtocol.AddPassing(0, ptNeutralize);
end;

procedure TFormLapProtocolTest.ButtonNewLeaderClick(Sender: TObject);
begin
  FRaceProtocol.AddPassing(0, ptNewLeader);
end;

procedure TFormLapProtocolTest.ButtonStartRaceClick(Sender: TObject);
begin
  FRaceProtocol.AddPassing(0, ptStartRace);
end;

procedure TFormLapProtocolTest.ButtonStopClick(Sender: TObject);
begin
  FRaceProtocol.AddPassing(0, ptStop);
end;

procedure TFormLapProtocolTest.ButtonWarmUpClick(Sender: TObject);
begin
  FRaceProtocol.AddPassing(0, ptWarmUp);
end;

procedure TFormLapProtocolTest.FormCreate(Sender: TObject);
begin
  FRaceProtocol := TRaceProtocol.Create(self);
  FRaceProtocol.Parent := PanelLapProtocol;
  FRaceProtocol.Align := alClient;
end;

end.
