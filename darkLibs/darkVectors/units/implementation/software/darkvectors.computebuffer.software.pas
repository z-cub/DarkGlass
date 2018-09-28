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
unit darkvectors.computebuffer.software;

interface
uses
  darkIO.buffers,
  darkvectors.computeengine;

type
  TComputeBuffer = class( TInterfacedObject, IComputeBuffer )
  private
    fBuffer: IBuffer;
    fComputeEngine: IComputeEngine;
  private //- IComputeBuffer -//
    function getHandle: pointer;
    function getComputeEngine: IComputeEngine;
    function getSize: uint64;
    function getFloatSize: uint8;
    procedure getData( TargetPtr: pointer; Offset: uint64; cbBytes: uint64 );
    procedure setData( SourcePtr: pointer; Offset: uint64; cbBytes: uint64 );
    function getObject( OffsetElements: uint64; Height: uint64; Width: uint64 ): IComputeObject;
  public
    constructor Create( Engine: IComputeEngine; Size: uint64 ); reintroduce;
    destructor Destroy; override;

  end;

implementation
uses
  darkvectors.computeobject.standard;

{ TComputeBuffer }

constructor TComputeBuffer.Create(Engine: IComputeEngine; Size: uint64);
begin
  inherited Create;
  fComputeEngine := Engine;
  fBuffer := TBuffer.Create(Size);
end;

destructor TComputeBuffer.Destroy;
begin
  fBuffer := nil;
  fComputeEngine := nil;
  inherited Destroy;
end;

procedure TComputeBuffer.getData(TargetPtr: pointer; Offset, cbBytes: uint64);
begin
  fBuffer.ExtractData(TargetPtr,Offset,cbBytes);
end;

function TComputeBuffer.getFloatSize: uint8;
begin
  Result := fComputeEngine.FloatSize;
end;

function TComputeBuffer.getHandle: pointer;
begin
  Result := fBuffer;
end;

function TComputeBuffer.getComputeEngine: IComputeEngine;
begin
  Result := fComputeEngine;
end;


function TComputeBuffer.getObject(OffsetElements, Height, Width: uint64): IComputeObject;
begin
  Result := TComputeObject.Create(Self,OffsetElements*getFloatSize,Height,Width);
end;

function TComputeBuffer.getSize: uint64;
begin
  Result := fBuffer.Size;
end;

procedure TComputeBuffer.setData(SourcePtr: pointer; Offset, cbBytes: uint64);
begin
  fBuffer.InsertData(SourcePtr,Offset,cbBytes);
end;

end.
