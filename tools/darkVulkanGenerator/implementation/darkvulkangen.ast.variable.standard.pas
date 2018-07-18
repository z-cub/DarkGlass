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
unit darkvulkangen.ast.variable.standard;

interface
uses
  darkIO.streams,
  darkLog,
  darkvulkangen.ast,
  darkvulkangen.ast.node.standard;

type
  TdvVariable = class( TdvASTNode, IdvVariable )
  private
    fName: string;
    fTypeKind: string;
    fInitialize: string;
  private //- IdvConstant -//
    function getName: string;
    procedure setName( value: string );
    function getTypeKind: string;
    procedure setTypeKind( value: string );
  protected
    function InsertChild( node: IdvASTNode ): IdvASTNode; override;
    function WriteToStream( Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32 ): boolean; override;
  public
    constructor Create( Name: string; TypeKind: string; Initialize: string = '' ); reintroduce;
  end;

implementation
uses
  sysutils;

{ TdvVariable }

constructor TdvVariable.Create(Name, TypeKind: string; Initialize: string = '');
begin
  inherited Create;
  SetName(Name);
  SetTypeKind(TypeKind);
  fInitialize := Initialize;
end;

function TdvVariable.getName: string;
begin
  Result := fName;
end;

function TdvVariable.getTypeKind: string;
begin
  Result := fTypeKind;
end;

function TdvVariable.InsertChild(node: IdvASTNode): IdvASTNode;
begin
  Result := nil;
  Log.Insert(ENoChildren,TLogSeverity.lsError);
end;

procedure TdvVariable.setName(value: string);
begin
  fName := value;
end;

procedure TdvVariable.setTypeKind(value: string);
begin
  fTypeKind := Value;
end;

function TdvVariable.WriteToStream(Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32): boolean;
var
  InitStr: string;
begin
  Result := False;
  if not WriteBeforeNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  if fInitialize<>'' then begin
    InitStr := ' = '+fInitialize;
  end else begin
    InitStr := '';
  end;
  Stream.WriteString(getIndentation(Indentation)+fName+': '+fTypeKind+InitStr+';'+sLineBreak,UnicodeFormat);
  if not WriteAfterNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  Result := True;
end;

end.

