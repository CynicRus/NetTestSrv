unit ulpclasses;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, lpcompiler;


procedure RegisterLCLClasses(Compiler: TLapeCompiler);

implementation

uses
  ulptypes,
  lpTObject,

  lplclsystem,
  //lplclgraphics,
  //lplclforms,
  //lplclcontrols,
  //lplclstdctrls,
  //lplclextctrls,
  //lplclcomctrls,
  //lplcldialogs,
  //lplclmenus,
  //lplclspin,
  lplclprocess,
  lplclregexpr,
  lpjson,
  lpxml;

procedure RegisterLCLClasses(Compiler: TLapeCompiler);
begin
  RegisterTypes(Compiler);
  Register_TObject(Compiler);

  RegisterLCLSystem(Compiler);
  //RegisterLCLGraphics(Compiler);
  //RegisterLCLControls(Compiler);
  //RegisterLCLForms(Compiler);
  //RegisterLCLStdCtrls(Compiler);
  //RegisterLCLExtCtrls(Compiler);
  //RegisterLCLComCtrls(Compiler);
  //RegisterLCLDialogs(Compiler);
  //RegisterLCLMenus(Compiler);
  //RegisterLCLSpinCtrls(Compiler);
  RegisterLCLProcess(Compiler);
  RegisterLCLTRegExpr(Compiler);
  Register_JSON(Compiler);
  Register_TXml(Compiler);
end;

end.
