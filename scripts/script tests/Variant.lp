program Variant_Example;

var
  V: Variant;  
  S: String;  

begin
  V := 10;  
  V := 'hello';  
  V := 16.9;  

  S := V; 
    

  Writeln(S);
end.
