unit func;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics,
  StdTypes;

function DeviceFound: bool;  //поиск устройства на линии связи
procedure SendCommand(cmd: uint8_t);  //послать команду
function  ReadMessage: bool;  //чтение сообщения


implementation

uses
  global, port;


function DeviceFound: bool;
begin
  result:= false;

  SendCommand(GET_RESPONSE);
  if TelegramRead(4) then
      result:= true;
end;

procedure SendCommand(cmd: uint8_t);
var
  len, cxr: uint8_t;
begin
  ComPortClear;

  len:= $04;
  cxr:= len xor cmd;

  data_tx[1]:= HEADER;
  data_tx[2]:= len;
  data_tx[3]:= cmd;
  data_tx[4]:= cxr;

  TelegramSend(4);
end;

function CalculateCxr(mes_len: uint8_t): uint8_t;
var
  i: uint8_t;
begin
  result:= 0;

  for i:= 2 to mes_len - 2 do
    result:= result xor data_rx[i];
end;

function ReadMessage: bool;
var
  cxr: uint8_t;
  mes_len, i: uint8_t;
begin
  result:= false;
  cxr:= 0;

  data_rx[1]:= ComPortRead(true);
  if data_rx[1] = HEADER then begin
    data_rx[2]:= ComPortRead(true);
    mes_len:= data_rx[2];
    for i:= 1 to mes_len - 2 do
      data_rx[i+2]:= ComPortRead(true);

    cxr:= CalculateCxR(data_rx[2]);
    
    if (data_rx[1] = HEADER) then
      result:= true;
  end;
end;

end.
