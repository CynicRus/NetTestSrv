program RepeatLoop_Example;

var
  Counter: Integer;

begin
  Counter := 0; 

  repeat
    Writeln('Counter = ' + IntToStr(Counter));

    Counter := Counter + 1;  

  Until(Counter > 10);
  
end.
