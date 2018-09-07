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
unit darkmath.provider;

interface
uses
  darkmath.device;

type
  ///  <summary>
  ///    An implementation of IComputeProvider behaves as a factory for
  ///    creating instances of IComputeDevice for a given compute technology.
  ///    For example, IComputeProviders may represent SIMD, OpenCL, Vulkan, or
  ///    Software implementations of compute devices and associated compute
  ///    engines.
  ///  </summary>
  IComputeProvider = interface
  ['{C891BB76-FE3A-4436-95CE-BD60F73AA483}']

    ///  <summary>
    ///    Returns the name of this provider.
    ///    (i.e. OpenCL / Software / SIMD / Vulkan / Remote )
    ///  </summary>
    function getName: string;

    ///  <summary>
    ///    Return the number of devices which can support math engines of the
    ///    type that this implementation is able to create.
    ///    For example, the openCL implementation of IComputeProvider will
    ///    return the number of GPU's which have an OpenCL driver.
    ///  </summary>
    function getDeviceCount: uint64;

    ///  <summary>
    ///    Returns a device for this implementation.
    ///  </summary>
    function getDevice( DeviceIndex: uint64 ): IComputeDevice;

    //- Pascal Only -//

    ///  <summary>
    ///    Returns the number of devices available for this provider.
    ///  </summary>
    property DeviceCount: uint64 read getDeviceCount;

    ///  <summary>
    ///    Returns the name of the provider.
    ///  </summary>
    property Name: string read getName;

    ///  <summary>
    ///    Provides array style access to the compute devices available
    ///    through this provider.
    ///  </summary>
    property Devices[ DeviceIndex: uint64 ]: IComputeDevice read getDevice;
  end;


implementation

end.
