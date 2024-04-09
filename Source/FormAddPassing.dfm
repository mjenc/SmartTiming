object FormManuallyAddPassing: TFormManuallyAddPassing
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Durchfahrt manuell hinzuf'#252'gen'
  ClientHeight = 389
  ClientWidth = 416
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
    Top = 73
    Width = 416
    Height = 316
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitTop = 97
    ExplicitWidth = 375
    ExplicitHeight = 307
    object ListViewCompetitors: TListView
      Left = 0
      Top = 0
      Width = 414
      Height = 308
      Align = alClient
      Columns = <
        item
          Caption = 'Start#'
          Width = 45
        end
        item
          Caption = 'Name'
          Width = 120
        end
        item
          Caption = 'Team'
          Width = 120
        end
        item
          Caption = 'Klasse'
          Width = 120
        end>
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnDblClick = ListViewCompetitorsDblClick
      ExplicitTop = -10
    end
  end
  object PanelControls: TPanel
    Left = 0
    Top = 0
    Width = 416
    Height = 73
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitWidth = 414
    DesignSize = (
      416
      73)
    object Label3: TLabel
      Left = 8
      Top = 8
      Width = 38
      Height = 15
      Caption = 'Startnr.'
    end
    object Label2: TLabel
      Left = 8
      Top = 37
      Width = 37
      Height = 15
      Caption = 'Uhrzeit'
    end
    object EditTime: TMaskEdit
      Left = 80
      Top = 34
      Width = 89
      Height = 23
      Alignment = taCenter
      EditMask = '!90:00:00.000;1;_'
      MaxLength = 12
      TabOrder = 1
      Text = '  :  :  .   '
    end
    object EditBIB: TEdit
      Left = 80
      Top = 5
      Width = 89
      Height = 23
      NumbersOnly = True
      TabOrder = 0
    end
    object ButtonOK: TButton
      Left = 241
      Top = 20
      Width = 83
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Hinzuf'#252'gen'
      Default = True
      ModalResult = 1
      TabOrder = 2
      OnClick = ButtonOKClick
      ExplicitLeft = 239
    end
    object ButtonCancel: TButton
      Left = 330
      Top = 20
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Schlie'#223'en'
      ModalResult = 2
      TabOrder = 3
      OnClick = ButtonCancelClick
      ExplicitLeft = 328
    end
  end
end
