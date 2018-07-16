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
unit darkio.memorystream.standard;

interface
uses
  darkio.buffers,
  darkio.streams,
  darkio.unicodestream.custom;

const
  cDefaultGranularity = 256; //- One quater kilobyte!

type
  /// <summary>
  ///   This class provides an IStream and IUnicodeStream implementation,
  ///   which streams data into and from a memory buffer.
  ///   The memory buffer will expand as more data is written to it.
  /// </summary>
  TMemoryStream = class( TCustomUnicodeStream,
                         IStream,
                         IUnicodeStream )
  private
    fBuffer: IUnicodeBuffer;
    fGranularity: uint32;
    fSize: nativeuint;
    fPosition: nativeuint;
  protected
    function getPosition: uint64; override;
    procedure setPosition( newPosition: uint64 ); override;
    function getSize: uint64; override;
    function Read( p: pointer; Count: uint32 ): uint32; override;
    function Write( p: pointer; Count: uint32 ): uint32; override;
    procedure Clear; override;
  public

    /// <summary>
    ///   The constructor accepts a granularity parameter, which sets the
    ///   granularity with which memory is allocated on the buffer. For
    ///   example, with a granularity of 512 (the default) when writing to the
    ///   stream, should the memory buffer become full, an additional 512 bytes
    ///   will be allocated.
    /// </summary>
    /// <param name="BufferGranularity">
    ///   sOptional parameter, The allocation granularity of the memory buffer,
    ///   in bytes.
    /// </param>
    constructor Create(BufferGranularity: uint32 = cDefaultGranularity ); reintroduce;
    destructor Destroy; override;

  public
    property EndOfStream;
    property Position;
    property Size;
  end;

implementation
uses
  darkio.buffer.standard;

procedure TMemoryStream.Clear;
begin
  fBuffer.Size := fGranularity;
  fSize := 0;
  fPosition := 0;
end;

constructor TMemoryStream.Create(BufferGranularity: uint32);
begin
  inherited Create;
  fBuffer := TBuffer.Create();
  if BufferGranularity>0 then begin
    fGranularity := BufferGranularity;
  end else begin
    fGranularity := cDefaultGranularity;
  end;
  //- Clear buffer
  Clear;
end;

destructor TMemoryStream.Destroy;
begin
  fBuffer := nil;
  inherited Destroy;
end;

function TMemoryStream.getPosition: uint64;
begin
  Result := fPosition;
end;

function TMemoryStream.getSize: uint64;
begin
  Result := fSize;
end;

function TMemoryStream.Read(p: pointer; Count: uint32): uint32;
var
  ActualBytesToRead: uint32;
begin
  ActualBytesToRead := Count;
  if ActualBytesToRead > Size-Position then begin
    ActualBytesToRead := Size-Position;
  end;
  if ActualBytesToRead<=0 then begin
    Result := 0;
    Exit;
  end;
  fBuffer.ExtractData(P,Position,ActualBytesToRead);
  fPosition := fPosition + ActualBytesToRead;
  Result := ActualBytesToRead;
end;

procedure TMemoryStream.setPosition(newPosition: uint64);
begin
  if newPosition<fSize then begin
    fPosition := NewPosition;
  end else begin
    fPosition := fSize;
  end;
end;

function TMemoryStream.Write(p: pointer; Count: uint32): uint32;
begin
  //- If the buffer is not big enough to add this data.
  while (Count>fBuffer.Size-Position) do begin
    fBuffer.Size := fBuffer.Size + fGranularity;
  end;
  fBuffer.InsertData(p,position,count);
  fSize := fSize + Count;
  fPosition := fPosition + Count;
  Result := Count;
end;

end.


