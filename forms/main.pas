unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  ExtCtrls, Menus, SynEdit, SynHighlighterPas, TreeFilterEdit, userverscript,
  usettingform, uabout, umultilang,usettings;

type
  TServerState = (ssStopped = 0, ssRunning = 1);
  TRunningState = (rsInTray = 0, rsOnFocused = 1);
  TRunCommand = (rcExit = 0, rcStartServer = 1, rcStopServer = 2,
    rcSettings = 3, rcAbout = 4, rcTray = 5, rcNewScript = 6, rcOpenScript = 7, rcSaveScript = 8);
  { TMainForm }

  TMainForm = class(TForm)
    DataGroupBox: TGroupBox;
    BtnList: TImageList;
    btnRestore: TMenuItem;
    mnuSeparator: TMenuItem;
    btnTrExit: TMenuItem;
    OpenScriptDialog: TOpenDialog;
    ScriptSaveDialog: TSaveDialog;
    StatusBar1: TStatusBar;
    separator4: TToolButton;
    newScriptBtn: TToolButton;
    openScriptBtn: TToolButton;
    saveScriptBtn: TToolButton;
    trayMenu: TPopupMenu;
    ScriptGBox: TGroupBox;
    LogMemo: TMemo;
    DataPgControl: TPageControl;
    ScriptEdit: TSynEdit;
    ScriptSyn: TSynPasSyn;
    DataTab: TTabSheet;
    ScriptTab: TTabSheet;
    btnBar: TToolBar;
    btnExit: TToolButton;
    Separator: TToolButton;
    btnTray: TToolButton;
    Separator2: TToolButton;
    btnServer: TToolButton;
    btnSettings: TToolButton;
    separator3: TToolButton;
    btnAbout: TToolButton;
    trIcon: TTrayIcon;
    procedure Button1Click(Sender: TObject);
    procedure DataPgControlChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure trIconClick(Sender: TObject);
  private
    FServerState: TServerState;
    FRunningState: TRunningState;
    procedure ToolBtnClick(Sender: TObject);
    procedure TrayPopupClick(Sender: TObject);
    procedure AppExit();
    procedure StartServer();
    procedure StopServer();
    procedure Tray();
    procedure ToTray();
    procedure FromTray();
    procedure RunSettings();
    procedure About();
    procedure NewScript();
    procedure LoadScript();
    procedure SaveScript();
  public
    property ServerState: TServerState read FServerState write FServerState;
    property RunningState: TRunningState read FRunningState write FRunningState;
    procedure RunCommand(Command: TRunCommand);

  end;

var
  MainForm: TMainForm;
  Server: TScriptableServer;
  LastActiveTab: integer;

implementation

{ TMainForm }
{$ASMMODE INTEL}




procedure TMainForm.Button1Click(Sender: TObject);
begin
  //DeleteFile(ExpandFileName('~/Library/Preferences/')+'NetTestSrv_script.lp)');
  //DeleteFile(ExpandFileName('~/Library/Preferences/')+'NetTestSrv.ini') ;
  //ScriptEdit.Lines.SaveToFile(ExpandFileName('~/Library/Preferences/')+'NetTestSrv/script.lp');
  //ScriptEdit.Lines.Clear;
  //ScriptEdit.Lines.LoadFromFile(ExpandFileName('~/Library/Preferences/')+'NetTestSrv/script.lp');
  //ScriptEdit.Lines.Add();
  //ScriptEdit.Lines.Add(GetAppConfigDir(false));
  case TButton(Sender).Tag of
    1:
    begin
      //IsWorking := True;
      //TToolButton(Sender).ImageIndex := 1;
      Server := TScriptableServer.Create(False);
      TButton(Sender).Tag := 2;
      //ConnectMenuItem.Tag := 2;
    end;
    2:
    begin
      Server.Terminate;
      //IsWorking := False;
      // TToolButton(Sender).ImageIndex := 0;
      TButton(Sender).Tag := 1;
      //ConnectMenuItem.Tag := 1;
    end;
  end;
  //SettingsFrm.ShowModal;
end;

procedure TMainForm.DataPgControlChange(Sender: TObject);
begin
  if DataPgControl.ActivePageIndex = 1 then
  begin
    newScriptbtn.Visible:=true;
    openScriptBtn.Visible:=true;
    SaveScriptBtn.Visible:=true;
  end else
  begin
   newScriptbtn.Visible:=false;
   openScriptBtn.Visible:=false;
   SaveScriptBtn.Visible:=false;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  i, j: integer;
begin
  LastActiveTab := 0;
  RunningState := rsOnFocused;
  for i := 0 to ComponentCount - 1 do
  begin
    if (Components[i] is TToolButton) then
      TToolButton(Components[i]).OnClick := @ToolBtnClick;
    if (Components[i] is TPopupMenu) then
    begin
      for j := 0 to TPopupMenu(Components[i]).Items.Count - 1 do
        TPopupMenu(Components[i]).Items[j].OnClick := @TrayPopupClick;
    end;
  end;

end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  //TCP.Free;
  //LogMemo.Lines.SaveToFile('test.txt');
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  //LanguageManager.MakeDefaultLang;
  LanguageManager.ApplyLanguage(0);
  DataPgControlChange(Sender);
  ScriptEdit.Clear;
  ScriptEdit.Lines.LoadFromFile(Settings.DataProcessingScript);
end;

procedure TMainForm.trIconClick(Sender: TObject);
begin
 RunCommand(rcTray);
end;


procedure TMainForm.ToolBtnClick(Sender: TObject);
begin
  case TToolButton(Sender).Tag of
    0: RunCommand(rcExit);
    1: RunCommand(rcTray);
    2: RunCommand(rcStartServer);
    3: RunCommand(rcSettings);
    4: RunCommand(rcAbout);
    5: RunCommand(rcStopServer);
    6: RunCommand(rcTray);
    7: RunCommand(rcNewScript);
    8: RunCommand(rcOpenScript);
    9: RunCommand(rcSaveScript);
  end;
end;

procedure TMainForm.TrayPopupClick(Sender: TObject);
begin
  case TMenuItem(Sender).Tag of
    0: RunCommand(rcTray);
    1: RunCommand(rcExit);
  end;
end;

procedure TMainForm.AppExit;
begin
  if (ServerState = ssRunning) then
    RunCommand(rcStopServer);
  Application.Terminate;
end;

procedure TMainForm.StartServer;
begin
  //DataPGControl.ActivePageIndex := DataTab.TabIndex;
  LastActiveTab := DataPgControl.ActivePageIndex;
  DataPgControl.ActivePageIndex := DataTab.TabIndex;
  DataPgControlChange(Self);
  ScriptTab.Visible := False;
  btnServer.Tag := 5;
  btnServer.ImageIndex := 4;
  ServerState := ssRunning;
  Server := TScriptableServer.Create(False);
end;

procedure TMainForm.StopServer;
begin
  Server.Terminate;
  btnServer.Tag := 2;
  btnServer.ImageIndex := 3;
  ServerState := ssStopped;
  ScriptTab.Visible := True;
  DataPgControl.ActivePageIndex := LastActiveTab;
  DataPgControlChange(Self);

end;

procedure TMainForm.Tray;
begin
  case RunningState of
    rsOnFocused: ToTray;
    rsInTray: FromTray;
  end;
end;

procedure TMainForm.ToTray;
begin
  RunningState := rsInTray;
  Hide;
  trIcon.Visible := True;
  btnTray.ImageIndex := 2;
  btnTray.Tag := 6;

end;

procedure TMainForm.FromTray;
begin
  RunningState := rsOnFocused;
  btnTray.ImageIndex := 1;
  btnTray.Tag := 1;
  WindowState := wsNormal;
  Show;
  SetFocus;
  trIcon.Visible := False;
end;

procedure TMainForm.RunSettings;
begin
  if ServerState = ssStopped then
    SettingsFrm.ShowModal
  else
    ShowMessage('ssRunning');
end;

procedure TMainForm.About;
begin
  ShowAbout('CynicRus@gmail.com', 'CynicRus', 1, 16, 2022);
end;

procedure TMainForm.NewScript;
begin
  ScriptEdit.Lines.Clear;
end;

procedure TMainForm.LoadScript;
begin
  {$IFDEF MSWINDOWS}
  OpenScriptDialog.InitialDir:=ExtractFilePath(ParamStr(0))+'scripts\';
  {$ENDIF}
  {$IFDEF DARWIN}
  OpenScriptDialog.InitialDir:=ExpandFileName('~/Library/Preferences/')+'NetTestSrv/;
  {$ENDIF}
  if OpenScriptDialog.Execute() then
  begin
    ScriptEdit.Lines.Clear;
    ScriptEdit.Lines.BeginUpdate;
    ScriptEdit.Lines.LoadFromFile(OpenScriptDialog.FileName);
    ScriptEdit.Lines.EndUpdate;
  end;



end;

procedure TMainForm.SaveScript;
begin
  {$IFDEF MSWINDOWS}
  ScriptSaveDialog.InitialDir:=ExtractFilePath(ParamStr(0))+'scripts\';
  {$ENDIF}
  {$IFDEF DARWIN}
  ScriptSaveDialog.InitialDir:=ExpandFileName('~/Library/Preferences/')+'NetTestSrv/;
  {$ENDIF}
  if ScriptSaveDialog.Execute then
  begin
    ScriptEdit.Lines.SaveToFile(ScriptSaveDialog.FileName);
    Settings.DataProcessingScript := ScriptSaveDialog.FileName;
    Settings.Save;
  end;

end;

procedure TMainForm.RunCommand(Command: TRunCommand);
begin
  case Command of
    rcExit: AppExit;
    rcStartServer: StartServer;
    rcStopServer: StopServer;
    rcSettings: RunSettings;
    rcTray: Tray;
    rcAbout: About;
    rcNewScript: NewScript;
    rcOpenScript: LoadScript;
    rcSaveScript: SaveScript;
  end;
end;


{$R *.lfm}

end.
