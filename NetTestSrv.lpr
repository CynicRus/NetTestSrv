program NetTestSrv;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, lazcontrols, lnetbase, main, usettingform, tcpipcfgform, ulptypes,
  ucustomtypes, ulpclasses, ulpclasshelper, umultilang, uplugins, usettings,
  lpffiwrappers, synaser, lpTObject, userverscript, uabout, uversionsupport;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSettingsFrm, SettingsFrm);
  Application.CreateForm(TTCPIPForm,TCPIPForm);
  Application.Run;
end.

