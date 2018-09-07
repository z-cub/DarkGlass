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
unit darkthreading.atomicringbuffer;
{$ifdef fpc} {$mode objfpc} {$endif}

interface

type
  /// <summary>
  ///   An implementation of IAtomicRingBuffer provides a buffer of items which
  ///   may be exchanged between two threads. Atomic variables are used to
  ///   marshal the sharing of data between threads. <br /><br />Only two
  ///   threads may use the ring buffer during it's life-cycle. One thread (the
  ///   producer) is able to push items into the buffer, and the other thread
  ///   (the consumer) is able to pull items out of the buffer.
  /// </summary>
  /// <remark>
  ///   WARNING: FPC users, this code will compile, however, as of version 3.0.4
  ///   the compiler will generate an internal error (with no error code) if you
  ///   attempt to specialize this. Compiler bug? Sorry, this interface / class
  ///   is unavailable in FPC / Lazarus.
  /// </remark>
  /// <remarks>
  ///   <b>CAUTION -</b> There is no mechanism to prevent the consumer thread
  ///   from calling the push() method, nor the producer thread from calling
  ///   the pull() method. There is also no mechanism to prevent threads other
  ///   than the producer and consumer from calling these methods. It is your
  ///   responsibility to ensure that only one producer, and one consumer
  ///   thread calls the respective methods.
  /// </remarks>
  {$ifdef fpc} generic {$endif}
  IAtomicRingBuffer<T: record> = interface
    ['{6681F3CF-CF51-4312-816C-3E173F57C2CB}']

    /// <summary>
    ///   The producer thread may call Push() to add an item to the
    ///   IAtomicRingBuffer.
    /// </summary>
    /// <param name="item">
    ///   The item to be added to the ring buffer. <br />
    /// </param>
    /// <returns>
    ///   Returns true if the item is successfully inserted into the ring
    ///   buffer, however, this does not indicate that the message has been
    ///   retrieved by the consumer thread. <br />If this method returns false,
    ///   the buffer is full. An unsuccessful push operation can be retried and
    ///   will be successful if the consumer thread has called Pull() to free
    ///   up space for a new item in the buffer.
    /// </returns>
    /// <remarks>
    ///   The item will be copied during the push operation, permitting the
    ///   producer thread to dispose the memory after calling push.
    /// </remarks>
    function Push( item: T ): boolean;

    /// <summary>
    ///   The Pull() method is called by the consumer thread to retrieve an
    ///   item from the ring buffer.
    /// </summary>
    /// <param name="item">
    ///   Passed by reference, item will be set to match the next item in the
    ///   buffer.
    /// </param>
    /// <returns>
    ///   If there is an item in the ring buffer to be retrieved, this method
    ///   will return true. <br />If the method returns false, the buffer is
    ///   empty, a retry may be successful if the producer thread has pushed a
    ///   new item into the buffer.
    /// </returns>
    function Pull( var item: T ): boolean;

    ///  <summary>
    ///    Returns true if the ring buffer is currently empy.
    ///  </summary>
    function IsEmpty: boolean;
  end;

  /// <summary>
  ///   Implements IAtomicRingBuffer&lt;T: record&gt;
  /// </summary>
  /// <remark>
  ///   WARNING: FPC users, this code will compile, however, as of version 3.0.4
  ///   the compiler will generate an internal error (with no error code) if you
  ///   attempt to specialize this. Compiler bug? Sorry, this interface / class
  ///   is unavailable in FPC / Lazarus.
  /// </remark>
  /// <typeparam name="T">
  ///   A record datatype (or non-object)
  /// </typeparam>
  {$ifdef fpc} generic {$endif}
  TAtomicRingBuffer<T: record> = class( TInterfacedObject, {$ifdef fpc} specialize {$endif} IAtomicRingBuffer<T> )
  private
    fPushIndex: uint32;
    fPullIndex: uint32;
    fItems: array of T;
  private //- IAtomicRingBuffer -//
    /// <exclude />
    function Push( item: T ): boolean;
    /// <exclude />
    function Pull( var item: T ): boolean;
    /// <exclude />
    function IsEmpty: boolean;
  public

    /// <summary>
    ///   The constructor creates an instance of the atomic ring-buffer with a
    ///   pre-allocated number of items. By default, 128 items are
    ///   pre-allocated, set the ItemCount parameter to override this.
    /// </summary>
    /// <param name="ItemCount">
    ///   The number of items to pre-allocate in the buffer.
    /// </param>
    constructor Create( ItemCount: uint32 = 128 ); reintroduce;
  end;


implementation

{$ifdef fpc}
constructor TAtomicRingBuffer.Create( ItemCount: uint32 );
{$else}
constructor TAtomicRingBuffer<T>.Create( ItemCount: uint32 );
{$endif}
begin
  inherited Create;
  fPushIndex := 0;
  fPullIndex := 0;
  SetLength(fItems,ItemCount);
end;

{$ifdef fpc}
function TAtomicRingBuffer.IsEmpty: boolean;
{$else}
function TAtomicRingBuffer<T>.IsEmpty: boolean;
{$endif}
begin
  Result := True;
  if fPullIndex=fPushIndex then begin
    exit;
  end;
  Result := False;
end;

{$ifdef fpc}
function TAtomicRingBuffer.Pull(var item: T): boolean;
{$else}
function TAtomicRingBuffer<T>.Pull(var item: T): boolean;
{$endif}
var
  NewIndex: uint32;
begin
  Result := False;
  if fPullIndex=fPushIndex then begin
    exit;
  end;
  Move( fItems[fPullIndex], item, sizeof(T) );
  NewIndex := succ(fPullIndex);
  if NewIndex>=Length(fItems) then begin
    NewIndex := 0;
  end;
  fPullIndex := NewIndex;
  Result := True;
end;

{$ifdef fpc}
function TAtomicRingBuffer.Push(item: T): boolean;
{$else}
function TAtomicRingBuffer<T>.Push(item: T): boolean;
{$endif}
var
  NewIndex: uint32;
begin
  Result := False;
  NewIndex := succ(fPushIndex);
  if (NewIndex>=Length(fItems)) then begin
    NewIndex := 0;
  end;
  if NewIndex=fPullIndex then begin
    Exit;
  end;
  Move( item, fItems[fPushIndex], sizeof(T) );
  fPushIndex := NewIndex;
  Result := True;
end;



end.
