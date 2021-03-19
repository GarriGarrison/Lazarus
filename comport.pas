unit com_port;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, Windows;

procedure ComPortClose;
procedure ComPortOpen;
procedure ComPortWrite(bait: Byte);
function ComPortRead: Byte;
procedure TelegramSend(mes_length: Integer; mes_data: array of Byte);
function ReadPort(var Buf; Size: Word): Integer;
procedure PortClear;

const
  maxbuf = 25000;

var
  hPort: THandle;
  dcb: TDCB;
  cto: TCommTimeouts;
  dwNumByte: DWord;

  port_used: PChar;
  port_name: String;
  port_speed: Cardinal;

  connected_flag: Boolean;  //флаг подключения СОМ-порта
  read_error_flag: Boolean;  //флаг ошибки чтения данных
  error_code: Integer;

  data: array [1..maxbuf{data_length}] of Byte;  //посылка от платы
  telegram_data: array [1..50000] of Byte;  //принятые быйты сообщения
  send_command: array [1..65535] of Byte;
  //send: Byte;  //передаваемый байт
  answer: Byte;  //ответ платы на запрос
  answer_res: Byte;  //резервный байт ответа

implementation

uses
  main;

procedure ComPortClose;
begin
  CloseHandle(hPort);
  connected_flag:= false;
end;

procedure ComPortOpen;
begin
  if connected_flag then Exit;

  port_used:= PChar('\\.\' + port_name);
  hPort:= CreateFile(port_used, GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

  if hPort = INVALID_HANDLE_VALUE then begin
    MessageDlg('Не удалось открыть порт ' + port_used + '!', mtError, [mbOK], 0);
    connected_flag:= false;
    Exit;
  end;

  if not GetCommState(hPort, dcb) then begin
    ShowMessage('Не удалось получить настройки порта');
    Exit;
  end;

  dcb.BaudRate:= CBR_115200;//CBR_57600;  //port_speed;  StrToCard(Form1.ComboBoxBitRate.Text);
  dcb.ByteSize:= 8;
  dcb.Parity:= NOPARITY;  //0
  dcb.StopBits:= ONESTOPBIT;  //0

  if not SetCommState(hPort, dcb) then
    ShowMessage('Не удалось установить настройки порта');

  SetupComm(hPort, MAXBUF, MAXBUF);

  cto.ReadIntervalTimeout:= 1000;
  cto.ReadTotalTimeoutMultiplier:= 0;
  cto.ReadTotalTimeoutConstant:= 1000;  //500
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

  connected_flag:= true;
end;

//function ComPortRead(var size: Integer): Integer;
function ComPortRead: Byte;
var
  res: Byte;
begin
  ReadFile(hPort, res, 1, dwNumByte, nil);
  if dwNumByte <> 1 then begin
    read_error_flag:= true;
    result:= 0;
  end else begin
    read_error_flag:= false;
    result:= res;
  end;
end;

procedure ComPortWrite(bait: Byte);
begin
  WriteFile(hPort, bait, 1, dwNumByte, nil);
end;

procedure TelegramSend(mes_length: Integer; mes_data: array of Byte);
begin
  WriteFile(hPort, mes_data, mes_length, dwNumByte, nil);
end;

function ReadPort(var Buf; Size: Word): Integer;
var
  i: Cardinal;
  ovr: TOverlapped;
begin
  FillChar(Buf, Size, 0);
  FillChar(ovr, SizeOf(ovr), 0);
  i := 0;
  result := -1;
  if not Windows.ReadFile(hPort, Buf, Size, i, @ovr) then exit;
  result := i;
end;

procedure PortClear;
begin
  ComPortClose;
  Sleep(500);
  ComPortOpen;

//  if not PurgeComm(hPort, PURGE_TXCLEAR or PURGE_RXCLEAR) then
//    ShowMessage('Не удалось очистить порт');
end;

end.

