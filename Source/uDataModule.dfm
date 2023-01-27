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
end
