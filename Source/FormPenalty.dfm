object FormEditPenalty: TFormEditPenalty
  Left = 0
  Top = 0
  Caption = 'Strafe bearbeiten'
  ClientHeight = 194
  ClientWidth = 490
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  TextHeight = 15
  object PanelButtons: TPanel
    Left = 0
    Top = 153
    Width = 490
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitLeft = -37
    ExplicitWidth = 527
    DesignSize = (
      490
      41)
    object ButtonOK: TButton
      Left = 316
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
      ExplicitLeft = 353
    end
    object ButtonCancel: TButton
      Left = 404
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Abbrechen'
      ModalResult = 2
      TabOrder = 1
      ExplicitLeft = 441
    end
  end
  object MemoPenalty: TMemo
    Left = 8
    Top = 8
    Width = 474
    Height = 147
    TabOrder = 1
  end
end
