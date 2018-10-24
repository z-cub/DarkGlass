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
unit darkvectors.computedevice.import;

interface
uses
  darkHandles,
  darkvectors.plugin,
  darkvectors.imported.import,
  darkvectors.computeengine,
  darkvectors.computedevice;

type
  TComputeDevice = class( TInterfacedObject, IComputeDevice, IImported )
  private
    fHandle: THandle;
    fPlugin: IComputePlugin;
    fHalfEngine: IComputeEngine;
    fSingleEngine: IComputeEngine;
    fDoubleEngine: IComputeEngine;
  private //- IImported -//
    function getExternalHandle: THandle;
  private //- IComputeDevice -//
   function getName: string;
   function getVendor: string;
   function getClockSpeed: uint32;
   function getCoreCount: uint32;
   function getMemorySize: uint64;
   function getMaxAllocation: uint64;
   function getMemoryInUse: uint64;
   function getMemoryAvailable: uint64;
   function getSupportedTypes: TFloatTypes;
   function getEngine( FloatType: TFloatType ): IComputeEngine;
  public
    constructor Create( Plugin: IComputePlugin; Handle: THandle ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  darkio.buffers,
  darkvectors.computeengine.import;

{ TComputeDevice }

constructor TComputeDevice.Create(Plugin: IComputePlugin; Handle: THandle );
begin
  inherited Create;
  fPlugin := Plugin;
  fHandle := Handle;
  fHalfEngine := nil;
  fSingleEngine := nil;
  fDoubleEngine := nil;
end;

destructor TComputeDevice.Destroy;
begin
  fHalfEngine := nil;
  fSingleEngine := nil;
  fDoubleEngine := nil;
  fPlugin.FreeHandle(fHandle);
  fPlugin := nil;
  inherited Destroy;
end;

function TComputeDevice.getClockSpeed: uint32;
begin
  Result := fPlugin.cd_getClockSpeed(fHandle);
end;

function TComputeDevice.getCoreCount: uint32;
begin
  Result := fPlugin.cd_getCoreCount(fHandle);
end;

function TComputeDevice.getEngine(FloatType: TFloatType): IComputeEngine;
var
  EngineHandle: THandle;
  ComputeEngine: IComputeEngine;
begin
  Result := nil;
  //- Check to see if we already have the required engine instance and
  //- return it if so.
  case FloatType of
    ftHalf: if assigned(fHalfEngine) then begin
      Result := fHalfEngine;
      exit;
    end;
    ftSingle: if assigned(fSingleEngine) then begin
      Result := fSingleEngine;
      exit;
    end;
    ftDouble: if assigned(fDoubleEngine) then begin
      Result := fDoubleEngine;
      exit;
    end;
  end;
  //- If we got here, we need to attempt to create the engine
  EngineHandle := fPlugin.cd_getEngine(fHandle,FloatType);
  if EngineHandle=THandles.cNullHandle then begin
    exit;
  end;
  ComputeEngine := TComputeEngine.Create(fPlugin,EngineHandle);
  case FloatType of
    ftHalf: fHalfEngine := ComputeEngine;
    ftSingle: fSingleEngine := ComputeEngine;
    ftDouble: fDoubleEngine := ComputeEngine;
  end;
  Result := ComputeEngine;
end;

function TComputeDevice.getExternalHandle: THandle;
begin
  Result := fHandle;
end;

function TComputeDevice.getMaxAllocation: uint64;
begin
  Result := fPlugin.cd_getMaxAllocation(fHandle);
end;

function TComputeDevice.getMemoryAvailable: uint64;
begin
  Result := fPlugin.cd_getMemoryAvailable(fHandle);
end;

function TComputeDevice.getMemoryInUse: uint64;
begin
  Result := fPlugin.cd_getMemoryInUse(fHandle);
end;

function TComputeDevice.getMemorySize: uint64;
begin
  Result := fPlugin.cd_getMemorySize(fHandle);
end;

function TComputeDevice.getName: string;
var
  Buffer: IUnicodeBuffer;
  Size: uint32;
begin
  Result := '';
  fPlugin.cd_getName(fHandle,nil,Size);
  if Size=0 then begin
    exit;
  end;
  Buffer := TBuffer.Create(Size);
  try
    fPlugin.cd_getName(fHandle,Buffer.DataPtr,Size);
    Result := Buffer.ReadString(TUnicodeFormat.utf16LE);
  finally
    Buffer := nil;
  end;
end;

function TComputeDevice.getSupportedTypes: TFloatTypes;
begin
  Result := fPlugin.cd_getSupportedTypes(fHandle);
end;

function TComputeDevice.getVendor: string;
var
  Buffer: IUnicodeBuffer;
  Size: uint32;
begin
  Result := '';
  fPlugin.cd_getVendor(fHandle,nil,Size);
  if Size=0 then begin
    exit;
  end;
  Buffer := TBuffer.Create(Size);
  try
    fPlugin.cd_getVendor(fHandle,Buffer.DataPtr,Size);
    Result := Buffer.ReadString(TUnicodeFormat.utf16LE);
  finally
    Buffer := nil;
  end;
end;

end.
