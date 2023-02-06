object FormGenerateTransponderMappings: TFormGenerateTransponderMappings
  Left = 0
  Top = 0
  Caption = #220'bersetzungstabelle generieren'
  ClientHeight = 441
  ClientWidth = 360
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object PanelButtons: TPanel
    Left = 0
    Top = 400
    Width = 360
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      360
      41)
    object ButtonOK: TButton
      Left = 186
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      ModalResult = 1
      TabOrder = 0
      OnClick = ButtonOKClick
    end
    object ButtonCancel: TButton
      Left = 274
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
  object PanelMain: TPanel
    Left = 0
    Top = 0
    Width = 360
    Height = 400
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object Label1: TLabel
      Left = 16
      Top = 74
      Width = 136
      Height = 15
      Caption = 'Einlesen beginnen mit Nr.'
    end
    object CheckBoxClearExisiting: TCheckBox
      Left = 16
      Top = 24
      Width = 177
      Height = 17
      Alignment = taLeftJustify
      Caption = 'Vorhandene Liste l'#246'schen'
      TabOrder = 0
      OnClick = CheckBoxClearExisitingClick
    end
    object EditStartingNumber: TEdit
      Left = 177
      Top = 71
      Width = 80
      Height = 23
      NumbersOnly = True
      TabOrder = 1
    end
    object CheckBoxFillGaps: TCheckBox
      Left = 16
      Top = 47
      Width = 177
      Height = 17
      Alignment = taLeftJustify
      Caption = 'L'#252'cken auff'#252'llen'
      Checked = True
      State = cbChecked
      TabOrder = 2
      OnClick = CheckBoxFillGapsClick
    end
    object MemoLog: TMemo
      Left = 0
      Top = 160
      Width = 360
      Height = 240
      Align = alBottom
      TabOrder = 3
    end
    object ButtonStartReceiving: TButton
      Left = 16
      Top = 112
      Width = 321
      Height = 25
      Caption = 'Starten'
      TabOrder = 4
      OnClick = ButtonStartReceivingClick
    end
  end
end
