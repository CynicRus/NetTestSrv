const
 ClearOnIteration = true;
var
data: string;

begin
 if ClearOnIteration then
   ClearScriptLog();
   
 Data := GetData();
 WriteLn('Recieved: ' + Data);
 SetData(Data);
 WriteLn('Send back: ' + Data);
 
end.
