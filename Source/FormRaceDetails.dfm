object FormRaceDetails: TFormRaceDetails
  Left = 0
  Top = 0
  Caption = 'Rennen Details'
  ClientHeight = 327
  ClientWidth = 406
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object PanelButtons: TPanel
    Left = 0
    Top = 286
    Width = 406
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      406
      41)
    object ButtonOK: TButton
      Left = 232
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
      OnClick = ButtonOKClick
    end
    object ButtonCancel: TButton
      Left = 320
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
    Width = 406
    Height = 286
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object Bezeichnung: TLabel
      Left = 17
      Top = 24
      Width = 68
      Height = 15
      Caption = 'Bezeichnung'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object Label1: TLabel
      Left = 17
      Top = 53
      Width = 42
      Height = 15
      Caption = 'Startzeit'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object Label2: TLabel
      Left = 17
      Top = 82
      Width = 16
      Height = 15
      Caption = 'Art'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object LabelLapCount: TLabel
      Left = 17
      Top = 120
      Width = 150
      Height = 15
      AutoSize = False
      Caption = 'Runden'
    end
    object Label3: TLabel
      Left = 17
      Top = 175
      Width = 38
      Height = 15
      Caption = 'Distanz'
    end
    object Label4: TLabel
      Left = 17
      Top = 204
      Width = 150
      Height = 15
      AutoSize = False
      Caption = 'Minimale Rundenzeit'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object EditTime: TMaskEdit
      Left = 259
      Top = 50
      Width = 60
      Height = 23
      Alignment = taCenter
      EditMask = '!90:00:00;1;_'
      MaxLength = 8
      TabOrder = 2
      Text = '  :  :  '
    end
    object ComboBoxRaceType: TComboBox
      Left = 181
      Top = 79
      Width = 193
      Height = 23
      Style = csDropDownList
      TabOrder = 3
      OnChange = ComboBoxRaceTypeChange
    end
    object CBFirstPassingCounts: TCheckBox
      Left = 17
      Top = 149
      Width = 250
      Height = 17
      Alignment = taLeftJustify
      Caption = 'Erste Passage z'#228'hlt als Runde'
      TabOrder = 5
    end
    object EditMinLapDuration: TMaskEdit
      Left = 181
      Top = 201
      Width = 60
      Height = 23
      Alignment = taCenter
      EditMask = '!90:00;1;_'
      MaxLength = 5
      TabOrder = 7
      Text = '  :  '
    end
    object EditDate: TMaskEdit
      Left = 181
      Top = 50
      Width = 72
      Height = 23
      Alignment = taCenter
      EditMask = '!99/99/0000;1;_'
      MaxLength = 10
      TabOrder = 1
      Text = '  .  .    '
    end
    object DBEditTitle: TDBEdit
      Left = 181
      Top = 21
      Width = 193
      Height = 23
      DataSource = MainDataModule.DataSourceRaces
      TabOrder = 0
    end
    object DBEditLapCount: TDBEdit
      Left = 181
      Top = 117
      Width = 60
      Height = 23
      DataSource = MainDataModule.DataSourceRaces
      TabOrder = 4
    end
    object DBEditDistance: TDBEdit
      Left = 181
      Top = 172
      Width = 60
      Height = 23
      DataSource = MainDataModule.DataSourceRaces
      TabOrder = 6
    end
  end
end
