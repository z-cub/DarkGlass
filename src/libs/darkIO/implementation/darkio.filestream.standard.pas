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
unit darkio.filestream.standard;

interface
uses
  classes,
  darkio.streams,
  darkUnicode,
  darkio.unicodestream.custom;

type
  TFileStream = class( TCustomUnicodeStream, IStream, IUnicodeStream )
  private
    fFilePath: string;
    fSysFileStream: classes.TFileStream;
  protected
    procedure Clear; override;
    function Read( p: pointer; Count: uint32 ): uint32; override;
    function Write( p: pointer; Count: uint32 ): uint32; override;
    function getSize: uint64; override;
    function getPosition: uint64; override;
    procedure setPosition( newPosition: uint64 ); override;
  public
    constructor Create( Filepath: string; ReadOnly: boolean ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  sysutils; //[RTL]

{ TdeFileStream }

procedure TFileStream.Clear;
begin
  {$ifdef fpc}
  fSysFileStream.Free;
  {$else}
  fSysFileStream.DisposeOf;
  {$endif}
  fSysFileStream := nil;
  if FileExists(fFilePath) then begin
    DeleteFile(fFilePath);
  end;
  fSysFileStream := classes.TFileStream.Create(fFilePath,fmCreate);
end;

constructor TFileStream.Create( Filepath: string; ReadOnly: boolean );
begin
  inherited Create;
  fFilepath := FilePath;
  if ReadOnly then begin
    fSysFileStream := classes.TFileStream.Create(fFilepath,fmOpenRead);
  end else begin
    if FileExists(FilePath) then begin
      fSysFileStream := classes.TFileStream.Create(fFilepath,fmOpenReadWrite);
    end else begin
      fSysFileStream := classes.TFileStream.Create(fFilepath,fmCreate);
    end;
  end;
end;

destructor TFileStream.Destroy;
begin
  {$ifdef fpc}
  fSysFileStream.Free;
  {$else}
  fSysFileStream.DisposeOf;
  {$endif}
  inherited;
end;

function TFileStream.getPosition: uint64;
begin
  Result := fSysFileStream.Position;
end;

function TFileStream.getSize: uint64;
begin
  Result := fSysFileStream.Size;
end;

function TFileStream.Read(p: pointer; Count: uint32): uint32;
begin
  Result := fSysfileStream.Read(p^,Count);
end;

procedure TFileStream.setPosition(newPosition: uint64);
begin
  fSysFileStream.Position := newPosition;
end;

function TFileStream.Write(p: pointer; Count: uint32): uint32;
begin
  Result := fSysFileStream.Write(p^,Count);
end;

end.
