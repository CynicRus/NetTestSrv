unit cdr_plugin;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  PParamArray = ^TParamArray;
  TParamArray = array[Word] of Pointer;


  TPluginType = record
    Name, Decl: string;
  end;
  TPluginTypes = array of TPluginType;

  TPluginMethod = record
    Decl: string;
    Ptr: Pointer;
  end;
  TPluginMethods = array of TPluginMethod;

var
  PluginTypes: TPluginTypes;
  PluginMethods: TPluginMethods;
  Mem: TMemoryManager;
  MemSet: boolean = False;

procedure addType(Name, Decl: string);
procedure addMethod(Decl: string; Ptr: Pointer);

implementation

procedure addType(Name, Decl: string);
var
  H: longint;
begin
  H := Length(PluginTypes);
  SetLength(PluginTypes, H + 1);
  PluginTypes[H].Name := Name;
  PluginTypes[H].Decl := Decl;
end;

procedure addMethod(Decl: string; Ptr: Pointer);
var
  H: longint;
begin
  H := Length(PluginMethods);
  SetLength(PluginMethods, H + 1);
  PluginMethods[H].Decl := Decl;
  PluginMethods[H].Ptr := Ptr;
end;

end.
