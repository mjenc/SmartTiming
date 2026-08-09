object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'SmartTiming'
  ClientHeight = 936
  ClientWidth = 1483
  Color = clBackground
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu
  Position = poScreenCenter
  WindowState = wsMaximized
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 15
  object PanelTitle: TPanel
    AlignWithMargins = True
    Left = 0
    Top = 0
    Width = 1483
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
    OnClick = PanelTitleClick
    DesignSize = (
      1479
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
      Left = 1392
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
    Width = 1483
    Height = 828
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 1
    object PageControlMain: TPageControl
      AlignWithMargins = True
      Left = 0
      Top = 6
      Width = 1483
      Height = 816
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
          Width = 1475
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
          object EditDateTo: TMaskEdit
            Left = 814
            Top = 13
            Width = 72
            Height = 23
            Alignment = taCenter
            EditMask = '!99/99/0000;1;_'
            MaxLength = 10
            TabOrder = 2
            Text = '  .  .    '
          end
          object EditDateFrom: TMaskEdit
            Left = 572
            Top = 13
            Width = 72
            Height = 23
            Alignment = taCenter
            EditMask = '!99/99/0000;1;_'
            MaxLength = 10
            TabOrder = 1
            Text = '  .  .    '
          end
        end
        object PanelEventDetails: TPanel
          AlignWithMargins = True
          Left = 0
          Top = 126
          Width = 1475
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
            Width = 1471
            Height = 296
            Margins.Left = 0
            Margins.Top = 5
            Margins.Right = 0
            Margins.Bottom = 0
            Align = alBottom
            BevelKind = bkFlat
            BevelOuter = bvNone
            TabOrder = 0
            object DBGridRaces: TDBGrid
              Left = 30
              Top = 0
              Width = 1437
              Height = 292
              Align = alClient
              DataSource = MainDataModule.DataSourceRaces
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
              TabOrder = 0
              TitleFont.Charset = DEFAULT_CHARSET
              TitleFont.Color = clWindowText
              TitleFont.Height = -12
              TitleFont.Name = 'Segoe UI'
              TitleFont.Style = [fsBold]
              OnDrawDataCell = DBGridRacesDrawDataCell
            end
            object PanelRacesGridButtons: TPanel
              Left = 0
              Top = 0
              Width = 30
              Height = 292
              Align = alLeft
              BevelOuter = bvNone
              TabOrder = 1
              object DBNavigatorRaces: TDBNavigator
                Left = 0
                Top = 0
                Width = 30
                Height = 100
                Margins.Left = 0
                Margins.Top = 0
                Margins.Right = 0
                Margins.Bottom = 0
                DataSource = MainDataModule.DataSourceRaces
                VisibleButtons = [nbInsert, nbDelete, nbEdit, nbRefresh]
                Align = alTop
                Flat = True
                Ctl3D = False
                Kind = dbnVertical
                ParentCtl3D = False
                TabOrder = 0
                BeforeAction = DBNavigatorRacesBeforeAction
              end
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
          Width = 1475
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
          object ButtonImportCompetitors: TButton
            Left = 312
            Top = 10
            Width = 113
            Height = 25
            Caption = 'Importieren ...'
            TabOrder = 2
            OnClick = MenuItemImportCompetitorsClick
          end
        end
        object DBGridCompetitors: TDBGrid
          Left = 30
          Top = 41
          Width = 1445
          Height = 735
          Align = alClient
          DataSource = DataSourceCompetitors
          FixedColor = clBtnShadow
          GradientEndColor = cl3DLight
          GradientStartColor = cl3DLight
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          Options = [dgTitles, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgMultiSelect, dgTitleClick, dgTitleHotTrack]
          ParentFont = False
          PopupMenu = PopupMenuCompetitorActions
          TabOrder = 1
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = [fsBold]
          OnDblClick = DBGridCompetitorsDblClick
          OnKeyUp = DBGridCompetitorsKeyUp
        end
        object PanelCompetitorsGridButtons: TPanel
          Left = 0
          Top = 41
          Width = 30
          Height = 735
          Align = alLeft
          TabOrder = 2
          OnClick = PanelCompetitorsGridButtonsClick
          object DBNavigatorCompetitors: TDBNavigator
            Left = 1
            Top = 1
            Width = 28
            Height = 100
            Margins.Bottom = 600
            DataSource = DataSourceCompetitors
            VisibleButtons = [nbInsert, nbDelete, nbEdit, nbRefresh]
            Align = alTop
            Flat = True
            Ctl3D = False
            Kind = dbnVertical
            ParentCtl3D = False
            ConfirmDelete = False
            TabOrder = 0
            BeforeAction = DBNavigatorCompetitorsBeforeAction
          end
        end
      end
      object TabSheetTiming: TTabSheet
        Caption = 'Zeitmessung'
        ImageIndex = 1
        object Splitter1: TSplitter
          Left = 185
          Top = 0
          Height = 776
          Color = clBlack
          ParentColor = False
          ExplicitLeft = 272
          ExplicitTop = 408
          ExplicitHeight = 100
        end
        object Splitter2: TSplitter
          Left = 709
          Top = 0
          Height = 776
          Align = alRight
          Color = clBlack
          ParentColor = False
          ExplicitLeft = 865
          ExplicitHeight = 744
        end
        object PanelRaces: TPanel
          Left = 0
          Top = 0
          Width = 185
          Height = 776
          Align = alLeft
          BevelOuter = bvNone
          TabOrder = 0
          object ListBoxRaces: TListBox
            Left = 0
            Top = 0
            Width = 185
            Height = 764
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
            OnClick = ListBoxRacesTimingClick
            OnDrawItem = ListBoxRacesDrawItem
          end
        end
        object PanelPassings: TPanel
          Left = 188
          Top = 0
          Width = 521
          Height = 776
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          object PanelRaceControls: TPanel
            Left = 0
            Top = 0
            Width = 521
            Height = 41
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 0
            DesignSize = (
              521
              41)
            object ButtonNeutralize: TBitBtn
              Left = 104
              Top = 2
              Width = 38
              Height = 38
              Hint = 'Neutralisieren'
              ImageIndex = 2
              Images = ImageListButtons32
              TabOrder = 0
              OnClick = ButtonNeutralizeClick
            end
            object ButtonWarmUp: TBitBtn
              Left = 16
              Top = 3
              Width = 38
              Height = 38
              Hint = 'Aufw'#228'rmphase'
              HotImageIndex = 0
              ImageIndex = 0
              Images = ImageListButtons32
              Spacing = 0
              TabOrder = 1
              OnClick = ButtonWarmUpClick
            end
            object ButtonStart: TBitBtn
              Left = 60
              Top = 3
              Width = 38
              Height = 38
              Hint = 'Start'
              ImageIndex = 1
              Images = ImageListButtons32
              TabOrder = 2
              OnClick = ButtonStartClick
            end
            object ButtonAbort: TBitBtn
              Left = 148
              Top = 2
              Width = 38
              Height = 38
              Hint = 'Finish'
              ImageIndex = 3
              Images = ImageListButtons32
              TabOrder = 3
              OnClick = ButtonAbortClick
            end
            object ButtonFinish: TBitBtn
              Left = 192
              Top = 3
              Width = 38
              Height = 38
              Hint = 'Finish'
              ImageIndex = 4
              Images = ImageListButtons32
              TabOrder = 4
              OnClick = ButtonFinishClick
            end
            object ButtonStop: TBitBtn
              Left = 236
              Top = 3
              Width = 38
              Height = 38
              Hint = 'Finish'
              ImageIndex = 5
              Images = ImageListButtons32
              TabOrder = 5
              OnClick = ButtonStopClick
            end
            object CheckBoxAutoScrollPassings: TCheckBox
              Left = 415
              Top = 13
              Width = 88
              Height = 17
              Anchors = [akTop, akRight]
              Caption = 'AutoScroll'
              Checked = True
              State = cbChecked
              TabOrder = 6
              OnClick = ToggleAutoScrollClick
            end
            object ButtonPrintParticipantList: TButton
              Left = 280
              Top = 10
              Width = 121
              Height = 25
              Caption = 'Startliste drucken'
              TabOrder = 7
              OnClick = ButtonPrintParticipantListClick
            end
          end
          object CardPanelPassings: TCardPanel
            Left = 0
            Top = 41
            Width = 521
            Height = 735
            Align = alClient
            BevelOuter = bvNone
            TabOrder = 1
          end
        end
        object PanelStandings: TPanel
          Left = 712
          Top = 0
          Width = 763
          Height = 776
          Align = alRight
          Anchors = [akLeft, akTop, akRight, akBottom]
          TabOrder = 2
          object PanelStandingsControls: TPanel
            Left = 1
            Top = 1
            Width = 761
            Height = 41
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 0
            object CheckBoxRankingGroupedByClass: TCheckBox
              Left = 16
              Top = 12
              Width = 145
              Height = 17
              Caption = 'Nach Klasse gruppiert'
              TabOrder = 0
              OnClick = CheckBoxRankingGroupedByClassClick
            end
          end
        end
      end
      object TabSheetResults: TTabSheet
        Caption = 'Ergebnisse'
        ImageIndex = 2
        object PanelResultRaces: TPanel
          Left = 0
          Top = 0
          Width = 185
          Height = 776
          Align = alLeft
          BevelEdges = []
          BevelOuter = bvNone
          TabOrder = 0
        end
        object PanelResults: TPanel
          Left = 185
          Top = 0
          Width = 1290
          Height = 776
          Align = alClient
          BevelEdges = []
          BevelOuter = bvNone
          TabOrder = 1
          object PanelResultControls: TPanel
            Left = 0
            Top = 0
            Width = 1290
            Height = 41
            Align = alTop
            BevelEdges = []
            BevelOuter = bvNone
            TabOrder = 0
            object ButtonExportToExelTemplate: TButton
              Left = 137
              Top = 7
              Width = 98
              Height = 25
              Caption = 'Export Excel'
              Enabled = False
              TabOrder = 0
              OnClick = ButtonExportToExelTemplateClick
            end
            object ButtonResultExportCSV: TButton
              Left = 241
              Top = 7
              Width = 113
              Height = 25
              Caption = 'Export CSV'
              Enabled = False
              TabOrder = 1
            end
            object ButtonResultExportHTML: TButton
              Left = 360
              Top = 7
              Width = 105
              Height = 25
              Caption = 'Export HTML'
              Enabled = False
              TabOrder = 2
            end
            object CheckBoxResultsGroupByClass: TCheckBox
              Left = 471
              Top = 11
              Width = 145
              Height = 17
              Caption = 'Nach Klasse gruppiert'
              Enabled = False
              TabOrder = 3
              OnClick = CheckBoxRankingGroupedByClassClick
            end
            object ButtonPrintResults: TButton
              Left = 33
              Top = 7
              Width = 98
              Height = 25
              Caption = 'Drucken'
              Enabled = False
              TabOrder = 4
              OnClick = ButtonPrintResultsClick
            end
          end
          object PanelResultGrid: TPanel
            Left = 0
            Top = 41
            Width = 1290
            Height = 735
            Align = alClient
            BevelEdges = []
            BevelOuter = bvNone
            Caption = 'Bitte Rennen ausw'#228'hlen.'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -17
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            TabOrder = 1
          end
        end
      end
    end
  end
  object PanelStatus: TPanel
    AlignWithMargins = True
    Left = 0
    Top = 887
    Width = 1483
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
    object Splitter4: TSplitter
      Left = 782
      Top = 0
      Height = 45
      ExplicitLeft = 656
      ExplicitTop = 16
      ExplicitHeight = 100
    end
    object PanelDecoder: TPanel
      Left = 0
      Top = 0
      Width = 273
      Height = 45
      Align = alLeft
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 0
      OnDblClick = PanelDecoderDblClick
      object LabelDecoderIpAddress: TLabel
        Left = 8
        Top = 23
        Width = 56
        Height = 15
        Caption = 'IP-Adresse'
      end
      object LabelDecoderManufacturer: TLabel
        Left = 8
        Top = 2
        Width = 134
        Height = 15
        Caption = 'Decoder nicht verbunden'
        OnClick = LabelDecoderManufacturerClick
      end
      object LabelDecoderId: TLabel
        Left = 148
        Top = 2
        Width = 3
        Height = 15
      end
    end
    object PanelNoiseChart: TPanel
      Left = 273
      Top = 0
      Width = 509
      Height = 45
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 1
    end
    object PanelTemperatureChart: TPanel
      Left = 785
      Top = 0
      Width = 694
      Height = 45
      Align = alClient
      TabOrder = 2
    end
  end
  object MainMenu: TMainMenu
    Left = 184
    Top = 3
    object MenuItemFile: TMenuItem
      Caption = 'Datei'
      object MenuItemLoadEvent: TMenuItem
        Caption = 'Veranstaltung laden ...'
        OnClick = MenuItemLoadEventClick
      end
      object MenuItemBackup: TMenuItem
        Caption = 'Backup ...'
        OnClick = MenuItemBackupClick
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
        object MenuItemCreateFakeMappings: TMenuItem
          Caption = 'Pseudoeintr'#228'ge generieren'
          OnClick = MenuItemCreateFakeMappingsClick
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
      object MenuItemUnassignedPassings: TMenuItem
        Caption = 'Nicht zugeordnete Transponder'
        OnClick = MenuItemUnassignedPassingsClick
      end
      object MenuItemSettings: TMenuItem
        Caption = 'Einstellungen'
        OnClick = MenuItemSettingsClick
      end
      object MenuItemReports: TMenuItem
        Caption = 'Druckvorlagen'
        Enabled = False
      end
      object MenuItemRecalc: TMenuItem
        Caption = 'Ergebnis neu berechnen'
        OnClick = MenuItemRecalcClick
      end
      object MenuItemImportTriaTimes: TMenuItem
        Caption = 'TRIA-Zeiten importieren'
        OnClick = MenuItemImportTriaTimesClick
      end
    end
  end
  object SQLDataSetCompetitors: TSQLDataSet
    AfterOpen = ClientDataSetCompetitorsAfterOpen
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
    Options = [poIncFieldProps, poCascadeUpdates, poAutoRefresh, poUseQuoteChar]
    UpdateMode = upWhereKeyOnly
    Left = 280
    Top = 411
  end
  object ClientDataSetCompetitors: TClientDataSet
    Aggregates = <>
    DisableStringTrim = True
    Params = <>
    ProviderName = 'DataSetProviderCompetitors'
    AfterOpen = ClientDataSetCompetitorsAfterOpen
    BeforeRefresh = ClientDataSetRacesBeforeRefresh
    Left = 280
    Top = 485
  end
  object DataSourceCompetitors: TDataSource
    AutoEdit = False
    DataSet = ClientDataSetCompetitors
    Left = 272
    Top = 550
  end
  object ImageListButtons: TImageList
    Left = 384
    Bitmap = {
      494C010102000800040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008F8F8FFF020202FF313131FF3333
      33FF343434FF343434FF343434FF333333FF2F2F2FFF303030FF313131FF3131
      31FF313131FF313131FF313131FF000000FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008B8B8BFF424242FFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFEFEFFFFFFFFFFFBFBFBFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFF303030FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000006D6D
      98006D6D98000000000000000000000000000000000000000000000000006D6D
      98006D6D98000000000000000000000000008A8A8AFF424242FFF8F8F8FF4C4C
      4CFF1F1F1FFF252525FF252525FF1F1F1FFFC3C3C3FF252525FF252525FF2626
      26FF262626FF4A4A4AFFFFFFFFFF303030FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000006D6D98000B0B
      86000A0A85006D6D9800000000000000000000000000000000006D6D98000101
      8200000082006D6D980000000000000000008B8B8BFF404040FFFAFAFAFF8585
      85FF646464FF696969FF696969FF636363FFD9D9D9FF686868FF696969FF6A6A
      6AFF6B6B6BFF808080FFFFFFFFFF2F2F2FFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000006D6D98000D0D
      86001717B5000A0A85006D6D980000000000000000006D6D9800040483000505
      AF00020283006D6D980000000000000000008B8B8BFF434343FFF9F9F9FF6C6C
      6CFF474747FF4B4B4BFF4B4B4BFF464646FFCECECEFF494949FF4B4B4BFF4C4C
      4CFF4C4C4CFF6B6B6BFFFEFEFEFF303030FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000006D6D
      98000D0D86001717B5000B0B85006D6D98006D6D9800070784000B0BB1000505
      83006D6D98000000000000000000000000008B8B8BFF434343FFFDFDFDFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFF2D2D2DFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00006D6D98000E0E86001818B5000B0B85000A0A85001111B300070784006D6D
      9800000000000000000000000000000000008B8B8BFF404040FFFEFEFEFFFFFF
      FFFF757575FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFF7F7F7FFFFFFFFFFFFFFFFFFF2C2C2CFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000006D6D98000E0E86001919B5001616B5000A0A85006D6D98000000
      0000000000000000000000000000000000008A8A8AFF3F3F3FFFF8F8F8FF5B5B
      5BFF121212FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFEFEFFFFFF
      FFFFD5D5D5FF4E4E4EFFFFFFFFFF2D2D2DFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000006D6D98000F0F87001C1CB6001919B6000C0C86006D6D98000000
      0000000000000000000000000000000000008B8B8BFF3F3F3FFFFFFFFFFFFFFF
      FFFF414141FFFFFFFFFFFFFFFFFFFFFFFFFFFEFEFEFFFEFEFEFFFEFEFEFFFCFC
      FCFF5E5E5EFFF5F5F5FFFFFFFFFF2E2E2EFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00006D6D98000909C5001010DD00101089000E0E87001A1AB6000C0C86006D6D
      9800000000000000000000000000000000008C8C8CFF444444FFFAFAFAFFFFFF
      FFFFF6F6F6FFFFFFFFFFFFFFFFFFFFFFFFFFFDFDFDFFFDFDFDFFFDFDFDFFFFFF
      FFFFF0F0F0FFFFFFFFFFFFFFFFFF2D2D2DFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000006D6D
      98000A0AC6000000FF000909C4006D6D98006D6D98000F0F89001717C1000B0B
      8C006D6D9800000000000000000000000000909090FF131313FF5D5D5DFF5959
      59FF5C5C5CFF595959FF5A5A5AFF595959FF595959FF595959FF5A5A5AFF5858
      58FF5F5F5FFF5B5B5BFF5E5E5EFF090909FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000006D6D98000C0C
      C5000000FF000A0AC4006D6D980000000000000000006D6D98000707C3000000
      FF000606C3006D6D980000000000000000008C8C8CFF434343FFFFFFFFFFC7C7
      C7FFC6C6C6FFABABABFFE5E5E5FFEFEFEFFFA2A2A2FFA1A1A1FFA1A1A1FFA1A1
      A1FFA1A1A1FFC6C6C6FFFFFFFFFF323232FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000006D6D98000C0C
      C5000C0CC5006D6D9800000000000000000000000000000000006D6D98000707
      C3000707C3006D6D980000000000000000008B8B8BFF3F3F3FFFFBFBFBFF6A6A
      6AFF626262FF323232FFA8A8A8FFCACACAFF161616FF191919FF1B1B1BFF1B1B
      1BFF1B1B1BFF6A6A6AFFFFFFFFFF2D2D2DFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000006D6D
      98006D6D98000000000000000000000000000000000000000000000000006D6D
      98006D6D98000000000000000000000000008B8B8BFF3F3F3FFFFBFBFBFFFBFB
      FBFFF9F9F9FFF8F8F8FFFBFBFBFFFDFDFDFFFBFBFBFFF9F9F9FFFCFCFCFFFBFB
      FBFFFCFCFCFFFBFBFBFFFFFFFFFF2C2C2CFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000919191FF0C0C0CFF414141FF3E3E
      3EFF3F3F3FFF3F3F3FFF3D3D3DFF404040FF414141FF3F3F3FFF3E3E3EFF3E3E
      3EFF3E3E3EFF3D3D3DFF404040FF010101FF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000E9E9E9FF969696FF909090FF9090
      90FF909090FF909090FF909090FF909090FF909090FF909090FF909090FF9090
      90FF909090FF909090FF929292FF979797FF0000000000000000000000000000
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
    OnPopup = PopupMenuCompetitorActionsPopup
    Left = 602
    Top = 173
    object PopupMenuCompetitorAssignToRace: TMenuItem
      Caption = 'Zu Rennen zuweisen'
      OnClick = PopupMenuCompetitorAssignToRaceClick
    end
    object PopupMenuCompetitorRemoveFromRace: TMenuItem
      Caption = 'Aus Rennen entfernen'
    end
    object PopupMenuCompetitorDelete: TMenuItem
      Caption = 'L'#246'schen'
      Enabled = False
      OnClick = PopupMenuCompetitorDeleteClick
    end
  end
  object ImageListButtons32: TImageList
    Height = 32
    Width = 32
    Left = 626
    Top = 65534
    Bitmap = {
      494C010106000800040020002000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000800000004000000001002000000000000080
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000D0D0D0007F7F
      7F00E2E2E2000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000F6F6F600000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FDFDFD00565656000000
      0000B1B1B1000000000000000000000000000000000000000000BBBBBB000000
      0000000000000000000000000000DEDEDE00565656000000000058585800E0E0
      E000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000DEDEE2004848AE002C2C
      AC002C2CAB002C2CAB002C2CAB002C2CAB002C2CAB002C2CAB002C2CAB002C2C
      AB002C2CAB002C2CAB005959B000ECECED000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000DCDCDC00000000000000
      0000DEDEDE000000000000000000000000000000000000000000BBBBBB000000
      00000000000000000000FCFCFC0055555500000000006E6E6E00000000005858
      5800FCFCFC000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000DCDCE1004343AF002929C1002828
      C7002828C7002828C7002828C7002828C7002828C7002828C7002828C7002828
      C7002828C7002828C7002A2ABE006666B300F1F1F20000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000009F9F9F00000000005656
      5600FDFDFD000000000000000000000000000000000000000000BBBBBB000000
      00000000000000000000E9E9E900000000006666660000000000666666000000
      0000E9E9E9000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000DBDBE1004141B1002A2AC2002929C8002929
      C8002929C8002929C8002929C8002929C8002929C8002929C8002929C8002929
      C8002929C8002929C8002929C8002A2BBD007676B700F6F6F600000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F9F9F9003838380000000000AFAF
      AF00000000000000000000000000000000000000000000000000BBBBBB000000
      00000000000000000000E9E9E900000000007575750000000000757575000000
      0000E9E9E9000000000000000000000000000000000000000000000000000000
      00000000000000000000D9D9E0003F3FB1002A2AC400292AC900292AC900292A
      C900292AC900292AC900292AC900292AC900292AC900292AC900292AC900292A
      C900292AC900292AC900292AC900292AC9002B2CBC008484BB00F9F9F9000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000CFCFCF000000000000000000E6E6
      E6000000000000000000000000000000000000000000000000008C8C8C00C0C0
      C000C0C0C000E3E3E300FEFEFE006666660022222200C0C0C000222222006666
      6600FEFEFE000000000000000000000000000000000000000000000000000000
      000000000000D7D7DF003F3FB2002A2BC5002A2ACA002A2ACA002A2ACA002A2A
      CA002A2ACA002A2ACA002A2ACA002A2ACA002A2ACA002A2ACA002A2ACA002A2A
      CA002A2ACA002A2ACA002A2ACA002A2ACA002A2ACA002C2DBB009191BF00FCFC
      FC00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008B8B8B00000000006C6C6C000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000BBBBBB0000000000EAEAEA002A2A2A000000000026262600E9E9
      E900000000000000000000000000000000000000000000000000000000000000
      0000D5D6DF003D3DB3002A2BC6002A2BCB002A2BCB002A2BCB002A2BCB002A2B
      CB002A2BCB002A2BCB002A2BCB002A2BCB002A2BCB002A2BCB002A2BCB002A2B
      CB002A2BCB002A2BCB002A2BCB002A2BCB002A2BCB002A2BCB002D2DB9009F9F
      C400FEFEFE000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000F2F2F2001616160000000000BDBDBD000000
      000000000000000000000000000000000000000000000000000094949400CACA
      CA00CACACA00E7E7E700000000009D9D9D000000000096969600000000009D9D
      9D0000000000000000000000000000000000000000000000000000000000D3D3
      DE003A3BB5002B2CC7002B2BCC002B2BCC002B2BCC002B2BCC002B2BCC002B2B
      CC002B2BCC002B2BCC002B2BCC002B2BCC002B2BCC002B2BCC002B2BCC002B2B
      CC002B2BCC002B2BCC002B2BCC002B2BCC002B2BCC002B2BCC002B2BCC002D2E
      B800ADADC9000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C2C2C2000000000016161600EEEEEE000000
      0000000000000000000000000000000000000000000000000000BBBBBB000000
      00000000000000000000FBFBFB001C1C1C0032323200FEFEFE002E2E2E001C1C
      1C00FCFCFC000000000000000000000000000000000000000000D1D1DD003738
      B5002B2CC9002B2CCD002B2CCD002B2CCD002B2CCD002B2CCD002B2CCD002B2C
      CD002B2CCD002B2CCD002B2CCD002B2CCD002B2CCD002B2CCD002B2CCD002B2C
      CD002B2CCD002B2CCD002B2CCD002B2CCD002B2CCD002B2CCD002B2CCD002B2C
      CC002E2FB700BBBBD00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000737373000000000081818100000000000000
      0000000000000000000000000000000000000000000000000000BBBBBB000000
      00000000000000000000FAFAFA00000000002E2E2E00FBFBFB002A2A2A000000
      0000FAFAFA0000000000000000000000000000000000CFCFDC003839B6002C2D
      CA002B2CCE002B2CCE002B2CCE002B2CCE002B2CCE002B2CCE002B2CCE002B2C
      CE002B2CCE002B2CCE002B2CCE002B2CCE002B2CCE002B2CCE002B2CCE002B2C
      CE002B2CCE002B2CCE002B2CCE002B2CCE002B2CCE002B2CCE002B2CCE002B2C
      CE002C2DCC003233B700C7C7D600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000E9E9E9000000000000000000C8C8C800E8E8E8006060
      60009F9F9F00FAFAFA0000000000000000000000000000000000454545006262
      62006262620062626200C5C5C500767676000000000063636300000000007878
      780000000000000000000000000000000000000000003537B4002C2DCB002C2D
      CF002C2DCF002C2DCF002C2DCF002C2DCF002C2DCF002C2DCF002C2DCF002C2D
      CF002C2DCF002C2DCF002C2DCF002C2DCF002C2DCF002C2DCF002C2DCF002C2D
      CF002C2DCF002C2DCF002C2DCF002C2DCF002C2DCF002C2DCF002C2DCF002C2D
      CF002C2DCF002C2DCC003537B400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000B2B2B200000000002A2A2A00F6F6F600A2A2A2000000
      00000000000078787800EEEEEE00000000000000000000000000000000000000
      00000000000000000000BBBBBB00E6E6E6005F5F5F000000000060606000E8E8
      E80000000000000000000000000000000000000000003031B3002C2ED0002C2E
      D0002C2ED0002C2ED0002C2ED0002C2ED0002C2ED0002C2ED0002C2ED0002C2E
      D0002C2ED0002C2ED0002C2ED0002C2ED0002C2ED0002C2ED0002C2ED0002C2E
      D0002C2ED0002C2ED0002C2ED0002C2ED0002C2ED0002C2ED0002C2ED0002C2E
      D0002C2ED0002C2ED0003031B400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FDFDFD005A5A5A000000000094949400FAFAFA003D3D3D000000
      0000000000000000000038383800B8B8B800F5F5F50000000000000000000000
      000000000000F7F7F700D6D6D600ADADAD008383830068686800717171008686
      8600B8B8B800E3E3E300FEFEFE0000000000000000003132B4002D2ED1002D2E
      D1002D2ED1002D2ED1002D2ED1002D2ED1002D2ED1002D2ED1002D2ED1002D2E
      D1002D2ED1002D2ED1002D2ED1002D2ED1002D2ED1002D2ED1002D2ED1002D2E
      D1002D2ED1002D2ED1002D2ED1002D2ED1002D2ED1002D2ED1002D2ED1002D2E
      D1002D2ED1002D2ED1003032B500000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000DDDDDD000000000000000000D5D5D500D1D1D100000000000000
      0000000000000000000000000000000000002A2A2A0083838300989898008F8F
      8F006E6E6E001616160000000000000000000000000000000000000000000000
      0000000000000000000069696900D9D9D900000000003132B5002D2FD2002D2F
      D2002D2FD2002D2FD2002D2FD2002D2FD2002D2FD2002D2FD2002D2FD2002D2F
      D2002D2FD2002D2FD2002D2FD2002D2FD2002D2FD2002D2FD2002D2FD2002D2F
      D2002D2FD2002D2FD2002D2FD2002D2FD2002D2FD2002D2FD2002D2FD2002D2F
      D2002D2FD2002D2FD2003132B600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000A2A2A2000000000042424200FBFBFB008F8F8F00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007F7F7F00A7A7A700A3A3A3006363
      63000000000000000000000000005D5D5D00000000003133B7002E2FD4002E2F
      D4002E2FD4002E2FD4002E2FD4002E2FD4002E2FD4002E2FD4002E2FD4002E2F
      D4002E2FD4002E2FD4002E2FD4002E2FD4002E2FD4002E2FD4002E2FD4002E2F
      D4002E2FD4002E2FD4002E2FD4002E2FD4002E2FD4002E2FD4002E2FD4002E2F
      D4002E2FD4002E2FD4003133B700000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FBFBFB003D3D3D0000000000A5A5A500F3F3F30022222200000000000000
      000000000000000000000000000042424200B4B4B4008F8F8F007F7F7F008989
      890071717100000000000000000000000000F0F0F0000000000000000000A5A5
      A5000000000000000000000000004F4F4F00000000003233B7002E30D5002E30
      D5002E30D5002E30D5002E30D5002E30D5002E30D5002E30D5002E30D5002E30
      D5002E30D5002E30D5002E30D5002E30D5002E30D5002E30D5002E30D5002E30
      D5002E30D5002E30D5002E30D5002E30D5002E30D5002E30D5002E30D5002E30
      D5002E30D5002E30D5003233B700000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000D2D2D2000000000000000000DFDFDF00C4C4C40000000000000000000000
      0000000000000000000000000000ABABAB000000000000000000000000000000
      00009F9F9F0000000000000000005D5D5D000000000000000000000000009494
      940000000000000000000000000047474700000000003233B8002F31D6002F31
      D6002F31D6002F31D6002F31D6002F31D6002F31D6002F31D6002F31D6002F31
      D6002F31D6002F31D6002F31D6002F31D6002F31D6002F31D6002F31D6002F31
      D6002F31D6002F31D6002F31D6002F31D6002F31D6002F31D6002F31D6002F31
      D6002F31D6002F31D5003233B800000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000091919100000000005D5D5D00FEFEFE00787878000000000078787800C3C3
      C3002A2A2A000000000000000000E7E7E700000000000000000000000000FEFE
      FE005353530000000000000000009B9B9B000000000000000000000000008383
      830000000000000000000000000047474700000000003234B9002F31D7002F31
      D7002F31D7002F31D7002F31D7002F31D7002F31D7002F31D7002F31D7002F31
      D7002F31D7002F31D7002F31D7002F31D7002F31D7002F31D7002F31D7002F31
      D7002F31D7002F31D7002F31D7002F31D7002F31D7002F31D7002F31D7002F31
      D7002F31D7002F31D6003234B900000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000F4F4
      F4002222220000000000B5B5B500ECECEC000000000000000000C4C4C4000000
      0000EAEAEA00878787007373730000000000000000000000000000000000E9E9
      E900000000000000000047474700ABABAB00C8C8C800C3C3C300CBCBCB009696
      960022222200000000000000000047474700000000003234BA002F32D8002F32
      D8002F32D8002F32D8002F32D8002F32D8002F32D8002F32D8002F32D8002F32
      D8002F32D8002F32D8002F32D8002F32D8002F32D8002F32D8002F32D8002F32
      D8002F32D8002F32D8002F32D8002F32D8002F32D8002F32D8002F32D8002F32
      D8002F32D8002F32D7003234BA00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C7C7
      C7000000000000000000EAEAEA00B8B8B8000000000022222200F3F3F3000000
      00000000000000000000C0C0C000C3C3C300E2E2E200EAEAEA00E5E5E500CACA
      CA00C2C2C200E6E6E600FDFDFD007D7D7D00000000000000000000000000F9F9
      F900F5F5F5009D9D9D000000000047474700000000003235BB003032D9003032
      D9003032D9003032D9003032D9003032D9003032D9003032D9003032D9003032
      D9003032D9003032D9003032D9003032D9003032D9003032D9003032D9003032
      D9003032D9003032D9003032D9003032D9003032D9003032D9003032D9003032
      D9003032D9003032D8003235BB00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000007D7D
      7D000000000076767600FEFEFE0063636300000000008D8D8D00000000000000
      000000000000FCFCFC005353530000000000000000000000000000000000D9D9
      D9000000000000000000FBFBFB002A2A2A00000000000000000032323200FEFE
      FE0000000000BEBEBE000000000047474700000000003335BB003033DA003033
      DA003033DA003033DA003033DA003033DA003033DA003033DA003033DA003033
      DA003033DA003033DA003033DA003033DA003033DA003033DA003033DA003033
      DA003033DA003033DA003033DA003033DA003033DA003033DA003033DA003033
      DA003033DA003033D9003335BC00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000EDEDED000000
      000000000000C3C3C300E2E2E2000000000000000000CFCFCF00000000000000
      000000000000D6D6D600000000000000000000000000000000002A2A2A00FAFA
      FA000000000000000000E2E2E2000000000000000000000000005A5A5A000000
      000000000000BEBEBE000000000047474700000000003336BC003133DB003133
      DB003133DB003133DB003133DB003133DB003133DB003133DB003133DB003133
      DB003133DB003133DB003133DB003133DB003133DB003133DB003133DB003133
      DB003133DB003133DB003133DB003133DB003133DB003133DB003133DB003133
      DB003133DB003134DA003336BD00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000B8B8B8000000
      000022222200F3F3F300AAAAAA000000000000000000EBEBEB00000000000000
      0000000000009191910000000000000000000000000000000000898989000000
      00000000000000000000C0C0C000000000000000000000000000787878000000
      000000000000BEBEBE000000000047474700000000007979C8003235CC003134
      DC003134DC003134DC003134DC003134DC003134DC003134DC003134DC003134
      DC003134DC003134DC003134DC003134DC003134DC003134DC003134DC003134
      DC003134DC003134DC003134DC003134DC003134DC003134DC003134DC003134
      DC003134DC003235CD007475CA00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FEFEFE00636363000000
      00008D8D8D00FCFCFC004B4B4B0000000000000000004F4F4F00CBCBCB00FDFD
      FD00F3F3F3002222220000000000000000000000000000000000BFBFBF000000
      000000000000FEFEFE00C8C8C800D5D5D500EDEDED00EEEEEE00D5D5D500CBCB
      CB00FBFBFB00BDBDBD00000000004747470000000000F6F6F7008687CB003336
      CB003235DD003235DD003235DD003235DD003235DD003235DD003235DD003235
      DD003235DD003235DD003235DD003235DD003235DD003235DD003235DD003235
      DD003235DD003235DD003235DD003235DD003235DD003235DD003235DD003235
      DD003335CF007272CA00F2F2F400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000E2E2E200000000000000
      0000CFCFCF00DADADA0000000000000000000000000000000000000000006969
      6900C3C3C3006060600000000000000000000000000000000000E7E7E700F6F6
      F600C5C5C50069696900F7F7F700000000000000000000000000D6D6D6000000
      0000535353007A7A7A00000000004B4B4B000000000000000000FAFAFA009393
      CE003436C9003235DD003235DE003235DE003235DE003235DE003235DE003235
      DE003235DE003235DE003235DE003235DE003235DE003235DE003235DE003235
      DE003235DE003235DE003235DE003235DE003235DE003235DE003235DE003336
      D1006E6FC900F1F1F30000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000EFEFEF008F8F8F00000000003838
      3800F9F9F900A2A2A20000000000000000000000000000000000000000001616
      1600F1F1F10000000000F4F4F400DFDFDF00D4D4D400C9C9C900818181002222
      2200000000006E6E6E0000000000000000000000000000000000C8C8C8000000
      00000000000000000000000000004B4B4B00000000000000000000000000FCFC
      FC00A0A0D1003537C8003336DE003336DF003336DF003336DF003336DF003336
      DF003336DF003336DF003336DF003336DF003336DF003336DF003336DF003336
      DF003336DF003336DF003336DF003336DF003336DF003336DF003436D2006C6C
      C900F0F0F2000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007373730000000000000000005A5A
      5A00FBFBFB005353530000000000000000000000000000000000000000008F8F
      8F000000000000000000000000000000000000000000D8D8D800000000000000
      000000000000A7A7A70000000000FCFCFC00F5F5F500FBFBFB00B9B9B9000000
      00000000000000000000000000004B4B4B000000000000000000000000000000
      0000FEFEFE00ADAED5003538C7003336DE003336E0003336E0003336E0003336
      E0003336E0003336E0003336E0003336E0003336E0003336E0003336E0003336
      E0003336E0003336E0003336E0003336E0003336E0003437D4006869C900EFEF
      F100000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000A3A3A30000000000000000000000
      0000EEEEEE009B9B9B000000000000000000000000000000000000000000D4D4
      D4000000000000000000000000000000000000000000ADADAD00000000000000
      0000000000008D8D8D00818181002A2A2A000000000016161600323232000000
      00000000000000000000000000004B4B4B000000000000000000000000000000
      00000000000000000000BABBD900393BC6003437DE003337E1003337E1003337
      E1003337E1003337E1003337E1003337E1003337E1003337E1003337E1003337
      E1003337E1003337E1003337E1003337E1003437D6006566C900EEEEF1000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000EDEDED00C5C5C500D0D0
      D00000000000FCFCFC00ADADAD0000000000000000000000000000000000BFBF
      BF00F0F0F000000000000000000000000000000000006C6C6C00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000004F4F4F000000000000000000000000000000
      0000000000000000000000000000C7C7DD003B3EC7003438DD003438E2003438
      E2003438E2003438E2003438E2003438E2003438E2003438E2003438E2003438
      E2003438E2003438E2003438E2003538D8006364C900ECECEF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000DCDCDC006969690000000000000000000000
      0000000000005A5A5A00898989009A9A9A009696960000000000000000000000
      0000000000000000000071717100BBBBBB00CDCDCD00C3C3C300969696002A2A
      2A000000000000000000000000004F4F4F000000000000000000000000000000
      000000000000000000000000000000000000D1D2E1004346C6003538DC003438
      E3003438E3003438E3003438E3003438E3003438E3003438E3003438E3003438
      E3003438E3003438E3003538D9006062C800EBEBEE0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FCFCFC00CFCFCF007D7D7D000000
      0000000000000000000000000000000000000000000000000000000000001616
      160091919100DEDEDE000000000000000000000000000000000000000000F2F2
      F200AAAAAA0016161600000000004F4F4F000000000000000000000000000000
      00000000000000000000000000000000000000000000DADBE6004B4EC600373A
      C400363AC400363AC400363AC400363AC400363AC400363AC400363AC400363A
      C400363AC400363AC4005D5FC800E9EAED000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000F0F0
      F000CECECE00ABABAB008F8F8F007F7F7F00818181009B9B9B00C3C3C300EFEF
      EF00000000000000000000000000000000000000000000000000000000000000
      000000000000E4E4E4008B8B8B00C5C5C5000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000DFDBDF000000
      0000000000000000000031243100000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000EBF6EB000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000EBFBFB000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000EBEBFE000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E8E7E8000000
      00000000000000000000140E1400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9F6E9000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9FBFB000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9E9FE000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FAFAFA000000
      00000000000000000000140E1400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9F6E9000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9FBFB000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9E9FE000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FDFDFD000000
      00000000000000000000140E1400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9F6E9000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9FBFB000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9E9FE000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000140E1400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9F6E9000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9FBFB000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9E9FE000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000140E1400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9F6E9000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9FBFB000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9E9FE000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FEFEFE000000
      00000000000000000000140E1400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9F6E9000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9FBFB000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9E9FE000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FCFCFC000000
      00000000000000000000140E1400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9F6E9000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9FBFB000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9E9FE000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000F8F7F8000000
      00000000000000000000140E1400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9F6E9000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9FBFB000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9E9FE000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000F8F7F8000000
      00000000000000000000140E14000000000000000000FCF6FC00F6E3F600F5DD
      F500F7E3F700FCF5FC0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9F6E9000000
      00000000000000000000000000000000000000000000F5FBF500E0F2E000D9EF
      D900E1F2E100F4FAF40000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9FBFB000000
      00000000000000000000000000000000000000000000F5FDFD00DFF9F900D9F8
      F800E0F9F900F4FDFD0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9E9FE000000
      00000000000000000000000000000000000000000000F5F5FE00DFDFFD00D9D9
      FD00E0E0FD00F4F4FE0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000F8F7F8000000
      00000000000000000000140E1400F6E1F600E498E400DB58DB00DB55DB00DB55
      DB00DB55DB00DB55DB00E181E100ECBAEC00F8E8F80000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9F6E9000000
      0000000000000000000000000000DEF1DE0089D6890022C7220016C6160016C6
      160016C6160016C616006BCF6B00B2E1B200E6F4E60000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9FBFB000000
      0000000000000000000000000000DDF9F90087EEEE0016E8E80000E8E80000E8
      E80000E8E80000E8E80069EBEB00B1F2F200E6FAFA0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E9E9FE000000
      0000000000000000000000000000DDDDFD008787FA001616F8000000F8000000
      F8000000F8000000F8006969F900B1B1FB00E6E6FE0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000F8F7F8000000
      000000000000000000000F020F00DB55DB00DB55DB00DB55DB00DB55DB00DB55
      DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55DB00E185E100EFC8EF00FBF3
      FB00000000000000000000000000000000000000000000000000000000000000
      0000F7E3F700FBF3FB0000000000000000000000000000000000E9F6E9000000
      000000000000000000000000000016C6160016C6160016C6160016C6160016C6
      160016C6160016C6160016C6160016C6160016C6160071D07100C2E7C200F2FA
      F200000000000000000000000000000000000000000000000000000000000000
      0000E1F2E100F1F9F10000000000000000000000000000000000E9FBFB000000
      000000000000000000000000000000E8E80000E8E80000E8E80000E8E80000E8
      E80000E8E80000E8E80000E8E80000E8E80000E8E8006EECEC00C2F5F500F2FD
      FD00000000000000000000000000000000000000000000000000000000000000
      0000E0F9F900F1FCFC0000000000000000000000000000000000E9E9FE000000
      00000000000000000000000000000000F8000000F8000000F8000000F8000000
      F8000000F8000000F8000000F8000000F8000000F8006E6EF900C2C2FC00F2F2
      FE00000000000000000000000000000000000000000000000000000000000000
      0000E0E0FD00F1F1FE0000000000000000000000000000000000F8F7F8000000
      0000000000000000000010021000DB55DB00DB55DB00DB55DB00DB55DB00DB55
      DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55DB00DB58
      DB00E496E400EFC7EF00F7E3F700FBF3FB00FCF7FC00FAEEFA00F2D4F200E59B
      E500DB55DB00F9EBF90000000000000000000000000000000000E9F6E9000000
      000000000000000000000000000016C6160016C6160016C6160016C6160016C6
      160016C6160016C6160016C6160016C6160016C6160016C6160016C6160022C7
      220087D58700C1E6C100E1F2E100F2FAF200F6FBF600EDF7ED00CFECCF008DD7
      8D0016C61600E9F6E90000000000000000000000000000000000E9FBFB000000
      000000000000000000000000000000E8E80000E8E80000E8E80000E8E80000E8
      E80000E8E80000E8E80000E8E80000E8E80000E8E80000E8E80000E8E80016E8
      E80085EEEE00C0F5F500E0F9F900F2FDFD00F6FDFD00EDFCFC00CFF7F7008BEE
      EE0000E8E800E9FBFB0000000000000000000000000000000000E9E9FE000000
      00000000000000000000000000000000F8000000F8000000F8000000F8000000
      F8000000F8000000F8000000F8000000F8000000F8000000F8000000F8001616
      F8008585FA00C0C0FC00E0E0FD00F2F2FE00F6F6FE00EDEDFE00CFCFFC008B8B
      FA000000F800E9E9FE0000000000000000000000000000000000F8F7F8000000
      0000000000000000000010021000DB55DB00DB55DB00DB55DB00DB55DB00DB55
      DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55
      DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55
      DB00DB55DB00F9EBF90000000000000000000000000000000000E9F6E9000000
      000000000000000000000000000016C6160016C6160016C6160016C6160016C6
      160016C6160016C6160016C6160016C6160016C6160016C6160016C6160016C4
      160014BC140014BC140016C6160016C6160016C6160016C6160016C6160016C6
      160016C61600E9F6E90000000000000000000000000000000000E9FBFB000000
      000000000000000000000000000000E8E80000E8E80000E8E80000E8E80000E8
      E80000E8E80000E8E80000E8E80000E8E80000E8E80000E8E80000E8E80000E8
      E80000E5E50000DCDC0000E6E60000E8E80000E8E80000E8E80000E8E80000E8
      E80000E8E800E9FBFB0000000000000000000000000000000000E9E9FE000000
      00000000000000000000000000000000F8000000F8000000F8000000F8000000
      F8000000F8000000F8000000F8000000F8000000F8000000F8000000F8000000
      F8000000F8000000F8000000F8000000F8000000F8000000F8000000F8000000
      F8000000F800E9E9FE0000000000000000000000000000000000F8F7F8000000
      0000000000000000000010021000DB55DB00DB55DB00DB55DB00C14AC1000000
      000000000000D352D300DB55DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55
      DB00DB55DB00C94DC9000000000000000000C94DC900DB55DB00DB55DB00DB55
      DB00DB55DB00F9EBF90000000000000000000000000000000000E9F6E9000000
      000000000000000000000000000016C6160016C6160016C6160012AE12000000
      00000000000015BF150016C6160016C6160016C6160016C616000A820A00000E
      00000000000000000000034A030012AE120016C6160016C6160016C6160016C6
      160016C61600E9F6E90000000000000000000000000000000000E9FBFB000000
      000000000000000000000000000000E8E80000E8E80000E8E80000CCCC000000
      00000000000000E0E00000E8E80000E8E80000E8E80000E8E80000E8E80000AD
      AD0000323200000000000045450000C2C20000E8E80000E8E80000E8E80000E8
      E80000E8E800E9FBFB0000000000000000000000000000000000E9E9FE000000
      00000000000000000000000000000000F8000000F8000000F8000000DA000000
      0000000000000000EF000000F8000000F8000000F8000000F8000000F8000000
      9B000000000000008E000000F8000000F8000000F8000000F8000000F8000000
      F8000000F800E9E9FE0000000000000000000000000000000000F8F7F8000000
      0000000000000000000010021000DB55DB00DB55DB00DB55DB00C14AC1000000
      000000000000D352D300DB55DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55
      DB00DB55DB00C94DC9000000000000000000C94DC900DB55DB00DB55DB00DB55
      DB00DB55DB00F9EBF90000000000000000000000000000000000E9F6E9000000
      000000000000000000000000000016C6160016C6160016C6160012AE12000000
      00000000000015BF150016C6160016C6160016C6160016C61600097709000000
      0000000000000000000000000000023A020015C2150016C6160016C6160016C6
      160016C61600E9F6E90000000000000000000000000000000000E9FBFB000000
      000000000000000000000000000000E8E80000E8E80000E8E80000CCCC000000
      00000000000000E0E00000E8E80000E8E80000E8E80000E8E80000CACA000000
      0000000000000000000000000000002F2F0000DEDE0000E8E80000E8E80000E8
      E80000E8E800E9FBFB0000000000000000000000000000000000E9E9FE000000
      00000000000000000000000000000000F8000000F8000000F8000000DA000000
      0000000000000000EF000000F8000000F8000000F8000000F8000000F8000000
      C8000000000000003B000000F6000000F8000000F8000000F8000000F8000000
      F8000000F800E9E9FE0000000000000000000000000000000000F8F7F8000000
      0000000000000000000010021000DB55DB00DB55DB00DB55DB00C14AC1000000
      000000000000D352D300DB55DB00DB55DB00DB55DB00CE4FCE009E3B9E009E3B
      9E009E3B9E0091369100000000000000000091369100CA4ECA00DB55DB00DB55
      DB00DB55DB00F9EBF90000000000000000000000000000000000E9F6E9000000
      000000000000000000000000000016C6160016C6160016C6160012AE12000000
      00000000000015BF150016C6160016C6160016C6160016C6160013B4130014B7
      140015C0150012AE1200000700000000000011A9110016C6160016C6160016C6
      160016C61600E9F6E90000000000000000000000000000000000E9FBFB000000
      000000000000000000000000000000E8E80000E8E80000E8E80000CCCC000000
      00000000000000E0E00000E8E80000E8E80000E8E80000E8E800009F9F000000
      0000004F4F0000D1D100000A0A000000000000C1C10000E8E80000E8E80000E8
      E80000E8E800E9FBFB0000000000000000000000000000000000E9E9FE000000
      00000000000000000000000000000000F8000000F8000000F8000000DA000000
      0000000000000000EF000000F8000000F8000000F8000000F8000000F8000000
      EB0000000000000000000000DD000000F8000000F8000000F8000000F8000000
      F8000000F800E9E9FE0000000000000000000000000000000000F8F7F8000000
      0000000000000000000010021000DB55DB00DB55DB00DB55DB00C14AC1000000
      000000000000D352D300DB55DB00DB55DB00DB55DB00C14AC100000000000000
      00000000000000000000000000000000000000000000B746B700DB55DB00DB55
      DB00DB55DB00F9EBF90000000000000000000000000000000000E9F6E9000000
      000000000000000000000000000016C6160016C6160016C6160012AE12000000
      00000000000015BF150016C6160016C6160016C6160016C6160016C6160016C6
      160016C6160016C6160004520400000000000F9B0F0016C6160016C6160016C6
      160016C61600E9F6E90000000000000000000000000000000000E9FBFB000000
      000000000000000000000000000000E8E80000E8E80000E8E80000CCCC000000
      00000000000000E0E00000E8E80000E8E80000E8E80000E8E800008E8E000000
      00000085850000E8E800004949000000000000B6B60000E8E80000E8E80000E8
      E80000E8E800E9FBFB0000000000000000000000000000000000E9E9FE000000
      00000000000000000000000000000000F8000000F8000000F8000000DA000000
      0000000000000000EF000000F8000000F8000000F8000000F8000000F8000000
      F80000006900000000000000B7000000F8000000F8000000F8000000F8000000
      F8000000F800E9E9FE0000000000000000000000000000000000F8F7F8000000
      0000000000000000000010021000DB55DB00DB55DB00DB55DB00C14AC1000000
      000000000000D352D300DB55DB00DB55DB00DB55DB00C84DC800000000000000
      000063226300792B79000000000000000000792B7900C44BC400DB55DB00DB55
      DB00DB55DB00F9EBF90000000000000000000000000000000000E9F6E9000000
      000000000000000000000000000016C6160016C6160016C6160012AE12000000
      00000000000015BF150016C6160016C6160016C6160016C6160016C6160016C6
      160016C6160016C6160004570400000000000E990E0016C6160016C6160016C6
      160016C61600E9F6E90000000000000000000000000000000000E9FBFB000000
      000000000000000000000000000000E8E80000E8E80000E8E80000CCCC000000
      00000000000000E0E00000E8E80000E8E80000E8E80000E8E800008E8E000000
      00000087870000E8E800004E4E000000000000B4B40000E8E80000E8E80000E8
      E80000E8E800E9FBFB0000000000000000000000000000000000E9E9FE000000
      00000000000000000000000000000000F8000000F8000000F8000000DA000000
      0000000000000000EF000000F8000000F8000000F8000000F8000000F8000000
      F8000000A80000000000000083000000F8000000F8000000F8000000F8000000
      F8000000F800E9E9FE0000000000000000000000000000000000F5F4F5000000
      0000000000000000000010021000DB55DB00DB55DB00DB55DB00C14AC1000000
      000000000000772A77007B2C7B007B2C7B00AC41AC00DB55DB00792B79000000
      00006B256B00CB4ECB003A103A003A103A00CB4ECB00DB55DB00DB55DB00DB55
      DB00DB55DB00F9EBF90000000000000000000000000000000000E9F6E9000000
      000000000000000000000000000016C6160016C6160016C6160012AE12000000
      000000000000076B0700076E0700076E07000F9B0F0016C6160016C6160015C1
      150015BF150014BD1400011E01000000000010A4100016C6160016C6160016C6
      160016C61600E9F6E90000000000000000000000000000000000E9FBFB000000
      000000000000000000000000000000E8E80000E8E80000E8E80000CCCC000000
      000000000000007E7E00008282000082820000B7B70000E8E800009393000000
      0000005F5F0000DEDE00001919000000000000C1C10000E8E80000E8E80000E8
      E80000E8E800E9FBFB0000000000000000000000000000000000E9E9FE000000
      00000000000000000000000000000000F8000000F8000000F8000000DA000000
      0000000000000000870000008C0000008C000000C3000000F8000000F8000000
      F8000000D10000000000000029000000F4000000F8000000F8000000F8000000
      F8000000F800E9E9FE0000000000000000000000000000000000000000000000
      0000000000000000000010021000DB55DB00DB55DB00DB55DB00C14AC1000000
      00000000000000000000000000000000000094379400DB55DB00C54CC5000000
      000000000000BA47BA00DB55DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55
      DB00DB55DB00F9EBF90000000000000000000000000000000000E9F6E9000000
      000000000000000000000000000016C6160016C6160016C6160012AE12000000
      0000000000000000000000000000000000000B860B0016C616000C8A0C000013
      00000121010001290100000000000013000014BC140016C6160016C6160016C6
      160016C61600E9F6E90000000000000000000000000000000000E9FBFB000000
      000000000000000000000000000000E8E80000E8E80000E8E80000CCCC000000
      000000000000000000000000000000000000009D9D0000E8E800009F9F000000
      0000000000000034340000000000000A0A0000DCDC0000E8E80000E8E80000E8
      E80000E8E800E9FBFB0000000000000000000000000000000000E9E9FE000000
      00000000000000000000000000000000F8000000F8000000F8000000DA000000
      0000000000000000000000000000000000000000A8000000F8000000F8000000
      F8000000F10000001B00000000000000D7000000F8000000F8000000F8000000
      F8000000F800E9E9FE0000000000000000000000000000000000000000000000
      0000000000000000000010021000DB55DB00DB55DB00DB55DB00C14AC1000000
      0000000000009F3C9F00A53EA500A53EA500BE49BE00DB55DB00DB55DB00812F
      81000000000064226400DB55DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55
      DB00DB55DB00F9EBF90000000000000000000000000000000000E9F6E9000000
      000000000000000000000000000016C6160016C6160016C6160012AE12000000
      0000000000000D900D000E950E000E950E0012AC120016C61600097709000000
      0000012F0100000E0000000E00000D920D0016C6160016C6160016C6160016C6
      160016C61600E9F6E90000000000000000000000000000000000E9FBFB000000
      000000000000000000000000000000E8E80000E8E80000E8E80000CCCC000000
      00000000000000A9A90000AFAF0000AFAF0000CACA0000E8E80000B2B2000000
      0000000000000000000000000000009D9D0000E8E80000E8E80000E8E80000E8
      E80000E8E800E9FBFB0000000000000000000000000000000000E9E9FE000000
      00000000000000000000000000000000F8000000F8000000F8000000DA000000
      0000000000000000B5000000BB000000BB000000D8000000F8000000F8000000
      F8000000F80000007C00000000000000AF000000F8000000F8000000F8000000
      F8000000F800E9E9FE0000000000000000000000000000000000FDFDFD000000
      0000000000000000000010021000DB55DB00DB55DB00DB55DB00C14AC1000000
      000000000000D352D300DB55DB00DB55DB00DB55DB00DB55DB00DB55DB00C94D
      C9000901090000000000B645B600DB55DB00DB55DB00DB55DB00DB55DB00DB55
      DB00DB55DB00F9EBF90000000000000000000000000000000000E9F6E9000000
      000000000000000000000000000016C6160016C6160016C6160012AE12000000
      00000000000015BF150016C6160016C6160016C6160016C61600097709000000
      00000977090015BF150015BF150016C6160016C6160016C6160016C6160016C6
      160016C61600E9F6E90000000000000000000000000000000000E9FBFB000000
      000000000000000000000000000000E8E80000E8E80000E8E80000CCCC000000
      00000000000000E0E00000E8E80000E8E80000E8E80000E8E80000CECE000000
      00000000000000BEBE0000D0D00000E8E80000E8E80000E8E80000E8E80000E8
      E80000E8E800E9FBFB0000000000000000000000000000000000E9E9FE000000
      00000000000000000000000000000000F8000000F8000000F8000000DA000000
      0000000000000000EF000000F8000000F8000000F8000000F8000000F8000000
      F8000000F8000000B30000000000000077000000F8000000F8000000F8000000
      F8000000F800E9E9FE0000000000000000000000000000000000000000000000
      0000000000000000000010021000DB55DB00DB55DB00DB55DB00C14AC1000000
      000000000000D352D300DB55DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55
      DB0088328800000000005D1F5D00DA55DA00DB55DB00DB55DB00DB55DB00DB55
      DB00DB55DB00F9EBF90000000000000000000000000000000000E9F6E9000000
      000000000000000000000000000016C6160016C6160016C6160012AE12000000
      00000000000015BF150016C6160016C6160016C6160016C61600097709000000
      00000977090016C6160016C6160016C6160016C6160016C6160016C6160016C6
      160016C61600E9F6E90000000000000000000000000000000000E9FBFB000000
      000000000000000000000000000000E8E80000E8E80000E8E80000CCCC000000
      00000000000000E0E00000E8E80000E8E80000E8E80000E8E80000E7E7000055
      5500000000000094940000E8E80000E8E80000E8E80000E8E80000E8E80000E8
      E80000E8E800E9FBFB0000000000000000000000000000000000E9E9FE000000
      00000000000000000000000000000000F8000000F8000000F8000000DA000000
      0000000000000000EF000000F8000000F8000000F8000000F8000000F8000000
      F8000000F8000000DA0000000000000015000000F0000000F8000000F8000000
      F8000000F800E9E9FE0000000000000000000000000000000000000000000000
      000000000000000000001F061F00DB55DB00DB55DB00DB55DB00C14AC1000000
      000000000000AD42AD00B344B300B344B300B344B300BE49BE00DB55DB00DB55
      DB00CC4FCC001704170000000000B143B100DB55DB00DB55DB00DB55DB00DB55
      DB00DB55DB00F9EBF90000000000000000000000000000000000E9F6E9000000
      000000000000000000000000000016C6160016C6160016C6160012AE12000000
      0000000000000F9C0F0010A2100010A2100010A2100012AC1200097709000000
      00000560050010A2100010A2100010A2100015C1150016C6160016C6160016C6
      160016C61600E9F6E90000000000000000000000000000000000E9FBFB000000
      000000000000000000000000000000E8E80000E8E80000E8E80000CCCC000000
      00000000000000B8B80000BEBE0000BEBE0000BEBE0000CACA0000E8E80000B6
      B60000000000000A0A0000C9C90000E8E80000E8E80000E8E80000E8E80000E8
      E80000E8E800E9FBFB0000000000000000000000000000000000E9E9FE000000
      00000000000000000000000000000000F8000000F8000000F8000000DA000000
      0000000000000000C5000000CB000000CB000000CB000000D2000000CB000000
      CB000000CB000000C80000000C00000000000000D0000000F8000000F8000000
      F8000000F800E9E9FE0000000000000000000000000000000000000000000000
      0000000000000000000017041700DB55DB00DB55DB00DB55DB00C14AC1000000
      0000000000000000000000000000000000000000000074297400DB55DB00DB55
      DB00DB55DB008E348E0000000000551C5500D954D900DB55DB00DB55DB00DB55
      DB00DB55DB00F9EBF90000000000000000000000000000000000E9F6E9000000
      000000000000000000000000000016C6160016C6160016C6160012AE12000000
      0000000000000000000000000000000000000000000007680700097709000000
      00000000000000000000000000000000000013B6130016C6160016C6160016C6
      160016C61600E9F6E90000000000000000000000000000000000E9FBFB000000
      000000000000000000000000000000E8E80000E8E80000E8E80000CCCC000000
      00000000000000000000000000000000000000000000007B7B0000E8E80000E7
      E70000707000000000000049490000E3E30000E8E80000E8E80000E8E80000E8
      E80000E8E800E9FBFB0000000000000000000000000000000000E9E9FE000000
      00000000000000000000000000000000F8000000F8000000F8000000DA000000
      0000000000000000000000000000000000000000000000005F00000000000000
      0000000000000000000000000000000000000000C0000000F8000000F8000000
      F8000000F800E9E9FE0000000000000000000000000000000000F8F7F8000000
      0000000000000000000000000000DB55DB00DB55DB00DB55DB00C54CC5006121
      610061216100612161006121610061216100612161008D348D00DB55DB00DB55
      DB00DB55DB00CF50CF003810380096389600D653D600DB55DB00DB55DB00DB55
      DB00DB55DB00F9EBF90000000000000000000000000000000000E9F6E9000000
      000000000000000000000000000016C6160016C6160016C6160013B213000457
      040004570400045704000457040004570400045704000A7F0A000C890C000457
      04000457040004570400045704000457040014B9140016C6160016C6160016C6
      160016C61600E9F6E90000000000000000000000000000000000E9FBFB000000
      000000000000000000000000000000E8E80000E8E80000E8E80000D1D1000067
      670000676700006767000067670000676700006767000096960000E8E80000E8
      E80000D8D8000057570000C8C80000E8E80000E8E80000E8E80000E8E80000E8
      E80000E8E800E9FBFB0000000000000000000000000000000000E9E9FE000000
      00000000000000000000000000000000F8000000F8000000F8000000E0000000
      6F0000006F0000006F0000006F0000006F0000006F0000008B0000006F000000
      6F0000006F0000006F0000006F0000006F000000CB000000F8000000F8000000
      F8000000F800E9E9FE0000000000000000000000000000000000FAF8FA000000
      0000000000000000000000000000DB55DB00DB55DB00DB55DB00DB55DB00DB55
      DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55
      DB00DB55DB00DB55DB00D653D600DB55DB00DB55DB00DB55DB00DB55DB00DB55
      DB00DB55DB00F9EBF90000000000000000000000000000000000E9F6E9000000
      000000000000000000000000000016C6160016C6160016C6160016C6160016C6
      160016C6160016C6160016C6160016C6160016C6160016C6160016C6160016C6
      160016C6160016C6160016C6160016C6160016C6160016C6160016C6160016C6
      160016C61600E9F6E90000000000000000000000000000000000E9FBFB000000
      000000000000000000000000000000E8E80000E8E80000E8E80000E8E80000E8
      E80000E8E80000E8E80000E8E80000E8E80000E8E80000E8E80000E8E80000E8
      E80000E8E80000E6E60000E8E80000E8E80000E8E80000E8E80000E8E80000E8
      E80000E8E800E9FBFB0000000000000000000000000000000000E9E9FE000000
      00000000000000000000000000000000F8000000F8000000F8000000F8000000
      F8000000F8000000F8000000F8000000F8000000F8000000F8000000F8000000
      F8000000F8000000F8000000F8000000F8000000F8000000F8000000F8000000
      F8000000F800E9E9FE0000000000000000000000000000000000FAF8FA000000
      0000000000000000000017041700DB55DB00DD66DD00E7A5E700EEC2EE00F0CA
      F000EDC1ED00E8A8E800DF75DF00DB55DB00DB55DB00DB55DB00DB55DB00DB55
      DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55
      DB00DB55DB00F9EBF90000000000000000000000000000000000E9F6E9000000
      000000000000000000000000000016C6160042C9420099DA9900BBE5BB00C5E8
      C500BAE4BA009CDB9C005ACC5A0016C6160016C6160016C6160016C6160016C6
      160016C6160016C6160016C6160016C6160016C6160016C6160016C6160016C6
      160016C61600E9F6E90000000000000000000000000000000000E9FBFB000000
      000000000000000000000000000000E8E8003DE9E90098F0F000BBF4F400C4F5
      F500B9F4F4009BF0F00056EAEA0000E8E80000E8E80000E8E80000E8E80000E8
      E80000E8E80000E8E80000E8E80000E8E80000E8E80000E8E80000E8E80000E8
      E80000E8E800E9FBFB0000000000000000000000000000000000E9E9FE000000
      00000000000000000000000000000000F8003D3DF8009898FA00BBBBFB00C4C4
      FC00B9B9FB009B9BFA005656F9000000F8000000F8000000F8000000F8000000
      F8000000F8000000F8000000F8000000F8000000F8000000F8000000F8000000
      F8000000F800E9E9FE0000000000000000000000000000000000FAF8FA000000
      0000000000000000000000000000EEC4EE00FDF9FD0000000000000000000000
      0000000000000000000000000000F8E8F800ECBBEC00DF75DF00DB55DB00DB55
      DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55
      DB00DB55DB00F9EBF90000000000000000000000000000000000E9F6E9000000
      0000000000000000000000000000BDE5BD00F9FCF90000000000000000000000
      0000000000000000000000000000E6F4E600B3E2B3005ACC5A0016C6160016C6
      160016C6160016C6160016C6160016C6160016C6160016C6160016C6160016C6
      160016C61600E9F6E90000000000000000000000000000000000E9FBFB000000
      0000000000000000000000000000BDF4F400F9FEFE0000000000000000000000
      0000000000000000000000000000E6FAFA00B2F3F30056EAEA0000E8E80000E8
      E80000E8E80000E8E80000E8E80000E8E80000E8E80000E8E80000E8E80000E8
      E80000E8E800E9FBFB0000000000000000000000000000000000E9E9FE000000
      0000000000000000000000000000BDBDFC00F9F9FF0000000000000000000000
      0000000000000000000000000000E6E6FE00B2B2FB005656F9000000F8000000
      F8000000F8000000F8000000F8000000F8000000F8000000F8000000F8000000
      F8000000F800E9E9FE0000000000000000000000000000000000F6F4F6007373
      7300000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FEFDFE00F5DDF500E8A8
      E800DD64DD00DB55DB00DB55DB00DB55DB00DB55DB00DB55DB00DB55DB00DD64
      DD00EDC0ED00FEFDFE0000000000000000000000000000000000E9F6E9000000
      00000000000000000000ABDFAB00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FDFEFD00D9EFD9009CDB
      9C003DC93D0016C6160016C6160016C6160016C6160016C6160016C616003DC9
      3D00B9E4B900FCFEFC0000000000000000000000000000000000E9FBFB000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FDFFFF00D9F8F8009BF0
      F00038E9E90000E8E80000E8E80000E8E80000E8E80000E8E80000E8E80038E9
      E900B8F3F300FCFEFE0000000000000000000000000000000000E9E9FE000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FDFDFF00D9D9FD009B9B
      FA003838F8000000F8000000F8000000F8000000F8000000F8000000F8003838
      F800B8B8FB00FCFCFF000000000000000000000000000000000000000000E8E8
      E800000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FEFBFE00F5DEF500EDC1ED00E8AAE800E7A5E700EAB2EA00F2D2F200FDF8
      FD00000000000000000000000000000000000000000000000000F9FCF9000000
      00000000000000000000DDF1DD00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FBFDFB00DAF0DA00BAE4BA00A0DCA00099DA9900A9DFA900CDEBCD00F7FC
      F700000000000000000000000000000000000000000000000000F9FEFE000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FBFEFE00DAF8F800B9F4F4009FF0F00098F0F000A8F1F100CDF6F600F7FD
      FD00000000000000000000000000000000000000000000000000F9F9FF000000
      00000000000000000000DCDCFD00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FBFBFF00DADAFD00B9B9FB009F9FFA009898FA00A8A8FB00CDCDFC00F7F7
      FF0000000000000000000000000000000000424D3E000000000000003E000000
      2800000080000000400000000100010000000000000400000000000000000000
      000000000000000000000000FFFFFF00FFC7FFBFFFFFFFFF0000000000000000
      FF871E0FFF8000FF0000000000000000FF871C07FF00007F0000000000000000
      FF871C47FE00003F0000000000000000FF0F1C47FC00001F0000000000000000
      FF0F0007F800000F0000000000000000FF1F020FF00000070000000000000000
      FE1F020FE00000070000000000000000FE1F1C07C00000030000000000000000
      FE3F1C07800000010000000000000000FC03000F800000010000000000000000
      FC01000F800000010000000000000000F8007801800000010000000000000000
      F8000000800000010000000000000000F8000000800000010000000000000000
      F0000060800000010000000000000000F000F0E0800000010000000000000000
      F000E0E0800000010000000000000000E011E000800000010000000000000000
      E01C0000800000010000000000000000E0380C08800000010000000000000000
      C0380C18800000010000000000000000C0381C18800000010000000000000000
      80001800800000010000000000000000800001C0C00000030000000000000000
      000403C0E00000070000000000000000000F8200F000000F0000000000000000
      000F8000FC00001F000000000000000088078000FE00003F0000000000000000
      FE000000FF00007F0000000000000000FF0003E0FF8000FF0000000000000000
      FFE00FF8FFFFFFFF0000000000000000C1FFFFFFC1FFFFFFC1FFFFFFC1FFFFFF
      C1FFFFFFC1FFFFFFC1FFFFFFC1FFFFFFC1FFFFFFC1FFFFFFC1FFFFFFC1FFFFFF
      C1FFFFFFC1FFFFFFC1FFFFFFC1FFFFFFE1FFFFFFC1FFFFFFC1FFFFFFC1FFFFFF
      E1FFFFFFC1FFFFFFC1FFFFFFC1FFFFFFC1FFFFFFC1FFFFFFC1FFFFFFC1FFFFFF
      C1FFFFFFC1FFFFFFC1FFFFFFC1FFFFFFC1FFFFFFC1FFFFFFC1FFFFFFC1FFFFFF
      C183FFFFC183FFFFC183FFFFC183FFFFC0007FFFC0007FFFC0007FFFC0007FFF
      C0000FF3C0000FF3C0000FF3C0000FF3C0000003C0000003C0000003C0000003
      C0000003C0000003C0000003C0000003C0000003C0000003C0000003C0000003
      C0000003C0000003C0000003C0000003C0000003C0000003C0000003C0000003
      C0000003C0000003C0000003C0000003C0000003C0000003C0000003C0000003
      C0000003C0000003C0000003C0000003E0000003C0000003C0000003C0000003
      E0000003C0000003C0000003C0000003C0000003C0000003C0000003C0000003
      E0000003C0000003C0000003C0000003E0000003C0000003C0000003C0000003
      E0000003C0000003C0000003C0000003C0000003C0000003C0000003C0000003
      C0000003C0000003C0000003C0000003C0000003C0000003C0000003C0000003
      C07E0003C07E0003C07E0003C07E0003C1FF8003C1FF8003C1FF8003C1FF8003
      E1FFF00FC1FFF00FC1FFF00FC1FFF00F00000000000000000000000000000000
      000000000000}
  end
  object FileOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoOverWritePrompt, fdoDefaultNoMiniMode]
    Left = 792
    Top = 16
  end
  object ImageListPassingStates: TImageList
    Left = 504
    Bitmap = {
      494C010105000800040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000002000000001002000000000000020
      0000000000000000000000000000000000007F7F7FFF7F7F7FFF7F7F7FFF7F7F
      7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F
      7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007F7F7FFF7F7F7FFF7F7F7FFF7F7F
      7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F
      7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007F7F7FFF7F7F7FFF7F7F7FFF7F7F
      7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F
      7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007F7F7FFF7F7F7FFF7F7F7FFF0000
      00FF000000FF000000FF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF000000FF0000
      00FF000000FF7F7F7FFF7F7F7FFF7F7F7FFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007F7F7FFF7F7F7FFF7F7F7FFF0000
      00FF000000FF000000FF000000FF7F7F7FFF7F7F7FFF000000FF000000FF0000
      00FF000000FF7F7F7FFF7F7F7FFF7F7F7FFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007F7F7FFF7F7F7FFF7F7F7FFF0000
      00FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000
      00FF000000FF7F7F7FFF7F7F7FFF7F7F7FFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007F7F7FFF7F7F7FFF7F7F7FFF7F7F
      7FFF000000FF000000FF000000FF000000FF000000FF000000FF000000FF7F7F
      7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007F7F7FFF7F7F7FFF7F7F7FFF7F7F
      7FFF7F7F7FFF000000FF000000FF000000FF000000FF000000FF7F7F7FFF7F7F
      7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007F7F7FFF7F7F7FFF7F7F7FFF7F7F
      7FFF7F7F7FFF000000FF000000FF000000FF000000FF000000FF000000FF7F7F
      7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007F7F7FFF7F7F7FFF7F7F7FFF0000
      00FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000
      00FF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007F7F7FFF7F7F7FFF000000FF0000
      00FF000000FF000000FF000000FF7F7F7FFF000000FF000000FF000000FF0000
      00FF000000FF7F7F7FFF7F7F7FFF7F7F7FFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007F7F7FFF7F7F7FFF000000FF0000
      00FF000000FF000000FF7F7F7FFF7F7F7FFF7F7F7FFF000000FF000000FF0000
      00FF000000FF7F7F7FFF7F7F7FFF7F7F7FFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007F7F7FFF7F7F7FFF7F7F7FFF0000
      00FF000000FF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF000000FF0000
      00FF000000FF7F7F7FFF7F7F7FFF7F7F7FFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007F7F7FFF7F7F7FFF7F7F7FFF7F7F
      7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F
      7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007F7F7FFF7F7F7FFF7F7F7FFF7F7F
      7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F
      7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007F7F7FFF7F7F7FFF7F7F7FFF7F7F
      7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F
      7FFF7F7F7FFF7F7F7FFF7F7F7FFF7F7F7FFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000439B1EFF439B1EFF439B1EFF439B
      1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B
      1EFF439B1EFF439B1EFF439B1EFF439B1EFF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF0EC9FFFF0EC9FFFF0EC9FFFF0EC9
      FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9
      FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF439B1EFF439B1EFF439B1EFF439B
      1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B
      1EFF439B1EFF439B1EFF439B1EFF439B1EFF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF0EC9FFFF0EC9FFFF0EC9FFFF0EC9
      FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9
      FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF439B1EFF439B1EFF439B1EFF439B
      1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B
      1EFF439B1EFF439B1EFF439B1EFF439B1EFF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF0EC9FFFF0EC9FFFF0EC9FFFF0EC9
      FFFF241CEDFF241CEDFF241CEDFF241CEDFF241CEDFF241CEDFF241CEDFF241C
      EDFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF439B1EFF439B1EFF439B1EFF439B
      1EFF439B1EFF439B1EFFFFFFFFFFFFFFFFFFFFFFFFFF439B1EFF439B1EFF439B
      1EFF439B1EFF439B1EFF439B1EFF439B1EFF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FFFFFFFFFF1DE6B5FF1DE6B5FF1DE6
      B5FFFFFFFFFF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF0000
      00FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000
      00FF000000FF000000FF1DE6B5FF1DE6B5FF0EC9FFFF0EC9FFFF0EC9FFFF0EC9
      FFFF241CEDFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF241C
      EDFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF439B1EFF439B1EFF439B1EFF439B
      1EFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF439B1EFF439B
      1EFF439B1EFF439B1EFF439B1EFF439B1EFF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FFFFFFFFFFFFFFFFFF1DE6B5FF1DE6
      B5FFFFFFFFFF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF000000FF000000FF000000FF000000FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF0EC9FFFF0EC9FFFF0EC9FFFF0EC9
      FFFF241CEDFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF241C
      EDFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF439B1EFF439B1EFF439B1EFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF439B1EFF439B
      1EFF439B1EFF439B1EFF439B1EFF439B1EFF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FFFFFFFFFFFFFFFFFF1DE6
      B5FFFFFFFFFF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF000000FF000000FF1DE6B5FF000000FF000000FF000000FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF0EC9FFFF241CEDFF241CEDFF0EC9
      FFFF241CEDFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF241C
      EDFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF439B1EFF439B1EFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF439B
      1EFF439B1EFF439B1EFF439B1EFF439B1EFF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FFFFFFFFFFFFFF
      FFFFFFFFFFFF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF000000FF000000FF1DE6B5FF1DE6B5FF000000FF1DE6B5FF000000FF0000
      00FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF0EC9FFFF0EC9FFFF0EC9FFFF241C
      EDFF241CEDFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF241C
      EDFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF439B1EFF439B1EFF439B1EFFFFFF
      FFFFFFFFFFFF439B1EFF439B1EFF439B1EFFFFFFFFFFFFFFFFFFFFFFFFFF439B
      1EFF439B1EFF439B1EFF439B1EFF439B1EFF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FFFFFF
      FFFFFFFFFFFF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF0000
      00FF000000FF1DE6B5FF1DE6B5FF1DE6B5FF000000FF1DE6B5FF1DE6B5FF0000
      00FF000000FF1DE6B5FF1DE6B5FF1DE6B5FF0EC9FFFF0EC9FFFF0EC9FFFF0EC9
      FFFF241CEDFF241CEDFF241CEDFF241CEDFF0EC9FFFF0EC9FFFF0EC9FFFF241C
      EDFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF439B1EFF439B1EFF439B1EFF439B
      1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B1EFFFFFFFFFFFFFFFFFFFFFF
      FFFF439B1EFF439B1EFF439B1EFF439B1EFF1DE6B5FF1DE6B5FF1DE6B5FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF000000FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF0EC9FFFF0EC9FFFF0EC9FFFF0EC9
      FFFF241CEDFF0EC9FFFF0EC9FFFF0EC9FFFF241CEDFF241CEDFF0EC9FFFF241C
      EDFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF439B1EFF439B1EFF439B1EFF439B
      1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B1EFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFF439B1EFF439B1EFF439B1EFF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FFFFFFFFFFFFFF
      FFFFFFFFFFFF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF000000FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF0EC9FFFF0EC9FFFF0EC9FFFF0EC9
      FFFF241CEDFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF241CEDFF241C
      EDFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF439B1EFF439B1EFF439B1EFF439B
      1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B1EFFFFFFFFFFFFFF
      FFFFFFFFFFFF439B1EFF439B1EFF439B1EFF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FFFFFFFFFFFFFFFFFF1DE6
      B5FFFFFFFFFF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF000000FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF0EC9FFFF0EC9FFFF0EC9FFFF0EC9
      FFFF241CEDFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF241C
      EDFF241CEDFF241CEDFF0EC9FFFF0EC9FFFF439B1EFF439B1EFF439B1EFF439B
      1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B1EFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFF439B1EFF439B1EFF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FFFFFFFFFFFFFFFFFF1DE6B5FF1DE6
      B5FFFFFFFFFF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF000000FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF0EC9FFFF0EC9FFFF0EC9FFFF0EC9
      FFFF241CEDFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF241C
      EDFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF439B1EFF439B1EFF439B1EFF439B
      1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B1EFFFFFF
      FFFFFFFFFFFFFFFFFFFF439B1EFF439B1EFF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FFFFFFFFFF1DE6B5FF1DE6B5FF1DE6
      B5FFFFFFFFFF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF000000FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF0EC9FFFF0EC9FFFF0EC9FFFF0EC9
      FFFF241CEDFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF241C
      EDFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF439B1EFF439B1EFF439B1EFF439B
      1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B
      1EFFFFFFFFFF439B1EFF439B1EFF439B1EFF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FFFFFFFFFF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF0EC9FFFF0EC9FFFF0EC9FFFF0EC9
      FFFF241CEDFF241CEDFF241CEDFF241CEDFF241CEDFF241CEDFF241CEDFF241C
      EDFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF439B1EFF439B1EFF439B1EFF439B
      1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B
      1EFF439B1EFF439B1EFF439B1EFF439B1EFF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF0EC9FFFF0EC9FFFF0EC9FFFF0EC9
      FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9
      FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF439B1EFF439B1EFF439B1EFF439B
      1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B1EFF439B
      1EFF439B1EFF439B1EFF439B1EFF439B1EFF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6
      B5FF1DE6B5FF1DE6B5FF1DE6B5FF1DE6B5FF0EC9FFFF0EC9FFFF0EC9FFFF0EC9
      FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9
      FFFF0EC9FFFF0EC9FFFF0EC9FFFF0EC9FFFF424D3E000000000000003E000000
      2800000040000000200000000100010000000000000100000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
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
end
