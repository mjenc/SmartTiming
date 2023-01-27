object FormSettings: TFormSettings
  Left = 0
  Top = 0
  Caption = 'Einstellungen'
  ClientHeight = 457
  ClientWidth = 628
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
    Top = 416
    Width = 628
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitTop = 408
    ExplicitWidth = 626
    DesignSize = (
      628
      41)
    object ButtonOK: TButton
      Left = 454
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      ModalResult = 1
      TabOrder = 0
      OnClick = ButtonOKClick
      ExplicitLeft = 452
    end
    object ButtonCancel: TButton
      Left = 542
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Abbrechen'
      ModalResult = 2
      TabOrder = 1
      ExplicitLeft = 540
    end
  end
  object PanelMain: TPanel
    Left = 0
    Top = 0
    Width = 628
    Height = 416
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitWidth = 626
    ExplicitHeight = 408
    object PageControlSettings: TPageControl
      AlignWithMargins = True
      Left = 5
      Top = 5
      Width = 618
      Height = 406
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      ActivePage = TabSheetCommon
      Align = alClient
      TabOrder = 0
      ExplicitWidth = 616
      ExplicitHeight = 398
      object TabSheetCommon: TTabSheet
        Caption = 'Allgemein'
        object Label2: TLabel
          Left = 24
          Top = 59
          Width = 64
          Height = 15
          Caption = 'Farbschema'
        end
        object CheckBoxPassingBeep: TCheckBox
          Left = 24
          Top = 24
          Width = 193
          Height = 17
          Alignment = taLeftJustify
          Caption = 'Akustisches Signal bei Passage'
          Checked = True
          State = cbChecked
          TabOrder = 0
        end
        object ComboBoxStyle: TComboBox
          Left = 200
          Top = 47
          Width = 193
          Height = 23
          TabOrder = 1
          OnChange = ComboBoxStyleChange
        end
      end
      object TabSheetCompetitorImport: TTabSheet
        Caption = 'Teilnehmerimport'
        ImageIndex = 1
      end
      object TabSheetFieldTitles: TTabSheet
        Caption = 'Spaltentitel'
        ImageIndex = 2
        DesignSize = (
          610
          376)
        object Label1: TLabel
          Left = 24
          Top = 16
          Width = 39
          Height = 15
          Caption = 'Bereich'
        end
        object ComboBoxTable: TComboBox
          Left = 69
          Top = 16
          Width = 228
          Height = 23
          TabOrder = 0
          Items.Strings = (
            'Veranstaltung'
            'Teilnehmer'
            'Team'
            'Rennen'
            'Ergebnis'
            'Transponder'
            'Teilnahme'
            'Passage')
        end
        object DBGridDictionary: TDBGrid
          Left = 16
          Top = 56
          Width = 573
          Height = 297
          Anchors = [akLeft, akTop, akRight, akBottom]
          DataSource = DataSourceDictionary
          TabOrder = 1
          TitleFont.Charset = DEFAULT_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -12
          TitleFont.Name = 'Segoe UI'
          TitleFont.Style = []
        end
      end
    end
  end
  object ClientDataSetDictionary: TClientDataSet
    Aggregates = <>
    DisableStringTrim = True
    FieldDefs = <
      item
        Name = 'COMPETITORID'
        Attributes = [faRequired]
        DataType = ftLargeint
      end
      item
        Name = 'CLASS'
        DataType = ftWideString
        Size = 30
      end
      item
        Name = 'BIB'
        DataType = ftLargeint
      end
      item
        Name = 'FIRSTNAME'
        DataType = ftWideString
        Size = 50
      end
      item
        Name = 'LASTNAME'
        DataType = ftWideString
        Size = 50
      end
      item
        Name = 'CLUB'
        DataType = ftWideString
        Size = 50
      end
      item
        Name = 'TEAM'
        DataType = ftWideMemo
      end
      item
        Name = 'NATIONALITY'
        DataType = ftWideString
        Size = 50
      end
      item
        Name = 'NATIONALITYISO'
        DataType = ftWideString
        Size = 3
      end
      item
        Name = 'UCIID'
        DataType = ftWideString
        Size = 10
      end
      item
        Name = 'HANDICAPFACTOR'
        DataType = ftFloat
      end
      item
        Name = 'ADDITIONAL1'
        DataType = ftWideMemo
      end
      item
        Name = 'ADDITIONAL2'
        DataType = ftWideMemo
      end
      item
        Name = 'ADDITIONAL3'
        DataType = ftWideMemo
      end
      item
        Name = 'TRANSPONDERID'
        DataType = ftLargeint
      end>
    IndexDefs = <>
    Params = <>
    ProviderName = 'DataSetProviderDictionary'
    ReadOnly = True
    StoreDefs = True
    Left = 423
    Top = 153
  end
  object DataSetProviderDictionary: TDataSetProvider
    DataSet = SQLQueryDictionary
    ResolveToDataSet = True
    Exported = False
    Options = [poReadOnly, poDisableInserts, poDisableEdits, poDisableDeletes, poAutoRefresh, poUseQuoteChar]
    Left = 261
    Top = 149
  end
  object SQLQueryDictionary: TSQLQuery
    MaxBlobSize = -1
    Params = <>
    SQL.Strings = (
      'SELECT STARTTIME, TITLE, STATUS FROM RACES '
      'WHERE EVENTID = 0'
      'ORDER BY STARTTIME, RACEID')
    SQLConnection = MainDataModule.SQLConnection
    Left = 90
    Top = 146
  end
  object DataSourceDictionary: TDataSource
    AutoEdit = False
    DataSet = ClientDataSetDictionary
    Left = 409
    Top = 241
  end
end
