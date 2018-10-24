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
unit darkvulkan.instance;

interface
uses
  darkVulkan.bindings.vulkan;

type
  ///  <summary>
  ///    Represents the severity of a debug message issued to the
  ///    debug callback.
  ///  </summary>
  TvkDebugSeverity = ( dsUnknown, dsVerbose, dsInfo, dsWarning, dsError );

  ///  <summary>
  ///    Represents the type of debug message issued to the debug callback.
  ///  </summary>
  TvkDebugType = ( dtUnknown, dtGeneral, dtValidation, dtPerformance );

  ///  <summary>
  ///    Callback type used to handle debug messages from the IvkInstance.
  ///  </summary>
  TvkDebugCallback = procedure ( DebugSeverity: TvkDebugSeverity; DebugType: TvkDebugType; Message: string ) of object;

  ///  <summary>
  ///    Represents a vulkan instance.
  ///  </summary>
  IvkInstance = interface
    ['{53E65C4B-1875-41ED-ADFA-7E1B790B65F3}']

    ///  <summary>
    ///    Returns the vkInstance represented by this interface.
    ///  </summary>
    function getvkInstance: vkInstance;

    ///  <summary>
    ///    Gets the callback handler used when debug messages are issued
    ///    from the instance. (Only applies when using debug layers)
    ///  </summary>
    function getOnDebug: TvkDebugCallback;

    ///  <summary>
    ///    Sets the callback handler used when debug messages are issued
    ///    from the instance. (Only applies when using debug layers)
    ///  </summary>
    procedure setOnDebug( value: TvkDebugCallback );

    //- Pascal Only, Properties -//

    ///  <summary>
    ///    Returns the vkInstance represented by this interface.
    ///  </summary>
    property Instance: vkInstance read getvkInstance;

    ///  <summary>
    ///    Get/Set the callback handler used when debug messages are issued
    ///    from the instance. (Only applies when using debug layers)
    ///  </summary>
    property OnDebug: TvkDebugCallback read getOnDebug write setOnDebug;
  end;

implementation

end.
