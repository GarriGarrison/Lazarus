function TDevice.RegisterRead(device_num: uint8_t; reg_numer, quantity: uint16_t): bool;
var
  i: uint16_t;
begin
  ComPortClear;

  data_tx[1]:= device_num;
  data_tx[2]:= CMD_REGISTER_READ;
  data_tx[3]:= reg_numer div 256;//shr 8;
  data_tx[4]:= reg_numer;
  data_tx[5]:= quantity div 256;//shr 8;
  data_tx[6]:= quantity;

  Crc(data_tx, 6);
  data_tx[7]:= crc16_l;
  data_tx[8]:= crc16_h;

  TelegramSend(8);

  Sleep(5);
  for i:= 1 to 5 + quantity * 2 do
    data_rx[i]:= ComPortRead(false);
  if ReadControl(device_num, quantity) = 0 then begin
    result:= true;
  end else
    result:= false;
end;

function TDevice.ReadControl(device_num: adr_t; quantity: reg_t): uint8_t;
var
  error_code: Integer;
  reg_count: Integer;
begin
  error_code:= 0;
  reg_count:= 3 + quantity * 2;

  if data_rx[1] <> device_num then error_code:= error_code or $01;
  if data_rx[2] <> CMD_REGISTER_READ then error_code:= error_code or $02;
  if data_rx[3] <> 2*quantity then error_code:= error_code or $04; //0x02 - кол-во читаемых байт, 1 регистр

  Crc(data_rx, reg_count);
  if data_rx[reg_count+1] <> crc16_l then error_code:= error_code or $08;
  if data_rx[reg_count+2] <> crc16_h then error_code:= error_code or $08;

  result:= error_code;
end;

function TDevice.RegisterWrite(device_num: uint8_t; reg_numer: reg_t; value: uint16_t): bool;
var
  error_code: Integer;
  i: Integer;
begin
  result:= false;
  error_code:= 0;

  ComPortClear;

  data_tx[1]:= device_num;
  data_tx[2]:= CMD_REGISTER_WRITE;
  data_tx[3]:= reg_numer shr 8;
  data_tx[4]:= reg_numer;
  data_tx[5]:= value shr 8;
  data_tx[6]:= value;

  Crc(data_tx, 6);
  data_tx[7]:= crc16_l;
  data_tx[8]:= crc16_h;

  TelegramSend(8);

  Sleep(50);
  for i:= 1 to 2 do
    data_rx[i]:= ComPortRead(false);

  if data_rx[1] <> address then  error_code:= 1;

  case data_rx[2] of
  CMD_REGISTER_WRITE: begin
    for i:= 3 to 6 do
      data_rx[i]:= ComPortRead(false);
    if data_rx[3] <> data_tx[3] then  error_code:= 2;
    if data_rx[4] <> data_tx[4] then  error_code:= 3;
    if data_rx[5] <> data_tx[5] then  error_code:= 4;
    if data_rx[6] <> data_tx[6] then  error_code:= 5;
  end;
  CMD_REGISTER_WRITE_ERROR: begin
    data_rx[3]:= ComPortRead(false);
    MessageDlg('Ошибка ' + IntToStr(data_rx[3]) + ' записи в регистр', mtError, [mbOK], 0);
    error_code:= 6;
  end
  else begin
    MessageDlg('Неизвестный Function code', mtError, [mbOK], 0);
    error_code:= 7;
  end;
  end;

  if error_code = 0 then  result:= true;
end;
