object FormRaceDetails: TFormRaceDetails
  Left = 0
  Top = 0
  Caption = 'Rennen Details'
  ClientHeight = 287
  ClientWidth = 396
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object PanelButtons: TPanel
    Left = 0
    Top = 246
    Width = 396
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitLeft = 112
    ExplicitTop = 360
    ExplicitWidth = 185
    DesignSize = (
      396
      41)
    object ButtonOK: TButton
      Left = 222
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      ModalResult = 1
      TabOrder = 0
      OnClick = ButtonOKClick
      ExplicitLeft = 448
    end
    object ButtonCancel: TButton
      Left = 310
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Abbrechen'
      ModalResult = 2
      TabOrder = 1
      ExplicitLeft = 536
    end
  end
  object PanelMain: TPanel
    Left = 0
    Top = 0
    Width = 396
    Height = 246
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitLeft = 112
    ExplicitTop = 360
    ExplicitWidth = 185
    ExplicitHeight = 41
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
      Top = 111
      Width = 62
      Height = 15
      Caption = 'Rundenzahl'
    end
    object Label3: TLabel
      Left = 17
      Top = 163
      Width = 38
      Height = 15
      Caption = 'Distanz'
    end
    object Label4: TLabel
      Left = 17
      Top = 192
      Width = 112
      Height = 15
      Caption = 'Minimale Rundenzeit'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object EditTitle: TEdit
      Left = 181
      Top = 21
      Width = 193
      Height = 23
      TabOrder = 0
    end
    object EditTime: TMaskEdit
      Left = 253
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
      TabOrder = 3
    end
    object EditLapCount: TEdit
      Left = 181
      Top = 108
      Width = 60
      Height = 23
      Alignment = taCenter
      NumbersOnly = True
      TabOrder = 4
      Text = '1'
    end
    object CBFirstPassingCounts: TCheckBox
      Left = 17
      Top = 137
      Width = 180
      Height = 17
      Alignment = taLeftJustify
      Caption = 'Erste Passage z'#228'hlt als Runde'
      TabOrder = 5
    end
    object EditDistance: TEdit
      Left = 181
      Top = 160
      Width = 60
      Height = 23
      Alignment = taCenter
      NumbersOnly = True
      TabOrder = 6
      Text = '1'
    end
    object EditMinLapDuration: TMaskEdit
      Left = 181
      Top = 189
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
      Width = 58
      Height = 23
      Alignment = taCenter
      EditMask = '!99/99/00;1;_'
      MaxLength = 8
      TabOrder = 1
      Text = '  .  .  '
    end
  end
end
