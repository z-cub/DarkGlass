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
unit darkvulkangen.ast.rootnode.standard;

interface
uses
  darkvulkangen.ast,
  darkvulkangen.ast.node.standard;

type
  TdvASTRootNode = class( TdvASTNode, IdvASTRootNode )
  private //- IdvASTRootNode -//
    function WriteToDirectory( Directory: string; Indentation: uint32 ): boolean;
  protected //- IdvASTNode -//
    function InsertChild( node: IdvASTNode ): IdvASTNode; override;
  end;

implementation
uses
  darkIO.streams,
  darkLog,
  SysUtils;

const
  {$ifdef MSWINDOWS}
  cPathSeparator = '\';
  {$else}
  cPathSeparator = '/';
  {$endif}

type
  EASTRootUnitsOnly = class(ELogEntry);
  EUnableToCreateFile = class(ELogEntry);

{ TdvASTRootNode }

function TdvASTRootNode.InsertChild(node: IdvASTNode): IdvASTNode;
begin
  //- Check that we're only inserting units!
  if not Supports( node, IdvASTUnit ) then begin
    Result := nil;
    Log.Insert(EASTRootUnitsOnly,TLogSeverity.lsFatal);
    exit;
  end;
  Result := inherited InsertChild(node);
end;

function TdvASTRootNode.WriteToDirectory(Directory: string; Indentation: uint32): boolean;
var
  idx: uint32;
  Filename: string;
  FS: IUnicodeStream;
  UnicodeFormat: TUnicodeFormat;
begin
  Result := False;
  UnicodeFormat := TUnicodeFormat.utf8;
  //- We know that all children are units, so attempt to write them to
  //- unit files.
  if getChildCount=0 then begin
    Result := True;
    exit;
  end;
  for idx := 0 to pred(getChildCount) do begin
    Filename := Directory + cPathSeparator + (getChild(idx) as IdvASTUnit).Name + '.pas';
    //- If the file already exists, remove it, we're going to replace.
    if FileExists(Filename) then begin
      DeleteFile(Filename);
    end;
    //- Create output file
    FS := TFileStream.Create(Filename,False);
    try
      //- Check file was created
      if not assigned(FS) then begin
        Log.Insert(EUnableToCreateFile,TLogSeverity.lsFatal,[LogBind('filename',(getChild(idx) as IdvASTUnit).Name + '.pas')]);
        exit;
      end;
      //- Output unit to file.
      FS.WriteBOM(UnicodeFormat);
      //- Write the children.
      if not (getChild(idx) as IdvASTUnit).WriteToStream(FS,UnicodeFormat,Indentation) then begin
        Log.Insert(EUnableToCreateFile,TLogSeverity.lsFatal,[LogBind('filename',(getChild(idx) as IdvASTUnit).Name + '.pas')]);
        exit;
      end;
    finally
      FS := nil;
    end;
  end;
  Result := True;
end;

initialization
  Log.Register(EASTRootUnitsOnly,'You may only insert AST units (IdvASTUnit) into the AST root node.');
  Log.Register(EUnableToCreateFile,'Unable to create output file "(%filename%)."');

end.
