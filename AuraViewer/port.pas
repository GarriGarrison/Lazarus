unit port;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StdTypes, Windows, Dialogs;

function  ComPortOpen(port_name: str_t; port_speed: Integer): bool;
procedure ComPortClose;
procedure ComPortWrite(bait: uint8_t);
function  ComPortRead(Message_error_show: bool): uint8_t;
procedure TelegramSend(mes_length: uint16_t);
function  TelegramRead(mes_length: uint16_t): bool;
procedure ComPortClear;


var
  data_tx: array [1..1000{65535}] of uint8_t;  //буфер байт для отправки
  data_rx: array [1..1000{65535}] of uint8_t;  //буфер притях данных
  Read_byte_error: bool;  //флаг ошибки чтения байта

implementation

const
  MAXBUF = 1000;//25000;

var
  hPort: THandle;
  dwNumByte: DWord;
  Connected: bool;  //флаг подключения СОМ-порта


//******************************************************************************
function  ComPortOpen(port_name: str_t; port_speed: Integer): bool;
var
  dcb: TDCB;
  cto: TCommTimeouts;
  port_used: PChar;
  port_baudrate: Cardinal;
begin
  result:= false;
  if Connected then Exit;

  port_used:= PChar('\\.\' + port_name);
  case port_speed of
    2400:   port_baudrate:= CBR_2400;
    4800:   port_baudrate:= CBR_4800;
    9600:   port_baudrate:= CBR_9600;
    14400:  port_baudrate:= CBR_14400;
    19200:  port_baudrate:= CBR_19200;
    38400:  port_baudrate:= CBR_38400;
    57600:  port_baudrate:= CBR_57600;
    115200: port_baudrate:= CBR_115200;
  else
    port_baudrate:= CBR_115200;
  end;
  dcb.BaudRate:= port_baudrate;


  hPort:= CreateFile(port_used, GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

  if hPort = INVALID_HANDLE_VALUE then begin
    MessageDlg('Не удалось открыть порт ' + port_used + '!', mtError, [mbOK], 0);
    Connected:= false;
    Exit;
  end;

  if not GetCommState(hPort, dcb) then begin
    ShowMessage('Не удалось получить настройки порта');
    Exit;
  end;

  dcb.BaudRate:= port_baudrate;
  dcb.ByteSize:= 8;
  dcb.Parity:= NOPARITY;  //0
  dcb.StopBits:= ONESTOPBIT;  //0

  if not SetCommState(hPort, dcb) then
    ShowMessage('Не удалось установить настройки порта');

  SetupComm(hPort, MAXBUF, MAXBUF);

  cto.ReadIntervalTimeout:= 50;
  cto.ReadTotalTimeoutMultiplier:= 0;
  cto.ReadTotalTimeoutConstant:= 50;  //500
  cto.WriteTotalTimeoutMultiplier:= 0;
  cto.WriteTotalTimeoutConstant:= 1;  //200
  SetCommTimeouts(hPort, cto);

  //if not PurgeComm(hPort, PURGE_TXABORT, PURGE_RXABORT, PURGE_TXCLEAR or PURGE_RXCLEAR) then begin
  if not PurgeComm(hPort, PURGE_TXCLEAR or PURGE_RXCLEAR) then begin
    ShowMessage('Не удалось очистить порт');
    Exit;
  end;

  if not SetCommMask(hPort, EV_RXCHAR) then
    raise Exception.Create('Не удалось настроить маску приёма порта');

  Connected:= true;
  result:= true;
end;

procedure ComPortClose;
begin
  CloseHandle(hPort);
  Connected:= false;
end;

procedure ComPortWrite(bait: uint8_t);
begin
   WriteFile(hPort, bait, 1, dwNumByte, nil);
end;

function ComPortRead(Message_error_show: bool): uint8_t;
var
  res: uint8_t;
begin
  res:= 0;
  Read_byte_error:= false;


  ReadFile(hPort, res, 1, dwNumByte, nil);

  if dwNumByte <> 1 then begin
    if Message_error_show then  //MessageDlg('Устройство не ответило на запрос!', mtError, [mbOK], 0);
      Read_byte_error:= true;
    result:= 0;
  end else begin
    result:= res;
  end;
end;

procedure TelegramSend(mes_length: uint16_t);
begin
   WriteFile(hPort, data_tx, mes_length, dwNumByte, nil);
end;

function TelegramRead(mes_length: uint16_t): bool;
begin
  ReadFile(hPort, data_rx, mes_length, dwNumByte, nil);
  if dwNumByte <> mes_length then
    result:= false
  else
    result:= true;
end;

procedure ComPortClear;
begin
  PurgeComm(hPort, PURGE_TXCLEAR or PURGE_RXCLEAR);
end;

end.
