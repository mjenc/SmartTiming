object MainDataModule: TMainDataModule
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 600
  Width = 800
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
    Left = 82
    Top = 90
  end
  object SQLDataSetCompetitors: TSQLDataSet
    CommandText = 'SELECT * FROM COMPETITORS WHERE 1=2'
    MaxBlobSize = 1
    Params = <>
    SQLConnection = SQLConnection
    Left = 249
    Top = 70
  end
  object DataSourceCompetitors: TDataSource
    Left = 250
    Top = 269
  end
  object DataSetProviderCompetitors: TDataSetProvider
    DataSet = SQLDataSetCompetitors
    Left = 250
    Top = 128
  end
  object ClientDataSetCompetitors: TClientDataSet
    Aggregates = <>
    Params = <>
    ProviderName = 'DataSetProviderCompetitors'
    Left = 250
    Top = 192
  end
  object SQLDataSetRaces: TSQLDataSet
    CommandText = 'SELECT * FROM RACES'
    DataSource = DataSourceRaces
    MaxBlobSize = -1
    Params = <>
    SQLConnection = SQLConnection
    Left = 58
    Top = 253
  end
  object DataSetProviderRaces: TDataSetProvider
    DataSet = SQLDataSetRaces
    Options = [poAutoRefresh, poUseQuoteChar]
    Left = 58
    Top = 302
  end
  object ClientDataSetRaces: TClientDataSet
    Aggregates = <>
    DisableStringTrim = True
    Params = <>
    ProviderName = 'DataSetProviderRaces'
    Left = 56
    Top = 354
  end
  object DataSourceRaces: TDataSource
    DataSet = ClientDataSetRaces
    Left = 60
    Top = 403
  end
  object DataSourceResults: TDataSource
    Left = 520
    Top = 312
  end
end
