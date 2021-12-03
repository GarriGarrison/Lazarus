unit listener;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, BlckSock, tcpread;


type
  {"Слушающая нить". Ожидает запрос на подключение и управляет потоками
  для работы с клиентами}
  TListenerThread = class(TThread)
  private
     FSocket: TTCPBlockSocket;//объект сокета
     FThreadList: TList; //список дескрипторов потоков для работы с клиентами
  protected
     procedure Execute;override;
  public
     constructor Create(ASyspended: boolean{; const AIP,APort: string});
     destructor Destroy;override;
     property Socket: TTCPBlockSocket read FSocket;
end;


implementation

uses main;

{ TListenerThread }

constructor TListenerThread.Create(ASyspended: boolean);
begin
  FSocket:= TTCPBlockSocket.Create;
  FThreadList:= TList.Create;
  inherited Create(ASyspended)
end;

destructor TListenerThread.Destroy;
var
  Thread:TTCPThread;
begin
  //завершаем все работающие нити
  while FThreadList.Count > 0 do
    begin
      Thread:= TTCPThread(FThreadList.Extract(FThreadList.Last));
      Thread.Terminate;
      Thread.WaitFor;
      Thread.Free;
    end;
  //освобождаем память
  FThreadList.Free;
  FSocket.Free;
  inherited;
end;

procedure TListenerThread.Execute;
var
  Thread:TTCPThread;
begin
  FSocket.CreateSocket;//создаем новый сокет
  //связываем сокет с локальным адресом
  //выбор номера порта оставляем на усмотрение Synapse
  //FSocket.Bind(FSocket.LocalName,'0');
  FSocket.Bind('127.0.0.1', '9090');
  if FSocket.LastError = 0 then //связываение с локальным адресом прошло успешно
     FSocket.Listen //переходим в режим ожидания
  else
    raise Exception.Create(FSocket.LastErrorDesc);//ошибка связывания - показываем её пользователю
  repeat
     if FSocket.CanRead(100) then //можем произвести чтение
       begin
         //получаем дескриптор сокета и создаем новую нить для клиента
         Thread:= TTCPThread.Create(True,FSocket.Accept);
         //определяем обработчик события ONStatus для новой нити
         Thread.Socket.OnStatus:= FSocket.OnStatus;
         //добавляем указатель на нить в список
         FThreadList.Add(pointer(T));
         //запускаем нить на выполнение
         Thread.Start;
       end;
   until Terminated;//"гуляем" по циклу до тех пор, пока пользователь не остановит
end;

end.
