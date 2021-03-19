unit echo_tester;

{$mode objfpc}{$H+}

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, FileUtil, StdCtrls, ExtCtrls;

type

  { TMainForm }

  TMainForm = class(TForm)
    ExitButton: TButton;
    StartButton: TButton;
    SelPortComboBox: TComboBox;
    SelSpeedComboBox: TComboBox;
    TestOKPanel: TPanel;
    TestErrPanel: TPanel;
    CurrModePanel: TPanel;
    procedure ExitButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure SelPortComboBoxChange(Sender: TObject);
    procedure SelSpeedComboBoxChange(Sender: TObject);
    procedure StartButtonClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  MainForm: TMainForm;
  COMPortHandle: THandle;
  portname: String;
  connspeed: Cardinal;
  usedport: PChar;
  stopprocessin_flag: Boolean;
  processing_flag: Boolean;

implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  // Free all the taken resorces
  stopprocessin_flag:=true;
end;

procedure TMainForm.ExitButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  // Initialize random number generator
  Randomize;
  //Set up process priority
  if (not SetPriorityClass(GetCurrentProcess, HIGH_PRIORITY_CLASS)) then begin
    MessageDlg('Не удалось установить необходимый класс приоритета процесса.', mtError, [mbOK], 0);
    Close;
  end;
  //Set up thread priority
  if(not SetThreadPriority(GetCurrentThread, THREAD_PRIORITY_TIME_CRITICAL)) then begin
    MessageDlg('Не удалось установить необходимый приоритет потока.', mtError, [mbOK], 0);
    Close;
  end;

  portname:= '\\.\COM1';
  connspeed:= CBR_57600;
  stopprocessin_flag:= false;
  processing_flag:= false;
end;

procedure TMainForm.SelPortComboBoxChange(Sender: TObject);
begin
   portname:='\\.\'+ SelPortComboBox.Text;
end;

procedure TMainForm.SelSpeedComboBoxChange(Sender: TObject);
begin
    case StrToInt(SelSpeedComboBox.Text) of
    115200: connspeed:= CBR_115200;
    57600:  connspeed:= CBR_57600;
    38400:  connspeed:= CBR_38400;
    14400:  connspeed:= CBR_14400;
    else begin
       SelSpeedComboBox.Text:= '57600';
       connspeed:= CBR_57600;
    end;
  end;
end;

procedure TMainForm.StartButtonClick(Sender: TObject);
var
  realwrite, realcount: Cardinal;
  ch: Char; dcb: TDCB; cto: TCommTimeouts;
  i: Integer;
  datatosend, datatocheck, currmode: Char;
begin
  //Initialize array
  if processing_flag then Exit;
  processing_flag:= true;
  StartButton.Enabled:= false;
  TestErrPanel.Color:= clBtnFace;
  TestOKPanel.Color:= clBtnFace;
  CurrModePanel.Caption:= 'Текущий режим: ';
  currmode:= Char(255);
  usedport:= PChar(portname);

  // Create COM1 handle
  COMportHandle:= CreateFile(
        usedport, //Port name
        GENERIC_READ or GENERIC_WRITE, // R/W access
        0, // Exclisive access
        nil, // No protection
        OPEN_EXISTING, // Open em
        FILE_ATTRIBUTE_NORMAL, // Synchro mode
        0 // Always 0
  );

  Application.ProcessMessages;
  if COMportHandle=INVALID_HANDLE_VALUE then begin
    Beep;
    //MessageDlg('Can''t open '+usedport+' port!', mtError, [mbOK], 0);
    MessageDlg('Не удалось открыть порт '+usedport+'!', mtError, [mbOK], 0);
    processing_flag:= false;
    StartButton.Enabled:= true;
    Exit;
  end;

  Application.ProcessMessages;

  // Set up COM1 options
  FillChar(dcb, SizeOf(TDCB), 0); // Clear the structure
  dcb.DCBlength:= SizeOf(dcb);
  dcb.BaudRate:= connspeed; // Set up baud rate
  dcb.Flags:= 1; // Binary mode
  dcb.ByteSize:= 8; // 8 data bits
  dcb.Parity:= 0; // No parity checking
  dcb.StopBits:= 0; // 1 stop bit
  SetCommState(COMportHandle, dcb);

  //Set up timeouts
  FillChar(cto, SizeOf(TCommTimeouts), 0); // Clear the structure
  cto.ReadIntervalTimeout:= MAXDWORD;
  SetCommTimeouts(COMportHandle,cto);

  //Clear the buffer
  repeat
    ReadFile(COMportHandle, ch, 1, RealCount, nil);
  until RealCount=0;

  //Send the request
  Application.ProcessMessages;
  for i := 1 to 456 do begin
    //Initialize tyemporary variables
    datatosend:=Char(Random(255));
    datatocheck:= Char(0);
    //Send the request
    WriteFile(COMportHandle, datatosend, 1, realwrite, nil);
    Sleep(20);
    //Get the response
    ReadFile(COMportHandle, currmode, 1, RealCount, nil);
    if RealCount <> 1 then begin
      TestErrPanel.Color:=clRed;
      // MessageDlg('Device have NOT answered!', mtError, [mbOK], 0);
      MessageDlg('Устройство не ответило на запрос!', mtError, [mbOK], 0);
      processing_flag:= false;
      CloseHandle(COMportHandle);
      StartButton.Enabled:= true;
      Application.ProcessMessages;
      Exit;
    end
    else if (currmode > Char(5)) then TestErrPanel.Color:= clRed;

    ReadFile(COMportHandle, datatocheck, 1, RealCount, nil);
    if RealCount <> 1 then
      TestErrPanel.Color:=c lRed
    else if datatocheck <> datatosend then 
      TestErrPanel.Color:= clRed;
  end;

  if TestErrPanel.Color= clBtnFace then begin
    TestOKPanel.Color:= clGreen;
    CurrModePanel.Caption:='Текущий режим: '+inttostr(Byte(currmode)+1);
  end else
    CurrModePanel.Caption:='Текущий режим: не определён.';
  
  //Free some resources
  CloseHandle(COMportHandle);
  StartButton.Enabled:= true;
  Application.ProcessMessages;
  processing_flag:= false;
end;

end.
