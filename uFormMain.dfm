object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'SmartTiming'
  ClientHeight = 904
  ClientWidth = 1073
  Color = clBackground
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object PanelTitle: TPanel
    AlignWithMargins = True
    Left = 0
    Top = 0
    Width = 1073
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
    ExplicitWidth = 1386
    DesignSize = (
      1069
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
      Left = 982
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
    Width = 1073
    Height = 796
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 1
    ExplicitWidth = 1386
    object PageControlMain: TPageControl
      AlignWithMargins = True
      Left = 0
      Top = 6
      Width = 1073
      Height = 784
      Margins.Left = 0
      Margins.Top = 6
      Margins.Right = 0
      Margins.Bottom = 6
      ActivePage = TabSheetEvent
      Align = alClient
      TabHeight = 30
      TabOrder = 0
      StyleElements = [seFont, seClient]
      ExplicitWidth = 1386
      object TabSheetEvent: TTabSheet
        Caption = 'Veranstaltung'
        object PanelEventInfo: TPanel
          Left = 0
          Top = 0
          Width = 1065
          Height = 121
          Align = alTop
          BevelKind = bkFlat
          BevelOuter = bvNone
          TabOrder = 0
          ExplicitWidth = 1378
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
          object ButtonSaveEvent: TButton
            Left = 28
            Top = 80
            Width = 75
            Height = 25
            Caption = 'Speichern'
            TabOrder = 3
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
            TabOrder = 4
          end
        end
        object PanelEventDetails: TPanel
          AlignWithMargins = True
          Left = 0
          Top = 126
          Width = 1065
          Height = 339
          Margins.Left = 0
          Margins.Top = 5
          Margins.Right = 0
          Margins.Bottom = 0
          Align = alTop
          BevelKind = bkFlat
          BevelOuter = bvNone
          TabOrder = 1
          ExplicitLeft = 48
          ExplicitTop = 142
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
            Width = 1061
            Height = 296
            Margins.Left = 0
            Margins.Top = 5
            Margins.Right = 0
            Margins.Bottom = 0
            Align = alBottom
            BevelKind = bkFlat
            BevelOuter = bvNone
            TabOrder = 0
          end
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
          Left = 552
          Top = 0
          Height = 744
          Align = alRight
          Color = clBlack
          ParentColor = False
          OnCanResize = Splitter2CanResize
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
          object ListBox1: TListBox
            Left = 0
            Top = 0
            Width = 185
            Height = 744
            Align = alClient
            ItemHeight = 15
            Items.Strings = (
              '1 - U15 m/w'
              '2 - U13 m/w')
            TabOrder = 0
          end
        end
        object PanelPassings: TPanel
          Left = 188
          Top = 0
          Width = 364
          Height = 744
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          ExplicitWidth = 677
          object PanelRaceControls: TPanel
            Left = 0
            Top = 0
            Width = 364
            Height = 41
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 0
            ExplicitWidth = 677
          end
          object PanelPassingGrid: TPanel
            Left = 0
            Top = 41
            Width = 364
            Height = 703
            Align = alClient
            BevelOuter = bvNone
            TabOrder = 1
            ExplicitWidth = 677
          end
        end
        object PanelStandings: TPanel
          Left = 555
          Top = 0
          Width = 510
          Height = 744
          Align = alRight
          TabOrder = 2
          ExplicitLeft = 924
          ExplicitTop = -3
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
    Width = 1073
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
    ExplicitWidth = 1386
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
    Left = 720
    Top = 3
    object Datei1: TMenuItem
      Caption = 'Datei'
    end
    object ools1: TMenuItem
      Caption = 'Tools'
      object MenuItemTxMapping: TMenuItem
        Caption = #220'bersetzungstabelle ...'
        object MenuItemTxMappingImport: TMenuItem
          Caption = 'Importieren'
          Enabled = False
        end
        object MenuItemTxMappingExport: TMenuItem
          Caption = 'Exportieren'
          Enabled = False
        end
        object MenuItemTxMappingGenerate: TMenuItem
          Caption = 'Generieren'
          Enabled = False
        end
        object MenuItemTxMappingEdit: TMenuItem
          Caption = 'Editieren'
          Enabled = False
        end
      end
      object MenuItemSimulatePassings: TMenuItem
        Caption = 'Simulator'
        Enabled = False
      end
    end
  end
end
