library example;

{$mode objfpc}{$H+}

uses
  Classes,strings, cdr_plugin, plugin_functions, functions
  { you can add units after this };

function GetPluginABIVersion: Integer; cdecl;
begin
  Result := 2;
end;

procedure SetPluginMemManager(MemMgr : TMemoryManager); cdecl;
begin
  if (MemSet) then
    Exit;

  GetMemoryManager(Mem);
  SetMemoryManager(MemMgr);
  MemSet := True;
end;

procedure OnDetach; cdecl;
begin
  if (MemSet) then
    SetMemoryManager(Mem);
end;

function GetTypeCount(): Integer; cdecl;
begin
  Result := Length(PluginTypes);
end;

function GetTypeInfo(x: Integer; var sType, sTypeDef: PChar): integer; cdecl;
begin
  Result := -1;
  if (x < Length(PluginTypes)) and (x >= 0) then
  begin
    strpcopy(sType, PluginTypes[x].Name);
    strpcopy(sTypeDef, PluginTypes[x].Decl);
    Result := x;
  end;
end;

function GetFunctionCount(): Integer; cdecl;
begin
  Result := Length(PluginMethods);
end;

function GetFunctionInfo(x: Integer; var ProcAddr: Pointer; var ProcDef: PChar): Integer; cdecl;
begin
  Result := -1;
  if (x < Length(PluginMethods)) and (x >= 0) then
  begin
    strpcopy(ProcDef, PluginMethods[x].Decl);
    ProcAddr := PluginMethods[x].Ptr;
    Result := x;
  end;
end;

exports GetPluginABIVersion;
exports SetPluginMemManager;
exports GetTypeCount;
exports GetTypeInfo;
exports GetFunctionCount;
exports GetFunctionInfo;
exports OnDetach;

end.

