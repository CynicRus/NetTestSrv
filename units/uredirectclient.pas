unit uredirectclient;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,lNet, usettings, LConvEncoding;

type

TRedirectClient = class
  private
    FConnected: boolean;
    FKeepConnection: boolean;
    FLastError: integer;
    FLastErrorDesc: string;
    FData: string;
  public
    procedure SendData(Data: string);virtual; abstract;
    function GetData(): string;virtual; abstract;
    property KeepConnection: boolean read FKeepConnection write FKeepConnection;
    property Connected: boolean read FConnected write FConnected;
    property LastError: integer read FLastError write FLastError;
    property LastErrorDesc: string read FLastErrorDesc write FLastErrorDesc;
  end;

{ TTCPRedirectClient }

TTCPRedirectClient = class(TRedirectClient)
  private
    FConnector: TLTcp;
    FIP: string;
    FPort: string;
    procedure Connect;
    procedure Disconnect;
    procedure OnDisconnect(aSocket: TLSocket);
    procedure OnRecieve(aSocket: TLSocket);
    procedure OnError(const msg: string; aSocket: TLSocket);
  public
    constructor Create;
    destructor Destroy; override;
    procedure SendData(Data: string);override;
    function GetData(): string;override;
    property KeepConnection;
    property Connected;
    property LastError;
    property LastErrorDesc;
  end;

{ TUDPRedirectClient }

TUDPRedirectClient = class(TRedirectClient)
  private
    FConnector: TLUdp;
    FIP: string;
    FPort: string;
    procedure Connect;
    procedure Disconnect;
    procedure OnDisconnect(aSocket: TLSocket);
    procedure OnRecieve(aSocket: TLSocket);
    procedure OnError(const msg: string; aSocket: TLSocket);
  public
    constructor Create;
    destructor Destroy; override;
    procedure SendData(Data: string);override;
    function GetData(): string;override;
   // property KeepConnection;
    //property Connected;
    property LastError;
    property LastErrorDesc;
  end;

{ TRedirectClientFactory }

TRedirectClientFactory = class
public
  class function GetInstance(ClientType: integer): TRedirectClient;
end;

implementation

{ TRedirectClientFactory }

class function TRedirectClientFactory.GetInstance(ClientType: integer): TRedirectClient;
begin
  case ClientType of
    0: Result := TTCPRedirectClient.Create;
    1: Result := TUDPRedirectClient.Create;
  end;
end;

{ TUDPRedirectClient }

procedure TUDPRedirectClient.Connect;
begin
 if not FConnector.Connect(FIP,StrToInt(FPort)) then
    begin
      LastError:=1;
      LastErrorDesc:='Cannot connect to ' + FIP + ' !';
    end else
      FConnector.CallAction;
end;

procedure TUDPRedirectClient.Disconnect;
begin
  FConnector.Disconnect(true);
  FConnector.CallAction;
end;

procedure TUDPRedirectClient.OnDisconnect(aSocket: TLSocket);
begin
  LastError := -1;
  FLastErrorDesc := 'Disconnect from server: ' + aSocket.PeerAddress;
end;

procedure TUDPRedirectClient.OnRecieve(aSocket: TLSocket);
var
  s: string;
begin
  if aSocket.GetMessage(s) > 0 then
  FData := s;
end;

procedure TUDPRedirectClient.OnError(const msg: string; aSocket: TLSocket);
begin
  FLastError := 1;
  FLastErrorDesc := 'Error:' + CP1251ToUTF8(msg);
end;

constructor TUDPRedirectClient.Create;
var
  ConCfg: TTCPIPRedirectSettings;
begin
  FConnector := TLUDP.Create(nil);
  FConnector.OnError := @OnError;
  FConnector.OnReceive := @OnRecieve;
  FConnector.OnDisconnect := @OnDisconnect;
  FConnector.Timeout := 100;
  ConCfg := TTCPIPRedirectSettings(Settings.RedirectSettings);
  FIP := ConCfg.IPAddr;
  FPort := ConCfg.Port;
end;

destructor TUDPRedirectClient.Destroy;
begin
  FConnector.Free;
  inherited Destroy;
end;

procedure TUDPRedirectClient.SendData(Data: string);
begin
  FData := '';
  Connect;//подключились
  FConnector.SendMessage(Data);//отправили
  FConnector.CallAction;//получили гипотетический ответ
  Sleep(100);//чутка подождали
  Disconnect();//отключились
end;

function TUDPRedirectClient.GetData: string;
begin
  result := FData;
end;

{ TTCPRedirectClient }

procedure TTCPRedirectClient.Connect;
begin
  if not FConnector.Connect(FIP,StrToInt(FPort)) then
    begin
      LastError:=1;
      LastErrorDesc:='Cannot connect to ' + FIP + ' !';
    end else
    begin
      FConnector.CallAction;
      Connected := true;
    end;
end;

procedure TTCPRedirectClient.Disconnect;
begin
  FConnector.Disconnect(true);
  Connected := false;
  FConnector.CallAction;
end;

procedure TTCPRedirectClient.OnDisconnect(aSocket: TLSocket);
begin
  LastError := -1;
  FLastErrorDesc := 'Disconnect from server: ' + aSocket.PeerAddress;
  Connected := false;
end;

procedure TTCPRedirectClient.OnRecieve(aSocket: TLSocket);
var
  s: string;
begin
  if aSocket.GetMessage(s) > 0 then
  FData := s;
end;

procedure TTCPRedirectClient.OnError(const msg: string; aSocket: TLSocket);
begin
  FLastError := 1;
  FLastErrorDesc := 'Error:' + CP1251ToUTF8(msg);
end;

constructor TTCPRedirectClient.Create;
var
  ConCfg: TTCPIPRedirectSettings;
begin
  FConnector := TLTCP.Create(nil);
  FConnector.OnError := @OnError;
  FConnector.OnReceive := @OnRecieve;
  FConnector.OnDisconnect := @OnDisconnect;
  FConnector.Timeout := 100;
  ConCfg := TTCPIPRedirectSettings(Settings.RedirectSettings);
  FIP := ConCfg.IPAddr;
  FPort := ConCfg.Port;

end;

destructor TTCPRedirectClient.Destroy;
begin
  FConnector.Free;
  inherited Destroy;
end;

procedure TTCPRedirectClient.SendData(Data: string);
begin
  if not Connected then
  Connect;
  FData := '';
  FConnector.SendMessage(Data);
  FConnector.Callaction;
end;

function TTCPRedirectClient.GetData(): string;
begin
  result := FData;
end;

end.

