unit usettingform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  ExtCtrls, Spin, MaskEdit, usettings, tcpipcfgform, umultilang;

type

  { TSettingsFrm }

  TSettingsFrm = class(TForm)
    IpAddrEdt: TEdit;
    ServerTypeBox: TComboBox;
    Label1: TLabel;
    TypeLbl: TLabel;
    PortLbl: TLabel;
    PortEdt: TSpinEdit;
    UseRedirectCHBox: TCheckBox;
    cnclBtn: TButton;
    ScriptEdt: TEdit;
    okBtn: TButton;
    OpenDialog1: TOpenDialog;
    LanguageBox: TComboBox;
    LanguageGroupBox: TGroupBox;
    SetScriptBtn: TButton;
    RedirectSettingsBtn: TButton;
    ServerGBox: TGroupBox;
    ConnectionTypeLbl: TLabel;
    RedirectGBox: TGroupBox;
    ScriptBoxLbl: TLabel;
    ScriptSettingsBox: TGroupBox;
    procedure cnclBtnClick(Sender: TObject);
    procedure RedirectSettingsBtnClick(Sender: TObject);
    //procedure ExportTypeBoxChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LanguageBoxChange(Sender: TObject);
    procedure okBtnClick(Sender: TObject);
    procedure ServerTypeBoxChange(Sender: TObject);
    procedure SetScriptBtnClick(Sender: TObject);
    procedure UseRedirectCHBoxChange(Sender: TObject);
  private

  public

  end;


procedure EditSettings();

var
  SettingsFrm: TSettingsFrm;

implementation

{$R *.lfm}

procedure EditSettings();
var
  i: integer;
  Con: TTCPIpConnectionSettings;
begin
  with SettingsFrm do
  begin
    Con := TTCPIpConnectionSettings(Settings.ConnectionSettings);
    ServerTypeBox.ItemIndex := Settings.ServerType;
    Con.ServerType:= Settings.ServerType;
    ipAddrEdt.Text := Con.IPAddr;
    PortEdt.Value := StrToInt(Con.Port);
    ScriptEdt.Text := Settings.DataProcessingScript;
    for i := 0 to ComponentCount - 1 do
      if Components[i] is TComboBox then
        TComboBox(Components[i]).ReadOnly := True;
    LanguageManager.FillComboBox(LanguageBox);
    LanguageBox.ItemIndex := Settings.LangIndex;
    //Show;
    if ShowModal = mrOk then
    begin
      //Settings.ConnectionType := ConnectionTypeBox.ItemIndex;
      //Settings.ExportType := ExportTypeBox.ItemIndex;
      Settings.LangIndex := LanguageBox.ItemIndex;
      Settings.UseRedirect := UseRedirectCHBox.Checked;
      Settings.DataProcessingScript := ScriptEdt.Text;
      Con.IPaddr := ipAddrEdt.Text;
      Con.Port := IntToStr(PortEdt.Value);
      Con.ServerType := ServerTypeBox.ItemIndex;
      //ChangeConnectionSettings()
      Settings.ServerType := Con.ServerType;
      Settings.Save;
      //Free();
    end;
    Close();
  end;

end;



{ TSettingsFrm }


procedure TSettingsFrm.cnclBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TSettingsFrm.RedirectSettingsBtnClick(Sender: TObject);
begin
  EditTCPIpConnection(Settings.RedirectSettings);
end;


procedure TSettingsFrm.FormCreate(Sender: TObject);
begin

end;

procedure TSettingsFrm.FormShow(Sender: TObject);
var
  Con: TTCPIpConnectionSettings;
  i: integer;
begin
  with SettingsFrm do
  begin
    Con := TTCPIpConnectionSettings(Settings.ConnectionSettings);
    ServerTypeBox.ItemIndex := Con.ServerType;
    ipAddrEdt.Text := Con.IPAddr;
    PortEdt.Value := StrToInt(Con.Port);
    UseRedirectCHBox.Checked:=Settings.UseRedirect;
    RedirectSettingsBtn.Enabled := Settings.UseRedirect;
    ScriptEdt.Text := Settings.DataProcessingScript;
    for i := 0 to ComponentCount - 1 do
      if Components[i] is TComboBox then
        TComboBox(Components[i]).ReadOnly := True;
    LanguageManager.FillComboBox(LanguageBox);
    LanguageBox.ItemIndex := Settings.LangIndex;
  end;

end;

procedure TSettingsFrm.LanguageBoxChange(Sender: TObject);
begin
  Settings.LangIndex := LanguageBox.ItemIndex;
  Settings.ServerType:= ServerTypeBox.ItemIndex;
  LanguageManager.ApplyLanguage(Settings.LangIndex);
  LanguageManager.FillComboBox(LanguageBox);
  LanguageBox.ItemIndex := Settings.LangIndex;
  ServerTypeBox.ItemIndex := Settings.ServerType;
end;

procedure TSettingsFrm.okBtnClick(Sender: TObject);
var
  Con: TTCPIpConnectionSettings;
begin
  with SettingsFrm do
  begin
    Con := TTCPIpConnectionSettings(Settings.ConnectionSettings);
    //Settings.ConnectionType := ConnectionTypeBox.ItemIndex;
    //Settings.ExportType := ExportTypeBox.ItemIndex;
    Settings.LangIndex := LanguageBox.ItemIndex;
    Settings.UseRedirect := UseRedirectCHBox.Checked;
    Settings.DataProcessingScript := ScriptEdt.Text;
    Con.IPaddr := ipAddrEdt.Text;
    Con.Port := IntToStr(PortEdt.Value);
    Con.ServerType := ServerTypeBox.ItemIndex;
    Settings.ServerType := Con.ServerType;
    Settings.Save;
    //Free();
    Close();
  end;
end;

procedure TSettingsFrm.ServerTypeBoxChange(Sender: TObject);
begin

end;

procedure TSettingsFrm.SetScriptBtnClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    Settings.DataProcessingScript := OpenDialog1.FileName;
    ScriptEdt.Text := OpenDialog1.FileName;
  end;
end;

procedure TSettingsFrm.UseRedirectCHBoxChange(Sender: TObject);
begin
  if UseRedirectCHBox.Checked then
    RedirectSettingsBtn.Enabled := True
  else
    RedirectSettingsBtn.Enabled := False;
end;


{procedure TSettingsFrm.ConnectionTypeBoxChange(Sender: TObject);
var
  s: string;
begin
  //Settings.ConnectionType := ConnectionTypeBox.ItemIndex;
  case Settings.ConnectionType of
  0,2: s := '{"ip":"127.0.0.1","port":"5050"}';
  1: s := '{}';
  end;
  Settings.ChangeConnectionSettings(s);
  //Settings.
end;}


end.
