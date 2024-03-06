object FormProgressIndicator: TFormProgressIndicator
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'FormProgress'
  ClientHeight = 51
  ClientWidth = 390
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnShow = FormShow
  TextHeight = 15
  object Label1: TLabel
    Left = 50
    Top = 19
    Width = 329
    Height = 15
    Alignment = taCenter
    AutoSize = False
    Caption = 'Die Daten werden beeitgestellt ...'
  end
  object Animate: TAnimate
    Left = 8
    Top = 10
    Width = 32
    Height = 32
  end
end
