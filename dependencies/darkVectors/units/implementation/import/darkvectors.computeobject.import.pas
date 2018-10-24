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
unit darkvectors.computeobject.import;

interface
uses
  darkHandles,
  darkcollections.types,
  darkvectors.plugin,
  darkvectors.imported.import,
  darkvectors.computeengine;

type
  TComputeObject = class( TInterfacedObject, IComputeObject, IImported )
  private
    fHandle: THandle;
    fPlugin: IComputePlugin;
    fComputeBuffer: IComputeBuffer;
  private //- IImported -//
    function getExternalHandle: THandle;
  private //- IComputeObject -//
    function getComputeBuffer: IComputeBuffer;
    function getComputeEngine: IComputeEngine;
    function getOffset: uint64;
    function getFloatType: TFloatType;
    function getFloatSize: uint8;
    procedure getElements( ElementIndex: uint64; ElementCount: uint64; var Elements: TArrayOfFloat );
    procedure setElements( ElementIndex: uint64; Elements: TArrayOfFloat );
    function getElement( ElementIndex: uint64 ): float;
    procedure setElement( ElementIndex: uint64; value: float );
    function getWidth: uint64;
    function getHeight: uint64;
  public
    constructor Create( Plugin: IComputePlugin; Handle: THandle; ComputeBuffer: IComputeBuffer ); reintroduce;
    destructor Destroy; override;

  end;

implementation

{ TComputeObject }

constructor TComputeObject.Create(Plugin: IComputePlugin; Handle: THandle; ComputeBuffer: IComputeBuffer);
begin
  inherited Create;
  fPlugin := Plugin;
  fHandle := Handle;
  fComputeBuffer := ComputeBuffer;
end;

destructor TComputeObject.Destroy;
begin
  fComputeBuffer := nil;
  fPlugin.FreeHandle(fHandle);
  fPlugin := nil;
  inherited;
end;

function TComputeObject.getComputeBuffer: IComputeBuffer;
begin
  Result := fComputeBuffer;
end;

function TComputeObject.getComputeEngine: IComputeEngine;
begin
  Result := fComputeBuffer.Engine;
end;

function TComputeObject.getElement(ElementIndex: uint64): float;
begin
  Result := fPlugin.co_getElement(fHandle,ElementIndex);
end;

procedure TComputeObject.getElements(ElementIndex, ElementCount: uint64; var Elements: TArrayOfFloat);
begin
  fPlugin.co_getElements(fHandle,ElementIndex,Elementcount,Elements);
end;

function TComputeObject.getExternalHandle: THandle;
begin
  Result := fHandle;
end;

function TComputeObject.getFloatSize: uint8;
begin
  Result := fPlugin.co_getFloatSize(fHandle);
end;

function TComputeObject.getFloatType: TFloatType;
begin
  Result := fPlugin.co_getFloatType(fHandle);
end;

function TComputeObject.getHeight: uint64;
begin
  Result := fPlugin.co_getHeight(fHandle);
end;

function TComputeObject.getOffset: uint64;
begin
  Result := fPlugin.co_getOffset(fHandle);
end;

function TComputeObject.getWidth: uint64;
begin
  Result := fPlugin.co_getWidth(fHandle);
end;

procedure TComputeObject.setElement(ElementIndex: uint64; value: float);
begin
  fPlugin.co_setElement(fHandle,ElementIndex,Value);
end;

procedure TComputeObject.setElements(ElementIndex: uint64; Elements: TArrayOfFloat);
begin
  fPlugin.co_setElements(fHandle,ElementIndex,Elements);
end;

end.
