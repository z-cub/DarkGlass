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
unit darkvulkangen.ast.functionheader.standard;

interface
uses
  darkIO.streams,
  darkvulkangen.ast,
  darkvulkangen.ast.node.standard;

type
  TdvFunctionHeader = class( TdvASTNode, IdvFunctionHeader )
  private
    fisVariable: boolean;
    fIsFunction: boolean;
    fName: string;
    fReturnType: string;
  private //- IdvFunctionHeader -//
    function getReturnType: string;
    procedure setReturnType( value: string );
    function getName: string;
    procedure setName( value: string );
    function getIsVariable: boolean;
    procedure setIsVariable( value: boolean );
  protected
    function WriteToStream( Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32 ): boolean; override;
  public
    constructor Create( name: string ); reintroduce;
  end;

implementation
uses
  sysutils;

{ TdvFunctionHeader }

constructor TdvFunctionHeader.Create(name: string);
begin
  inherited Create;
  fisVariable := False;
  setReturnType('');
  setName(Name);
end;

function TdvFunctionHeader.getIsVariable: boolean;
begin
  Result := fIsVariable;
end;

function TdvFunctionHeader.getName: string;
begin
  Result := fName;
end;

function TdvFunctionHeader.getReturnType: string;
begin
  if fIsFunction then begin
    Result := fReturnType;
  end else begin
    Result := '';
  end;
end;

procedure TdvFunctionHeader.setIsVariable(value: boolean);
begin
  fIsVariable := Value;
end;

procedure TdvFunctionHeader.setName(value: string);
begin
  fName := Value;
end;

procedure TdvFunctionHeader.setReturnType(value: string);
begin
  fIsFunction := True;
  if Uppercase(Trim(Value))='VOID' then begin
    fIsFunction := False;
  end;
  if Value='' then begin
    fIsFunction := False;
  end;
  fReturnType := Value;
end;

function TdvFunctionHeader.WriteToStream(Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32): boolean;
var
  idx: uint32;
begin
  Result := False;
  // Write the before node
  if not WriteBeforeNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  //- Write the keyword.
  if fIsFunction then begin
    if fIsVariable then begin
      Stream.WriteString(getIndentation(Indentation)+fName+': function ',UnicodeFormat);
    end else begin
      Stream.WriteString(getIndentation(Indentation)+'function '+fName,UnicodeFormat);
    end;
  end else begin
    if fIsVariable then begin
      Stream.WriteString(getIndentation(Indentation)+fName+': procedure ',UnicodeFormat);
    end else begin
      Stream.WriteString(getIndentation(Indentation)+'procedure '+fName,UnicodeFormat);
    end;
  end;
  //- Write the parameters ( children ).
  if getChildCount>0 then begin
    Stream.WriteString('( ',UnicodeFormat);
    for idx := 0 to pred(getChildCount) do begin
      if not getChild(idx).WriteToStream(Stream, UnicodeFormat, 0 ) then begin
        exit;
      end;
      if idx<pred(getChildCount) then begin
        Stream.WriteString('; ',UnicodeFormat);
      end;
    end;
    Stream.WriteString(' )',UnicodeFormat);
  end;
  //- Write the keyword.
  if fIsFunction then begin
    Stream.WriteString(': '+fReturnType,UnicodeFormat);
  end;
  //- Write the semi and after node
  Stream.WriteString(';'+LineBreaks,UnicodeFormat);
  if not WriteAfterNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  Result := True;
end;

end.

