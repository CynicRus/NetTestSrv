unit usettings;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, IniFiles, ujson{$IFDEF DARWIN},MACOSAll{$ENDIF};


const
  Configfile = 'NetTestSrv.ini';

type

  TConnectionSettings = class
  public
    function AsJson: string; virtual; abstract;
    procedure fromJson(const Json: string); virtual; abstract;
  end;

  { TTCPIpConnectionSettings }

  TTCPIpConnectionSettings = class(TConnectionSettings)
  private
    FIP: string;
    FPort: string;
    FServerType: integer;
  public
    function AsJson: string; override;
    procedure fromJson(const Json: string); override;
    property IPAddr: string read FIP write FIP;
    property Port: string read FPort write FPort;
    property ServerType: integer read FServerType write FServerType;
  end;

  { TTCPIpRedirectSettings }

  TTCPIpRedirectSettings = class(TConnectionSettings)
  private
    FIP: string;
    FPort: string;
  public
    function AsJson: string; override;
    procedure fromJson(const Json: string); override;
    property IPAddr: string read FIP write FIP;
    property Port: string read FPort write FPort;
  end;

  { TSettings }

  TSettings = class
  private
    {$IFDEF WINDOWS}
    FPortable: boolean;
    {$ENDIF}
    FConnectionSettings: TConnectionSettings;
    FServerType: integer;
    FUseRedirect: boolean;
    FRedirectSettings: TTCPIpRedirectSettings;
    //FId: integer;
    FLangIndex: integer;
    FScriptPath: string;
    FUseInbuiltDataDump: boolean;
    FFirstRun: boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Load;
    procedure Save;
    procedure ChangeConnectionSettings(const Data: string);
    procedure ChangeRedirectSettings(const Data: string);
    property ServerType: integer read FServerType write FServerType;
    property ConnectionSettings: TConnectionSettings read FConnectionSettings;
    property RedirectSettings: TTCPIpRedirectSettings read FRedirectSettings;
    property DataProcessingScript: string read FScriptPath write FScriptPath;//текущий скрипт для обработки
    property UseInbuiltDataDump: boolean read FUseInbuiltDataDump
      write FUseInbuiltDataDump;
    property LangIndex: integer read FLangIndex write FLangIndex;
    property UseRedirect: boolean read FUseRedirect write FUseRedirect;
    property FirstRun: boolean read FFirstRun write FFirstRun;
    {$IFDEF WINDOWS}
    property Portable: boolean read FPortable write FPortable;
    {$ENDIF}
    //property Id: integer read FId write FId;
  end;

var
  ConfigPath: string;
  Settings: TSettings;

implementation

procedure StringArrayToList(AList: TStrings; const AStrings: array of string);
var
  Cpt: integer;
begin
  for Cpt := Low(AStrings) to High(AStrings) do
    AList.Add(AStrings[Cpt]);
end;

{ TTCPIpRedirectSettings }

function TTCPIpRedirectSettings.AsJson: string;
var
  Obj: TJsonObject;
begin
  Obj := TJsonObject.Create();
  try
    Obj.put('ip', ipaddr);
    Obj.put('port', port);

    Result := Obj.toString();
  finally
    Obj.Free;
  end;

end;

procedure TTCPIpRedirectSettings.fromJson(const Json: string);
var
  Obj: TJsonObject;
begin
  Obj := TJsonObject.Create(Json);
  try
    IpAddr := Obj.optString('ip');
    Port := Obj.optString('port');
  finally
    Obj.Free;
  end;

end;


{ TSettings }

constructor TSettings.Create;
begin

end;

destructor TSettings.Destroy;
begin

end;

procedure TSettings.Load;
var
  Ini: TIniFile;
begin
  Ini := nil;
  Ini := TIniFile.Create(ConfigPath);
  try
    ServerType := Ini.ReadInteger('Server', 'ServerType', 0);
    ChangeConnectionSettings(Ini.ReadString('Server','Configuration','{"ip":"127.0.0.1","port":"5050","server_type":0}'));
    {$IFDEF WINDOWS}
    DataProcessingScript := Ini.ReadString('Application', 'Script', ExtractFilePath(ParamStr(0))+'scripts\script.lp');
    {$ENDIF}
    {$IFDEF DARWIN}
     DataProcessingScript := Ini.ReadString('Application', 'Script', ExpandFileName('~/Library/Preferences/')+'NetTestSrv/script.lp');
    {$ENDIF}
    UseInbuiltDataDump := Ini.ReadBool('Application', 'DataDump', True);
    UseRedirect := Ini.ReadBool('Application','Redirect', False);
    ChangeRedirectSettings(Ini.ReadString('Application','RedirectConf','{"ip":"127.0.0.1","port":"5050"}'));
    LangIndex := Ini.ReadInteger('Application', 'Lang', 0);
    FirstRun := Ini.ReadBool('Application','FirstRun',true);
    //Id := Ini.ReadInteger('Application','ID',1);
  finally
    Ini.Free;
  end;
end;

procedure TSettings.Save;
var
  Ini: TIniFile;
begin
  Ini := nil;
  Ini := TIniFile.Create(ConfigPath);
  try
    //{ ToDo: сделать обработку выполнения, что такая штука выполняется только перед первым запуском
    //ChangeConnectionSettings('{"ip":"127.0.0.1","port":"5050","server_type":0}');
    //ChangeRedirectSettings('{"ip":"127.0.0.1","port":"5050"}');
    //}
    Ini.WriteInteger('Server', 'ServerType', ServerType);
    Ini.WriteString('Server', 'Configuration', ConnectionSettings.AsJson);
    {$IFDEF WINDOWS}
    if FirstRun then
    DataProcessingScript := ExtractFilePath(ParamStr(0))+'scripts\script.lp';
    {$ENDIF}
    {$IFDEF DARWIN}
    if FirstRun then
     DataProcessingScript:= ExpandFileName('~/Library/Preferences/')+'NetTestSrv/script.lp';
    {$ENDIF}

    Ini.WriteString('Application', 'Script', DataProcessingScript); //todo переменная не заполнена на первом запуске
    Ini.WriteBool('Application', 'DataDump', UseInbuiltDataDump);
    Ini.WriteBool('Application','Redirect',UseRedirect);
    Ini.WriteString('Application','RedirectConf',RedirectSettings.AsJson);
    Ini.WriteInteger('Application', 'Lang', LangIndex);
    Ini.WriteBool('Application','FirstRun',FirstRun);
    //Ini.WriteInteger('Application','ID',id);
  finally
    Ini.Free;
  end;
end;

procedure TSettings.ChangeConnectionSettings(const Data: string);
begin
  if ConnectionSettings <> nil then
     ConnectionSettings.Free;
  FConnectionSettings := TTCPIPConnectionSettings.Create;
  ConnectionSettings.fromJson(data);
end;

procedure TSettings.ChangeRedirectSettings(const Data: string);
begin
  if RedirectSettings <> nil then
     RedirectSettings.Free;
  FRedirectSettings := TTCPIpRedirectSettings.Create;
  RedirectSettings.fromJson(data);
end;

{ TTCPIpConnectionSettings }

function TTCPIpConnectionSettings.AsJson: string;
var
  Obj: TJsonObject;
begin
  Obj := TJsonObject.Create();
  try
    Obj.put('ip', ipaddr);
    Obj.put('port', port);
    Obj.put('server_type',ServerType);

    Result := Obj.toString();
  finally
    Obj.Free;
  end;

end;

procedure TTCPIpConnectionSettings.fromJson(const Json: string);
var
  Obj: TJsonObject;
begin
  Obj := TJsonObject.Create(Json);
  try
    IpAddr := Obj.optString('ip');
    Port := Obj.optString('port');
    ServerType := Obj.optInt('server_type');
  finally
    Obj.Free;
  end;

end;

initialization
  //AppPath := ExtractFilePath(ParamStr(0));
  {$IFDEF WINDOWS}
  ConfigPath := ExtractFilePath(ParamStr(0)) + 'config\' + ConfigFile;
  {$ENDIF}
  {$IFDEF DARWIN}
  ConfigPath := ExpandFileName('~/Library/Preferences/')+'NetTestSrv/'+ConfigFile;
  {$ENDIF}
  {$IFDEF LINUX}
  ConfigPath := GetAppConfigDir(true) + ConfigFile;
  {$ENDIF}

  Settings := TSettings.Create;
  Settings.Load;
  if Settings.FirstRun then
  begin
  Settings.FirstRun := False;
  Settings.Save;
  end;

finalization
  if Settings <> nil then
    Settings.Free;

end.
