object FormManuallyAddPassing: TFormManuallyAddPassing
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Durchfahrt manuell hinzuf'#252'gen'
  ClientHeight = 445
  ClientWidth = 375
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
  object PanelButtons: TPanel
    Left = 0
    Top = 404
    Width = 375
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      375
      41)
    object ButtonOK: TButton
      Left = 200
      Top = 6
      Width = 83
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object ButtonCancel: TButton
      Left = 289
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
  object PanelControls: TPanel
    Left = 0
    Top = 0
    Width = 375
    Height = 97
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object Label3: TLabel
      Left = 8
      Top = 8
      Width = 49
      Height = 23
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
  end
  object PanelGrid: TPanel
    Left = 0
    Top = 97
    Width = 375
    Height = 307
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object ListViewCompetitors: TListView
      Left = 0
      Top = 0
      Width = 375
      Height = 307
      Align = alClient
      Columns = <
        item
          Caption = 'Startnr.'
        end
        item
          Caption = 'Name'
        end
        item
          Caption = 'Team'
        end
        item
          Caption = 'Klasse'
        end>
      GridLines = True
      Items.ItemData = {
        057B0000000100000000000000FFFFFFFFFFFFFFFF03000000FFFFFFFF000000
        000131000C4D00690063006800610065006C0020004A0065006E00630030E986
        2410520053004700200052006900650064002000520061007300740061007400
        7400A0D48624094D006100730074006500720073002000330090E68624FFFFFF
        FFFFFF}
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      ExplicitLeft = 96
      ExplicitTop = 88
      ExplicitWidth = 250
      ExplicitHeight = 150
    end
  end
end
