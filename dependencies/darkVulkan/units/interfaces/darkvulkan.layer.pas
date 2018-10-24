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
unit darkvulkan.layer;

interface

type
  ///  <summary>
  ///    Represents a vulkan layer.
  ///  </summary>
  IvkLayer = interface
    ['{8F8FDDC9-551A-4AE7-AB4D-CE6CE387ED3E}']

    ///  <summary>
    ///    Returns the name as a pAnsiChar
    ///  </summary>
    function getNameAsPAnsiChar: pointer;

    ///  <summary>
    ///    Returns the name of this layer.
    ///  </summary>
    function getName: string;

    ///  <summary>
    ///    Returns the specification version of this layer.
    ///  </summary>
    function getSpecVersion: uint32;

    ///  <summary>
    ///    Returns the Implementation version of this layer.
    ///  </summary>
    function getImplementationVersion: uint32;

    ///  <summary>
    ///    Returns a description of this layer.
    ///  </summary>
    function getDescription: string;

    //- Pascal Only, properties -//

    ///  <summary>
    ///    Returns the name of this layer.
    ///  </summary>
    property Name: string read getName;

    ///  <summary>
    ///    Returns the specification version of this layer.
    ///  </summary>
    property SpecVersion: uint32 read getSpecVersion;

    ///  <summary>
    ///    Returns the Implementation version of this layer.
    ///  </summary>
    property ImplementationVersion: uint32 read getImplementationVersion;

    ///  <summary>
    ///    Returns a description of this layer.
    ///  </summary>
    property Description: string read getDescription;

    ///  <summary>
    ///    Returns the name of the layer as a pAnsiChar.
    ///  </summary>
    property NameAsPAnsiChar: pointer read getNameAsPAnsiChar;

  end;

implementation

end.
