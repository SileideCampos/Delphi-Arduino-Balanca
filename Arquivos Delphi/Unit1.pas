unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ListBox,
  FMX.Layouts, FMX.StdCtrls, FMX.MultiView, FMX.DateTimeCtrls, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, FMX.Memo, Xml.xmldom,
  Xml.XMLIntf, Xml.XMLDoc, System.Sensors, System.Sensors.Components,
  Androidapi.JNIBridge,
  Androidapi.JNI.JavaTypes, Androidapi.JNI.Os, Androidapi.Helpers,
  Xml.XmlTransform, FMX.ExtCtrls, FMX.Objects, FMX.Ani, FMX.ListView.Types,
  FMX.ListView, FMX.Filter, FMX.VirtualKeyboard,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.Bitmap,
  //Androidapi.Jni,
  Androidapi.NativeWindow,
  Androidapi.JNI.Util,
  Androidapi.Input,
  Androidapi.JNI.Bluetooth,
  Androidapi.IOUtils,
  Androidapi.JNI.Widget,
  System.Bluetooth,
  FMX.Edit,
  System.Rtti, FMX.Grid, Data.Bind.GenData,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, Data.Bind.Components, Data.Bind.ObjectScope,
  FMX.Controls.Presentation, Data.DbxSqlite, Data.FMTBcd, Data.Bind.DBScope,
  Data.DB, Data.SqlExpr, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Comp.Client,
  System.IOUtils, FireDAC.FMXUI.Wait, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteDef, FireDAC.Phys.SQLite, FireDAC.Comp.UI,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FMX.Colors, FMX.Effects, FMX.Filter.Effects,
  FMX.MediaLibrary.Actions, System.Actions, FMX.ActnList, FMX.StdActns,
  Fmx.Bind.Grid, Data.Bind.Grid, DataSnap.DBClient,
  Data.Bind.DBXScope, FMX.TabControl, FMXTee.Engine, FMXTee.Series,
  FMXTee.Procs, FMXTee.Chart, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, System.Bluetooth.Components;
type
  TForm1 = class(TForm)
    ScaledLayout1: TScaledLayout;
    Chart1: TChart;
    Series1: TPieSeries;
    Panel1: TPanel;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    TabItem2: TTabItem;
    TabControl2: TTabControl;
    TabItem3: TTabItem;
    TabItem4: TTabItem;
    Rectangle6: TRectangle;
    Edit3: TEdit;
    Label6: TLabel;
    SpeedButton7: TSpeedButton;
    ListView6: TListView;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Label3: TLabel;
    Button2: TButton;
    Button5: TButton;
    ListView1: TListView;
    Bluetooth1: TBluetooth;
    procedure ListView6PullRefresh(Sender: TObject);
    procedure ListView6ItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure TabControl1Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    //procedure calcularCaloria;
    function Conectar: boolean;
    procedure Bluetooth(Sender: TObject);
    procedure PairedDevices;
    procedure DiscoverDevices(Sender: TObject);
    function ManagerConnected: Boolean;
    procedure DevicesDiscoveryEnd(const Sender: TObject;
      const ADevices: TBluetoothDeviceList);
    function enviar: String;
    { Private declarations }
  public
    { Public declarations }
    LItem             : TListViewItem;
    conectado         : boolean;
    Adapter     : JBluetoothAdapter;
    Dispositivo : JBluetoothDevice;
    Socket      : JBluetoothSocket;
    outs        : JOutputStream;
    inps        : JInputStream;
    uuid        : JUUID;
    FBluetoothManager : TBluetoothManager;
    FPairedDevices    : TBluetoothDeviceList;
    FAdapter          : TBluetoothAdapter;
    FDiscoverDevices  : TBluetoothDeviceList;


  end;

var
  Form1: TForm1;
  valorCalorico, peso: Double;

implementation

{$R *.fmx}

uses StrUtils, FMX.Helpers.Android, FMX.Platform, Android.JNI.Toast;

procedure TForm1.Button2Click(Sender: TObject);
var s: String;
begin
 try
   s := enviar;
 except
   Toast('Erro ao receber dados!');
 end;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
 Adapter := TJBluetoothAdapter.JavaClass.getDefaultAdapter;
 Adapter.enable;
 Conectar;
end;

procedure TForm1.ListView6ItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  Edit3.Text := AItem.Detail;
end;

procedure TForm1.ListView6PullRefresh(Sender: TObject);
begin
  Bluetooth(Sender);
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
var s: String;
begin
  try
    s := enviar;
  except
    Toast('Erro ao receber dados!');
  end;
end;

procedure TForm1.TabControl1Change(Sender: TObject);
begin
  if TabControl1.TabIndex = 2 then
    Bluetooth(Sender);
end;

Function TForm1.Conectar: boolean;
var
  len,i:integer;
  s:string;
  buffer:TJavaArray<byte>;
begin
try
  Adapter := TJBluetoothAdapter.JavaClass.getDefaultAdapter;
  Dispositivo :=  Adapter.getRemoteDevice(StringToJString(StringReplace(edit3.text, '.', ':' , [rfReplaceAll])));
  Socket := Dispositivo.createRfcommSocketToServiceRecord(uuid);
  Socket.connect;
  conectado := Socket.isConnected;
  if conectado then
    Toast('Conectado!', LongToast)
  else
    Toast('Dispositivo desconectado!', LongToast);
except
  conectado := false;
  Toast('Não foi possível conectar ao dispositivo!', LongToast);
end;
end;

procedure TForm1.Bluetooth(Sender: TObject);
begin
  ListView6.Items.Clear;
  LItem := ListView6.Items.Add;
  PairedDevices;
  DiscoverDevices(Sender);
end;

procedure TForm1.PairedDevices;
var
  I: Integer;
begin
  FBluetoothManager := TBluetoothManager.Current;
  FAdapter := FBluetoothManager.CurrentAdapter;
  if ManagerConnected then
  begin
    FPairedDevices := FBluetoothManager.GetPairedDevices;
    if FPairedDevices.Count > 0 then
    begin
      for I:= 0 to FPairedDevices.Count - 1 do
      begin
        LItem.Text   := FPairedDevices[I].DeviceName;
        LItem.Detail := FPairedDevices[I].Address;
      end;
    end
    else
      LItem.Text     := 'No Paired Devices';
 end;
end;

procedure TForm1.DiscoverDevices(Sender: TObject);
begin
  if ManagerConnected then
  begin
    FAdapter := FBluetoothManager.CurrentAdapter;
    FBluetoothManager.StartDiscovery(10000);
    FBluetoothManager.OnDiscoveryEnd := DevicesDiscoveryEnd;
  end;
end;

Function TForm1.enviar: String;
var
  str: Byte;
  i, j: integer;
  s, r: String;
  valor: Double;
  valorCalorico2: String;
  vetor: array [0..7] of Byte;
  input : JInputStream;
begin
 try
   j := 0; r := '';
   if Socket.isConnected then
   begin
     outs := Socket.getOutputStream();
     outs.write(Ord('p'));  // envia
     sleep(1000);
     input := Socket.getInputStream;
     for j := 0 to input.available-1 do
     begin
       vetor[0] := input.read;
       s := s +  IntToStr(Ord(vetor[0]));
       if (IntToStr(Ord(vetor[0])) <> '#10') and (IntToStr(Ord(vetor[0])) <> #10) then
         r := r + (Chr(vetor[0]));
     end;
      Label3.Text:= StringReplace(r, '.', ',', [rfReplaceAll, rfIgnoreCase]);
   end;
 finally
   Result := r;
 end;
end;

function TForm1.ManagerConnected:Boolean;
begin
  if FBluetoothManager.ConnectionState = TBluetoothConnectionState.Connected then
    Result := True
  else
  begin
    Result := False;
    Toast('Dispositivos Bluetooth n�o encontrados', ShortToast);
  end
end;

procedure TForm1.DevicesDiscoveryEnd(const Sender: TObject; const ADevices: TBluetoothDeviceList);
begin
  TThread.Synchronize(nil, procedure
  var
    I: Integer;
  begin
    FDiscoverDevices := ADevices;
    for I := 0 to ADevices.Count - 1 do
    begin
      LItem.Text      := ADevices[I].DeviceName;
      LItem.Detail    := ADevices[I].Address;
      LItem.ButtonText:= 'N�o Pareado';
    end;
  end);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Adapter.disable;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  uuid := TJUUID.JavaClass.fromString(stringtojstring('00001101-0000-1000-8000-00805F9B34FB'));
  Adapter := TJBluetoothAdapter.JavaClass.getDefaultAdapter;
  Adapter.enable;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  peso := 0.00;
  Bluetooth(Sender);
end;

end.
