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
unit darkvulkangen.ast.typedefs.standard;

interface
uses
  darkIO.streams,
  darkLog,
  darkvulkangen.ast,
  darkvulkangen.ast.node.standard;

type
  TdvTypeDefs = class( TdvASTNode, IdvTypeDefs )
  private
    function FindTypeByName(TypeName: string; var FoundIdx: nativeuint): boolean;
  private
    function CheckRecordDependsOn( RecordDef: IdvTypeDef; TypeName: string ): boolean;
    procedure OrderStructs;
    function CheckAliasDependsOn(AliasDef: IdvTypeDef; TypeName: string): boolean;
  protected
    function InsertChild( node: IdvASTNode ): IdvASTNode; override;
    function WriteToStream( Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32 ): boolean; override;
  end;

implementation
uses
  sysutils;

type
  ETypeDefReinsertion = class( ELogEntry );

function TdvTypeDefs.FindTypeByName( TypeName: string; var FoundIdx: nativeuint ): boolean;
var
  idx: nativeuint;
  Child: IdvTypeDef;
begin
  Result := False;
  if getChildCount=0 then begin
    exit;
  end;
  for idx := 0 to pred(getChildCount) do begin
    if not Supports(getChild(idx),IdvTypeDef) then begin
      continue;
    end;
    Child := getChild(idx) as IdvTypeDef;
    if Child.Name=TypeName then begin
      FoundIdx := idx;
      Result := True;
      exit;
    end;
  end;
end;

function TdvTypeDefs.InsertChild(node: IdvASTNode): IdvASTNode;
var
  FoundIdx: nativeuint;
  TypeName: string;
begin
  if Supports(node,IdvTypeDef) then begin
    TypeName := (node as IdvTypeDef).Name;
    if FindTypeByName(TypeName,FoundIdx) then begin
      Result := getChild(FoundIdx);
      exit;
    end;
  end;
  Result := inherited InsertChild(node);
end;

function TdvTypeDefs.CheckRecordDependsOn( RecordDef: IdvTypeDef; TypeName: string ): boolean;
var
  idx: nativeuint;
  Child: IdvTypeDef;
  TypeString: string;
  TypeIdx: nativeuint;
begin
  Result := False;
  if RecordDef.ChildCount=0 then begin
    exit;
  end;
  for idx := 0 to pred(RecordDef.ChildCount) do begin
    if not supports(RecordDef.Children[idx],IdvTypeDef) then begin
      continue;
    end;
    Child := RecordDef.Children[idx] as IdvTypeDef;
    if not assigned(Child) then begin
      continue;
    end;
    if Child.ChildCount<>1 then begin
      continue;
    end;
    if not Supports(Child.Children[0],IdvTypeDef) then begin
      continue;
    end;
    TypeString := (Child.Children[0] as IdvTypeDef).Name;
    TypeString := StringReplace(TypeString,'^','',[rfReplaceAll]);
    if TypeString=TypeName then begin
      Result := True;
      exit;
    end;
  end;
end;

function TdvTypeDefs.CheckAliasDependsOn( AliasDef: IdvTypeDef; TypeName: string ): boolean;
var
  Child: IdvTypeDef;
  TypeString: string;
  TypeIdx: nativeuint;
begin
  Result := False;
  if AliasDef.ChildCount<>1 then begin
    exit;
  end;
  if not supports(AliasDef.Children[0],IdvTypeDef) then begin
    exit;
  end;
  Child := AliasDef.Children[0] as IdvTypeDef;
  if not assigned(Child) then begin
    exit;
  end;
  //- The child is now the type
  if not Supports(Child,IdvTypeDef) then begin
    exit;
  end;
  if Child.TypeKind<>tkUserDefined then begin
    exit;
  end;
  TypeString := Child.Name;
  TypeString := StringReplace(TypeString,'^','',[rfReplaceAll]);
  if TypeString=TypeName then begin
    Result := True;
    exit;
  end;
end;

procedure TdvTypeDefs.OrderStructs;
type
  TypeDefRecord = record
    TypeDef: IdvASTNode;
    Reinserted: boolean;
  end;
var
  idx: nativeuint;
  idy: nativeuint;
  InsertedCount: nativeuint;
  HasDependency: Boolean;
  ArrayOfTypeDefs: array of TypeDefRecord;
  CurrentDef: IdvTypeDef;
  TestDef: IdvTypeDef;
  TestType: string;
begin
  if getChildCount=0 then begin
    exit;
  end;
  //- Copy all type definitions into the local array.
  SetLength(ArrayOfTypeDefs,getChildCount);
  for idx := 0 to pred(getChildCount) do begin
    ArrayOfTypeDefs[idx].TypeDef := getChild(idx);
    ArrayOfTypeDefs[idx].Reinserted := False;
  end;
  //- Clear all type-defs from this node.
  Clear;
  //- Begin re-inserting.
  InsertedCount := 0; //- Only when InsertedCount = Length(ArrayOfTypeDefs) are we done re-ordering.
  repeat
    for idx := 0 to pred(Length(ArrayOfTypeDefs)) do begin

      //- No point testing something that's already been reinserted.
      if ArrayOfTypeDefs[idx].Reinserted then begin
        continue;
      end;

      //- Any node which is not a type def, just gets reinserted.
      if not Supports(ArrayOfTypeDefs[idx].TypeDef,IdvTypeDef) then begin
        InsertChild(ArrayOfTypeDefs[idx].TypeDef);
        inc(InsertedCount);
        ArrayOfTypeDefs[idx].Reinserted := True;
        continue;
      end;

      //- Now with our type-def, do we depend on some other type def in our list,
      //- which has not already been inserteD?
      CurrentDef := ArrayOfTypeDefs[idx].TypeDef as IdvTypeDef;

      HasDependency := False;
      for idy := 0 to pred(Length(ArrayOfTypeDefs)) do begin

        //- Save checking all other methods.
        if HasDependency then begin
          continue;
        end;

        if (idx=idy) then begin
          continue;
        end;

        if (ArrayOfTypeDefs[idy].Reinserted) then begin
          continue;
        end;

        if not Supports(ArrayOfTypeDefs[idy].TypeDef,IdvTypeDef) then begin
          continue;
        end;

        TestDef := ArrayOfTypeDefs[idy].TypeDef as IdvTypeDef;
        TestType := TestDef.Name;
        TestType := StringReplace(TestType,'^','',[rfReplaceAll]);
         //- Does CurrentDef depend on TestDef?
        case CurrentDef.TypeKind of
//          tkVoid: ;
//          tkUserDefined: ;
//          tkEnum: ;
//          tkPointer: ;
            tkTypedPointer,
            tkAlias: begin
              if CheckAliasDependsOn( CurrentDef, TestType ) then begin
                Hasdependency := True;
                continue;
              end;
            end;
//          tkuint8: ;
//          tkint8: ;
//          tkuint16: ;
//          tkint16: ;
//          tkuint32: ;
//          tkint32: ;
//          tkuint64: ;
//          tkint64: ;
//          tkNativeUInt: ;
//          tkNativeInt: ;
//          tkSingle: ;
//          tkDouble: ;
//          tkAnsiChar: ;
//          tkChar: ;
//          tkString: ;
//          tkAnsiString: ;
          tkRecord,
          tkUnion: begin
            if CheckRecordDependsOn( CurrentDef, TestType ) then begin
              HasDependency := True;
              continue;
            end;
          end;
//          tkFuncPointer: ;
        end; // case
      end; // for idy
      //- If a depenency was found, we can't insert this yet.
      if HasDependency then begin
        continue;
      end;
      //- Otherwise, reinsert this node.
      Log.Insert(ETypeDefReinsertion,TLogSeverity.lsInfo,[LogBind('name',CurrentDef.Name)]);
      InsertChild(CurrentDef);
      inc(InsertedCount);
      ArrayOfTypeDefs[idx].Reinserted := True;
    end; // for idx
  until InsertedCount = Length(ArrayOfTypeDefs);
  SetLength(ArrayOfTypeDefs,0);
end;


function TdvTypeDefs.WriteToStream(Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32): boolean;
var
  idx: nativeuint;
begin
  OrderStructs;
  Result := False;
  if not WriteBeforeNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  Stream.WriteString(sLineBreak+getIndentation(Indentation)+'type'+sLineBreak,UnicodeFormat);
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

initialization
  Log.Register(ETypeDefReinsertion,'Reinserting type-def: (%name%)');
end.

