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
unit darkplugins.manager.standard;

interface
uses
  darkplugins.installer,
  darkcollections.types,
  darkplugins.category,
  darkplugins.plugin,
  darkplugins.manager;

const
{$ifdef MSWINDOWS}
  cFileSeparator = '\';
  cPluginExtension = '.dll';
{$else}
  cFileSeparator = '/';
  {$ifdef MACOS}
    cPluginExtension = '.dynlib';
    {$else}
    cPluginExtension = '.so';
    {$endif}
  {$endif}

type
  TPluginManager = class( TInterfacedObject, IPluginManager )
  private
    fCategories: ICollection;
  private //- IPluginManager -//
    function getCategoryCount: uint64;
    function getPluginCategory( index: uint64 ): IPluginCategory;
    function getPluginCategoryByID( CategoryID: TGUID ): IPluginCategory;
    procedure LoadPlugins( CategoryID: TGUID; Directory: string; Recursive: boolean; OnAddPlugin: TOnPluginLoadEvent = nil; UserData: pointer = nil ); overload;
    procedure LoadPlugins( Directory: string; Recursive: boolean; OnAddPlugin: TOnPluginLoadEvent = nil; UserData: pointer = nil ); overload;
    procedure LoadPlugin( Filepath: string; OnAddPlugin: TOnPluginLoadEvent = nil; UserData: pointer = nil );
  private
    procedure AddPlugin(aCategory: IPluginInstaller; aPlugin: IPlugin; OnAddPlugin: TOnPluginLoadEvent; UserData: pointer);
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

function PluginManager: IPluginManager;

implementation
uses
  sysutils,
  strutils,
  darkplugins.category.standard,
  darkplugins.plugin.standard,
  darkCollections.list;

type
  ICategoryList = IList<IPluginCategory>;
  TCategoryList = TList<IPluginCategory>;

var
  SingletonPluginManager: IPluginManager = nil;

function PluginManager: IPluginManager;
begin
  if not assigned(SingletonPluginManager) then begin
    SingletonPluginManager := TPluginManager.Create;
  end;
  Result := SingletonPluginManager;
end;

{ TPluginManager }

constructor TPluginManager.Create;
begin
  inherited Create;
  fCategories := TCategoryList.Create();
end;

destructor TPluginManager.Destroy;
begin
  fCategories := nil;
  inherited Destroy;
end;

function TPluginManager.getCategoryCount: uint64;
begin
  Result := ICategoryList(fCategories).Count;
end;

function TPluginManager.getPluginCategory(index: uint64): IPluginCategory;
begin
  Result := ICategoryList(fCategories).Items[index];
end;

function TPluginManager.getPluginCategoryByID(CategoryID: TGUID): IPluginCategory;
var
  idx: uint64;
begin
  Result := nil;
  if ICategoryList(fCategories).Count=0 then begin
    exit;
  end;
  for idx := 0 to pred(ICategoryList(fCategories).Count) do begin
    if ICategoryList(fCategories).Items[idx].ID = CategoryID then begin
      Result := ICategoryList(fCategories).Items[idx];
      exit;
    end;
  end;
end;

procedure TPluginManager.LoadPlugin(Filepath: string; OnAddPlugin: TOnPluginLoadEvent = nil; UserData: pointer = nil);
var
  aPlugin: IPlugin;
  aCategory: IPluginCategory;
  CategoryID: TGUID;
begin
  aPlugin := TPluginImport.Create( Filepath );
  if assigned(aPlugin) then begin
    CategoryID := aPlugin.Category;
    //- Found one, so add it to the category.
    aCategory := getPluginCategoryByID(CategoryID);
    if not assigned(aCategory) then begin
      //- Category not found, so add it.
      aCategory := TPluginCategory.Create( CategoryID );
      ICategoryList(fCategories).Add(aCategory);
    end;
    AddPlugin( (aCategory as IPluginInstaller), aPlugin, OnAddPlugin, UserData );
  end;
end;

procedure TPluginManager.AddPlugin( aCategory: IPluginInstaller; aPlugin: IPlugin; OnAddPlugin: TOnPluginLoadEvent; UserData: pointer );
var
  TargetPlugin: IPlugin;
begin
  if not assigned(aCategory) then begin
    exit;
  end;
  if not assigned(aPlugin) then begin
    exit;
  end;
  TargetPlugin := aCategory.AddPlugin(aPlugin);
  if assigned(OnAddPlugin) then begin
    OnAddPlugin( TargetPlugin, UserData );
  end;
end;

procedure TPluginManager.LoadPlugins(CategoryID: TGUID; Directory: string; Recursive: boolean; OnAddPlugin: TOnPluginLoadEvent = nil; UserData: pointer = nil);
var
  SearchResult: TSearchRec;
  aPlugin: IPlugin;
  aCategory: IPluginCategory;
  NewDirectory: string;
begin
  //- Ensure no directory separator on directory string, we'll add manually later.
  if RightStr(Directory,1)=cFileSeparator then begin
    Directory := LeftStr(Directory,pred(Length(Directory)));
  end;
  // Find any files in the specified directory which match the plugin extension pattern.
  if findfirst(Directory+cFileSeparator+'*'+cPluginExtension, faAnyFile, searchResult) = 0 then begin
    try
      repeat
        aPlugin := TPluginImport.Create( Directory+ cFileSeparator + SearchResult.Name );
        if assigned(aPlugin) and (aPlugin.Category=CategoryID) then begin
          //- Found one, so add it to the category.
          aCategory := getPluginCategoryByID(CategoryID);
          if not assigned(aCategory) then begin
            //- Category not found, so add it.
            aCategory := TPluginCategory.Create( CategoryID );
            ICategoryList(fCategories).Add(aCategory);
          end;
          AddPlugin( (aCategory as IPluginInstaller), aPlugin, OnAddPlugin, UserData );
        end;
      until FindNext(searchResult) <> 0;
    finally
      FindClose(searchResult);
    end;
  end;
  /// If the search is recursive...
  if not Recursive then begin
    exit;
  end;
  if findfirst(Directory+cFileSeparator+'*', faDirectory, searchResult) = 0 then begin
    try
      repeat
        // Only show directories
        if (searchResult.attr and faDirectory) = faDirectory then begin
          NewDirectory := Directory + cFileSeparator + searchResult.Name;
          if (searchResult.Name='.') or (searchResult.Name='..') then begin
            continue;
          end;
          LoadPlugins( CategoryID, NewDirectory, Recursive );
        end;
      until FindNext(searchResult) <> 0;
    finally
      FindClose(searchResult);
    end;
  end;
end;

procedure TPluginManager.LoadPlugins(Directory: string; Recursive: boolean; OnAddPlugin: TOnPluginLoadEvent = nil; UserData: pointer = nil);
var
  SearchResult: TSearchRec;
  aPlugin: IPlugin;
  aCategory: IPluginCategory;
  CategoryID: TGUID;
  NewDirectory: string;
begin
  //- Ensure no directory separator on directory string, we'll add manually later.
  if RightStr(Directory,1)=cFileSeparator then begin
    Directory := LeftStr(Directory,pred(Length(Directory)));
  end;
  // Find any files in the specified directory which match the plugin extension pattern.
  if findfirst(Directory+cFileSeparator+'*'+cPluginExtension, faAnyFile, searchResult) = 0 then begin
    try
      repeat
        aPlugin := TPluginImport.Create( Directory+ cFileSeparator + SearchResult.Name );
        if assigned(aPlugin) then begin
          CategoryID := aPlugin.Category;
          //- Found one, so add it to the category.
          aCategory := getPluginCategoryByID(CategoryID);
          if not assigned(aCategory) then begin
            //- Category not found, so add it.
            aCategory := TPluginCategory.Create( CategoryID );
            ICategoryList(fCategories).Add(aCategory);
          end;
          AddPlugin( (aCategory as IPluginInstaller), aPlugin, OnAddPlugin, UserData );
        end;
      until FindNext(searchResult) <> 0;
    finally
      FindClose(searchResult);
    end;
  end;
  /// If the search is recursive...
  if not Recursive then begin
    exit;
  end;
  if findfirst(Directory+cFileSeparator+'*', faDirectory, searchResult) = 0 then begin
    try
      repeat
        // Only show directories
        if (searchResult.attr and faDirectory) = faDirectory then begin
          NewDirectory := Directory + cFileSeparator + searchResult.Name;
          if (searchResult.Name='.') or (searchResult.Name='..') then begin
            continue;
          end;
          LoadPlugins( NewDirectory, Recursive );
        end;
      until FindNext(searchResult) <> 0;
    finally
      FindClose(searchResult);
    end;
  end;
end;




initialization
finalization
  SingletonPluginManager := nil;
end.
