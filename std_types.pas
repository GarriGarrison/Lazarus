unit std_types;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;


type
  int8_t   = -128..127;  //ShortInt
  uint8_t  =  0..255;  //Byte
  int16_t  = -32768..32767;  //SmallInt
  uint16_t =  0..65535;  //Word
  int32_t  =  -2147483648..2147483647;  //Integer, LongInt
  uint32_t =  0..4294967295;  //Cardinal, LongWord, Dword
  int64_t  = -9223372036854775808..9223372036854775807;  //Int64
  uint64_t = 0..18446744073709551615;  //QWord
  
  bool  = Boolean;
  str_t = String;
  size_t = 0..4294967295;  //Cardinal, LongWord, Dword


  //adr_t  = 0..99;  //диапазон адресов устройств на линии
  //reg_t  = $0000..$FFFF;  //диапазон адресов регисторв


implementation

end.

