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
unit darkvulkangen.ast._function.standard;

interface
uses
  darkIO.streams,
  darkvulkangen.ast,
  darkvulkangen.ast.node.standard;

type
  TdvFunction = class( TdvASTNode, IdvFunction )
  private
    fHeader: IdvFunctionHeader;
    fBody: IdvCompoundStatement;
  private
    function getBodySection: IdvCompoundStatement;
    function getHeader: IdvFunctionHeader; //- IdvFuntion -//
  protected
    function InsertChild( node: IdvASTNode ): IdvASTNode; override;
  public
    constructor Create( name: string ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  darkLog,
  darkvulkangen.ast.functionheader.standard,
  darkvulkangen.ast.compoundstatement.standard;

{ TdvFunction }

constructor TdvFunction.Create( name: string );
begin
  inherited Create;
  fHeader := inherited InsertChild( TdvFunctionHeader.Create( name ) ) as IdvFunctionHeader;
  fBody := inherited InsertChild( TdvCompoundStatement.Create ) as IdvCompoundStatement;
  fBody.LineBreaks := 2;
end;

destructor TdvFunction.Destroy;
begin
  fBody := nil;
  fHeader := nil;
  inherited Destroy;
end;

function TdvFunction.getBodySection: IdvCompoundStatement;
begin
  Result := fBody;
end;

function TdvFunction.getHeader: IdvFunctionHeader;
begin
  Result := fHeader;
end;

function TdvFunction.InsertChild(node: IdvASTNode): IdvASTNode;
begin
  Result := nil;
  Log.Insert(ENoChildren,TLogSeverity.lsError);
end;


end.

