object FormSmartStartListServer: TFormSmartStartListServer
  Left = 0
  Top = 0
  Caption = 'SmartStartListServer'
  ClientHeight = 480
  ClientWidth = 800
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 13
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 800
    Height = 120
    Align = alTop
    TabOrder = 0
    object LabelCsv: TLabel
      Left = 8
      Top = 12
      Width = 52
      Height = 13
      Caption = 'CSV-Datei:'
    end
    object LabelPort: TLabel
      Left = 8
      Top = 48
      Width = 24
      Height = 13
      Caption = 'Port:'
    end
    object EditCsv: TEdit
      Left = 80
      Top = 8
      Width = 600
      Height = 21
      TabOrder = 0
    end
    object ButtonBrowse: TButton
      Left = 688
      Top = 6
      Width = 75
      Height = 25
      Caption = '...'
      TabOrder = 1
      OnClick = ButtonBrowseClick
    end
    object SpinEditPort: TSpinEdit
      Left = 80
      Top = 44
      Width = 80
      Height = 22
      MaxValue = 65535
      MinValue = 1
      TabOrder = 2
      Value = 9768
    end
    object ButtonStart: TButton
      Left = 200
      Top = 42
      Width = 90
      Height = 25
      Caption = 'Start'
      TabOrder = 3
      OnClick = ButtonStartClick
    end
    object ButtonStop: TButton
      Left = 296
      Top = 42
      Width = 90
      Height = 25
      Caption = 'Stop'
      TabOrder = 4
      OnClick = ButtonStopClick
    end
    object ButtonSaveMapping: TButton
      Left = 400
      Top = 42
      Width = 120
      Height = 25
      Caption = 'Mapping speichern'
      TabOrder = 5
      OnClick = ButtonSaveMappingClick
    end
    object ButtonLoadMapping: TButton
      Left = 528
      Top = 42
      Width = 120
      Height = 25
      Caption = 'Mapping laden'
      TabOrder = 6
      OnClick = ButtonLoadMappingClick
    end
  end
  object GroupBoxMapping: TGroupBox
    Left = 0
    Top = 120
    Width = 800
    Height = 200
    Align = alTop
    Caption = 'Spaltenmapping'
    TabOrder = 1
    object LabelClass: TLabel
      Left = 16
      Top = 28
      Width = 30
      Height = 13
      Caption = 'Klasse'
    end
    object LabelBib: TLabel
      Left = 16
      Top = 56
      Width = 62
      Height = 13
      Caption = 'Startnummer'
    end
    object LabelFirstName: TLabel
      Left = 16
      Top = 84
      Width = 42
      Height = 13
      Caption = 'Vorname'
    end
    object LabelLastName: TLabel
      Left = 16
      Top = 112
      Width = 50
      Height = 13
      Caption = 'Nachname'
    end
    object LabelClub: TLabel
      Left = 16
      Top = 140
      Width = 30
      Height = 13
      Caption = 'Verein'
    end
    object LabelTeam: TLabel
      Left = 400
      Top = 28
      Width = 26
      Height = 13
      Caption = 'Team'
    end
    object LabelNationality: TLabel
      Left = 400
      Top = 56
      Width = 31
      Height = 13
      Caption = 'Nation'
    end
    object LabelUciId: TLabel
      Left = 400
      Top = 84
      Width = 33
      Height = 13
      Caption = 'UCI-ID'
    end
    object LabelStartTime: TLabel
      Left = 400
      Top = 112
      Width = 41
      Height = 13
      Caption = 'Startzeit'
    end
    object ComboClass: TComboBox
      Left = 120
      Top = 24
      Width = 200
      Height = 21
      Style = csDropDownList
      TabOrder = 0
    end
    object ComboBib: TComboBox
      Left = 120
      Top = 52
      Width = 200
      Height = 21
      Style = csDropDownList
      TabOrder = 1
    end
    object ComboFirstName: TComboBox
      Left = 120
      Top = 80
      Width = 200
      Height = 21
      Style = csDropDownList
      TabOrder = 2
    end
    object ComboLastName: TComboBox
      Left = 120
      Top = 108
      Width = 200
      Height = 21
      Style = csDropDownList
      TabOrder = 3
    end
    object ComboClub: TComboBox
      Left = 120
      Top = 136
      Width = 200
      Height = 21
      Style = csDropDownList
      TabOrder = 4
    end
    object ComboTeam: TComboBox
      Left = 480
      Top = 24
      Width = 200
      Height = 21
      Style = csDropDownList
      TabOrder = 5
    end
    object ComboNationality: TComboBox
      Left = 480
      Top = 52
      Width = 200
      Height = 21
      Style = csDropDownList
      TabOrder = 6
    end
    object ComboUciId: TComboBox
      Left = 480
      Top = 80
      Width = 200
      Height = 21
      Style = csDropDownList
      TabOrder = 7
    end
    object ComboStartTime: TComboBox
      Left = 480
      Top = 108
      Width = 200
      Height = 21
      Style = csDropDownList
      TabOrder = 8
    end
  end
  object MemoLog: TMemo
    Left = 0
    Top = 320
    Width = 800
    Height = 160
    Align = alClient
    TabOrder = 2
  end
  object OpenDialogCsv: TOpenDialog
    Filter = 'CSV-Dateien (*.csv)|*.csv|Alle Dateien (*.*)|*.*'
    Left = 736
    Top = 88
  end
end
