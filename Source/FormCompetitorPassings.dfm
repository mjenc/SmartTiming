object FormCompetitorPassings: TFormCompetitorPassings
  Left = 0
  Top = 0
  Caption = 'Rundenprotokoll'
  ClientHeight = 480
  ClientWidth = 720
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
    Width = 720
    Height = 48
    Align = alTop
    BevelOuter = bvNone
    Padding.Left = 8
    Padding.Top = 8
    Padding.Right = 8
    TabOrder = 0
    object LabelCompetitor: TLabel
      Left = 8
      Top = 8
      Width = 400
      Height = 15
      Caption = 'Teilnehmer'
    end
    object ButtonInvalidate: TButton
      Left = 8
      Top = 28
      Width = 90
      Height = 25
      Caption = 'Ung'#252'ltig'
      TabOrder = 0
      OnClick = ButtonInvalidateClick
    end
    object ButtonValidate: TButton
      Left = 104
      Top = 28
      Width = 90
      Height = 25
      Caption = 'G'#252'ltig'
      TabOrder = 1
      OnClick = ButtonValidateClick
    end
    object ButtonClose: TButton
      Left = 637
      Top = 28
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Schlie'#223'en'
      ModalResult = 2
      TabOrder = 2
      OnClick = ButtonCloseClick
    end
  end
  object ListViewPassings: TListView
    Left = 0
    Top = 48
    Width = 720
    Height = 432
    Align = alClient
    Columns = <
      item
        Caption = 'Runde'
        Width = 60
      end
      item
        Caption = 'Zeit'
        Width = 110
      end
      item
        Caption = 'Rundenzeit'
        Width = 100
      end
      item
        Caption = 'Status'
        Width = 80
      end
      item
        Caption = 'Quelle'
        Width = 80
      end
      item
        Caption = 'Chip'
        Width = 120
      end
      item
        Caption = 'Passing#'
        Width = 70
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
  end
end
