unit FormPlausibilityDecision;

{==============================================================================
  Plan 4 step 4: operator decision for pdAskOperator findings.
==============================================================================}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TFormPlausibilityDecision = class(TForm)
    PanelTop: TPanel;
    LabelTitle: TLabel;
    MemoMessage: TMemo;
    PanelBottom: TPanel;
    CheckBoxAlwaysAccept: TCheckBox;
    ButtonAccept: TButton;
    ButtonReject: TButton;
  public
    (* True = accept/score. AAlwaysAccept set when checkbox checked on accept. *)
    class function Execute(AOwner: TComponent; const AChipId, AMessage: string;
      ACanScore, AAllowAlwaysAccept: Boolean; out AAlwaysAccept: Boolean): Boolean; static;
  end;

implementation

{$R *.dfm}

uses
  SmartTiming.Consts;

{==============================================================================}
class function TFormPlausibilityDecision.Execute(AOwner: TComponent;
  const AChipId, AMessage: string; ACanScore, AAllowAlwaysAccept: Boolean;
  out AAlwaysAccept: Boolean): Boolean;
var
  lForm: TFormPlausibilityDecision;
begin
  AAlwaysAccept := False;
  lForm := TFormPlausibilityDecision.Create(AOwner);
  try
    lForm.Caption := cMessagesPlausibilityTitle;
    lForm.LabelTitle.Caption := cMessagesPlausibilityTitle;
    lForm.MemoMessage.Lines.Text := AMessage;
    lForm.CheckBoxAlwaysAccept.Caption :=
      Format(cMessagesPlausibilityAlwaysAccept, [AChipId]);
    lForm.ButtonAccept.Caption := cMessagesPlausibilityAccept;
    lForm.ButtonReject.Caption := cMessagesPlausibilityReject;

    lForm.ButtonAccept.Visible := ACanScore;
    lForm.CheckBoxAlwaysAccept.Visible := ACanScore and AAllowAlwaysAccept;
    if not ACanScore then
    begin
      lForm.ButtonReject.Caption := cMessagesPlausibilityAcknowledge;
      lForm.ButtonReject.Default := True;
      lForm.ButtonReject.ModalResult := mrOk;
    end
    else
    begin
      (* Explicit choice: score vs keep invalid. *)
      lForm.ButtonAccept.Default := True;
      lForm.ButtonAccept.ModalResult := mrYes;
      lForm.ButtonReject.Cancel := True;
      lForm.ButtonReject.ModalResult := mrNo;
    end;

    if ACanScore then
      Result := lForm.ShowModal = mrYes
    else
    begin
      lForm.ShowModal;
      Result := False;
    end;

    if Result and lForm.CheckBoxAlwaysAccept.Visible then
      AAlwaysAccept := lForm.CheckBoxAlwaysAccept.Checked;
  finally
    FreeAndNil(lForm);
  end;
end;

end.
