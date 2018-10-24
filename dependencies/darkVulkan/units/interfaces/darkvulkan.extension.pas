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
unit darkvulkan.extension;

interface

type
  ///  <summary>
  ///    Represents a vulkan extension.
  ///  </summary>
  IvkExtension = interface
    ['{E69122A1-8923-49CB-A1D4-09B92AD4079D}']

    ///  <summary>
    ///    Useful in constructing pAnsiChar array.
    ///  </summary>
    function getNameAsPAnsiChar: pointer;

    ///  <summary>
    ///    Returns the name of this extension.
    ///  </summary>
    function getName: string;

    ///  <summary>
    ///    Returns the spec version of this extension.
    ///  <summary>
    function getVersion: uint32;

    //- Pascal Only, Properties -//
    property NameAsPAnsiChar: pointer read getNameAsPAnsiChar;
    property Name: string read getName;
    property Version: uint32 read getVersion;
  end;

implementation

end.
