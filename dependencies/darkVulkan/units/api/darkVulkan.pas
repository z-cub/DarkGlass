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
unit darkVulkan;

interface
uses
  darkVulkan.extension,
  darkVulkan.extensions,
  darkVulkan.layer,
  darkVulkan.layers,
  darkVulkan.layers.lunarg,
  darkVulkan.instance;

type
  IvkExtension      = darkVulkan.extension.IvkExtension;
  IvkExtensions     = darkVulkan.extensions.IvkExtensions;
  IvkLayer          = darkVulkan.layer.IvkLayer;
  IvkLayers         = darkVulkan.layers.IvkLayers;
  TvkLunarGLayers   = darkVulkan.layers.lunarg.TvkLunarGLayers;
  TvkDebugType      = darkVulkan.instance.TvkDebugType;
  TvkDebugSeverity  = darkVulkan.instance.TvkDebugSeverity;
  TvlDebugCallback  = darkVulkan.instance.TvkDebugCallback;
  IvkInstance       = darkVulkan.instance.IvkInstance;

type
  ///  <summary>
  ///    Factory class for creating IvkInstance
  ///  </summary>
  TvkInstance = class
    ///  <summary>
    ///    Returns a singleton instance of IvkExtensions containing those
    ///    extensions which are supported on the target vulkan implementation.
    ///  </summary>
    class function AvailableExtensions: IvkExtensions; static;

    ///  <summary>
    ///    Returns a singleton instance of IvkLayers containing those
    ///    layers which are supported on the target vulkan implementation.
    ///  </summary>
    class function AvailableLayers: IvkLayers; static;

    ///  <summary>
    ///    Creates an instance of the IvkInstance interface.
    ///    If anything should fail during this process, the return value
    ///    is nil.
    ///  </summary>
    class function Create(AppName: string; DebugLayers: IvkLayers = nil; OnDebug: TvkDebugCallback = nil): IvkInstance; static;
  end;


implementation
uses
  sysutils,
  darkvulkan.bindings.vulkan,
  darkVulkan.extensions.standard,
  darkVulkan.layers.standard,
  darkVulkan.instance.standard;


{ TvkInstance }

class function TvkInstance.AvailableExtensions: IvkExtensions;
begin
  Result := TvkExtensions.Create(Tvk.Create);
end;

class function TvkInstance.AvailableLayers: IvkLayers;
begin
  Result := TvkLayers.Create(Tvk.Create);
end;

class function TvkInstance.Create(AppName: string; DebugLayers: IvkLayers = nil; OnDebug: TvkDebugCallback = nil): IvkInstance;
begin
  try
    Result := darkVulkan.instance.standard.TvkInstance.Create(AppName,DebugLayers,OnDebug);
  except
    on E: Exception do
      Result := nil;
  end;
end;

end.
