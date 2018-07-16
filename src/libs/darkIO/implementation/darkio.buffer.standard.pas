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
unit darkio.buffer.standard;

interface
uses
  darkUnicode,
  darkio.streams,
  darkio.buffers;

type
  /// <summary>
  ///   An implementation of IdeBuffer, which allocates and manages a buffer of
  ///   memory on the heap.
  /// </summary>
  TBuffer = class( TInterfacedObject, IBuffer, IUnicodeBuffer )
  private
    fData: pointer;
    fSize: nativeuint;
  private  //- IBuffer -//
    procedure FillMem( value: uint8 );
    function LoadFromStream( Stream: IStream; Bytes: uint32 ): uint32;
    function SaveToStream( Stream: IStream; Bytes: uint32 ): uint32;
    procedure Assign( Buffer: IBuffer );
    procedure InsertData( Buffer: Pointer; Offset: uint32; Bytes: uint32 );
    function AppendData( Buffer: Pointer; Bytes: uint32 ): pointer;
    procedure ExtractData( Buffer: Pointer; Offset: uint32; Bytes: uint32 );
    function getDataPointer: pointer;
    function getSize: uint32;
    function getByte( idx: uint32 ): uint8;
    procedure setByte( idx: uint32; value: uint8 );
    procedure setSize( aSize: uint32 );
  private //- IUnicodeBuffer -//
    function ReadBOM( Format: TUnicodeFormat ): boolean;
    procedure WriteBOM( Format: TUnicodeFormat );
    function DetermineUnicodeFormat: TUnicodeFormat;
    function WriteString(aString: string; Format: TUnicodeFormat): uint32;
    function ReadString( Format: TUnicodeFormat; ZeroTerm: boolean = False; Max: int32 = -1 ): string;
    function getAsString: string;
    procedure setAsString( value: string );
    procedure AllocateBuffer( NewSize: uint32 );
    procedure DeallocateBuffer;
    procedure ResizeBuffer( NewSize: uint32 );
  public
    constructor Create( aSize: uint32 = 0 ); reintroduce;
    destructor Destroy; override;
  end;

implementation

procedure TBuffer.AllocateBuffer(NewSize: uint32);
begin
  if (fSize>0) then begin
    DeallocateBuffer;
  end;
  if NewSize>0 then begin
    fSize := NewSize;
    GetMem(fData,fSize);
  end;
end;

procedure TBuffer.DeallocateBuffer;
begin
  if (fSize>0) then begin
    if assigned(fData) then begin
      FreeMem(fData);
    end;
    fSize := 0;
    fData := nil;
  end;
end;

function TBuffer.GetDataPointer: pointer;
begin
  Result := fData;
end;

function TBuffer.GetSize: uint32;
begin
  Result := fSize;
end;

function TBuffer.ReadBOM(Format: TUnicodeFormat): boolean;
var
  BomSize: uint8;
begin
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
    Result := Unicode.DecodeBOM(fData^,Format,BomSize);
  end else begin
    Result := False;
  end;
end;

function TBuffer.ReadString(Format: TUnicodeFormat; ZeroTerm: boolean; Max: int32): string;
var
  TotalSize: uint32;
  bytecount: uint8;
  ptr: pointer;
  CH: uint32;
  CP: TUnicodeCodePoint;
  S: string;
  StopOnError: boolean;
begin
  CH:=0;
  if fSize=0 then begin
    Result := '';
    Exit;
  end;
  // This must happen one 'character' (code-point) at a time.
  S := '';
  bytecount := 0;
  CP := 0;
  TotalSize := 0;
  ptr := fData;
  StopOnError := False;
  while (TotalSize<GetSize) and ((Max<0) or (Length(S)<Max)) and (not StopOnError) do begin
    // decode the character from the buffer.
    Move(ptr^,CH,sizeof(CH));
    case Format of
      TUnicodeFormat.utfANSI: begin
        bytecount := sizeof(uint8);
        if not Unicode.AnsiDecode(CH,CP) then begin
          StopOnError := True;
          Continue;
        end;
      end;
      TUnicodeFormat.utf8: begin
        if Unicode.UTF8CharacterLength(CH, bytecount) then begin
          if not Unicode.UTF8Decode(CH, CP) then begin
            StopOnError := True;
            Continue;
          end;
          end else begin
            StopOnError := True;
            Continue;
          end;
      end;
      TUnicodeFormat.utf16LE: begin
        if Unicode.UTF16LECharacterLength(CH, bytecount) then begin
          if not Unicode.UTF16LEDecode(CH, CP) then begin
            StopOnError := True;
            Continue;
          end;
        end else begin
          StopOnError := True;
          Continue;
        end;
      end;
      TUnicodeFormat.utf16BE: begin
        if Unicode.UTF16BECharacterLength(CH,bytecount) then begin
          if not Unicode.UTF16BEDecode(CH, CP) then begin
            StopOnError := True;
            Continue;
          end;
        end else begin
          StopOnError := True;
          Continue;
        end;
      end;
      TUnicodeFormat.utf32LE: begin
        bytecount := sizeof(uint32);
        if not Unicode.UTF32LEDecode(CH, CP) then begin
          StopOnError := True;
          Continue;
        end;
      end;
      TUnicodeFormat.utf32BE: begin
        bytecount := sizeof(uint32);
        if not Unicode.UTF32BEDecode(CH,CP) then begin
          StopOnError := True;
          Continue;
        end;
      end;
    end;
    if (CP=0) and (ZeroTerm) then begin
      Break; // drop the loop
    end;
    Unicode.EncodeCodepointToString(CP,S);
    {$ifdef fpc} {$hints off} {$endif}
    ptr := pointer(nativeuint(ptr)+bytecount);
    {$ifdef fpc} {$hints on} {$endif}
    TotalSize := TotalSize + bytecount;
  end;
  Result := S;
end;

procedure TBuffer.ResizeBuffer(NewSize: uint32);
var
  fNewBuffer: pointer;
begin
  if NewSize=fSize then begin
    Exit;
  end else if fSize=0 then begin
    AllocateBuffer(NewSize);
  end else if NewSize=0 then begin
  	DeallocateBuffer;
  end else begin
    // Create the new buffer and copy old data to it.
    GetMem(fNewBuffer,NewSize);
    FillChar(fNewBuffer^,NewSize,0);
    if NewSize>fSize then begin
    	Move(fData^,fNewBuffer^,fSize);
    end else begin
      Move(fData^,fNewBuffer^,NewSize);
    end;
    DeallocateBuffer;
    fData := fNewBuffer;
    fSize := NewSize;
  end;
end;

procedure TBuffer.setAsString(value: string);
begin
  SetSize( Length(value) * 4 ); // max length of utf16 character is 32-bit, therefore 4-bytes, 4*characters in string should be sufficient.
  SetSize( WriteString(value,TUnicodeFormat.utf16LE) );
end;

procedure TBuffer.setByte(idx: uint32; value: uint8);
var
  ptr: ^uint8;
begin
  if (idx<fSize) then begin
    {$ifdef fpc} {$hints off} {$endif}
    ptr := pointer(nativeuint(fData)+idx);
    {$ifdef fpc} {$hints on} {$endif}
    ptr^ := value;
  end;
end;

function TBuffer.LoadFromStream(Stream: IStream; Bytes: uint32): uint32;
begin
  if getSize<=Bytes then begin
    Stream.Read(getDataPointer,getSize);
    Result := getSize;
  end else begin
    Stream.Read(getDataPointer,Bytes);
    Result := Bytes;
  end;
end;

function TBuffer.SaveToStream(Stream: IStream; Bytes: uint32): uint32;
begin
  if Bytes>getSize then begin
    Stream.Write(getDataPointer,getSize);
    Result := getSize;
  end else begin
    Stream.Write(getDataPointer,Bytes);
    Result := Bytes;
  end;
end;

procedure TBuffer.setSize( aSize: uint32 );
begin
  if fSize=aSize then Exit;
  ResizeBuffer(aSize);
end;

procedure TBuffer.WriteBOM(Format: TUnicodeFormat);
var
  size: uint8;
begin
  size := 0;
  Unicode.EncodeBOM(fData^,Format,size);
end;

function TBuffer.WriteString(aString: string; Format: TUnicodeFormat): uint32;
var
  ptr: ^char;
  CH: uint32;
  StrLen: int32;
  CP: TUnicodeCodepoint;
  Cursor: int32;
  L: uint8;
begin
  CP := 0;
  CH := 0;
  Result := 0;
  // Loop each character
  {$ifdef NEXTGEN}
  StrLen := Pred(Length(aString));
  {$else}
  StrLen := Length(aString);
  {$endif}
  //- Pass one, measure string length.
  {$ifdef NEXTGEN}
  Cursor := 0;
  {$else}
  Cursor := 1;
  {$endif}
  //- Pass one, measure string length.
  while (Cursor<=StrLen) do begin
    Unicode.DecodeCodepointFromString(CP,aString,Cursor);
    case Format of
      TUnicodeFormat.utfANSI: L := 1;
         TUnicodeFormat.utf8: Unicode.UTF8Encode(CP,CH,L);
      TUnicodeFormat.utf16LE: Unicode.UTF16LEEncode(CP,CH,L);
      TUnicodeFormat.utf16BE: Unicode.UTF16BEEncode(CP,CH,L);
      TUnicodeFormat.utf32LE: Unicode.UTF32LEEncode(CP,CH,L);
      TUnicodeFormat.utf32BE: Unicode.UTF32BEEncode(CP,CH,L);
    end;
    Result := Result + L;
  end;
  //- Set buffer size.
  Self.AllocateBuffer(Result);
  //- Pass two, put data into buffer
  {$ifdef NEXTGEN}
  Cursor := 0;
  {$else}
  Cursor := 1;
  {$endif}
  ptr := fData;
  while (Cursor<=StrLen) do begin
    Unicode.DecodeCodepointFromString(CP,aString,Cursor);
    case Format of
      TUnicodeFormat.utfANSI: Unicode.ANSIEncode(CP,CH,L);
         TUnicodeFormat.utf8: Unicode.UTF8Encode(CP,CH,L);
      TUnicodeFormat.utf16LE: Unicode.UTF16LEEncode(CP,CH,L);
      TUnicodeFormat.utf16BE: Unicode.UTF16BEEncode(CP,CH,L);
      TUnicodeFormat.utf32LE: Unicode.UTF32LEEncode(CP,CH,L);
      TUnicodeFormat.utf32BE: Unicode.UTF32BEEncode(CP,CH,L);
    end;
    Move(CH,ptr^,L);
    {$ifdef fpc} {$hints off} {$endif}
    ptr := pointer(nativeuint(pointer(Ptr)) + L);
    {$ifdef fpc} {$hints on} {$endif}
  end;
end;

constructor TBuffer.Create( aSize: uint32 = 0 );
begin
  inherited Create;
  fData := nil;
  fSize := aSize;
  //- Dependencies
  //- Allocate an initial amount.
  AllocateBuffer(fSize);
end;

destructor TBuffer.Destroy;
begin
  DeallocateBuffer;
  inherited Destroy;
end;

function TBuffer.DetermineUnicodeFormat: TUnicodeFormat;
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

procedure TBuffer.Assign(Buffer: IBuffer);
begin
  if Buffer.Size=0 then begin
    fSize := 0;
    Exit;
  end;
  SetSize( Buffer.Size );
  Move(Buffer.getDataPointer^,fData^,fSize);
end;

procedure TBuffer.InsertData( Buffer: Pointer; Offset: uint32; Bytes: uint32 );
var
  DataPtr: pointer;
begin
  {$ifdef fpc} {$hints off} {$endif}
  DataPtr := pointer(nativeuint(fData) + Offset );
  {$ifdef fpc} {$hints on} {$endif}
  Move(Buffer^,DataPtr^,Bytes);
end;

function TBuffer.AppendData(Buffer: Pointer; Bytes: uint32): pointer;
var
  Target: NativeInt;
  TargetPtr: Pointer;
  OldSize: Longword;
begin
  Result := nil;
  if bytes>0 then begin
    OldSize := fSize;
    SetSize( OldSize + Bytes );
    {$HINTS OFF} Target := NativeInt(fData); {$HINTS ON}
    inc(Target,OldSize);
    {$HINTS OFF} TargetPtr := Pointer(Target); {$HINTS ON}
    Move(Buffer^,TargetPtr^,Bytes);
    Result := TargetPtr;
  end;
end;

procedure TBuffer.ExtractData( Buffer: Pointer; Offset: uint32; Bytes: uint32 );
var
  DataPtr: pointer;
begin
  if Bytes=0 then Exit;
  {$ifdef fpc} {$hints off} {$endif}
  DataPtr := pointer(nativeuint(fData) + Offset);
  {$ifdef fpc} {$hints on} {$endif}
  if Bytes>(fSize-Offset) then begin
    Move(DataPtr^,Buffer^,(fSize-Offset));
  end else begin
    Move(DataPtr^,Buffer^,Bytes);
  end;
end;

procedure TBuffer.FillMem(value: uint8);
begin
  FillChar(getDataPointer^,getSize,value);
end;

function TBuffer.getAsString: string;
begin
  Result := ReadString(TUnicodeFormat.utf16LE);
end;

function TBuffer.getByte(idx: uint32): uint8;
var
  ptr: ^uint8;
begin
  if (idx<fSize) then begin
    {$ifdef fpc} {$hints off} {$endif}
    ptr := pointer(nativeuint(fData)+idx);
    {$ifdef fpc} {$hints on} {$endif}
    Result := ptr^;
  end else begin
    Result := 0;
  end;
end;


end.



