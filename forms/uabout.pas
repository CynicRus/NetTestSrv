unit uabout;

{$mode objfpc}{$H+}

interface

uses Classes, Graphics, Controls;

procedure ShowAbout(const Developer, Company: string;
  HiVer, LoVer, Year: Integer);
procedure ShowAboutDialog(const AppTitle, Developer, Company: string;
  AppIcon: TIcon; HiVer, LoVer, Year: Integer);

implementation

uses
  LCLType,LCLIntf,
  SysUtils, LMessages, Forms, Dialogs, ExtCtrls, StdCtrls, Buttons, uversionsupport;

{$IFDEF RX_D3}
resourcestring
{$ELSE}
const
{$ENDIF}
  sYear = '%s © %d';
  sAbout = 'About';
{$IFDEF WIN32}
  sFreeMemoryLabel = 'Physical memory:';
  sFreeResourcesLabel = 'Memory in use:';
{$ELSE}
  sFreeMemoryLabel = 'Free memory:';
  sFreeResourcesLabel = 'Free system resources:';
{$ENDIF WIN32}
  sVersion = 'Version %d.%.2d';
  sFileVer = 'Version %s';
  sExeFile = 'Executable file %s';

{ TAboutDialog }

type
  TAboutDialog = class(TForm)
    FProgramIcon: TImage;
    FProductName: TLabel;
    FProductVersion: TLabel;
    FCopyright: TLabel;
    FYearLabel: TLabel;
    FMemSize: TLabel;
    FPercent: TLabel;
  private
    procedure SetVersion(LoVer, HiVer: Integer);
    procedure SetCopyright(const Developer, Company: string; Year: Integer);
    procedure SetAppData(const AppTitle: string; AIcon: TIcon);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

{ Utility routines }

function MakeAboutDialog: TForm;
begin
  Result := TAboutDialog.Create(Application);
  with Result do
    { scale to screen res }
    if Screen.PixelsPerInch <> 96 then begin
      ScaleBy(Screen.PixelsPerInch, 96);
      { The ScaleBy method does not scale the font well, so set the
        font back to the original info. }
      Font.Name := 'MS Sans Serif';
      Font.Size := 8;
      Font.Style := [];
      Font.Color := clWindowText;
      Left := (Screen.Width div 2) - (Width div 2);
      Top := (Screen.Height div 2) - (Height div 2);
    end;
end;


procedure ShowAboutDialog(const AppTitle, Developer, Company: string;
  AppIcon: TIcon; HiVer, LoVer, Year: Integer);
begin
  with TAboutDialog(MakeAboutDialog) do
  try
    SetVersion(LoVer, HiVer);
    SetCopyright(Developer, Company, Year);
    SetAppData(AppTitle, AppIcon);
    ShowModal;
  finally
    Free;
  end;
end;

procedure ShowAbout(const Developer, Company: string;
  HiVer, LoVer, Year: Integer);
begin
  ShowAboutDialog(Application.Title, Developer, Company, Application.Icon,
    HiVer, LoVer, Year);
end;

{ TAboutDialog }

constructor TAboutDialog.Create(AOwner: TComponent);
begin
{$IFDEF CBUILDER}
  inherited CreateNew(AOwner, 0);
{$ELSE}
  inherited CreateNew(AOwner);
{$ENDIF}
  BorderStyle := bsDialog;
  Position := poScreenCenter;
  ClientHeight := 103;
  ClientWidth := 339;
  Caption := sAbout;

  with Font do begin
{$IFNDEF WIN32}
    Color := clWindowText;
    Size := 8;
    Name := 'MS Sans Serif';
{$ENDIF}
    Style := [];
  end;

  FProgramIcon := TImage.Create(Self);
  with FProgramIcon do begin
    Parent := Self;
    Left := 12;
    Top := 8;
    Width := 32;
    Height := 32;
    AutoSize := True;
  end;

  FProductName := TLabel.Create(Self);
  with FProductName do begin
    Parent := Self;
    Left := 60;
    Top := 6;
    Width := 205;
    Height := 13;
    ParentFont := True;
    ShowAccelChar := False;
  end;

  FProductVersion := TLabel.Create(Self);
  with FProductVersion do begin
    Parent := Self;
    Left := 60;
    Top := 23;
    Width := 205;
    Height := 13;
    ParentFont := True;
    Caption := sVersion;
  end;

  FCopyright := TLabel.Create(Self);
  with FCopyright do begin
    Parent := Self;
    Left := 60;
    Top := 57;
    Width := 273;
    Height := 13;
    ParentFont := True;
  end;

  FYearLabel := TLabel.Create(Self);
  with FYearLabel do begin
    Parent := Self;
    Left := 60;
    Top := 40;
    Width := 273;
    Height := 13;
    ParentFont := True;
  end;

  with TBevel.Create(Self) do begin
    Parent := Self;
    Shape := bsTopLine;
    Style := bsLowered;
    Left := 60;
    Top := 81;
    Width := 273;
    Height := 2;
  end;

  with TButton.Create(Self) do begin
    Parent := Self;
    Left := 272;
    Top := 6;
    Width := 61;
    Height := 25;
    Caption := 'Ok';
    //Cursor := crHand;
    Default := False;
    Cancel := True;
    ModalResult := mrOk;
  end;
end;

procedure TAboutDialog.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  if Application.MainForm <> nil then
    Params.WndParent := Application.MainForm.Handle;
end;

procedure TAboutDialog.SetCopyright(const Developer, Company: string;
  Year: Integer);
begin
  FYearLabel.Caption := Format(sYear, [Company, Year]);
  FCopyright.Caption := Developer;
end;

procedure TAboutDialog.SetVersion(LoVer, HiVer: Integer);
begin
  FProductVersion.Caption := Format(sVersion, [HiVer, LoVer]);
end;

procedure TAboutDialog.SetAppData(const AppTitle: string; AIcon: TIcon);
begin
  if (AIcon <> nil) and not AIcon.Empty then Icon := AIcon
  else Icon.Handle := Application.Icon.Handle;
  FProductName.Caption := AppTitle;
  FProgramIcon.Picture.Icon := Icon;
end;


end.
