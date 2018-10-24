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
unit darkplugins.export;

interface
uses
  classes,
  sysutils,
  darkplugins.plugin;

type
  TExportablePlugin = class( TInterfacedObject, IPlugin )
  private
    fVersionMajor: uint32;
    fVersionMinor: uint32;
    fCategory: TGUID;
    fName: string;
  private //- IPlugin -//
    function getVersionMajor: uint32;
    function getVersionMinor: uint32;
    function getCategory: TGUID;
    function getName: string;
    function getInstance: IInterface;
  public
    constructor Create( aVersionMajor: uint32; aVersionMinor: uint32; aCategory: TGUID; aName: string ); reintroduce; virtual;
  end;

implementation
uses
  darkplugins.plugin.export;

var
  SingletonPlugin: IPlugin = nil;

constructor TExportablePlugin.Create(aVersionMajor, aVersionMinor: uint32; aCategory: TGUID; aName: string);
begin
  inherited Create;
  if assigned(SingletonPlugin) then begin
    raise
      Exception.Create('Plugin is already instanced.');
  end;
  fVersionMajor := aVersionMajor;
  fVersionMinor := aVersionMinor;
  fCategory := aCategory;
  fName := aName;
  SingletonPlugin := Self;
  darkPlugins.plugin.export.ExportPlugin(SingletonPlugin);
end;

function TExportablePlugin.getCategory: TGUID;
begin
  Result := fCategory;
end;

function TExportablePlugin.getInstance: IInterface;
begin
  Result := Self;
end;

function TExportablePlugin.getName: string;
begin
  Result := fName;
end;

function TExportablePlugin.getVersionMajor: uint32;
begin
  Result := fVersionMajor;
end;

function TExportablePlugin.getVersionMinor: uint32;
begin
  Result := fVersionMinor;
end;

initialization
finalization
  SingletonPlugin := nil;

end.
