object MainDataModule: TMainDataModule
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
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
    Left = 103
    Top = 113
  end
  object SQLDataSetCompetitors: TSQLDataSet
    CommandText = 'SELECT * FROM COMPETITORS WHERE 1=2'
    MaxBlobSize = 1
    Params = <>
    SQLConnection = SQLConnection
    Left = 311
    Top = 88
  end
  object DataSourceCompetitors: TDataSource
    Left = 313
    Top = 336
  end
  object DataSetProviderCompetitors: TDataSetProvider
    DataSet = SQLDataSetCompetitors
    Left = 313
    Top = 160
  end
  object ClientDataSetCompetitors: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DataSetProviderCompetitors'
    Left = 313
    Top = 240
  end
  object SQLDataSetRaces: TSQLDataSet
    CommandText = 'SELECT * FROM RACES'
    DataSource = DataSourceRaces
    MaxBlobSize = -1
    Params = <>
    SQLConnection = SQLConnection
    Left = 73
    Top = 316
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
    Left = 70
    Top = 443
  end
  object DataSourceRaces: TDataSource
    DataSet = ClientDataSetRaces
    Left = 75
    Top = 504
  end
  object DataSourceResults: TDataSource
    Left = 650
    Top = 390
  end
end
