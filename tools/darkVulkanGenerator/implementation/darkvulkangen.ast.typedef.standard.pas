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
unit darkvulkangen.ast.typedef.standard;

interface
uses
  darkIO.streams,
  darkLog,
  darkvulkangen.ast,
  darkvulkangen.ast.node.standard;

type
  TdvTypeDef = class( TdvASTNode, IdvTypeDef )
  private
    fName: string;
    fKind: TdvTypeKind;
  private //- IdvTypeDef -//
    function getName: string;
    procedure setName( value: string );
    function getTypeKind: TdvTypeKind;
    procedure setTypeKind( value: TdvTypeKind );
    function getTypeString(Indentation: uint32): string;
  protected
    function WriteToStream( Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32 ): boolean; override;
  public
    constructor Create( Name: string; Kind: TdvTypeKind ); reintroduce;
  end;

implementation
uses
  sysutils;

{ TdvTypeDef }

constructor TdvTypeDef.Create(Name: string; Kind: TdvTypeKind);
begin
  inherited Create;
  fName := Name;
  fKind := Kind;
end;

function TdvTypeDef.getName: string;
begin
  Result := fName;
end;

function TdvTypeDef.getTypeKind: TdvTypeKind;
begin
  Result := fKind;
end;

procedure TdvTypeDef.setName(value: string);
begin
  fName := Value;
end;

procedure TdvTypeDef.setTypeKind(value: TdvTypeKind);
begin
  fKind := Value;
end;

function TdvTypeDef.getTypeString(Indentation: uint32): string;
var
  idx: uint32;
  WorkStr: string;
  UnionCounter: uint32;
begin
  Result := '';
  case fKind of

    tkVoid: exit;

    tkUserDefined: Result := fName;

    tkPointer: Result := 'pointer';

    tkTypedPointer: begin
      if getChildCount=0 then begin
        Result := '## Unknown typed-pointer in AST. ##';
        exit;
      end;
      if not Supports(getChild(0),IdvTypeDef) then begin
        Result := '## Unknown typed-pointer in AST. ##';
      end;
      Result := '^'+(getChild(0) as IdvTypeDef).getTypeString( Indentation );
    end;

    tkAlias: begin
      if getChildCount=0 then begin
        Result := '## Unknown Alias in AST. ##';
        exit;
      end;
      if not Supports(getChild(0),IdvTypeDef) then begin
        Result := '## Unknown Alias in AST. ##';
      end;
      Result := (getChild(0) as IdvTypeDef).getTypeString( Indentation );
    end;

    tkEnum: begin
      if getChildCount=0 then begin
        Result := '()';
        exit;
      end;
      Result := '(' + sLineBreak;
      for idx := 0 to pred(getChildCount) do begin
        if not Supports(getChild(idx),IdvConstant) then begin
          Result := Result + '## Unknown Enum value AST. ##';
          exit;
        end;
        Result := Result + getIndentation(Indentation+cIndentationStep) + (getChild(idx) as IdvConstant).Name + ' = ' + (getChild(idx) as IdvConstant).Value;
        if idx<>pred(getChildCount) then begin
          Result := Result + ', '
        end;
        Result := Result + sLineBreak;
      end;
      Result := Result + getIndentation(Indentation) + ')';
    end;

         tkuint8: Result := 'uint8';
          tkint8: Result := 'int8';
        tkuint16: Result := 'uint16';
         tkint16: Result := 'int16';
        tkuint32: Result := 'uint32';
         tkint32: Result := 'int32';
        tkuint64: Result := 'uint64';
         tkint64: Result := 'int64';
        tkSingle: Result := 'single';
        tkDouble: Result := 'double';
      tkAnsiChar: Result := 'ansiChar';
          tkChar: Result := 'char';
        tkString: Result := 'string';
    tkAnsiString: Result := 'ansiString';
    tkNativeUInt: Result := 'nativeuint';
     tkNativeInt: Result := 'nativeint';

    tkUnion,
    tkRecord: begin
      setLineBreaks(2);
      Result := 'record' + sLineBreak;
      if fKind=tkUnion then begin
        Result := Result + getIndentation(Indentation+cIndentationStep) + 'case uint32 of' + sLineBreak;
      end;
      if getChildCount>0 then begin
        UnionCounter := 0;
        for idx := 0 to pred(getChildCount) do begin
          if Supports(getChild(idx),IdvTypeDef) then begin
            Result := Result + getIndentation(Indentation+cIndentationStep);
            if fKind=tkUnion then begin
              Result := Result + IntToStr(UnionCounter) + ':(';
            end;
            Result := Result + (getChild(idx) as IdvTypeDef).Name + ': ' + (getChild(idx) as IdvTypeDef).getTypeString( Indentation ) + ';';
            if fKind=tkUnion then begin
              Result := Result + ');';
            end;
            inc(UnionCounter);
            if idx<pred(getChildCount) then begin
              if Supports(getChild(succ(idx)),IdvASTComment) then begin
                Result := Result + ' // ' + (getChild(succ(idx)) as IdvASTComment).CommentString;
              end;
            end;
            Result := Result + sLineBreak;
          end else begin
            if not Supports(getChild(idx),IdvASTComment) then begin
              Result := Result + '## Unsupported child node in AST! ##';
            end;
          end;
        end;
      end;
      Result := Result + getIndentation(Indentation) + 'end';
    end;

    //- Function
    tkFuncPointer: begin
      // First child is return type,
      // Subsequent children are parameters ( IdvTypeDef )
      if getChildCount=0 then begin
        Result := '## Unknown function pointer return type? ##';
      end;
      if not Supports(getChild(0),IdvTypeDef) then begin
        Result := '## Unsupported child AST node type. ##';
      end;
      //- Set the reserved word and determine the return type.
      if (getChild(0) as IdvTypeDef).TypeKind=tkVoid then begin
        WorkStr := '';
        Result := Result + 'procedure ';
      end else begin
        Result := Result + 'function ';
        WorkStr := ':' + (getChild(0) as IdvTypeDef).getTypeString(0);
      end;
      //- Loop parameters
      if getChildCount>1 then begin
        Result := Result + '( ';
        for idx := 1 to pred(getChildCount) do begin

          if not Supports(getChild(idx),IdvParameter) then begin
            Result := Result + '## Unsupported parameter node ##';
            continue;
          end;

          Result := Result + (getChild(idx) as IdvParameter).AsString;

          if idx=pred(getChildCount) then begin
            Result := Result + ' ';
          end else begin
            Result := Result + '; ';
          end;

        end;
        Result := Result + ')';
      end else begin
        Result := Result + '()';
      end;
      //- Put the return type on the string
      Result := Result + WorkStr;
    end;

    else begin
      Result := '## Unrecognized Type! ##';
    end;
  end;
end;


function TdvTypeDef.WriteToStream(Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32): boolean;
begin
  Result := False;
  if not WriteBeforeNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;

  //- Depending on the type of definition, determine the type string.
  if (fKind=TdvTypeKind.tkEnum) and (getChildCount=0) then begin
    Stream.WriteString(getIndentation(Indentation)+'//',UnicodeFormat);
  end;

  Stream.WriteString(getIndentation(Indentation)+fName+' = '+getTypeString(Indentation)+';'+LineBreaks,UnicodeFormat);

  if not WriteAfterNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  Result := True;
end;

end.

