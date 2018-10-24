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
unit darkplugins.category.standard;

interface
uses
  darkCollections.types,
  darkplugins.plugin,
  darkplugins.category,
  darkplugins.installer;

type
  TPluginCategory = class( TInterfacedObject, IPluginCategory, IPluginInstaller )
  private
    fID: TGUID;
    fPlugins: ICollection;
  private //- IPluginCategory -//
    function getID: TGUID;
    function getPluginCount: uint64;
    function getPlugin( index: uint64 ): IPlugin;
    function getPluginByName( name: string ): IPlugin;
  private //- IPluginInstaller -//
    function AddPlugin( aPlugin: IPlugin ): IPlugin;
  private
    function FindPlugin(aPlugin: IPlugin): IPlugin;
  public
    constructor Create( CategoryID: TGUID ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  sysutils,
  darkCollections.list;

type
  IPluginList = IList<IPlugin>;
  TPluginList = TList<IPlugin>;

{ TPluginCategory }

function TPluginCategory.FindPlugin( aPlugin: IPlugin ): IPlugin;
var
  idx: uint64;
  utSearch: string;
begin
  Result := nil;
  if IPluginList(fPlugins).Count=0 then begin
    exit;
  end;
  utSearch := Uppercase(Trim(aPlugin.Name));
  for idx := 0 to pred(IPluginList(fPlugins).Count) do begin
    if Uppercase(Trim(IPluginList(fPlugins).Items[idx].name))=utSearch then begin
      Result := IPluginList(fPlugins).Items[idx];
      exit;
    end;
  end;
end;

function TPluginCategory.AddPlugin(aPlugin: IPlugin): IPlugin;
var
  TargetPlugin: IPlugin;
begin
  TargetPlugin := FindPlugin(aPlugin);
  if not assigned(TargetPlugin) then begin
    TargetPlugin := aPlugin;
  end;
  IPluginList(fPlugins).Add(TargetPlugin);
  Result := TargetPlugin;
end;

constructor TPluginCategory.Create(CategoryID: TGUID);
begin
  inherited Create;
  fID := CategoryID;
  fPlugins := TPluginList.Create();
end;

destructor TPluginCategory.Destroy;
begin
  fPlugins := nil;
  inherited Destroy;
end;

function TPluginCategory.getID: TGUID;
begin
  Result := fID;
end;

function TPluginCategory.getPlugin(index: uint64): IPlugin;
begin
  Result := IPluginList(fPlugins).Items[index];
end;

function TPluginCategory.getPluginByName(name: string): IPlugin;
var
  utName: string;
  utTest: string;
  idx: uint64;
begin
  Result := nil;
  utName := Uppercase(Trim(name));
  if (IPluginList(fPlugins).Count)=0 then begin
    exit;
  end;
  for idx := 0 to pred(IPluginList(fPlugins).Count) do begin
    utTest := Uppercase(Trim(IPluginList(fPlugins).Items[idx].Name));
    if utTest=utName then begin
      Result := IPluginList(fPlugins).Items[idx];
      exit;
    end;
  end;
end;

function TPluginCategory.getPluginCount: uint64;
begin
  Result := IPluginList(fPlugins).Count;
end;

end.
