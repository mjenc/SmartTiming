object FormUnassignedPassings: TFormUnassignedPassings
  Left = 0
  Top = 0
  Caption = 'Nicht zugeordnete Transponder'
  ClientHeight = 420
  ClientWidth = 560
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnShow = FormShow
  TextHeight = 15
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 560
    Height = 57
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object LabelHint: TLabel
      Left = 8
      Top = 8
      Width = 400
      Height = 15
      Caption = 
        'Passagen ohne eindeutige Chip-Zuordnung. Zuweisen nutzt das aktue' +
        'll gew'#228'hlte Rennen.'
    end
    object ButtonAssign: TButton
      Left = 8
      Top = 28
      Width = 97
      Height = 25
      Caption = 'Zuweisen'
      TabOrder = 0
      OnClick = ButtonAssignClick
    end
    object ButtonDelete: TButton
      Left = 111
      Top = 28
      Width = 97
      Height = 25
      Caption = 'L'#246'schen'
      TabOrder = 1
      OnClick = ButtonDeleteClick
    end
    object ButtonRefresh: TButton
      Left = 214
      Top = 28
      Width = 97
      Height = 25
      Caption = 'Aktualisieren'
      TabOrder = 2
      OnClick = ButtonRefreshClick
    end
    object ButtonClose: TButton
      Left = 477
      Top = 28
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Schlie'#223'en'
      ModalResult = 2
      TabOrder = 3
      OnClick = ButtonCloseClick
    end
  end
  object ListViewPassings: TListView
    Left = 0
    Top = 57
    Width = 560
    Height = 363
    Align = alClient
    Columns = <
      item
        Caption = 'Chip'
        Width = 120
      end
      item
        Caption = 'Uhrzeit'
        Width = 110
      end
      item
        Caption = 'Signal'
        Width = 60
      end
      item
        Caption = 'Passage#'
        Width = 80
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    OnDblClick = ListViewPassingsDblClick
  end
end
