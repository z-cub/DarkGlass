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
unit darkio.cyclicbuffer.standard;
{$ifdef fpc} {$mode delphiunicode} {$endif}

interface
uses
  darkio.buffers,
  darkio.streams;

type
  ///  <summary>
  ///    The cyclic buffer provides the means to create a seemingly endless buffer of data.
  ///    The cyclic buffer provides the means to create a seemingly endless buffer
  ///    of data. As data is written into the buffer, space is consumed, and as
  ///    data is read from the buffer that space is restored. So long as the data
  ///    is being read from the buffer at the same speed, or higher speed than it
  ///    is being written, the buffer will not run out of memory. You should
  ///    check that the buffer has sufficient space remaining before writing to it
  ///    and if necessary halt the write operation.
  ///  </summary>
  TCyclicBuffer = class( TInterfacedObject, ICyclicBuffer )
  private
    fBuffer: IBuffer;
    fBottom: uint32;
    fTop: uint32;

  private
    function OffsetPointer( P: pointer; Offset: uint32 ): pointer; overload;
    function OffsetPointer( Offset: uint32 ): pointer; overload;

  protected
    //- Implement IdeCyclicBuffer -//
    procedure Clear;
    function Write( DataPtr: Pointer; Count: uint32 ): uint32;
    function Read( DataPtr: Pointer; Count: uint32 ): uint32;
    function Peek( DataPtr: Pointer; Count: uint32 ): uint32;
    function LoadFromStream( Stream: IStream; Bytes: uint32 ): uint32;
    function SaveToStream( Stream: IStream; Bytes: uint32 ): uint32;
    function getFreeBytes: uint32;
    function getUsedBytes: uint32;

  public
    /// <summary>
    ///   Creates a buffer of 'Size' bytes.
    /// </summary>
    constructor Create( Size: uint32 = 0 ); reintroduce;

    /// <summary>
    ///   Frees all memory used.
    /// </summary>
    destructor Destroy; override;
  public
    { Returns the number of bytes that are freely available in the buffer. }
    property FreeBytes: uint32 read GetFreeBytes;

    { Returns the number of bytes that are currently occupied in the buffer. }
    property UsedBytes: uint32 read GetUsedBytes;

  end;

implementation
uses
  darkio.buffer.standard;

procedure TCyclicBuffer.Clear;
begin
  fBottom := 0;
  fTop := 0;
end;

constructor TCyclicBuffer.Create( Size: uint32 = 0 );
begin
  inherited Create;
  //- Create internal buffer (coax and heap dependencies).
  fBuffer := TBuffer.Create(Size);
  Clear;
end;

destructor TCyclicBuffer.Destroy;
begin
  fBuffer := nil; // dispose interface.
  inherited Destroy;
end;

function TCyclicBuffer.GetFreeBytes: uint32;
begin
  if fBottom<fTop then begin
    Result := (fBuffer.Size - fTop) + (fBottom); // distance from buffer borders.
  end else if fTop<fBottom then begin
    Result := fBottom-fTop; // distance between the pointers
  end else begin
    Result := fBuffer.Size;
  end;
end;

function TCyclicBuffer.GetUsedBytes: uint32;
begin
  if fTop>fBottom then begin
    Result := fTop-fBottom;
  end else if fBottom>fTop then begin
    Result := (fBuffer.Size - fBottom) + fTop;
  end else begin
    Result := 0;
  end;
end;

function TCyclicBuffer.LoadFromStream(Stream: IStream; Bytes: uint32): uint32;
var
  Buffer: IBuffer;
  BytesToLoad: uint32;
  BytesLoaded: uint32;
begin
  Buffer := TBuffer.Create();
  try
    // Find out the number of bytes we can safely load in.
    BytesToLoad := Bytes;
    if FreeBytes<BytesToLoad then begin
      BytesToLoad := FreeBytes;
    end;
    if (Stream.getSize-Stream.getPosition)<BytesToLoad then begin
      BytesToLoad := (Stream.getSize-Stream.getPosition);
    end;
    // Size the buffer to load data from the stream
    Buffer.setSize(BytesToLoad);
    BytesLoaded := Buffer.LoadFromStream(Stream, BytesToLoad);
    // Write the data into the cyclic buffer
    Result := Write(Buffer.getDataPointer,BytesLoaded);
  finally
    Buffer := nil; // interface
  end;
end;

function TCyclicBuffer.OffsetPointer(P: pointer; Offset: uint32): pointer;
begin
  {$ifdef fpc} {$hints off} {$endif}
  Result := pointer(nativeuint(P)+Offset);
  {$ifdef fpc} {$hints on} {$endif}
end;

function TCyclicBuffer.OffsetPointer(Offset: uint32): pointer;
begin
  Result := OffsetPointer(fBuffer.getDataPointer,Offset);
end;

function TCyclicBuffer.Peek(DataPtr: Pointer; Count: uint32): uint32;
var
  SizeToRead: uint32;
  Remaining: uint32;
  NewPtr: pointer;
begin
  Result := 0;
  // Which is closest? The top of data or the top of the buffer.
  if fTop>fBottom then begin
    SizeToRead := fTop-fBottom;
    if SizeToRead>Count then begin
      SizeToRead := Count;
    end;
    Move( OffsetPointer(fBottom)^, DataPtr^, SizeToRead );
    Result := SizeToRead;
  end else if fBottom>=fTop then begin
    SizeToRead := fBuffer.Size - fBottom;
    if SizeToRead>Count then begin
      SizeToRead := Count;
    end;
    Move( OffsetPointer(fBottom)^, DataPtr^, SizeToRead );
    inc(Result,SizeToRead);
    NewPtr := OffsetPointer( DataPtr, SizeToRead );
    Remaining := Count-SizeToRead;
    if Remaining>0 then begin
      SizeToRead := fTop;
      if SizeToRead>Remaining then begin
        SizeToRead := Remaining;
      end;
      Move( OffsetPointer(fBottom)^, NewPtr^, SizeToRead );
      Result := Result + SizeToRead;
    end;
  end;
end;

function TCyclicBuffer.Read(DataPtr: Pointer; Count: uint32): uint32;
var
  SizeToRead: uint32;
  Remaining: uint32;
  NewPtr: pointer;
begin
  Result := 0;
  // Which is closest? The top of data or the top of the buffer.
  if fTop>fBottom then begin
    SizeToRead := fTop-fBottom;
    if SizeToRead>Count then begin
      SizeToRead := Count;
    end;
    Move( OffsetPointer(fBottom)^, DataPtr^, SizeToRead );
    inc(fBottom,SizeToRead);
    Result := SizeToRead;
  end else if fBottom>=fTop then begin
    SizeToRead := fBuffer.Size - fBottom;
    if SizeToRead>Count then begin
      SizeToRead := Count;
    end;
    Move( OffsetPointer(fBottom)^, DataPtr^, SizeToRead );
    inc(Result,SizeToRead);
    NewPtr := OffsetPointer( DataPtr, SizeToRead );
    Remaining := Count-SizeToRead;
    fBottom := 0; // we've read to the top of the buffer.
    if Remaining>0 then begin
      SizeToRead := fTop;
      if SizeToRead>Remaining then begin
        SizeToRead := Remaining;
      end;
      Move( OffsetPointer(fBottom)^, NewPtr^, SizeToRead );
      Result := Result + SizeToRead;
    end;
  end;
end;

function TCyclicBuffer.SaveToStream(Stream: IStream; Bytes: uint32): uint32;
var
  BytesToWrite: uint32;
  Buffer: IBuffer;
begin
  BytesToWrite := Bytes;
  if BytesToWrite>UsedBytes then begin
    BytesToWrite := UsedBytes;
  end;
  Buffer := TBuffer.Create();
  try
    Buffer.setSize(Bytes);
    BytesToWrite := Read(Buffer.getDataPointer,BytesToWrite);
    Result := Buffer.SaveToStream(Stream,BytesToWrite);
  finally
    Buffer := nil; // interface
  end;
end;

function TCyclicBuffer.Write(DataPtr: Pointer; Count: uint32): uint32;
var
  SizeToWrite: uint32;
  Remaining: uint32;
  Space: uint32;
  NewPtr: pointer;
  P: pointer;
begin
  // Calculate how many bytes of those provided can be written to the buffer.
  SizeToWrite := FreeBytes;
  if SizeToWrite>Count then begin
    SizeToWrite := Count;
  end;
  // Set a remainder to calcuate how much of the buffer we've written.
  Remaining := SizeToWrite;
  // If the buffer top is above the buffer bottom, then there may be
  // space above the top, and there may be space below the bottom.
  // If the buffer top is below the buffer bottom, then there is only
  // space between the buffer top and the buffer bottom. Start with the simplest.
  if fTop<fBottom then begin
    // There is only space between fTop and fBottom.
    // Move the data into fTop, and increment fTop.
    P := OffsetPointer(fTop);
    Move( DataPtr^, P^, Remaining );
    inc(fTop,Remaining);
  end else if fBottom<fTop then begin
    // There may be space above fTop and below fBottom.
    // Start by writing whatever can be written to the space above fTop.
    Space := fBuffer.Size - fTop;
    if Space>Remaining then begin
      Space := Remaining;
    end;
    p := OffsetPointer(fTop);
    Move( DataPtr^, P^, Space );
    NewPtr := OffsetPointer( DataPtr, Space ); // pointer for remaining data.
    dec(Remaining,Space);
    inc(fTop,Space);
    // If there is remaining data, it will fit between zero and fBottom
    if Remaining>0 then begin
      P := fBuffer.getDataPointer;
      Move( NewPtr^, P^, Remaining );
      fTop := Remaining;
    end;
  end else begin
    // fTop and fBottom are the same.
    SizeToWrite := fBuffer.Size;
    if SizeToWrite>Count then begin
      SizeToWrite := Count;
    end;
    P := OffsetPointer(fTop);
    Move( DataPtr^, P^, SizeToWrite );
    inc( fTop, SizeToWrite );
  end;
  Result := SizeToWrite;
end;

end.


