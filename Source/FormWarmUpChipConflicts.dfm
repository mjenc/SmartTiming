object FormWarmUpChipConflicts: TFormWarmUpChipConflicts
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Chip-Konflikte vor Vorbereitung'
  ClientHeight = 360
  ClientWidth = 700
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  TextHeight = 15
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 700
    Height = 49
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object LabelHint: TLabel
      Left = 8
      Top = 8
      Width = 684
      Height = 33
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 
        'Folgende Chips sind bereits in einem anderen aktiven Rennen zuge' +
        'ordnet.'
      WordWrap = True
    end
  end
  object ListViewConflicts: TListView
    Left = 0
    Top = 49
    Width = 700
    Height = 266
    Align = alClient
    Columns = <
      item
        Caption = 'Chip'
        Width = 100
      end
      item
        Caption = 'Fahrer (dieses Rennen)'
        Width = 150
      end
      item
        Caption = 'Anderes Rennen'
        Width = 140
      end
      item
        Caption = 'Fahrer (anderes Rennen)'
        Width = 150
      end
      item
        Caption = 'Status'
        Width = 100
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
  end
  object PanelButtons: TPanel
    Left = 0
    Top = 315
    Width = 700
    Height = 45
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      700
      45)
    object ButtonContinue: TButton
      Left = 412
      Top = 10
      Width = 161
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Trotzdem fortfahren'
      ModalResult = 6
      TabOrder = 0
    end
    object ButtonCancel: TButton
      Left = 579
      Top = 10
      Width = 110
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Abbrechen'
      ModalResult = 2
      TabOrder = 1
    end
  end
end
