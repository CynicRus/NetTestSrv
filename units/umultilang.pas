unit umultilang;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls, Forms, StdCtrls, fgl, gvector,
  gutil, XMLRead, XMLWrite, Dom, TypInfo;

const
  LangPath = 'languages\';

type
  {TOnChangeLang = function(obj: TObject): boolean of object;
  TOnDefaultLang = procedure(obj: TObject);}
  { TLangItem }

  TLangItem = class
  private
    FComponentName: string;
    FComponentCaption: string;
    FComponentHint: string;
    FData: string;
  public
    constructor Create(Component: TComponent); overload;
    constructor Create;
    procedure LoadFromXML(aParentNode: TDOMNode);
    procedure SaveToXML(XMLDoc: TXMLDocument; aParentNode: TDOMNode);
    function toStr: string;
    destructor Destroy; override;
    property ComponentName: string read FComponentName write FComponentName;
    property ComponentCaption: string read FComponentCaption write FComponentCaption;
    property ComponentHint: string read FComponentHint write FComponentHint;
    property Data: string read FData write FData;
  end;

  TLangItemList = specialize TVector<TLangItem>;

  { TSection }

  TSection = class
  private
    FSectionName: string;
    FItems: TLangItemList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddControl(Component: TComponent);
    procedure ApplyToControl(Component: TComponent);
    procedure LoadFromXML(aParentNode: TDOMNode);
    procedure SaveToXML(XMLDoc: TXMLDocument; aParentNode: TDOMNode);
    property SectionName: string read FSectionName write FSectionName;
    property Items: TLangItemList read FItems;
  end;

  TSectionList = specialize TVector<TSection>;

  { TFormSection }

  TFormSection = class
  private
    FFormName: string;
    FFormCaption: string;
    FSections: TSectionList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AssignForm(Form: TForm);
    procedure LoadFromXML(aParentNode: TDOMNode);
    procedure SaveToXML(XMLDoc: TXMLDocument; aParentNode: TDOMNode);
    procedure ApplyToForm(Form: TForm);
    property Items: TSectionList read FSections;
    property FormName: string read FFormName write FFormName;
    property FormCaption: string read FFormCaption write FFormCaption;
  end;

  TFormSectionList = specialize TVector<TFormSection>;

  TAppStringList = specialize TFPGMap<string, string>;

  { TAppStrings }

  TAppStrings = class
  private
    FItems: TAppStringList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddString(AName, AValue: string);
    function GetString(AName: string): string;
    procedure LoadFromXML(aParentNode: TDOMNode);
    procedure SaveToXML(XMLDoc: TXMLDocument; aParentNode: TDOMNode);
  end;

  { TLanguage }

  { TLanguageHeader }

  TLanguageHeader = class
  private
    FLangName: string;
    FAuthor: string;
    FCreationDate: int64;
    FModifiedDate: int64;
    FAuthorsMail: string;
    FPath: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromXML(aParentNode: TDOMNode);
    procedure SaveToXML(XMLDoc: TXMLDocument; aParentNode: TDOMNode);
    property LangName: string read FLangName write FLangName;
    property Path: string read FPath write FPath;
    property Author: string read FAuthor write FAuthor;
    property AuthorsMail: string read FAuthorsMail write FAuthorsMail;
    property CreationDate: int64 read FCreationDate write FCreationDate;
    property ModifiedDate: int64 read FModifiedDate write FModifiedDate;
  end;

  TLanguage = class
  private
    FHeader: TLanguageHeader;
    FSections: TFormSectionList;
    FAppStrings: TAppStrings;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromXML(FileName: string);
    procedure SaveToXML(FileName: string);
    procedure FormToLang(Form: TForm);
    procedure LangToForm(Form: TForm);
    procedure FillHeader(FileName: string);
    property Header: TLanguageHeader read FHeader write FHeader;
    property AppStrings: TAppStrings read FAppStrings;
  end;

  TLanguageList = specialize TVector<TLanguage>;

  { TLanguageManager }

  TLanguageManager = class
  private
    FLangs: TLanguageList;
    FLangsPath: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure MakeDefaultLang;
    procedure FillComboBox(Combobox: TCombobox);
    procedure FillStrings(St: TStrings);
    procedure ApplyLanguage(const LangIndex: integer);
    procedure ApplyLanguage(LangIndex: integer; Form: TForm); overload;

  end;

const
  cr = chr(13) + chr(10);
  tab = chr(9);

var
  LanguageManager: TLanguageManager = nil;

implementation

uses DateUtils, FileUtil;

function GetSection(SectionName: string; List: TSectionList): TSection;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to List.Size - 1 do
    if SectionName = List[i].SectionName then
      Result := List[i];
end;

function GetFormSection(FormSectionName: string; List: TFormSectionList): TFormSection;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to List.Size - 1 do
    if FormSectionName = List[i].FormName then
      Result := List[i];
end;

function GetComponentProperty(Component: TComponent; PropName: string): string;
var
  PropInfo: PPropInfo;
  str: string;
begin
  Result := '';
  PropInfo := GetPropInfo(Component, PropName);
  if PropInfo <> nil then
  begin
    Str := GetStrProp(Component, PropInfo);
    Str := stringreplace(Str, cr, '~~', [rfreplaceall]);
    Result := Str;
  end;
end;

procedure SetComponentProperty(Component: TComponent; PropName, PropValue: string);
var
  PropInfo: PPropInfo;
begin
  PropInfo := GetPropInfo(Component, PropName);
  if PropInfo <> nil then
    setStrProp(Component, PropName, PropValue);
end;

{ TAppStrings }

constructor TAppStrings.Create;
begin
  FItems := TAppStringList.Create;
end;

destructor TAppStrings.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TAppStrings.AddString(AName, AValue: string);
begin
  FItems.add(AName, AValue);
end;

function TAppStrings.GetString(AName: string): string;
begin
  Result := FItems[AName];
end;

procedure TAppStrings.LoadFromXML(aParentNode: TDOMNode);
var
  i: integer;
  Node: TDomNode;
  AName, AValue: string;
begin
  AName := '';
  AValue := '';
  FItems.Clear;
  for i := 0 to aParentNode.ChildNodes.Count - 1 do
  begin
    Node := aParentNode.ChildNodes[i];
    AName := Node.NodeName;
    AValue := Node.Attributes.GetNamedItem('Value').NodeValue;
    FItems.Add(AName, AValue);
  end;

end;

procedure TAppStrings.SaveToXML(XMLDoc: TXMLDocument; aParentNode: TDOMNode);
var
  Node: TDomNode;
  i: integer;
begin
  for i := 0 to FItems.Count - 1 do
  begin
    Node := XMLDoc.CreateElement(FItems.Keys[i]);
    TDomElement(Node).SetAttribute('Value', Fitems[FItems.Keys[i]]);
    Node := aParentNode.AppendChild(Node);
  end;
end;

{ TLanguageManager }

procedure TLanguageManager.MakeDefaultLang;
var
  Lang: TLanguage;
  i: integer;
begin
  Lang := TLanguage.Create;
  try
    Lang.Header.Author := 'Author';
    Lang.Header.AuthorsMail := 'Author@mail';
    Lang.Header.LangName := 'Default';
    for i := 0 to Application.ComponentCount - 1 do
    begin
      if Application.Components[i] is TForm then
        Lang.FormToLang(TForm(Application.Components[i]));
    end;
    Lang.SaveToXML(ExtractFilePath(ParamStr(0)) + Langpath + Lang.Header.LangName + '.xml');
  finally
    Lang.Free;
  end;
end;

constructor TLanguageManager.Create;
var
  Langs: TStringList;
  i: integer;
  Lang: TLanguage;
begin
  FLangs := TLanguageList.Create;
  if not DirectoryExists(ExtractFilePath(ParamStr(0)) + Langpath) then
    CreateDir(ExtractFilePath(ParamStr(0)) + Langpath);
  Langs := FindAllFiles(ExtractFilePath(ParamStr(0)) + Langpath, '*.xml', True);
  if Langs.Count = 0 then
    MakeDefaultLang;
  for i := 0 to Langs.Count - 1 do
  begin
    Lang := TLanguage.Create;
    Lang.FillHeader(Langs[i]);
    Flangs.PushBack(Lang);
  end;
end;

destructor TLanguageManager.Destroy;
begin
  if FLangs <> nil then
    FLangs.Free;
  inherited;
end;

procedure TLanguageManager.FillComboBox(Combobox: TCombobox);
var
  i: integer;
begin
  Combobox.Items.Clear;
  for i := 0 to Flangs.Size - 1 do
    Combobox.Items.Add(Flangs[i].Header.LangName);
  Combobox.ItemIndex := 0;
end;

procedure TLanguageManager.FillStrings(St: TStrings);
var
  i: integer;
begin
  St.Clear;
  for i := 0 to Flangs.Size - 1 do
    St.Add(Flangs[i].Header.LangName);
  //Combobox.ItemIndex := 0;
end;

procedure TLanguageManager.ApplyLanguage(const LangIndex: integer);
var
  Lang: TLanguage;
  i: integer;
begin
  Lang := Flangs[LangIndex];
  Lang.LoadFromXML(Lang.Header.Path);
  for i := 0 to Application.ComponentCount - 1 do
  begin
    if Application.Components[i] is TForm then
      Lang.LangToForm(TForm(Application.Components[i]));
  end;

end;

procedure TLanguageManager.ApplyLanguage(LangIndex: integer; Form: TForm);
var
  Lang: TLanguage;
begin
  Lang := Flangs[LangIndex];
  Lang.LoadFromXML(Lang.Header.Path);
  Lang.LangToForm(Form);
end;

{ TLanguageHeader }

constructor TLanguageHeader.Create;
begin
  LangName := '';
  Author := '';
  AuthorsMail := '';
  CreationDate := DateTimeToUnix(now);
  ModifiedDate := DateTimeToUnix(now);
end;

destructor TLanguageHeader.Destroy;
begin
  inherited Destroy;
end;

procedure TLanguageHeader.LoadFromXML(aParentNode: TDOMNode);
begin
  LangName := aParentNode.Attributes.GetNamedItem('Name').NodeValue;
  Author := aParentNode.Attributes.GetNamedItem('Author').NodeValue;
  AuthorsMail := aParentNode.Attributes.GetNamedItem('Mail').NodeValue;
  CreationDate := StrToInt64(aParentNode.Attributes.GetNamedItem(
    'CreationDate').NodeValue);
  ModifiedDate := StrToInt64(aParentNode.Attributes.GetNamedItem(
    'ModifiedDate').NodeValue);
end;

procedure TLanguageHeader.SaveToXML(XMLDoc: TXMLDocument; aParentNode: TDOMNode);
begin
  TDOMElement(aParentNode).SetAttribute('Name', LangName);
  TDOMElement(aParentNode).SetAttribute('Author', Author);
  TDOMElement(aParentNode).SetAttribute('Mail', AuthorsMail);
  TDOMElement(aParentNode).SetAttribute('CreationDate', IntToStr(CreationDate));
  TDOMElement(aParentNode).SetAttribute('ModifiedDate', IntToStr(ModifiedDate));
end;

{ TFormSection }

constructor TFormSection.Create;
begin
  FSections := TSectionList.Create;
end;

destructor TFormSection.Destroy;
begin
  Fsections.Free;
  inherited Destroy;
end;

procedure TFormSection.AssignForm(Form: TForm);
var
  i: integer;
  Section: TSection;
  Component: TComponent;
begin
  Section := nil;
  FormName := Form.Name;
  FormCaption := Form.Caption;
  for i := 0 to Form.ComponentCount - 1 do
  begin
    Component := Form.Components[i];
    //Section := TSection.Create;
    Section := GetSection(Component.ClassName, FSections);
    //If not FSections.TryGetValue(Control.ClassName,Section) then
    if Section = nil then
    begin
      Section := TSection.Create;
      Section.SectionName := Component.ClassName;
      FSections.PushBack(Section);
    end;
    Section.AddControl(Component);

  end;
end;

procedure TFormSection.LoadFromXML(aParentNode: TDOMNode);
var
  Section: TSection;
  i: integer;
begin
  FormName := aParentNode.Attributes.GetNamedItem('Name').NodeValue;
  FormCaption := aParentNode.Attributes.GetNamedItem('Caption').NodeValue;
  {Node := aParentNode.ChildNodes;}
  try
    for i := 0 to aParentNode.ChildNodes.Count - 1 do
    begin
      Section := GetSection(aParentNode.ChildNodes[i].Attributes.GetNamedItem(
        'Name').NodeValue, FSections);
      if Section = nil then
      begin
        Section := TSection.Create;
        Section.LoadFromXML(aParentNode.ChildNodes[i]);
        FSections.PushBack(Section);
      end
      else
      begin
        Section.LoadFromXML(aParentNode.ChildNodes[i]);
      end;
    end;
  except
    on E: Exception do
      raise;
  end;
end;

procedure TFormSection.SaveToXML(XMLDoc: TXMLDocument; aParentNode: TDOMNode);
var
  Node: TDomNode;
  i: integer;
  Section: TSection;
begin
  Node := XMLDoc.CreateElement('Form');
  TDOMElement(Node).SetAttribute('Name', FormName);
  TDOMElement(Node).SetAttribute('Caption', FormCaption);
  Node := aParentNode.AppendChild(Node);
  for i := 0 to FSections.Size - 1 do
  begin
    Section := FSections[i];
    Section.SaveToXML(XMLDoc, Node);
  end;
end;

procedure TFormSection.ApplyToForm(Form: TForm);
var
  Component: TComponent;
  i: integer;
  Section: TSection;
begin
  Form.Caption := FormCaption;
  for i := 0 to Form.ComponentCount - 1 do
  begin
    Component := Form.Components[i];
    Section := GetSection(Component.ClassName, FSections);
    if (Section = nil) then
    {$ifndef DBG}
    continue;
    {$ELSE}
      raise Exception.Create('Error! The language section for ' +
        Component.ClassName + ' not found!');
    {$ENDIF}
    Section.ApplyToControl(Component);
  end;

end;

{ TLanguage }

constructor TLanguage.Create;
begin
  FSections := TFormSectionList.Create;
  FHeader := TLanguageHeader.Create;
  FAppStrings := TAppStrings.Create;
  FAppStrings.AddString('TestKey', 'TestValue');
end;

destructor TLanguage.Destroy;
begin
  FSections.Clear;
  Fsections.Free;
  FAppStrings.Free;
  inherited Destroy;
end;

procedure TLanguage.LoadFromXML(FileName: string);
var
  xdoc: TXMLDocument;
  Child: TDOMNode;
  Section: TFormSection;
  i: integer;
  aSize: integer;
begin
  aSize := 0;
  xdoc := TXMLDocument.Create;
  try
    ReadXMLFile(xdoc, FileName);
    Child := xdoc.DocumentElement;
    FSections.Clear;
    if Header.LangName = '' then
      Header.LoadFromXML(Child);
    aSize := StrToInt(TDomElement(Child).GetAttribute('Count'));
    for i := 0 to aSize - 1 do
    begin
      Section := TFormSection.Create;
      Section.LoadFromXML(Child.ChildNodes[i]);
      FSections.PushBack(Section);
    end;
    AppStrings.LoadFromXML(Child.ChildNodes[Child.ChildNodes.Count - 1]);
  finally
    FreeAndNil(xdoc);
  end;
end;

procedure TLanguage.SaveToXML(FileName: string);
var
  xdoc: TXMLDocument;
  Node, StringsNode: TDomNode;
  Section: TFormSection;
  i: integer;
begin
  xdoc := TXMLDocument.Create;
  try
    Node := xdoc.CreateElement('Language');
    xdoc.AppendChild(Node);
    Node := xdoc.DocumentElement;
    Header.SaveToXML(xdoc, Node);
    TDomElement(Node).SetAttribute('Count', IntToStr(FSections.Size));
    for i := 0 to FSections.Size - 1 do
      FSections[i].SaveToXML(xdoc, node);
    StringsNode := xdoc.CreateElement('AppStrings');
    node.AppendChild(StringsNode);
    FAppStrings.SaveToXML(xDoc, StringsNode);
    WriteXMLFile(xdoc, FileName);
  finally
    FreeAndNil(xdoc);
  end;
end;

procedure TLanguage.FormToLang(Form: TForm);
var
  Section: TFormSection;
begin
  Section := GetFormSection(Form.Name, FSections);

  if (Section = nil) then
  begin
    Section := TFormSection.Create;
    Section.AssignForm(Form);
    FSections.PushBack(Section);
  end
  else
    Section.AssignForm(Form);

end;

procedure TLanguage.LangToForm(Form: TForm);
var
  Section: TFormSection;
begin
  Section := GetFormSection(Form.Name, FSections);

  if (Section = nil) then
    raise Exception.Create('Lang to form exception, section not found!');

  Section.ApplyToForm(Form);

end;

procedure TLanguage.FillHeader(FileName: string);
var
  xdoc: TXMLDocument;
  Node: TDOMNode;
begin
  xdoc := TXMLDocument.Create;
  try
    ReadXMLFile(xdoc, FileName);
    Node := xdoc.DocumentElement;
    Header.LoadFromXML(Node);
    Header.Path := FileName;
  finally
    FreeAndNil(xDoc)
  end;
end;

{ TSection }

constructor TSection.Create;
begin
  FSectionName := '';
  FItems := TLangItemList.Create;
end;

destructor TSection.Destroy;
begin
  FItems.Clear;
  FItems.Free;
  inherited Destroy;
end;

procedure TSection.AddControl(Component: TComponent);
var
  Item: TLangItem;
begin
  Item := TLangItem.Create(Component);
  Fitems.PushBack(Item);
end;

procedure TSection.ApplyToControl(Component: TComponent);
var
  Item: TLangItem;
  i: integer;
  ss: TStringStream;
begin
  // for Item in FItems do
  for i := 0 to Fitems.Size - 1 do
  begin
    Item := FItems[i];
    if (Item.ComponentName = GetComponentProperty(Component, 'name')) then
    begin
      SetComponentProperty(Component, 'caption', Item.ComponentCaption);
      SetComponentProperty(Component, 'hint', Item.ComponentHint);
      if Component is TComboBox then
      begin
        ss := TStringStream.Create(Item.Data);
        TComboBox(Component).Items.LoadFromStream(ss);
        ss.Free;
      end;
      Break;
    end;
  end;
end;

procedure TSection.LoadFromXML(aParentNode: TDOMNode);
var
  i: integer;
  Item: TLangItem;
  Node: TDomNode;
begin
  SectionName := aParentNode.Attributes.GetNamedItem('Name').NodeValue;
  FItems.Clear;
  for i := 0 to aParentNode.ChildNodes.Count - 1 do
  begin
    Node := aParentNode.ChildNodes[i];
    Item := TLangItem.Create;
    Item.LoadFromXML(Node);
    FItems.PushBack(Item);
  end;
end;

procedure TSection.SaveToXML(XMLDoc: TXMLDocument; aParentNode: TDOMNode);
var
  Node: TDomNode;
  Item: TLangItem;
  i: integer;
begin
  Node := XMLDoc.CreateElement('Section');
  TDOMElement(Node).SetAttribute('Name', SectionName);
  Node := aParentNode.AppendChild(Node);
  for i := 0 to FItems.Size - 1 do
  begin
    Item := TLangItem(FItems[i]);
    Item.SaveToXML(XMLDoc, Node);
  end;
end;

{ TLangItem }


constructor TLangItem.Create(Component: TComponent);
var
  SS: TStringStream;
begin
  ComponentCaption := GetComponentProperty(Component, 'caption');
  ComponentHint := GetComponentProperty(Component, 'hint');
  ComponentName := GetComponentProperty(Component, 'name');
  if Component is TComboBox then
  begin
    SS := TStringStream.Create('');
    try
      TComboBox(Component).Items.SaveToStream(ss);
      Data := ss.DataString;

    finally
      ss.Free;
    end;
  end;
  // ComponentType := Component.ClassName;
end;

constructor TLangItem.Create;
begin
  ComponentName := '';
  ComponentCaption := '';
  ComponentHint := '';
  Data := '';
end;

procedure TLangItem.LoadFromXML(aParentNode: TDOMNode);
begin
  ComponentName := aParentNode.NodeName;
  ComponentCaption := aParentNode.Attributes.GetNamedItem('Caption').NodeValue;
  ComponentHint := aParentNode.Attributes.GetNamedItem('Hint').NodeValue;
  if aParentNode.Attributes.GetNamedItem('Data') <> nil then
    Data := aParentNode.Attributes.GetNamedItem('Data').NodeValue;
end;

procedure TLangItem.SaveToXML(XMLDoc: TXMLDocument; aParentNode: TDOMNode);
var
  Node: TDomNode;
begin
  Node := XMLDoc.CreateElement(ComponentName);
  TDomElement(Node).SetAttribute('Caption', ComponentCaption);
  if ComponentHint <> '' then
    TDomElement(Node).SetAttribute('Hint', ComponentHint);
  if Data <> '' then
    TDomElement(Node).SetAttribute('Data', Data);
  aParentNode.AppendChild(Node);
end;

function TLangItem.toStr: string;
begin
  Result := {ComponentType + '|' +} ComponentName + '|' + ComponentCaption +
    '|' + ComponentHint;
end;

destructor TLangItem.Destroy;
begin
  inherited Destroy;
end;

initialization
  LanguageManager := TLanguageManager.Create;

finalization
  if (LanguageManager <> nil) then
    LanguageManager.Free;
end.
