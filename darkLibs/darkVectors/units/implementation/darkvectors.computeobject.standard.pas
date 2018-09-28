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
unit darkvectors.computeobject.standard;
{$ifdef fpc} {$ifdef CPU64} {$define CPU64BITS} {$endif} {$endif}

interface
uses
  darkvectors.halftype,
  darkvectors.computeengine;

type
  TComputeObject = class( TInterfacedObject, IComputeObject )
  private
    fComputeBuffer: IComputeBuffer;
    fOffset: uint64;
    fWidth: uint64;
    fHeight: uint64;
  private
    procedure getElementData(ElementIndex, ElementCount: uint64; ElementBuffer: pointer);
    procedure setElementData(ElementIndex, ElementCount: uint64; ElementBuffer: pointer);
  private //- IComputeObject -//
    function getComputeBuffer: IComputeBuffer;
    function getComputeEngine: IComputeEngine;
    function getOffset: uint64;
    function getFloatType: TFloatType;
    function getFloatSize: uint8;
    function getWidth: uint64;
    function getHeight: uint64;
    function getElement(ElementIndex: uint64): float;
    procedure setElement(ElementIndex: uint64; value: float);
    procedure getElements(ElementIndex, ElementCount: uint64; var Elements: TArrayOfFloat);
    procedure setElements(ElementIndex: uint64; Elements: TArrayOfFloat);
  public
    constructor Create( ComputeBuffer: IComputeBuffer; Offset: uint64; Height: uint64; Width: uint64 ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  darkio.buffers;

{ TComputeObject }

constructor TComputeObject.Create(ComputeBuffer: IComputeBuffer; Offset: uint64; Height: uint64; Width: uint64 );
begin
  inherited Create;
  fComputeBuffer := ComputeBuffer;
  fOffset := Offset;
  fWidth := Width;
  fHeight := Height;
end;

destructor TComputeObject.Destroy;
begin
  fComputeBuffer := nil;
  inherited Destroy;
end;

function TComputeObject.getElement(ElementIndex: uint64): float;
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

procedure TComputeObject.getElementData(ElementIndex, ElementCount: uint64; ElementBuffer: pointer);
var
  BufferOffset: uint64;
  DataSize: uint64;
begin
  BufferOffset := fOffset + (ElementIndex*getFloatSize);
  DataSize := ElementCount * getFloatSize;
  getComputeBuffer.getData(ElementBuffer,BufferOffset,DataSize);
end;

procedure TComputeObject.getElements(ElementIndex, ElementCount: uint64; var Elements: TArrayOfFloat );
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
  Buffer := TBuffer.Create( getFloatSize * ElementCount );
  try
    getElementData(ElementIndex,ElementCount,Buffer.DataPtr);
    ptrData := Buffer.DataPtr;
    for idx := 0 to pred(ElementCount) do begin
      case getFloatType of
        ftHalf: Elements[idx] := half(PtrData^);
        ftSingle: Elements[idx] := single(PtrData^);
        ftDouble: Elements[idx] := double(PtrData^);
        {$ifndef CPU64BITS} ftExtended: Elements[idx] := single(PtrData^); {$endif}
      end;
      ptrData := pointer( nativeuint( ptrData ) + getFloatSize );
    end;
  finally
    Buffer := nil;
  end;
end;

function TComputeObject.getComputeBuffer: IComputeBuffer;
begin
  Result := fComputeBuffer;
end;

function TComputeObject.getFloatSize: uint8;
begin
  Result := getComputeBuffer.Engine.FloatSize;
end;

function TComputeObject.getFloatType: TFloatType;
begin
  Result := getComputeBuffer.Engine.FloatType;
end;

function TComputeObject.getHeight: uint64;
begin
  Result := fHeight;
end;

function TComputeObject.getComputeEngine: IComputeEngine;
begin
  Result := getComputeBuffer.Engine;
end;

function TComputeObject.getOffset: uint64;
begin
  Result := fOffset;
end;

function TComputeObject.getWidth: uint64;
begin
  Result := fWidth;
end;

procedure TComputeObject.setElement(ElementIndex: uint64; value: float);
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

procedure TComputeObject.setElementData(ElementIndex, ElementCount: uint64; ElementBuffer: pointer);
var
  BufferOffset: uint64;
  DataSize: uint64;
begin
  BufferOffset := fOffset + (ElementIndex*getFloatSize);
  DataSize := ElementCount * getFloatSize;
  getComputeBuffer.setData(ElementBuffer,BufferOffset,DataSize);
end;

procedure TComputeObject.setElements(ElementIndex: uint64; Elements: TArrayOfFloat );
var
  idx: uint64;
  Buffer: IBuffer;
  DataPtr: pointer;
begin
  if Length(Elements)=0 then begin
    exit;
  end;
  Buffer := TBuffer.Create(getFloatSize*Length(Elements));
  try
    DataPtr := Buffer.DataPtr;
    for idx := 0 to pred(Length(Elements)) do begin
      case getFloatType of
        ftHalf: half(DataPtr^) := Elements[idx];
        ftSingle: single(DataPtr^) := Elements[idx];
        ftDouble: double(DataPtr^) := Elements[idx];
        {$ifndef CPU64BITS} ftExtended: extended(DataPtr^) := Elements[idx]; {$endif}

      end;
      DataPtr := Pointer( nativeuint( DataPtr ) + getFloatSize );
    end;
    setElementData(ElementIndex,Length(Elements),Buffer.DataPtr);
  finally
    Buffer := nil;
  end;
end;

end.

