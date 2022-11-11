unit plugin_functions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, cdr_plugin, functions;

implementation

procedure lpCompressStringB64(const Params: PParamArray; const Result: Pointer); cdecl;
begin
  PSTring(Result)^ := CompressStringB64(PString(Params^[0])^);
end;

procedure lpDeCompressStringB64(const Params: PParamArray; const Result: Pointer); cdecl;
begin
  PSTring(Result)^ := DeCompressStringB64(PString(Params^[0])^);
end;

procedure lpStrToFile(const Params: PParamArray); cdecl;
begin
  StrToFile(PString(Params^[0])^, PString(Params^[1])^);
end;

procedure lpFileToStr(const Params: PParamArray; const Result: Pointer); cdecl;
begin
  PSTring(Result)^ := FileToStr(PString(Params^[0])^);
end;

initialization
  addMethod('procedure StrToFile(const FileName, SourceString : string);native;',
    @lpStrToFile);
  addMethod('function FileToStr(const FileName : string):string;native;', @lpFileToStr);
  addMethod('function Compress(const s: string): string;native;', @lpCompressStringB64);
  addMethod('function Decompress(const s: string): string;native;',
    @lpDeCompressStringB64);
end.
