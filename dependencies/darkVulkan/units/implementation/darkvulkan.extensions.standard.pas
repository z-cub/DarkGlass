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
unit darkvulkan.extensions.standard;

interface
uses
  darkCollections.types,
  darkvulkan.bindings.vulkan,
  darkvulkan.extension,
  darkvulkan.extensions;

type
  TvkExtensions = class( TInterfacedObject, IvkExtensions )
  private
    [weak] fvkRef: Tvk;
    fExtensions: ICollection;
  private //- IvkExtensions -//
    function getCount: uint64;
    function getExtension( index: uint64 ): IvkExtension;
    function getByName( name: string ): IvkExtension;
    function Exists( name: string ): boolean;
  private
    constructor InternalCreate( vk: Tvk );
  public
    class function Create( vk: Tvk ): IvkExtensions; reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  darkIO.buffers,
  darkCollections.list,
  darkvulkan.bindings.utils,
  darkvulkan.extension.standard;

type
  IvkExtensionList = IList<IvkExtension>;
  TvkExtensionList = TList<IvkExtension>;

var
  Singleton: IvkExtensions = nil;

constructor TvkExtensions.InternalCreate( vk: Tvk );
var
  idx: uint32;
  extensionCount: uint32;
  vkExtensions: array of TVkExtensionProperties;
begin
  inherited Create;
  fExtensions := TvkExtensionList.Create;
  fvkRef := vk;
  //- Get number of extensions.
  fvkRef.vkEnumerateInstanceExtensionProperties(nil, @extensionCount, nil);
  if extensionCount=0 then begin
    exit;
  end;
  //- Get extension pchars
  SetLength( vkExtensions,extensionCount );
  try
    fvkRef.vkEnumerateInstanceExtensionProperties(nil, @extensionCount, @vkExtensions[0]);
    //- Map convert pchars to strings and add to our list.
    for idx := 0 to pred(ExtensionCount) do begin
      IvkExtensionList(fExtensions).Add( TvkExtension.Create(StrPChar(@vkExtensions[idx].extensionName[0]),vkExtensions[idx].specVersion) );
    end;
  finally
    SetLength(vkExtensions,0);
  end;
end;

class function TvkExtensions.Create( vk: Tvk ): IvkExtensions;
begin
  if not assigned(Singleton) then begin
    Singleton := InternalCreate( vk );
  end;
  Result := Singleton;
end;

destructor TvkExtensions.Destroy;
begin
  fExtensions := nil;
  inherited Destroy;
end;

function TvkExtensions.Exists(name: string): boolean;
begin
  Result := Assigned( getByName(name) );
end;

function TvkExtensions.getByName(name: string): IvkExtension;
var
  idx: uint64;
begin
  Result := nil;
  if getCount=0 then begin
    exit;
  end;
  for idx := 0 to pred(getCount) do begin
    if getExtension(idx).Name=name then begin
      Result := getExtension(idx);
      exit;
    end;
  end;
end;

function TvkExtensions.getCount: uint64;
begin
  Result := IvkExtensionList(fExtensions).Count;
end;

function TvkExtensions.getExtension(index: uint64): IvkExtension;
begin
  Result := IvkExtensionList(fExtensions).Items[index];
end;

initialization

finalization
  Singleton := nil;

end.
