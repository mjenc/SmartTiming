object FormPassingSimulator: TFormPassingSimulator
  Left = 0
  Top = 0
  Caption = 'Passagensimulator'
  ClientHeight = 727
  ClientWidth = 934
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
    Top = 686
    Width = 934
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      934
      41)
    object ButtonClose: TButton
      Left = 840
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Schlie'#223'en'
      ModalResult = 1
      TabOrder = 0
      OnClick = ButtonCloseClick
    end
  end
  object PageControlSimulator: TPageControl
    AlignWithMargins = True
    Left = 5
    Top = 5
    Width = 924
    Height = 676
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    ActivePage = TabSheetSinglePassings
    Align = alClient
    TabOrder = 1
    object TabSheetSinglePassings: TTabSheet
      Caption = 'Einzelpassagen'
      object StringGridCompetitorsInRace: TStringGrid
        Left = 0
        Top = 0
        Width = 916
        Height = 646
        Align = alClient
        FixedCols = 0
        FixedRows = 0
        TabOrder = 0
        OnSelectCell = StringGridCompetitorsInRaceCellClick
      end
    end
    object TabSheetSingleSimulateRace: TTabSheet
      Caption = 'Rennsimulation'
      ImageIndex = 1
    end
  end
  object SQLDataSetCompetitorsInRace: TSQLDataSet
    CommandText = 'SELECT * FROM COMPETITORS'
    DataSource = DataSourceCompetitorsInRace
    MaxBlobSize = -1
    Params = <>
    SQLConnection = MainDataModule.SQLConnection
    Left = 316
    Top = 417
  end
  object DataSetProviderCompetitorsInRace: TDataSetProvider
    DataSet = SQLDataSetCompetitorsInRace
    Options = [poAutoRefresh, poUseQuoteChar]
    Left = 316
    Top = 311
  end
  object ClientDataSetCompetitorsInRace: TClientDataSet
    Aggregates = <>
    DisableStringTrim = True
    Params = <>
    ProviderName = 'DataSetProviderCompetitorsInRace'
    Left = 316
    Top = 231
  end
  object DataSourceCompetitorsInRace: TDataSource
    DataSet = ClientDataSetCompetitorsInRace
    Left = 316
    Top = 139
  end
end
