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
unit darkvectors.vector;

interface
uses
  darkvectors.computeengine;

type
  ///  <summary>
  ///    Represents a vector of floats. (Internally defined as a column vector).
  ///    When a Vector is first assigned, it is automatically allocated on the
  ///    currently selected math engine (see ComputeEngine).
  ///  </summary>
  Vector = record
  private
    fEngineBuffer: IComputeBuffer; // garunteed nil by compiler.
    fEngineObject: IComputeObject; // garunteed nil by compiler.
  private
    function Engine: IComputeEngine;
    procedure UploadData( a: TArrayOfFloat );
    procedure DownloadData( var a: TArrayOfFloat );
    function getElement(idx: uint64): float;
    procedure setElement(idx: uint64; const Value: float);
  public //- Operator Overloads
    class operator Implicit(a: TArrayOfFloat): Vector;
    class operator Implicit(a: Vector): TArrayOfFloat;
    class operator Explicit(a: TArrayOfFloat): Vector;
    class operator Explicit(a: Vector): TArrayOfFloat;
    class operator Add(a: Vector; b: float): Vector;
    class operator Add(a: Vector; b: Vector): Vector;
    class operator Subtract(a: Vector; b: float): Vector;
    class operator Subtract(a: Vector; b: Vector): Vector;
    class operator Multiply(a: Vector; b: float): Vector;
    class operator Multiply(a: Vector; b: Vector): Vector;
    class operator Divide(a: Vector; b: float): Vector;
    class operator Divide(a: Vector; b: Vector): Vector;
  public
    function EngineObject( Elements: uint64 = 0 ): IComputeObject;
    procedure Assign( SourceVector: Vector );
    function dotProduct( b: Vector ): float;
    function Count: uint64; // Returns the number of elements in the vector.
    property Elements[ idx: uint64 ]: float read getElement write setElement; default;
  end;

implementation
uses
  darkVectors;

{ Vector }

class operator Vector.Add(a: Vector; b: float): Vector;
begin
  Result.Assign(a);
  Result.Engine.Addition(Result.EngineObject, b);
end;

class operator Vector.Add(a, b: Vector): Vector;
begin
 Result.Assign(b);
 Result.Engine.Addition(a.EngineObject,Result.EngineObject);
end;

procedure Vector.Assign(SourceVector: Vector);
begin
  EngineObject( SourceVector.Count ).Engine.Copy( SourceVector.EngineObject(), EngineObject());
end;

function Vector.Count: uint64;
begin
  Result := 0;
  if assigned(EngineObject()) then begin
    Result := EngineObject.Height * EngineObject.Width;
  end;
end;

class operator Vector.Divide(a, b: Vector): Vector;
begin
 Result.Assign(b);
 Result.Engine.Division(a.EngineObject,Result.EngineObject);
end;

function Vector.dotProduct(b: Vector): float;
begin
  Engine.DotProduct(EngineObject,b.EngineObject,Result);
end;

procedure Vector.DownloadData(var a: TArrayOfFloat);
var
  ElementCount: uint64;
begin
  if not assigned(EngineObject()) then begin
    exit;
  end;
  ElementCount := EngineObject.Width*EngineObject.Height;
  SetLength(a,ElementCount);
  EngineObject.getElements(0,ElementCount,a);
end;

class operator Vector.Divide(a: Vector; b: float): Vector;
begin
  Result.Assign(a);
  Result.Engine.Division(Result.EngineObject, b);
end;

function Vector.Engine: IComputeEngine;
begin
  Result := EngineObject.Engine;
end;

function Vector.EngineObject(Elements: uint64): IComputeObject;
begin
  Result := fEngineObject;
  //- If we're requesting zero elements, return the existing object if any.
  if (Elements=0) then begin
    exit;
  end;
  //- If the number of elements in the existing object is correct, simply return it.
  if (Elements<>0) and
     (assigned(fEngineObject)) and
     ((fEngineObject.Width * fEngineObject.Height)=Elements) then begin
    exit;
  end;
  //- Under any other conditions, create a new object.
  fEngineBuffer := ComputeEngine.getBuffer(Elements);
  fEngineObject := fEngineBuffer.getObject(0,Elements,1);
  Result := fEngineObject;
end;

class operator Vector.Explicit(a: TArrayOfFloat): Vector;
begin
  Result.EngineObject(Length(a));
  Result.UploadData(a);
end;

class operator Vector.Explicit(a: Vector): TArrayOfFloat;
begin
  a.DownloadData(Result);
end;

function Vector.getElement(idx: uint64): float;
begin
  Result := EngineObject.Elements[idx];
end;

class operator Vector.Implicit(a: TArrayOfFloat): Vector;
begin
  Result.EngineObject(Length(a));
  Result.UploadData(a);
end;

class operator Vector.Implicit(a: Vector): TArrayOfFloat;
begin
  a.DownloadData(Result);
end;

class operator Vector.Multiply(a: Vector; b: float): Vector;
begin
  Result.Assign(a);
  Result.Engine.Multiplication(Result.EngineObject, b);
end;

class operator Vector.Multiply(a, b: Vector): Vector;
begin
 Result.Assign(b);
 Result.Engine.Multiplication(a.EngineObject,Result.EngineObject);
end;

procedure Vector.setElement(idx: uint64; const Value: float);
begin
  EngineObject.Elements[idx] := Value;
end;

class operator Vector.Subtract(a, b: Vector): Vector;
begin
 Result.Assign(b);
 Result.Engine.Subtraction(a.EngineObject,Result.EngineObject);
end;

procedure Vector.UploadData(a: TArrayOfFloat);
begin
  if not assigned(EngineObject()) then begin
    exit;
  end;
  EngineObject.setElements(0,a);
end;

class operator Vector.Subtract(a: Vector; b: float): Vector;
begin
  Result.Assign(a);
  Result.Engine.Subtraction(Result.EngineObject, b);
end;


end.
