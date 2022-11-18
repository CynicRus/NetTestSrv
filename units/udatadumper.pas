unit udatadumper;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DateUtils, StrUtils;

type

  { TDataDumper }

  TDataDumper = class
  private
    FCurrentFileName: string;
    FOldDate: TDateTime;
    FNewDate: TDateTime;
  public
    constructor Create;
    destructor Destroy; override;
    procedure DumpData(Filename: string; Data: string);
    procedure SimpleDumpData(const Data: string);
    property CurrentFileName: string read FCurrentFileName write FCurrentFileName;
  end;




var
  DataDumper: TDataDumper;


procedure DumpData(FileName: string; Data: string);
procedure SimpleDumpData(Data: string);

implementation

procedure DumpData(FileName: string; Data: string);
begin
  DataDumper.DumpData(FileName,Data);
end;

procedure SimpleDumpData(Data: string);
begin
  DataDumper.SimpleDumpData(Data);
end;


{ TDataDumper }

constructor TDataDumper.Create;
begin
  FOldDate := Now();
  FNewDate := Now();
  CurrentFileName := ExtractFilePath(ParamStr(0)) + '/data/' +
    FormatDateTime('yyyy-mm-dd', Now) + '.data';
end;

destructor TDataDumper.Destroy;
begin
  inherited Destroy;
end;

procedure TDataDumper.DumpData(Filename: string; Data: string);
var
  Stm: TFileStream;
  str,f_name: string;
  S: ansistring;
  Buf: Pointer;
  BufSize: integer;
begin
  try
    Stm := TFileStream.Create(Filename, fmOpenReadWrite or fmShareDenyNone);
  except
    Stm := TFileStream.Create(Filename, fmCreate or fmShareDenyNone);
  end;
  try
    Stm.Position := Stm.Size;
    Str := Data + #13#10;
    BufSize := Length(Str);
    if SizeOf(char) = 1 then
      Buf := @Str[1]
    else
    begin
      S := Str;
      Buf := @S[1];
    end;

    if BufSize > 0 then
      Stm.Write(Buf^, BufSize);

  finally
    Stm.Free;
  end;

end;

procedure TDataDumper.SimpleDumpData(const Data: string);
var
  Stm: TFileStream;
  str: string;
  S: ansistring;
  Buf: Pointer;
  BufSize: integer;
begin
  FNewDate := Now;
  if (CompareDate(FOldDate, FNewDate) < 0) then
  begin
    CurrentFileName := ExtractFilePath(ParamStr(0)) + 'data/' +
      FormatDateTime('yyyy-mm-dd', Now) + '.sec';
  end;
  try
    Stm := TFileStream.Create(CurrentFileName, fmOpenReadWrite or fmShareDenyNone);
  except
    Stm := TFileStream.Create(CurrentFileName, fmCreate or fmShareDenyNone);
  end;
  try
    Stm.Position := Stm.Size;
    Str := Data + #13#10;
    BufSize := Length(Str);
    if SizeOf(char) = 1 then
      Buf := @Str[1]
    else
    begin
      S := Str;
      Buf := @S[1];
    end;

    if BufSize > 0 then
      Stm.Write(Buf^, BufSize);

  finally
    Stm.Free;
  end;

end;

initialization
 DataDumper := TDataDumper.Create;

finalization
 if DataDumper <> nil then
    DataDumper.Free;

end.

