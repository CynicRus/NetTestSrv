program new;

var
  myString: string;
  myCharPtr: PChar;
  i: Integer;
begin
  myString := 'Hello World';
  i := 1;
  myCharPtr := @ myString[i];
  while i <= Length(myString) do
  begin
    WriteLn(myCharPtr^);
    Inc(i);
    Inc(myCharPtr);
  end;
end;