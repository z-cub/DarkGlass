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
unit darkvulkan.layers.standard;

interface
uses
  darkCollections.types,
  darkvulkan.bindings.vulkan,
  darkvulkan.layer,
  darkvulkan.layers;

type
  TvkLayers = class( TInterfacedObject, IvkLayers )
  private
    fLayers: ICollection;
    [weak] fvkRef: Tvk;
  private //- IvkLayers -//
    function getCount: uint64;
    function getLayer( index: uint64 ): IvkLayer;
    function getByName( name: string ): IvkLayer;
    function Exists( name: string ): boolean;
  private
    constructor InternalCreate( vk: Tvk );
  public
    class function Create( vk: Tvk ): IvkLayers; reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  darkIO.buffers,
  darkCollections.list,
  darkvulkan.bindings.utils,
  darkvulkan.layer.standard;

type
  IvkLayerList = IList<IvkLayer>;
  TvkLayerList = TList<IvkLayer>;

var
  Singleton: IvkLayers = nil;

constructor TvkLayers.InternalCreate( vk: Tvk );
var
  idx: uint32;
  layerCount: uint32;
  vkLayers: array of TVkLayerProperties;
begin
  inherited Create;
  fLayers := TvkLayerList.Create;
  fvkRef := vk;
  //- Get number of layers
  fvkRef.vkEnumerateInstanceLayerProperties(@layerCount, nil);
  if layerCount=0 then begin
    exit;
  end;
  //- Get layer records
  SetLength( vkLayers, layerCount );
  try
    fvkRef.vkEnumerateInstanceLayerProperties(@layerCount, @vkLayers[0]);
    //- Map convert pchars to strings and add to our list.
    for idx := 0 to pred(layerCount) do begin
      IvkLayerList(fLayers).Add( TvkLayer.Create( StrPChar(@vkLayers[idx].layerName[0]),StrPChar(@vkLayers[idx].Description[0]),vkLayers[idx].ImplementationVersion,vkLayers[idx].specVersion) );
    end;
  finally
    SetLength(vkLayers,0);
  end;
end;

class function TvkLayers.Create( vk: Tvk ): IvkLayers;
begin
  if not assigned(Singleton) then begin
    Singleton := InternalCreate( vk );
  end;
  Result := Singleton;
end;

destructor TvkLayers.Destroy;
begin
  fvkRef := nil;
  fLayers := nil;
  inherited Destroy;
end;

function TvkLayers.Exists(name: string): boolean;
begin
  Result := assigned( getByName( name ) );
end;

function TvkLayers.getByName(name: string): IvkLayer;
var
  idx: uint64;
begin
  Result := nil;
  if getCount=0 then begin
    exit;
  end;
  for idx := 0 to pred(getCount) do begin
    if getLayer(idx).Name=name then begin
      Result := getLayer(idx);
      exit;
    end;
  end;
end;


function TvkLayers.getCount: uint64;
begin
  Result := IvkLayerList(fLayers).Count;
end;

function TvkLayers.getLayer(index: uint64): IvkLayer;
begin
  Result := IvkLayerList(fLayers).Items[index];
end;

initialization

finalization
  Singleton := nil;

end.
