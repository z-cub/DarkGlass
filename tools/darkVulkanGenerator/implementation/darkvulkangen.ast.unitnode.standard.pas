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
unit darkvulkangen.ast.unitnode.standard;

interface
uses
  darkIO.streams,
  darkvulkangen.ast,
  darkvulkangen.ast.node.standard;

type
  TdvASTUnit = class( TdvASTNode, IdvASTUnit )
  private
    fUnitName: string;
    fInterfaceSection: IdvASTUnitSection;
    fImplementationSection: IdvASTUnitSection;
  private
    function RecursiveSearchEnum(StartNode: IdvASTNode; name: string): IdvTypeDef;
    function RecursiveSearchType(StartNode: IdvASTNode; name: string): IdvTypeDef;
    function RecursiveSearchFunctionHeader(StartNode: IdvASTNode; name: string): IdvFunctionHeader;
  private //- IdvASTUnit
    function getName: string;
    procedure setName( value: string );
    function getInterfaceSection: IdvASTUnitSection;
    function getImplementationSection: IdvASTUnitSection;
    function findEnumByName( name: string ): IdvTypeDef;
    function findTypeByName( name: string ): IdvTypeDef;
    function findFunctionHeaderByName( name: string ): IdvFunctionHeader;
  protected
    function WriteToStream( Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32 ): boolean; override;
  public
    constructor Create( unitName: string ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  SysUtils;

{ TdvASTUnit }

constructor TdvASTUnit.Create(unitName: string);
begin
  inherited Create;
  fUnitName := unitName;
  fInterfaceSection := InsertChild(TdvASTUnitSection.Create(TASTUnitSectionKind.usInterface)) as IdvASTUnitSection;
  fImplementationSection := InsertChild(TdvASTUnitSection.Create(TASTUnitSectionKind.usImplementation)) as IdvASTUnitSection;
  SetLineBreaks(2);
end;

destructor TdvASTUnit.Destroy;
begin
  fInterfaceSection := nil;
  fImplementationSection := nil;
  inherited Destroy;
end;

function TdvASTUnit.RecursiveSearchEnum( StartNode: IdvASTNode; name: string ): IdvTypeDef;
var
  idx: nativeuint;
  ChildNode: IdvASTNode;
begin
  Result := nil;
  //- First chec start node.
  if Supports(StartNode,IdvTypeDef) then begin
    if (StartNode as IdvTypeDef).TypeKind = TdvTypeKind.tkEnum then begin
      if (StartNode as IdvTypeDef).Name=Name then begin
        Result := StartNode as IdvTypeDef;
        exit;
      end;
    end;
  end;
  //- Not it? Okay, lets repeat the search on all child nodes.
  if StartNode.ChildCount=0 then begin
    exit;
  end;
  for idx := 0 to pred(StartNode.ChildCount) do begin
    ChildNode := StartNode.Children[idx];
    Result := RecursiveSearchEnum( ChildNode, name );
    if assigned(Result) then begin
      exit;
    end;
  end;
end;

function TdvASTUnit.RecursiveSearchFunctionHeader(StartNode: IdvASTNode; name: string): IdvFunctionHeader;
var
  idx: nativeuint;
  ChildNode: IdvASTNode;
begin
  Result := nil;
  //- First chec start node.
  if Supports(StartNode,IdvFunctionHeader) then begin
    if (StartNode as IdvFunctionHeader).Name=Name then begin
      Result := StartNode as IdvFunctionHeader;
      exit;
    end;
  end;
  //- Not it? Okay, lets repeat the search on all child nodes.
  if StartNode.ChildCount=0 then begin
    exit;
  end;
  for idx := 0 to pred(StartNode.ChildCount) do begin
    ChildNode := StartNode.Children[idx];
    Result := RecursiveSearchFunctionHeader( ChildNode, name );
    if assigned(Result) then begin
      exit;
    end;
  end;
end;


function TdvASTUnit.RecursiveSearchType(StartNode: IdvASTNode; name: string): IdvTypeDef;
var
  idx: nativeuint;
  ChildNode: IdvASTNode;
begin
  Result := nil;
  //- First chec start node.
  if Supports(StartNode,IdvTypeDef) then begin
    if (StartNode as IdvTypeDef).Name=Name then begin
      Result := StartNode as IdvTypeDef;
      exit;
    end;
  end;
  //- Not it? Okay, lets repeat the search on all child nodes.
  if StartNode.ChildCount=0 then begin
    exit;
  end;
  for idx := 0 to pred(StartNode.ChildCount) do begin
    ChildNode := StartNode.Children[idx];
    Result := RecursiveSearchType( ChildNode, name );
    if assigned(Result) then begin
      exit;
    end;
  end;
end;

function TdvASTUnit.findEnumByName(name: string): IdvTypeDef;
begin
  Result := RecursiveSearchEnum( Self, Name );
end;

function TdvASTUnit.findFunctionHeaderByName(name: string): IdvFunctionHeader;
begin
  Result := RecursiveSearchFunctionHeader( Self, Name );
end;

function TdvASTUnit.findTypeByName(name: string): IdvTypeDef;
begin
  Result := RecursiveSearchType( Self, Name );
end;

function TdvASTUnit.getImplementationSection: IdvASTUnitSection;
begin
  Result := fImplementationSection;
end;

function TdvASTUnit.getInterfaceSection: IdvASTUnitSection;
begin
  Result := fInterfaceSection;
end;

function TdvASTUnit.getName: string;
begin
  Result := fUnitName;
end;

procedure TdvASTUnit.setName(value: string);
begin
  fUnitName := Value;
end;

function TdvASTUnit.WriteToStream(Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32): boolean;
var
  idx: nativeuint;
begin
  Result := False;
  if not WriteBeforeNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  Stream.WriteString(getIndentation(Indentation)+'unit '+fUnitName+';'+LineBreaks,UnicodeFormat);
  if getChildCount=0 then begin
    Result := True;
    exit;
  end;
  for idx := 0 to pred(getChildCount) do begin
    if not getChild(idx).WriteToStream(Stream,UnicodeFormat,Indentation) then begin
      exit;
    end;
  end;
  Stream.WriteString(getIndentation(Indentation)+'end.',UnicodeFormat);
  if not WriteAfterNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  Result := True;
end;

end.
