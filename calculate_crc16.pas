procedure TDevice.Crc(data: array of uint8_t; byte_count: uint8_t);
var
  crc16: uint16_t;
  byte_i, bit_i: uint8_t;
begin
  crc16:= $FFFF;

  for byte_i:= 0 to byte_count - 1 do begin
    crc16:= crc16 xor data[byte_i];
    for bit_i:= 1 to 8 do begin
      if (crc16 and $01) = $01 then begin
        crc16:= crc16 div 2; //shr 1;
        crc16:= crc16 xor $A001;
      end else
        crc16:= crc16 div 2; //shr 1;
    end;
  end;

  crc16_h:= crc16 shr 8;
  crc16_l:= crc16;
end;
