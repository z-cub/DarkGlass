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
unit darkcollections.dictionary;
{$ifdef fpc} {$mode objfpc} {$endif}

interface
uses
  darkcollections.types;

type
  {$ifdef fpc} generic {$endif}
  IDictionary<T> = interface( ICollection )
    ['{5D0EA611-6D3D-4495-B8CB-3F249AF59746}']
    function getCount: uint64;
    function getKeyByIndex( idx: uint64 ): string;
    function getValueByIndex( idx: uint64 ): T;
    function getKeyExists( key: string ): boolean;
    function getValueByKey( key: string ): T;
    procedure setValueByKey( key: string; value: T );
    procedure removeByIndex( idx: uint64 );
    procedure clear;
    //- Pascal only, properties -//
    property Count: uint64 read getCount;
    property KeyExists[ key: string ]: boolean read getKeyExists;
    property ValueByKey[ key: string ]: T read getValueByKey;
    property ValueByIndex[ idx: uint64 ]: T read getValueByIndex;
    property KeyByIndex[ idx: uint64 ]: string read getKeyByIndex;
  end;

  /// <summary>
  ///   Standard dictionary is an implementation of IDictionary which uses
  ///   dynamic arrays to store entries. The performance of the class may be
  ///   adjusted by several parameters given to the constructor.
  /// </summary>
  {$ifdef fpc} generic {$endif}
  TDictionary<T: IInterface> = class( TInterfacedObject, ICollection, {$ifdef fpc} specialize {$endif} IDictionary<T> )
  private //- IDictionary<IfceType> -//
    function getCount: uint64;
    function getKeyByIndex( idx: uint64 ): string;
    function getValueByIndex( idx: uint64 ): T;
    function getKeyExists( key: string ): boolean;
    function getValueByKey(key: string): T;
    procedure setValueByKey( key: string; value: T );
    procedure removeByIndex( idx: uint64 );
    procedure clear;

  private
    fKeys: array of string;
    fItems: array of T;
    fCapacity: uint64;
    fCount: uint64;
    fGranularity: uint64;
    fPruned: boolean;
    fOrdered: boolean;
    function OrderedRemoveItem(idx: uint64): boolean;
    function UnorderedRemoveItem(idx: uint64): boolean;
    procedure PruneCapacity;

  public

    /// <summary>
    ///   The consrtuctor accepts two parameters which adjust the performance
    ///   of the dictionary under certain conditions.
    /// </summary>
    /// <param name="Granularity">
    ///   The array dictionary implementation allocates memory for new
    ///   entries as required. Rather than allocate memory for each single
    ///   entry at a time, space for a block of entries is allocated.
    ///   The size of this block can be specified by setting Granularity to
    ///   any value greater than zero. Leaving the granularity at zero will
    ///   cause the default 32 granularity to be used.
    /// </param>
    /// <param name="isPruned">
    ///   If set true, the dictionarys memory space will be pruned to the
    ///   closest granularity on entry removal. (See Granularity).
    ///   When set false, memory is not returned to the system until the
    ///   instance is disposed. In situations where a large number of entries
    ///   are added, and then removed, a large block of memory could remain
    ////  allocated when isPruned is set false.
    /// </param>
    constructor Create( Granularity: uint64 = 0; isOrdered: boolean = false; isPruned: boolean = false ); reintroduce;

    /// <summary>
    ///   Returns all memory to the system.
    /// </summary>
    destructor Destroy; override;
  end;

implementation

{$ifdef fpc}
constructor TDictionary.Create( Granularity: uint64 = 0; isOrdered: boolean = false; isPruned: boolean = false );
{$else}
constructor TDictionary<T>.Create( Granularity: uint64 = 0; isOrdered: boolean = false; isPruned: boolean = false );
{$endif}
const cDefaultGranularity = 32;
begin
  inherited Create;
  // Set granularity control
  if Granularity>0 then begin
    fGranularity := Granularity;
  end else begin
    fGranularity := cDefaultGranularity; // default granularity
  end;
  // Set granularity pruning.
  fPruned := isPruned;
  // Set order maintenance flag
  fOrdered := isOrdered;
  // Initialize the array.
  fCount := 0;
  fCapacity := 0;
  SetLength( fKeys, fCapacity );
  SetLength( fItems, fCapacity );
end;

{$ifdef fpc}
destructor TDictionary.Destroy;
{$else}
destructor TDictionary<T>.Destroy;
{$endif}
begin
  SetLength( fKeys, 0 );
  SetLength( fItems, 0 );
  inherited Destroy;
end;

{$ifdef fpc}
function TDictionary.getCount: uint64;
{$else}
function TDictionary<T>.getCount: uint64;
{$endif}
begin
  Result := fCount;
end;

{$ifdef fpc}
function TDictionary.getKeyByIndex(idx: uint64): string;
{$else}
function TDictionary<T>.getKeyByIndex(idx: uint64): string;
{$endif}
begin
  Result := '';
  if idx<getCount then begin
    Result := fKeys[idx];
  end;
end;

{$ifdef fpc}
function TDictionary.getKeyExists(key: string): boolean;
{$else}
function TDictionary<T>.getKeyExists(key: string): boolean;
{$endif}
var
  idx: uint64;
begin
  Result := False;
  if getCount>0 then begin
    for idx := 0 to pred(getCount) do begin
      if fKeys[idx]=key then begin
        Result := True;
        Exit;
      end;
    end;
  end;
end;

{$ifdef fpc}
function TDictionary.getValueByIndex(idx: uint64): T;
{$else}
function TDictionary<T>.getValueByIndex(idx: uint64): T;
{$endif}
begin
  Result := nil;
  if idx<getCount then begin
    Result := fItems[idx];
  end;
end;

{$ifdef fpc}
function TDictionary.getValueByKey(key: string): T;
{$else}
function TDictionary<T>.getValueByKey(key: string): T;
{$endif}
var
  idx: uint64;
begin
  Result := nil;
  if getCount>0 then begin
    for idx := 0 to pred(getCount) do begin
      if fKeys[idx]=key then begin
        Result := fItems[idx];
        Exit;
      end;
    end;
  end;
end;

{$ifdef fpc}
function TDictionary.OrderedRemoveItem( idx: uint64 ): boolean;
{$else}
function TDictionary<T>.OrderedRemoveItem( idx: uint64 ): boolean;
{$endif}
var
  idy: uint64;
begin
  Result := False; // unless..
  if fCount>0 then begin
    if idx<pred(fCount) then begin
      for idy := idx to pred(pred(fCount)) do begin
        fItems[idy] := fItems[succ(idy)];
        fKeys[idy] := fKeys[succ(idy)];
      end;
      fItems[pred(fCount)] := nil;
      fKeys[pred(fCount)] := '';
      dec(fCount);
      Result := True;
    end else if idx=pred(fCount) then begin
      //- Item is last on list, no need to move-down items above it.
      fItems[idx] := nil;
      fKeys[idx] := '';
      dec(fCount);
      Result := True;
    end;
  end;
end;

{$ifdef fpc}
function TDictionary.UnorderedRemoveItem( idx: uint64 ): boolean;
{$else}
function TDictionary<T>.UnorderedRemoveItem( idx: uint64 ): boolean;
{$endif}
begin
  Result := False; // unless..
  if fCount>0 then begin
    if idx<pred(fCount) then begin
      //- Move last item into place of that being removed.
      fItems[idx] := fItems[pred(fCount)];
      fKeys[idx] := fKeys[pred(fCount)];
      //- Clear last item
      fItems[pred(fCount)] := nil;
      fKeys[pred(fCount)] := '';
      dec(fCount);
      Result := True;
    end else if idx=pred(fCount) then begin
      //- if idx=fCount then simply remove the top item and decrement
      fItems[idx] := nil;
      fKeys[idx] := '';
      dec(fCount);
      Result := True;
    end;
  end;
end;

{$ifdef fpc}
procedure TDictionary.PruneCapacity;
{$else}
procedure TDictionary<T>.PruneCapacity;
{$endif}
var
  Blocks: uint64;
  Remainder: uint64;
  TargetSize: uint64;
begin
  Blocks := fCount div fGranularity;
  Remainder := fCount - Blocks;
  if Remainder>0 then begin
    inc(Blocks);
  end;
  TargetSize := Blocks*fGranularity;
  //- Total number of required blocks has been determined.
  if fCapacity>TargetSize then begin
    fCapacity := TargetSize;
    SetLength( fItems, fCapacity );
    SetLength( fKeys, fCapacity );
  end;
end;


{$ifdef fpc}
procedure TDictionary.removeByIndex(idx: uint64);
{$else}
procedure TDictionary<T>.removeByIndex(idx: uint64);
{$endif}
begin
  // If the list is ordered, perform slow removal, else fast removal
  if fOrdered then begin
    OrderedRemoveItem( idx );
  end else begin
    UnorderedRemoveItem( idx );
  end;
  // If the list is pruning memory (to save memory space), do the prune.
  if fPruned then begin
    PruneCapacity;
  end;
end;

{$ifdef fpc}
procedure TDictionary.clear;
{$else}
procedure TDictionary<T>.clear;
{$endif}
begin
  fCount := 0;
  if fPruned then begin
    fCapacity := 0;
    SetLength( fKeys, fCapacity );
    SetLength( fItems, fCapacity );
  end;
end;

{$ifdef fpc}
procedure TDictionary.setValueByKey(key: string; value: T);
{$else}
procedure TDictionary<T>.setValueByKey(key: string; value: T);
{$endif}
var
  idx: uint64;
begin
  if getCount>0 then begin
    for idx := 0 to pred(getCount) do begin
      if fKeys[idx]=key then begin
        fItems[idx] := value;
        Exit;
      end;
    end;
  end;
  //- If we made it here, add the item.
  if (fCount=fCapacity) then begin
    fCapacity := fCapacity + fGranularity;
    SetLength(fKeys,fCapacity);
    SetLength(fItems, fCapacity);
  end;
  fKeys[fCount] := key;
  fItems[fCount] := value;
  inc(fCount);
end;

end.
