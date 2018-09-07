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
unit darkmath.buffer.software;

interface
uses
  darkIO.buffers,
  darkmath.engine;

type
  TMathEngineBuffer = class( TInterfacedObject, IMathEngineBuffer )
  private
    fBuffer: IBuffer;
    fMathEngine: IMathEngine;
  private //- IMathEngineBuffer -//
    function getHandle: pointer;
    function getMathEngine: IMathEngine;
    function getSize: uint64;
    procedure getData( TargetPtr: pointer; Offset: uint64; cbBytes: uint64 );
    procedure setData( SourcePtr: pointer; Offset: uint64; cbBytes: uint64 );
    function getObject( Offset: uint64; Height: uint64; Width: uint64 ): IMathEngineObject;
  public
    constructor Create( Engine: IMathEngine; Size: uint64 ); reintroduce;
    destructor Destroy; override;

  end;

implementation
uses
  darkmath.engineobject.standard;

{ TMathEngineBuffer }

constructor TMathEngineBuffer.Create(Engine: IMathEngine; Size: uint64);
begin
  inherited Create;
  fMathEngine := Engine;
  fBuffer := TBuffer.Create(Size);
end;

destructor TMathEngineBuffer.Destroy;
begin
  fBuffer := nil;
  fMathEngine := nil;
  inherited Destroy;
end;

procedure TMathEngineBuffer.getData(TargetPtr: pointer; Offset, cbBytes: uint64);
begin
  fBuffer.ExtractData(TargetPtr,Offset,cbBytes);
end;

function TMathEngineBuffer.getHandle: pointer;
begin
  Result := fBuffer;
end;

function TMathEngineBuffer.getMathEngine: IMathEngine;
begin
  Result := fMathEngine;
end;

function TMathEngineBuffer.getObject(Offset, Height, Width: uint64): IMathEngineObject;
begin
  Result := TMathEngineObject.Create(Self,Offset,Height,Width);
end;

function TMathEngineBuffer.getSize: uint64;
begin
  Result := fBuffer.Size;
end;

procedure TMathEngineBuffer.setData(SourcePtr: pointer; Offset, cbBytes: uint64);
begin
  fBuffer.InsertData(SourcePtr,Offset,cbBytes);
end;

end.
