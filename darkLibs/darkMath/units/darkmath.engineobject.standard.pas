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
unit darkmath.engineobject.standard;

interface
uses
  darkmath.halftype,
  darkmath.engine;

type
  TMathEngineObject = class( TInterfacedObject, IMathEngineObject )
  private
    fMathEngineBuffer: IMathEngineBuffer;
    fOffset: uint64;
    fWidth: uint64;
    fHeight: uint64;
  private
    procedure getElementData(ElementIndex, ElementCount: uint64; ElementBuffer: pointer);
    procedure setElementData(ElementIndex, ElementCount: uint64; ElementBuffer: pointer);
  private //- IMathEngineObject -//
    function getEngineBuffer: IMathEngineBuffer;
    function getMathEngine: IMathEngine;
    function getOffset: uint64;
    function getFloatType: TFloatType;
    function getFloatSize: uint8;
    function getWidth: uint64;
    function getHeight: uint64;

    procedure getElements(ElementIndex, ElementCount: uint64; var Elements: TArrayOfFloat);
    procedure setElements(ElementIndex: uint64; Elements: TArrayOfFloat);
    function getElement(ElementIndex: uint64): float;
    procedure setElement(ElementIndex: uint64; value: float);
  public
    constructor Create( EngineBuffer: IMathEngineBuffer; Offset: uint64; Height: uint64; Width: uint64 ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  darkio.buffers;

{ TMathEngineObject }

constructor TMathEngineObject.Create(EngineBuffer: IMathEngineBuffer; Offset: uint64; Height: uint64; Width: uint64 );
begin
  inherited Create;
  fMathEngineBuffer := EngineBuffer;
  fOffset := Offset;
  fWidth := Width;
  fHeight := Height;
end;

destructor TMathEngineObject.Destroy;
begin
  fMathEngineBuffer := nil;
  inherited Destroy;
end;

function TMathEngineObject.getElement(ElementIndex: uint64): float;
var
  aHalf: half;
  aSingle: single;
begin
  case getFloatType of
    ftHalf: begin
      self.getElementData(ElementIndex,1,@aHalf);
      Result := aHalf;
    end;
    ftSingle: begin
      self.getElementData(ElementIndex,1,@aSingle);
      Result := aSingle;
    end;
    ftDouble: self.getElementData(ElementIndex,1,@Result);
  end;
end;

procedure TMathEngineObject.getElementData(ElementIndex, ElementCount: uint64; ElementBuffer: pointer);
var
  BufferOffset: uint64;
  DataSize: uint64;
begin
  BufferOffset := fOffset + (ElementIndex*getFloatSize);
  DataSize := ElementCount * getFloatSize;
  getEngineBuffer.getData(ElementBuffer,BufferOffset,DataSize);
end;

procedure TMathEngineObject.getElements(ElementIndex, ElementCount: uint64; var Elements: TArrayOfFloat );
var
  idx: uint64;
  Buffer: IBuffer;
  PtrData: pointer;
begin
  if ElementCount=0 then begin
    SetLength( Elements, 0 );
    exit;
  end;
  SetLength( Elements, ElementCount );
  if getFloatType=ftDouble then begin
    getElementData(ElementIndex,ElementCount,@Elements[0]);
    exit;
  end;
  Buffer := TBuffer.Create( getFloatSize * ElementCount );
  try
    getElementData(ElementIndex,ElementCount,Buffer.DataPtr);
    ptrData := Buffer.DataPtr;
    for idx := 0 to pred(ElementCount) do begin
      case getFloatType of
        ftHalf: Elements[idx] := half(PtrData^);
        ftSingle: Elements[idx] := single(PtrData^);
      end;
      ptrData := pointer( nativeuint( ptrData ) + getFloatSize );
    end;
  finally
    Buffer := nil;
  end;
end;

function TMathEngineObject.getEngineBuffer: IMathEngineBuffer;
begin
  Result := fMathEngineBuffer;
end;

function TMathEngineObject.getFloatSize: uint8;
begin
  Result := getEngineBuffer.Engine.FloatSize;
end;

function TMathEngineObject.getFloatType: TFloatType;
begin
  Result := getEngineBuffer.Engine.FloatType;
end;

function TMathEngineObject.getHeight: uint64;
begin
  Result := fHeight;
end;

function TMathEngineObject.getMathEngine: IMathEngine;
begin
  Result := getEngineBuffer.Engine;
end;

function TMathEngineObject.getOffset: uint64;
begin
  Result := fOffset;
end;

function TMathEngineObject.getWidth: uint64;
begin
  Result := fWidth;
end;

procedure TMathEngineObject.setElement(ElementIndex: uint64; value: float);
var
  aHalf: half;
  aSingle: single;
begin
  case getFloatType of
    ftHalf: begin
      aHalf := value;
      setElementData(ElementIndex,1,@aHalf);
    end;
    ftSingle: begin
      aSingle := value;
      setElementData(ElementIndex,1,@aSingle);
    end;
    ftDouble: setElementData(ElementIndex,1,@value);
  end;
end;

procedure TMathEngineObject.setElementData(ElementIndex, ElementCount: uint64; ElementBuffer: pointer);
var
  BufferOffset: uint64;
  DataSize: uint64;
begin
  BufferOffset := fOffset + (ElementIndex*getFloatSize);
  DataSize := ElementCount * getFloatSize;
  getEngineBuffer.setData(ElementBuffer,BufferOffset,DataSize);
end;

procedure TMathEngineObject.setElements(ElementIndex: uint64; Elements: TArrayOfFloat );
var
  idx: uint64;
  Buffer: IBuffer;
  DataPtr: pointer;
begin
  if Length(Elements)=0 then begin
    exit;
  end;
  if getFloatType=ftDouble then begin
    setElementData(ElementIndex,Length(Elements),@Elements[0]);
    exit;
  end;
  Buffer := TBuffer.Create(getFloatSize*Length(Elements));
  try
    DataPtr := Buffer.DataPtr;
    for idx := 0 to pred(Length(Elements)) do begin
      case getFloatType of
        ftHalf: half(DataPtr^) := Elements[idx];
        ftSingle: single(DataPtr^) := Elements[idx];
      end;
      DataPtr := Pointer( nativeuint( DataPtr ) + getFloatSize );
    end;
    setElementData(ElementIndex,Length(Elements),Buffer.DataPtr);
  finally
    Buffer := nil;
  end;
end;

end.

