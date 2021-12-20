unit view;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, Windows,
  StdTypes;


procedure ViewSector(num, state: uint8_t);  //отображение состояний секторов
procedure ViewAuraDisabled;  //отключение рамки (выключение СОМ-порта)
procedure ViewBeep(beep_type: uint8_t);  //пищак при тех или иных событиях


const
  VIEW_STATE_DISABLE = 0;  //сектор отключен
  VIEW_STATE_READY = 1;  //сектор в дежурном режиме
  VIEW_STATE_ALARAM_FERROUS = 2;  //тревога -> чёрный металл
  VIEW_STATE_ALARM_PRECIOUS = 3;  //тревога -> цветной металл


implementation

uses
  main, global;

procedure ViewSector(num, state: uint8_t);
begin
  with MainForm do begin
    if num = 1  then ImageList1.GetBitmap(state,  Image1.Picture.Bitmap);
    if num = 2  then ImageList2.GetBitmap(state,  Image2.Picture.Bitmap);
    if num = 3  then ImageList3.GetBitmap(state,  Image3.Picture.Bitmap);
    if num = 4  then ImageList4.GetBitmap(state,  Image4.Picture.Bitmap);
    if num = 5  then ImageList5.GetBitmap(state,  Image5.Picture.Bitmap);
    //if num = 6  then ImageList6.GetBitmap(state,  Image6.Picture.Bitmap);
    if num = 7  then ImageList7.GetBitmap(state,  Image7.Picture.Bitmap);
    if num = 8  then ImageList8.GetBitmap(state,  Image8.Picture.Bitmap);
    if num = 9  then ImageList9.GetBitmap(state,  Image9.Picture.Bitmap);
    if num = 10 then ImageList10.GetBitmap(state, Image10.Picture.Bitmap);
    if num = 11 then ImageList11.GetBitmap(state, Image11.Picture.Bitmap);
    if num = 12 then ImageList12.GetBitmap(state, Image12.Picture.Bitmap);
    if num = 13 then ImageList13.GetBitmap(state, Image13.Picture.Bitmap);
    if num = 14 then ImageList14.GetBitmap(state, Image14.Picture.Bitmap);
    if num = 15 then ImageList15.GetBitmap(state, Image15.Picture.Bitmap);
    if num = 16 then ImageList16.GetBitmap(state, Image16.Picture.Bitmap);
    if num = 17 then ImageList17.GetBitmap(state, Image17.Picture.Bitmap);
    if num = 18 then ImageList18.GetBitmap(state, Image18.Picture.Bitmap);
  end;
end;

procedure ViewAuraDisabled;
begin
  with MainForm do begin
    ImageListPort.GetBitmap(0, BtnPort.Picture.Bitmap);
    ShapeConnect.Brush.Color:= clSilver;
    ImageList1.GetBitmap(0,  Image1.Picture.Bitmap);
    ImageList2.GetBitmap(0,  Image2.Picture.Bitmap);
    ImageList3.GetBitmap(0,  Image3.Picture.Bitmap);
    ImageList4.GetBitmap(0,  Image4.Picture.Bitmap);
    ImageList5.GetBitmap(0,  Image5.Picture.Bitmap);
    ImageList6.GetBitmap(0,  Image6.Picture.Bitmap);
    ImageList7.GetBitmap(0,  Image7.Picture.Bitmap);
    ImageList8.GetBitmap(0,  Image8.Picture.Bitmap);
    ImageList9.GetBitmap(0,  Image9.Picture.Bitmap);
    ImageList10.GetBitmap(0, Image10.Picture.Bitmap);
    ImageList11.GetBitmap(0, Image11.Picture.Bitmap);
    ImageList12.GetBitmap(0, Image12.Picture.Bitmap);
    ImageList13.GetBitmap(0, Image13.Picture.Bitmap);
    ImageList14.GetBitmap(0, Image14.Picture.Bitmap);
    ImageList15.GetBitmap(0, Image15.Picture.Bitmap);
    ImageList16.GetBitmap(0, Image16.Picture.Bitmap);
    ImageList17.GetBitmap(0, Image17.Picture.Bitmap);
    ImageList18.GetBitmap(0, Image18.Picture.Bitmap);
  end;
end;

procedure ViewBeep(beep_type: uint8_t);
begin
  case beep_type of
  STATE_WORK_OK: begin
    Windows.Beep(2000, 350);
    Sleep(200);
    Windows.Beep(2000, 250);
    Sleep(150);
    Windows.Beep(2000, 150);
    Sleep(100);
    Windows.Beep(2000, 100);
    end;
  STATE_ALARM_FERROUS: begin
    Windows.Beep(2000, 500);
    Sleep(200);
  end;
  STATE_ALARM_PRECIOUS: begin
    Windows.Beep(2000, 350);
    Sleep(200);
    Windows.Beep(2000, 350);
    Sleep(200);
    //Windows.Beep(2000, 250);
  end;
  STATE_ALARM_BAN: begin
    Windows.Beep(2000, 100);
  end;
  end;
end;

end.
