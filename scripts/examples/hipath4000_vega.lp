//type
//	TCallDirection = (cdUnknown = -1, cdInput = 0, cdOutput = 1, cdInternal = 2);
//  TCallType = (Undefined = -1, Local = 0, InZone = 1, Intercity = 2,
//    International = 3, FreeCall = 4);
	
type CDRData = record
    CallDate: TDateTime;
    Trunk: integer;
    InternalCallNumber: string;
    CallDirection: integer;
    ExternalCallNumber: string;
    Duration: integer;
    PrefixNumber: integer;
    CallType: integer;
end;

procedure CDRData.LoadFromString(Value: string);
var
  Str: string;
  Tmp: string;
  Data: TStringArray;
  //fmt: TFormatSettings;
begin
  Str := Value;
  try
	Data := Explode('+',ExtractText(Str,'$','$'));
    if (Length(Data) > 5) and (Length(Data) <=7) then
    begin
      if (Trim(Data[0]) = Trim('')) then
        Data[0] := '000';
      Trunk := StrToInt(Data[0]);
      InternalCallNumber := Data[1];
      case UpperCase(Data[3]) of
        'O': CallDirection := 1;
        'I': CallDirection := 0;
        'H': CallDirection := 2;
      end;
      if CallDirection = 1 then
      begin
        if not (Trim(Data[2]) = Trim('')) then
          PrefixNumber := StrToInt(Data[2]);
      end;
      ExternalCallNumber := Trim(Data[4]);
      Duration := StrToInt(Data[5]);
      tmp := Copy(Data[6], 5, 2) + DateSeparator + Copy(Data[6], 3, 2) +
        DateSeparator + Copy(Data[6], 1, 2) + #32 + Copy(Data[6], 7, 2) +
        TimeSeparator + Copy(Data[6], 9, 2) + TimeSeparator + Copy(Data[6], 11, 2);
      Data[6] := tmp;
      CallDate := StrToDateTime(Data[6]);
    end;
  finally
    //Data.Free;
  end;

end;

function DataAsJson(Data: CDRData): string;
var
 json: TJsonObject;
 s: string;
begin
 json.init();
 try
  json.put('calldate',DateToStr(Data.CallDate));
  json.put('trunk',Data.trunk);
  json.put('calldirection',Data.calldirection);
  json.put('phoneA',data.InternalCallNumber);
  json.put('phoneB',data.ExternalCallNumber);
  json.put('duration',data.duration);
  s:=json.ToString();
  result:=s;
 finally
  json.free();
  
 end;
end;

function DataAsXML(Data: CDRData; ss: TStringStream):string;
var
 Xml: TXml;
 Node, Child: TXmlNode;
begin
 XML.Init;
 try
  Xml.GetHeader().SetAttribute('encoding','utf-8');
  Node :=  Xml.GetRoot();	
  Node.SetNodeName('data');
  Node.AddChild('calldate').SetText(DateToStr(Data.CallDate));
  Node.AddChild('trunk').SetText(IntToStr(Data.trunk));
  Node.AddChild('direction').SetText(IntToStr(Data.CallDirection));
  Node.AddChild('phoneA').SetText(Data.InternalCallNumber);
  Node.AddChild('phoneB').SetText(Data.ExternalCallNumber);
  Node.AddChild('duration').SetText(IntToStr(Data.duration));
  	
  XML.SaveToStream(ss);
  //ShowStream('Generated xml',ss);
  result:=ss.getdatastring();
 finally
  if assigned(XML) then
   XML.Free;
 end;
end;


var
  s: string;
  data: CDRData;
  DataFile: string;
  ss: TStringStream;
begin
  DataFile := WorkingDirectory + '/data/' + 'data.txt';
  s := gettext();
  WriteLn(s);
  data.LoadFromString(s);
  DumpData(DataFile,DataAsJson(data));
  WriteLn(data);
  ss.Init('');
  DumpData(DataFile,DataAsXML(data,ss));
  
  //settext(s);
end;