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
unit darkio.streams;

interface
uses
  darkUnicode;

type
  ///  <summary>
  ///    Aliased here to make it available without having to uses de.unicode.
  ///  </summary>
  TUnicodeFormat          = darkUnicode.TUnicodeFormat;

  /// <summary>
  ///   IStream is an abstract interface from which other stream interfaces
  ///   are derrived.
  /// </summary>
  IStream = interface
    ['{08852882-39D7-4CC1-8E1E-D5F323E47421}']

    ///  <summary>
    ///    For streams which support the method, clear will empty all content
    ///    from the stream and reset the position to zero.
    ///    For streams which do not support clear, an error is inserted into
    ///    the log. (lsFatal)
    ///  </summary>
    procedure Clear;

    /// <summary>
    ///   Returns true if the cursor is currently positioned at the end of the
    ///   stream.
    /// </summary>
    /// <returns>
    ///   True if the cursor is currently positioned at the end of the stream,
    ///   otherwise returns false.
    /// </returns>
    function getEndOfStream: boolean;

    /// <summary>
    ///   Get the current cursor position within the stream.
    /// </summary>
    /// <returns>
    ///   index of the cursor within the stream from zero, in bytes.
    /// </returns>
    function getPosition: uint64;

    /// <summary>
    ///   Set the cursor position within the stream.
    /// </summary>
    /// <param name="newPosition">
    ///   The index from zero at which to position the cursor, in bytes.
    /// </param>
    /// <remarks>
    ///   Some streams do not support setting the cursor position. In such
    ///   cases, the cursor position will remain unchanged. You should test
    ///   getPosition() to confirm that the move was successful.
    /// </remarks>
    procedure setPosition( newPosition: uint64 );

    ///  <summary>
    ///    Returns the number of bytes remaining on the stream.
    ///  </summary>
    ///  <remarks>
    ///    Some streams do not support reporting the cursor position, and so,
    ///    the remaining number of bytes may be unknown. In such cases, this
    ///    method will return zero.
    ///  </remarks>
    function getRemainingBytes: uint64;

    /// <summary>
    ///   Reads an arbritrary number of bytes from the stream. <br />
    /// </summary>
    /// <param name="p">
    ///   Pointer to a buffer with sufficient space to store the bytes read
    ///   from the stream.
    /// </param>
    /// <param name="Count">
    ///   The maximum number of bytes to read from the stream (size of the
    ///   buffer).
    /// </param>
    /// <returns>
    ///   The number of bytes actually read from the stream, which may differ
    ///   from the number requested in the count parameter. See remarks.
    /// </returns>
    /// <remarks>
    ///   <para>
    ///     When reading from streams, a number of conditions may prevent the
    ///     read operation from returning the number of bytes requested.
    ///   </para>
    ///   <para>
    ///     Examples Include:
    ///   </para>
    ///   <list type="bullet">
    ///     <item>
    ///       Request is for more bytes than remain in the datasource of
    ///       the stream. In this case, the remaining data bytes are
    ///       returned, and the return value of the Read() method will
    ///       reflect the number of bytes actually returned. <br /><br />
    ///     </item>
    ///     <item>
    ///       The stream does not support read operations. Some streams are
    ///       unidirectional. If this stream does not support reading
    ///       operations, the read() method will return zero.
    ///     </item>
    ///   </list>
    /// </remarks>
    function Read( p: pointer; Count: uint32 ): uint32;

    /// <summary>
    ///   Writes an arbritrary number of bytes to the stream.
    /// </summary>
    /// <param name="p">
    ///   A pointer to a buffer from which bytes will be written onto the
    ///   stream.
    /// </param>
    /// <param name="Count">
    ///   The number of bytes to write onto the stream.
    /// </param>
    /// <returns>
    ///   Returns the number of bytes actually written to the stream, which may
    ///   differ from the number specified in the Count parameter. See remarks.
    /// </returns>
    /// <remarks>
    ///   <para>
    ///     A number of conditions can prevent writing data to a stream, in
    ///     which case, the number of bytes written may differ from the
    ///     number specified in the count parameter.
    ///   </para>
    ///   <para>
    ///     Examples include:
    ///   </para>
    ///   <list type="bullet">
    ///     <item>
    ///       There is insufficient space left in the stream target for
    ///       additional data. In this case, the maximum amount of data
    ///       that can be written, will be written, and the return value of
    ///       the Write() method reflects the number of bytes actually
    ///       written. <br /><br />
    ///     </item>
    ///     <item>
    ///       The stream does not support writing. Some streams are
    ///       unidirectional and therefore may not support writing
    ///       operations. In this case, the Write() method will return
    ///       zero.
    ///     </item>
    ///   </list>
    /// </remarks>
    function Write( p: pointer; Count: uint32 ): uint32;

    /// <summary>
    ///   Copies the contents of another stream to this one.
    /// </summary>
    /// <param name="Source">
    ///   The stream to copy data from.
    /// </param>
    /// <returns>
    ///   <para>
    ///     Returns the number of bytes copied from the source stream to this
    ///     one. A number of conditions could prevent successful copying of
    ///     one stream to another.
    ///   </para>
    ///   <para>
    ///     Examples include
    ///   </para>
    ///   <list type="bullet">
    ///     <item>
    ///       The target stream is not writable. In this case, the
    ///       CopyFrom() method will return zero. <br /><br />
    ///     </item>
    ///     <item>
    ///       The source stream is not readable. In this case the
    ///       CopyFrom() method will return zero. <br /><br />
    ///     </item>
    ///     <item>
    ///       The target stream has insufficient storage space for the data
    ///       being copied from the source stream. In this case, the
    ///       maximum number of bytes that can be copied will be copied,
    ///       and the return value of the CopyFrom() method will reflect
    ///       the number of bytes actually copied.
    ///     </item>
    ///   </list>
    /// </returns>
    function CopyFrom( Source: IStream ): uint64;

    /// <summary>
    ///   Get the size of the stream in bytes.
    /// </summary>
    /// <returns>
    ///   Returns the number of bytes stored on the stream in bytes.
    /// </returns>
    function getSize: uint64;

    ///  <summary>
    ///    Returns the name of the stream.
    ///    Naming the stream is optional, and if the stream has not been
    ///    named, this method will return a null string.
    ///  </summary>
    function getName: string;

    ///  <summary>
    ///    Optionally, this stream may be given a name.
    ///    This optional parameter is not used by the stream functionality,
    ///    but may be useful for labeling streams in mult-stream applications.
    ///  </summary>
    procedure setName( value: string );


    procedure WriteByte( value: uint8 );
    function ReadByte: uint8;
    procedure WriteBytes( value: array of uint8 );

    //- Pascal only, properties -//
    property Name: string read getName write setName;
    property Size: uint64 read getSize;
    property Position: uint64 read getPosition write setPosition;
  end;


  /// <summary>
  ///   A stream which supports the IUnicodeStream is able to read data from
  ///   a stream in one unicode format, and translate it on-the-fly into
  ///   another unicode format.
  /// </summary>
  IUnicodeStream = interface( IStream )
    ['{BA3588F0-32A4-4039-A212-389C630BB2E4}']

    /// <summary>
    ///   <para>
    ///     This method attempts to read the unicode BOM (byte-order-mark) of
    ///     the specified unicode format, and returns TRUE if the BOM is
    ///     found or else returns FALSE. <br />
    ///     Warning, the BOM for UTF16-LE will match when the BOM for UTF32-LE
    ///     is present, because the first two bytes of the UTF32-LE BOM match
    ///     those of the UTF-16LE BOM.  Similarly the UTF32-BE BOM will match
    ///     for UTF16-BE. In order to determine the unicode format from the BOM
    ///     values, these values must be tested in order of length, starting
    ///     with the highest. i.e. Test of UTF32-LE and only if that fails to
    ///     match, test for UTF-16LE.
    ///     The Determine unicode format tests BOM's in order to determine the
    ///     unicode format from the BOM.
    ///   </para>
    ///   <para>
    ///     If the BOM is found, the stream position is advanced, but if the
    ///     BOM is not found, the stream position does not change.
    ///   </para>
    /// </summary>
    /// <param name="Format">
    ///   Specifies the unicode format for which a byte-order-mark is expected
    ///   on the stream.
    /// </param>
    /// <returns>
    ///   Returns TRUE if the BOM is discovered on the stream at the current
    ///   position, otherwise returns FALSE.
    /// </returns>
    function ReadBOM( Format: TUnicodeFormat ): boolean;

    /// <summary>
    ///   <para>
    ///     This method will write the Byte-Order-Mark of the specified
    ///     unicode text format onto the stream.
    ///   </para>
    ///   <para>
    ///     Formats of unknown and ansi will do nothing as there is no BOM
    ///     for these formats.
    ///   </para>
    /// </summary>
    /// <param name="Format">
    ///   Format The unicode format to write a BOM for.
    /// </param>
    procedure WriteBOM( Format: TUnicodeFormat );

    /// <summary>
    ///   This method looks for a unicode BOM (byte-order-mark), and if one is
    ///   found, the appropriate unicode format enumeration is returned. <br />
    ///   If no unicode BOM is found, this function returns utfUnknown and you
    ///   should default to the most appropriate format. In most cases UTF-8 is
    ///   a good default option due to it's compatability with ANSI. <br />
    /// </summary>
    /// <returns>
    ///   The TdeUnicodeFormat enum which indicates the BOM which was
    ///   discovered, or else utfUnknown is returned if no appropriate BOM is
    ///   found.
    /// </returns>
    function DetermineUnicodeFormat: TUnicodeFormat;

    ///  <summary>
    ///    This method writes a character to the stream in the specified
    ///    unicode format.
    ///  </summary>
    ///  <param name="aChar">
    ///    The character to write to the stream.
    ///  </param>
    ///  <param name="Format">
    ///    The unicode format used to encode the character onto the stream.
    ///  </param>
    procedure WriteChar( aChar: char; Format: TUnicodeFormat );

    ///  <summary>
    ///    This method reads a single character from the stream using the
    ///    specified unicode format.
    ///  </summary>
    ///  <param name="Format">
    ///    The unicode format to use to decode the character being read from
    ///    the stream.
    ///  </param>
    ///  <returns>
    ///    Returns the next character from the unicode encoded stream.
    ///  </returns>
    function ReadChar( Format: TUnicodeFormat ): char;

    /// <summary>
    ///   This method writes the string of characters to the stream in <br />
    ///   the specified unicode format.
    /// </summary>
    /// <param name="aString">
    ///   The string of characters to write to the stream.
    /// </param>
    /// <param name="Format">
    ///   The unicode format to use when writing the characters to the stream.
    /// </param>
    procedure WriteString( aString: string; Format: TUnicodeFormat );

    /// <summary>
    ///   This method reads a string of characters from the stream in the
    ///   specified unicode format, translating them to a TString UTF-16LE. <br />
    /// </summary>
    /// <param name="Format">
    ///   The unicode format to use when reading the characters <br />from the
    ///   stream.
    /// </param>
    /// <param name="ZeroTerm">
    ///   Optional parameter. Terminate reading characters from the stream when
    ///   a zero character is found?
    /// </param>
    /// <param name="Max">
    ///   Optional parameter. The maximum number of unicode characters to read
    ///   from the stream.
    /// </param>
    /// <returns>
    ///   The string of characters read from the stream, converted to <br />
    ///   TdeString (UTF-16LE)
    /// </returns>
    /// <remarks>
    ///   <para>
    ///     This method, by default, will read characters from the stream
    ///     until the stream has been exhausted.
    ///   </para>
    ///   <para>
    ///     You can tell the stream to terminate early using the two optional
    ///     parameters. <br /><br />
    ///   </para>
    ///   <para>
    ///     Setting ZeroTerm to true causes the method to stop reading when a
    ///     code-point is discovered with the value of zero. This is useful
    ///     for reading zero terminated strings from the stream. The zero
    ///     will be removed from the stream, but not added to the string.
    ///   </para>
    ///   <para>
    ///     Alternatively, you can set the Max parameter to limit the number
    ///     of characters that will be read from the stream.
    ///   </para>
    /// </remarks>
    function ReadString( Format: TUnicodeFormat; ZeroTerm: boolean = False; Max: int32 = -1 ): string;

    //- Pascal Only, Properties -//
    property Size: uint64 read getSize;
    property Position: uint64 read getPosition write setPosition;
  end;


  TMemoryStream = class
  public
    class function Create(Granularity: uint32 = 256): IUnicodeStream; static;
  end;

  TFileStream = class
  public
    class function Create(Filepath: string; ReadOnly: boolean = TRUE): IUnicodeStream; static;
  end;


implementation
uses
  darkio.filestream.standard,
  darkio.memorystream.standard;

{ TMemoryStream }

class function TMemoryStream.Create(Granularity: uint32): IUnicodeStream;
begin
  Result := darkio.memorystream.standard.TMemoryStream.Create(Granularity);
end;

{ TFileStream }

class function TFileStream.Create(Filepath: string; ReadOnly: boolean): IUnicodeStream;
begin
  Result := darkio.filestream.standard.TFileStream.Create(Filepath,ReadOnly);
end;

end.
