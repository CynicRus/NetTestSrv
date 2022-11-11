program WhileLoop_Example;

var
  Counter: Integer;

begin
  Counter := 1;  

  
  while (Counter <= 10) do
  begin
    Writeln('Counter = ' + IntToStr(Counter));

    Counter := Counter + 1;  

  end;
end.
