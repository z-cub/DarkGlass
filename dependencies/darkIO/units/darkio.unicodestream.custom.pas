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
unit darkio.unicodestream.custom;
{$ifdef fpc} {$mode delphiunicode} {$endif}

interface
uses
  darkUnicode,
  darkio.stream.custom,
  darkio.streams;

type
  /// <summary>
  ///   <para>
  ///     Base class for classes which implement IUnicodeStream.
  ///   </para>
  ///   <para>
  ///     You should not instance this class directly, but rather, derrive
  ///     from it to implement unicode enabled streaming classes.
  ///   </para>
  /// </summary>
  TCustomUnicodeStream = class( TCustomStream, IStream )
  protected
    function ReadBOM( Format: TUnicodeFormat ): boolean;
    procedure WriteBOM( Format: TUnicodeFormat );
    function DetermineUnicodeFormat: TUnicodeFormat;
    procedure WriteString( aString: string; Format: TUnicodeFormat );
    function ReadString( Format: TUnicodeFormat; ZeroTerm: boolean = False; Max: int32 = -1 ): string;
    procedure WriteChar( aChar: char; Format: TUnicodeFormat );
    function ReadChar( Format: TUnicodeFormat ): char;
  public
    property EndOfStream;
    property Position;
    property Size;
  end;

implementation

function TCustomUnicodeStream.DetermineUnicodeFormat: TUnicodeFormat;
begin
  Result := TUnicodeFormat.utfUnknown;
  if ReadBOM(TUnicodeFormat.utf32LE) then begin
    Result := TUnicodeFormat.utf32LE;
  end else if ReadBOM(TUnicodeFormat.utf32BE) then begin
    Result := TUnicodeFormat.utf32BE;
  end else if ReadBOM(TUnicodeFormat.utf16LE) then begin
    Result := TUnicodeFormat.utf16LE
  end else if ReadBOM(TUnicodeFormat.utf16BE) then begin
    Result := TUnicodeFormat.utf16BE;
  end else if ReadBOM(TUnicodeFormat.utf8) then begin
    Result := TUnicodeFormat.utf8;
  end;
end;

function TCustomUnicodeStream.ReadBOM(Format: TUnicodeFormat): boolean;
var
  p: uint64;
  BomSize: uint8;
  Buffer32: uint32;
  Buffer16: uint16;
begin
  Result := False;
  Buffer16 := 0;
  Buffer32 := 0;
  P := Self.Position;
  try
    BomSize := 0;
    // Determine BOM size.
    case Format of
      TUnicodeFormat.utfUnknown: BomSize := 0;
         TUnicodeFormat.utfANSI: BomSize := 0;
            TUnicodeFormat.utf8: BomSize := 3;
         TUnicodeFormat.utf16LE: BomSize := 2;
         TUnicodeFormat.utf16BE: BomSize := 2;
         TUnicodeFormat.utf32LE: BomSize := 4;
         TUnicodeFormat.utf32BE: BomSize := 4;
    end;
    if BomSize>0 then begin
      if BomSize>2 then begin
        if Read(@Buffer32,BOMSize)=BOMSize then begin
          Result := Unicode.DecodeBOM(Buffer32,Format,BOMSize);
        end;
      end else begin
        Read(@Buffer16,BomSize);
        Result := Unicode.DecodeBOM(Buffer16,Format,BomSize);
      end;
    end;
  finally
    if not Result then begin
      Self.Position := P;
    end;
  end;
end;

function TCustomUnicodeStream.ReadString(Format: TUnicodeFormat; ZeroTerm: boolean = False; Max: int32 = -1): string;
var
  count: int32;
  CP: uint32;
  bytecount: uint8;
  Buffer: uint64;
  BufferPtr: pointer;
begin
  Result := '';
  CP := 0;
  ByteCount := 0;
  if Format<>TUnicodeFormat.utfUnknown then begin
    count := 0;
    while ((not getEndOfStream) and (Max<0)) or ((Max>=0) and (count<Max)) do begin
      BufferPtr := @Buffer;
      // decode a codepoint
      case Format of

        TUnicodeFormat.utfANSI: begin
          Read(BufferPtr,sizeof(uint8));
          Unicode.AnsiDecode(Buffer,CP);
        end;

        TUnicodeFormat.utf8: begin
          Read(BufferPtr,sizeof(uint8));
          Unicode.UTF8CharacterLength(Buffer, bytecount);
          if bytecount>1 then begin
            {$ifdef fpc} {$hints off} {$endif}
            BufferPtr := pointer(nativeuint(BufferPtr) + sizeof(uint8));
            {$ifdef fpc} {$hints on} {$endif}
            Read(BufferPtr,pred(bytecount));
          end;
          Unicode.UTF8Decode(Buffer,CP);
        end;

        TUnicodeFormat.utf16LE: begin
          Read(BufferPtr,sizeof(uint16));
          Unicode.UTF16LECharacterLength(Buffer, bytecount);
          if bytecount>2 then begin
            {$ifdef fpc} {$hints off} {$endif}
            BufferPtr := pointer(nativeuint(BufferPtr) + sizeof(uint16));
            {$ifdef fpc} {$hints on} {$endif}
            Read(BufferPtr,sizeof(uint16)); // read the extra 2
          end;
          Unicode.UTF16LEDecode(Buffer,CP);
        end;

        TUnicodeFormat.utf16BE: begin
          Read(BufferPtr,sizeof(uint16));
          Unicode.UTF16BECharacterLength(Buffer,bytecount);
          if bytecount>2 then begin
            {$ifdef fpc} {$hints off} {$endif}
            BufferPtr := pointer(nativeuint(BufferPtr) + sizeof(uint16));
            {$ifdef fpc} {$hints on} {$endif}
            Read(BufferPtr,sizeof(uint16)); // read the extra 2
          end;
          Unicode.UTF16BEDecode(Buffer,CP);
        end;

        TUnicodeFormat.utf32LE: begin
          Read(BufferPtr,Sizeof(uint32));
          Unicode.UTF32LEDecode(Buffer,CP);
        end;

        TUnicodeFormat.utf32BE: begin
          Read(BufferPtr,Sizeof(uint32));
          Unicode.UTF32BEDecode(Buffer,CP);
        end;

      end;
      // Check for zero terminator
      if (CP=0) and (ZeroTerm) then begin
        Exit;
      end;
      // add the codepoint to the string
      Unicode.EncodeCodepointToString(CP,Result);
      inc(count);
    end;
  end;
end;

procedure TCustomUnicodeStream.WriteChar(aChar: char; Format: TUnicodeFormat);
var
  Cursor: int32;
  Buffer: uint64;
  CP: uint32;
  L: uint8;
  aString: string;
begin
  aString := ''+aChar;
  Cursor := 1;
  // decode a character
  CP := 0;
  L := 0;
  Unicode.DecodeCodepointFromString(CP,aString,Cursor);
  {$HINTS OFF} // Compiler complains the buffer is uninitialized
    case Format of
      TUnicodeFormat.utfANSI: Unicode.ANSIEncode(CP,Buffer,L);
      TUnicodeFormat.utf8:    Unicode.UTF8Encode(CP,Buffer,L);
      TUnicodeFormat.utf16LE: Unicode.UTF16LEEncode(CP,Buffer,L);
      TUnicodeFormat.utf16BE: Unicode.UTF16BEEncode(CP,Buffer,L);
      TUnicodeFormat.utf32LE: Unicode.UTF32LEEncode(CP,Buffer,L);
      TUnicodeFormat.utf32BE: Unicode.UTF32BEEncode(CP,Buffer,L);
    end;
  {$HINTS ON}
  Self.Write(@Buffer,L);
end;

function TCustomUnicodeStream.ReadChar(Format: TUnicodeFormat): char;
var
  CP: uint32;
  bytecount: uint8;
  Buffer: uint64;
  BufferPtr: pointer;
  aString: string;
begin
  CP := 0;
  Result := chr($0);
  ByteCount := 0;
  if Format<>TUnicodeFormat.utfUnknown then begin
    if (not getEndOfStream) then begin
      BufferPtr := @Buffer;
      // decode a codepoint
      case Format of

        TUnicodeFormat.utfANSI: begin
          Read(BufferPtr,sizeof(uint8));
          Unicode.AnsiDecode(Buffer,CP);
        end;

        TUnicodeFormat.utf8: begin
          Read(BufferPtr,sizeof(uint8));
          Unicode.UTF8CharacterLength(Buffer, bytecount);
          if bytecount>1 then begin
            {$ifdef fpc} {$hints off} {$endif}
            BufferPtr := pointer(nativeuint(BufferPtr) + sizeof(uint8));
            {$ifdef fpc} {$hints on} {$endif}
            Read(BufferPtr,pred(bytecount));
          end;
          Unicode.UTF8Decode(Buffer,CP);
        end;

        TUnicodeFormat.utf16LE: begin
          Read(BufferPtr,sizeof(uint16));
          Unicode.UTF16LECharacterLength(Buffer, bytecount);
          if bytecount>2 then begin
            {$ifdef fpc} {$hints off} {$endif}
            BufferPtr := pointer(nativeuint(BufferPtr) + sizeof(uint16));
            {$ifdef fpc} {$hints on} {$endif}
            Read(BufferPtr,sizeof(uint16)); // read the extra 2
          end;
          Unicode.UTF16LEDecode(Buffer,CP);
        end;

        TUnicodeFormat.utf16BE: begin
          Read(BufferPtr,sizeof(uint16));
          Unicode.UTF16BECharacterLength(Buffer,bytecount);
          if bytecount>2 then begin
            {$ifdef fpc} {$hints off} {$endif}
            BufferPtr := pointer(nativeuint(BufferPtr) + sizeof(uint16));
            {$ifdef fpc} {$hints on} {$endif}
            Read(BufferPtr,sizeof(uint16)); // read the extra 2
          end;
          Unicode.UTF16BEDecode(Buffer,CP);
        end;

        TUnicodeFormat.utf32LE: begin
          Read(BufferPtr,Sizeof(uint32));
          Unicode.UTF32LEDecode(Buffer,CP);
        end;

        TUnicodeFormat.utf32BE: begin
          Read(BufferPtr,Sizeof(uint32));
          Unicode.UTF32BEDecode(Buffer,CP);
        end;
      end;
      // add the codepoint to the string
      aString := '';
      Unicode.EncodeCodepointToString(CP,aString);
      {$ifdef NEXTGEN}
        {$ifndef Linux} //- Doesn't make sense that Linux compiler is not zero-based, despite being nextgen
          result := aString[0];
        {$else}
          result := aString[1];
        {$endif}
      {$else}
      result := aString[1];
      {$endif}
    end;
  end;
end;

procedure TCustomUnicodeStream.WriteBOM(Format: TUnicodeFormat);
var
  Buffer: uint64;
  L: uint8;
begin
  {$HINTS OFF} // compiler complains that Buffer is uninitialized.
    Unicode.EncodeBOM(Buffer,Format,L);
  {$HINTS ON}
  Self.Write(@Buffer,L);
end;

procedure TCustomUnicodeStream.WriteString(aString: string; Format: TUnicodeFormat);
var
  Cursor: int32;
  Buffer: uint64;
  CP: uint32;
  L: uint8;
begin
  Cursor := 1;
  // decode a character
    while (Cursor<=Length(aString)) do begin
      CP := 0;
      L := 0;
      Unicode.DecodeCodepointFromString(CP,aString,Cursor);
      Buffer := 0;
      {$HINTS OFF} // Compiler complains the buffer is uninitialized
        case Format of
          TUnicodeFormat.utfANSI: Unicode.ANSIEncode(CP,Buffer,L);
          TUnicodeFormat.utf8:    Unicode.UTF8Encode(CP,Buffer,L);
          TUnicodeFormat.utf16LE: Unicode.UTF16LEEncode(CP,Buffer,L);
          TUnicodeFormat.utf16BE: Unicode.UTF16BEEncode(CP,Buffer,L);
          TUnicodeFormat.utf32LE: Unicode.UTF32LEEncode(CP,Buffer,L);
          TUnicodeFormat.utf32BE: Unicode.UTF32BEEncode(CP,Buffer,L);
        end;
      {$HINTS ON}
      Self.Write(@Buffer,L);
    end;
end;



end.


