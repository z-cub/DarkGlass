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
unit darkvulkangen.ast.typedsymbol.standard;

interface
uses
  darkIO.streams,
  darkvulkangen.ast,
  darkvulkangen.ast.node.standard;

type
  TdvTypedSymbol = class( TdvASTNode, IdvTypedSymbol )
  private
    fName: string;
    fType: string;
  private //- IdvTypedSymbol -//
    function getName: string;
    procedure setName( value: string );
    function getType: string;
    procedure setType( value: string );
    function AsString: string;
  protected
    function InsertChild( node: IdvASTNode ): IdvASTNode; override;
    function WriteToStream( Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32 ): boolean; override;
  public
    constructor Create( Name: string; DataType: string ); reintroduce;
  end;

implementation
uses
  sysutils,
  darkLog;

{ TdvTypedSymbol }

function TdvTypedSymbol.AsString: string;
begin
  Result := getName+': '+getType;
end;

constructor TdvTypedSymbol.Create( Name, DataType: string);
begin
  inherited Create;
  setName(Name);
  setType(DataType);
end;

function TdvTypedSymbol.getName: string;
begin
  Result := fName;
end;

function TdvTypedSymbol.getType: string;
begin
  Result := fType;
end;

function TdvTypedSymbol.InsertChild(node: IdvASTNode): IdvASTNode;
begin
  Result := nil;
  Log.Insert(ENoChildren,TLogSeverity.lsError);
end;

procedure TdvTypedSymbol.setName(value: string);
begin
  fName := TestReservedWord(Value);
end;

procedure TdvTypedSymbol.setType(value: string);
begin
  fType := Value;
end;

function TdvTypedSymbol.WriteToStream(Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32): boolean;
begin
  Stream.WriteString(AsString,UnicodeFormat);
  Result := True;
end;

end.
