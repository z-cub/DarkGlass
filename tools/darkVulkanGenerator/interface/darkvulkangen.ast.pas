//------------------------------------------------------------------------------
// This file is part of the DarkGlass game engine project.
// More information can be found here: http://chapmanworld.com/darkglass
//
// DarkGlass is licensed under the MIT License:
//
// Copyright 2018 Craig Chapman
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the “Software”),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.
//------------------------------------------------------------------------------
unit darkvulkangen.ast;

interface
uses
  darkIO.streams;

type
  ///  <summary>
  ///    Implementations represent a node in an abstract syntax tree, where
  ///    the tree abstracts one or more Delphi units which form the darkVulkan
  ///    header.
  ///  </summary>
  IdvASTNode = interface
    ['{DAAD3BC3-F117-4311-B116-CD7DEE2A3F11}']

    ///  <summary>
    ///    A node which comes before this one in the source code, but is not
    ///    suitable to be a child node.
    ///  </summary>
    function getBeforeNode: IdvASTNode;

    ///  <summary>
    ///    A node which comes immediately after this one in the source code,
    ///    but is not suitable to be a child node.
    ///  </summary>
    function getAfterNode: IdvASTNode;

    ///  <summary>
    ///    Gets the number of line breaks to be inserted at the end of the
    ///    node when source code is generated. Defaults to 1 for most AST nodes.
    ///  </summary>
    function getLineBreaks: uint32;

    ///  <summary>
    ///    Sets the number of line breaks to be inserted at the end of the
    ///    node when source code is generated. Defaults to 1 for most AST nodes.
    ///  </summary>
    procedure setLineBreaks( value: uint32 );

    ///  <summary>
    ///    Returns the number of nodes which are children to this one.
    ///  </summary>
    function getChildCount: uint32;

    ///  <summary>
    ///    Returns a child node of this one as specified by index.
    ///  </summary>
    function getChild( idx: uint32 ): IdvASTNode;

    ///  <summary>
    ///    Inserts a child node into this one.
    ///  </summary>
    function InsertChild( node: IdvASTNode ): IdvASTNode;

    ///  <summary>
    ///    Instructs this node to write it's self, and therefore it's
    ///    children to the specified unicode stream.
    ///  </summary>
    function WriteToStream( Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32 ): boolean;

    //- Pascal Only, properties -//
    property LineBreaks: uint32 read getLineBreaks write setLineBreaks;
    property ChildCount: uint32 read getChildCount;
    property Children[ idx: uint32 ]: IdvASTNode read getChild;
    property BeforeNode: IdvASTNode read getBeforeNode;
    property AfterNode: IdvASTNode read getAfterNode;
  end;

  ///  <summary>
  ///    Represents a list of labels (such as a uses list item)
  ///  </summary>
  IdvLabel = interface( IdvASTNode )
    ['{D7E46465-FDAE-4AAD-ADD3-97E50A8B3960}']
    ///  <summary>
    ///    Returns the name of the label.
    ///  </summary>
    function getLabelName: string;
    ///  <summary>
    ///    Sets the name of the label.
    ///  </summary>
    procedure setLabelName( value: string );

    ///  <summary>
    ///    Used at code-generation time to place a delimiting character
    ///    on list labels.
    ///  </summary>
    function getDelimiter: string;

    ///  <summary>
    ///    Used at code-generation time to place a delimiting character
    ///    on list labels.
    ///  </summary>
    procedure setDelimiter( value: string );

    //- Pascal Only, Properties
    property Name: string read getLabelName write setLabelName;
    property Delimiter: string read getDelimiter write setDelimiter;
  end;

  ///  <summary>
  ///    Represents a list of referenced units.
  ///  </summary>
  IdvUsesList = interface( IdvASTNode )
    ['{E14E7D6C-D5F5-4093-B2AE-351C96E5C53E}']
  end;

  ///  Defines a constant with both name and value parts.
  IdvConstant = interface( IdvASTNode )
    ['{5BBE802D-D0D7-4CEE-9217-1EBBAD45773B}']
    function getName: string;
    procedure setName( value: string );
    function getValue: string;
    procedure setValue( value: string );

    //- Pascal Only, Properties -//
    property Name: string read getName write setName;
    property Value: string read getValue write setValue;
  end;

  /// Defines a section of constants, where each child is an IdvConstant.
  IdvConstants = interface( IdvASTNode )
    ['{C56105C0-9AE0-4E45-A69C-E7E04285E837}']
  end;

  TdvTypeKind = (
    tkVoid,         //- Generates nothing
    tkUserDefined,  //- A user defined type simply uses it's name as the type name (and therefore can be the child of an alias).
    tkEnum,         //- The child nodes are all constants, they provide the enum values.
    tkPointer,      //- A void pointer type.
    tkTypedPointer, //- A typed pointer, (target type will be a child node in the AST)
    tkAlias,        //- Alias to another type, (target type will be child node in AST)
    tkuint8,        //- 8-bit unsigned integer
    tkint8,         //- 8-bit signed integer
    tkuint16,       //- 16-bit unsigned integer
    tkint16,        //- 16-bit signed integer
    tkuint32,       //- 32-bit unsigned integer
    tkint32,        //- 32-bit signed integer
    tkuint64,       //- 64-bit unsigned integer
    tkint64,        //- 64-bit signed integer
    tkNativeUInt,   //- Platform determined unsigned integer.
    tkNativeInt,    //- Platform determined signed integer.
    tkSingle,       //- Single precision
    tkDouble,       //- Double precision
    tkAnsiChar,     //- Ansi character.
    tkChar,         //- UTF-16 charager.
    tkString,       //- Delphi string.
    tkAnsiString,   //- Ansi string
    tkRecord,       //- Members will be children in the AST
    tkFuncPointer   //- Child is a function header, but will be rendered as function pointer.
  );

  ///  Represents a type definition.
  IdvTypeDef = interface( IdvASTNode )
    ['{AF029232-CFAE-4C8E-BD41-669C1D3D9CCD}']
    // returns type as a string, should only be used by AST generator.
    function getTypeString(Indentation: uint32): string;

    function getName: string;
    procedure setName( value: string );
    function getTypeKind: TdvTypeKind;
    procedure setTypeKind( value: TdvTypeKind );

    //- Pascal Only, Properties -//
    property Name: string read getName write setName;
    property TypeKind: TdvTypeKind read getTypeKind write setTypeKind;
  end;

  /// Defines a section of type definitions, where each child is an IdvTypeDef
  /// or descendent;
  IdvTypeDefs = interface( IdvASTNode )
    ['{3BA9D84D-00EF-4D07-9DBC-C8F5294E3DEF}']
  end;

  ///  <summary>
  ///    Type representing the kinds of unit sections which may be written into
  ///    our unit.
  ///  </summary>
  TASTUnitSectionKind = ( usInterface, usImplementation, usInitialization, usFinalization );

  ///  <summary>
  ///    Represents a section of a unit (i.e. interface, implementation, initialization, finalization)
  ///  </summary>
  IdvASTUnitSection = interface( IdvASTNode )
    ['{C422F27B-072E-483F-A282-C1889FA39BD6}']
    function getKind: TASTUnitSectionKind;
    function getUsesList: IdvUsesList;

    //- If the last added child was an IdvConstants, it will be returned,
    //- otherwise a new IdvConstants is created and returned.
    function getConstants: IdvConstants;

    //- If the last added child was an IdvTypeDefs, it will be returned,
    //- otherwise a new IdvTypeDefs is created and returned.
    function getTypes: IdvTypeDefs;

    //- Pascal Only, properties -//
    property Kind: TASTUnitSectionKind read getKind;
    property UsesList: IdvUsesList read getUsesList;
    property Constants: IdvConstants read getConstants;
    property Types: IdvTypeDefs read getTypes;
  end;

  ///  <summary>
  ///    Represents a source-code comment.
  ///  </summary>
  IdvASTComment = interface( IdvASTNode )
    ['{1C0C892D-9734-4EB7-A2EE-35FF4E13F1AC}']
    function getCommentString: string;
    procedure setCommentString( value: string );
    //- Pascal Only, properties
    property CommentString: string read getCommentString write setCommentString;
  end;

  ///  <summary>
  ///    Represents a source code unit in the output.
  ///  </summary>
  IdvASTUnit = interface( IdvASTNode )
    ['{9BC30E93-FDC7-4A4F-B96C-41F3384AB5C9}']
    function getName: string;
    procedure setName( value: string );
    function getInterfaceSection: IdvASTUnitSection;
    function getImplementationSection: IdvASTUnitSection;
    function findEnumByName( name: string ): IdvTypeDef;

    //- Pascal Only, properties -//
    property Name: string read getName write setName;
    property InterfaceSection: IdvASTUnitSection read getInterfaceSection;
    property ImplementationSection: IdvASTUnitSection read getImplementationSection;
  end;

  ///  <summary>
  ///    Represents the root node of the abstract syntax tree.
  ///  </summary>
  IdvASTRootNode = interface( IdvASTNode )
    ['{3CA4EDFA-6DAF-482C-A6E9-BA66065CAB94}']
    function WriteToDirectory( Directory: string; Indentation: uint32 ): boolean;
  end;

  ///  <summary>
  ///    Represents a conditional define, where the Defined property returns
  ///    the node that will be output for the condition being met, and Undefined
  ///    returns the node that will be output for a condition unmet.
  ///  </summary>
  IdvIfDef = interface( IdvASTNode )
    ['{D911B26D-BF4B-4814-A1E8-94B6CCCF4191}']
    function getDefineName: string;
    procedure setDefineName( value: string );
    function getDefined: IdvASTNode;
    function getUndefined: IdvASTNode;
    function getOnOneLine: boolean;
    procedure setOnOneLine( value: boolean );
    //- Pascal Only, properties
    property OnOneLine: boolean read getOnOneLine write setOnOneLine;
    property DefineName: string read getDefineName write setDefineName;
    property Defined: IdvASTNode read getDefined;
    property Undefined: IdvASTNode read getUndefined;
  end;

  ///  <summary>
  ///    Same as IfDef but for not defined.
  ///  </summary>
  IdvIfNDef = interface( IdvIfDef )
    ['{2119E91D-98BF-4B05-89C3-BC334A21ED1A}']
  end;

  ///  <sumamry>
  ///    Represents a define declaration pre-processor directive.
  ///  </summary>
  IdvDefine = interface( IdvASTNode )
    ['{F052AB0C-81F4-4EA6-AEB2-DB1F080D0D1C}']
    function getDefineName: string;
    procedure setDefineName( value: string );
    //- Pascal Only, properties
    property DefineName: string read getDefineName write setDefineName;
  end;

  ///  <summary>
  ///    Represents a symbol which has a data-type.
  ///    The typed symbol does not concern it's self with the declarative
  ///    reserved word, this is done by the owning object.
  ///  </summary>
  IdvTypedSymbol = interface( IdvASTNode )
    ['{BCB0B42B-7D87-4D59-AE33-4CB2C0D0FF1D}']
    function getName: string;
    procedure setName( value: string );
    function getType: string;
    procedure setType( value: string );
    function AsString: string;
    //- Pascal Only, properties -//
    property Name: string read getName write setName;
    property TypeKind: string read getType write setType;
  end;

  ///  <summary>
  ///    Used to provide the protection operator for funciton parameters.
  ///  </summary>
  TParameterProtection = (
    ppNone,
    ppOut,
    ppIn, // const
    ppVar
  );

  ///  <summary>
  ///    Represents a parameter in a function parameter list.
  ///  </summary>
  IdvParameter = interface( IdvASTNode )
    ['{038AF6F2-2952-4837-BB72-B1C4D5BDA2DE}']
    function getTypedSymbol: IdvTypedSymbol;
    function getProtection: TParameterProtection;
    procedure setProtection( value: TParameterProtection );
    function AsString: string;

    //- Pascal Only, Properties -//
    property Protection: TParameterProtection read getProtection write setProtection;
    property TypedSymbol: IdvTypedSymbol read getTypedSymbol;
  end;

  ///  <summary>
  ///    Generates a function header, with IdvParameter children.
  ///    //note: if the return type is set to 'void', as is the default, the
  ///    function header will use the 'procedure' reserved word, else it'll
  ///    use 'function'
  ///  </summary>
  IdvFunctionHeader = interface( IdvASTNode )
  ['{36EADF3C-6520-485D-9135-643F4EEAB837}']
    function getReturnType: string;
    procedure setReturnType( value: string );
    function getName: string;
    procedure setName( value: string );

    //- Pascal Only, properties.
    property ReturnType: string read getReturnType write setReturnType;
  end;

  ///  <summary>
  ///    Generates a compound statement (content surrounded by begin..end;
  ///  </summary>
  IdvCompoundStatement = interface( IdvASTNode )
    ['{4DC7E086-780C-4048-B1DA-4DC1707B57E6}']
    function getContent: string;
    procedure setContent( value: string );

    //- Pascal Only, properties -//
    property Content: string read getContent write setContent;
  end;

  ///  <summary>
  ///    Represents a complete function declaration including the function
  ///    var section and body.
  ///  </summary>
  IdvFunction = interface( IdvASTNode )
    ['{EBD6BD00-BCCD-4137-A6D1-E8B341A4BC84}']
    function getHeader: IdvFunctionHeader;
    function getBodySection: IdvCompoundStatement;

    //- Pascal Only, properties -//
    property Header: IdvFunctionHeader read getHeader;
    property Body: IdvCompoundStatement read getBodySection;
  end;


//------------------------------------------------------------------------------
// Factories.
//------------------------------------------------------------------------------
type
  TdvASTRootNode = class
    class function Create: IdvASTRootNode;
  end;

  TdvASTUnit = class
    class function Create( aName: string ): IdvASTUnit;
  end;

  TdvASTComment = class
    class function Create( CommentText: string ): IdvASTComment;
  end;

  TdvASTUnitSection = class
    class function Create( SectionKind: TASTUnitSectionKind ): IdvASTNode;
  end;

  TdvIfDef = class
    class function Create( DefineName: string ): IdvIfDef;
  end;

  TdvIfNDef = class
    class function Create( DefineName: string ): IdvIfNDef;
  end;

  TdvDefine = class
    class function Create( DefineName: string ): IdvDefine;
  end;

  TdvLabel = class
    class function Create( LabelName: string ): IdvLabel;
  end;

  TdvUsesList = class
    class function Create: IdvUsesList;
  end;

  TdvFunction = class
    class function Create( name: string ): IdvFunction;
  end;

  TdvCompoundStatement = class
    class function Create: IdvCompoundStatement;
  end;

  TdvFunctionHeader = class
    class function Create( name: string ): IdvFunctionHeader;
  end;

  TdvParameter = class
    class function Create( Name: string; DataType: string; Protection: TParameterProtection = TParameterProtection.ppNone ): IdvParameter;
  end;

  TdvTypedSymbol = class
    class function Create( Name: string; DataType: string ): IdvTypedSymbol;
  end;

  TdvConstant = class
    class function Create( Name: string; Value: string ): IdvConstant;
  end;

  TdvConstants = class
    class function Create: IdvConstants;
  end;

  TdvTypeDefs = class
    class function Create: IdvTypeDefs;
  end;

  TdvTypeDef = class
    class function Create( Name: string; Kind: TdvTypeKind ): IdvTypeDef;
  end;



implementation
uses
  darkvulkangen.ast.node.standard,
  darkvulkangen.ast.rootnode.standard,
  darkvulkangen.ast.unitnode.standard,
  darkvulkangen.ast.comment.standard,
  darkvulkangen.ast.unitsection.standard,
  darkvulkangen.ast.ifdef.standard,
  darkvulkangen.ast.ifndef.standard,
  darkvulkangen.ast.astlabel.standard,
  darkvulkangen.ast.useslist.standard,
  darkvulkangen.ast.define.standard,
  darkvulkangen.ast._function.standard,
  darkvulkangen.ast.compoundstatement.standard,
  darkvulkangen.ast.functionheader.standard,
  darkvulkangen.ast.parameter.standard,
  darkvulkangen.ast.typedsymbol.standard,
  darkvulkangen.ast.constant.standard,
  darkvulkangen.ast.constants.standard,
  darkvulkangen.ast.typedefs.standard,
  darkvulkangen.ast.typedef.standard;


{ TdvASTRoot }

class function TdvASTRootNode.Create: IdvASTRootNode;
begin
  Result := darkvulkangen.ast.rootnode.standard.TdvASTRootNode.Create;
end;

{ TdvASTUnit }

class function TdvASTUnit.Create(aName: string): IdvASTUnit;
begin
  Result := darkvulkangen.ast.unitnode.standard.TdvASTUnit.Create(aName);
end;

{ TdvASTComment }

class function TdvASTComment.Create(CommentText: string): IdvASTComment;
begin
  Result := darkvulkangen.ast.comment.standard.TdvASTComment.Create(CommentText);
end;

{ TdvASTUnitSection }

class function TdvASTUnitSection.Create( SectionKind: TASTUnitSectionKind ): IdvASTNode;
begin
  Result := darkvulkangen.ast.unitsection.standard.TdvASTUnitSection.Create( SectionKind );
end;

{ TdvDefine }

class function TdvDefine.Create(DefineName: string): IdvDefine;
begin
  Result := darkvulkangen.ast.define.standard.TdvDefine.Create(DefineName);
end;

{ TdvIfDef }

class function TdvIfDef.Create(DefineName: string): IdvIfDef;
begin
  Result := darkvulkangen.ast.ifdef.standard.TdvIfDef.Create(DefineName);
end;

{ TdvIfNDef }

class function TdvIfNDef.Create(DefineName: string): IdvIfNDef;
begin
  Result := darkvulkangen.ast.ifndef.standard.TdvIfNDef.Create(DefineName);
end;

{ TdvLabel }

class function TdvLabel.Create(LabelName: string): IdvLabel;
begin
  Result := darkvulkangen.ast.astlabel.standard.TdvLabel.Create(LabelName);
end;

{ TdvUsesList }

class function TdvUsesList.Create: IdvUsesList;
begin
  Result := darkvulkangen.ast.useslist.standard.TdvUsesList.Create;
end;


{ TdvFunction }

class function TdvFunction.Create( name: string ): IdvFunction;
begin
  Result := darkvulkangen.ast._function.standard.TdvFunction.Create( name );
end;

{ TdvCompoundStatement }

class function TdvCompoundStatement.Create: IdvCompoundStatement;
begin
  Result := darkvulkangen.ast.compoundstatement.standard.TdvCompoundStatement.Create;
end;

{ TdvFunctionHeader }

class function TdvFunctionHeader.Create( name: string ): IdvFunctionHeader;
begin
  Result := darkvulkangen.ast.functionheader.standard.TdvFunctionHeader.Create( name );
end;

{ TdvParameter }

class function TdvParameter.Create( Name: string; DataType: string; Protection: TParameterProtection ): IdvParameter;
begin
  Result := darkvulkangen.ast.parameter.standard.TdvParameter.Create( Name, DataType, Protection );
end;

{ TdvTypedSymbol }

class function TdvTypedSymbol.Create( Name: string; DataType: string ): IdvTypedSymbol;
begin
  Result := darkvulkangen.ast.typedsymbol.standard.TdvTypedSymbol.Create(Name,DataType);
end;

{ TdvConstant }

class function TdvConstant.Create(Name, Value: string): IdvConstant;
begin
  Result := darkvulkangen.ast.constant.standard.TdvConstant.Create(Name,Value);
end;

{ TdvConstants }

class function TdvConstants.Create: IdvConstants;
begin
  Result := darkvulkangen.ast.constants.standard.TdvConstants.Create;
end;

{ TdvTypeDefs }

class function TdvTypeDefs.Create: IdvTypeDefs;
begin
  Result := darkvulkangen.ast.typedefs.standard.TdvTypeDefs.Create;
end;

{ TdvTypeDef }

class function TdvTypeDef.Create(Name: string; Kind: TdvTypeKind): IdvTypeDef;
begin
  Result := darkvulkangen.ast.typedef.standard.TdvTypeDef.Create( Name, Kind );
end;

end.
