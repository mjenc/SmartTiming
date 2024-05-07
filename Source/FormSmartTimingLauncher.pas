unit FormSmartTimingLauncher;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.MMSystem, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Imaging.jpeg, JclFileUtils,
  DataModule, SmartTiming.Tools, SmartTiming.Consts;

type
  TFormAppLauncher = class(TForm)
    ComboBoxEventHistory: TComboBox;
    Label1: TLabel;
    ButtonNew: TButton;
    ButtonLoad: TButton;
    ButtonNewWithTemplate: TButton;
    Image1: TImage;
    LabelVersion: TLabel;
    LabelCopyright: TLabel;
    ButtonFromBackup: TButton;
    FileOpenDialog: TFileOpenDialog;
    ButtonCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonLoadClick(Sender: TObject);
    procedure ButtonFromBackupClick(Sender: TObject);
    procedure ButtonNewClick(Sender: TObject);
    procedure ButtonNewWithTemplateClick(Sender: TObject);
  private
    FEventPath: string;
    FHistoryList: TStringList;

    function GetAppVersion: string;
    procedure LoadHistory;

  protected
    procedure CreateParams(var AParams: TCreateParams); override;
  public
    property EventPath: string read FEventPath;
  end;

var
  FormAppLauncher: TFormAppLauncher;

implementation

{$R *.dfm}

{==============================================================================}
procedure TFormAppLauncher.ButtonFromBackupClick(Sender: TObject);
begin
  if not FileOpenDialog.Execute then
    Exit;

  MainDataModule.RestoreDatabase(FileOpenDialog.FileName);
  ModalResult := mrOK;
end;

{==============================================================================}
procedure TFormAppLauncher.ButtonLoadClick(Sender: TObject);
begin
  if ComboBoxEventHistory.ItemIndex >= 0 then
  begin
    MainDataModule.OpenDatabase(FHistoryList.Names[ComboBoxEventHistory.ItemIndex]);
    ModalResult := mrOK;
  end;
end;

{==============================================================================}
procedure TFormAppLauncher.ButtonNewClick(Sender: TObject);
begin
  MainDataModule.CreateNewDatabase(gStdDataPath, cStdDatabaseName);
  ModalResult := mrOK;
end;

{==============================================================================}
procedure TFormAppLauncher.ButtonNewWithTemplateClick(Sender: TObject);
begin
  if ComboBoxEventHistory.ItemIndex >= 0 then
  begin
    MainDataModule.RestoreDatabase(FHistoryList.Names[ComboBoxEventHistory.ItemIndex]);
    ModalResult := mrOK;
  end;
end;

{==============================================================================}
procedure TFormAppLauncher.CreateParams(var AParams: TCreateParams);
begin
  inherited;
  AParams.ExStyle := AParams.ExStyle or WS_EX_APPWINDOW;
end;
{==============================================================================}
procedure TFormAppLauncher.FormCreate(Sender: TObject);
begin
  LabelCopyright.Caption := cCopyright;
  LabelVersion.Caption := GetAppVersion;
  FEventPath := gStdDataPath + cStdDatabaseName;

  FHistoryList := TStringList.Create;
  LoadHistory;
end;

{==============================================================================}
procedure TFormAppLauncher.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FHistoryList);
end;

{==============================================================================}
function TFormAppLauncher.GetAppVersion: string;
var
  lVerblock: PVSFIXEDFILEINFO;
  lVersionMS, lVersionLS: Cardinal;
  lVerLen: Cardinal;
  lResStream: TResourceStream;
  lMemStream: TMemoryStream;
  lP: Pointer;
  lPLen: Cardinal;
begin
  lMemStream := TMemoryStream.Create;
  try
    lResStream := TResourceStream.CreateFromID(HInstance, 1, RT_VERSION);
    try
      lMemStream.CopyFrom(lResStream, lResStream.Size);
    finally
      FreeAndNil(lResStream);
    end;
    lMemStream.Position:=0;

    if VerQueryValue(lMemStream.Memory, '\', Pointer(lVerblock),lVerLen) then
    begin
      lVersionMS := lVerblock.dwFileVersionMS;
      lVersionLS := lVerblock.dwFileVersionLS;
      result :=
        IntToStr(lVersionMS shr 16) + '.' +
        IntToStr(lVersionMS and $FFFF) + '.' +
        IntToStr(lVersionLS shr 16) + '.' +
        IntToStr(lVersionLS and $FFFF);
    end;
    if VerQueryValue(lMemStream.Memory, PChar('\\StringFileInfo\\' + IntToHex(GetThreadLocale, 4) + IntToHex(GetACP,4)+'\\FileDescription'), lP, lPLen)
       or
       VerQueryValue(lMemStream.Memory, '\\StringFileInfo\\040904E4\\FileDescription', lP, lPLen) then //en-us
     result := PChar(lP) + ' ' + result;
  finally
    FreeAndNil(lMemStream);
  end;
end;

{==============================================================================}
procedure TFormAppLauncher.LoadHistory;
var
  i: integer;
begin
  FHistoryList.Clear;
  ComboBoxEventHistory.Items.Clear;
  ComboBoxEventHistory.ItemIndex := -1;
  ComboBoxEventHistory.Text := '';

  MainDataModule.LoadEventHistory(FHistoryList);
  if FHistoryList.Count = 0 then
  begin
    ButtonLoad.Default := false;
    ButtonLoad.Enabled := false;
    ButtonNewWithTemplate.Enabled := false;
    ButtonNew.Default := true;
    Exit;
  end;

  for i := 0 to FHistoryList.Count - 1 do
  begin
    if FileExists(FHistoryList.Names[i]) then
      ComboBoxEventHistory.Items.Add(FHistoryList.ValueFromIndex[i]);
  end;
  ComboBoxEventHistory.ItemIndex := 0;
end;

end.
