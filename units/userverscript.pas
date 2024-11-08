unit userverscript;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,LConvEncoding, lnet, lptypes, lpvartypes, lpparser, lpcompiler, lputils,
  lpeval, lpinterpreter, lpmessages,
  typinfo, ffi, lpffi, ulpclasses, uplugins, usettings, udatadumper,uredirectclient;

type
  TServerType = (stTCP = 0, stUDP = 1);

  { TScriptableServer }

  TScriptableServer = class(TThread)
  private
    FHost: string;
    FPort: integer;
    FServerType: TServerType;
    FCompiler: TLapeCompiler;
    FDisplayString: string;
    FParser: TLapeTokenizerBase;
    FRawData: string;
    FProcessedData: string;
    FUsedPlugins: TMPluginsList;
    FSocket: TLConnection;
    FClient: TRedirectClient;
    FUseRedirect: boolean;
    procedure OnError(const msg: string; aSocket: TLSocket);
    procedure OnAccept(aSocket: TLSocket);
    procedure OnRecieve(aSocket: TLSocket);
    procedure OnDisconnet(aSocket: TLSocket);
    procedure SendTCPData(const S: String);
    procedure SendUDPData(const S: String);
    function GetModeStr():string;
  protected
    procedure Execute; override;
    procedure RunScript();
    function Import(): boolean;
    function Compile(): boolean;
    procedure OnHint(Sender: TLapeCompilerBase; Hint: lpString);
    procedure HandleException(e: Exception);
    function OnHandleDirective(Sender: TLapeCompiler;
      Directive, Argument: lpString; InPeek, InIgnore: boolean): boolean;
  public
    constructor Create(CreateSuspended: boolean);
    destructor Destroy; override;
    procedure Display();
    procedure ClearOutput();
    procedure GetSocketData(aSocket: TLSocket);
    procedure SendSocketData(const S: string);
    property Parser: TLapeTokenizerBase read FParser;
    property Compiler: TLapeCompiler read FCompiler;
    property DisplayString: string read FDisplayString write FDisplayString;
    property RawData: string read FRawData write FRawData;
    property ProcessedData: string read FProcessedData write FProcessedData;
    property UseRedirect: boolean read FUseRedirect write FUseRedirect;

  end;

implementation
uses main;
procedure Log(Params: PParamArray); cdecl;
begin
  TScriptableServer(Params^[0]).DisplayString := PlpString(Params^[1])^;
  TScriptableServer(Params^[0]).Display;
end;

procedure ClearLog(Params: PParamArray); cdecl;
begin
  TScriptableServer(Params^[0]).ClearOutput();
end;

procedure MyWriteLn(Params: PParamArray); cdecl;
begin
  //Log(Params);
  //WriteLn();
end;

{
procedure lpExtractText(const Params: PParamArray; const result: Pointer); cdecl;
begin
  PString(result)^ := ExtractText(Pstring(Params^[0])^, PChar(Params^[1])^, PChar(Params^[2])^);
end;

procedure lpExplode(const Params: PParamArray; const result: Pointer); cdecl;
type
  PlpStringArray = ^TStringArray;
begin
  PlpStringArray(result)^ := Explode(PString(Params^[0])^, PString(Params^[1])^);
end;
}

procedure lpDumpData(const Params: PParamArray); cdecl;
begin
  DumpData(PString(Params^[0])^, PString(Params^[1])^);
end;

procedure lpSimpleDumpData(const Params: PParamArray); cdecl;
begin
  SimpleDumpData(PString(Params^[0])^);
end;

procedure getData(const Params: PParamArray; const Result: Pointer); cdecl;
begin
  PString(Result)^ := TScriptableServer(Params^[0]).RawData;
end;

procedure SetData(Params: PParamArray); cdecl;
begin
  TScriptableServer(Params^[0]).ProcessedData := PString(Params^[1])^;
end;

procedure SendData(Params: PParamArray); cdecl;
begin
  TScriptableServer(Params^[0]).SendSocketData(PString(Params^[1])^);
end;

function TScriptableServer.Import(): boolean;
begin
  Result := False;
  try
    Compiler.StartImporting();
    Compiler.addBaseDefine('LAPE');
    Compiler.addGlobalVar(ExtractFilePath(ParamStr(0)), 'WorkingDirectory');
    Compiler.addGlobalMethod('function GetData():string;', @getData, self);
    Compiler.addGlobalMethod('procedure SetData(s: string);', @SetData, self);
    Compiler.addGlobalMethod('procedure SendData(s: string);',@SendData,self);
    Compiler.addGlobalMethod('procedure _write(s: string); override;', @Log, self);
    Compiler.addGlobalMethod('procedure _writeln; override;', @MyWriteLn, self);
    Compiler.addGlobalMethod('procedure ClearScriptLog();',@ClearLog,self);
    RegisterLCLClasses(Compiler);
    Compiler.addGlobalFunc('procedure DumpData(FileName: string; Data: string);', @lpDumpData);
    Compiler.addGlobalFunc('procedure SimpleDumpData(Data: string);', @lpSimpleDumpData);
    with DefaultFormatSettings do
    begin
      Compiler.addGlobalVar(DateSeparator, 'DateSeparator');
      Compiler.addGlobalVar(TimeSeparator, 'TimeSeparator');
    end;
    {Compiler.addGlobalFunc('function ExtractText(Str: string;Delim1, Delim2: char): string;', @lpExtractText);
    Compiler.addGlobalFunc('function Explode(del, str: string): TStringArray;', @lpExplode);
    Compiler.addGlobalFunc('procedure SendCommand(const Data: string);', @lpSendCommand);
    Compiler.addGlobalFunc('function GetRecorderID():integer;',@lpGetRecorderID);}
    Compiler.EndImporting;
    Result := True;
  except
    On E: Exception do
      HandleException(E);
  end;
end;

function TScriptableServer.Compile(): boolean;
var
  T: int64;
begin
  Result := False;

  try
    T := GetTickCount64();

    if FCompiler.Compile() then
    begin
      FDisplayString := 'Compiled successfully in ' +
        IntToStr(GetTickCount64() - T) + ' ms.';
      Synchronize(@Display);
      Result := True;
    end;
  except
    on e: Exception do
      HandleException(e);
  end;
end;

procedure TScriptableServer.OnHint(Sender: TLapeCompilerBase; Hint: lpString);
begin
  FDisplayString := Hint;
  Synchronize(@Display);
end;

procedure TScriptableServer.HandleException(e: Exception);
begin
  if (e is lpException) then
    with (e as lpException) do
      FDisplayString := format('col: %d, pos %d: %s', [DocPos.Col, DocPos.Line, Message])
  else
    FDisplayString := 'ERROR: ' + e.ClassName + ' :: ' + e.Message;
  Synchronize(@Display);
  //Terminate;
  //Synchronize(@MainForm.btnServer.Click);
  //Synchronize(@MainForm.OnErrorClick);
  //Display;
end;


function TScriptableServer.OnHandleDirective(Sender: TLapeCompiler;
  Directive, Argument: lpString; InPeek, InIgnore: boolean): boolean;
var
  Plugin: TMPlugin;
  i: integer;
begin
  if (UpperCase(Directive) = 'LOADLIB') or (UpperCase(Directive) = 'ERROR') then
  begin
    if InPeek or (Argument = '') then
      exit(True);

    try
      case UpperCase(Directive) of
        'ERROR': if (not InIgnore) then
            raise Exception.Create('User defined error: "' + Argument + '"');

        'LOADLIB':
        begin
          if InIgnore then
            exit;


          Plugin := Plugins.Get(Sender.Tokenizer.FileName, Argument, True);
          FDisplayString := Format('Loading plugin....%s',
            [ExtractFileName(Plugin.FilePath)]);
          Synchronize(@Display);
          for i := 0 to Plugin.Declarations.Size - 1 do
            Plugin.Declarations[i].Import(Sender);

          FUsedPlugins.PushBack(Plugin);
          FDisplayString := 'Done.';
          Synchronize(@Display);
        end;

      end;
    except
      on e: Exception do
        raise lpException.Create(e.Message, Sender.DocPos);
    end;

    exit(True);
  end;

  exit(False);
end;

constructor TScriptableServer.Create(CreateSuspended: boolean);
var
  St: TStringList;
  ConCfg: TTCPIPConnectionSettings;
begin
  inherited Create(CreateSuspended);
  FreeOnTerminate := True;
  St := TStringList.Create;

  ConCfg := TTCPIPConnectionSettings(Settings.ConnectionSettings);
  self.FServerType:=TServerType(ConCfg.ServerType);
  case FServerType of
    stTCP: begin
      FSocket := TLTcp.Create(nil);
      TLTcp(FSocket).ReuseAddress:=true;
      TLTcp(FSocket).OnAccept:=@OnAccept;
      end;
    stUDP: begin
       FSocket := TLUdp.Create(nil);
      end;
    end;

  FSocket.OnReceive:=@OnRecieve;
  FSocket.OnDisconnect:=@OnDisconnet;
  FSocket.OnError:=@OnError;
  FSocket.Host:=ConCfg.IPAddr;
  FSocket.Port:=StrToInt(ConCfg.Port);
  FUseRedirect := Settings.UseRedirect;
  if (FUseRedirect) then
   FClient := TRedirectClientFactory.GetInstance(ConCfg.ServerType);



  FUsedPlugins := TMPluginsList.Create();
  try
    St.LoadFromFile(Settings.DataProcessingScript);

    FParser := TLapeTokenizerString.Create(st.Text);
    FCompiler := TLapeCompiler.Create(Parser);
    FCompiler.OnHandleDirective := @OnHandleDirective;
    FCompiler.OnHint := @OnHint;
    InitializeFFI(Compiler);
    InitializePascalScriptBasics(Compiler);
    ExposeGlobals(Compiler);
    Import;
    st.Free;
    Compile;
    Resume;
  except
    on E: Exception do
    begin
      HandleException(E);
      exit;
    end;
  end;
end;

destructor TScriptableServer.Destroy;
begin

  if (FUsedPlugins <> nil) then
  begin
    FreeAndNil(FUsedPlugins);
  end;
  FDisplayString := 'Stopped.';
  Synchronize(@Display);
  if (Compiler <> nil) then
    Compiler.Free()
  else if (Parser <> nil) then
    Parser.Free();
  if FSocket.Connected then
   FSocket.Disconnect(true);
  FSocket.Free;
  if UseRedirect then
   FClient.Free;
  inherited Destroy;
end;

procedure TScriptableServer.Display;
begin
  {if MainForm.LogMemo.Lines.Count > 100 then
  begin
    DumpCustomData(ExtractFilePath(ParamStr(0)) + 'logs\log.txt', MainForm.LogMemo.Lines.Text);
    MainForm.LogMemo.Lines.Clear;
  end;}
  MainForm.LogMemo.Lines.Add(FDisplayString);
end;

procedure TScriptableServer.ClearOutput;
begin
  MainForm.LogMemo.Lines.Clear();
end;

procedure TScriptableServer.GetSocketData(aSocket: TLSocket);
var
  s: string;
begin
  FRawData := '';
  if aSocket.GetMessage(s) > 0 then begin
    FDisplayString := 'Got: "'+ s + '" with length: ' + IntToStr(Length(s));
    Synchronize(@Display);
    FRawData := S;
  end;
end;

procedure TScriptableServer.SendSocketData(const S: string);
begin
  case FServerType of
    stTCP: SendTCPData(S);
    stUDP: SendUDPData(S);
  end;
end;

procedure TScriptableServer.OnError(const msg: string; aSocket: TLSocket);
begin
  FDisplayString := 'Error:' + CP1251ToUTF8(msg);
  Synchronize(@Display)
end;

procedure TScriptableServer.OnAccept(aSocket: TLSocket);
begin
  FDisplayString := 'Connection accepted from ' + aSocket.PeerAddress;
  Synchronize(@Display);
end;

procedure TScriptableServer.OnRecieve(aSocket: TLSocket);
begin
  GetSocketData(aSocket);
end;

procedure TScriptableServer.OnDisconnet(aSocket: TLSocket);
begin
  FDisplayString := 'Connetion lost from ' + aSocket.PeerAddress;
  Synchronize(@Display);
end;

procedure TScriptableServer.SendTCPData(const S: String);
var
  n: integer;
begin
  TLTCP(FSocket).IterReset; // now it points to server socket
    while TLTCP(FSocket).IterNext do begin // while we have clients to echo to
      n := TLTCP(FSocket).SendMessage(s, FSocket.Iterator);
      if n < Length(s) then
        begin
        //Writeln(); // if send fails write error
        FDisplayString := 'Unsuccessful send, wanted: ' + IntToStr(Length(s)) + ' got: ' + IntToStr(n);
        Synchronize(@Display);
        end;
    end;
  TLTCP(FSocket).CallAction;
end;

procedure TScriptableServer.SendUDPData(const S: String);
begin
  TLUDP(FSocket).SendMessage(S);
  TLUDP(FSocket).CallAction;
end;

function TScriptableServer.GetModeStr: string;
begin
  case FServerType of
    stTCP: result := 'TCP';
    stUDP: result := 'UDP';
  end;
end;



procedure TScriptableServer.Execute;
begin
  if FSocket.Listen(FSocket.Port) then
    begin
      FDisplayString := 'Create server at '+IntToStr(FSocket.Port) + ' Mode: ' +GetModeStr() ;
      Synchronize(@Display);
    end;
  FRawData := '';
  FProcessedData := '';
  while not Terminated do
  begin
    sleep(50);
    FRawData := '';
    FSocket.CallAction;
    if Length(FRawData) > 0 then
     begin
       Synchronize(@RunScript);
       FRawData := '';
     end;
    //если данные не пусты, то отправим по сокету. После чего обнулим.
    //если же нужно без последующего обнуления, то отправку данных надо делать прям из скрипта с помощью senddata
    if Length(ProcessedData) > 0 then
      begin
      if UseRedirect then
       begin
        FClient.SendData(ProcessedData);//отправим обработанные данные дальше
        self.SendSocketData(FClient.GetData());//пульнем ответ в обратку
       end else
      self.SendSocketData(ProcessedData);//просто отправляем ответа самого сервера
      //sleep(50);
      ProcessedData := '';
      end;
  end;

end;

procedure TScriptableServer.RunScript();
begin
  RunCode(Compiler.Emitter.Code, Compiler.Emitter.CodeLen);
end;

{$IF DEFINED(MSWINDOWS) AND DECLARED(LoadFFI)}
initialization
  if (not FFILoaded()) then
    LoadFFI(
    {$IFDEF Win32}
    'ffi\bin\win32'
    {$ELSE}
      'ffi\bin\win64'
    {$ENDIF}
      );
{$IFEND}
finalization

end.
