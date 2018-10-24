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
unit darkvulkan.extensions;

interface
uses
  darkvulkan.extension;

type
  ///  <summary>
  ///    Represents the available extensions on the vulkan implementation.
  ///  </summary>
  IvkExtensions = interface
    ['{DC2EF626-A924-4EA0-AA02-4920899BA660}']
    ///  <summary>
    ///    Returns the number of extensions supported.
    ///  </summary>
    function getCount: uint64;

    ///  <summary>
    ///    Returns an IvkExtension instance representing the extension
    ///    specified by index.
    ///  </summary>
    function getExtension( index: uint64 ): IvkExtension;

    ///  <summary>
    ///    Returns an extension as specified by name.
    ///  </summary>
    function getByName( name: string ): IvkExtension;

    ///  <summary>
    ///    Returns true if the named extension is present in the extensions
    ///    list, otherwise returns false.
    ///  </summary>
    function Exists( name: string ): boolean;

    //- Pascal Only, properties -//
    ///  <summary>
    ///    Returns the number of extensions supported.
    ///  </summary>
    property Count: uint64 read getCount;

    ///  <summary>
    ///    Returns the extension specified by index.
    ///  </summary>
    property Name[ index: uint64 ]: IvkExtension read getExtension; default;

  end;

implementation

end.
