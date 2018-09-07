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
unit darkcollections.list;
{$ifdef fpc} {$mode objfpc} {$endif}

interface
uses
  darkCollections.types;

type
  /// <summary>
  ///   Represents a list collection. <br />Lists provide array style access to
  ///   the items within the collection.
  /// </summary>
  {$ifdef fpc} generic {$endif}
  IList<T: IInterface> = interface( ICollection )
    ['{2F7708B6-39A9-41CC-980A-AA653AF016D8}']

    ///  <summary>
    ///    Removes all items from the list.
    ///  </summary>
    procedure Clear;

    ///  <sumamry>
    ///    Adds an item to the list and returns it's index within the list.
    ///  </summary>
    function Add( item: T ): uint64;

    /// <summary>
    ///   Returns the number of items currently stored in the list.
    /// </summary>
    /// <returns>
    ///   The number of items currently stored in the list.
    /// </returns>
    function getCount: uint64;

    /// <summary>
    ///   Returns an item from the list, specified by it's index.
    /// </summary>
    /// <param name="idx">
    ///   An index into the list of items, specifying which item should be
    ///   returned.
    /// </param>
    /// <returns>
    ///   Returns an item, or else nil if the index was out of range.
    /// </returns>
    function getItem( idx: uint64 ): T;

    ///  <summary>
    ///    Replaces the item at idx with the new item.
    ///  </summary>
    procedure setItem( idx: uint64; item: T );

    /// <summary>
    ///   Removes an item from the list as specified by it's index.
    /// </summary>
    /// <param name="idx">
    ///   The index of the item to remove from the list.
    /// </param>
    function RemoveItem( idx: uint64 ): boolean;

    //- Pascal only properties -//
    property Count: uint64 read getCount;
    property Items[ idx: uint64 ]: T read getItem write setItem; default;

  end;

  /// <summary>
  ///   Standard list is an implementation of IList which uses dynamic arrays
  ///   to store list items. The performance of the class may be adjusted by
  ///   several parameters given to the constructor.
  /// </summary>
  {$ifdef fpc} generic {$endif}
  TList<T: IInterface> = class( TInterfacedObject, {$ifdef fpc} specialize {$endif} IList<T>, ICollection )
  private
    fItems: array of T;
    fCount: uint64;
    fCapacity: uint64;
    fGranularity: uint64;
    fOrdered: boolean;
    fPruned: boolean;
  private //- IList & inherited ICollection -/
    procedure Clear;
    function Add( Item: T ): uint64;
    function getCount: uint64;
    function getItem( idx: uint64 ): T;
    procedure setItem( idx: uint64; item: T );
    function RemoveItem( idx: uint64 ): boolean;
  private
    function OrderedRemoveItem(idx: uint64): boolean;
    function UnorderedRemoveItem(idx: uint64): boolean;
    procedure PruneCapacity;
  public

    /// <summary>
    ///   The consrtuctor accepts two parameters which adjust the performance
    ///   of the list under certain conditions.
    /// </summary>
    /// <param name="Granularity">
    ///   The array list implementation allocates memory for new items as
    ///   required. Rather than allocate memory for each single entry at a
    ///   time, space for a block of entries is allocated. The size of this
    ///   block can be specified by setting Granularity to any value greater
    ///   than zero. Leaving the granularity at zero will cause the default 32
    ///   granularity to be used.
    /// </param>
    /// <param name="isOrdered">
    ///   If set true, the items in the list will remain in the order they were
    ///   added, even as items are removed from the list. This slows
    ///   performance on item removal, as all items above the removed item must
    ///   be moved down into the space which is created. Setting this to false
    ///   will increase performance of item removal, at the cost of item
    ///   ordering within the list.
    /// </param>
    /// <param name="isPruned">
    ///   If set true, the list's memory space will be pruned to the closest
    ///   granularity on item removal. (See Granularity). When set false,
    ///   memory is not returned to the system until the instance is disposed.
    ///   In situations where a large number of items are added, and then
    ///   removed, a large block of memory could remain allocated when isPruned
    ///   is set false.
    /// </param>
    constructor Create( Granularity: uint64 = 0; isOrdered: boolean = false; isPruned: boolean = false ); reintroduce;

    /// <summary>
    ///   Returns all memory to the system.
    /// </summary>
    destructor Destroy; override;
  end;


implementation

{$ifdef fpc}
function TList.Add(Item: T): uint64;
{$else}
function TList<T>.Add(Item: T): uint64;
{$endif}
begin
  if (fCount=fCapacity) then begin
    fCapacity := fCapacity + fGranularity;
    SetLength(fItems, fCapacity);
  end;
  fItems[fCount] := Item;
  Result := fCount;
  inc(fCount);
end;

{$ifdef fpc}
procedure TList.Clear;
{$else}
procedure TList<T>.Clear;
{$endif}
begin
  fCount := 0;
  if fPruned then begin
    fCapacity := fGranularity;
    SetLength(fItems,fCapacity);
  end;
end;

{$ifdef fpc}
constructor TList.Create(Granularity: uint64 = 0; isOrdered: boolean = false; isPruned: boolean = false);
{$else}
constructor TList<T>.Create(Granularity: uint64; isOrdered, isPruned: boolean);
{$endif}
const cDefaultGranularity = 32;
begin
  inherited Create;
  // Set granularity control
  if Granularity>0 then begin
    fGranularity := Granularity;
  end else begin
    fGranularity := cDefaultGranularity; //- default granularity
  end;
  // Set granularity pruning.
  fPruned := isPruned;
  // Set order maintenance flag
  fOrdered := isOrdered;
  // Initialize the array.
  fCount := 0;
  fCapacity := 0;
  SetLength( fItems, fCapacity );
end;

{$ifdef fpc}
destructor TList.Destroy;
{$else}
destructor TList<T>.Destroy;
{$endif}
begin
  SetLength( fItems, 0 );
  inherited Destroy;
end;

{$ifdef fpc}
function TList.getCount: uint64;
{$else}
function TList<T>.getCount: uint64;
{$endif}
begin
  Result := fCount;
end;

{$ifdef fpc}
function TList.getItem(idx: uint64): T;
{$else}
function TList<T>.getItem(idx: uint64): T;
{$endif}
begin
  if idx<fCount then begin
    Result := fItems[idx];
  end else begin
    Result := nil;
  end;
end;

{$ifdef fpc}
function TList.OrderedRemoveItem( idx: uint64 ): boolean;
{$else}
function TList<T>.OrderedRemoveItem( idx: uint64 ): boolean;
{$endif}
var
  idy: uint64;
begin
  Result := False; // unless..
  if fCount=0 then begin
    exit;
  end;
  if idx<pred(fCount) then begin
    for idy := idx to pred(pred(fCount)) do begin
      fItems[idy] := fItems[succ(idy)];
    end;
    fItems[pred(fCount)] := nil;
    dec(fCount);
    Result := True;
  end else if idx=pred(fCount) then begin
    //- Item is last on list, no need to move-down items above it.
    fItems[idx] := nil;
    dec(fCount);
    Result := True;
  end;
end;

{$ifdef fpc}
function TList.UnorderedRemoveItem( idx: uint64 ): boolean;
{$else}
function TList<T>.UnorderedRemoveItem( idx: uint64 ): boolean;
{$endif}
begin
  Result := False; // unless..
  if fCount>0 then begin
    if idx<pred(fCount) then begin
      //- Move last item into place of that being removed.
      fItems[idx] := fItems[pred(fCount)];
      //- Clear last item
      fItems[pred(fCount)] := nil;
      dec(fCount);
      Result := True;
    end else if idx=pred(fCount) then begin
      //- if idx=fCount then simply remove the top item and decrement
      fItems[idx] := nil;
      dec(fCount);
      Result := True;
    end;
  end;
end;

{$ifdef fpc}
procedure TList.PruneCapacity;
{$else}
procedure TList<T>.PruneCapacity;
{$endif}
var
  Blocks: uint64;
  Remainder: uint64;
  TargetSize: uint64;
begin
  TargetSize := 0;
  Remainder := 0;
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
  end;
end;

{$ifdef fpc}
function TList.RemoveItem(idx: uint64): boolean;
{$else}
function TList<T>.RemoveItem(idx: uint64): boolean;
{$endif}
begin
  // If the list is ordered, perform slow removal, else fast removal
  if fOrdered then begin
    Result := OrderedRemoveItem( idx );
  end else begin
    Result := UnorderedRemoveItem( idx );
  end;
  // If the list is pruning memory (to save memory space), do the prune.
  if fPruned then begin
    PruneCapacity;
  end;
end;

{$ifdef fpc}
procedure TList.setItem(idx: uint64; item: T);
{$else}
procedure TList<T>.setItem(idx: uint64; item: T);
{$endif}
begin
  fItems[idx] := item;
end;

end.
