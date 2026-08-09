object FormPlausibilityDecision: TFormPlausibilityDecision
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Plausibilit'#228'tspr'#252'fung'
  ClientHeight = 280
  ClientWidth = 520
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  TextHeight = 15
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 520
    Height = 40
    Align = alTop
    BevelOuter = bvNone
    Padding.Left = 12
    Padding.Top = 10
    Padding.Right = 12
    TabOrder = 0
    object LabelTitle: TLabel
      Left = 12
      Top = 10
      Width = 200
      Height = 15
      Caption = 'Kritische Passage — Entscheidung'
    end
  end
  object MemoMessage: TMemo
    Left = 12
    Top = 40
    Width = 496
    Height = 160
    Align = alClient
    BorderStyle = bsNone
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object PanelBottom: TPanel
    Left = 0
    Top = 200
    Width = 520
    Height = 80
    Align = alBottom
    BevelOuter = bvNone
    Padding.Left = 12
    Padding.Right = 12
    TabOrder = 2
    DesignSize = (
      520
      80)
    object CheckBoxAlwaysAccept: TCheckBox
      Left = 12
      Top = 8
      Width = 360
      Height = 17
      Caption = 'F'#252'r diesen Chip immer annehmen (diese Sitzung)'
      TabOrder = 0
    end
    object ButtonAccept: TButton
      Left = 248
      Top = 40
      Width = 120
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Annehmen'
      Default = True
      ModalResult = 6
      TabOrder = 1
    end
    object ButtonReject: TButton
      Left = 380
      Top = 40
      Width = 120
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Verwerfen'
      ModalResult = 2
      TabOrder = 2
    end
  end
end
