procedure TMainForm.ComboBoxPortDropDown(Sender: TObject);
var
  reg: TRegistry;
  key: String;
  list: TStringList;
  //list_port: TStringList;
  i: Integer;
begin
  ComboBoxPort.Clear;
  ListBoxPort.Clear;

  list:= TStringList.Create;
  reg:= TRegistry.Create;
  key:= 'HARDWARE\DEVICEMAP\SERIALCOMM';  //'HKEY_LOCAL_MACHINE\HARDWARE\DEVICEMAP\SERIALCOMM'

  try
    reg.RootKey:= HKEY_LOCAL_MACHINE;
    reg.OpenKeyReadOnly(key);  //reg.OpenKey(key, false);
    reg.GetValueNames(list);
    for i:= 0 to list.Count - 1 do
      ListBoxPort.Items.Add(reg.ReadString(list[i]));
    for i:= 0 to ListBoxPort.Items.Count - 1 do
      if ComPortScan(ListBoxPort.Items[i]) then
        ComboBoxPort.Items.Add(ListBoxPort.Items[i]);
  finally
    reg.CloseKey;
    reg.Free;
    list.Free;
  end;
end;
