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
unit darkvectors.computebuffer.import;

interface
uses
  darkHandles,
  darkvectors.plugin,
  darkvectors.imported.import,
  darkvectors.computeengine;

type
  TComputeBuffer = class( TInterfacedObject, IComputeBuffer, IImported )
  private
    fHandle: THandle;
    fPlugin: IComputePlugin;
    fEngine: IComputeEngine;
  private //- IImported -//
    function getExternalHandle: THandle;
  private //- IComputeBuffer -//
    function getFloatSize: uint8;
    function getHandle: pointer;
    function getComputeEngine: IComputeEngine;
    function getSize: uint64;
    procedure getData( TargetPtr: pointer; Offset: uint64; cbBytes: uint64 );
    procedure setData( SourcePtr: pointer; Offset: uint64; cbBytes: uint64 );
    function getObject( OffsetElements: uint64; Height: uint64; Width: uint64 ): IComputeObject;
  public
    constructor Create( Plugin: IComputePlugin; Handle: THandle; Engine: IComputeEngine ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  darkvectors.computeobject.import;

{ TComputeBuffer }

constructor TComputeBuffer.Create(Plugin: IComputePlugin; Handle: THandle; Engine: IComputeEngine);
begin
  inherited Create;
  fPlugin := Plugin;
  fHandle := Handle;
  fEngine := Engine;
end;

destructor TComputeBuffer.Destroy;
begin
  fEngine := nil;
  fPlugin.FreeHandle(fHandle);
  fPlugin := nil;
  inherited Destroy;
end;

function TComputeBuffer.getComputeEngine: IComputeEngine;
begin
  result := fEngine;
end;

procedure TComputeBuffer.getData(TargetPtr: pointer; Offset, cbBytes: uint64);
begin
  fPlugin.cb_getData( fHandle, TargetPtr, Offset, cbBytes );
end;

function TComputeBuffer.getExternalHandle: THandle;
begin
  Result := fHandle;
end;

function TComputeBuffer.getFloatSize: uint8;
begin
  Result := fPlugin.cb_getFloatSize(fHandle);
end;

function TComputeBuffer.getHandle: pointer;
begin
  Result := fPlugin.cb_getHandle(fHandle);
end;

function TComputeBuffer.getObject(OffsetElements, Height, Width: uint64): IComputeObject;
var
  ObjectHandle: THandle;
begin
  Result := nil;
  ObjectHandle := fPlugin.cb_getObject(fHandle,OffsetElements,Height,Width);
  if ObjectHandle=THandles.cNullHandle then begin
    exit;
  end;
  Result := TComputeObject.Create(fPlugin,ObjectHandle,Self);
end;

function TComputeBuffer.getSize: uint64;
begin
  Result := fPlugin.cb_getSize(fHandle);
end;

procedure TComputeBuffer.setData(SourcePtr: pointer; Offset, cbBytes: uint64);
begin
  fPlugin.cb_setData( fHandle, SourcePtr, Offset, cbBytes );
end;

end.
