object FormPassingSimulator: TFormPassingSimulator
  Left = 0
  Top = 0
  Caption = 'Decoder-Simulator (Test)'
  ClientHeight = 560
  ClientWidth = 640
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 15
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 640
    Height = 185
    Align = alTop
    BevelOuter = bvNone
    Padding.Left = 12
    Padding.Top = 10
    Padding.Right = 12
    Padding.Bottom = 8
    TabOrder = 0
    object LabelHint: TLabel
      Left = 12
      Top = 10
      Width = 616
      Height = 30
      Align = alTop
      Caption = 
        'Erzeugt Test-Passagen wie ein MyLaps-Decoder. Kurznummer wird '#252'ber das Tx-Mapping aufgel'#246'st.'
      WordWrap = True
      ExplicitWidth = 500
    end
    object RadioGroupMode: TRadioGroup
      Left = 12
      Top = 40
      Width = 616
      Height = 48
      Align = alTop
      Caption = 'Einspeisung'
      Columns = 2
      ItemIndex = 0
      Items.Strings = (
        'In-Process (SendSimulatedPassing)'
        'P3-Loopback (127.0.0.1:5403)')
      TabOrder = 0
      OnClick = RadioGroupModeClick
    end
    object PanelInputs: TPanel
      Left = 12
      Top = 88
      Width = 616
      Height = 89
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object LabelShortId: TLabel
        Left = 0
        Top = 8
        Width = 78
        Height = 15
        Caption = 'Kurznummer'
      end
      object EditShortId: TEdit
        Left = 0
        Top = 28
        Width = 100
        Height = 23
        TabOrder = 0
        OnChange = EditShortIdChange
      end
      object LabelChip: TLabel
        Left = 120
        Top = 8
        Width = 35
        Height = 15
        Caption = 'ChipId'
      end
      object LabelChipPreview: TLabel
        Left = 120
        Top = 30
        Width = 200
        Height = 15
        Caption = '-'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object LabelTime: TLabel
        Left = 340
        Top = 8
        Width = 70
        Height = 15
        Caption = 'Zeit (opt.)'
      end
      object EditTime: TMaskEdit
        Left = 340
        Top = 28
        Width = 110
        Height = 23
        EditMask = '!90:00:00.000;1;_'
        MaxLength = 12
        TabOrder = 1
        Text = '  :  :  .   '
      end
      object LabelSignal: TLabel
        Left = 0
        Top = 60
        Width = 33
        Height = 15
        Caption = 'Signal'
      end
      object EditSignal: TEdit
        Left = 40
        Top = 57
        Width = 50
        Height = 23
        TabOrder = 2
        Text = '100'
      end
      object LabelHits: TLabel
        Left = 110
        Top = 60
        Width = 22
        Height = 15
        Caption = 'Hits'
      end
      object EditHits: TEdit
        Left = 140
        Top = 57
        Width = 50
        Height = 23
        TabOrder = 3
        Text = '90'
      end
      object ButtonSend: TButton
        Left = 220
        Top = 55
        Width = 90
        Height = 25
        Caption = 'Senden'
        Default = True
        TabOrder = 4
        OnClick = ButtonSendClick
      end
      object ButtonUseNow: TButton
        Left = 460
        Top = 26
        Width = 75
        Height = 25
        Caption = 'Jetzt'
        TabOrder = 5
        OnClick = ButtonUseNowClick
      end
    end
  end
  object PanelMapping: TPanel
    Left = 0
    Top = 185
    Width = 640
    Height = 40
    Align = alTop
    BevelOuter = bvNone
    Padding.Left = 12
    Padding.Right = 12
    TabOrder = 1
    object LabelMappingStatus: TLabel
      Left = 12
      Top = 12
      Width = 80
      Height = 15
      Caption = 'Mapping: -'
    end
    object ButtonImportMapping: TButton
      Left = 168
      Top = 8
      Width = 148
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Mapping importieren'#8230
      TabOrder = 0
      OnClick = ButtonImportMappingClick
    end
    object ButtonRunRuleTests: TButton
      Left = 322
      Top = 8
      Width = 148
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Regelkatalog testen'
      TabOrder = 1
      OnClick = ButtonRunRuleTestsClick
    end
    object ButtonRunCorrectionTests: TButton
      Left = 476
      Top = 8
      Width = 152
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Korrektur-Regression'
      TabOrder = 2
      OnClick = ButtonRunCorrectionTestsClick
    end
  end
  object ListViewLog: TListView
    Left = 0
    Top = 225
    Width = 640
    Height = 294
    Align = alClient
    Columns = <
      item
        Caption = '#'
        Width = 50
      end
      item
        Caption = 'Kurznummer'
        Width = 80
      end
      item
        Caption = 'ChipId'
        Width = 110
      end
      item
        Caption = 'Zeit'
        Width = 110
      end
      item
        Caption = 'Signal'
        Width = 55
      end
      item
        Caption = 'Kanal'
        Width = 60
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 2
    ViewStyle = vsReport
  end
  object PanelButtons: TPanel
    Left = 0
    Top = 519
    Width = 640
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    DesignSize = (
      640
      41)
    object ButtonClose: TButton
      Left = 546
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Schlie'#223'en'
      TabOrder = 0
      OnClick = ButtonCloseClick
    end
  end
  object OpenDialogMapping: TOpenDialog
    DefaultExt = 'txt'
    Filter = 'Mapping (*.txt)|*.txt|Alle Dateien (*.*)|*.*'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Title = 'Transponder-Mapping importieren'
    Left = 304
    Top = 320
  end
end
