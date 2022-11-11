unit ulptypes;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, lpcompiler;

procedure RegisterTypes(Compiler: TLapeCompiler);

implementation

procedure RegisterTypes(Compiler: TLapeCompiler);
begin
  Compiler.addGlobalType('UInt32', 'DWord');

  Compiler.addGlobalType('Integer', 'TColor');
  Compiler.addGlobalType('record R, T: extended; end', 'PPoint');
  Compiler.addGlobalType('array of string', 'TStringArray');
  Compiler.addGlobalType('array of TStringArray', 'T2DStringArray');
  Compiler.addGlobalType('array of Integer', 'TIntegerArray');
  Compiler.addGlobalType('array of TIntegerArray', 'T2DIntegerArray');
  Compiler.addGlobalType('array of TIntegerArray', 'T2DIntArray');
  Compiler.addGlobalType('array of T2DIntegerArray', 'T3DIntegerArray');
  Compiler.addGlobalType('array of Cardinal', 'TCardinalArray');
  Compiler.addGlobalType('array of TCardinalArray', 'T2DCardinalArray');
  Compiler.addGlobalType('array of Char', 'TCharArray');
  Compiler.addGlobalType('array of TCharArray', 'T2DCharArray');
  Compiler.addGlobalType('array of byte', 'TByteArray');
  Compiler.addGlobalType('array of TByteArray', 'T2DByteArray');
  Compiler.addGlobalType('array of extended', 'TExtendedArray');
  Compiler.addGlobalType('array of TExtendedArray', 'T2DExtendedArray');
  Compiler.addGlobalType('array of T2DExtendedArray', 'T3DExtendedArray');
  Compiler.addGlobalType('array of boolean', 'TBoolArray');
  Compiler.addGlobalType('array of variant', 'TVariantArray');
  Compiler.addGlobalType('record X, Y: integer; end', 'TPoint');
  Compiler.addGlobalType('array of TPoint', 'TPointArray');
end;

end.

