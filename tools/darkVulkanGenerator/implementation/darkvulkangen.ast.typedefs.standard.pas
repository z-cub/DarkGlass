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
    procedure CheckAliasOrder(TypeUnderInspection: IdvTypeDef; CurrentIdx: nativeuint);
    procedure CheckRecordOrProcedureOrder(TypeUnderInspection: IdvTypeDef; CurrentIdx: nativeuint);
    procedure OrderStructs;
    function FindTypeByName(TypeName: string; var FoundIdx: nativeuint): boolean;
    procedure Reorder(TypeIdx, DependsOn: nativeuint);
  protected
    function WriteToStream( Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32 ): boolean; override;
  end;

implementation
uses
  sysutils;

procedure TdvTypeDefs.Reorder( TypeIdx: nativeuint; DependsOn: nativeuint );
var
  DependedOn: IdvTypeDef;
begin
  if DependsOn<=TypeIdx then begin
    exit;
  end;
  DependedOn := getChild(DependsOn) as IdvTypeDef;
end;

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

procedure TdvTypeDefs.CheckAliasOrder( TypeUnderInspection: IdvTypeDef; CurrentIdx: nativeuint );
var
  Child: IdvTypeDef;
  TypeString: string;
  TypeIdx: nativeuint;
begin
  //- Get the name of the type being referenced.
  if TypeUnderInspection.ChildCount=0 then begin
    exit; // do nothing
  end;
  if not supports(TypeUnderInspection.Children[0],IdvTypeDef) then begin
    exit;
  end;
  Child := TypeUnderInspection.Children[0] as IdvTypeDef;
  TypeString := Child.Name;
  if TypeString=TypeUnderInspection.Name then begin
    exit;
  end;
  //- Find the target type
  if FindTypeByName( TypeString, TypeIdx ) then begin
    Reorder( CurrentIdx, TypeIdx );
  end;
end;

procedure TdvTypeDefs.CheckRecordOrProcedureOrder(TypeUnderInspection: IdvTypeDef; CurrentIdx: nativeuint);
var
  idx: nativeuint;
  Child: IdvTypeDef;
  TypeString: string;
  TypeIdx: nativeuint;
begin
  //- Get the name of the type being referenced.
  if TypeUnderInspection.ChildCount=0 then begin
    exit; // do nothing
  end;
  for idx := 0 to pred(TypeUnderInspection.ChildCount) do begin
    if not supports(TypeUnderInspection.Children[idx],IdvTypeDef) then begin
      continue;
    end;
    Child := TypeUnderInspection.Children[idx] as IdvTypeDef;
    if not assigned(Child) then begin
      exit;
    end;
    if Child.ChildCount<>1 then begin
      exit;
    end;
    if not Supports(Child.Children[0],IdvTypeDef) then begin
      exit;
    end;
    TypeString := (Child.Children[0] as IdvTypeDef).Name;
    if TypeString=TypeUnderInspection.Name then begin
      continue;
    end;
    //- Find the target type
    if FindTypeByName( TypeString, TypeIdx ) then begin
      Reorder( CurrentIdx, TypeIdx );
    end;
  end;
end;


{ TdvTypeDefs }
procedure TdvTypeDefs.OrderStructs;
var
  idx: nativeuint;
  TypeUnderInspection: IdvTypeDef;
begin
  if getChildCount=0 then begin
    exit;
  end;
  //- Loop through all types.
  for idx := 0 to pred(getChildCount) do begin
    if Supports(getChild(idx),IdvTypeDef) then begin
      TypeUnderInspection := getChild(idx) as IdvTypedef;
      //- Is this type a record or alias?
      case TypeUnderInspection.TypeKind of
        tkTypedPointer,
        tkAlias: CheckAliasOrder( TypeUnderInspection, idx );
        tkFuncPointer,
        tkRecord,
        tkUnion: CheckRecordOrProcedureOrder( TypeUnderInspection, idx );
      end;
    end;
  end;
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

end.

