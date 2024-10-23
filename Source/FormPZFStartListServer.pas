unit FormPZFStartListServer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,  IdHTTPServer, IdCustomHTTPServer, IdContext,
  Tools.Logger, Tools.SuperObject, GWServices_TLB, ActiveX, uServerFactory;

type
  TFormPZFStartList = class(TForm)
    EditUsername: TEdit;
    EditPassword: TEdit;
    EditAppServer: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ComboBoxDatabase: TComboBox;
    ButtonLogon: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ButtonLogonClick(Sender: TObject);
  private
    FUserService: UserService;
    FSessionTicket: string;

    FHTTPPort: integer;
    FHTTPServer: TIdHTTPServer;
    procedure HTTPServerCommand(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    function GetRunningState: boolean;
    function GetCurrentHTTPPort: integer;
    procedure InitHttpServer;
    procedure FillStartListResponse(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure FillResultResponse(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure GetEventInfo(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure GetRaceInfo(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    function GetJSONFromDataService(ADataService: DataService; const AFieldTitles: string): string;
  public
     destructor Destroy; override;
  end;

var
  FormPZFStartList: TFormPZFStartList;

implementation

{$R *.dfm}

const
  cLogger = 'PZFStartListServer';

function VarToInt(const AValue: OleVariant; ADefault: integer = 0): integer;
begin
  if VarIsStr(AValue) then
    Result := StrToIntDef(AValue, ADefault)
  else if not (VarIsNumeric(AValue) or VarIsType(AValue, 14)) then
    Result := ADefault
  else
  begin
    try
      Result := integer(AValue);
    except
      Result := ADefault;
    end;
  end;
end;

{******************************************************************************}
procedure TFormPZFStartList.ButtonLogonClick(Sender: TObject);
begin
  FUserService := CoUserService.CreateRemote(EditAppServer.Text);
  FSessionTicket := FUserService.LoginUser2(EditUsername.Text, EditPassword.Text, '', ComboBoxDatabase.Text);
  FHTTPServer.Active := true;
end;

{******************************************************************************}
destructor TFormPZFStartList.Destroy;
begin
  try
    FreeAndNil(FHTTPServer);
  finally
    inherited;
  end;
end;

{******************************************************************************}
procedure TFormPZFStartList.HTTPServerCommand(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  try
    if ARequestInfo = nil then
      raise Exception.Create('ARequestInfo = nil');

    if (ARequestInfo.Document.IsEmpty or ARequestInfo.Document.Equals('/')) then
    begin
      AResponseInfo.ResponseNo := 404;
      Exit;
    end;

    if AResponseInfo = nil then
      raise Exception.Create('AResponseInfo = nil');

    if ARequestInfo.Document.Equals('/startlist') then
    begin
      FillStartListResponse(ARequestInfo, AResponseInfo);
      Exit;
    end;

    if ARequestInfo.Document.Equals('/results') then
    begin
      FillResultResponse(ARequestInfo, AResponseInfo);
      Exit;
    end;

    if ARequestInfo.Document.Equals('/eventinfo') then
    begin
      GetEventInfo(ARequestInfo, AResponseInfo);
      Exit;
    end;

    if ARequestInfo.Document.Equals('/raceinfo') then
    begin
      GetRaceInfo(ARequestInfo, AResponseInfo);
      Exit;
    end;

    if ARequestInfo.Document.Equals('/connectiontest') then
    begin
      AResponseInfo.ResponseNo := 200;
      AResponseInfo.ContentType := 'text/json';
      AResponseInfo.ContentText := '{"test":"succeeded"}';
      Exit;
    end;
  except
    LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['HTTPServerCommand']);
  end;
end;

{******************************************************************************}
function TFormPZFStartList.GetRunningState: boolean;
begin
  result := FHTTPServer.Active;
end;

{******************************************************************************}
function TFormPZFStartList.GetCurrentHTTPPort: integer;
begin
  result := FHTTPServer.DefaultPort;
end;

{******************************************************************************}
procedure TFormPZFStartList.InitHttpServer;
begin
  FHTTPServer := TIdHTTPServer.Create;
  FHTTPServer.OnCommandGet := HTTPServerCommand;
  FHTTPServer.OnCommandOther := HTTPServerCommand;
  FHTTPServer.DefaultPort := FHTTPPort;
end;

{******************************************************************************}
procedure TFormPZFStartList.FillResultResponse(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  // TODO
end;

{******************************************************************************}
procedure TFormPZFStartList.FillStartListResponse(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  lUserService: UserService;
  lsessionTicket: string;
  lDataService: DataService;
begin
  CoInitialize(nil);
  try
    try
      LogOnDebug(cLogger, ['FillStartListResponse']);
      AResponseInfo.ResponseNo := 200;
      AResponseInfo.ContentType := 'text/json';

      lUserService := CoUserService.Create;
      lSessionTicket := lUserService.LoginUser2(EditUsername.Text, EditPassword.Text, '', ComboBoxDatabase.Text);
      try
        lDataService := CoDataService.CreateRemote(EditAppServer.Text);
        lDataService.SessionTicket := lSessionTicket;
        lDataService.Open(
        'SELECT /* NOADDITIONALQUERYFIELDS */ STARTINGNUMBER, FIRSTNAMERIDER1, RIDER1NAME, FIRSTNAMERIDER2, RIDER2NAME, STARTTIME ' +
        'FROM TEAM WHERE STARTTIME = @J:"Im Jahr 2023" ORDER BY STARTTIME', true);

        AResponseInfo.ContentText := GetJSONFromDataService(lDataService, '');
      finally
        lUserService.LogOffUser(lSessionTicket);
      end;
    except
      LogAndRaise(ExceptObject, cLogger, Tools.Logger.Error, ['FillStartListResponse']);
    end;
  finally
    CoUninitialize;
  end;
end;

{******************************************************************************}
procedure TFormPZFStartList.GetEventInfo(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  // TODO
end;

{******************************************************************************}
procedure TFormPZFStartList.GetRaceInfo(ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  // TODO
end;

{******************************************************************************}
procedure TFormPZFStartList.FormCreate(Sender: TObject);
begin
  FHttpPort := 9768;
  InitHttpServer;
end;

{******************************************************************************}
function TFormPZFStartList.GetJSONFromDataService(ADataService: DataService; const AFieldTitles: string): string;
var
  lRowIdx: Integer;
  lColIdx: Integer;
  lRow: ISuperObject;
  lFieldTitles: TStringList;
  lTitle: string;
begin
  lFieldTitles := TStringList.Create;
  try
    lFieldTitles.CommaText := AFieldTitles;
    result := '{"list":[';

    for lRowIdx := 1 to ADataService.RecordCount do
    begin
      ADataService.AbsolutePosition := lRowIdx;
      lRow := TSuperObject.Create;
      lRow.S['BIB'] := VarToInt(ADataService.FieldValue['STARTINGNUMBER']).ToString;
      lRow.S['FIRSTNAME'] := VarToStr(ADataService.FieldValue['FIRSTNAMERIDER1']);
      lRow.S['LASTNAME'] := VarToStr(ADataService.FieldValue['RIDER1NAME']);
      lRow.S['CLUB'] := VarToStr(ADataService.FieldValue['RIDER2NAME']) + ', ' +
                        VarToStr(ADataService.FieldValue['FIRSTNAMERIDER2']);
      lRow.D['STARTTIME'] := ADataService.FieldValue['STARTTIME'];
      result := result + lRow.AsJSon;

      if lRowIdx <> ADataService.RecordCount then
        result := result + ',';
    end;
    result := result + ']}';
  finally
    FreeAndNil(lFieldTitles);
  end;
end;

initialization
  CoInitialize(nil);

finalization
  CoUninitialize;
end.
