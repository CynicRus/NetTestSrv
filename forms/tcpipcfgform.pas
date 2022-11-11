unit tcpipcfgform;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, MaskEdit,
  Spin, usettings;

type

  { TTCPIPForm }

  TTCPIPForm = class(TForm)
    KeepConnectionBox: TCheckBox;
    ipAddrEdit: TEdit;
    okBtn: TButton;
    IpAddrLbl: TLabel;
    PortLbl: TLabel;
    PortEdt: TSpinEdit;
  private

  public

  end;


procedure EditTCPIpConnection(Cfg: TTCPIpRedirectSettings);

var
  TCPIPForm: TTCPIPForm;

implementation

procedure EditTCPIpConnection(Cfg: TTCPIpRedirectSettings);
begin
  with TCPIPForm do
  begin
    KeepConnectionBox.Visible := False;
    ipAddrEdit.Text := Cfg.ipaddr;
    PortEdt.Value := StrToInt(Cfg.Port);


    if ShowModal = mrOk then
    begin
      Cfg.IPaddr := ipAddrEdit.Text;
      cfg.Port := IntToStr(PortEdt.Value);
    end;
    Close;
  end;
end;


{$R *.lfm}

end.
