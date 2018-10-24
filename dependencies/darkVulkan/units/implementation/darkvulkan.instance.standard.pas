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
unit darkvulkan.instance.standard;

interface
uses
  sysutils,
  darkvulkan.bindings.vulkan,
  darkvulkan.extensions,
  darkvulkan.layers,
  darkvulkan.instance;

type
  ERequiredExtensions = Exception;
  ERequiredLayers = Exception;
  ECreateInstance = Exception;

type
  TvkInstance = class( TInterfacedObject, IvkInstance )
  private
    fAppName: string;
    fOnDebug: TvkDebugCallback;
    fInstance: vkInstance;
    fvk: Tvk;
  private
    fCallback: VkDebugUtilsMessengerEXT;
  private // IvkInstance //
    function getvkInstance: vkInstance;
    function getOnDebug: TvkDebugCallback;
    procedure setOnDebug( value: TvkDebugCallback );
  private
    class function CheckExtensions( vk: Tvk; RequiredExtensions: IvkExtensions ): boolean; static;
    class function CheckLayers(vk: Tvk; RequiredLayers: IvkLayers): boolean; static;
  protected
    procedure HandleDebug( DebugSeverity: TvkDebugSeverity; DebugType: TvkDebugType; Message: string );
  public
    constructor Create( AppName: string; DebugLayers: IvkLayers = nil; OnDebug: TvkDebugCallback = nil ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  darkIO.Buffers,
  darkIO.Streams,
  darkvulkan.layers.standard,
  darkvulkan.extensions.standard,
  darkvulkan.extensions.required,
  darkvulkan.bindings.utils;


type
  pVkDebugUtilsMessengerCallbackDataEXT = ^VkDebugUtilsMessengerCallbackDataEXT;

function debugCallback( messageSeverity: VkDebugUtilsMessageSeverityFlagBitsEXT;
                        messageType: VkDebugUtilsMessageTypeFlagsEXT;
                        const pCallbackData: pVkDebugUtilsMessengerCallbackDataEXT;
                        pUserData: pointer ):VkBool32;
var
  DebugSeverity: TvkDebugSeverity;
  DebugType: TvkDebugType;
  Buffer: IUnicodeBuffer;
begin
  Result := VK_FALSE;
  if pUserData=nil then begin
    exit;
  end;
  //- Determine severity.
  DebugSeverity := TvkDebugSeverity.dsUnknown;
  if (messageSeverity >= VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT) then begin
    DebugSeverity := TvkDebugSeverity.dsVerbose;
    if (messageSeverity >= VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT) then begin
      DebugSeverity := TvkDebugSeverity.dsInfo;
      if (messageSeverity >= VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT) then begin
        DebugSeverity := TvkDebugSeverity.dsWarning;
        if (messageSeverity >= VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT) then begin
          DebugSeverity := TvkDebugSeverity.dsError;
        end;
      end;
    end;
  end;
  //- Determine the message type
  DebugType := TvkDebugType.dtUnknown;
  if (messageType=uint32(VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT)) then begin
    DebugType := TvkDebugType.dtGeneral;
  end else if (messageType=uint32(VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT)) then begin
    DebugType := TvkDebugType.dtValidation;
  end else if (messageType=uint32(VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT)) then begin
    DebugType := TvkDebugType.dtPerformance;
  end;
  //- Get the message
  if pUserData<>nil then begin
    Buffer := TBuffer.Create(0);
    try
      Buffer.AppendData(pCallbackData^.pMessage);
      TvkInstance(pUserData).HandleDebug( DebugSeverity, DebugType, Buffer.ReadString(TUnicodeFormat.utfAnsi,true));
    finally
      Buffer := nil;
    end;
  end;
end;
{ TvkInstance }

class function TvkInstance.CheckExtensions( vk: Tvk; RequiredExtensions: IvkExtensions ): boolean;
var
  Extensions: IvkExtensions;
  idx: uint64;
begin
  Result := False;
  Extensions := TvkExtensions.Create( vk );
  if not assigned(RequiredExtensions) then begin
    Result := True;
    exit;
  end;
  if RequiredExtensions.Count=0 then begin
    Result := True;
    exit;
  end;
  for idx := 0 to pred(RequiredExtensions.Count) do begin
    if Extensions.Exists(RequiredExtensions[idx].Name) then begin
      if not (Extensions.getByName(RequiredExtensions[idx].Name).Version>=RequiredExtensions[idx].Version) then begin
        exit;
      end;
    end else begin
      exit;
    end;
  end;
  Result := True;
end;

class function TvkInstance.CheckLayers( vk: Tvk; RequiredLayers: IvkLayers ): boolean;
var
  Layers: IvkLayers;
  idx: uint64;
begin
  Result := False;
  Layers := TvkLayers.Create( vk );
  if not assigned(RequiredLayers) then begin
    Result := True;
    exit;
  end;
  if RequiredLayers.Count=0 then begin
    Result := True;
    exit;
  end;
  for idx := 0 to pred(RequiredLayers.Count) do begin
    if not Layers.Exists(RequiredLayers[idx].Name) then begin
      exit;
    end;
  end;
  Result := True;
end;

constructor TvkInstance.Create( AppName: string; DebugLayers: IvkLayers = nil; OnDebug: TvkDebugCallback = nil );
var
  appInfo: VkApplicationInfo;
  createInfo: VkInstanceCreateInfo;
  AppNameBuffer: IUnicodeBuffer;
  //- Handling required extensions
  idx: uint64;
  RequiredExtensions: IvkExtensions;
  RequiredExtensionsArray: array of pointer;
  //- Handling required layers
  RequiredLayersArray: array of pointer;
begin
  fvk := Tvk.Create;
  fOnDebug := nil;
  fAppName := AppName;
  fCallback := 0;
  //- Get required extensions
  RequiredExtensions := TvkRequiredExtensions.Create( assigned(DebugLayers) );
  try
    //- Check that our extensions exist.
    if not CheckExtensions( fvk, RequiredExtensions ) then begin
      raise
        ERequiredExtensions.Create('Required vulkan extensions are not available.');
    end;
    SetLength(RequiredExtensionsArray,RequiredExtensions.Count);
    try
      if RequiredExtensions.Count>0 then begin
        for idx := 0 to pred(RequiredExtensions.Count) do begin
          RequiredExtensionsArray[idx] := RequiredExtensions[idx].NameAsPAnsiChar;
        end;
      end;
      //- Lets do the same for layers
      if not CheckLayers( fvk, DebugLayers ) then begin
      raise
        ERequiredLayers.Create('Required vulkan layers are not available.');
      end;
      SetLength(RequiredLayersArray,DebugLayers.Count);
      try
        if DebugLayers.Count>0 then begin
          for idx := 0 to pred(DebugLayers.Count) do begin
            RequiredLayersArray[idx] := DebugLayers[idx].NameAsPAnsiChar;
          end;
        end;
        //- Convert app name to pchar for appInfo.
        AppNameBuffer := TBuffer.Create(succ(Length(AppName)));
        try
          AppNameBuffer.FillMem(0);
          AppNameBuffer.WriteString(AppName,TUnicodeFormat.utfANSI);
          FillChar(appInfo,Sizeof(VkApplicationInfo),0);
          appInfo.sType := VK_STRUCTURE_TYPE_APPLICATION_INFO;
          appInfo.pApplicationName := AppNameBuffer.DataPtr;
          appInfo.applicationVersion := VK_MAKE_VERSION(1, 0, 0);
          appInfo.pEngineName := 'darkGlass';
          appInfo.engineVersion := VK_MAKE_VERSION(1, 0, 0);          appInfo.apiVersion := VK_API_VERSION_1_0;          FillChar(createInfo, Sizeof(VkInstanceCreateInfo), 0);          createInfo.sType := VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;          createInfo.pApplicationInfo := @appInfo;          if RequiredExtensions.Count>0 then begin            createInfo.enabledExtensionCount := RequiredExtensions.Count;            createInfo.ppEnabledExtensionNames := @RequiredExtensionsArray[0];          end else begin            createInfo.enabledExtensionCount := 0;            createInfo.ppEnabledExtensionNames := nil;          end;          if Length(RequiredLayersArray)>0 then begin            createInfo.enabledLayerCount := DebugLayers.Count;            createInfo.ppEnabledLayerNames := @RequiredLayersArray[0];          end else begin            createInfo.enabledLayerCount := 0;
          end;          if VKFAILED(fvk.vkCreateInstance(@createInfo, nil, @fInstance)) then begin            raise              ECreateInstance.Create('Failed to create vulkan instance.');
          end;        finally          AppNameBuffer := nil;
        end;
      finally
        SetLength(RequiredLayersArray,0);
      end;
    finally
      SetLength(RequiredExtensionsArray,0);
    end;
  finally
    RequiredExtensions := nil;
  end;
  // We got here, so set the instance.
  fvk.ReloadPointers(fInstance);
  //- Set OnDebug
  if assigned(OnDebug) then begin
    setOnDebug(OnDebug);
  end;
end;

destructor TvkInstance.Destroy;
begin
//  setOnDebug(nil);
  fvk.vkDestroyInstance(fInstance, nil);
  fvk.DisposeOf;
  inherited Destroy;
end;

function TvkInstance.getOnDebug: TvkDebugCallback;
begin
  Result := fOnDebug;
end;

function TvkInstance.getvkInstance: vkInstance;
begin
  Result := fInstance;
end;

procedure TvkInstance.HandleDebug(DebugSeverity: TvkDebugSeverity; DebugType: TvkDebugType; Message: string);
begin
  if not assigned(fOnDebug) then begin
    exit;
  end;
  fOnDebug(DebugSeverity,DebugType,Message);
end;

procedure TvkInstance.setOnDebug(value: TvkDebugCallback);
var
  debugCreateInfo: VkDebugUtilsMessengerCreateInfoEXT;
begin
  //- Remove any existing callback.
  if assigned(fOnDebug) then begin
      if fCallback<>0 then begin
        fvk.vkDestroyDebugUtilsMessengerEXT(fInstance,fCallback,nil);
    end;
  end;
  // Set value.
  fOnDebug := Value;
  // If value is nil, we're done.
  if not assigned(fOnDebug) then begin
    exit;
  end;
  //- Create a debugCreateInfo for the debug message handler.
  FillChar( debugCreateInfo, Sizeof(VkDebugUtilsMessengerCreateInfoEXT), 0 );  debugCreateInfo.sType := VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT;  debugCreateInfo.messageSeverity :=  uint32(VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT) or
                                      uint32(VK_DEBUG_UTILS_MESSAGE_SEVERITY_INFO_BIT_EXT) or
                                      uint32(VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT) or
                                      uint32(VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT);
  debugCreateInfo.messageType :=  uint32(VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT) or
                                  uint32(VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT) or
                                  uint32(VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT);
  debugCreateInfo.pfnUserCallback := @debugCallback;
  debugCreateInfo.pUserData := Self;  if VKFAILED(fvk.vkCreateDebugUtilsMessengerEXT(fInstance,@debugCreateInfo,nil,@fCallback)) then begin    fCallback := 0;    exit;  end;end;

end.

