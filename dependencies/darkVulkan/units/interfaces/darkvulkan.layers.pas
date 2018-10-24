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
unit darkvulkan.layers;

interface
uses
  darkvulkan.layer;

type
  ///  <summary>
  ///    Represents the available layers on the vulkan implementation.
  ///  </summary>
  IvkLayers = interface
    ['{156B3FC3-CD6D-44D6-9771-DAAD21A67346}']

    ///  <summary>
    ///    Returns the number of layers supported.
    ///  </summary>
    function getCount: uint64;

    ///  <summary>
    ///    Returns an IvkLayer instance representing the layer
    ///    specified by index.
    ///  </summary>
    function getLayer( index: uint64 ): IvkLayer;

    ///  <summary>
    ///    Returns a layer as specified by name.
    ///  </summary>
    function getByName( name: string ): IvkLayer;

    ///  <summary>
    ///    Returns true if the named layer is present in the layers
    ///    list, otherwise returns false.
    ///  </summary>
    function Exists( name: string ): boolean;

    //- Pascal Only, properties -//
    ///  <summary>
    ///    Returns the number of layers supported.
    ///  </summary>
    property Count: uint64 read getCount;

    ///  <summary>
    ///    Returns the layer specified by index.
    ///  </summary>
    property Name[ index: uint64 ]: IvkLayer read getLayer; default;

  end;

implementation

end.

