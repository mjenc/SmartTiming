object FormSettings: TFormSettings
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Einstellungen'
  ClientHeight = 598
  ClientWidth = 569
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnShow = FormShow
  TextHeight = 15
  object PanelButtons: TPanel
    Left = 0
    Top = 557
    Width = 569
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitTop = 565
    ExplicitWidth = 571
    object ButtonOK: TButton
      Left = 399
      Top = 8
      Width = 75
      Height = 25
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object ButtonCancel: TButton
      Left = 480
      Top = 8
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Abbrechen'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object PanelTemperatureSettings: TPanel
    Left = 0
    Top = 0
    Width = 569
    Height = 105
    Align = alTop
    BevelEdges = [beBottom]
    BevelKind = bkFlat
    BevelOuter = bvNone
    BevelWidth = 2
    TabOrder = 1
    ExplicitWidth = 571
    object Label1: TLabel
      Left = 16
      Top = 43
      Width = 89
      Height = 15
      Caption = 'Schwellwert gelb'
    end
    object Label2: TLabel
      Left = 16
      Top = 72
      Width = 81
      Height = 15
      Caption = 'Schwellwert rot'
    end
    object Label3: TLabel
      Left = 16
      Top = 14
      Width = 264
      Height = 20
      Caption = #220'berwachungsparameter Temperatur'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object EditTemperatureThresholdYellow: TEdit
      Left = 120
      Top = 40
      Width = 81
      Height = 23
      NumbersOnly = True
      TabOrder = 0
    end
    object EditTemperatureThresholdRed: TEdit
      Left = 120
      Top = 69
      Width = 81
      Height = 23
      NumbersOnly = True
      TabOrder = 1
    end
    object CheckBoxTemperatureSoundOnYellow: TCheckBox
      Left = 232
      Top = 44
      Width = 121
      Height = 15
      Alignment = taLeftJustify
      Caption = 'Akustisches Signal'
      TabOrder = 2
    end
    object CheckBoxTemperatureSoundOnRed: TCheckBox
      Left = 232
      Top = 73
      Width = 121
      Height = 15
      Alignment = taLeftJustify
      Caption = 'Akustisches Signal'
      TabOrder = 3
    end
    object CheckBoxTemperatureDialogOnYellow: TCheckBox
      Left = 408
      Top = 44
      Width = 112
      Height = 15
      Alignment = taLeftJustify
      Caption = 'Dialog anzeigen'
      TabOrder = 4
    end
    object CheckBoxTemperatureDialogOnRed: TCheckBox
      Left = 408
      Top = 73
      Width = 112
      Height = 15
      Alignment = taLeftJustify
      Caption = 'Dialog anzeigen'
      TabOrder = 5
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 105
    Width = 569
    Height = 105
    Align = alTop
    BevelEdges = [beBottom]
    BevelKind = bkFlat
    BevelOuter = bvNone
    TabOrder = 2
    ExplicitWidth = 571
    object Label4: TLabel
      Left = 16
      Top = 43
      Width = 89
      Height = 15
      Caption = 'Schwellwert gelb'
    end
    object Label5: TLabel
      Left = 16
      Top = 72
      Width = 81
      Height = 15
      Caption = 'Schwellwert rot'
    end
    object Label6: TLabel
      Left = 16
      Top = 14
      Width = 243
      Height = 20
      Caption = #220'berwachungsparameter St'#246'rlevel'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object EditNoiseThresholdYellow: TEdit
      Left = 120
      Top = 40
      Width = 81
      Height = 23
      NumbersOnly = True
      TabOrder = 0
    end
    object EditNoiseThresholdRed: TEdit
      Left = 120
      Top = 69
      Width = 81
      Height = 23
      NumbersOnly = True
      TabOrder = 1
    end
    object CheckBoxNoiseSoundOnYellow: TCheckBox
      Left = 232
      Top = 44
      Width = 121
      Height = 15
      Alignment = taLeftJustify
      Caption = 'Akustisches Signal'
      TabOrder = 2
    end
    object CheckBoxNoiseSoundOnRed: TCheckBox
      Left = 232
      Top = 73
      Width = 121
      Height = 15
      Alignment = taLeftJustify
      Caption = 'Akustisches Signal'
      TabOrder = 3
    end
    object CheckBoxNoiseDialogOnYellow: TCheckBox
      Left = 408
      Top = 44
      Width = 112
      Height = 15
      Alignment = taLeftJustify
      Caption = 'Dialog anzeigen'
      TabOrder = 4
    end
    object CheckBoxNoiseDialogOnRed: TCheckBox
      Left = 408
      Top = 73
      Width = 112
      Height = 15
      Alignment = taLeftJustify
      Caption = 'Dialog anzeigen'
      TabOrder = 5
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 210
    Width = 569
    Height = 105
    Align = alTop
    BevelEdges = [beBottom]
    BevelKind = bkFlat
    BevelOuter = bvNone
    TabOrder = 3
    ExplicitWidth = 571
    object Label7: TLabel
      Left = 16
      Top = 43
      Width = 89
      Height = 15
      Caption = 'Schwellwert gelb'
    end
    object Label8: TLabel
      Left = 16
      Top = 72
      Width = 81
      Height = 15
      Caption = 'Schwellwert rot'
    end
    object Label9: TLabel
      Left = 16
      Top = 14
      Width = 252
      Height = 20
      Caption = #220'berwachungsparameter Spannung'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object EditVoltageThresholdYellow: TEdit
      Left = 120
      Top = 40
      Width = 81
      Height = 23
      NumbersOnly = True
      TabOrder = 0
    end
    object EditVoltageThresholdRed: TEdit
      Left = 120
      Top = 69
      Width = 81
      Height = 23
      NumbersOnly = True
      TabOrder = 1
    end
    object CheckBoxVoltageSoundOnYellow: TCheckBox
      Left = 232
      Top = 44
      Width = 121
      Height = 15
      Alignment = taLeftJustify
      Caption = 'Akustisches Signal'
      TabOrder = 2
    end
    object CheckBoxVoltageSoundOnRed: TCheckBox
      Left = 232
      Top = 73
      Width = 121
      Height = 15
      Alignment = taLeftJustify
      Caption = 'Akustisches Signal'
      TabOrder = 3
    end
    object CheckBoxVoltageDialogOnYellow: TCheckBox
      Left = 408
      Top = 44
      Width = 112
      Height = 15
      Alignment = taLeftJustify
      Caption = 'Dialog anzeigen'
      TabOrder = 4
    end
    object CheckBoxVoltageDialogOnRed: TCheckBox
      Left = 408
      Top = 73
      Width = 112
      Height = 15
      Alignment = taLeftJustify
      Caption = 'Dialog anzeigen'
      TabOrder = 5
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 315
    Width = 569
    Height = 242
    Align = alClient
    BevelEdges = [beBottom]
    BevelKind = bkFlat
    BevelOuter = bvNone
    TabOrder = 4
    ExplicitWidth = 571
    ExplicitHeight = 250
    object ButtonPlayWarnSound: TButton
      Left = 16
      Top = 25
      Width = 179
      Height = 25
      Caption = 'Warnsignal'
      TabOrder = 0
      OnClick = ButtonPlayWarnSoundClick
    end
    object ButtonPlayAlertSound: TButton
      Left = 16
      Top = 56
      Width = 179
      Height = 25
      Caption = 'Alarmsignal'
      TabOrder = 1
      OnClick = ButtonPlayAlertSoundClick
    end
  end
end
