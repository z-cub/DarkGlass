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
unit darkio.buffers;

interface
uses
  darkUnicode,
  darkio.streams;

type
  TUnicodeFormat           = darkio.streams.TUnicodeFormat;

  /// <summary>
  ///   IBuffer provides methods for manipulating the data content of a buffer.
  /// </summary>
  /// <seealso cref="de.buffers|TBuffer">
  ///   TBuffer
  /// </seealso>
  IBuffer = interface
    ['{115CCCF5-4F51-425E-9A00-3CEB8E6E19E6}']

    ///  <summary>
    ///    Fills the entire buffer with the value passed in the 'value' parameter.
    ///    Useful for clearing the buffer for example.
    ///  </summary>
    ///  <param name="value">
    ///    The value to fill the buffer with.
    ///  </param>
    procedure FillMem( value: uint8 );

    /// <summary>
    ///   Loads 'Bytes' bytes of data from the stream into the buffer.
    /// </summary>
    /// <param namme="Stream">
    ///   The stream to load data from.
    /// </param>
    /// <param name="Bytes">
    ///   The number of bytes to load from the stream.
    /// </param>
    /// <returns>
    ///   The number of bytes actually read from the stream.
    /// </returns>
    function LoadFromStream( Stream: IStream; Bytes: uint32 ): uint32;

    /// <summary>
    ///   Saves 'Bytes' bytes of data from the buffer into the stream.
    /// </summary>
    /// <param name="Stream">
    ///   The stream to save bytes into.
    /// </param>
    /// <param name="Bytes">
    ///   The number of bytes to write into the stream.
    /// </param>
    /// <returns>
    ///   The number of bytes actually written to the stream.
    /// </returns>
    function SaveToStream( Stream: IStream; Bytes: uint32 ): uint32;

    /// <summary>
    ///   Copy the data from another buffer to this one. <br />The size of the
    ///   buffer will be appropriately altered to match that of the buffer
    ///   being copied.
    /// </summary>
    /// <param name="Buffer">
    ///   The buffer to copy data from.
    /// </param>
    /// <remark>
    ///   This method is destructive to existing data in the buffer.
    /// </remark>
    procedure Assign( Buffer: IBuffer );

    /// <summary>
    ///   Insert data from another memory location into this buffer.
    ///   There must be sufficient space in the buffer to store the inserted
    ///   data at the specified offset.
    /// </summary>
    /// <param name="Buffer">
    ///   This is a pointer to the memory location that data should be copied
    ///   from.
    /// </param>
    /// <param name="Bytes">
    ///   Specifies the number of bytes to read from the memory location.
    /// </param>
    /// <remarks>
    ///   This method is destructive to existing data in the buffer.
    /// </remarks>
    procedure InsertData( Buffer: Pointer; Offset: uint32; Bytes: uint32 );

    /// <summary>
    ///   Appends data from another memory location to the end of this buffer.
    /// </summary>
    /// <param name="Buffer">
    ///   A pointer to the memory location that data should be copied from.
    /// </param>
    /// <param name="Bytes">
    ///   Specifies the number of bytes to add to the buffer from the memory
    ///   location specified in the buffer parameter.
    /// </param>
    /// <returns>
    ///   Pointer to the newly appended data.
    /// </returns>
    function AppendData( Buffer: Pointer; Bytes: uint32 ): pointer;

    /// <summary>
    ///   Extract data to another memory location from this buffer.
    /// </summary>
    /// <param name="Buffer">
    ///   This is a pointer to the memory location that data should be copied
    ///   to
    /// </param>
    /// <param name="Bytes">
    ///   This is the number of bytes that should be copied from this buffer.
    /// </param>
    procedure ExtractData( Buffer: Pointer; Offset: uint32; Bytes: uint32 );

    /// <summary>
    ///   Returns a void pointer to the buffer data.
    /// </summary>
    function getDataPointer: pointer;

    /// <summary>
    ///   Returns the size of the buffer in bytes.
    /// </summary>
    function getSize: uint32;

    /// <summary>
    ///    Returns the value of the byte specified by index (offset within the buffer)
    ///  </summary>
    ///  <param name="idx">
    ///    An offset into the buffer.
    ///  </param>
    function getByte( idx: uint32 ): uint8;

    /// <summary>
    ///    Sets the value of the byte specified by index (offset within the buffer)
    ///  </summary>
    ///  <param name="idx">
    ///    An offset into the buffer.
    ///  </param>
    ///  <param>
    ///    The value to set.
    ///  </param>
    procedure setByte( idx: uint32; value: uint8 );

    /// <summary>
    ///   Sets the size of the buffer in bytes.
    /// </summary>
    /// <param name="aSize">
    ///   The new buffer size in bytes.
    /// </param>
    /// <remarks>
    ///   This function will retain any existing data, up-to the new size of
    ///   the buffer.
    /// </remarks>
    procedure setSize( aSize: uint32 );

    /// <summary>
    ///   Get the size of the data in this buffer, in bytes.
    /// </summary>
    property Size: uint32 read getSize write setSize;
    property DataPtr: pointer read getDataPointer;
    property Bytes[ idx: uint32 ]: uint8 read getByte write setByte;
  end;


  ///  <summary>
  ///    Provides methods for working with buffers containing unicode text.
  ///  </summary>
  IUnicodeBuffer = interface( IBuffer )
    ['{E0472DB1-CDE7-4FD1-BB02-00291C0342F6}']

    ///  <summary>
    ///    Returns the entire buffer as a string, assuming that the data in
    ///    the buffer is encoded as UTF16-LE (the default string type).
    ///  </summary>
    function getAsString: string;

    ///  <summary>
    ///    Sets the buffer length to be sufficient to store the string in
    ///    UTF16-LE format internally.
    ///  </summary>
    procedure setAsString( value: string );

    ///  <summary>
    ///    Attempts to read the byte-order-mark of the specified unicode format.
    ///    Returns true if the requested BOM is present at the beginning of
    ///    the buffer, else returns false.
    ///  </summary>
    function ReadBOM( Format: TUnicodeFormat ): boolean;

    ///  <summary>
    ///    Writes the specified unicode byte-order-mark to the beginning of the
    ///    buffer.
    ///  </summary>
    procedure WriteBOM( Format: TUnicodeFormat );

    ///  <summary>
    ///    Attempts to identify the unicode format of the data in the buffer
    ///    by inspecting the byte-order-mark or other attributes of the data.
    ///  </summary>
    function DetermineUnicodeFormat: TUnicodeFormat;

    ///  Returns length of string written to buffer, in bytes.
    ///  The buffer size is set to match the length of the string after encoding.
    function WriteString(aString: string; Format: TUnicodeFormat): uint32;

    ///  Max when not -1, is lenght of TString in characters
    function ReadString( Format: TUnicodeFormat; ZeroTerm: boolean = False; Max: int32 = -1 ): string;

    //- Pascal only properties -//

    ///  <summary>
    ///    When setting, will set the length of the buffer to the required number
    ///    of bytes to contain the string in UTF16-LE format internally.
    ///    When getting, the entire buffer will be returned as a string.
    ///  </summary>
    property AsString: string read getAsString write setAsString;
  end;

  ICyclicBuffer = interface
    ['{42C239B3-36F7-4618-B4BD-929C53DFF75C}']

    /// <summary>
    ///   Simply resets the buffer pointers.
    /// </summary>
    procedure Clear;

    /// <summary>
    ///   Write 'Count' bytes into the buffer. If there is insufficient space in
    ///   the buffer, this method will return a <0 error code. Otherwise the
    ///   number of bytes added is returned.
    /// </summary>
    function Write( DataPtr: Pointer; Count: uint32 ): uint32;

    /// <summary>
    ///   Read 'Count' bytes from the buffer. If there is insufficient data to
    ///   return the number of bytes requested, the maximum available bytes
    ///   will be read. This method returns the number of bytes read from
    ///   the buffer.
    /// </summary>
    function Read( DataPtr: Pointer; Count: uint32 ): uint32;

    ///  <summary>
    ///    Reads 'Size' bytes from the buffer, but doesn't remove that data from
    ///    the buffer as Read does.
    ///  </summary>
    function Peek( DataPtr: Pointer; Count: uint32 ): uint32;

    /// <summary>
    ///   Loads 'Bytes' bytes of data from the stream into the buffer.
    /// </summary>
    function LoadFromStream( Stream: IStream; Bytes: uint32 ): uint32;

    /// <summary>
    ///   Saves 'Bytes' bytes of data from the buffer into the stream.
    /// </summary>
    function SaveToStream( Stream: IStream; Bytes: uint32 ): uint32;

    /// <summary>
    ///   Returns the number of bytes that are freely available in the buffer.
    /// </summary>
    function GetFreeBytes: uint32;

    /// <summary>
    ///   Returns the number of bytes that are currently occupied in the buffer.
    /// </summary>
    function GetUsedBytes: uint32;
  end;


  TBuffer = class
  public
    class function Create( size: uint32 = 256 ): IUnicodeBuffer; static;
  end;

  TCyclicBuffer = class
  public
    class function Create( size: uint32 = 256 ): ICyclicBuffer; static;
  end;


implementation
uses
  darkio.buffer.standard,
  darkio.cyclicbuffer.standard;

{ TBuffer }

class function TBuffer.Create(size: uint32): IUnicodeBuffer;
begin
  Result := darkio.buffer.standard.TBuffer.Create(Size);
end;

{ TCyclicBuffer }

class function TCyclicBuffer.Create(size: uint32): ICyclicBuffer;
begin
  Result := darkio.cyclicbuffer.standard.TCyclicBuffer.Create(size);
end;

end.
