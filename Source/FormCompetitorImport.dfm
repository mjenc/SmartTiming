object FormCompetitorImport: TFormCompetitorImport
  Left = 0
  Top = 0
  Caption = 'Teilnehmer importieren'
  ClientHeight = 496
  ClientWidth = 821
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object PanelButtons: TPanel
    Left = 0
    Top = 455
    Width = 821
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitTop = 447
    ExplicitWidth = 819
    DesignSize = (
      821
      41)
    object LabelProgress: TLabel
      Left = 348
      Top = 12
      Width = 3
      Height = 15
    end
    object ButtonOK: TButton
      Left = 647
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Importieren'
      Default = True
      ModalResult = 1
      TabOrder = 0
      OnClick = ButtonOKClick
      ExplicitLeft = 645
    end
    object ButtonCancel: TButton
      Left = 735
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Abbrechen'
      ModalResult = 2
      TabOrder = 1
      ExplicitLeft = 733
    end
    object ProgressBar: TProgressBar
      Left = 16
      Top = 10
      Width = 313
      Height = 21
      TabOrder = 2
      Visible = False
    end
  end
  object PanelMappings: TPanel
    Left = 0
    Top = 0
    Width = 249
    Height = 455
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitHeight = 447
    DesignSize = (
      249
      455)
    object Label1: TLabel
      Left = 16
      Top = 11
      Width = 97
      Height = 15
      Caption = 'Spaltenzuordnung'
    end
    object StringGridFieldMapping: TStringGrid
      Left = 13
      Top = 32
      Width = 230
      Height = 409
      Anchors = [akLeft, akTop, akRight, akBottom]
      BorderStyle = bsNone
      ColCount = 2
      DefaultColWidth = 114
      FixedCols = 0
      RowCount = 9
      FixedRows = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goFixedRowDefAlign]
      TabOrder = 0
      OnGetEditText = StringGridFieldMappingGetEditText
      OnSelectCell = StringGridFieldMappingSelectCell
      ExplicitHeight = 401
    end
  end
  object ComboBoxFileColumns: TComboBox
    Left = 64
    Top = 344
    Width = 145
    Height = 23
    TabOrder = 2
    Visible = False
    OnExit = ComboBoxFileColumnsExit
    Items.Strings = (
      'No'
      'Class'
      'FirstName'
      'LastName'
      'Club'
      'Team'
      'UCIID'
      'Transponder')
  end
  object PanelGrid: TPanel
    Left = 249
    Top = 0
    Width = 572
    Height = 455
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 3
    ExplicitWidth = 570
    ExplicitHeight = 447
    DesignSize = (
      572
      455)
    object Label2: TLabel
      Left = 16
      Top = 11
      Width = 48
      Height = 15
      Caption = 'Vorschau'
    end
    object StringGridPreview: TStringGrid
      Left = 16
      Top = 32
      Width = 542
      Height = 409
      Anchors = [akLeft, akTop, akRight, akBottom]
      ColCount = 8
      FixedCols = 0
      TabOrder = 0
      ExplicitWidth = 540
      ExplicitHeight = 401
    end
  end
  object FileOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = []
    Left = 200
    Top = 416
  end
end
