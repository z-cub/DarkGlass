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
unit darkio.stream.custom;
{$ifdef fpc} {$mode objfpc} {$endif}

interface
uses
  darkio.streams;

type
  /// <summary>
  ///   Base class for classes which implement IStream. <br />You should not
  ///   create an instance directly, but derrive from this class to provide
  ///   streams with CopyFrom() and getEndOfStream() support.
  /// </summary>
  TCustomStream = class( TInterfacedObject, IStream )
  private
    fName: string;
  protected //- IStream -//
    procedure Clear; virtual;
    procedure WriteBytes( value: array of uint8 ); virtual;
    procedure WriteByte( value: uint8 ); virtual;
    function ReadByte: uint8; virtual;
    function Read( p: pointer; Count: uint32 ): uint32; virtual; abstract;
    function Write( p: pointer; Count: uint32 ): uint32; virtual; abstract;
    function getSize: uint64; virtual; abstract;
    function getPosition: uint64; virtual; abstract;
    procedure setPosition( newPosition: uint64 ); virtual; abstract;
    function getRemainingBytes: uint64;
    function getName: string;
    procedure setName( value: string );
  protected
    function CopyFrom( Source: IStream ): uint64; virtual;
    function getEndOfStream: boolean; virtual;
  public
    constructor Create; reintroduce;
  public
    property EndOfStream: boolean read getEndOfStream;
    property Position: uint64 read getPosition write setPosition;
    property Size: uint64 read getSize;
  end;

implementation
uses
  sysutils;

function TCustomStream.getRemainingBytes: uint64;
begin
  Result := (Self.Size - Self.Position);
end;

function TCustomStream.ReadByte: uint8;
var
  b: uint8;
begin
  Self.Read(@b,1);
  Result := B;
end;

procedure TCustomStream.setName(value: string);
begin
  fName := value;
end;

procedure TCustomStream.WriteByte(value: uint8);
var
  B: uint8;
begin
  B := value;
  Self.Write(@b,1);
end;

procedure TCustomStream.WriteBytes(value: array of uint8);
begin
  Self.Write(@value[0],Length(value))
end;

procedure TCustomStream.Clear;
begin
  raise
    Exception.Create('Stream does not support .Clear()');
end;

function TCustomStream.CopyFrom(Source: IStream): uint64;
const
  cCopyBlockSize = 1024;
var
  Buffer: array of uint8;
  ReadBytes: uint32;
  WrittenBytes: uint32;
begin
  Result := 0;
  Initialize(Buffer);
  try
    SetLength(Buffer,cCopyBlockSize);
    if not Source.getEndOfStream then begin
      repeat
        ReadBytes := Source.Read( @Buffer[0], cCopyBlockSize );
        WrittenBytes := Write( @Buffer[0], ReadBytes );
        Result := Result + WrittenBytes;
      until (ReadBytes<cCopyBlockSize) or (not WrittenBytes=ReadBytes) or (Source.getEndOfStream);
    end;
  finally
    Finalize(Buffer);
  end;
end;

constructor TCustomStream.Create;
begin
  inherited Create;
  fName := '';
end;

function TCustomStream.getEndOfStream: boolean;
begin
  Result := getPosition()=getSize();
end;


function TCustomStream.getName: string;
begin
  Result := fName;
end;

end.


