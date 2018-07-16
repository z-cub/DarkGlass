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
unit darkvulkangen.ast.comment.standard;

interface
uses
  darkIO.streams,
  darkvulkangen.ast,
  darkvulkangen.ast.node.standard;

type
  TdvASTComment = class( TdvASTNode, IdvASTComment )
  private
    fCommentString: string;
  private //- IdvASTComment
    function getCommentString: string;
    procedure setCommentString( value: string );
  protected
    function InsertChild(node: IdvASTNode): IdvASTNode; override;
    function WriteToStream( Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32 ): boolean; override;
  public
    constructor Create( aCommentString: string ); reintroduce;
    destructor Destroy; override;

  end;

implementation
uses
  darkLog,
  sysutils;

{ TdvASTComment }

constructor TdvASTComment.Create(aCommentString: string);
begin
  inherited Create;
  fCommentString := aCommentString;
  SetLineBreaks(2);
end;

destructor TdvASTComment.Destroy;
begin
  inherited Destroy;
end;


function TdvASTComment.getCommentString: string;
begin
  Result := fCommentString;
end;

procedure TdvASTComment.setCommentString(value: string);
begin
  fCommentString := value;
end;

function TdvASTComment.InsertChild(node: IdvASTNode): IdvASTNode;
begin
  Result := nil;
  Log.Insert(ENoChildren,TLogSeverity.lsError);
end;

function TdvASTComment.WriteToStream(Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32): boolean;
begin
  Result := False;
  if not WriteBeforeNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  if Trim(fCommentString)<>'' then begin
    Stream.WriteString(getIndentation(Indentation)+'{'+sLineBreak,UnicodeFormat);
    inc(Indentation,cIndentationStep);
    Stream.WriteString(getIndentation(Indentation)+fCommentString,UnicodeFormat);
    dec(Indentation,cIndentationStep);
    Stream.WriteString(getIndentation(Indentation)+sLineBreak+'}'+LineBreaks,UnicodeFormat);
  end;
  if not WriteAfterNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  Result := True;
end;

end.

