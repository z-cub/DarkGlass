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
unit darkplugins.category;

interface
uses
  darkplugins.plugin;

type
  ///  <summary>
  ///    Represents a category of plugins to be managed by the IPluginManager
  ///  <summary>
  IPluginCategory = interface
    ['{B95ACE1C-7132-4221-9B9A-5F75C7E81E56}']

    ///  <summary>
    ///    Returns the GUID ID of this plugin category.
    ///  </summary>
    function getID: TGUID;

    ///  <summary>
    ///    Returns the number of plugins loaded into this plugin category.
    ///  </summary>
    function getPluginCount: uint64;

    ///  <summary>
    ///    Returns the instance of a loaded plugin as specified by index.
    ///  </summary>
    function getPlugin( index: uint64 ): IPlugin;

    ///  <summary>
    ///    Attempts to get a plugin by the plugin name.
    ///  </summary>
    function getPluginByName( name: string ): IPlugin;

    //- Pascal Only, properties -//
    property ID: TGUID read getID;
    property PluginCount: uint64 read getPluginCount;
    property Plugin[ name: string ]: IPlugin read getPluginByName; default;
    property Plugin[ idx: uint64 ]: IPlugin read getPlugin; default;
  end;

implementation

end.
