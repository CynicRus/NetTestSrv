program new;
const
  ALLOCATE_SIZE = 20;

type
  PInt = ^Integer;

type
  TNumberList = record
    msCount: Integer;
    maxCount: Integer;
    memStart: Pointer;
    nextSlot: PInt;
  end;

procedure TNumberList.Init;
begin
  msCount := 0;
  memStart := GetMem(ALLOCATE_SIZE * SizeOf(Integer));
  maxCount := ALLOCATE_SIZE;
  nextSlot := memStart;
end;

procedure TNumberList.Destroy;
begin
  FreeMem(memStart)
end;

procedure TNumberList.Add(const number: Int64);
var
  newMemoryStart: Pointer;
  oldPtr, newPtr: PInt;
  i: Integer;
begin
  if msCount = maxCount then
  begin
    newMemoryStart := GetMem((maxCount + ALLOCATE_SIZE) * SizeOf(Integer));
    oldPtr := memStart;
    newPtr := newMemoryStart;
    for i := 1 to maxCount do
    begin
      newPtr ^ := oldPtr ^;
      Inc(oldPtr);
      Inc(newPtr);
    end;
    FreeMem(memStart);
    memStart := newMemoryStart;
    nextSlot := memStart;
    Inc(nextSlot, maxCount);
    Inc(maxCount, ALLOCATE_SIZE);
  end;
  nextSlot ^ := number;
  Inc(msCount);
  Inc(nextSlot);
end;

function TNumberList.GetValue(index: Integer): Integer;
var
  numberPtr: PInt;
begin
  numberPtr := memStart;
  Inc(numberPtr, index);
  Result := numberPtr ^;
end;

var
  list: TNumberList;
  value: Integer;
  i: Integer;
begin
  list.Init;
  try
    for i := 0 to 29 do
      list.Add(i * 2);
    value := list.GetValue(22);
    WriteLn('22nd value = ' + IntToStr(value));
  finally
    List.Destroy;
  end;
end;