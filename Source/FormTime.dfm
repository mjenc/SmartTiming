object FormEditTime: TFormEditTime
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Zeit bearbeiten'
  ClientHeight = 128
  ClientWidth = 280
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  TextHeight = 15
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 20
    Height = 15
    Caption = 'Zeit'
  end
  object LabelOverride: TLabel
    Left = 16
    Top = 48
    Width = 248
    Height = 30
    AutoSize = False
    Caption = 
      'Manuelle Zielzeit aktiv — Recalc '#252'berschreibt sie nicht. Zur'#252'cks' +
      'etzen stellt die Passagen-Zeit wieder her.'
    WordWrap = True
    Visible = False
  end
  object PanelButtons: TPanel
    Left = 0
    Top = 87
    Width = 280
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      280
      41)
    object ButtonOK: TButton
      Left = 109
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object ButtonCancel: TButton
      Left = 190
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Abbrechen'
      ModalResult = 2
      TabOrder = 1
    end
    object ButtonReset: TButton
      Left = 8
      Top = 8
      Width = 95
      Height = 25
      Caption = 'Zur'#252'cksetzen'
      TabOrder = 2
      Visible = False
      OnClick = ButtonResetClick
    end
  end
  object EditTime: TMaskEdit
    Left = 88
    Top = 13
    Width = 89
    Height = 23
    Alignment = taCenter
    EditMask = '!90:00:00.000;1;_'
    MaxLength = 12
    TabOrder = 1
    Text = '  :  :  .   '
  end
end
