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
unit darkcollections.stack;
{$ifdef fpc} {$mode objfpc} {$endif}

interface
uses
  darkCollections.types;

type
  /// <summary>
  ///   When implemented, provides a simple push/pop stack of collection items.
  /// </summary>
  /// <remarks>
  ///   <para>
  ///     The Push method performs the same operation as Add() which is
  ///     inherited from ICollection.
  ///   </para>
  ///   <para>
  ///     The inherited Iterate() method will repeatedly pop items from the
  ///     stack until none remain.
  ///   </para>
  /// </remarks>
  {$ifdef fpc} generic {$endif}
  IStack<T> = interface( ICollection )
    ['{36648989-4580-4003-B773-4563F186A2B1}']

    /// <summary>
    ///   <para>
    ///     Pushes an item onto the stack.
    ///   </para>
    ///   <para>
    ///     Internally calls the Add() method which is inherited from
    ///     ICollection.
    ///   </para>
    /// </summary>
    /// <param name="Item">
    ///   The item to push onto the stack.
    /// </param>
    procedure Push( Item: T );

    /// <summary>
    ///   Returns the top item from the stack, and removes it from the stack.
    /// </summary>
    /// <returns>
    ///   The item returned from the stack, or nil if no items remain.
    /// </returns>
    function Pop: T;
  end;

  ///  <summary>
  ///    Provides an array based implementation of IStack;
  ///  </summary>
  {$ifdef fpc} generic {$endif}
  TStack<T: IInterface> = class( TInterfacedObject, {$ifdef fpc} specialize {$endif} IStack<T>, ICollection )
  private
    fItems: array of T;
    fCount: uint64;
    fCapacity: uint64;
    fGranularity: uint64;
    fPruned: boolean;
  private //- IStack  -//
    procedure Push( Item: T );
    function Pop: T;
  public

    /// <summary>
    ///   Constructs the stack with some memory managment options.
    /// </summary>
    /// <param name="Granularity">
    ///   Sets the memory allocation granularity of the internal array. Setting
    ///   this to any value greater than zero, will cause the stack to allocate
    ///   memory in chunks sufficient to store the given number of items.
    ///   Leaving Granularity at zero (or omitting the parameter), causes the
    ///   default granularity of 32 to be used.
    /// </param>
    /// <param name="Purge">
    ///   If set to true, the internal array will be reduced in size to the
    ///   nearest granularity block with sufficient space to store the
    ///   remaining items. This causes some pop operations to complete more
    ///   slowly, but returns unused memory to the system as soon as possible
    ///   (rather than on disposal of the stack).
    /// </param>
    constructor Create( Granularity: uint64 = 0; IsPruned: boolean = false ); reintroduce;

    ///  <summary>
    ///    Disposes of the stack of items.
    ///  </summary>
    destructor Destroy; override;
  end;

implementation

{$ifdef fpc}
constructor TStack.Create(Granularity: uint64; IsPruned: boolean);
{$else}
constructor TStack<T>.Create(Granularity: uint64; IsPruned: boolean);
{$endif}
const cDefaultGranularity = 32;
begin
  inherited Create;
  //- Determine memory usage granularity.
  if Granularity>0 then begin
    fGranularity := Granularity;
  end else begin
    fGranularity := cDefaultGranularity; //-default granularity
  end;
  fPruned := IsPruned;
  fCapacity := 0;
  fCount := 0;
  SetLength( fItems, fCapacity );
end;

{$ifdef fpc}
destructor TStack.Destroy;
{$else}
destructor TStack<T>.Destroy;
{$endif}
begin
  SetLength( fItems, 0 );
  inherited;
end;

{$ifdef fpc}
function TStack.Pop: T;
{$else}
function TStack<T>.Pop: T;
{$endif}
begin
  Result := nil;
  if fCount>0 then begin
    Result := fItems[pred(fCount)];
    fItems[pred(fCount)] := nil;
    dec(fCount);
  end;
end;

{$ifdef fpc}
procedure TStack.Push(Item: T);
{$else}
procedure TStack<T>.Push(Item: T);
{$endif}
begin
  //- Test that there is sufficient memory to add the item.
  if (fCount=fCapacity) then begin
    fCapacity := fCapacity + fGranularity;
    SetLength( fItems, fCapacity );
  end;
  //- Add the item
  fItems[fCount] := Item;
  inc(fCount);
end;

end.
