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
unit darkplugins.plugin.export;

interface
uses
  darkPlugins.plugin;

procedure ExportPlugin( Plugin: IPlugin );

implementation
uses
  darkIO.buffers;

var
  ExportPlg: IPlugin = nil;

procedure ExportPlugin( Plugin: IPlugin );
begin
  ExportPlg := Plugin;
end;

function getVersionMajor: uint32; cdecl; export;
begin
  Result := ExportPlg.VersionMajor;
end;

function getVersionMinor: uint32; cdecl; export;
begin
  Result := ExportPlg.VersionMinor;
end;

function getCategory: TGUID; cdecl; export;
begin
  Result := ExportPlg.Category;
end;

procedure getName( lpName: pointer; var lpSize: uint32 ); cdecl; export;
var
  Buffer: IUnicodeBuffer;
begin
  Buffer := TBuffer.Create;
  try
    Buffer.AsString := ExportPlg.Name;
    if assigned(lpName) then begin
      lpSize := Buffer.Size;
      Buffer.ExtractData(lpName,0,Buffer.Size);
    end else begin
      lpSize := Buffer.Size;
    end;
  finally
    Buffer := nil;
  end;
end;

function getInstance: IInterface; cdecl; export;
begin
  Result := ExportPlg.getInstance;
end;

exports
  getVersionMajor,
  getVersionMinor,
  getCategory,
  getName,
  getInstance;

initialization

finalization
  ExportPlg := nil; // dispose the plugin

end.
