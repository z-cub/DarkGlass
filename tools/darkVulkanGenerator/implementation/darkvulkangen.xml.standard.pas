unit darkvulkangen.xml.standard;

interface
uses
  classes,
  darkvulkangen.xml,
  darkvulkangen.ast,
  xml.xmldoc,
  xml.xmlintf;

type
  TArrayOfString = array of string;

  TdvXMLParser = class( TInterfacedObject, IdvXMLParser )
  private
    fCollectComments: boolean;
    fFilename: string;
    fXMLDocument: IXMLDocument;
  private
    class procedure Explode(cDelimiter, sValue: string; var Results: TArrayOfString; iCount: uint32 = 0); static;
    function GetIdentifier(SourceStr: string; var PtrCount: uint32): string;
    function CreateVulkanUnit(ASTNode: IdvASTNode): IdvASTUnit;
  private
    function OpenDocument: boolean;
    function MatchNode(XMLNode: IXMLNode; nodeType, parentnode: string; LogFailures: boolean = TRUE): boolean;
    function MatchAttributes(XMLNode: IXMLNode; Attributes: array of string; ParentNode: string; LogFailures: boolean = TRUE): boolean;
    function ParseDocument( ParentASTNode: IdvASTNode ): boolean;
    function ParseXMLNode( XMLNode: IXMLNode ): boolean;
    function ParseRegistryNode( XMLNode: IXMLNode; ASTNode: IdvASTNode ): boolean;
    function ParseRegistryCommands( XMLNode: IXMLNode; ASTNode: IdvASTNode  ): boolean;
    function ParseRegistryComment( XMLNode: IXMLNode; UnitNode: IdvASTUnit ): boolean;
    function ParseCommentToASTNode(XMLNode: IXMLNode; TargetNode: IdvASTNode ): boolean;
    function ParseRegistryEnums( XMLNode: IXMLNode; UnitNode: IdvASTUnit ): boolean;
    function ParseRegistryExtensions( XMLNode: IXMLNode; ASTNode: IdvASTNode ): boolean;
    function ParseRegistryFeature( XMLNode: IXMLNode; ASTNode: IdvASTNode ): boolean;
    function ParseRegistryPlatforms( XMLNode: IXMLNode; UnitNode: IdvASTUnit ): boolean;
    function ParseRegistryTags( XMLNode: IXMLNode; ASTNode: IdvASTNode ): boolean;
    function ParseRegistryTypes( XMLNode: IXMLNode; UnitNode: IdvASTUnit ): boolean;
    function ParsePlatformNode(XMLNode: IXMLNode; UnitNode: IdvASTUnit; LastPlatform: boolean): boolean;
    function ParseTypeNode(XMLNode: IXMLNode; UnitNode: IdvASTUnit): boolean;
    function ParseAliasNodeType(XMLNode: IXMLNode; UnitNode: IdvASTUnit): boolean;
    function ParseDefineTypeNode(XMLNode: IXMLNode; UnitNode: IdvASTUnit): boolean;
    function ParseEnumTypeNode(XMLNode: IXMLNode; UnitNode: IdvASTUnit): boolean;
    function ParseFuncPointerTypeNode(XMLNode: IXMLNode; UnitNode: IdvASTUnit): boolean;
    function ParseHandleTypeNode(XMLNode: IXMLNode; UnitNode: IdvASTUnit): boolean;
    function ParseIncludeTypeNode(XMLNode: IXMLNode; UnitNode: IdvASTUnit): boolean;
    function ParseStructTypeNode(XMLNode: IXMLNode; UnitNode: IdvASTUnit): boolean;
    function VerifyDefineHandle(XMLNode: IXMLNode): boolean;
    function VerifyMakeVersion(XMLNode: IXMLNode): boolean;
    function VerifyVersionMajor(XMLNode: IXMLNode): boolean;
    function VerifyVersionMinor(XMLNode: IXMLNode): boolean;
    function VerifyVersionPatch(XMLNode: IXMLNode): boolean;
    function VerifyAPIVersion(XMLNode: IXMLNode): boolean;
    function VerifyIAintParsingThat(XMLNode: IXMLNode): boolean;
    function RemoveComments(source: string): string;
    function ParseDefineMakeVersion(XMLNode: IXMLNode; UnitNode: IdvASTUnit): boolean;
    function ParseConstantDefineNode(XMLNode: IXMLNode; UnitNode: IdvASTUnit): boolean;
    function ParseEnumValue( Enum: IdvASTNode; XMLNode: IXMLNode; UnitNode: IdvASTUnit): boolean;
    function ParseUnionTypeNode(XMLNode: IXMLNode; UnitNode: IdvASTUnit): boolean;

  public
    constructor Create( Filename: string ); reintroduce;
    destructor Destroy; override;
    function Parse( ASTRoot: IdvASTRootNode ): boolean;
  end;

implementation
uses
  sysutils,
  darkLog,
  xml.xmldom,
  xml.omnixmldom;

type
  EDocumentNotFound = class(ELogEntry);
  EUnrecognizedXMLTag = class(ELogEntry);
  EExpectedEncoding = class(ELogEntry);
  EUnexpectedEncodingType = class(ELogEntry);
  EExpectedXMLVersion = class(ELogEntry);
  EUnexpectedVersion = class(ELogEntry);
  EMissingPlatforms = class(ELogEntry);
  EMissingTypes = class(ELogEntry);
  EMissingNode = class(ELogEntry);
  EExpectedNode = class(ELogEntry);
  EMissingAttribute = class(ELogEntry);
  EUnhandledAttribute = class(ELogEntry);
  EPlatformNotSupported = class(ELogEntry);
  ESkippedNode = class(ELogEntry);
  EMacroChanged = class(ELogEntry);
  EUnknownXMLFormat = class(ELogEntry);
  EInvalidMacroParameters = class(ELogEntry);

{ TdvXMLParser }

constructor TdvXMLParser.Create(Filename: string);
begin
  inherited Create;
  fFilename := Filename;
  fXMLDocument := nil;
end;

destructor TdvXMLParser.Destroy;
begin
  fXMLDocument := nil;
  inherited Destroy;
end;

function TdvXMLParser.OpenDocument: boolean;
var
  NewDoc: TXMLDocument;
begin
  Result := False;
  if not FileExists(fFilename) then begin
    exit;
  end;
  NewDoc := TXMLDocument.Create(nil);
  NewDoc.DOMVendor := GetDomVendor(xml.omnixmldom.sOmniXmlVendor);
  fXMLDocument := NewDoc;
  fXMLDocument.LoadFromFile(fFilename);
  Result := fXMLDocument.Active;
end;

function TdvXMLParser.ParseXMLNode( XMLNode: IXMLNode ): boolean;
var
  value: string;
begin
  if not XMLNode.HasAttribute('encoding') then begin
    Log.Insert(EExpectedEncoding,lsHint);
  end else begin
    Value := XMLNode.Attributes['encoding'];
    if Uppercase(Trim(Value))<>'UTF-8' then begin
      Log.Insert(EUnexpectedEncodingType,TLogSeverity.lsHint,[LogBind('enctype',Value)]);
    end;
  end;
  if not XMLNode.HasAttribute('version') then begin
    Log.Insert(EExpectedXMLVersion,lsHint);
  end else begin
    Value := XMLNode.Attributes['version'];
    if Uppercase(Trim(Value))<>'1.0' then begin
      Log.Insert(EUnexpectedVersion,TLogSeverity.lsHint,[LogBind('version',Value)]);
    end;
  end;
  Result := True;
end;

function TdvXMLParser.ParseRegistryComment( XMLNode: IXMLNode; UnitNode: IdvASTUnit ): boolean;
var
  idx: uint32;
  Comment: IdvASTComment;
begin
  Result := True;
  if XMLNode.ChildNodes.Count=0 then begin
    exit;
  end;
  for idx := 0 to pred(XMLNode.ChildNodes.Count) do begin
    Comment := TdvASTComment.Create(XMLNode.ChildNodes[idx].Text);
    UnitNode.BeforeNode.InsertChild(Comment);
  end;
end;

function TdvXMLParser.MatchNode( XMLNode: IXMLNode; nodeType: string; parentnode: string; LogFailures: boolean = TRUE): boolean;
var
  utNodeType: string;
begin
  Result := False;
  utNodeType := Uppercase(Trim(NodeType));
  if not (Uppercase(Trim(XMLNode.NodeName))=utNodeType) then begin
    if LogFailures then begin
      Log.Insert(EExpectedNode,TLogSeverity.lsError,[LogBind('parenttype',parentnode),LogBind('unknowntype',XMLNode.NodeName),LogBind('nodetype',nodeType)]);
    end;
    exit;
  end;
  Result := True;
end;

function TdvXMLParser.MatchAttributes( XMLNode: IXMLNode; Attributes: array of string; ParentNode: string; LogFailures: boolean = TRUE ): boolean;
var
  idx: uint32;

  function AttributeExists( attribute: string ): boolean;
  var
    idy: uint32;
  begin
    Result := False;
    for idy := 0 to pred(Length(Attributes)) do begin
      if Attributes[idy]=attribute then begin
        Result := True;
        exit;
      end;
    end;
  end;

begin
  Result := False;
  //- First check that all desired attribtues exist.
  for idx := 0 to pred(Length(Attributes)) do begin
    if not XMLNode.HasAttribute( Attributes[idx] ) then begin
      if LogFailures then begin
        Log.Insert(EMissingAttribute,TLogSeverity.lsError,[LogBind('attribute',Attributes[idx]),LogBind('parentnode',ParentNode)]);
      end;
      exit;
    end;
  end;
  //- Now check that we aren't missing a node.
  if XMLNode.AttributeNodes.Count=0 then begin
    Result := True;
    exit;
  end;
  for idx := 0 to pred(XMLNode.AttributeNodes.Count) do begin
    if not AttributeExists(XMLNode.AttributeNodes[idx].NodeName) then begin
      if LogFailures then begin
        Log.Insert(EUnhandledAttribute,TLogSeverity.lsError,[LogBind('attribute',XMLNode.AttributeNodes[idx].NodeName),LogBind('parentnode',ParentNode)]);
      end;
    end;
  end;
  Result := True;
end;

function TdvXMLParser.ParsePlatformNode( XMLNode: IXMLNode; UnitNode: IdvASTUnit; LastPlatform: boolean ): boolean;
var
  utName: string;
  utProtect: string;
  IfDef: IdvIfDef;
  IfNDef: IdvIfNDef;
  Define: IdvDefine;
begin
  Result := False;
  IfDef := nil;
  IfNDef := nil;
  Define := nil;
  if not MatchAttributes( XMLNode, ['name', 'protect', 'comment'], 'platform' ) then begin
    exit;
  end;
  //- We have all the attribtues we need, so lets use them :-)
  utName := Uppercase(Trim(XMLNode.Attributes['name']));
  utProtect := Uppercase(Trim(XMLNode.Attributes['protect']));
  if utName='XLIB' then begin
    IfDef := TdvIfDef.Create('LINUX');
    UnitNode.InterfaceSection.UsesList.BeforeNode.InsertChild( IfDef );
    Define := TdvDefine.Create(utProtect);
    IfDef.Defined.InsertChild( Define );
    IfDef := TdvIfDef.Create(utProtect);
    IfDef.Defined.InsertChild( TdvLabel.Create('darkplatform.linux.binding.x') );
    IfDef.Defined.InsertChild( TdvLabel.Create('darkplatform.linux.binding.xlib') );
    UnitNode.InterfaceSection.UsesList.InsertChild(IfDef);
  end else if utName='ANDROID' then begin
    IfDef := TdvIfDef.Create('ANDROID');
    UnitNode.InterfaceSection.UsesList.BeforeNode.InsertChild( IfDef );
    Define := TdvDefine.Create(utProtect);
    IfDef.Defined.InsertChild( Define );
    IfDef := TdvIfDef.Create(utProtect);
    IfDef.Defined.InsertChild( TdvLabel.Create('AndroidAPI.NativeWindow') );
    UnitNode.InterfaceSection.UsesList.InsertChild(IfDef);
  end else if utNAME='WIN32' then begin
    IfDef := TdvIfDef.Create('MSWINDOWS');
    UnitNode.InterfaceSection.UsesList.BeforeNode.InsertChild( IfDef );
    Define := TdvDefine.Create(utProtect);
    IfDef.Defined.InsertChild( Define );
    IfDef := TdvIfDef.Create(utProtect);
    ifDef.Defined.InsertChild( TdvLabel.Create('Windows') );
    UnitNode.InterfaceSection.UsesList.InsertChild(IfDef);
  end else if utName='IOS' then begin
    IfDef := TdvIfDef.Create('IOS');
    UnitNode.InterfaceSection.UsesList.BeforeNode.InsertChild( IfDef );
    Define := TdvDefine.Create(utProtect);
    IfDef.Defined.InsertChild( Define );
  end else if utName='MACOS' then begin
    IfDef := TdvIfDef.Create('MACOS');
    IfNDef := TdvIfnDef.Create('IOS');
    IfNDef.LineBreaks := 0;
    UnitNode.InterfaceSection.UsesList.BeforeNode.InsertChild( IfDef );
    IfDef.Defined.InsertChild(IfNDef);
    Define := TdvDefine.Create(utProtect);
    IfNDef.UnDefined.InsertChild( Define );
  end else begin
    Log.Insert(EPlatformNotSupported,TLogSeverity.lsWarning,[LogBind('platform',XMLNode.Attributes['name'])]);
  end;
  if assigned(IfDef) then begin
    if LastPlatform then begin
      IfDef.LineBreaks := 2;
    end;
  end;
  Result := True;
end;

function TdvXMLParser.ParseRegistryPlatforms( XMLNode: IXMLNode; UnitNode: IdvASTUnit ): boolean;
var
  idx: int32;
begin
  Result := False;
  //- Check that there are child nodes.
  if XMLNode.ChildNodes.Count=0 then begin
    Log.Insert(EMissingPlatforms,TLogSeverity.lsWarning);
    exit;
  end;
  //- Loop the child nodes.
  for idx := 0 to pred(XMLNode.ChildNodes.Count) do begin
    //- Ensure the node is a platform.
    if not MatchNode(XMLNode.ChildNodes[idx],'platform','platforms') then begin
      exit;
    end;
    //- We have a platform node, lets take a look..
    if not ParsePlatformNode(XMLNode.ChildNodes[idx],UnitNode,idx=pred(XMLNode.ChildNodes.Count)) then begin
      exit;
    end;
  end;
  UnitNode.InterfaceSection.UsesList.InsertChild(TdvLabel.Create('sysutils'));
  UnitNode.InterfaceSection.UsesList.InsertChild(TdvLabel.Create('darkDynlib'));
  Result := True;
end;

function TdvXMLParser.ParseRegistryTags( XMLNode: IXMLNode; ASTNode: IdvASTNode ): boolean;
begin
  Result := True; //- skip tags, what else is there to do with them?
  Log.Insert(ESkippedNode,TLogSeverity.lsWarning,[LogBind('nodetype','tags'),LogBind('because','tags not required for generator.')]);
end;

function TdvXMLParser.VerifyMakeVersion( XMLNode: IXMLNode ): boolean;
var
  text: string;
begin
  //- Verify that the VK_MAKE_VERSION macro has not changed since this
  //- generator was writte. The macro is hard coded into the AST and so
  //- this generator would need to be modified to account for the change.
  Result := False;
  //- I should have three child nodes
  if XMLNode.ChildNodes.Count<>3 then begin
    exit;
  end;
  //- My first child node has set text.
  text := XMLNode.ChildNodes[0].Text;
  if Trim(text)<>'#define' then begin
    exit;
  end;
  //- My second child node is a 'name' node
  if XMLNode.ChildNodes[1].nodeName<>'name' then begin
    exit;
  end;
  //- My thid child node is set text.
  text := XMLNode.ChildNodes[2].Text;
  if Trim(text)<>'(major, minor, patch) \'+chr($A)+'    (((major) << 22) | ((minor) << 12) | (patch))' then begin
    exit;
  end;
  Result := True;
end;

function TdvXMLParser.VerifyVersionMajor( XMLNode: IXMLNode ): boolean;
var
  text: string;
begin
  //- Verify that the VK_MAKE_VERSION_MAJOR macro has not changed since this
  //- generator was writte. The macro is hard coded into the AST and so
  //- this generator would need to be modified to account for the change.
  Result := False;
  //- I should have three child nodes
  if XMLNode.ChildNodes.Count<>3 then begin
    exit;
  end;
  //- My first child node has set text.
  text := XMLNode.ChildNodes[0].Text;
  if Trim(text)<>'#define' then begin
    exit;
  end;
  //- My second child node is a 'name' node
  if XMLNode.ChildNodes[1].nodeName<>'name' then begin
    exit;
  end;
  //- My thid child node is set text.
  text := XMLNode.ChildNodes[2].Text;
  if Trim(text)<>'(version) ((uint32_t)(version) >> 22)' then begin
    exit;
  end;
  Result := True;
end;

function TdvXMLParser.VerifyVersionMinor( XMLNode: IXMLNode ): boolean;
var
  text: string;
begin
  //- Verify that the VK_MAKE_VERSION_MINOR macro has not changed since this
  //- generator was writte. The macro is hard coded into the AST and so
  //- this generator would need to be modified to account for the change.
  Result := False;
  //- I should have three child nodes
  if XMLNode.ChildNodes.Count<>3 then begin
    exit;
  end;
  //- My first child node has set text.
  text := XMLNode.ChildNodes[0].Text;
  if Trim(text)<>'#define' then begin
    exit;
  end;
  //- My second child node is a 'name' node
  if XMLNode.ChildNodes[1].nodeName<>'name' then begin
    exit;
  end;
  //- My thid child node is set text.
  text := XMLNode.ChildNodes[2].Text;
  if Trim(text)<>'(version) (((uint32_t)(version) >> 12) & 0x3ff)' then begin
    exit;
  end;
  Result := True;
end;

function TdvXMLParser.VerifyVersionPatch( XMLNode: IXMLNode ): boolean;
var
  text: string;
begin
  //- Verify that the VK_MAKE_VERSION_PATCH macro has not changed since this
  //- generator was writte. The macro is hard coded into the AST and so
  //- this generator would need to be modified to account for the change.
  Result := False;
  //- I should have three child nodes
  if XMLNode.ChildNodes.Count<>3 then begin
    exit;
  end;
  //- My first child node has set text.
  text := XMLNode.ChildNodes[0].Text;
  if Trim(text)<>'#define' then begin
    exit;
  end;
  //- My second child node is a 'name' node
  if XMLNode.ChildNodes[1].nodeName<>'name' then begin
    exit;
  end;
  //- My thid child node is set text.
  text := XMLNode.ChildNodes[2].Text;
  if Trim(text)<>'(version) ((uint32_t)(version) & 0xfff)' then begin
    exit;
  end;
  Result := True;
end;

function TdvXMLParser.VerifyDefineHandle( XMLNode: IXMLNode ): boolean;
var
  text: string;
begin
  //- Verify that the VK_DEFINE_HANDLE macro has not changed since this
  //- generator was writte. The macro is hard coded into the AST and so
  //- this generator would need to be modified to account for the change.
  Result := False;
  //- I should have three child nodes
  if XMLNode.ChildNodes.Count<>3 then begin
    exit;
  end;
  //- My first child node has set text.
  text := XMLNode.ChildNodes[0].Text;
  if Trim(text)<>'#define' then begin
    exit;
  end;
  //- My second child node is a 'name' node
  if XMLNode.ChildNodes[1].nodeName<>'name' then begin
    exit;
  end;
  //- My thid child node is set text.
  text := XMLNode.ChildNodes[2].Text;
  if Trim(text)<>'(object) typedef struct object##_T* object;' then begin
    exit;
  end;
  Result := True;
end;

function TdvXMLParser.VerifyAPIVersion( XMLNode: IXMLNode ): boolean;
var
  text: string;
begin
  //- Verify that the VK_API_VERSION macro has not changed since this
  //- generator was writte. The macro is hard coded into the AST and so
  //- this generator would need to be modified to account for the change.
  Result := False;
  //- I should have four child nodes
  if XMLNode.ChildNodes.Count<>4 then begin
    exit;
  end;
  //- My first child node has set text.
  text := XMLNode.ChildNodes[0].Text;
  if Trim(text)<>'// DEPRECATED: This define has been removed. Specific version defines (e.g. VK_API_VERSION_1_0), or the VK_MAKE_VERSION macro, should be used instead.'+chr($A)+'//#define' then begin
    exit;
  end;
  //- My second child node is a 'name' node
  if XMLNode.ChildNodes[1].nodeName<>'name' then begin
    exit;
  end;
  //- My third child node is a 'type' node with 'VK_MAKE_VERSION' text.
  if XMLNode.ChildNodes[2].nodeName<>'type' then begin
    exit;
  end;
  text := XMLNode.ChildNodes[2].Text;
  if Trim(text)<>'VK_MAKE_VERSION' then begin
    exit;
  end;
  //- My fourth child node is set text.
  text := XMLNode.ChildNodes[3].Text;
  if Trim(text)<>'(1, 0, 0) // Patch version should always be set to 0' then begin
    exit;
  end;
  Result := True;
end;

function TdvXMLParser.VerifyIAintParsingThat( XMLNode: IXMLNode ): boolean;
var
  text: string;
begin
  //- Verify that the VK_DEFINE_NON_DISPATCHABLE_HANDLE macro has not changed
  //- since this generator was writte. The macro is hard coded into the AST
  //- and so this generator would need to be modified to account for the change.
  Result := False;
  //- I should have four child nodes
  if XMLNode.ChildNodes.Count<>1 then begin
    exit;
  end;
  //- My child node has set text.
  text := XMLNode.ChildNodes[0].Text;
  if Trim(text)<>
      '#if !defined(VK_DEFINE_NON_DISPATCHABLE_HANDLE)'+chr($A)+
      '#if defined(__LP64__) || defined(_WIN64) || (defined(__x86_64__) && !defined(__ILP32__) ) || '+
      'defined(_M_X64) || defined(__ia64) || defined (_M_IA64) || defined(__aarch64__) || defined(__powerpc64__)'+chr($A)+
      '        #define VK_DEFINE_NON_DISPATCHABLE_HANDLE(object) typedef struct object##_T *object;'+chr($A)+
      '#else'+chr($A)+
      '        #define VK_DEFINE_NON_DISPATCHABLE_HANDLE(object) typedef uint64_t object;'+chr($A)+
      '#endif'+chr($A)+'#endif'
   then begin
    exit;
  end;
  Result := True;
end;

function TdvXMLParser.RemoveComments( source: string ): string;
var
  Start: int32;
  Fin: int32;
  WorkStr: string;
begin
  WorkStr := Source;
  repeat
    Start := Pos('//',WorkStr);
    if Start>0 then begin
      Fin := Pos(chr($A),WorkStr,Start);
      if Fin=0 then begin
        {$ifdef NEXTGEN}
          Fin := Length(WorkStr);
        {$else}
          Fin := succ(Length(WorkStr));
        {$endif}
      end;
      Delete(WorkStr,Start,Fin-Start);
    end;
  until Start = 0;
  Result := Trim(WorkStr);
end;

class procedure TdvXMLParser.Explode(cDelimiter, sValue: string; var Results: TArrayOfString; iCount: uint32 = 0);
var
  s: string;
  i,p: int32;
begin
  s:= sValue;
  i:= 0;
  while length(s) > 0 do begin
    inc(i);
    SetLength(Results, i);
    p:= pos(cDelimiter,s);
    if (p>0) and ((i<iCount) OR (iCount = 0)) then begin
      Results[pred(i)]:=copy(s,0,p-1);
      s:=copy(s,p + length(cDelimiter),length(s));
    end else begin
      Results[pred(i)]:= s;
      s:='';
    end;
  end;
end;

function TdvXMLParser.ParseDefineMakeVersion( XMLNode: IXMLNode; UnitNode: IdvASTUnit ): boolean;
var
  text: string;
  idx: int32;
  ValueStr: string;
  NameNode: IXMLNode;
  TypeNode: IXMLNode;
  Parameters: TArrayOfString;
  ParamStr: string;
begin
  Result := False;
  //- My first node (less comments) should be '#define';
  if XMLNode.ChildNodes.Count<2 then begin
    exit;
  end;
  text := Uppercase(Trim(RemoveComments(XMLNode.ChildNodes[0].Text)));
  if text<>'#DEFINE' then begin
    exit;
  end;
  //- At this point, we're confidently parsing a constant declaration.
  //- Get the constant name and type.
  NameNode := XMLNode.ChildNodes.FindNode('name');
  TypeNode := XMLNode.ChildNodes.FindNode('type');
  if not (assigned(NameNode) and assigned(TypeNode)) then begin
    exit;
  end;
  //- The constant value can be obtained by combining all child nodes but the first,
  //- and ignoring the 'name' and 'type' nodes.
  ValueStr := '';
  for idx := 1 to pred(XMLNode.ChildNodes.Count) do begin
    if (XMLNode.ChildNodes[idx]<>NameNode) and
       (XMLNode.ChildNodes[idx]<>TypeNode) then begin
      ValueStr := ValueStr + XMLNode.ChildNodes[idx].Text;
     end;
  end;
  ValueStr := RemoveComments(ValueStr);
  //- Insert VK_MAKE_VERSION constant.
  ValueStr := StringReplace(ValueStr,'(','',[rfReplaceAll, rfIgnoreCase]);
  Explode(',',ValueStr,Parameters);
  if Length(Parameters)<>3 then begin
    Log.Insert(EInvalidMacroParameters,TLogSeverity.lsError,[LogBind('macro','VK_MAKE_VERSION'),LogBind('parameters',ValueStr)]);
    exit;
  end;
  //- Build parameter string.
  ParamStr := '';
  if Parameters[0]<>'0' then begin
    ParamStr := ParamStr + '(' + Trim(Parameters[0]) + ' shl 22)';
  end;
  if Parameters[1]<>'0' then begin
    ParamStr := ParamStr + ' or (' + Trim(Parameters[0]) + ' shl 12)';
  end;
  if Parameters[2]<>'0' then begin
    ParamStr := ParamStr + ' or ' + Trim(Parameters[0]);
  end;
  //- Insert node.
  UnitNode.InterfaceSection.Constants.InsertChild( TdvConstant.Create(NameNode.Text,ParamStr) );
  Result := True;
end;

function TdvXMLParser.ParseConstantDefineNode( XMLNode: IXMLNode; UnitNode: IdvASTUnit ): boolean;
var
  text: string;
  idx: int32;
  ValueStr: string;
  NameNode: IXMLNode;
begin
  Result := False;
  //- My first node (less comments) should be '#define';
  if XMLNode.ChildNodes.Count<>3 then begin
    exit;
  end;
  text := Uppercase(Trim(RemoveComments(XMLNode.ChildNodes[0].Text)));
  if text<>'#DEFINE' then begin
    if text='STRUCT' then begin
      Log.Insert(ESkippedNode,TLogSeverity.lsWarning,[LogBind('nodetype','type'),LogBind('because','node contains "struct <name>...</name>;" not needed?')]);
      Result := True;
      exit;
    end;
    exit;
  end;
  //- At this point, we're confidently parsing a constant declaration.
  //- Get the constant name.
  NameNode := XMLNode.ChildNodes.FindNode('name');
  if not assigned(NameNode) then begin
    exit;
  end;
  //- The constant value can be obtained by combining all child nodes but the first,
  //- and ignoring the 'name' and 'type' nodes.
  ValueStr := '';
  for idx := 1 to pred(XMLNode.ChildNodes.Count) do begin
    if (XMLNode.ChildNodes[idx]<>NameNode) then begin
      ValueStr := ValueStr + XMLNode.ChildNodes[idx].Text;
    end;
  end;
  ValueStr := RemoveComments(ValueStr);
  //- Insert constant.
  UnitNode.InterfaceSection.Constants.InsertChild( TdvConstant.Create(NameNode.Text, ValueStr ) );
  Result := True;
end;

function TdvXMLParser.ParseDefineTypeNode( XMLNode: IXMLNode; UnitNode: IdvASTUnit ): boolean;
var
  NameNode: IXMLNode;
  utNodeName: string;
  FunctionHeader: IdvFunctionHeader;
  aFunction: IdvFunction;
  utSubType: string;
  utAttribute: string;
begin
  Result := False;
  // There must be at least one node.
  if XMLNode.ChildNodes.Count=0 then begin
    Log.Insert(ESkippedNode,TLogSeverity.lsError,[LogBind('nodetype','type'),LogBind('because','node is definition with no child nodes.')]);
    exit;
  end;
  //- Look at the first node, is it a text element?
  if not (XMLNode.ChildNodes.First.NodeType = TNodeType.ntText) then begin
    Log.Insert(ESkippedNode,TLogSeverity.lsError,[LogBind('nodetype','type'),LogBind('because','node is definition but first child is not text.')]);
    exit;
  end;

  //- Is this the node for 'VK_DEFINE_NON_DISPATCHABLE_HANDLE' ?
  if MatchAttributes( XMLNode, ['category','name'], 'type', FALSE ) then begin
    utAttribute := Uppercase(Trim(XMLNode.Attributes['name']));
    if utAttribute = 'VK_DEFINE_NON_DISPATCHABLE_HANDLE' then begin
      if not VerifyIAintParsingThat( XMLNode ) then begin
        Log.Insert(EMacroChanged,TLogSeverity.lsError,[LogBind('nodetype','type'),LogBind('macro',XMLNode.Attributes['name'])]);
        Result := False;
        exit;
      end;
      Result := True;
      exit;
    end;
  end;

  //- Lets get the name of the node and see if it's one that must be handled
  //- specially (macros f.x.).
  NameNode := XMLNode.ChildNodes.FindNode('name');
  if not assigned(NameNode) then begin
    Log.Insert(ESkippedNode,TLogSeverity.lsError,[LogBind('nodetype','type'),LogBind('because','node is a definition with no name.')]);
    exit;
  end;
  utNodeName := NameNode.Text;
  if utNodeName='VK_MAKE_VERSION' then begin

    if not VerifyMakeVersion( XMLNode ) then begin
      Log.Insert(EMacroChanged,TLogSeverity.lsError,[LogBind('nodetype','type'),LogBind('macro',NameNode.Text)]);
      exit;
    end;

    //- Build and insert the make version macro.
    FunctionHeader := UnitNode.InterfaceSection.InsertChild(TdvFunctionHeader.Create('VK_MAKE_VERSION')) as IdvFunctionHeader;
    FunctionHeader.ReturnType := 'int32';
    FunctionHeader.InsertChild( TdvParameter.Create('VersionMajor','int32') );
    FunctionHeader.InsertChild( TdvParameter.Create('VersionMinor','int32') );
    FunctionHeader.InsertChild( TdvParameter.Create('VersionPatch','int32') );
    aFunction := UnitNode.ImplementationSection.InsertChild(TdvFunction.Create('VK_MAKE_VERSION')) as IdvFunction;
    aFunction.Header.ReturnType := 'int32';
    aFunction.Header.InsertChild( TdvParameter.Create('VersionMajor','int32') );
    aFunction.Header.InsertChild( TdvParameter.Create('VersionMinor','int32') );
    aFunction.Header.InsertChild( TdvParameter.Create('VersionPatch','int32') );
    aFunction.Body.Content := 'Result := ((VersionMajor shl 22) or (VersionMinor shl 12)) or VersionPatch;';

  end else if utNodeName='VK_VERSION_MAJOR' then begin

    if not VerifyVersionMajor( XMLNode ) then begin
      Log.Insert(EMacroChanged,TLogSeverity.lsError,[LogBind('nodetype','type'),LogBind('macro',NameNode.Text)]);
      exit;
    end;

    //- Build and insert the make version major macro
    FunctionHeader := UnitNode.InterfaceSection.InsertChild(TdvFunctionHeader.Create('VK_VERSION_MAJOR')) as IdvFunctionHeader;
    FunctionHeader.ReturnType := 'int32';
    FunctionHeader.InsertChild( TdvParameter.Create('Version','int32') );
    aFunction := UnitNode.ImplementationSection.InsertChild(TdvFunction.Create('VK_VERSION_MAJOR')) as IdvFunction;
    aFunction.Header.ReturnType := 'int32';
    aFunction.Header.InsertChild( TdvParameter.Create('Version','int32') );
    aFunction.Body.Content := 'Result := Version shr 22;';


  end else if utNodeName='VK_VERSION_MINOR' then begin

    if not VerifyVersionMinor( XMLNode ) then begin
      Log.Insert(EMacroChanged,TLogSeverity.lsError,[LogBind('nodetype','type'),LogBind('macro',NameNode.Text)]);
      exit;
    end;

    //- Build and insert the make version minor macro
    FunctionHeader := UnitNode.InterfaceSection.InsertChild(TdvFunctionHeader.Create('VK_VERSION_MINOR')) as IdvFunctionHeader;
    FunctionHeader.ReturnType := 'int32';
    FunctionHeader.InsertChild( TdvParameter.Create('Version','int32') );
    aFunction := UnitNode.ImplementationSection.InsertChild(TdvFunction.Create('VK_VERSION_MINOR')) as IdvFunction;
    aFunction.Header.ReturnType := 'int32';
    aFunction.Header.InsertChild( TdvParameter.Create('Version','int32') );
    aFunction.Body.Content := 'Result := (Version shr 12) and $3ff;';

  end else if utNodeName='VK_VERSION_PATCH' then begin

    if not VerifyVersionPatch( XMLNode ) then begin
      Log.Insert(EMacroChanged,TLogSeverity.lsError,[LogBind('nodetype','type'),LogBind('macro',NameNode.Text)]);
      exit;
    end;

    //- Build and insert the make version minor macro
    FunctionHeader := UnitNode.InterfaceSection.InsertChild(TdvFunctionHeader.Create('VK_VERSION_PATCH')) as IdvFunctionHeader;
    FunctionHeader.ReturnType := 'int32';
    FunctionHeader.InsertChild( TdvParameter.Create('Version','int32') );
    aFunction := UnitNode.ImplementationSection.InsertChild(TdvFunction.Create('VK_VERSION_PATCH')) as IdvFunction;
    aFunction.Header.ReturnType := 'int32';
    aFunction.Header.InsertChild( TdvParameter.Create('Version','int32') );
    aFunction.Body.Content := 'Result := $fff;';

  end else if utNodeName='VK_DEFINE_HANDLE' then begin

    if not VerifyDefineHandle( XMLNode ) then begin
      Log.Insert(EMacroChanged,TLogSeverity.lsError,[LogBind('nodetype','type'),LogBind('macro',NameNode.Text)]);
      exit;
    end;

  end else if utNodeName='VK_API_VERSION' then begin

    if not VerifyAPIVersion( XMLNode ) then begin
      Log.Insert(EMacroChanged,TLogSeverity.lsError,[LogBind('nodetype','type'),LogBind('macro',NameNode.Text)]);
      exit;
    end;

  end else begin

    //- Does the node have a 'type' subnode?
    if assigned(XMLNode.ChildNodes.FindNode('type')) then begin

      utSubType := Uppercase(Trim(XMLNode.ChildNodes.FindNode('type').Text));
      if utSubType<>'VK_MAKE_VERSION' then begin
        Log.Insert(ESkippedNode,TLogSeverity.lsError,[LogBind('nodetype',XMLNode.NodeName),LogBind('because','not yet implemented.')]);
        exit;
      end;
      if not ParseDefineMakeVersion( XMLNode, UnitNode ) then begin
        Log.Insert(EUnknownXMLFormat,TLogSeverity.lsError);
        exit;
      end;

    end else begin

      if not ParseConstantDefineNode( XMLNode, UnitNode ) then begin
        Log.Insert(EUnknownXMLFormat,TLogSeverity.lsError);
        Result := False;
        exit;
      end;

    end;
  end;
  Result := True;
end;

function TdvXMLParser.ParseAliasNodeType( XMLNode: IXMLNode; UnitNode: IdvASTUnit ): boolean;
var
  NameNode: IXMLNode;
  TypeNode: IXMLNode;
  Name: string;
  TypeKind: string;
begin
  Result := False;
  //- Simple Aliases, should have a type and a name.
  NameNode := XMLNode.ChildNodes.FindNode('name');
  TypeNode := XMLNode.ChildNodes.FindNode('type');
  if not (assigned(NameNode) and assigned(TypeNode)) then begin
    if MatchAttributes( XMLNode, ['name','alias'], '', FALSE) then begin
      Name := XMLNode.Attributes['name'];
      TypeKind := XMLNode.Attributes['alias'];
    end else begin
      if not assigned(NameNode) then begin
        Log.Insert(EMissingNode,TLogSeverity.lsError,[LogBind('nodetype','name'),LogBind('in',XMLNode.NodeName+' category="basetype"')]);
      end else begin
        Log.Insert(EMissingNode,TLogSeverity.lsError,[LogBind('nodetype','type'),LogBind('in',XMLNode.NodeName+' category="basetype"')]);
      end;
      exit;
    end;
  end else begin
    Name := NameNode.Text;
    TypeKind := TypeNode.Text;
  end;
  //- Insert the type alias.
  (UnitNode.InterfaceSection.Types.InsertChild( TdvTypeDef.Create(Name,TdvTypeKind.tkAlias) ) as IdvTypeDef).InsertChild( TdvTypeDef.Create( TypeKind, TdvTypeKind.tkUserDefined ) );
  Result := True;
end;

function TdvXMLParser.ParseHandleTypeNode( XMLNode: IXMLNode; UnitNode: IdvASTUnit ): boolean;
var
  utType: string;
  TypeNode: IXMLNode;
  NameNode: IXMLNode;
  NameStr: string;
begin
  Result := False;
  TypeNode := XMLNode.ChildNodes.FindNode('type');
  if not assigned(TypeNode) then begin
    Result := ParseAliasNodeType( XMLNode, UnitNode );
    exit;
  end;
  utType := Uppercase(Trim(TypeNode.Text));
  if (utType<>'VK_DEFINE_HANDLE') and (utType<>'VK_DEFINE_NON_DISPATCHABLE_HANDLE') then begin
    Log.Insert(EUnrecognizedXMLTag,TLogSeverity.lsError,[LogBind('xmltag',XMLNode.nodename+' category="handle"')]);
    exit;
  end;
  //- If we got here, whatever node it is, it's an alias of nativeuint
  NameNode := XMLNode.ChildNodes.FindNode('name');
  if not assigned(NameNode) then begin
    Log.Insert(EUnrecognizedXMLTag,TLogSeverity.lsError,[LogBind('xmltag',XMLNode.nodename+' category="handle" - missing <name>')]);
    exit;
  end;
  NameStr := NameNode.Text;
  (UnitNode.InterfaceSection.Types.InsertChild( TdvTypeDef.Create(NameStr,TdvTypeKind.tkAlias) ) as IdvTypeDef).InsertChild( TdvTypeDef.Create( 'nativeuint', TdvTypeKind.tkUserDefined ) );
  Result := True;
end;

function TdvXMLParser.ParseEnumTypeNode( XMLNode: IXMLNode; UnitNode: IdvASTUnit ): boolean;
var
  NameStr: string;
begin
  // Ensure we have an enum.
  if not MatchAttributes(XMLNode,['name','category'],'type category=enum') then begin
    exit;
  end;
  NameStr := XMLNode.Attributes['name'];
  UnitNode.InterfaceSection.Types.InsertChild( TdvTypeDef.Create(NameStr, TdvTypeKind.tkEnum) );
  Result := True;
end;

function TdvXMLParser.GetIdentifier( SourceStr: string; var PtrCount: uint32 ): string;
var
  Start, Fin, idx: int32;
begin
  Result := '';
  PtrCount := 0;
  {$ifdef NEXTGEN} Start := 0; {$else} Start := 1; {$endif}
  {$ifdef NEXTGEN} Fin := pred(Length(SourceStr)); {$else} Fin := Length(SourceStr); {$endif}
  for idx := Start to Fin do begin
    if CharInSet(SourceStr[idx],
       [ '0','1','2','3','4','5','6','7','8','9','_',
         'a','b','c','d','e','f','g','h','i','j','k',
         'l','m','n','o','p','q','r','s','t','u','v',
         'w','x','y','z','A','B','C','D','E','F','G',
         'H','I','J','K','L','M','N','O','P','Q','R',
         'S','T','U','V','W','X','Y','X' ]) then begin
      Result := Result + SourceStr[idx];
    end else if SourceStr[idx]=' ' then begin
      continue;
    end else if SourceStr[idx]='*' then begin
      inc(PtrCount);
    end else begin
      exit;
    end;
  end;
end;

function TdvXMLParser.ParseFuncPointerTypeNode( XMLNode: IXMLNode; UnitNode: IdvASTUnit ): boolean;
var
  FunctionName: string;
  ReplaceString: string;
  ReturnType: string;
  utReturnType: string;
  PtrCount: uint32;
  IsProcedure: boolean;
  FuncTypeDef: IdvTypeDef;
  idx: uint32;
  ReturnTypeNode: IdvTypeDef;
  PS: string;
  PreviousName: string;
begin
  // Parsing a function pointer.
  Result := False;
  // There should be at least a text node for the return type, and a function name node.
  if XMLNode.ChildNodes.Count<2 then begin
    Log.Insert(ESkippedNode,TLogSeverity.lsError,[LogBind('nodetype',XMLNode.NodeName),LogBind('because','function pointer has no return type or function name.')]);
    exit;
  end;
  //- Get the return type as a string.
  ReturnType := XMLNode.ChildNodes[0].Text;
  ReturnType := StringReplace(ReturnType,'typedef','',[rfReplaceAll,rfIgnoreCase]);
  ReturnType := GetIdentifier( ReturnType, PtrCount );
  utReturnType := Uppercase(Trim(ReturnType));

  // My second node should be the name of the function
  if Uppercase(Trim(XMLNode.ChildNodes[1].nodeName))<>'NAME' then begin
    Log.Insert(ESkippedNode,TLogSeverity.lsError,[LogBind('nodetype',XMLNode.NodeName),LogBind('because','<name> node for function pointer not found.')]);
    exit;
  end;
  FunctionName := XMLNode.ChildNodes[1].Text;
  //- If the return type is a void, and not a pointer, we're defining a procedure call-back
  if (utReturnType='VOID') and (PtrCount=0) then begin
    FuncTypeDef := UnitNode.InterfaceSection.Types.InsertChild(TdvTypeDef.Create(FunctionName,tkFuncPointer)) as IdvTypeDef;
    FuncTypeDef.InsertChild(TdvTypeDef.Create('',TdvTypeKind.tkVoid));
  end else if (utReturnType='VOID') and (PtrCount=1) then begin
    FuncTypeDef := UnitNode.InterfaceSection.Types.InsertChild(TdvTypeDef.Create(FunctionName,tkFuncPointer)) as IdvTypeDef;
    FuncTypeDef.InsertChild(TdvTypeDef.Create('',TdvTypeKind.tkPointer));
  end else begin
    //- We must build the return type as a separate type def.
    if PtrCount=0 then begin
      //- Straight return type.
      FuncTypeDef := UnitNode.InterfaceSection.Types.InsertChild(TdvTypeDef.Create(FunctionName,tkFuncPointer)) as IdvTypeDef;
      FuncTypeDef.InsertChild(TdvTypeDef.Create(ReturnType,TdvTypeKind.tkUserDefined));
    end else begin
      //- Generate the return type.
      PreviousName := 'T'+FunctionName+'Result';
      ReturnTypeNode := UnitNode.InterfaceSection.Types.InsertChild(TdvTypeDef.Create(PreviousName,tkAlias)) as IdvTypeDef;
      ReturnTypeNode.InsertChild(TdvTypeDef.Create(ReturnType,TdvTypeKind.tkUserDefined));
      //- Add pointers to the return type node.
      Ps := '';
      for idx := 0 to pred(PtrCount) do begin
        Ps := Ps + 'P';
        ReturnTypeNode := UnitNode.InterfaceSection.Types.InsertChild(TdvTypeDef.Create(Ps+FunctionName+'Result',tkTypedPointer)) as IdvTypeDef;
        ReturnTypeNode.InsertChild(TdvTypeDef.Create(PreviousName,tkUserDefined));
        PreviousName := 'P'+PreviousName;
      end;
      FuncTypeDef := UnitNode.InterfaceSection.Types.InsertChild(TdvTypeDef.Create(FunctionName,tkFuncPointer)) as IdvTypeDef;
      FuncTypeDef.InsertChild(TdvTypeDef.Create(PreviousName,TdvTypeKind.tkUserDefined));
    end;
  end;
  //- Are we done yet?


  Result := True;
end;

function TdvXMLParser.ParseStructTypeNode( XMLNode: IXMLNode; UnitNode: IdvASTUnit ): boolean;
begin
  Log.Insert(ESkippedNode,TLogSeverity.lsError,[LogBind('nodetype',XMLNode.NodeName),LogBind('because','not yet implemented.')]);
  Result := True;
end;

function TdvXMLParser.ParseUnionTypeNode( XMLNode: IXMLNode; UnitNode: IdvASTUnit ): boolean;
begin
  Log.Insert(ESkippedNode,TLogSeverity.lsError,[LogBind('nodetype',XMLNode.NodeName),LogBind('because','not yet implemented.')]);
  Result := True;
end;

function TdvXMLParser.ParseIncludeTypeNode( XMLNode: IXMLNode; UnitNode: IdvASTUnit ): boolean;
begin
  Result := False;
  if not MatchAttributes(XMLNode,['name','category'],'type') then begin
    exit;
  end;
  //- Simply skip include nodes, we're building all includes in!
  Log.Insert(ESkippedNode,TLogSeverity.lsWarning,[LogBind('nodetype','type'),LogBind('because',XMLNode.Attributes['name']+' is included in main unit unit')]);
  Result := True;
end;

function TdvXMLParser.ParseCommentToASTNode(XMLNode: IXMLNode; TargetNode: IdvASTNode): boolean;
var
  idx: uint32;
  Comment: IdvASTComment;
begin
  Result := True;
  if XMLNode.ChildNodes.Count=0 then begin
    exit;
  end;
  for idx := 0 to pred(XMLNode.ChildNodes.Count) do begin
    Comment := TdvASTComment.Create(XMLNode.ChildNodes[idx].Text);
    TargetNode.InsertChild(Comment);
  end;
end;

function TdvXMLParser.ParseTypeNode( XMLNode: IXMLNode; UnitNode: IdvASTUnit ): boolean;
var
  utCategory: string;
begin
  Result := False;
  //- Handle those nodes
  if not MatchAttributes(XMLNode,['category'],'type',FALSE) then begin
    if (
         MatchAttributes(XMLNode,['requires','name'],'type',FALSE) or
         MatchAttributes(XMLNode,['requires'],'type',FALSE) or
         MatchAttributes(XMLNode,['name'],'type',FALSE)
       ) then begin
      Log.Insert(ESkippedNode,TLogSeverity.lsWarning,[LogBind('nodetype','type'),LogBind('because','unused node')]);
      Result := True; // processing can continue, these are un-required nodes.
    end else begin
      Log.Insert(ESkippedNode,TLogSeverity.lsWarning,[LogBind('nodetype','type'),LogBind('because','no category attribute')]);
    end;
    exit;
  end;
  //- Which category of type node is this?
  utCategory := Uppercase(Trim(XMLNode.Attributes['category']));
  if utCategory='DEFINE' then begin
    Result := ParseDefineTypeNode(XMLNode,UnitNode);
  end else if utCategory='BASETYPE' then begin
    Result := ParseAliasNodeType(XMLNode,UnitNode);
  end else if utCategory='BITMASK' then begin
    Result := ParseAliasNodeType(XMLNode,UnitNode);
  end else if utCategory='HANDLE' then begin
    Result := ParseHandleTypeNode(XMLNode,UnitNode);
  end else if utCategory='ENUM' then begin
    Result := ParseEnumTypeNode(XMLNode,UnitNode);
  end else if utCategory='FUNCPOINTER' then begin
    Result := ParseFuncPointerTypeNode(XMLNode,UnitNode);
  end else if utCategory='STRUCT' then begin
    Result := ParseStructTypeNode(XMLNode,UnitNode);
  end else if utCategory='INCLUDE' then begin
    Result := ParseIncludeTypeNode(XMLNode,UnitNode);
  end else if utCategory='UNION' then begin
    Result := ParseUnionTypeNode(XMLNode,UnitNode);
  end else begin
    Log.Insert(ESkippedNode,TLogSeverity.lsError,[LogBind('nodetype','type'),LogBind('because','Unknown category '+XMLNode.Attributes['category'])]);
    exit;
  end;
end;

function TdvXMLParser.ParseRegistryTypes( XMLNode: IXMLNode; UnitNode: IdvASTUnit ): boolean;
var
  idx: uint32;
begin
  Result := False;
  if XMLNode.ChildNodes.Count=0 then begin
    Log.Insert(EMissingTypes,TLogSeverity.lsWarning);
    exit;
  end;
  //- Loop the child ndoes
  for idx := 0 to pred(XMLNode.ChildNodes.Count) do begin
    //- Make sure we have a matching node type. (or comment)
    if MatchNode(XMLNode.ChildNodes[idx],'comment','types',FALSE) then begin
      if not ParseCommentToASTNode(XMLNode.ChildNodes[idx],UnitNode.InterfaceSection) then begin
        exit;
      end;
      continue;
    end;
    if not MatchNode(XMLNode.ChildNodes[idx],'type','types') then begin
      exit;
    end;
    //- Parse the type node.
    if not ParseTypeNode(XMLNode.ChildNodes[idx],UnitNode) then begin
      exit;
    end;
  end;
  Result := True;
end;

function TdvXMLParser.ParseEnumValue( Enum: IdvASTNode; XMLNode: IXMLNode; UnitNode: IdvASTUnit ): boolean;
var
  NameStr: string;
  ValueStr: string;

//  idx: uint32;
//  Attrib: string;
begin
  Result := False;
  //- Check attributes
  if ( MatchAttributes(XMLNode,['name','value'],'',FALSE) or
       MatchAttributes(XMLNode,['name','alias'],'',FALSE) or
       MatchAttributes(XMLNode,['name','value','comment'],'',FALSE) or
       MatchAttributes(XMLNode,['name','alias','comment'],'',FALSE)) then begin
    NameStr := XMLNode.Attributes['name'];
    if XMLNode.HasAttribute('value') then begin
      ValueStr := XMLNode.Attributes['value'];
    end else begin
      ValueStr := XMLNode.Attributes['alias'];
    end;
  end else if ( MatchAttributes(XMLNode,['name','bitpos'],'',FALSE) or
                MatchAttributes(XMLNode,['name','bitpos','comment'],'',FALSE)) then begin
    NameStr := XMLNode.Attributes['name'];
    ValueStr := trim(XMLNode.Attributes['bitpos']);
    if ValueStr<>'0' then begin
      ValueStr := '1 shl '+ValueStr;
    end;
  end else begin
    Log.Insert(ESkippedNode,TLogSeverity.lsError,[LogBind('nodename','enum'),LogBind('because','enum has no valid combination of attribuets.')]);

//    for idx := 0 to pred(XMLNode.AttributeNodes.Count) do begin
//      Attrib := XMLNode.AttributeNodes[idx].nodename;
//    end;

    exit;
  end;
  //- If we made it here, we're valid.
  Enum.InsertChild(TdvConstant.Create(NameStr,ValueStr));
  Result := True;
end;

function TdvXMLParser.ParseRegistryEnums( XMLNode: IXMLNode; UnitNode: IdvASTUnit ): boolean;
var
  idx: uint32;
  ChildNode: IXMLNode;
  Enum: IdvASTNode;
  utNodeName: string;
begin
  Result := False;
  if XMLNode.ChildNodes.Count=0 then begin
    Log.Insert(ESkippedNode,TLogSeverity.lsWarning,[LogBind('nodetype','enums'),LogBind('because','enum node was empty')]);
    Result := True;
    exit;
  end;
  //- Check that the parent node has a name attribute.
  if not (
           MatchAttributes(XMLNode,['name','comment'],'',FALSE) or
           MatchAttributes(XMLNode,['name'],'',FALSE) or
           MatchAttributes(XMLNode,['name','type'],'',FALSE) or
           MatchAttributes(XMLNode,['name','type','comment'],'',FALSE)
         ) then begin
    Log.Insert(ESkippedNode,TLogSeverity.lsError,[LogBind('nodetype','enums'),LogBind('because','enum node has no valid combination of attribute.')]);
    exit;
  end;
  //- Create / Acqure enum node
  Enum := UnitNode.findEnumByName(XMLNode.Attributes['name']);
  if not assigned(Enum) then begin
    Enum := UnitNode.InterfaceSection.Types.InsertChild( TdvTypeDef.Create( XMLNode.Attributes['name'], TdvTypeKind.tkEnum ) );
  end;
  //- Loop through child nodes.
  for idx := 0 to pred(XMLNode.ChildNodes.Count) do begin
    ChildNode := XMLNode.ChildNodes[idx];
    utNodeName := Uppercase(Trim(ChildNode.NodeName));
    if utNodeName='COMMENT' then begin
      if not ParseCommentToASTNode(ChildNode,Enum.BeforeNode) then begin
        exit;
      end;
    end else if utNodeName = 'UNUSED' then begin
      Log.Insert(ESkippedNode,TLogSeverity.lsWarning,[LogBind('nodetype','unused'),LogBind('because','it''s not used.')]);
      continue;
    end else begin
      //- Parse the enum value
      if not ParseEnumValue( Enum, ChildNode, UnitNode ) then begin
        exit;
      end;
    end;
  end;
  Result := True;
end;

function TdvXMLParser.ParseRegistryCommands( XMLNode: IXMLNode; ASTNode: IdvASTNode ): boolean;
begin
  Result := True;
  Log.Insert(ESkippedNode,TLogSeverity.lsWarning,[LogBind('nodetype','commands'),LogBind('because','feature not yet implemented.')]);
end;

function TdvXMLParser.ParseRegistryFeature( XMLNode: IXMLNode; ASTNode: IdvASTNode ): boolean;
begin
  Result := True;
  Log.Insert(ESkippedNode,TLogSeverity.lsWarning,[LogBind('nodetype','feature'),LogBind('because','feature not yet implemented.')]);
end;

function TdvXMLParser.ParseRegistryExtensions( XMLNode: IXMLNode; ASTNode: IdvASTNode ): boolean;
begin
  Result := True;
  Log.Insert(ESkippedNode,TLogSeverity.lsWarning,[LogBind('nodetype','extensions'),LogBind('because','feature not yet implemented.')]);
end;

function TdvXMLParser.CreateVulkanUnit( ASTNode: IdvASTNode ): IdvASTUnit;
begin
  Result := ASTNode.InsertChild( TdvASTUnit.Create('vulkan') ) as IdvASTUnit;
  Result.InterfaceSection.InsertChild( TdvASTComment.Create('Aliases for c-types') );
  Result.InterfaceSection.Types.InsertChild( TdvTypeDef.Create('uint32_t',TdvTypeKind.tkAlias) ).InsertChild(TdvTypeDef.Create('',TdvTypeKind.tkuint32));
  Result.InterfaceSection.Types.InsertChild( TdvTypeDef.Create('uint64_t',TdvTypeKind.tkAlias) ).InsertChild(TdvTypeDef.Create('',TdvTypeKind.tkuint64));
end;

function TdvXMLParser.ParseRegistryNode( XMLNode: IXMLNode; ASTNode: IdvASTNode ): boolean;
var
  idx: uint32;
  ChildXMLNode: IXMLNode;
  utNodeName: string;
  MainUnit: IdvASTUnit;
begin
  Result := False;
  if XMLNode.ChildNodes.Count=0 then begin
    exit;
  end;
  //- Create the unit AST Node.
  MainUnit := CreateVulkanUnit( ASTNode );
  // Loop through knows and parse them all..
  for idx := 0 to pred(XMLNode.ChildNodes.Count) do begin
    ChildXMLNode := XMLNode.ChildNodes[idx];
    utNodeName := Uppercase(Trim(ChildXMLNode.NodeName));
    //- We only want to collect header comments, the rest are omitted.
    if utNodeName<>'COMMENT' then begin
      fCollectComments := False;
    end;
    //- Parse the node.
    if utNodeName='COMMENT' then begin
      if fCollectComments then begin
        if not ParseRegistryComment( ChildXMLNode, MainUnit ) then begin
          exit;
        end;
      end;
    end else if utNodeName='PLATFORMS' then begin
      if not ParseRegistryPlatforms( ChildXMLNode, MainUnit ) then begin
        exit;
      end;
    end else if utNodeName='TAGS' then begin
      if not ParseRegistryTags( ChildXMLNode, MainUnit ) then begin
        exit;
      end;
    end else if utNodeName='TYPES' then begin
      if not ParseRegistryTypes( ChildXMLNode, MainUnit ) then begin
        exit;
      end;
    end else if utNodeName='ENUMS' then begin
      if not ParseRegistryEnums( ChildXMLNode, MainUnit ) then begin
        exit;
      end;
    end else if utNodeName='COMMANDS' then begin
      if not ParseRegistryCommands( ChildXMLNode, MainUnit ) then begin
        exit;
      end;
    end else if utNodeName='FEATURE' then begin
      if not ParseRegistryFeature( ChildXMLNode, MainUnit ) then begin
        exit;
      end;
    end else if utNodeName='EXTENSIONS' then begin
      if not ParseRegistryExtensions( ChildXMLNode, MainUnit ) then begin
        exit;
      end;
    end else begin
      Log.Insert(EUnrecognizedXMLTag,TLogSeverity.lsWarning,[LogBind('xmltag',ChildXMLNode.NodeName)]);
    end;
  end;
  Result := True;
end;

function TdvXMLParser.ParseDocument( ParentASTNode: IdvASTNode ): boolean;
var
  idx: uint32;
  ChildXMLNode: IXMLNode;
  utName: string;
begin
  Result := False;
  //- We're expecting an xml node (xml version and encoding),
  //- and a single registry node.
  if fXMLDocument.ChildNodes.Count<>2 then begin
    exit;
  end;
  //- Loop through the nodes and process.
  for idx := 0 to pred(fXMLDocument.ChildNodes.Count) do begin
    ChildXMLNode := fXMLDocument.ChildNodes[idx];
    utName := Uppercase(Trim(ChildXMLNode.NodeName));
    if utName='XML' then begin
      if not ParseXMLNode(ChildXMLNode) then begin
        exit;
      end;
    end else if utName='REGISTRY' then begin
      if not ParseRegistryNode(ChildXMLNode,ParentASTNode) then begin
        exit;
      end;
    end else begin
      Log.Insert(EUnrecognizedXMLTag,TLogSeverity.lsWarning,[LogBind('xmltag',fXMLDocument.ChildNodes[idx].NodeName)]);
    end;
  end;
  //- If we made it here, parsing succeeded.
  Result := True;
end;

function TdvXMLParser.Parse( ASTRoot: IdvASTRootNode ): boolean;
begin
  Result := False;
  fCollectComments := True;
  //- Make sure we have the xml document open.
  if not OpenDocument then begin
    Log.Insert(EDocumentNotFound, TLogSeverity.lsError, [ LogBind('filename',fFilename)] );
    exit;
  end;
  //- Parse the registry node.
  Result := ParseDocument( ASTRoot );
end;

initialization
  Log.Register( EExpectedEncoding, 'Expected XML encoding attribute. <?xml encoding="">' );
  Log.Register( EUnexpectedEncodingType, 'Unexpected XML encoding "(%enctype%)", expected "UTF-8"' );
  Log.Register( EExpectedXMLVersion, 'Expected XML version attribute. <?xml version="">' );
  Log.Register( EUnexpectedVersion, 'Unexpected XML version "(%version%)" expected "1.0"' );
  Log.Register( EDocumentNotFound, 'File not found: (%filename%)' );
  Log.Register( EUnrecognizedXMLTag, 'Skipping unrecognized XML tag ((%xmltag%))');
  Log.Register( EMissingPlatforms, 'There are no platforms defined in the xml file.');
  Log.Register( EMissingTypes, 'There are no types defined in type section.');
  Log.Register( EMissingNode, 'A node of type "(%nodetype%)" was expected in "(%in%)".');
  Log.Register( EExpectedNode, 'Expected node type "(%nodetype%)" but got "(%unknowntype%)" in "(%parenttype%)."');
  Log.Register( EMissingAttribute, 'Expected attribtue "(%attribute%)" in "(%parentnode%)."');
  Log.Register( EUnhandledAttribute, 'Attribtue "(%attribute%)" found in "(%parentnode%)" but was not expected.');
  Log.Register( EPlatformNotSupported, 'Platform not supported "(%Platform%)."');
  Log.Register( ESkippedNode, 'Node of type "(%nodetype%)" skipped because "(%because%)".');
  Log.Register( EMacroChanged,'The macro "(%macro%)" has changed since darkVulkanGen was written, do not know how to process this.');
  Log.Register( EUnknownXMLFormat, 'Unknown tag or un-expected data. The format of the xml file may have changed since darkVulkanGen was written.' );
  Log.Register( EInvalidMacroParameters, 'Invalid parameters supplied for macro "(%macro&)" = "(%parameters%)"');
end.
