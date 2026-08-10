object FormManuallyAddPassing: TFormManuallyAddPassing
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Durchfahrt manuell hinzuf'#252'gen'
  ClientHeight = 460
  ClientWidth = 480
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 15
  object PanelGrid: TPanel
    Left = 0
    Top = 140
    Width = 480
    Height = 320
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object ListViewCompetitors: TListView
      Left = 0
      Top = 0
      Width = 480
      Height = 320
      Align = alClient
      Columns = <
        item
          Caption = 'Start#'
          Width = 55
        end
        item
          Caption = 'Name'
          Width = 140
        end
        item
          Caption = 'Team'
          Width = 120
        end
        item
          Caption = 'Chip'
          Width = 100
        end
        item
          Caption = 'Klasse'
          Width = 80
        end>
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnClick = ListViewCompetitorsClick
      OnDblClick = ListViewCompetitorsDblClick
    end
  end
  object PanelControls: TPanel
    Left = 0
    Top = 0
    Width = 480
    Height = 140
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      480
      140)
    object LabelRace: TLabel
      Left = 8
      Top = 10
      Width = 40
      Height = 15
      Caption = 'Rennen'
    end
    object Label3: TLabel
      Left = 8
      Top = 41
      Width = 38
      Height = 15
      Caption = 'Startnr.'
    end
    object Label2: TLabel
      Left = 200
      Top = 41
      Width = 37
      Height = 15
      Caption = 'Uhrzeit'
    end
    object LabelPreview: TLabel
      Left = 8
      Top = 72
      Width = 300
      Height = 15
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Fahrer / Chip'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGrayText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object ComboBoxRace: TComboBox
      Left = 80
      Top = 7
      Width = 280
      Height = 23
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      OnChange = ComboBoxRaceChange
    end
    object EditTime: TMaskEdit
      Left = 248
      Top = 38
      Width = 112
      Height = 23
      Alignment = taCenter
      EditMask = '!90:00:00.000;1;_'
      MaxLength = 12
      TabOrder = 2
      Text = '  :  :  .   '
    end
    object EditBIB: TEdit
      Left = 80
      Top = 38
      Width = 89
      Height = 23
      NumbersOnly = True
      TabOrder = 1
      OnChange = EditBIBChange
    end
    object ButtonOK: TButton
      Left = 300
      Top = 100
      Width = 83
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Hinzuf'#252'gen'
      Default = True
      TabOrder = 3
      OnClick = ButtonOKClick
    end
    object ButtonCancel: TButton
      Left = 389
      Top = 100
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Schlie'#223'en'
      TabOrder = 4
      OnClick = ButtonCancelClick
    end
  end
end
