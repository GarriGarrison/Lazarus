unit global;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, StdTypes;


const
    //Команды
  GET_RESPONSE       = $00;  //фиксированный отклик, эхо
  GET_HANDLE         = $01;  //резерв, дескриптор устройства
  GET_EVENT          = $02;  //запрос текущих событий

  //Состояния секторов
  STATE_WORK_OK         = $00;  //готов, дежурный режим
  STATE_ALARM_FERROUS   = $01;  //тревога, чёрный металл
  STATE_ALARM_PRECIOUS  = $02;  //тревога, цветной металл
  STATE_ALARM_BAN       = $03;  //запрет прохода (работы)


  HEADER = $AA;  //заголовок сообщения
  REQUEST_TIME = 5;  //5 сек., время ожидания ответа от устойства (5 раз в течении 1 сек.)


var
  connect_flag: bool;
  connect_error_count: uint8_t;
  sector: array [1..18] of uint8_t;
  beep_sound: uint8_t;


implementation

end.

