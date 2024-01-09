unit Tools.Preferences;

interface

uses
  SysUtils, Variants, Generics.Collections
{$IFDEF ANDROID}
  ,AndroidApi.Helpers
  ,Androidapi.JNI.GraphicsContentViewText
{$ELSE}
  , Windows, Registry
{$ENDIF}
  ;

type
  TPreferences = class
  protected
    FCreatorName: string;
    FAppName: string;
    constructor Create(const ACreatorName, AAppName: string); reintroduce; virtual;

  public
    procedure Save; virtual; abstract;

    function GetString(const AName: string; const ADefault: string = ''): string; virtual; abstract;
    function GetBoolean(const AName: string; ADefault: boolean = false): boolean; virtual; abstract;
    function GetInteger(const AName: string; ADefault: Integer = 0): Integer; virtual; abstract;

    procedure SetString(const AName: string; const AValue: string); virtual; abstract;
    procedure SetBoolean(const AName: string; AValue: boolean); virtual; abstract;
    procedure SetInteger(const AName: string; AValue: Integer); virtual; abstract;
  end;

  function CreatePreferencesObject(const ACreatorName, AAppName: string): TPreferences;

implementation

{$IFDEF ANDROID}
uses
  Androidapi.JNI.App;

type
  TPreferencesAndroid = class(TPreferences)
  protected
    FPref: JSharedPreferences;

    constructor Create(const ACreatorName, AAppName: string); override;

  public
    procedure Save; override;

    function GetString(const AName: string; const ADefault: string = ''): string; override;
    function GetBoolean(const AName: string; ADefault: boolean = false): boolean; override;
    function GetInteger(const AName: string; ADefault: Integer = 0): Integer; override;

    procedure SetString(const AName: string; const AValue: string); override;
    procedure SetBoolean(const AName: string; AValue: boolean); override;
    procedure SetInteger(const AName: string; AValue: Integer); override;
  end;

{==============================================================================}
constructor TPreferencesAndroid.Create(const ACreatorName, AAppName: string);
begin
  inherited Create(ACreatorName, AAppName);
  FPref := SharedActivity.getSharedPreferences(StringToJString(ACreatorName + '.' + AAppName), 0);
end;

{==============================================================================}
procedure TPreferencesAndroid.Save;
begin
  FPref.edit.commit;
end;

{==============================================================================}
function TPreferencesAndroid.GetString(const AName: string; const ADefault: string = ''): string;
begin
  result := JStringToString(FPref.getString(StringToJString(AName), StringToJString(ADefault)));
end;

{==============================================================================}
function TPreferencesAndroid.GetBoolean(const AName: string; ADefault: boolean): boolean;
begin
  result := FPref.getBoolean(StringToJString(AName), ADefault);
end;

{==============================================================================}
function TPreferencesAndroid.GetInteger(const AName: string; ADefault: Integer): Integer;
begin
  result := FPref.getInt(StringToJString(AName), ADefault);
end;

{==============================================================================}
procedure TPreferencesAndroid.SetString(const AName: string; const AValue: string);
begin
  FPref.edit.putString(StringToJString(AName), StringToJString(AValue));
end;

{==============================================================================}
procedure TPreferencesAndroid.SetBoolean(const AName: string; AValue: boolean);
begin
  FPref.edit.putBoolean(StringToJString(AName), AValue);
end;

{==============================================================================}
procedure TPreferencesAndroid.SetInteger(const AName: string; AValue: Integer);
begin
  FPref.edit.putInt(StringToJString(AName), AValue);
end;

{$ELSE}

type
  TPreferencesWindows = class(TPreferences)
  private
    FReg: TRegistry;
    constructor Create(const ACreatorName, AAppName: string); override;

  public
    destructor Destroy; override;
    procedure Save; override;

    function GetString(const AName: string; const ADefault: string = ''): string; override;
    function GetBoolean(const AName: string; ADefault: boolean = false): boolean; override;
    function GetInteger(const AName: string; ADefault: Integer = 0): Integer; override;

    procedure SetString(const AName: string; const AValue: string); override;
    procedure SetBoolean(const AName: string; AValue: boolean); override;
    procedure SetInteger(const AName: string; AValue: Integer); override;
  end;

{==============================================================================}
constructor TPreferencesWindows.Create(const ACreatorName, AAppName: string);
begin
  inherited Create(ACreatorName, AAppName);

  FReg := TRegistry.Create(KEY_WRITE);
  FReg.RootKey := HKEY_CURRENT_USER;
  FReg.OpenKey(Format('SOFTWARE\%s\%s\Settings', [FCreatorName, FAppName]), true);
end;

{==============================================================================}
destructor TPreferencesWindows.Destroy;
begin
  try
    FreeAndNil(FReg);
  finally
    inherited Destroy;
  end;
end;

{==============================================================================}
procedure TPreferencesWindows.Save;
begin
end;

{==============================================================================}
function TPreferencesWindows.GetString(const AName: string; const ADefault: string = ''): string;
begin
  if not FReg.ValueExists(AName) then
    Exit(ADefault);
  result := FReg.ReadString(AName);
end;

{==============================================================================}
function TPreferencesWindows.GetBoolean(const AName: string; ADefault: boolean): boolean;
begin
  if not FReg.ValueExists(AName) then
    Exit(ADefault);
  result := FReg.ReadBool(AName);
end;

{==============================================================================}
function TPreferencesWindows.GetInteger(const AName: string; ADefault: Integer): Integer;
begin
  if not FReg.ValueExists(AName) then
    Exit(ADefault);
  result := FReg.ReadInteger(AName);
end;

{==============================================================================}
procedure TPreferencesWindows.SetString(const AName: string; const AValue: string);
begin
  FReg.WriteString(AName, AValue);
end;

{==============================================================================}
procedure TPreferencesWindows.SetBoolean(const AName: string; AValue: boolean);
begin
  FReg.WriteBool(AName, AValue);
end;

{==============================================================================}
procedure TPreferencesWindows.SetInteger(const AName: string; AValue: Integer);
begin
  FReg.WriteInteger(AName, AValue);
end;

{$ENDIF}

{==============================================================================}
constructor TPreferences.Create(const ACreatorName, AAppName: string);
begin
  FCreatorName := ACreatorName;
  FAppName := AAppName;
end;

function CreatePreferencesObject(const ACreatorName, AAppName: string): TPreferences;
begin
{$IFDEF ANDROID}
  result := TPreferencesAndroid.Create(ACreatorName, AAppName);
{$ELSE}
  result := TPreferencesWindows.Create(ACreatorName, AAppName);
{$ENDIF}
end;



end.
