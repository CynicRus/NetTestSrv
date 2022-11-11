unit functions;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, zstream, base64;

procedure StrToFile(const FileName, SourceString: string); cdecl;
function FileToStr(const FileName: string): string; cdecl;
function CompressStringB64(const s: string): string; cdecl;
function DeCompressStringB64(const s: string): string; cdecl;

implementation

procedure StrToFile(const FileName, SourceString: string); cdecl;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate or fmShareDenyWrite);
  try
    Stream.WriteBuffer(Pointer(SourceString)^, Length(SourceString));
  finally
    Stream.Free;
  end;
end;

function FileToStr(const FileName: string): string; cdecl;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead);
  try
    SetLength(Result, Stream.Size);
    Stream.Position := 0;
    Stream.ReadBuffer(Pointer(Result)^, Stream.Size);
  finally
    Stream.Free;
  end;
end;

function CompressDataB64(const Data: pointer; const size: longint): string; cdecl;
var
  b64Stream: TBase64EncodingStream;
  cStream: TCompressionStream;
  outStream: TStringStream;
  dataStream: TMemoryStream;
  buffer: pointer;
  l: integer;
begin
  dataStream := TMemoryStream.Create;
  cStream := TCompressionStream.Create(cldefault, dataStream);
  outStream := TStringStream.Create('');
  b64Stream := TBase64EncodingStream.Create(outStream);
  try
    cStream.Write(size, 4);
    cStream.Write(Data^, size);
    cStream.Free;
    dataStream.Position := 0;
    l := dataStream.Size;
    buffer := allocmem(l);
    dataStream.Read(buffer^, l);
    b64Stream.Write(buffer^, l);
    Result := outStream.DataString;
  finally
    b64Stream.Free;
    freemem(buffer);
    dataStream.Free;
    outStream.Free;
  end;

end;

function CompressStringB64(const s: string): string; cdecl;
begin
  Result := CompressDataB64(@s[1], length(s));
end;

function DeCompressDataB64(const inStr: string; const size: PInteger): pointer;
var
  b64Stream: TBase64DecodingStream;
  dcStream: TDeCompressionStream;
  outStream: TMemoryStream;
  inStream: TStringStream;
  l: longint;
begin
  outStream := TMemoryStream.Create;
  inStream := TStringStream.Create(inStr);
  b64Stream := TBase64DecodingStream.Create(inStream, bdmMIME);
  outStream.CopyFrom(b64Stream, b64Stream.Size);
  try
    outStream.Position := 0;
    dcStream := TDeCompressionStream.Create(outStream);
    dcStream.Read(l, 4);
    Result := allocmem(l);
    dcStream.Read(Result^, l);

  finally
    b64Stream.Free;
    inStream.Free;
    dcStream.Free;
    outStream.Free;
  end;
end;

function DeCompressStringB64(const s: string): string; cdecl;
begin
  Result := PChar(DeCompressDataB64(s, PInteger(length(s))));
end;

end.



