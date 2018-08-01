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
/// <summary>
///   Provides the types required for working with the unicode codec.
/// </summary>
unit darkUnicode;
{$ifdef fpc} {$mode objfpc} {$endif}

interface

type
  /// <summary>
  ///   Specifies a supported unicode text format.
  /// </summary>
  TUnicodeFormat = (
    /// <summary>
    ///   An undetermined text format.
    /// </summary>
    utfUnknown,
    /// <summary>
    ///   Ansi format (UTF-8 compatible)
    /// </summary>
    utfANSI,
    /// <summary>
    ///   UTF-8
    /// </summary>
    utf8,
    /// <summary>
    ///   UTF-16 Little Endian
    /// </summary>
    utf16LE,
    /// <summary>
    ///   UTF-16 Big Endian
    /// </summary>
    utf16BE,
    /// <summary>
    ///   UTF-32 Little Endian
    /// </summary>
    utf32LE,
    /// <summary>
    ///   UTF-32 Big Endian
    /// </summary>
    utf32BE );

   /// <summary>
   ///   Canonical representation of a code point, will never exceed 32-bits.
   /// </summary>
   TUnicodeCodePoint = uint32;

type

  /// <summary>
  ///   An implementation of IUnicodeCodec provides routines for encoding and
  ///   decoding unicode code-points.
  /// </summary>
  IUnicodeCodec = interface
    ['{FDE5359D-9C06-4559-A99A-7D5DA94FEB07}']

    /// <summary>
    ///   Appends a given code-point to the end of the string.
    /// </summary>
    /// <param name="CodePoint">
    ///   The unicode code-point to be appended to the string.
    /// </param>
    /// <param name="Str">
    ///   A string parameter (passed by reference) which will be appended with
    ///   the new unicode code-point.
    /// </param>
    /// <returns>
    ///   Returns true if the operation completed successfully, otherwise
    ///   false. A false return value here is an encoding failure, the
    ///   code-point value may be outside the accepted range.
    /// </returns>
    function EncodeCodepointToString(CodePoint: TUnicodeCodePoint; var Str: string): boolean;


    /// <summary>
    ///   Decodes a single character from the string as a code-point.
    /// </summary>
    /// <param name="CodePoint">
    ///   A variable passed by reference, to receive the code-point.
    /// </param>
    /// <param name="Source">
    ///   The source string from which to extract a code-point.
    /// </param>
    /// <param name="Cursor">
    ///   The index of the character within the string to decode. On NextGen
    ///   platforms, this cursor is indexed from zero, but for desktop
    ///   platforms it remains indexed from one.
    /// </param>
    /// <returns>
    ///   Returns true if the code point was decoded, otherwise false. A False
    ///   return is likely to be an out-of-bounds cursor.
    /// </returns>
    function DecodeCodepointFromString(var CodePoint: TUnicodeCodePoint; Source: string; var Cursor: int32): boolean;


    /// <summary>
    ///   Determines the length (in bytes) of a UTF-8 code-point.
    /// </summary>
    /// <param name="Bytes">
    ///   A buffer containing the character to be measured. (Can be a
    ///   dereferened pointer into a buffer of code points.
    /// </param>
    /// <param name="size">
    ///   Pass an int32 to be populated with the number of bytes.
    /// </param>
    /// <returns>
    ///   Retrns true if the operation was successful. If unsuccessful, the
    ///   character buffer likely contained an invalid code-point.
    /// </returns>
    function UTF8CharacterLength(var Bytes; var size: uint8): boolean;

    /// <summary>
    ///   Determines the length (in bytes) of a UTF-16LE code-point.
    /// </summary>
    /// <param name="Bytes">
    ///   A buffer containing the character to be measured. (Can be a
    ///   dereferened pointer into a buffer of code points.
    /// </param>
    /// <param name="size">
    ///   Pass an int32 to be populated with the number of bytes.
    /// </param>
    /// <returns>
    ///   Retrns true if the operation was successful. If unsuccessful, the
    ///   character buffer likely contained an invalid code-point.
    /// </returns>
    function UTF16LECharacterLength(var Bytes; var size: uint8): boolean;

    /// <summary>
    ///   Determines the length (in bytes) of a UTF-16BE code-point.
    /// </summary>
    /// <param name="Bytes">
    ///   A buffer containing the character to be measured. (Can be a
    ///   dereferened pointer into a buffer of code points.
    /// </param>
    /// <param name="size">
    ///   Pass an int32 to be populated with the number of bytes.
    /// </param>
    /// <returns>
    ///   Retrns true if the operation was successful. If unsuccessful, the
    ///   character buffer likely contained an invalid code-point.
    /// </returns>
    function UTF16BECharacterLength(var Bytes; var size: uint8): boolean;


    /// <summary>
    ///   Decodes a unicode UTF-8 code-point.
    /// </summary>
    /// <param name="Bytes">
    ///   A buffer containing the character to be decoded. (Can be a
    ///   dereferened pointer into a buffer of code points.
    /// </param>
    /// <param name="CodePoint">
    ///   A code-point passed by reference to receive the decoded value.
    /// </param>
    /// <returns>
    ///   Returns true if successful. If unsuccessful, it is likely the
    ///   code-point in the bytes parameter is invalid.
    /// </returns>
    function UTF8Decode(var Bytes; var CodePoint: TUnicodeCodePoint): boolean;

    /// <summary>
    ///   Decodes a unicode UTF-16LE code-point.
    /// </summary>
    /// <param name="Bytes">
    ///   A buffer containing the character to be decoded. (Can be a
    ///   dereferened pointer into a buffer of code points.
    /// </param>
    /// <param name="CodePoint">
    ///   A code-point passed by reference to receive the decoded value.
    /// </param>
    /// <returns>
    ///   Returns true if successful. If unsuccessful, it is likely the
    ///   code-point in the bytes parameter is invalid.
    /// </returns>
    function UTF16LEDecode(var Bytes; var CodePoint: TUnicodeCodePoint ): boolean;

    /// <summary>
    ///   Decodes a unicode UTF-16BE code-point.
    /// </summary>
    /// <param name="Bytes">
    ///   A buffer containing the character to be decoded. (Can be a
    ///   dereferened pointer into a buffer of code points.
    /// </param>
    /// <param name="CodePoint">
    ///   A code-point passed by reference to receive the decoded value.
    /// </param>
    /// <returns>
    ///   Returns true if successful. If unsuccessful, it is likely the
    ///   code-point in the bytes parameter is invalid.
    /// </returns>
    function UTF16BEDecode(var Bytes; var CodePoint: TUnicodeCodePoint): boolean;

    /// <summary>
    ///   Decodes a unicode UTF-32LE code-point.
    /// </summary>
    /// <param name="Bytes">
    ///   A buffer containing the character to be decoded. (Can be a
    ///   dereferened pointer into a buffer of code points.
    /// </param>
    /// <param name="CodePoint">
    ///   A code-point passed by reference to receive the decoded value.
    /// </param>
    /// <returns>
    ///   Returns true if successful. If unsuccessful, it is likely the
    ///   code-point in the bytes parameter is invalid.
    /// </returns>
    /// <remarks>
    ///   For Little Endian targets, this method may be irrelevant as the
    ///   code-point data is not encoded. However, it does provide a consistent
    ///   interface across Little Endian and Big Endian targets.
    /// </remarks>
    function UTF32LEDecode(var Bytes; var CodePoint: TUnicodeCodePoint): boolean;

    /// <summary>
    ///   Decodes a unicode UTF-32BE code-point.
    /// </summary>
    /// <param name="Bytes">
    ///   A buffer containing the character to be decoded. (Can be a
    ///   dereferened pointer into a buffer of code points.
    /// </param>
    /// <param name="CodePoint">
    ///   A code-point passed by reference to receive the decoded value.
    /// </param>
    /// <returns>
    ///   Returns true if successful. If unsuccessful, it is likely the
    ///   code-point in the bytes parameter is invalid.
    /// </returns>
    /// <remarks>
    ///   For Big Endian targets, this method may be irrelevant as the
    ///   code-point data is not encoded. However, it does provide a consistent
    ///   interface across Little Endian and Big Endian targets.
    /// </remarks>
    function UTF32BEDecode(var Bytes; var CodePoint: TUnicodeCodePoint): boolean;

    /// <summary>
    ///   Decodes an ANSI character as a code-point.
    /// </summary>
    /// <param name="Bytes">
    ///   A buffer containing the character to be decoded. (Can be a
    ///   dereferened pointer into a buffer of code points.
    /// </param>
    /// <param name="CodePoint">
    ///   A code-point passed by reference to receive the decoded value.
    /// </param>
    /// <returns>
    ///   Returns true if successful. If unsuccessful, it is likely the
    ///   code-point in the bytes parameter is invalid.
    /// </returns>
    /// <remarks>
    ///   The decoded value is simply a 32-bit representation of the first byte
    ///   passed in the 'byte' paramter.
    /// </remarks>
    function AnsiDecode(var Bytes; var CodePoint: TUnicodeCodePoint): boolean;

    /// <summary>
    ///   Encodes a UTF-8 code-point.
    /// </summary>
    /// <param name="CodePoint">
    ///   The code point to be encoded.
    /// </param>
    /// <param name="Bytes">
    ///   A buffer to store the resulting encoded data into.
    /// </param>
    /// <param name="Size">
    ///   Is populated with the size of the code-point after encoding, in
    ///   bytes.
    /// </param>
    /// <returns>
    ///   Returns true if successful. If unsuccessful, it is likely the
    ///   code-point is not a valid unicode code-point.
    /// </returns>
    function UTF8Encode(CodePoint: TUnicodeCodePoint; var Bytes; var Size: uint8): boolean;

    /// <summary>
    ///   Encodes a UTF-16LE code-point.
    /// </summary>
    /// <param name="CodePoint">
    ///   The code point to be encoded.
    /// </param>
    /// <param name="Bytes">
    ///   A buffer to store the resulting encoded data into.
    /// </param>
    /// <param name="size">
    ///   Is populated with the size of the code-point after encoding, in
    ///   bytes.
    /// </param>
    /// <returns>
    ///   Returns true if successful. If unsuccessful, it is likely the
    ///   code-point is not a valid unicode code-point.
    /// </returns>
    function UTF16LEEncode(CodePoint: TUnicodeCodePoint; var Bytes; var size: uint8 ): boolean;

    /// <summary>
    ///   Encodes a UTF-16BE code-point.
    /// </summary>
    /// <param name="CodePoint">
    ///   The code point to be encoded.
    /// </param>
    /// <param name="Bytes">
    ///   A buffer to store the resulting encoded data into.
    /// </param>
    /// <param name="size">
    ///   Is populated with the size of the code-point after encoding, in
    ///   bytes.
    /// </param>
    /// <returns>
    ///   Returns true if successful. If unsuccessful, it is likely the
    ///   code-point is not a valid unicode code-point.
    /// </returns>
    function UTF16BEEncode(CodePoint: TUnicodeCodePoint; var Bytes; var size: uint8): boolean;

    /// <summary>
    ///   Encodes a UTF-32LE code-point.
    /// </summary>
    /// <param name="CodePoint">
    ///   The code point to be encoded.
    /// </param>
    /// <param name="Bytes">
    ///   A buffer to store the resulting encoded data into.
    /// </param>
    /// <param name="size">
    ///   Is populated with the size of the code-point after encoding, in
    ///   bytes.
    /// </param>
    /// <returns>
    ///   Returns true if successful. If unsuccessful, it is likely the
    ///   code-point is not a valid unicode code-point.
    /// </returns>
    function UTF32LEEncode(CodePoint: TUnicodeCodePoint; var Bytes; var size: uint8): boolean;

    /// <summary>
    ///   Encodes a UTF-32BE code-point.
    /// </summary>
    /// <param name="CodePoint">
    ///   The code point to be encoded.
    /// </param>
    /// <param name="Bytes">
    ///   A buffer to store the resulting encoded data into.
    /// </param>
    /// <param name="size">
    ///   Is populated with the size of the code-point after encoding, in
    ///   bytes.
    /// </param>
    /// <returns>
    ///   Returns true if successful. If unsuccessful, it is likely the
    ///   code-point is not a valid unicode code-point.
    /// </returns>
    function UTF32BEEncode(CodePoint: TUnicodeCodePoint; var Bytes; var size: uint8): boolean;

    /// <summary>
    ///   Encodes an code-point as an ANSI character. The code-point must match
    ///   an ANSI character in order to be valid.
    /// </summary>
    /// <param name="CodePoint">
    ///   The code point to be encoded.
    /// </param>
    /// <param name="Bytes">
    ///   A buffer to store the resulting encoded data into.
    /// </param>
    /// <param name="size">
    ///   Is populated with the size of the code-point after encoding, in
    ///   bytes.
    /// </param>
    /// <returns>
    ///   Returns true if successful. If unsuccessful, it is likely the
    ///   code-point is not a valid unicode code-point.
    /// </returns>
    function AnsiEncode(CodePoint: TUnicodeCodePoint; var Bytes; var size: uint8): boolean;


    /// <summary>
    ///   Detects a BOM (byte-order-mark).
    /// </summary>
    /// <param name="Bytes">
    ///   A buffer containing the bytes to decode as a BOM.
    /// </param>
    /// <param name="Format">
    ///   The expected unicode format for the BOM.
    /// </param>
    /// <param name="BomSize">
    ///   The size of the BOM in bytes to be decoded.
    /// </param>
    /// <returns>
    ///   Returns true if the BOM contained in the bytes parameter matches the
    ///   specified unicode format in the Format parameter. Otherwise returns
    ///   false.
    /// </returns>
    function DecodeBOM(var Bytes; Format: TUnicodeFormat; BomSize: uint8): boolean;

    /// <summary>
    ///   Encodes a BOM (Byte-Order-Mark).
    /// </summary>
    /// <param name="Bytes">
    ///   A buffer passed by reference to encode the BOM into.
    /// </param>
    /// <param name="Format">
    ///   The unicode format for which a BOM is required.
    /// </param>
    /// <param name="size">
    ///   A uint8 passed by reference, will be populated with the size of the
    ///   BOM in bytes.
    /// </param>
    function EncodeBOM(var Bytes; Format: TUnicodeFormat; var size: uint8): boolean;
  end;

function Unicode: IUnicodeCodec;

implementation
uses
  darkUnicode.codec.standard;

var
  /// <exclude />
  SingletonUnicodeCodec: IUnicodeCodec = nil;

function Unicode: IUnicodeCodec;
begin
  if not assigned(SingletonUnicodeCodec) then begin
    SingletonUnicodeCodec := TUnicodeCodec.Create;
  end;
  Result := SingletonUnicodeCodec;
end;

initialization
  SingletonUnicodeCodec := nil;

finalization
  SingletonUnicodeCodec := nil;

end.
