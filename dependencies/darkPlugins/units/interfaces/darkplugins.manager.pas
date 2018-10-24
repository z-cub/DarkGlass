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
unit darkplugins.manager;

interface
uses
  darkplugins.plugin,
  darkplugins.category;

type
  ///  <summary>
  ///  </summary>
  TOnPluginLoadEvent = procedure ( Plugin: IPlugin; Userdata: pointer );

  ///  <summary>
  ///    IPluginManager is responsible for managing the available categories of
  ///    plugin which may be loaded, and manages the loading and freeing of
  ///    plugins.
  ///  </summary>
  IPluginManager = interface
    ['{15C6335A-1B3A-4A8E-936A-DF7D647F3F97}']

    ///  <summary>
    ///    Returns the number of plugin categories that are registered with
    ///    this manager. Plugin categories are registered by the importing
    ///    plugin library.
    ///  </summary>
    function getCategoryCount: uint64;

    ///  <summary>
    ///    Returns an instance of IPluginCategory which represents a
    ///    category of plugins which may be loaded into the manger.
    ///  </summary>
    function getPluginCategory( index: uint64 ): IPluginCategory;

    ///  <summary>
    ///    Searches for a plugin category with matching ID and returns it's
    ///    instance. If no category is found, returns nil.
    ///  </summary>
    function getPluginCategoryByID( CategoryID: TGUID ): IPluginCategory;

    ///  <summary>
    ///    Loads all plugins in the specified directory, so long as they match
    ///    the specified category ID.
    ///  </summary>
    procedure LoadPlugins( CategoryID: TGUID; Directory: string; Recursive: boolean; OnAddPlugin: TOnPluginLoadEvent = nil; UserData: pointer = nil ); overload;

    ///  <summary>
    ///    Loads all plugins in the specified directory.
    ///  </summary>
    procedure LoadPlugins( Directory: string; Recursive: boolean; OnAddPlugin: TOnPluginLoadEvent = nil; UserData: pointer = nil ); overload;

    ///  <summary>
    ///    Loads an individual plugin.
    ///  </summary>
    procedure LoadPlugin( Filepath: string; OnAddPlugin: TOnPluginLoadEvent = nil; UserData: pointer = nil );

    // - Pascal Only, Properties -//
    property Categories[ index: uint64 ]: IPluginCategory read getPluginCategory;
    property Categories[ ID: TGUID ]: IPluginCategory read getPluginCategoryByID;
  end;

implementation


end.
