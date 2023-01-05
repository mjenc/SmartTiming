object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'SmartTiming'
  ClientHeight = 904
  ClientWidth = 1475
  Color = clBackground
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 15
  object PanelTitle: TPanel
    AlignWithMargins = True
    Left = 0
    Top = 0
    Width = 1475
    Height = 59
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alTop
    BevelKind = bkFlat
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      1471
      55)
    object LabelTitle: TLabel
      Left = 10
      Top = 31
      Width = 68
      Height = 20
      Caption = 'LabelTitle'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LabelOrganizer: TLabel
      Left = 10
      Top = 8
      Width = 105
      Height = 20
      Caption = 'LabelOrganizer'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LabelDate: TLabel
      Left = 1384
      Top = 8
      Width = 70
      Height = 20
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      Caption = 'LabelDate'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitLeft = 1009
    end
  end
  object PanelMain: TPanel
    Left = 0
    Top = 59
    Width = 1475
    Height = 796
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 1
    object PageControlMain: TPageControl
      AlignWithMargins = True
      Left = 0
      Top = 6
      Width = 1475
      Height = 784
      Margins.Left = 0
      Margins.Top = 6
      Margins.Right = 0
      Margins.Bottom = 6
      ActivePage = TabSheetTiming
      Align = alClient
      TabHeight = 30
      TabOrder = 0
      StyleElements = [seFont, seClient]
      OnChange = PageControlMainChange
      object TabSheetEvent: TTabSheet
        Caption = 'Veranstaltung'
        object PanelEventInfo: TPanel
          Left = 0
          Top = 0
          Width = 1467
          Height = 121
          Align = alTop
          BevelKind = bkFlat
          BevelOuter = bvNone
          TabOrder = 0
          object Label1: TLabel
            Left = 28
            Top = 16
            Width = 85
            Height = 20
            Caption = 'Veranstalter'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Label2: TLabel
            Left = 28
            Top = 45
            Width = 31
            Height = 20
            Caption = 'Titel'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Label3: TLabel
            Left = 488
            Top = 16
            Width = 78
            Height = 20
            Caption = 'Datum von'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Label8: TLabel
            Left = 736
            Top = 16
            Width = 72
            Height = 20
            Caption = 'Datum bis'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object EditOrganizer: TEdit
            Left = 119
            Top = 13
            Width = 345
            Height = 23
            TabOrder = 0
          end
          object EditTitle: TEdit
            Left = 119
            Top = 42
            Width = 345
            Height = 23
            TabOrder = 1
          end
          object DatePickerFrom: TDatePicker
            Left = 572
            Top = 13
            Width = 120
            Date = 44736.000000000000000000
            DateFormat = 'dd/mm/yyyy'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = 'Segoe UI'
            Font.Style = []
            TabOrder = 2
            OnChange = DatePickerFromChange
          end
          object DatePickerTo: TDatePicker
            Left = 822
            Top = 13
            Width = 120
            Date = 44736.000000000000000000
            DateFormat = 'dd/mm/yyyy'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = 'Segoe UI'
            Font.Style = []
            TabOrder = 3
          end
          object ButtonSaveEvent: TButton
            Left = 32
            Top = 80
            Width = 75
            Height = 25
            Caption = 'Speichern'
            TabOrder = 4
            OnClick = ButtonSaveEventClick
          end
        end
        object PanelEventDetails: TPanel
          AlignWithMargins = True
          Left = 0
          Top = 126
          Width = 1467
          Height = 339
          Margins.Left = 0
          Margins.Top = 5
          Margins.Right = 0
          Margins.Bottom = 0
          Align = alTop
          BevelKind = bkFlat
          BevelOuter = bvNone
          TabOrder = 1
          object Label4: TLabel
            Left = 28
            Top = 8
            Width = 53
            Height = 20
            Caption = 'Rennen'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object PanelEventRaces: TPanel
            AlignWithMargins = True
            Left = 0
            Top = 39
            Width = 1463
            Height = 296
            Margins.Left = 0
            Margins.Top = 5
            Margins.Right = 0
            Margins.Bottom = 0
            Align = alBottom
            BevelKind = bkFlat
            BevelOuter = bvNone
            TabOrder = 0
            object DBNavigatorRaces: TDBNavigator
              AlignWithMargins = True
              Left = 3
              Top = 3
              Width = 30
              Height = 109
              Margins.Bottom = 180
              DataSource = DataSourceRaces
              VisibleButtons = [nbInsert, nbDelete, nbEdit, nbRefresh]
              Align = alLeft
              Flat = True
              Ctl3D = False
              Kind = dbnVertical
              ParentCtl3D = False
              TabOrder = 0
              BeforeAction = DBNavigatorRacesBeforeAction
            end
            object DBGridRaces: TDBGrid
              Left = 36
              Top = 0
              Width = 1423
              Height = 292
              Align = alClient
              DataSource = DataSourceRaces
              DrawingStyle = gdsGradient
              FixedColor = clBtnShadow
              GradientEndColor = cl3DLight
              GradientStartColor = cl3DLight
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -12
              Font.Name = 'Segoe UI'
              Font.Style = []
              Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
              ParentFont = False
              TabOrder = 1
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -12
              TitleFont.Name = 'Segoe UI'
              TitleFont.Style = [fsBold]
              OnDrawColumnCell = DBGridDrawCheckBox
            end
          end
        end
      end
      object TabSheetCompetitors: TTabSheet
        Caption = 'Teilnehmer'
        ImageIndex = 3
        PopupMenu = PopupMenuCompetitorActions
        object PanelCompetitorFilters: TPanel
          Left = 0
          Top = 0
          Width = 1467
          Height = 41
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          object Label5: TLabel
            Left = 42
            Top = 15
            Width = 32
            Height = 15
            Caption = 'Klasse'
          end
          object ComboBoxClassFilter: TComboBox
            Left = 80
            Top = 12
            Width = 181
            Height = 23
            Style = csDropDownList
            TabOrder = 0
            OnSelect = ComboBoxClassFilterSelect
          end
          object BitBtnClearClassFilter: TBitBtn
            Left = 268
            Top = 12
            Width = 23
            Height = 23
            ImageIndex = 0
            Images = ImageListButtons
            TabOrder = 1
            OnClick = BitBtnClearClassFilterClick
          end
        end
        object DBGridCompetitors: TDBGrid
          Left = 36
          Top = 41
          Width = 1431
          Height = 703
          Align = alClient
          DataSource = DataSourceCompetitors
          DrawingStyle = gdsGradient
          FixedColor = clBtnShadow
          GradientEndColor = cl3DLight
          GradientStartColor = cl3DLight
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect, dgTitleClick, dgTitleHotTrack]
          ParentFont = False
          TabOrder = 1
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = [fsBold]
          OnKeyUp = DBGridCompetitorsKeyUp
        end
        object DBNavigatorCompetitors: TDBNavigator
          AlignWithMargins = True
          Left = 3
          Top = 44
          Width = 30
          Height = 100
          Margins.Bottom = 600
          DataSource = DataSourceCompetitors
          VisibleButtons = [nbInsert, nbDelete, nbEdit, nbRefresh]
          Align = alLeft
          Flat = True
          Ctl3D = False
          Kind = dbnVertical
          ParentCtl3D = False
          TabOrder = 2
          BeforeAction = DBNavigatorCompetitorsBeforeAction
        end
      end
      object TabSheetTiming: TTabSheet
        Caption = 'Zeitmessung'
        ImageIndex = 1
        object Splitter1: TSplitter
          Left = 185
          Top = 0
          Height = 744
          Color = clBlack
          ParentColor = False
          ExplicitLeft = 272
          ExplicitTop = 408
          ExplicitHeight = 100
        end
        object Splitter2: TSplitter
          Left = 954
          Top = 0
          Height = 744
          Align = alRight
          Color = clBlack
          ParentColor = False
          ExplicitLeft = 865
        end
        object PanelRaces: TPanel
          Left = 0
          Top = 0
          Width = 185
          Height = 744
          Align = alLeft
          BevelOuter = bvNone
          TabOrder = 0
          object ListBoxRaces: TListBox
            Left = 0
            Top = 0
            Width = 185
            Height = 744
            Style = lbOwnerDrawFixed
            AutoComplete = False
            Align = alClient
            Columns = 1
            ExtendedSelect = False
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Segoe UI'
            Font.Style = []
            IntegralHeight = True
            ItemHeight = 20
            ParentFont = False
            TabOrder = 0
            OnClick = ListBoxRacesClick
            OnDrawItem = ListBoxRacesDrawItem
          end
        end
        object PanelPassings: TPanel
          Left = 188
          Top = 0
          Width = 766
          Height = 744
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          object PanelRaceControls: TPanel
            Left = 0
            Top = 0
            Width = 766
            Height = 41
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 0
            object ButtonNeutralize: TBitBtn
              Left = 88
              Top = 4
              Width = 33
              Height = 33
              Hint = 'Neutralisieren'
              ImageIndex = 2
              Images = ImageListButtons32
              TabOrder = 0
              OnClick = ButtonNeutralizeClick
            end
            object ButtonWarmUp: TBitBtn
              Left = 16
              Top = 4
              Width = 33
              Height = 33
              Hint = 'Aufw'#228'rmphase'
              HotImageIndex = 0
              ImageIndex = 0
              Images = ImageListButtons32
              Spacing = 0
              TabOrder = 1
              OnClick = ButtonWarmUpClick
            end
            object ButtonStart: TBitBtn
              Left = 52
              Top = 4
              Width = 33
              Height = 33
              Hint = 'Start'
              ImageIndex = 1
              Images = ImageListButtons32
              TabOrder = 2
              OnClick = ButtonStartClick
            end
            object ButtonFinish: TBitBtn
              Left = 124
              Top = 4
              Width = 33
              Height = 33
              Hint = 'Finish'
              ImageIndex = 3
              Images = ImageListButtons32
              TabOrder = 3
              OnClick = ButtonFinishClick
            end
          end
          object PanelPassingGrid: TPanel
            Left = 0
            Top = 41
            Width = 766
            Height = 703
            Align = alClient
            BevelOuter = bvNone
            TabOrder = 1
          end
        end
        object PanelStandings: TPanel
          Left = 957
          Top = 0
          Width = 510
          Height = 744
          Align = alRight
          TabOrder = 2
          object DBGridRankings: TDBGrid
            Left = 1
            Top = 1
            Width = 508
            Height = 742
            Align = alClient
            DataSource = DataSourceRankings
            TabOrder = 0
            TitleFont.Charset = DEFAULT_CHARSET
            TitleFont.Color = clWindowText
            TitleFont.Height = -12
            TitleFont.Name = 'Segoe UI'
            TitleFont.Style = []
            OnDrawColumnCell = DBGridDrawCheckBox
          end
        end
      end
      object TabSheetResults: TTabSheet
        Caption = 'Ergebnisse'
        ImageIndex = 2
      end
    end
  end
  object PanelStatus: TPanel
    AlignWithMargins = True
    Left = 0
    Top = 855
    Width = 1475
    Height = 49
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alBottom
    BevelKind = bkFlat
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 2
    object PanelDecoder: TPanel
      Left = 0
      Top = 0
      Width = 401
      Height = 45
      Align = alLeft
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 0
      object LabelDecoderIpAddress: TLabel
        Left = 8
        Top = 23
        Width = 56
        Height = 15
        Caption = 'IP-Adresse'
      end
      object LabelDecoderId: TLabel
        Left = 8
        Top = 2
        Width = 134
        Height = 15
        Caption = 'Decoder nicht verbunden'
      end
      object LabelDecoderTemperature: TLabel
        Left = 248
        Top = 2
        Width = 60
        Height = 15
        Caption = 'Temperatur'
      end
      object LabelDecoderNoiseLevel: TLabel
        Left = 248
        Top = 23
        Width = 71
        Height = 15
        Caption = 'St'#246'rungslevel'
      end
    end
  end
  object MainMenu: TMainMenu
    Left = 704
    Top = 19
    object MenuItemFile: TMenuItem
      Caption = 'Datei'
      object MenuItemLoadEvent: TMenuItem
        Caption = 'Veranstaltung laden ...'
        OnClick = MenuItemLoadEventClick
      end
    end
    object MenuItemCompetitors: TMenuItem
      Caption = 'Teilnehmer'
      object MenuItemImportCompetitors: TMenuItem
        Caption = 'Teilnehmerdaten importieren'
        OnClick = MenuItemImportCompetitorsClick
      end
      object Startzeiteneinlesen1: TMenuItem
        Caption = 'Startzeiten einlesen'
      end
    end
    object MenuItemTools: TMenuItem
      Caption = 'Tools'
      object MenuItemTxMapping: TMenuItem
        Caption = #220'bersetzungstabelle ...'
        object MenuItemTxMappingImport: TMenuItem
          Caption = 'Importieren'
          OnClick = MenuItemTxMappingImportClick
        end
        object MenuItemTxMappingExport: TMenuItem
          Caption = 'Exportieren'
          OnClick = MenuItemTxMappingExportClick
        end
        object MenuItemTxMappingGenerate: TMenuItem
          Caption = 'Generieren'
          OnClick = MenuItemTxMappingGenerateClick
        end
        object MenuItemTxMappingEdit: TMenuItem
          Caption = 'Editieren'
          Enabled = False
        end
      end
      object MenuItemCheckBatteryStatus: TMenuItem
        Caption = 'Batteriestatus pr'#252'fen'
        OnClick = MenuItemCheckBatteryStatusClick
      end
      object MenuItemSimulatePassings: TMenuItem
        Caption = 'Simulator'
        OnClick = MenuItemSimulatePassingsClick
      end
      object MenuItemSettings: TMenuItem
        Caption = 'Einstellungen'
        OnClick = MenuItemSettingsClick
      end
    end
  end
  object SQLDataSetRaces: TSQLDataSet
    CommandText = 'SELECT * FROM RACES'
    DataSource = DataSourceRaces
    MaxBlobSize = -1
    Params = <>
    SQLConnection = MainDataModule.SQLConnection
    Left = 72
    Top = 316
  end
  object DataSourceRaces: TDataSource
    DataSet = ClientDataSetRaces
    Left = 75
    Top = 504
  end
  object DataSetProviderRaces: TDataSetProvider
    DataSet = SQLDataSetRaces
    Options = [poAutoRefresh, poUseQuoteChar]
    Left = 73
    Top = 378
  end
  object ClientDataSetRaces: TClientDataSet
    Aggregates = <>
    DisableStringTrim = True
    Params = <>
    ProviderName = 'DataSetProviderRaces'
    BeforeRefresh = ClientDataSetRacesBeforeRefresh
    Left = 70
    Top = 442
  end
  object SQLDataSetCompetitors: TSQLDataSet
    CommandText = 'SELECT * FROM COMPETITORS'
    DataSource = DataSourceCompetitors
    MaxBlobSize = -1
    Params = <>
    SQLConnection = MainDataModule.SQLConnection
    Left = 291
    Top = 352
  end
  object DataSetProviderCompetitors: TDataSetProvider
    DataSet = SQLDataSetCompetitors
    Options = [poAutoRefresh, poUseQuoteChar]
    Left = 280
    Top = 411
  end
  object ClientDataSetCompetitors: TClientDataSet
    Aggregates = <>
    DisableStringTrim = True
    Params = <>
    ProviderName = 'DataSetProviderCompetitors'
    BeforeRefresh = ClientDataSetRacesBeforeRefresh
    Left = 280
    Top = 485
  end
  object DataSourceCompetitors: TDataSource
    DataSet = ClientDataSetCompetitors
    Left = 272
    Top = 550
  end
  object ImageListButtons: TImageList
    Left = 384
    Bitmap = {
      494C010101000800040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000006D6D
      98006D6D98000000000000000000000000000000000000000000000000006D6D
      98006D6D98000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000006D6D98000B0B
      86000A0A85006D6D9800000000000000000000000000000000006D6D98000101
      8200000082006D6D980000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000006D6D98000D0D
      86001717B5000A0A85006D6D980000000000000000006D6D9800040483000505
      AF00020283006D6D980000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000006D6D
      98000D0D86001717B5000B0B85006D6D98006D6D9800070784000B0BB1000505
      83006D6D98000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00006D6D98000E0E86001818B5000B0B85000A0A85001111B300070784006D6D
      9800000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000006D6D98000E0E86001919B5001616B5000A0A85006D6D98000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000006D6D98000F0F87001C1CB6001919B6000C0C86006D6D98000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00006D6D98000909C5001010DD00101089000E0E87001A1AB6000C0C86006D6D
      9800000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000006D6D
      98000A0AC6000000FF000909C4006D6D98006D6D98000F0F89001717C1000B0B
      8C006D6D98000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000006D6D98000C0C
      C5000000FF000A0AC4006D6D980000000000000000006D6D98000707C3000000
      FF000606C3006D6D980000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000006D6D98000C0C
      C5000C0CC5006D6D9800000000000000000000000000000000006D6D98000707
      C3000707C3006D6D980000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000006D6D
      98006D6D98000000000000000000000000000000000000000000000000006D6D
      98006D6D98000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFFF000000000000FFFF000000000000
      E7E7000000000000C3C3000000000000C183000000000000E007000000000000
      F00F000000000000F81F000000000000F81F000000000000F00F000000000000
      E007000000000000C183000000000000C3C3000000000000E7E7000000000000
      FFFF000000000000FFFF00000000000000000000000000000000000000000000
      000000000000}
  end
  object PopupMenuCompetitorActions: TPopupMenu
    Left = 698
    Top = 93
    object PopupMenuCompetitorAssignToRace: TMenuItem
      Caption = 'Zu Rennen zuweisen'
    end
    object PopupMenuCompetitorDelete: TMenuItem
      Caption = 'L'#246'schen'
      OnClick = PopupMenuCompetitorDeleteClick
    end
  end
  object SQLDataSetRankings: TSQLDataSet
    CommandText = 'SELECT * FROM COMPETITORS'
    DataSource = DataSourceRankings
    MaxBlobSize = -1
    Params = <>
    SQLConnection = MainDataModule.SQLConnection
    Left = 625
    Top = 328
  end
  object DataSetProviderRankings: TDataSetProvider
    DataSet = SQLDataSetRankings
    Options = [poAutoRefresh, poUseQuoteChar]
    Left = 608
    Top = 421
  end
  object ClientDataSetRankings: TClientDataSet
    Aggregates = <>
    DisableStringTrim = True
    Params = <>
    ProviderName = 'DataSetProviderRankings'
    BeforeRefresh = ClientDataSetRacesBeforeRefresh
    Left = 608
    Top = 536
  end
  object DataSourceRankings: TDataSource
    DataSet = ClientDataSetRankings
    Left = 595
    Top = 638
  end
  object ImageListButtons32: TImageList
    Height = 32
    Width = 32
    Left = 626
    Top = 65534
    Bitmap = {
      494C010104000800040020002000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000800000004000000001002000000000000080
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC8FE000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00F1F1F100CBCBCB00BABABA006E6E6E007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF007E7E7E0077777700656565005858
      5800B1B1B100B1B1B100B1B1B100B1B1B1005858580058585800585858005858
      5800B3B3B300D2D2D200FFFFFF00FFFFFF00C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F00696969002A2A2A000E0E0E008F8F8F00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00FDFDFD00CECECE00525252000202
      0200040404000707070007070700070707000F0F0F000F0F0F000F0F0F000F0F
      0F000A0A0A003A3A3A007F7F7F007F7F7F00C276C200C276C200C276C200C276
      C200C276C200C276C200C175C100BC72BC00B26CB200BB72BB00C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C075C000B870B800B36DB300C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122003B8A1B00060D02002B6513004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB12200306F15000F230700060D
      0200060D02000F23070023500F00439B1E004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000DB5E600087696000BA3CF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000B98C1000982A5000876
      9600087696000982A5000B9EC8000EC3F7000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F00696969002A2A2A000E0E0E008F8F8F00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00FEFEFE00D2D2D200595959000D0D
      0D001F1F1F003737370037373700373737006F6F6F006F6F6F006F6F6F006F6F
      6F0039393900555555007F7F7F007F7F7F00C276C200C276C200C276C200C276
      C200C276C200C276C200BA71BA007A4A7A00120B120077497700C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200B36DB3005634560021142100C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122003A871A0000000000295F12004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122001B400C001E450D002658
      11002658110023500F00071103000A1604003F931C004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000B9AC30000000000076C89000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF0005415300043D4D00032C
      3800032C380004384700043E4F00087392000DBAEC000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F00696969002A2A2A000E0E0E008F8F8F00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00FEFEFE00E0E0E000727272001E1E
      1E0040404000797979007F7F7F007F7F7F00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00C276C200C276C200C276C200C276
      C200C276C200C276C200BA71BA007A4A7A00120B120077497700C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200B36DB3005634560021142100C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122003A871A0000000000295F12004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB1220048A9200049A9200049AB
      210049AB210049AA21003A871A00050C020018380B004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000B9AC30000000000076C89000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF00076A87000A92B9000A92
      B9000A92B9000A8CB100054B5F00010D1100087898000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F00696969002A2A2A000E0E0E008F8F8F00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00FFFFFF00F5F5F500A7A7A7003333
      330029292900636363007B7B7B007E7E7E00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00C276C200C276C200C276C200C276
      C200C276C200C276C200BA71BA007A4A7A00120B120077497700C276C200C276
      C200C276C200C276C200C276C200BF74BF00BA71BA00BA71BA00BA71BA00BA71
      BA00BA71BA00AB68AB005332530020132000BA71BA00BB72BB00C276C200C276
      C200C276C200C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122003A871A0000000000295F12004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004BAF2200224F0F0001030100439B1E004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000B9AC30000000000076C89000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000CB3E300032A350002212A000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00D2D2D200545454001D1D1D00474747007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF007F7F7F007E7E7E006F6F6F003E3E
      3E00333333006C6C6C00C5C5C500EEEEEE007E7E7E007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C276C200C276C200C276C200C276
      C200C276C200C276C200BA71BA007A4A7A00120B120077497700C276C200C276
      C200C276C200C276C200BD73BD009A5E9A005F3A5F005F3A5F005F3A5F005F3A
      5F005F3A5F005735570029192900100A10005F3A5F0070447000C276C200C276
      C200C276C200C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122003A871A0000000000295F12004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004BB022004CB122004CB1
      22004CB122004CB122004CB12200295E1200000000003B891A004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000B9AC30000000000076C89000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF0006536900000000000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00D2D2D200545454001D1D1D00474747007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF007F7F7F007F7F7F007C7C7C006666
      66006F6F6F003F3F3F0060606000A9A9A900707070007C7C7C007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C276C200C276C200C276C200C276
      C200C276C200C276C200BA71BA007A4A7A00120B120077497700C276C200C276
      C200C276C200C276C200BB72BB00804E800006040600040204000E090E00110B
      1100110B1100100A10000805080003020300110B1100301D3000C276C200C276
      C200C276C200C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122003A871A0000000000295F12004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004BB022004BB0
      22004CB122004CB122004CB12200295F1200000000003E901C004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000B9AC30000000000076C89000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000DBAEC000436450002171D000EC9FF000EC9FF000EC9
      FF000EC9FF000EC8FE000EC9FF000EC9FF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00D2D2D200545454001A1A1A004040400072727200727272007272
      7200E5E5E500E5E5E500EBEBEB00F8F8F8007F7F7F007F7F7F007F7F7F007C7C
      7C00D7D7D70089898900454545004747470045454500686868007A7A7A007E7E
      7E00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C276C200C276C200C276C200C276
      C200C276C200C276C200BA71BA007A4A7A00110B110073467300BA71BA00BA71
      BA00BA71BA00BA71BA00BF74BF00B06BB0004E2F4E00271827009A5E9A00C175
      C100C276C200B36DB3005634560021142100C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122003A871A000000000017350A002B6513002B65
      13002B6513002B6513003B8A1B004CB122004CB122004CB122004CB122004CB0
      22004CB122004CB12200439B1E00081203000A1604004BAF22004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000B9AC3000000000006576E000BA3CF000BA3
      CF000BA3CF000BA3CF000DB5E6000EC9FF000EC9FF000EC9FF000DBAEC000DB5
      E6000BA3CF000B98C1000766820002181F00086B88000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00D2D2D200545454000E0E0E00212121003B3B3B003B3B3B003B3B
      3B00767676007777770094949400D9D9D9007F7F7F007F7F7F007F7F7F007F7F
      7F00FEFEFE00E7E7E700A5A5A500575757001C1C1C00383838005F5F5F007777
      7700FFFFFF00FFFFFF00FFFFFF00FFFFFF00C276C200C276C200C276C200C276
      C200C276C200C276C200BA71BA007A4A7A0008050800392339005F3A5F005F3A
      5F005F3A5F00673F6700995D9900C276C200AC69AC003B243B00341F3400AD69
      AD00C276C200B36DB3005634560021142100C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122003A871A000000000001030100030701000307
      010003070100030701002A6213004CB122004CB12200439B1E002B6513002B65
      13002B651300275C12000A16040000010000337617004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000B9AC3000000000002212A00044051000440
      510004405100044051000987AB000EC9FF000EC9FF000EC9FF0008789800065B
      73000440510003313E00032A3500076A87000DBFF3000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F00696969002A2A2A0002020200111111001E1E1E001E1E1E001E1E
      1E000F0F0F00101010002828280060606000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007A7A7A00626262006D6D6D003434340058585800B4B4
      B4007B7B7B007F7F7F007F7F7F007F7F7F00C276C200C276C200C276C200C276
      C200C276C200C276C200BA71BA007A4A7A00010101000B060B00110B1100110B
      1100110B1100201420007E4D7E00C276C200C075C0009E609E00342034005332
      5300BC72BC00B36DB3005634560021142100C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122003A871A00000000002658110046A41F0046A4
      1F0046A41F0046A41F0049AB21004CB122004CB122003B891A00030701000307
      0100030701000711030018390B00367E18004AAE21004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000B9AC30000000000032C3800065369000653
      690006536900065369000A92B9000EC9FF000EC9FF000EC9FF00087392000653
      6900054C6100043A4A00043C4C000B98C1000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F00696969002A2A2A00080808005252520093939300939393009393
      930049494900494949005555550070707000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007C7C7C00D1D1D1006D6D6D00262626005B5B
      5B00676767007F7F7F007F7F7F007F7F7F00C276C200C276C200C276C200C276
      C200C276C200C276C200BA71BA007A4A7A00120B120077497700C276C200C276
      C200BE74BE00C276C200C276C200C276C200C276C200BD73BD008A548A002517
      250078497800B06BB0005634560021142100C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122003A871A0000000000295F12004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122003A871A0000000000367E
      180046A41F0047A4200048A920004BAE21004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000B9AC30000000000076C89000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000DC0F4000CA6D3000650650003313E000CADDB000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F00696969002A2A2A000E0E0E008F8F8F00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00F9F9F900C4C4C4004E4E4E001F1F
      1F00464646007C7C7C007F7F7F007F7F7F00C276C200C276C200C276C200C276
      C200C276C200C276C200BA71BA007A4A7A00120B120077497700C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200B770B7006F44
      6F001E121E008D568D005634560021142100C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122003A871A0000000000295F12004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122003E901C00000000003275
      16004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000B9AC30000000000076C89000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000CADDC0000000000087A9B000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F00696969002A2A2A000E0E0E008F8F8F00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00FFFFFF00EFEFEF00888888000E0E
      0E0030303000747474007F7F7F007F7F7F00C276C200C276C200C276C200C276
      C200C276C200C276C200BA71BA007A4A7A00120B120077497700C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200AD69
      AD00482C48003B243B005131510021142100C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122003A871A0000000000295F12004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004BAF2200000000002960
      12004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000B9AC30000000000076C89000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000CB1E10000000000076C89000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00D2D2D200545454001D1D1D00474747007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF007F7F7F007C7C7C00525252000D0D
      0D0053535300DCDCDC00FFFFFF00FFFFFF00C276C200C276C200C276C200C276
      C200C276C200C276C200BA71BA007A4A7A00110B110073467300BA71BA00BA71
      BA00BA71BA00BA71BA00BB72BB00C276C200C276C200C276C200C276C200C075
      C0009A5D9A00170E1700140C140021142100C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122003A871A000000000017350A002B6513002B65
      13002B6513002B6513002B6513004CB122004CB122004CB12200000000001735
      0A002B6513002B6513002B6513002B6513003B8A1B004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000B9AC3000000000006576E000BA3CF000BA3
      CF000BA3CF000BA3CF000BA3CF000EC9FF000EC9FF000CA8D5000B98C1000CA8
      D5000CB1E1000B9EC800065A7200000507000987AB000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00D2D2D200545454001D1D1D00474747007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF007F7F7F007F7F7F007C7C7C007A7A
      7A00FDFDFD00FFFFFF00FFFFFF00FFFFFF007F7F7F007B7B7B00505050000E0E
      0E0054545400DDDDDD00FFFFFF00FFFFFF00C276C200C276C200C276C200C276
      C200C276C200C276C200BA71BA007A4A7A0008050800392339005F3A5F005F3A
      5F005F3A5F005F3A5F0070447000C276C200C276C200C276C200C276C200C276
      C200B66FB600663E66000201020021142100C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122003A871A000000000001030100030701000307
      01000307010003070100030701004CB122004CB122004CB12200000000000103
      0100030701000307010003070100030701002A6213004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000B9AC3000000000002212A00044051000440
      51000440510004405100044051000EC9FF000EC9FF000986AA00054D6200054C
      600006546B00043E4F0002242E00054B5F000DB9EB000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00D2D2D200545454001D1D1D00474747007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF007F7F7F007E7E7E00707070006060
      6000DFDFDF00F7F7F700FFFFFF00FFFFFF007C7C7C006F6F6F003C3C3C000808
      080060606000E6E6E600FFFFFF00FFFFFF00C276C200C276C200C276C200C276
      C200C276C200C276C200BB72BB00814F8100110B1100110B1100110B1100110B
      1100110B1100110B1100301D3000C276C200C276C200C276C200C276C200C276
      C200C276C200A866A80025172500301D3000C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004BAE210046A41F0046A41F0046A41F0046A4
      1F0046A41F0046A41F0046A41F004CB122004CB122004CB1220046A41F0046A4
      1F0046A41F0046A41F0046A41F0046A41F0049AB21004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000CADDC000653690006536900065369000653
      69000653690006536900065369000EC9FF000EC9FF000CADDC00097B9C00065B
      730006536900065B7300097B9C000CB3E3000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00D2D2D20054545400181818003B3B3B0069696900696969006969
      6900D3D3D300D3D3D300D4D4D400E5E5E5007F7F7F007E7E7E00626262003535
      35007C7C7C00B9B9B900D8D8D800DCDCDC0064646400474747001D1D1D001313
      13008F8F8F00F6F6F600FFFFFF00FFFFFF00C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200BD73BD00C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F00696969002A2A2A00040404002C2C2C004E4E4E004E4E4E004E4E
      4E002727270027272700282828004A4A4A00FFFFFF00FDFDFD00CECECE006565
      65001B1B1B00262626003030300035353500545454003A3A3A00343434007171
      71006A6A6A007F7F7F007F7F7F007F7F7F00C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200BC73BC00C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007070700044444400272727004E4E4E004E4E4E004E4E4E004E4E
      4E002727270027272700282828004A4A4A00FFFFFF00FFFFFF00F0F0F000C3C3
      C30047474700363636002F2F2F002F2F2F005D5D5D00727272009C9C9C00D2D2
      D2007C7C7C007F7F7F007F7F7F007F7F7F00C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200BE74
      BE00BD73BD00C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF007F7F7F007F7F7F007F7F7F007F7F7F00C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C200C276C200C276C200C276C200C276
      C200C276C200C276C200C276C200C276C2004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122004CB122004CB122004CB122004CB1
      22004CB122004CB122004CB122004CB122000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9FF000EC9
      FF000EC9FF000EC9FF000EC9FF000EC9FF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF007F7F7F007F7F7F007F7F7F007F7F
      7F00FFFFFF00FFFFFF00FFFFFF00FFFFFF00424D3E000000000000003E000000
      2800000080000000400000000100010000000000000400000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000}
  end
  object FileOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = []
    Left = 792
    Top = 16
  end
end
