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
unit darkplugins.plugin.standard;

interface
uses
  darkDynlib,
  darkplugins.plugin;

type
  /// Types for dynamic library import methods.
  TGetUint32 = function: uint32; cdecl;
  TGetGUID = function: TGUID; cdecl;
  TGetString = procedure( lpStringBuffer: pointer; var lpStringLength: uint32 ); cdecl;
  TGetInterface = function: IInterface; cdecl;

  /// Represents loadable plugin.
  TPluginImport = class( TInterfacedObject, IPlugin )
  private
    fDynlib: IDynlib;
  private //- Imported methods -//
    fgetVersionMajor: TGetUint32;
    fgetVersionMinor: TGetUint32;
    fgetCategory: TGetGUID;
    fgetName: TGetString;
    fgetInstance: TGetInterface;
  private //- Interface methods -//
    function getVersionMajor: uint32;
    function getVersionMinor: uint32;
    function getInstance: IInterface;
    function getName: string;
    function getCategory: TGUID;
  private
    constructor InternalCreate( aDynlib: IDynlib );

  public
    class function Create( Filename: string ): IPlugin; reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  sysutils,
  darkIO.Buffers;

const
  cgetVersionMajor = 'getVersionMajor';
  cgetVersionMinor = 'getVersionMinor';
  cgetCategory = 'getCategory';
  cgetName = 'getName';
  cgetInstance = 'getInstance';


{ TPluginImport }

class function TPluginImport.Create(Filename: string): IPlugin;
var
  Dynlib: IDynlib;
  P: Pointer;
begin
  Result := nil;
  //- Check that the file exists.
  if not FileExists(filename) then begin
    exit;
  end;
  //- Attempt to load the file using a dynlib.
  Dynlib := TDynlib.Create;
  if not DynLib.LoadLibrary(Filename) then begin
    exit;
  end;
  try
    //- Verify that the required methods exist in the dynlib.
    P := DynLib.GetProcAddress( cgetVersionMajor );
    if not assigned(P) then begin
      exit;
    end;
    P := DynLib.GetProcAddress( cgetVersionMinor );
    if not assigned(P) then begin
      exit;
    end;
    P := Dynlib.GetProcAddress( cgetCategory );
    if not assigned(P) then begin
      exit;
    end;
    p := Dynlib.GetProcAddress( cgetName );
    if not assigned(P) then begin
      exit;
    end;
    p := Dynlib.GetProcAddress( cGetInstance );
    if not assigned(P) then begin
      exit;
    end;
    //- If we got here, the plugin is loadable, lets create an instance to
    //- represent the plugin.
    Result := InternalCreate( DynLib );
  finally
    DynLib := nil;
  end;
end;

destructor TPluginImport.Destroy;
begin
  fDynLib := nil;
  inherited Destroy;
end;

function TPluginImport.getCategory: TGUID;
begin
  Result := fgetCategory;
end;

function TPluginImport.getInstance: IInterface;
begin
  Result := fGetInstance;
end;

function TPluginImport.getName: string;
var
  Size: uint32;
  GotSize: uint32;
  Buffer: IUnicodeBuffer;
begin
  Result := '';
  Size := 0;
  fgetName(nil,Size);
  if Size=0 then begin
    exit;
  end;
  Buffer := TBuffer.Create(Size);
  try
    fGetName(Buffer.getDataPointer,GotSize);
    if GotSize<>Size then begin
      exit;
    end;
    Result := Buffer.AsString;
  finally
    Buffer := nil;
  end;
end;

function TPluginImport.getVersionMajor: uint32;
begin
  Result := fgetVersionMajor;
end;

function TPluginImport.getVersionMinor: uint32;
begin
  Result := fgetVersionMinor;
end;

constructor TPluginImport.InternalCreate( aDynlib: IDynlib );
begin
  inherited Create;
  fDynlib := aDynlib;
  fgetVersionMajor := fDynLib.GetProcAddress(cgetVersionMajor);
  fgetVersionMinor := fDynLib.GetProcAddress(cgetVersionMinor);
  fgetCategory := fDynLib.GetProcAddress(cgetCategory);
  fgetName := fDynLib.GetProcAddress(cgetName);
  fgetInstance := fDynLib.GetProcAddress(cGetInstance);
end;

end.
