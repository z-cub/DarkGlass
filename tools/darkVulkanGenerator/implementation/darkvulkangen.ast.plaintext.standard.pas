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
unit darkvulkangen.ast.plaintext.standard;

interface
uses
  darkIO.streams,
  darkvulkangen.ast,
  darkvulkangen.ast.node.standard;

type
  TdvASTPainText = class( TdvASTNode, IdvASTPlainText )
  private
    fTextString: string;
  private //- IdvASTPlainText
    function getText: string;
    procedure setText( value: string );
  protected
    function InsertChild(node: IdvASTNode): IdvASTNode; override;
    function WriteToStream( Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32 ): boolean; override;
  public
    constructor Create( Text: string ); reintroduce;
  end;

implementation
uses
  darkLog,
  sysutils;

{ TdvASTPainText }

constructor TdvASTPainText.Create(Text: string);
begin
  inherited Create;
  SetText(Text);
  SetLineBreaks(2);
end;

function TdvASTPainText.getText: string;
begin
  Result := fTextString;
end;

function TdvASTPainText.InsertChild(node: IdvASTNode): IdvASTNode;
begin
  Result := nil;
  Log.Insert(ENoChildren,TLogSeverity.lsError);
end;

procedure TdvASTPainText.setText(value: string);
begin
  fTextString := value;
end;

function TdvASTPainText.WriteToStream(Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32): boolean;
begin
  Result := False;
  if not WriteBeforeNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  if Trim(fTextString)<>'' then begin
    Stream.WriteString(getIndentation(Indentation)+fTextString,UnicodeFormat);
    Stream.WriteString(LineBreaks,UnicodeFormat);
  end;
  if not WriteAfterNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  Result := True;
end;

end.

