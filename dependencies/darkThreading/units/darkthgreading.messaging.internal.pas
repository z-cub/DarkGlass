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
unit darkThgreading.messaging.internal;
{$ifdef fpc} {$mode delphiunicode} {$endif}

interface
uses
  darkThreading;

type
  ///  Record structure used internally to transport messages on the message
  ///  bus.
  PtrBoolean = ^Boolean;
  PtrNativeUInt = ^NativeUInt;
  TInternalMessageRecord = record
    Handled: PtrBoolean;
    Return: PtrNativeUInt;
    aMessage: TMessage;
  end;

  // Duplicating IAtomicRingBuffer< TInternalMessageRecord > because fpc will
  // not compile  IPipeRing = specialize IAtomicRingBuffer< TInternalMessageRecord >;
  // giving an internal compiler error (without error code!).
  IPipeRing = interface
    function Push( item: TInternalMessageRecord ): boolean;
    function Pull( var item: TInternalMessageRecord ): boolean;
    function IsEmpty: boolean;
  end;

  // Duplicating TAtomicRingBuffer< TInternalMessageRecord > because fpc will
  // not compile  TPipeRing = specialize TAtomicRingBuffer< TInternalMessageRecord >;
  // giving an internal compiler error (without error code!).
  TPipeRing = class( TInterfacedObject, IPipeRing )
  private
    fPushIndex: uint32;
    fPullIndex: uint32;
    fItems: array of TInternalMessageRecord;
  private //- IPipeRing -//
    function Push( item: TInternalMessageRecord ): boolean;
    function Pull( var item: TInternalMessageRecord ): boolean;
    function IsEmpty: boolean;
  public
    constructor Create( ItemCount: uint32 = 128 ); reintroduce;
  end;


  ///    Provides access to the ring buffer for the message channel.
  ///    This is used internally, and should not be made public.
  IMessageRingBuffer = interface
    ['{9EFC4D5D-A4B7-49F8-8ED6-E4F21E72E819}']

    ///  Provides internal access to the ring buffer from the message pipe to
    ///  the message channel.
    function GetRingBuffer: IPipeRing;
  end;

implementation

{ TPipeRing }

function TPipeRing.Push(item: TInternalMessageRecord): boolean;
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
  Move( item, fItems[fPushIndex], sizeof(TInternalMessageRecord) );
  fPushIndex := NewIndex;
  Result := True;
end;

function TPipeRing.Pull(var item: TInternalMessageRecord): boolean;
var
  NewIndex: uint32;
begin
  Result := False;
  if fPullIndex=fPushIndex then begin
    exit;
  end;
  Move( fItems[fPullIndex], item, sizeof(TInternalMessageRecord) );
  NewIndex := succ(fPullIndex);
  if NewIndex>=Length(fItems) then begin
    NewIndex := 0;
  end;
  fPullIndex := NewIndex;
  Result := True;
end;

function TPipeRing.IsEmpty: boolean;
begin
  Result := True;
  if fPullIndex=fPushIndex then begin
    exit;
  end;
  Result := False;
end;

constructor TPipeRing.Create(ItemCount: uint32);
begin
  inherited Create;
  fPushIndex := 0;
  fPullIndex := 0;
  SetLength(fItems,ItemCount);
end;

end.
