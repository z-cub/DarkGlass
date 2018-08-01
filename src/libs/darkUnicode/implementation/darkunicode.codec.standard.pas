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
/// <exclude />
unit darkUnicode.codec.standard;
{$ifdef fpc} {$mode objfpc} {$endif}

interface
uses
  darkUnicode;

type
  /// <exclude />
  TUnicodeCodec = class( TInterfacedObject, IUnicodeCodec )
    function EncodeCodepointToString(CodePoint: TUnicodeCodePoint; var Str: string): boolean;
    function DecodeCodepointFromString(var CodePoint: TUnicodeCodePoint; Source: string; var Cursor: int32): boolean;
    function UTF8CharacterLength(var Bytes; var size: uint8): boolean;
    function UTF16LECharacterLength(var Bytes; var size: uint8): boolean;
    function UTF16BECharacterLength(var Bytes; var size: uint8): boolean;
    function UTF8Decode(var Bytes; var CodePoint: TUnicodeCodePoint): boolean;
    function UTF16LEDecode(var Bytes; var CodePoint: TUnicodeCodePoint ): boolean;
    function UTF16BEDecode(var Bytes; var CodePoint: TUnicodeCodePoint): boolean;
    function UTF32LEDecode(var Bytes; var CodePoint: TUnicodeCodePoint): boolean;
    function UTF32BEDecode(var Bytes; var CodePoint: TUnicodeCodePoint): boolean;
    function AnsiDecode(var Bytes; var CodePoint: TUnicodeCodePoint): boolean;
    function UTF8Encode(CodePoint: TUnicodeCodePoint; var Bytes; var Size: uint8): boolean;
    function UTF16LEEncode(CodePoint: TUnicodeCodePoint; var Bytes; var size: uint8 ): boolean;
    function UTF16BEEncode(CodePoint: TUnicodeCodePoint; var Bytes; var size: uint8): boolean;
    function UTF32LEEncode(CodePoint: TUnicodeCodePoint; var Bytes; var size: uint8): boolean;
    function UTF32BEEncode(CodePoint: TUnicodeCodePoint; var Bytes; var size: uint8): boolean;
    function AnsiEncode(CodePoint: TUnicodeCodePoint; var Bytes; var size: uint8): boolean;
    function DecodeBOM(var Bytes; Format: TUnicodeFormat; BomSize: uint8): boolean;
    function EncodeBOM(var Bytes; Format: TUnicodeFormat; var size: uint8): boolean;
  end;

implementation

//==============================================================================

const
  cpBMP   = 0;  /// Unicode Basic Multilingual plane.
//  cpSMP   = 1;  /// Unicode Suplementary Multilingual plane.
//  cpSIP   = 2;  /// Unicode Supplementary Ideographic plane.
//  cpSSPP  = 14; /// Unicode Supplementary Special-purpose Plane.
//  cpSPUP1 = 15; /// Unicode Supplementary Private Use Plane 1 (of 2)
//  cpSPUP2 = 16; /// Unicode Supplementary Private Use Plane 2 (of 2)


type
  /// <summary>
  ///   Represents the unicode code-plane portion of a code point.
  /// </summary>
  TCodePlane = $00 .. $10; //- code planes 0-17, represented as 5-bits of code plane.

  /// <summary>
  ///   Contains class methods for working with code points.
  /// </summary>
  UnicodeCodePoint = class
  public

    /// <summary>
    ///   Get the code plane portion of a code point.
    /// </summary>
    class function GetPlane( CodePoint: TUnicodeCodePoint ): TCodePlane;

    /// <summary>
    ///   Get the value portion of a code point.
    /// </summary>
    class function GetValue( CodePoint: TUnicodeCodePoint  ): uint32;

    /// <summary>
    ///   Get the least significant byte of a code point.
    /// </summary>
    class function GetLSB( CodePoint: TUnicodeCodePoint ): uint8;

    /// <summary>
    ///   Get the most significatn byte of a code point.
    /// </summary>
    class function GetMSB( CodePoint: TUnicodeCodePoint ): uint8;

    /// <summary>
    ///   Set the unicode code plane portion of a code point.
    /// </summary>
    class procedure SetPlane( var CodePoint: TUnicodeCodePoint; const Value: TCodePlane );

    /// <summary>
    ///   Set the value portion of a code point.
    /// </summary>
    class procedure SetValue( var CodePoint: TUnicodeCodePoint; const Value: uint32 );

    /// <summary>
    ///   Set the least significant byte of a code point.
    /// </summary>
    class procedure SetLSB( var CodePoint: TUnicodeCodePoint; const Value: uint8 );

    /// <summary>
    ///   Set the most significant byte of a code point.
    /// </summary>
    class procedure SetMSB( var CodePoint: TUnicodeCodePoint; const Value: uint8 );
  end;

//============
function IncPtr(P: pointer): pointer;
begin
  {$ifdef fpc}{$hints off}{$endif}
  Result := pointer(NativeUInt(P) + 1);
  {$ifdef fpc}{$hints on}{$endif}
end;

function SwapBytes( value: uint16 ): uint16;
type
  TByteSwapper = packed record
    A: uint8;
    B: uint8;
  end;
var
  ByteSwapper: TByteSwapper;
  Swap: uint16 absolute ByteSwapper;
begin
  Swap := Value;
  Result := (ByteSwapper.A shl 8) or (ByteSwapper.B);
end;

function HiWord(x:longword):word;
begin
  HiWord := (x and $FFFF0000) shr 16;
end;

function LoWord(x:longword):word;
begin
  LoWord := (x and $0000FFFF);
end;

function SwapEndianess( value: uint32 ): uint32;
var
  h: uint16;
  l: uint16;
begin
  h := HiWord(Value);
  l := LoWord(Value);
  h := SwapBytes(h);
  l := SwapBytes(l);
  Result := (L shl 16) or H;
end;

class function UnicodeCodePoint.GetPlane( CodePoint: TUnicodeCodePoint ): TCodePlane;
begin
  Result := (CodePoint and $1F0000) shr 16;
end;

class function UnicodeCodePoint.GetValue( CodePoint: TUnicodeCodePoint ): uint32;
begin
  Result := (CodePoint and $FFFF);
end;

class function UnicodeCodePoint.GetLSB( CodePoint: TUnicodeCodePoint ): uint8;
begin
  Result := CodePoint and $000000FF;
end;

class function UnicodeCodePoint.GetMSB( CodePoint: TUnicodeCodePoint ): uint8;
begin
  Result := (CodePoint and $0000FF00) shr 8;
end;

class procedure UnicodeCodePoint.SetPlane(var CodePoint: TUnicodeCodePoint; const Value: TCodePlane);
var
  aPlane: uint32;
begin
  aPlane := Value shl 16;
  CodePoint := (CodePoint AND $FFFF); // clear existing code plane
  CodePoint := (CodePoint or aPlane); // insert the new code plane
end;

class procedure UnicodeCodePoint.SetValue(var CodePoint: TUnicodeCodePoint; const Value: uint32);
begin
  CodePoint := (CodePoint and $FF0000); // clear the last 16 bits
  CodePoint := (CodePoint or Value); // insert the value
end;

class procedure UnicodeCodePoint.SetLSB(var CodePoint: TUnicodeCodePoint; const Value: uint8);
begin
  CodePoint := (CodePoint and $FFFF00); // clear the last 8-bits
  CodePoint := (CodePoint or Value); // insert the value.
end;

class procedure UnicodeCodePoint.SetMSB(var CodePoint: TUnicodeCodePoint; const Value: uint8);
var
  aValue: uint16;
begin
  CodePoint := (CodePoint and $FF00FF); // clear the MSB
  aValue := Value;
  AValue := AValue shl 8;
  CodePoint := (CodePoint or aValue); // insert the value
end;

function TUnicodeCodec.AnsiDecode(var Bytes; var CodePoint: TUnicodeCodePoint): boolean;
var
  Buffer: ^uint8;
begin
  // Turn this into a code-point.
  Result := True;
  CodePoint := 0;
  {$ifdef fpc}{$hints off}{$endif}
  Buffer := pointer(nativeuint(@Bytes));  // This nonsense because the compiler optimizes out Buffer := @Bytes;
  {$ifdef fpc}{$hints on}{$endif}
  UnicodeCodePoint.SetPlane( CodePoint, 0 );
  UnicodeCodePoint.SetMSB( CodePoint, 0 );
  UnicodeCodePoint.SetLSB( CodePoint, Buffer^ );
end;

function TUnicodeCodec.AnsiEncode(CodePoint: TUnicodeCodePoint; var Bytes; var size: uint8): boolean;
var
  Buffer: ^uint8;
begin
  Result := True;
  // The code plane should be zero to encode to ANSI or else data will be lost.
  // Load the byte into memory
  {$ifdef fpc}{$hints off}{$endif}
  Buffer := pointer(nativeuint(@Bytes));  // This nonsense because the compiler optimizes out Buffer := @Bytes;
  {$ifdef fpc}{$hints on}{$endif}
  Buffer^ := UnicodeCodePoint.GetLSB( CodePoint );
  size := sizeof(uint8);
end;

function TUnicodeCodec.UTF8CharacterLength(var Bytes; var size: uint8): boolean;
var
  Buffer: ^uint8;
begin
  Result := True; // unless..
  {$ifdef fpc}{$hints off}{$endif}
  Buffer := pointer(nativeuint(@Bytes));  // This nonsense because the compiler optimizes out Buffer := @Bytes;
  {$ifdef fpc}{$hints on}{$endif}
  if (Buffer^ and $FC)=$FC then begin
    Size := 6;
  end else if (Buffer^ and $F8)=$F8 then begin
    Size := 5;
  end else if (Buffer^ and $F0)=$F0 then begin
    Size := 4;
  end else if (Buffer^ and $E0)=$E0 then begin
    Size := 3;
  end else if (Buffer^ and $C0)=$C0 then begin
    Size := 2;
  end else if (Buffer^ or $7F)=$7F then begin
    Size := 1;
  end else begin
    Size := 0;
    Result := False;
  end;
end;

function TUnicodeCodec.UTF8Decode(var Bytes; var CodePoint: TUnicodeCodePoint): boolean;
var
  Target: uint32;
  Temp: uint32;
  Buffer: ^uint8;
begin
  Result := True; //- Unless..
  CodePoint := 0;
  Target := 0;
  {$ifdef fpc}{$hints off}{$endif}
  Buffer := pointer(nativeuint(@Bytes));  // This nonsense because the compiler optimizes out Buffer := @Bytes;
  {$ifdef fpc}{$hints on}{$endif}
  // Length check.
  if (Buffer^ and $FC)=$FC then begin
    // 6-byte encoding
    // Begin building result
    Temp   := (Buffer^ AND $01); // using Temp as it's same width as Target, prevents hint.
    Target := Target or Temp;
    Target := Target shl 6;
    Buffer := IncPtr(Buffer);
    Temp   := (Buffer^ AND $3F); // using Temp as it's same width as Target, prevents hint.
    Target := Target or Temp;
    Target := Target shl 6;
    Buffer := IncPtr(Buffer);
    Temp   := (Buffer^ AND $3F); // using Temp as it's same width as Target, prevents hint.
    Target := Target or Temp;
    Target := Target shl 6;
    Buffer := IncPtr(Buffer);
    Temp   := (Buffer^ AND $3F); // using Temp as it's same width as Target, prevents hint.
    Target := Target or Temp;
    Target := Target shl 6;
    Buffer := IncPtr(Buffer);
    Temp   := (Buffer^ AND $3F); // using Temp as it's same width as Target, prevents hint.
    Target := Target or Temp;
    Target := Target shl 6;
    Buffer := IncPtr(Buffer);
    Temp   := (Buffer^ AND $3F); // using Temp as it's same width as Target, prevents hint.
    Target := Target or Temp;
  end else if (Buffer^ and $F8)=$F8 then begin
    // 5-byte encoding
    // Begin building result
    Temp   := (Buffer^ AND $03); // using Temp as it's same width as Target, prevents hint.
    Target := Target or Temp;
    Target := Target shl 6;
    Buffer := IncPtr(Buffer);
    Temp   := (Buffer^ AND $3F); // using Temp as it's same width as Target, prevents hint.
    Target := Target or Temp;
    Target := Target shl 6;
    Buffer := IncPtr(Buffer);
    Temp   := (Buffer^ AND $3F); // using Temp as it's same width as Target, prevents hint.
    Target := Target or Temp;
    Target := Target shl 6;
    Buffer := IncPtr(Buffer);
    Temp   := (Buffer^ AND $3F); // using Temp as it's same width as Target, prevents hint.
    Target := Target or Temp;
    Target := Target shl 6;
    Buffer := IncPtr(Buffer);
    Temp   := (Buffer^ AND $3F); // using Temp as it's same width as Target, prevents hint.
    Target := Target or Temp;
  end else if (Buffer^ and $F0)=$F0 then begin
    // 4-byte encoding
    // Begin building result
    Temp   := (Buffer^ AND $07); // using Temp as it's same width as Target, prevents hint.
    Target := Target or Temp;
    Target := Target shl 6;
    Buffer := IncPtr(Buffer);
    Temp   := (Buffer^ AND $3F); // using Temp as it's same width as Target, prevents hint.
    Target := Target or Temp;
    Target := Target shl 6;
    Buffer := IncPtr(Buffer);
    Temp   := (Buffer^ AND $3F); // using Temp as it's same width as Target, prevents hint.
    Target := Target or Temp;
    Target := Target shl 6;
    Buffer := IncPtr(Buffer);
    Temp   := (Buffer^ AND $3F); // using Temp as it's same width as Target, prevents hint.
    Target := Target or Temp;
  end else if (Buffer^ and $E0)=$E0 then begin
    // Begin building result
    Temp   := (Buffer^ AND $0F); // using Temp as it's same width as Target, prevents hint.
    Target := Target or Temp;
    Target := Target shl 6;
    Buffer := IncPtr(Buffer);
    Temp   := (Buffer^ AND $3F); // using Temp as it's same width as Target, prevents hint.
    Target := Target or Temp;
    Target := Target shl 6;
    Buffer := IncPtr(Buffer);
    Temp   := (Buffer^ AND $3F); // using Temp as it's same width as Target, prevents hint.
    Target := Target or Temp;
  end else if (Buffer^ and $C0)=$C0 then begin
    // 2-byte encoding
    // Begin building result
    Temp   := (Buffer^ AND $1F); // using Temp as it's same width as Target, prevents hint.
    Target := Target or Temp;
    Target := Target shl 6;
    Buffer := IncPtr(Buffer);
    Temp   := (Buffer^ AND $3F); // using Temp as it's same width as Target, prevents hint.
    Target := Target or Temp;
  end else if (Buffer^ or $7F)=$7F then begin
    // 1-byte encoding
    //- remove unwanted encoding bits
    Target := (Buffer^ AND $7F);
  end else begin
    CodePoint := 0;
    Result := False;
  end;
  UnicodeCodePoint.SetValue( CodePoint, Target );
end;

function TUnicodeCodec.UTF8Encode(CodePoint: TUnicodeCodePoint; var Bytes; var Size: uint8): boolean;
var
  Point: uint64;
  Buffer: ^uint8;
begin
  Result := True; // Unless...
//  Point := UnicodeCodePoint.GetValue( CodePoint );
  Point := CodePoint;
  {$ifdef fpc}{$hints off}{$endif}
  Buffer := pointer(nativeuint(@Bytes));  // This nonsense because the compiler optimizes out Buffer := @Bytes;
  {$ifdef fpc}{$hints on}{$endif}
  // How many octets (bytes) are required to encode this code-point?
  if {(Point>=0) and} (Point<=$007F) then begin
    // 1-byte encoding
    Buffer^ := Point and $7F; // only the right 7 bits are useful
    Size := sizeof(uint8);
  end else if (Point>=$0080) and (Point<=$07FF) then begin
    // 2-byte encoding
    Buffer^ := $C0;
    Buffer^ := Buffer^ or ((Point and $7C0) shr 6);
    Buffer := IncPtr(Buffer);
    Buffer^ := $80;
    Buffer^ := Buffer^ or (Point and $3F);
    Size := sizeof(uint16);
  end else if (Point>=$0800) and (Point<=$FFFF) then begin
    // 3-byte encoding
    Buffer^ := $E0;
    Buffer^ := Buffer^ or ((Point and $F000) shr 12);
    Buffer := IncPtr(Buffer);
    Buffer^ := $80;
    Buffer^ := Buffer^ or ((Point and $FC0) shr 6);
    Buffer := IncPtr(Buffer);
    Buffer^ := $80;
    Buffer^ := Buffer^ or (Point and $3F);
    Size := sizeof(uint8) + sizeof(uint16);
  end else if (Point>=$10000) and (Point<=$1FFFFF) then begin
    // 4-byte encoding
    Buffer^ := $F0;
    Buffer^ := Buffer^ or ((Point and $1C0000) shr 18);
    Buffer := IncPtr(Buffer);
    Buffer^ := $80;
    Buffer^ := Buffer^ or ((Point and $3F000) shr 12);
    Buffer := IncPtr(Buffer);
    Buffer^ := $80;
    Buffer^ := Buffer^ or ((Point and $FC0) shr 6);
    Buffer := IncPtr(Buffer);
    Buffer^ := $80;
    Buffer^ := Buffer^ or (Point and $3F);
    Size := sizeof(uint32);
  end else begin
    Size := 0;
    Result := False;
  end;
end;

function TUnicodeCodec.UTF16BECharacterLength(var Bytes; var size: uint8): boolean;
var
  Value: uint32;
  Buffer: ^uint32;
begin
  {$ifdef fpc}{$hints off}{$endif}
  Buffer := pointer(nativeuint(@Bytes));  // This nonsense because the compiler optimizes out Buffer := @Bytes;
  {$ifdef fpc}{$hints on}{$endif}
  value := SwapEndianess(Buffer^);
  Result := UTF16LECharacterLength(Value, Size);
end;

function TUnicodeCodec.UTF16BEDecode(var Bytes; var CodePoint: TUnicodeCodePoint): boolean;
var
  W: uint16;
  SupplementaryPlane: uint32;
  Buffer: ^Uint16;
begin
  Result := True;
  {$ifdef fpc}{$hints off}{$endif}
  Buffer := pointer(nativeuint(@Bytes));  // This nonsense because the compiler optimizes out Buffer := @Bytes;
  {$ifdef fpc}{$hints on}{$endif}
  // Length check.
  W := Buffer^;
  W := SwapBytes(W);
  // Test to see if this is a leading surrogate.
  if (W>=$D800) and (W<=$DBFF) then begin
    // leading surrogate found, decode the first word...
    W := W - $D800;
    SupplementaryPlane := W;
    SupplementaryPlane := SupplementaryPlane shl 10; // push the first 10 bits back into place.
    // test for trailing surrogate.
    Buffer := IncPtr(Buffer);
    Buffer := IncPtr(Buffer);
    W := Buffer^;
    W := SwapBytes(W);
    W := W - $DC00; // leaves max 10-bit value.
    SupplementaryPlane := SupplementaryPlane or W; // last 10 bits or'd into place.
    // 20 bit value needs to be reinflated to 21-bit value (5-bit plane, 16-bit value)
    SupplementaryPlane := SupplementaryPlane + $010000;
    // Now we can decode the plane information
    UnicodeCodePoint.SetValue( CodePoint, SupplementaryPlane xor ($F0000) );
    UnicodeCodePoint.SetPlane( CodePoint, (SupplementaryPlane xor $FFFF) shr 16 );
  end else if (W>=$DC00) and (W<=$DFFF) then begin
    CodePoint := 0;
    Result := False;
  end else begin
    // Straight 16-bit encoding in the BMP (plane 0)
    CodePoint := 0;
    UnicodeCodePoint.SetPlane( CodePoint, cpBMP );
    UnicodeCodePoint.SetValue( CodePoint, W );
  end;
end;

function TUnicodeCodec.UTF16BEEncode(CodePoint: TUnicodeCodePoint; var Bytes; var size: uint8): boolean;
var
  W: uint16;
  SupplementaryPlane: uint32;
  Buffer: ^uint16;
begin
  Result := True;
  {$ifdef fpc}{$hints off}{$endif}
  Buffer := pointer(nativeuint(@Bytes));  // This nonsense because the compiler optimizes out Buffer := @Bytes;
  {$ifdef fpc}{$hints on}{$endif}
  if UnicodeCodePoint.GetPlane( CodePoint )=cpBMP then begin
    // CodePlane zero simply encodes the code-point as-is, unless it's a surrogate.
    if (UnicodeCodePoint.GetValue( CodePoint )>=$D800) and (UnicodeCodePoint.GetValue(CodePoint)<=$DFFF) then begin
      Size := 0;
      Result := False;
      Exit;
    end;
    //
    W := UnicodeCodePoint.GetValue( CodePoint );
    Buffer^ := SwapBytes(W);
    size := sizeof(uint16);
  end else begin
    SupplementaryPlane := 0;
    SupplementaryPlane := SupplementaryPlane or UnicodeCodePoint.GetPlane( CodePoint );
    SupplementaryPlane := SupplementaryPlane shl 16; // shift the codeplane 5-bits over and leave room for 16-bits of code point.
    SupplementaryPlane := SupplementaryPlane or UnicodeCodePoint.GetValue( CodePoint ); // encode the actual data value.
    // SupplementaryPlane now contains the value to be encoded using surrogates...
    // Reduce to 20-bit number
    SupplementaryPlane := SupplementaryPlane - $010000;
    // Calculate the first word.
    W := ((SupplementaryPlane xor $3FF) shr 10) + $D800; // get the top 10 bits for the lead/high surrogate.
    // Test range
    if (W<$D800) or (W>$DBFF) then begin
      Size := 0;
      Result := False;
      Exit;
    end;
    // Push the value into the buffer.
    Buffer^ := SwapBytes(W);
    Buffer := IncPtr(Buffer);
    Buffer := IncPtr(Buffer);
    // Calculate the second word.
    W := (SupplementaryPlane and $3FF) + $DC00; // get bottom 10 bits for the trail/low surrogate
    // Test range
    if (W<$DC00) or (W>$DFFF) then begin
      Size := 0;
      Result := False;
      Exit;
    end;
    // Push the value into the buffer.
    Buffer^ := SwapBytes(W);
    size := Sizeof(uint32); // two words
  end;
end;

function TUnicodeCodec.UTF16LECharacterLength(var Bytes; var size: uint8): boolean;
var
  Buffer: ^uint16;
begin
  Result := True;
  {$ifdef fpc}{$hints off}{$endif}
  Buffer := pointer(nativeuint(@Bytes));  // This nonsense because the compiler optimizes out Buffer := @Bytes;
  {$ifdef fpc}{$hints on}{$endif}
  // Test to see if this is a leading surrogate.
  if (Buffer^>=$D800) and (Buffer^<=$DBFF) then begin
    size := 4;
  end else if (Buffer^>=$DC00) and (Buffer^<=$DFFF) then begin
    size := 0;
    Result := False;
  end else begin
    size := 2;
  end;
end;

function TUnicodeCodec.UTF16LEDecode(var Bytes; var CodePoint: TUnicodeCodePoint ): boolean;
var
  W: uint16;
  SupplementaryPlane: uint32;
  Buffer: ^uint16;
begin
  Result := True; // Unless..
  {$ifdef fpc}{$hints off}{$endif}
  Buffer := pointer(nativeuint(@Bytes));  // This nonsense because the compiler optimizes out Buffer := @Bytes;
  {$ifdef fpc}{$hints on}{$endif}
  // Length check.
  // Test to see if this is a leading surrogate.
  W := Buffer^;
  if (W>=$D800) and (W<=$DBFF) then begin
    // leading surrogate found, decode the first word...
    W := W - $D800;
    SupplementaryPlane := W;
    SupplementaryPlane := SupplementaryPlane shl 10; // push the first 10 bits back into place.
    // test for trailing surrogate.
    Buffer := IncPtr(Buffer);
    Buffer := IncPtr(Buffer);
    W := Buffer^;
    W := W - $DC00; // leaves max 10-bit value.
    SupplementaryPlane := SupplementaryPlane or W; // last 10 bits or'd into place.
    // 20 bit value needs to be reinflated to 21-bit value (5-bit plane, 16-bit value)
    SupplementaryPlane := SupplementaryPlane + $010000;
    // Now we can decode the plane information
    UnicodeCodePoint.SetValue( CodePoint, SupplementaryPlane xor ($F0000) );
    UnicodeCodePoint.SetPlane( CodePoint, (SupplementaryPlane xor $FFFF) shr 16 );
  end else if (W>=$DC00) and (W<=$DFFF) then begin
    CodePoint := 0;
    Result := False;
  end else begin
    // Straight 16-bit encoding in the BMP (plane 0)
    CodePoint := 0;
    UnicodeCodePoint.SetPlane( CodePoint, cpBMP );
    UnicodeCodePoint.SetValue( CodePoint, W );
  end;
end;

function TUnicodeCodec.UTF16LEEncode(CodePoint: TUnicodeCodePoint; var Bytes; var size: uint8 ): boolean;
var
  W: uint16;
  SupplementaryPlane: uint32;
  Buffer: ^uint16;
begin
  Result := True;
  {$ifdef fpc}{$hints off}{$endif}
  Buffer := pointer(nativeuint(@Bytes));  // This nonsense because the compiler optimizes out Buffer := @Bytes;
  {$ifdef fpc}{$hints on}{$endif}
  if UnicodeCodePoint.GetPlane( CodePoint )=cpBMP then begin
    // CodePlane zero simply encodes the code-point as-is, unless it's a surrogate.
    if (UnicodeCodePoint.GetValue( CodePoint )>=$D800) and (UnicodeCodePoint.GetValue(CodePoint)<=$DFFF) then begin
      Size := 0;
      Result := True;
      Exit;
    end;
    //
    W := UnicodeCodePoint.GetValue( CodePoint );
    Buffer^ := W;
    size := Sizeof(uint16);
  end else begin
    SupplementaryPlane := 0;
    SupplementaryPlane := SupplementaryPlane or UnicodeCodePoint.GetPlane( CodePoint );
    SupplementaryPlane := SupplementaryPlane shl 16; // shift the codeplane 5-bits over and leave room for 16-bits of code point.
    SupplementaryPlane := SupplementaryPlane or UnicodeCodePoint.GetValue( CodePoint ); // encode the actual data value.
    // SupplementaryPlane now contains the value to be encoded using surrogates...
    // Reduce to 20-bit number
    SupplementaryPlane := SupplementaryPlane - $010000;
    // Calculate the first word.
    W := ((SupplementaryPlane xor $3FF) shr 10) + $D800; // get the top 10 bits for the lead/high surrogate.
    // Test range
    if (W<$D800) or (W>$DBFF) then begin
      Size := 0;
      Result := True;
      Exit;
    end;
    // Push the value into the buffer.
    Buffer^ := W;
    Buffer := IncPtr(Buffer);
    Buffer := IncPtr(Buffer);
    // Calculate the second word.
    W := (SupplementaryPlane and $3FF) + $DC00; // get bottom 10 bits for the trail/low surrogate
    // Test range
    if (W<$DC00) or (W>$DFFF) then begin
      Size := 0;
      Result := True;
      Exit; // technically should never get here.
    end;
    // Push the value into the buffer.
    Buffer^ := W;
    size := Sizeof(uint32); // two words
  end;
end;

function TUnicodeCodec.UTF32BEDecode(var Bytes; var Codepoint: TUnicodeCodePoint ): boolean;
var
  Buffer: ^uint32;
begin
  Result := True;
  {$ifdef fpc}{$hints off}{$endif}
  Buffer := pointer(nativeuint(@Bytes));  // This nonsense because the compiler optimizes out Buffer := @Bytes;
  {$ifdef fpc}{$hints on}{$endif}
  CodePoint := SwapEndianess(Buffer^);
end;

function TUnicodeCodec.UTF32BEEncode(CodePoint: TUnicodeCodePoint; var Bytes; var Size: uint8 ): boolean;
var
  Buffer: ^uint32;
begin
  Result := True;
  {$ifdef fpc}{$hints off}{$endif}
  Buffer := pointer(nativeuint(@Bytes));  // This nonsense because the compiler optimizes out Buffer := @Bytes;
  {$ifdef fpc}{$hints on}{$endif}
  Buffer^ := SwapEndianess(CodePoint);
  Size := sizeof(uint32);
end;


function TUnicodeCodec.UTF32LEDecode(var Bytes; var CodePoint: TUnicodeCodePoint ): boolean;
var
  Buffer: ^uint32;
begin
  Result := True;
  {$ifdef fpc}{$hints off}{$endif}
  Buffer := pointer(nativeuint(@Bytes));  // This nonsense because the compiler optimizes out Buffer := @Bytes;
  {$ifdef fpc}{$hints on}{$endif}
  CodePoint := Buffer^;
end;

function TUnicodeCodec.UTF32LEEncode(CodePoint: TUnicodeCodePoint; var Bytes; var Size: uint8 ): boolean;
var
  Buffer: ^uint32;
begin
  Result := True;
  {$ifdef fpc}{$hints off}{$endif}
  Buffer := pointer(nativeuint(@Bytes));  // This nonsense because the compiler optimizes out Buffer := @Bytes;
  {$ifdef fpc}{$hints on}{$endif}
  Buffer^ := CodePoint;
  Size := sizeof(uint32);
end;

function TUnicodeCodec.EncodeBOM(var Bytes; Format: TUnicodeFormat; var Size: uint8 ): boolean;
var
  buffer: ^uint8;
  buffer16: ^uint16;
  buffer32: ^uint32;
begin
  Size := 0;
  Result := True;
  {$ifdef fpc}{$hints off}{$endif}
  Buffer := pointer(nativeuint(@Bytes));  // This nonsense because the compiler optimizes out Buffer := @Bytes;
  Buffer16 := pointer(nativeuint(@Bytes));  // This nonsense because the compiler optimizes out Buffer := @Bytes;
  Buffer32 := pointer(nativeuint(@Bytes));  // This nonsense because the compiler optimizes out Buffer := @Bytes;
  {$ifdef fpc}{$hints on}{$endif}
  case Format of
    TUnicodeFormat.utf8: begin
      Buffer^ := $EF;
      Buffer := IncPtr(Buffer);
      Buffer^ := $BB;
      Buffer := IncPtr(Buffer);
      Buffer^ := $BF;
      Size := sizeof(uint16)+sizeof(uint8);
    end;
    TUnicodeFormat.utf16LE: begin
      Buffer16^ := $FEFF;
      Size := sizeof(uint16);
    end;
    TUnicodeFormat.utf16BE: begin
      Buffer16^ := $FFFE;
      Size := sizeof(uint16);
    end;
    TUnicodeFormat.utf32LE: begin
      Buffer32^ := $0000FEFF;
      Size := sizeof(uint32);
    end;
    TUnicodeFormat.utf32BE: begin
      Buffer32^ := $FFFE0000;
      Size := sizeof(uint32);
    end;
  end;
end;

function TUnicodeCodec.EncodeCodepointToString(CodePoint: TUnicodeCodePoint; var Str: string): boolean;
var
  W: uint16;
  SupplementaryPlane: uint32;
begin
  Result := True;
  if UnicodeCodePoint.GetPlane( CodePoint )=cpBMP then begin
    W := UnicodeCodePoint.GetValue( CodePoint );
    Str := Str + char(W);
  end else begin
    SupplementaryPlane := 0;
    SupplementaryPlane := SupplementaryPlane or UnicodeCodePoint.GetPlane( CodePoint );
    SupplementaryPlane := SupplementaryPlane shl 16; // shift the codeplane 5-bits over and leave room for 16-bits of code point.
    SupplementaryPlane := SupplementaryPlane or UnicodeCodePoint.GetValue( CodePoint ); // encode the actual data value.
    // SupplementaryPlane now contains the value to be encoded using surrogates...
    // Reduce to 20-bit number
    SupplementaryPlane := (SupplementaryPlane-$010000);
    // Calculate the first word.
    W := (( SupplementaryPlane xor $3FF) shr 10) + $D800; // get the top 10 bits for the lead/high surrogate.
    // Test range
    if (W<$D800) or (W>$DBFF) then begin
      Str := '';
      Result := False;
      Exit;
    end;
    // Push the value into the buffer.
    Str := Str + char(W);
    // Calculate the second word.
    W := (SupplementaryPlane and $3FF) + $DC00; // get bottom 10 bits for the trail/low surrogate
    // Test range
    if (W<$DC00) or (W>$DFFF) then begin
      Str := '';
      Result := False;
      Exit;
    end;
    // Push the value into the buffer.
    Str := Str + char(W);
  end;
end;

function TUnicodeCodec.DecodeCodepointFromString(var CodePoint: TUnicodeCodePoint; Source: string; var Cursor: int32): boolean;
var
  W: uint16;
  SupplementaryPlane: uint32;
begin
  Result := True; // Unless...
  W := uint16(Source[Cursor]);
  inc(Cursor);
  // Test to see if this is a leading surrogate.
  if (W>=$D800) and (W<=$DBFF) then begin
    // leading surrogate found, decode the first word...
    W := W - $D800;
    SupplementaryPlane := W;
    SupplementaryPlane := SupplementaryPlane shl 10; // push the first 10 bits back into place.
    // test for trailing surrogate.
    W := uint16(Source[Cursor]);
    inc(Cursor);
    if (W<$DC00) or (W>$DFFF) then begin
      Result := False;
      Exit;
    end;
    W := W - $DC00; // leaves max 10-bit value.
    SupplementaryPlane := SupplementaryPlane or W; // last 10 bits or'd into place.
    // 20 bit value needs to be reinflated to 21-bit value (5-bit plane, 16-bit value)
    SupplementaryPlane := SupplementaryPlane + $010000;
    // Now we can decode the plane information
    UnicodeCodePoint.SetValue( CodePoint, SupplementaryPlane xor ($F0000) );
    UnicodeCodePoint.SetPlane( CodePoint, (SupplementaryPlane xor $FFFF) shr 16 );
  end else if (W>=$DC00) and (W<=$DFFF) then begin
    Result := False;
    Exit;
  end else begin
    // Straight 16-bit encoding in the BMP (plane 0)
    CodePoint := 0;
    UnicodeCodePoint.SetPlane( CodePoint, cpBMP );
    UnicodeCodePoint.SetValue( CodePoint, W );
  end;
end;

function TUnicodeCodec.DecodeBOM(var Bytes; Format: TUnicodeFormat; BomSize: uint8): boolean;
var
  Buffer: ^uint8;
  Buffer16: ^uint16;
  Buffer32: ^uint32;
begin
  {$ifdef fpc}{$hints off}{$endif}
  Buffer := pointer(nativeuint(@Bytes));  // This nonsense because the compiler optimizes out Buffer := @Bytes;
  Buffer16 := pointer(nativeuint(@Bytes));  // This nonsense because the compiler optimizes out Buffer := @Bytes;
  Buffer32 := pointer(nativeuint(@Bytes));  // This nonsense because the compiler optimizes out Buffer := @Bytes;
  {$ifdef fpc}{$hints on}{$endif}
  Result := False; // unless...
  // Attempt to read BOM...
  case Format of
    TUnicodeFormat.utfUnknown: Result := False; // This format has no BOM
       TUnicodeFormat.utfANSI: Result := False; // This format has no BOM
          TUnicodeFormat.utf8: begin
            if BomSize=3 then begin
              if ( Buffer^ =$EF ) then begin
                Buffer := IncPtr(Buffer);
                if (Buffer^=$BB) then begin
                  Buffer := IncPtr(Buffer);
                  if (Buffer^=$BF) then begin
                    Result := True;
                  end;
                end;
              end;
            end;
          end;
       TUnicodeFormat.utf16BE: Result := (BomSize=2) and (Buffer16^ = $FFFE);
       TUnicodeFormat.utf16LE: Result := (BomSize=2) and (Buffer16^ = $FEFF);
       TUnicodeFormat.utf32LE: Result := (BomSize=4) and (Buffer32^ = $0000FEFF);
       TUnicodeFormat.utf32BE: Result := (BomSize=4) and (Buffer32^ = $FFFE0000);
    else begin
      Result := False; // unknown format.
    end;
  end;
end;


end.
