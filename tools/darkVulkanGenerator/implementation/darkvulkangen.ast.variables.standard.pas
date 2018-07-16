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
unit darkvulkangen.ast.variables.standard;

interface
uses
  darkIO.streams,
  darkLog,
  darkvulkangen.ast,
  darkvulkangen.ast.node.standard;

type
  TdvVariables = class( TdvASTNode, IdvVariables )
  protected
    function WriteToStream( Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32 ): boolean; override;
  end;

implementation

{ TdvVariables }

function TdvVariables.WriteToStream(Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32): boolean;
var
  idx: uint32;
begin
  Result := False;
  if not WriteBeforeNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  Stream.WriteString(sLineBreak+getIndentation(Indentation)+'var'+sLineBreak,UnicodeFormat);
  if getChildCount>0 then begin
    inc(Indentation,cIndentationStep);
    for idx := 0 to pred(getChildCount) do begin
      if not getChild(idx).WriteToStream(Stream,UnicodeFormat,Indentation) then begin
        exit;
      end;
    end;
    dec(Indentation,cIndentationStep);
  end;
  Stream.WriteString(LineBreaks,UnicodeFormat);
  if not WriteAfterNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  Result := True;
end;

end.

