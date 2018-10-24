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
unit darkvulkan.extensions.required;

interface
uses
  darkCollections.types,
  darkvulkan.extension,
  darkvulkan.extensions;

type
  TvkRequiredExtensions = class( TInterfacedObject, IvkExtensions )
  private
    fExtensions: ICollection;
  private
    function getCount: uint64;
    function getExtension( index: uint64 ): IvkExtension;
    function Exists( name: string ): boolean;
    function getByName(name: string): IvkExtension;

  public
    constructor Create( WithValidation: boolean = False ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  darkVulkan.bindings.vulkan,
  darkVulkan.extension.standard,
  darkCollections.List;

{ TvkRequiredExtensions }
type
  IvkExtensionList = IList<IvkExtension>;
  TvkExtensionList = TList<IvkExtension>;

constructor TvkRequiredExtensions.Create( WithValidation: boolean = False );
begin
  inherited Create;
  fExtensions := TvkExtensionList.Create;
  IvkExtensionList(fExtensions).Add(TvkExtension.Create(VK_KHR_SURFACE_EXTENSION_NAME,VK_KHR_SURFACE_SPEC_VERSION));
  if WithValidation then begin
    IvkExtensionList(fExtensions).Add(TvkExtension.Create(VK_EXT_DEBUG_UTILS_EXTENSION_NAME,VK_EXT_DEBUG_UTILS_SPEC_VERSION));
  end;
  {$ifdef MSWINDOWS}
  IvkExtensionList(fExtensions).Add(TvkExtension.Create(VK_KHR_WIN32_SURFACE_EXTENSION_NAME,VK_KHR_WIN32_SURFACE_SPEC_VERSION));
  {$endif}
  {$ifdef LINUX}
  IvkExtensionList(fExtensions).Add(TvkExtension.Create(VK_KHR_XLIB_SURFACE_EXTENSION_NAME,VK_KHR_XLIB_SURFACE_SPEC_VERSION));
  {$endif}
  {$ifdef ANDROID}
  IvkExtensionList(fExtensions).Add(TvkExtension.Create(VK_KHR_ANDROID_SURFACE_EXTENSION_NAME,VK_KHR_ANDROID_SURFACE_SPEC_VERSION));
  {$endif}
end;

destructor TvkRequiredExtensions.Destroy;
begin
  fExtensions := nil;
  inherited Destroy;
end;

function TvkRequiredExtensions.Exists(name: string): boolean;
begin
  Result := Assigned( getByName(name) );
end;

function TvkRequiredExtensions.getByName(name: string): IvkExtension;
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


function TvkRequiredExtensions.getCount: uint64;
begin
  Result := IvkExtensionList(fExtensions).Count;
end;

function TvkRequiredExtensions.getExtension(index: uint64): IvkExtension;
begin
  Result := IvkExtensionList(fExtensions).Items[index];
end;

end.
