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
unit darkplugins.plugin;

interface

type
  ///  <summary>
  ///    Represents a plugin loaded into memory from dynamic library.
  ///    This interface can be used to acquire the method pointers
  ///    needed for working with the plugin.
  ///  </summary>
  IPlugin = interface
    ['{27AD62ED-2763-4399-8D16-C1A648716867}']

    ///  <summary>
    ///    Returns the major part of the plugin version number.
    ///    For example, if the plugin version is 3.6, this method returns 3.
    ///  </summary>
    function getVersionMajor: uint32;

    ///  <summary>
    ///    Returns the minor part of the plugin version number.
    ///    For example, if the plugin version is 3.6, this method returns 6.
    ///  </summary>
    function getVersionMinor: uint32;

    ///  <summary>
    ///    Returns a GUID indicating the category to which this plugin
    ///    belongs.
    ///  </summary>
    function getCategory: TGUID;

    ///  <summary>
    ///    Returns the name of the plugin (human-readable).
    ///  </summary>
    function getName: string;

    ///  <summary>
    ///    Returns a pointer to a record which contains pointers to the
    ///    methods exposed by the plugin.
    ///  </summary>
    function getInstance: IInterface;

    //- Pascal Only, properties -//
    property VersionMajor: uint32 read getVersionMajor;
    property VersionMinor: uint32 read getVersionMinor;
    property Name: string read getName;
    property Category: TGUID read getCategory;
    property Instance: IInterface read getInstance;
  end;

implementation


end.
