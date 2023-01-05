unit uSmartDecoderWatchdogForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Data.SqlExpr, Data.DbxSqlite,
  StrUtils, DateUtils,
  Data.FMTBcd, Datasnap.DBClient, Datasnap.Provider, Vcl.Grids, Vcl.DBGrids,
  Vcl.ComCtrls, Vcl.Menus, AdvMenus, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.WinXPickers,
  SmartTiming.DecoderEngine, SmartTIming.DecoderInterface;

type
  TFormMain = class(TForm)
    PanelMain: TPanel;
    PanelStatus: TPanel;
    PanelDecoder: TPanel;
    LabelDecoderIpAddress: TLabel;
    LabelDecoderId: TLabel;
    LabelDecoderTemperature: TLabel;
    LabelDecoderNoiseLevel: TLabel;
    procedure FormCreate(Sender: TObject);

  private
    FCurrentFileSize: Integer;
    FMaxFileSize: Integer;
    FFileName: TFileName;
    procedure CreateLogFile(var aFileVar: TextFile);
    procedure Log(const Message: string);
    procedure HandleFileSizeOverflow;

  protected
    procedure OnStatusReceived(AStatus: TMyLapsP3Status);

  public
    { Public-Deklarationen }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

const
  CRLF = #13#10;

{==============================================================================}
procedure TFormMain.FormCreate(Sender: TObject);
var
  lDecoderEngine: TMyLapsDecoderEngine;
begin
  lDecoderEngine := TMyLapsDecoderEngine.GetSingleton;
  lDecoderEngine.NewStatusReceived := OnStatusReceived;
  FFileName := '.\TemperatureLog.log';
  FMaxFileSize := 100000;
//  lDecoderEngine.RefreshDecoderList;
end;

{==============================================================================}
procedure TFormMain.OnStatusReceived(AStatus: TMyLapsP3Status);
var
  lMessage: string;
begin
  try
    LabelDecoderNoiseLevel.Caption := 'Störungslevel: ' + AStatus.Noise.ToString;
    LabelDecoderTemperature.Caption := 'Temperatur: ' + AStatus.Temperature.ToString;
    lMessage := FormatDatetime('yyyy-mm-dd hh:mm:ss', Now) + ': Noise: ' + AStatus.Noise.ToString + ' Temperatur: ' + AStatus.Temperature.ToString + '° C' +CRLF;
    Log(lMessage);
  except
    on E: Exception do
      ShowMessage(E.Message);
  end;
end;

{==============================================================================}
procedure TFormMain.CreateLogFile(var aFileVar: TextFile);
// Prüft, ob die Datei schon existiert und erzeugt sie gegebenenfalls.
var
  lLastBackSlash: Integer;
  lFilePath: string;
begin
  try
    // Letzten Backslash im Dateinamen/-Pfad ermitteln.
    lLastBackSlash := AnsiPos('\', AnsiReverseString(FFileName));
    lLastBackSlash := Length(FFileName) - lLastBackSlash;

    // Prüfen, ob FFileName eine Pfad enthält oder nur einen Dateinamen
    if lLastBackSlash <> 0 then
    begin
      lFilePath := AnsiLeftStr(FFileName, lLastBackSlash);

      // Wenn der Pfad / das Verzeichnis nicht existiert, erzeugen.
      if not DirectoryExists(lFilePath) then
        MkDir(lFilePath);
    end;
    System.Rewrite(aFileVar);
  except
    ; // Fehler im Logger nicht protokollieren
  end;
end;

{==============================================================================}
{ TLogFileAppender.DoAppend }
{==============================================================================}
procedure TFormMain.Log(const Message: string);
var
  lFileVar : TextFile;
begin
  try
    if Trim(Message) <> '' then
    begin
      AssignFile(lFileVar, FFileName);
      try
        if FileExists(FFileName) then
        begin
          System.Append(lFileVar);
          if FCurrentFileSize = 0 then
            FCurrentFileSize := System.FileSize(lFileVar);
        end
        else
          CreateLogFile(lFileVar);
        System.Write(lFileVar, Message);
        System.Flush(lFileVar);  // Sicherstellen, daß AText tatsächlich in die Datei geschrieben wird.
      finally
        CloseFile(lFileVar);
      end;
      inc(FCurrentFileSize, length(Message));

      // Größe der Logdatei mit der maximal zulässigen Größe vergleichen. Angabe in
      // MaxFileSize ist in KB, während Size in Byte ist. Deshalb wird MaxFileSize
      // hier mal 2 hoch 10 genommen.
      if  (FCurrentFileSize > FMaxFileSize) and (FMaxFileSize > 0) then
        HandleFileSizeOverflow;
    end;
  except
    ; // Fehler im Logger nicht protokollieren
  end;
end;

procedure TFormMain.HandleFileSizeOverflow;
// Summary: Kopiert die Meldungen aus FStream und fügt sie in eine neue Datei
// ein, lässt dabei aber die 10% der meldungen weg (die ältesten). Die neue
// Datei wird dann als Logdatei weiterverwendet, die alte Datei wird gelöscht.
var
  lBytesToKeep: Integer;
  lOldFile: TStream;
  lNewFile: TStream;
begin
  // Wir wollen die ältesten 10% der Meldungen wegwerfen und die übrigen 90%
  // behalten.
  lBytesToKeep := (FMaxFileSize div 10) * 9;

  // Den aktuellen FStream schließen und die Datei in *.bkp umbenennen.
  RenameFile(FFileName, FFileName + '.bkp');

  // Die umbenannte, alte Logdatei wieder öffnen.
  lOldFile := TFileStream.Create(FFileName + '.bkp', fmOpenRead or fmShareDenyNone);
  try
    // Einen neuen FStream für den Appender erstellen
    lNewFile := TFileStream.Create(FFileName, fmCreate or fmShareDenyNone);
    try
      // In der alten Logdatei bis an die Stelle spulen, von der ab die Meldungen
      // übernommen werden sollen.
      lOldFile.Seek(-1 * lBytesToKeep, soFromEnd);

      // Die Meldungen aus der alten Logdatei in die neue übernehmen.
      lNewFile.CopyFrom(lOldFile, lBytesToKeep);
    finally
      lNewFile.Free;
    end;
  finally
    // Alte Logdatei schließen und löschen.
    FreeAndNil(lOldFile);
    DeleteFile(FFileName + '.bkp');
  end;
end;


end.
