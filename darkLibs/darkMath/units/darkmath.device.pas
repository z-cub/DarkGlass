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
unit darkmath.device;

interface
uses
  darkmath.engine;

type
  ///  <summary>
  ///    Represents a physical device for computation.
  ///  </summary>
  IComputeDevice = interface
    ['{C7778D3C-4680-4917-B93A-452EAB4453AA}']

    ///  <summary>
    ///    Returns the name of the device.
    ///  </summary>
    function getName: string;

    ///  <summary>
    ///    Returns the software/hardware vendor for this device.
    ///  </summary>
    function getVendor: string;

   ///  <summary>
   ///    Returns the clock speed of the device in MHz.
   ///  </summary>
   function getClockSpeed: uint32;

   ///  <summary>
   ///    Returns the number of cores available on the device.
   ///  </summary>
   function getCoreCount: uint32;

   ///  <summary>
   ///    Returns the number of bytes of memory available on this device.
   ///  </summary>
   function getMemorySize: uint64;

   ///  <summary>
   ///    Returns the maximum amount of memory which may be allocated for a
   ///    buffer on this device. (in bytes)
   ///  </summary>
   function getMaxAllocation: uint64;

   ///  <summary>
   ///    Returns the amount of memory that is currently in-use (allocated)
   ///    from this device. (in bytes)
   ///  </summary>
   function getMemoryInUse: uint64;

   ///  <summary>
   ///    Returns the amount of memory availalbe for allocation on this
   ///    device. (in bytes). Note, this value exists for reporting purposes
   ///    but may not be reliably used to determine if a buffer of a given
   ///    size may be allocated. This is due to the multi-threaded nature
   ///    of many parts of the compute framework, and the fact that multiple
   ///    math engines may be instanced on a single physical device.
   ///    When attempting to allocate a memory buffer, the allocation may fail,
   ///    and you should test for failures due to limited resources.
   ///  <//summary>
   function getMemoryAvailable: uint64;

   ///  <summary>
   ///    Returns a set of float types which indicates those types available
   ///    for use with this implementation.
   ///  </summary
   function getSupportedTypes: TFloatTypes;

    /// <summary>
    ///   Returns an instance of IMathEngine to support the specified
    ///   floating-point data type. <br />If an instance does not already exist
    ///   for the specified floating point type, it will be created, otherwise
    ///   the existing instance will be returned.
    /// </summary>
    /// <param name="FloatType">
    ///   An enumeration which identifies the floating-point data type to be
    ///   supported by the returned math engine.
    /// </param>
    function getEngine( FloatType: TFloatType ): IMathEngine;

    //- Pascal Only -//
    property Name: string read getName;
    property Vendor: string read getVendor;
    property ClockSpeed: uint32 read getClockSpeed;
    property CoreCount: uint32 read getCoreCount;
    property DeviceMemory: uint64 read getMemorySize;
    property MaxAllocation: uint64 read getMaxAllocation;
    property MemoryInUse: uint64 read getMemoryInUse;
    property MemoryAvailable: uint64 read getMemoryAvailable;
    property SupportedTypes: TFloatTypes read getSupportedTypes;
  end;

implementation

end.
