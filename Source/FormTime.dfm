object FormEditTime: TFormEditTime
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Zeit bearbeiten'
  ClientHeight = 79
  ClientWidth = 189
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  TextHeight = 15
  object Label1: TLabel
    Left = 62
    Top = 12
    Width = 20
    Height = 15
    Caption = 'Zeit'
  end
  object PanelButtons: TPanel
    Left = 0
    Top = 38
    Width = 189
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      189
      41)
    object ButtonOK: TButton
      Left = 15
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
      Left = 103
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Abbrechen'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object EditTime: TMaskEdit
    Left = 88
    Top = 9
    Width = 89
    Height = 23
    Alignment = taCenter
    EditMask = '!90:00:00.000;1;_'
    MaxLength = 12
    TabOrder = 1
    Text = '  :  :  .   '
  end
end
