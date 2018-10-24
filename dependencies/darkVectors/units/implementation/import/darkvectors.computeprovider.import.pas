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
unit darkvectors.computeprovider.import;

interface
uses
  darkHandles,
  darkcollections.types,
  darkvectors.plugin,
  darkvectors.imported.import,
  darkvectors.computedevice,
  darkvectors.computeprovider;

type
  TComputeProvider = class( TInterfacedObject, IComputeProvider, IImported )
  private
    fHandle: THandle;
    fPlugin: IComputePlugin;
    fDevices: ICollection;
  private //- IImported -//
    function getExternalHandle: THandle;
  private //- IComputeProvider -//
    function getName: string;
    function getDeviceCount: uint64;
    function getDevice( DeviceIndex: uint64 ): IComputeDevice;
  private
    procedure InstanceDevices;
  public
    constructor Create( Plugin: IComputePlugin ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  darkcollections.list,
  darkvectors.computedevice.import,
  darkio.buffers;

type
  IDeviceList = IList<IComputeDevice>;
  TDeviceList = TList<IComputeDevice>;

{ TComputeProvider }

procedure TComputeProvider.InstanceDevices;
var
  Max: uint64;
  idx: uint64;
  DevHandle: THandle;
  Device: IComputeDevice;
begin
  Max := fPlugin.cp_getDeviceCount(fHandle);
  if Max=0 then begin
    exit;
  end;
  for idx := 0 to pred(Max) do begin
    DevHandle := fPlugin.cp_getDevice(fHandle,idx);
    Device := TComputeDevice.Create(fPlugin,DevHandle);
    IDeviceList(fDevices).Add(Device);
  end;
end;

constructor TComputeProvider.Create(Plugin: IComputePlugin);
begin
  inherited Create;
  fPlugin := Plugin;
  fHandle := fPlugin.cp_Create;
  //- Instance devices.
  fDevices := TDeviceList.Create;
  InstanceDevices;
end;

destructor TComputeProvider.Destroy;
begin
  fDevices := nil;
  fPlugin.FreeHandle(fHandle);
  fPlugin := nil;
  inherited Destroy;
end;

function TComputeProvider.getDevice(DeviceIndex: uint64): IComputeDevice;
begin
  Result := IDeviceList(fDevices).Items[DeviceIndex];
end;

function TComputeProvider.getDeviceCount: uint64;
begin
  Result := IDeviceList(fDevices).Count;
end;

function TComputeProvider.getExternalHandle: THandle;
begin
  Result := fHandle;
end;

function TComputeProvider.getName: string;
var
  Buffer: IUnicodeBuffer;
  Size: uint32;
begin
  fPlugin.cp_getName(fHandle,nil,Size);
  Buffer := TBuffer.Create(Size);
  try
    fPlugin.cp_getName(fHandle,Buffer.DataPtr,Size);
    Result := Buffer.ReadString(TUnicodeFormat.utf16LE);
  finally
    Buffer := nil;
  end;
end;

end.
