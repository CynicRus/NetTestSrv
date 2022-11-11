program new;

type
  TMyRecord = record
    name: string [20];
    age: Integer;
  end;

var
  myRecord: TMyRecord;
  myRecordPtr: ^ TMyRecord;
begin
  myRecord.name := 'John Doe';
  myRecord.age := 23;
  myRecordPtr := @myRecord;
  WriteLn(myRecordptr^.name);
end;