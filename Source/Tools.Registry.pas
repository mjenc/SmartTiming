unit Tools.Registry;

interface

uses
  Windows, Registry, SysUtils;

type
  TToolsRegistry = class
    class function RegistryReadString(aRootKey: HKEY; const aPath, aKey: string; aDefault: String = ''): String;
    class procedure RegistryWriteString(aRootKey: HKEY; const aPath, aKey: string; aValue: String);
    class function RegistryReadBool(aRootKey: HKEY; const aPath, aKey: string; aDefault: boolean = false): boolean;
    class procedure RegistryWriteBool(aRootKey: HKEY; const aPath, aKey: string; aValue: Boolean);
  end;

implementation

{==============================================================================}
class function TToolsRegistry.RegistryReadString(aRootKey: HKEY; const aPath, aKey: string; aDefault: String = ''): String;
var
  lReg : TRegistry;
  lRegDataType: TRegDataType;
begin
  result := aDefault;
  lReg := TRegistry.Create(KEY_QUERY_VALUE);
  try
    lReg.RootKey := aRootKey;
    if not lReg.OpenKeyReadOnly(aPath) then
      Exit;
    if not lReg.ValueExists(aKey) then
      Exit;

    lRegDataType := lReg.GetDataType(aKey);
    if not (lRegDataType in [rdString, rdExpandString]) then
      Exit;

    Result := lReg.ReadString(aKey);
  finally
    FreeAndNil(lReg);
  end;
end;

{==============================================================================}
class procedure TToolsRegistry.RegistryWriteString(aRootKey: HKEY; const aPath, aKey: string; aValue: String);
var
  lReg : TRegistry;
begin
  lReg := TRegistry.Create;
  try
    lReg.RootKey := aRootKey;
    if lReg.OpenKey(aPath, true) then
      lReg.WriteString(aKey, aValue);
  finally
    FreeAndNil(lReg);
  end;
end;

{==============================================================================}
class function TToolsRegistry.RegistryReadBool(aRootKey: HKEY; const aPath, aKey: string; aDefault: boolean = false): boolean;
var
  lReg : TRegistry;
  lRegDataType: TRegDataType;
begin
  lReg := TRegistry.Create(KEY_QUERY_VALUE);
  try
    lReg.RootKey := aRootKey;
    if not lReg.OpenKeyReadOnly(aPath) then
      Exit(aDefault);
    if not lReg.ValueExists(aKey) then
      Exit(aDefault);

    lRegDataType := lReg.GetDataType(aKey);
    if not (lRegDataType in [rdInteger]) then
      Exit(aDefault);

    Result := lReg.ReadInteger(aKey) <> 0;
  finally
    FreeAndNil(lReg);
  end;
end;

{==============================================================================}
class procedure TToolsRegistry.RegistryWriteBool(aRootKey: HKEY; const aPath, aKey: string; aValue: Boolean);
var
  lReg : TRegistry;
begin
  lReg := TRegistry.Create;
  try
    lReg.RootKey := aRootKey;
    if lReg.OpenKey(aPath, true) then
    begin
      if aValue then
        lReg.WriteInteger(aKey, 1)
      else
        lReg.WriteInteger(aKey, 0);
    end;
  finally
    FreeAndNil(lReg);
  end;
end;

end.
