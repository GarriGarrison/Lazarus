unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, BlckSock, Windows, Messages, Variants;



type

  { TMainForm }

  TMainForm = class(TForm)
    btnConnect: TButton;
    dtnSend: TButton;
    edAddress: TEdit;
    edPort: TEdit;
    edRequestString: TEdit;
    lbResponseStr: TEdit;
    timerSend: TTimer;
    procedure btnConnectClick(Sender: TObject);
    procedure dtnSendClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
  private
    Client: TTCPBlockSocket;
  public
    { public declarations }
  end;

resourcestring
  rsConnected = 'Подключено';

const
  cReadTimeout = 10000;


var
  MainForm: TMainForm;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.btnConnectClick(Sender: TObject);
begin
  Client:= TTCPBlockSocket.Create;//создаем объект
  Client.RaiseExcept:= true;//показываем все исключения Winsock
  Client.Connect(edAddress.Text,edPort.Text);//пробуем соединиться с сервером
  ShowMessage(rsConnected);
end;

procedure TMainForm.dtnSendClick(Sender: TObject);
begin
  Client.SendString(edRequestString.Text);//отправляем строку на сервер
  lbResponseStr.Caption:= Client.RecvPacket(cReadTimeout);//пробуем получить ответ
  timerSend.Enabled:= true;
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Client.Free;
end;

procedure TMainForm.TimerSendTimer(Sender: TObject);
begin
  dtnSend.Click;
end;

end.
