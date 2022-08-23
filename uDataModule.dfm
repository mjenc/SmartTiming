object DataModule1: TDataModule1
  Height = 750
  Width = 1000
  PixelsPerInch = 120
  object SQLConnection: TSQLConnection
    DriverName = 'Sqlite'
    LoginPrompt = False
    Params.Strings = (
      'DriverUnit=Data.DbxSqlite'
      
        'DriverPackageLoader=TDBXSqliteDriverLoader,DBXSqliteDriver280.bp' +
        'l'
      
        'MetaDataPackageLoader=TDBXSqliteMetaDataCommandFactory,DbxSqlite' +
        'Driver280.bpl'
      'FailIfMissing=True'
      'Database=d:\projects\SmartTiming\Data\SmartTiming.db')
    TableScope = [tsSynonym, tsSysTable, tsTable, tsView]
    Connected = True
    Left = 102
    Top = 112
  end
  object SQLDataSet1: TSQLDataSet
    MaxBlobSize = -1
    Params = <>
    SQLConnection = SQLConnection
    Left = 40
    Top = 235
  end
  object SQLQuery1: TSQLQuery
    MaxBlobSize = -1
    Params = <>
    SQLConnection = SQLConnection
    Left = 222
    Top = 230
  end
  object SQLTable1: TSQLTable
    Active = True
    MaxBlobSize = 1
    SQLConnection = SQLConnection
    TableName = 'COMPETITORS'
    Left = 136
    Top = 234
  end
  object DataSource1: TDataSource
    DataSet = ClientDataSet1
    Left = 84
    Top = 460
  end
  object DataSetProvider1: TDataSetProvider
    DataSet = SQLTable1
    ResolveToDataSet = True
    Exported = False
    Left = 91
    Top = 312
  end
  object ClientDataSet1: TClientDataSet
    Active = True
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
    ProviderName = 'DataSetProvider1'
    StoreDefs = True
    Left = 88
    Top = 393
  end
end
