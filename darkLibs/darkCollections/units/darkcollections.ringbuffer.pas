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
unit darkcollections.ringbuffer;
{$ifdef fpc} {$mode objfpc} {$endif}

interface

type
  {$ifdef fpc} generic {$endif}
  IRingBuffer<T> = interface
    ['{44A78B5E-440D-4BC1-97E7-3C3DAB74DBB8}']

    ///  <summary>
    ///    Returns the head index (useful for diagnostics on the ring)
    ///  </summary>
    function getHead: uint32;

    ///  <summary>
    ///    Returns the tail index (useful for diagnostics on the ring)
    ///  </summary>
    function getTail: uint32;

    ///  <summary>
    ///    Pushes an item of type T into the ring, assuming there is space to
    ///    do so. If there is no space, immediately returns false.
    ///  </summary>
    function Push( Item: T ): boolean;

    ///  <summary>
    ///    Returns true if there are items to pop out of the ring.
    ///  </summary>
    function Peek: boolean;

    ///  <summary>
    ///    Pops an item of type T out of the ring, assuming there are items to
    ///    pop. If there are no items to pop, immediately returns false.
    ///  </summary>
    function Pop( out Item: T ): boolean;

  end;

  {$ifdef fpc} generic {$endif}
  TRingBuffer<T> = class( TInterfacedObject, {$ifdef fpc} specialize {$endif} IRingBuffer<T> )
  private
    fItems: array of T;
    fTop: uint32;
    fHead: uint32;
    fTail: uint32;
  private //- IRing of T -//
    function getHead: uint32;
    function getTail: uint32;
    function Push( Item: T ): boolean;
    function Peek: boolean;
    function Pop( out Item: T ): boolean;
    function IncCounter(var counter: uint32): uint32;
  public
    constructor Create( BufferSize: uint32 ); reintroduce;
    destructor Destroy; override;
  end;

implementation

{ TRing<T> }
{$ifdef fpc}
constructor TRingBuffer.Create(BufferSize: uint32);
{$else}
constructor TRingBuffer<T>.Create(BufferSize: uint32);
{$endif}
begin
  inherited Create;
  SetLength( fItems, BufferSize );
  fTop := BufferSize;
  fHead := 0;
  fTail := 0;
end;

{$ifdef fpc}
destructor TRingBuffer.Destroy;
{$else}
destructor TRingBuffer<T>.Destroy;
{$endif}
begin
  SetLength( fItems, 0 );
  inherited Destroy;
end;

{$ifdef fpc}
function TRingBuffer.getHead: uint32;
{$else}
function TRingBuffer<T>.getHead: uint32;
{$endif}
begin
  Result := fHead;
end;

{$ifdef fpc}
function TRingBuffer.getTail: uint32;
{$else}
function TRingBuffer<T>.getTail: uint32;
{$endif}
begin
  Result := fTail;
end;

{$ifdef fpc}
function TRingBuffer.Peek: boolean;
{$else}
function TRingBuffer<T>.Peek: boolean;
{$endif}
begin
  Result := not (fTail=fHead);
end;

{$ifdef fpc}
function TRingBuffer.IncCounter(var counter: uint32): uint32;
{$else}
function TRingBuffer<T>.IncCounter(var counter: uint32): uint32;
{$endif}
begin
  if succ(Counter)=fTop then begin
    Result := 0;
  end else begin
    Result := succ(counter);
  end;
end;

{$ifdef fpc}
function TRingBuffer.Pop(out Item: T): boolean;
{$else}
function TRingBuffer<T>.Pop(out Item: T): boolean;
{$endif}
begin
  Result := False;
  {$ifdef fpc}Item := nil;{$endif}
  if (fTail=fHead) then begin
    Exit; //- There are no items
  end;
  Move( fItems[fTail], Item, Sizeof(T) );
  fTail := IncCounter(fTail);
  Result := True;
end;

{$ifdef fpc}
function TRingBuffer.Push(Item: T): boolean;
{$else}
function TRingBuffer<T>.Push(Item: T): boolean;
{$endif}
begin
  Result := False;
  if IncCounter(fHead)=fTail then begin //- can't permit head to catch tail.
    Exit;
  end;
  Move( Item, fItems[fHead], Sizeof(T));
  fHead := IncCounter(fHead);
  Result := True;
end;

end.
