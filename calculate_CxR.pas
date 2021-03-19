function CalculateCxr(message_length: uint8_t): uint8_t;
var
  i: uint8_t;
begin
  result:= 0;

  for i:= 2 to message_length - 2 do
    result:= result xor buffer_rx[i];
end;
