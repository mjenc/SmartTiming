object ReportDesigner: TReportDesigner
  Left = 0
  Top = 0
  Caption = 'Druckvorlagen'
  ClientHeight = 854
  ClientWidth = 1210
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object frxPreview1: TfrxPreview
    Left = 344
    Top = 8
    Width = 858
    Height = 817
    OutlineVisible = False
    OutlineWidth = 120
    ThumbnailVisible = False
    FindFmVisible = False
    UseReportHints = True
    OutlineTreeSortType = dtsUnsorted
    HideScrolls = False
  end
  object Button1: TButton
    Left = 64
    Top = 280
    Width = 75
    Height = 25
    Caption = 'Design'
    TabOrder = 1
    OnClick = Button1Click
  end
  object FRReport: TfrxReport
    Version = '2022.2.7'
    DataSet = FRDBDataset
    DataSetName = 'frxDBDataset1'
    DotMatrixReport = False
    IniFile = '\Software\Fast Reports'
    Preview = frxPreview1
    PreviewOptions.Buttons = [pbPrint, pbLoad, pbSave, pbExport, pbZoom, pbFind, pbOutline, pbPageSetup, pbTools, pbEdit, pbNavigator, pbExportQuick, pbCopy, pbSelection]
    PreviewOptions.Zoom = 1.000000000000000000
    PrintOptions.Printer = 'Default'
    PrintOptions.PrintOnSheet = 0
    ReportOptions.CreateDate = 45275.331741944440000000
    ReportOptions.LastChange = 45275.331741944440000000
    ScriptLanguage = 'PascalScript'
    ScriptText.Strings = (
      'begin'
      ''
      'end.')
    Left = 40
    Top = 48
    Datasets = <>
    Variables = <>
    Style = <>
  end
  object FRDBDataset: TfrxDBDataset
    UserName = 'frxDBDataset1'
    CloseDataSource = False
    BCDToCurrency = False
    DataSetOptions = []
    Left = 48
    Top = 144
  end
end
