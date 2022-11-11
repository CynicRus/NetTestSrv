program ArraysAndLoops_Example;

var
  Counter: Integer;
  Arr: TIntegerArray; 

begin
  Arr := [2, 4, 6, 8, 10];

  for Counter := 0 to High(Arr) do
  begin
    Writeln('Arr[' + IntToStr(Counter) + '] = ' + IntToStr(Arr[Counter]));
  end;
end.
