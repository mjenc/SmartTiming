object FormAssignCompetitor: TFormAssignCompetitor
  Left = 0
  Top = 0
  Caption = 'Fahrer zu Transponder zuweisen'
  ClientHeight = 441
  ClientWidth = 415
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  OnActivate = FormActivate
  OnShow = FormShow
  object PanelControls: TPanel
    Left = 0
    Top = 0
    Width = 415
    Height = 33
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      415
      33)
    object Label3: TLabel
      Left = 8
      Top = 8
      Width = 38
      Height = 15
      Caption = 'Startnr.'
    end
    object EditBIB: TEdit
      Left = 80
      Top = 5
      Width = 89
      Height = 23
      NumbersOnly = True
      TabOrder = 0
      OnChange = EditBIBChange
    end
    object ButtonOK: TButton
      Left = 240
      Top = 4
      Width = 83
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Zuweisen'
      Default = True
      ModalResult = 0
      TabOrder = 1
      OnClick = ButtonOKClick
    end
    object ButtonCancel: TButton
      Left = 329
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Abbrechen'
      ModalResult = 2
      TabOrder = 2
    end
  end
  object PanelGrid: TPanel
    Left = 0
    Top = 33
    Width = 415
    Height = 408
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 73
    ExplicitWidth = 416
    ExplicitHeight = 316
    object ListViewCompetitors: TListView
      Left = 0
      Top = 0
      Width = 415
      Height = 408
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
      ExplicitWidth = 416
      ExplicitHeight = 316
    end
  end
end
