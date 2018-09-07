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
unit darkvulkangen.ast.functionheaderalias.standard;

interface
uses
  darkIO.streams,
  darkvulkangen.ast,
  darkvulkangen.ast.node.standard;

type
  TdvFunctionHeaderAlias = class( TdvASTNode, IdvFunctionHeaderAlias )
  private
    fName: string;
    fTarget: IdvFunctionHeader;
  private //- IdvFunctionHeaderAlias -//
    function getName: string;
    procedure setName( value: string );
    function getTargetNode: IdvFunctionHeader;
    procedure setTargetNode( value: IdvFunctionHeader );
  protected
    function WriteToStream( Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32 ): boolean; override;
  public
    constructor Create( Name: string; Target: IdvFunctionHeader ); reintroduce;
  end;

implementation


{ TdvFunctionHeaderAlias }

constructor TdvFunctionHeaderAlias.Create(Name: string; Target: IdvFunctionHeader);
begin
  inherited Create;
  setName(Name);
  setTargetNode(Target);
end;

function TdvFunctionHeaderAlias.getName: string;
begin
  Result := fName;
end;

function TdvFunctionHeaderAlias.getTargetNode: IdvFunctionHeader;
begin
  Result := fTarget;
end;

procedure TdvFunctionHeaderAlias.setName(value: string);
begin
  fName := Value;
end;

procedure TdvFunctionHeaderAlias.setTargetNode(value: IdvFunctionHeader);
begin
  fTarget := Value;
end;

function TdvFunctionHeaderAlias.WriteToStream(Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32): boolean;
var
  TempName: string;
begin
  TempName := getTargetNode.getName;
  getTargetNode.setName(fName);
  Result := getTargetNode.WriteToStream(Stream,UnicodeFormat,Indentation);
  getTargetNode.setName(TempName);
end;

end.

