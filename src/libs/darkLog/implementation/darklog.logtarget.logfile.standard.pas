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
unit darklog.logtarget.logfile.standard;

interface
uses
  darkUnicode,
  darklog;

type
  TFileLogTarget = class( TInterfacedObject, ILogTarget )
  private
    fFormat: TUnicodeFormat;
    fFileName: string;
  private //- ILogTarget -//
    procedure Insert( MessageClass: string; MessageVariables: array of TLogBindParameter; MessageText: string );
  public
    constructor Create( Filename: string; UnicodeFormat: TUnicodeFormat = TUnicodeFormat.utf8 ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  darkIO.streams,
  sysutils;


procedure TFileLogTarget.Insert( MessageClass: string; MessageVariables: array of TLogBindParameter; MessageText: string );
var
  fFileStream: IUnicodeStream;
begin
  fFileStream := TFileStream.Create(fFilename,False);
  try
    fFileStream.setPosition(fFileStream.getSize);
    fFileStream.WriteString(MessageText, fFormat);
  finally
    fFileStream := nil;
  end;
end;

constructor TFileLogTarget.Create(Filename: string; UnicodeFormat: TUnicodeFormat);
var
  fFileStream: IUnicodeStream;
begin
  inherited Create;
  fFormat := UnicodeFormat;
  fFilename := Filename;
  if not FileExists(Filename) then begin
    fFileStream := TFileStream.Create(fFilename,False);
    try
      //- Write the byte order mark.
      case fFormat of
        TUnicodeFormat.utfANSI: begin end; // Do nothing, ANSI has no BOM.
        TUnicodeFormat.utf8,
        TUnicodeFormat.utf16LE,
        TUnicodeFormat.utf16BE,
        TUnicodeFormat.utf32LE,
        TUnicodeFormat.utf32BE: fFileStream.WriteBOM(fFormat);
        else begin
          fFormat := TUnicodeFormat.utf8;
          fFileStream.WriteBOM(fFormat);
        end;
      end;
    finally
      fFileStream := nil;
    end;
  end;
end;

destructor TFileLogTarget.Destroy;
begin
  inherited Destroy;
end;

end.


