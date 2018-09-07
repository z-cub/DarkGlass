//------------------------------------------------------------------------------
// This file is part of the DarkGlass game engine project.
// More information can be found here: http://chapmanworld.com/darkglass
//
// DarkGlass is licensed under the MIT License:
//
// Copyright 2018 Craig Chapman
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the �Software�),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED �AS IS�, WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.
//------------------------------------------------------------------------------
unit darkvulkangen.ast.useslist.standard;

interface
uses
  darkIO.streams,
  darkvulkangen.ast,
  darkvulkangen.ast.node.standard;

type
  TdvUsesList = class( TdvASTNode, IdvUsesList )
  private
    procedure SetDelimiters(Node: IdvASTNode; LastInParent: boolean);
  protected
    function InsertChild( node: IdvASTNode ): IdvASTNode; override;
    function WriteToStream( Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32 ): boolean; override;
  public
    constructor Create; reintroduce;
  end;

implementation
uses
  darkLog,
  sysutils;

{ TdvUsesList }


constructor TdvUsesList.Create;
begin
  inherited Create;
  setLineBreaks(2);
end;

function TdvUsesList.InsertChild(node: IdvASTNode): IdvASTNode;
begin
  Result := nil;
  if (supports(node,IdvLabel)) or
     (supports(node,IdvIfDef)) or
     (supports(node,IdvIfNDef)) then begin
    Result := inherited InsertChild(node);
  end else begin
    Log.Insert(EUnsupportedChildType,TLogSeverity.lsFatal);
  end;
end;

procedure TdvUsesList.SetDelimiters( Node: IdvASTNode; LastInParent: boolean );
var
  idx: nativeuint;
begin
  if LastInParent then begin
    if Node.ChildCount=0 then begin
      if Supports(Node,IdvLabel) then begin
        (Node as IdvLabel).Delimiter := ';';
        (Node as IdvLabel).LineBreaks := 0;
      end;
    end;
  end else begin
    if Supports(Node,IdvLabel) then begin
      (Node as IdvLabel).Delimiter := ',';
      (Node as IdvLabel).Name := (Node as IdvLabel).Name;
    end;
  end;
  //-
  if Supports(Node,IdvIfDef) then begin
    (Node as IdvIfDef).OnOneLine := False;
  end;
  if Supports(Node,IdvIfNDef) then begin
    (Node as IdvIfNDef).OnOneLine := False;
  end;
  //- Loop through children doing the same.
  if Node.ChildCount=0 then begin
    exit;
  end;
  for idx := 0 to pred(Node.ChildCount) do begin
    if not LastInParent then begin
      SetDelimiters( Node.Children[idx], False );
    end else begin
      SetDelimiters( Node.Children[idx], idx=pred(Node.ChildCount) );
    end;
  end;
end;

function TdvUsesList.WriteToStream(Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32): boolean;
var
  idx: nativeuint;
begin
  Result := False;
  if not WriteBeforeNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  if getChildCount=0 then begin
    Result := True;
    exit;
  end;
  //- Write the items out.
  Stream.WriteString(getIndentation(Indentation)+'uses'+sLineBreak,UnicodeFormat);
  //- Set delimiters recursively on labels.
  for idx := 0 to pred(getChildCount) do begin
    SetDelimiters(getChild(idx),idx=pred(getChildCount));
  end;
  inc(Indentation,cIndentationStep);
  //- Write children.
  for idx := 0 to pred(getChildCount) do begin
    if not getChild(idx).WriteToStream(Stream,UnicodeFormat,Indentation) then begin
      exit;
    end;
  end;
  inc(Indentation,cIndentationStep);
  Stream.WriteString(LineBreaks,UnicodeFormat);
  if not WriteAfterNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  Result := True;
end;

end.
