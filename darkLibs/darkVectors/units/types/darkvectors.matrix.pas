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
unit darkvectors.matrix;

interface
uses
  darkvectors.computeengine,
  darkvectors.vector;

type
  ///  <summary>
  ///    For assignment to the Matrix type, the TArrayOfArrayOfFloat type
  ///    is used to define an array of row vectors, themselves defined as
  ///    arrays of floats. This enables the Matrix record to determine it's
  ///    dimensions from the array which is assigned to it.
  ///  </summary>
  TArrayOfArrayOfFloat = array of TArrayOfFloat;


  Matrix = record
  private
    fEngineBuffer: IComputeBuffer; // garunteed nil by compiler.
    fEngineObject: IComputeObject; // garunteed nil by compiler.
  private
    function Engine: IComputeEngine;
    function EngineObject( Height: uint64 = 0; Width: uint64 = 0 ): IComputeObject;
    procedure UploadData( a: TArrayOfArrayOfFloat );
    procedure DownloadData( var a: TArrayOfArrayOfFloat );
    procedure Assign( SourceMatrix: Matrix );
    function getElement(idy: uint64; idx: uint64): float;
    procedure setElement(idy: uint64; idx: uint64; const Value: float);
  public //- Operator overloads.
    class operator Implicit(a: TArrayOfArrayOfFloat): Matrix;
    class operator Implicit(a: Matrix): TArrayOfArrayOfFloat;
    class operator Explicit(a: TArrayOfArrayOfFloat): Matrix;
    class operator Explicit(a: Matrix): TArrayOfArrayOfFloat;
    class operator Add(a: Matrix; b: float): Matrix;
    class operator Add(a: Matrix; b: Matrix): Matrix;
    class operator Subtract(a: Matrix; b: float): Matrix;
    class operator Subtract(a: Matrix; b: Matrix): Matrix;
    class operator Multiply(a: Matrix; b: float): Matrix;
    class operator Multiply(a: Matrix; b: Matrix): Matrix;
    class operator Divide(a: Matrix; b: float): Matrix;
    class operator Divide(a: Matrix; b: Matrix): Matrix;
  public
    function dotProduct(b: Vector): Vector; overload;
    function dotProduct(b: Matrix): Matrix; overload;
    function Transpose: Matrix;

    function Width: uint64;
    function Height: uint64;
    property Elements[ idy: uint64; idx: uint64 ]: float read getElement write setElement; default;
  end;

implementation
uses
  darkvectors;

{ Matrix }

class operator Matrix.Add(a: Matrix; b: float): Matrix;
begin
  Result.Assign(a);
  Result.Engine.Addition(Result.EngineObject, b);
end;

class operator Matrix.Add(a, b: Matrix): Matrix;
begin
 Result.Assign(b);
 Result.Engine.Addition(a.EngineObject,Result.EngineObject);
end;

procedure Matrix.Assign(SourceMatrix: Matrix);
begin
  EngineObject( SourceMatrix.Height, SourceMatrix.Width ).Engine.Copy( SourceMatrix.EngineObject(), EngineObject() );
end;

class operator Matrix.Divide(a, b: Matrix): Matrix;
begin
 Result.Assign(b);
 Result.Engine.Division(a.EngineObject,Result.EngineObject);
end;

function Matrix.dotProduct(b: Matrix): Matrix;
begin
  Result.EngineObject(Height,b.Width);
  Engine.DotProduct(Self.EngineObject(),b.EngineObject(),Result.EngineObject);
end;

function Matrix.dotProduct(b: Vector): Vector;
begin
  Result.Assign(b);
  Engine.DotProduct(Self.EngineObject(),b.EngineObject(),Result.EngineObject);
end;

procedure Matrix.DownloadData(var a: TArrayOfArrayOfFloat);
var
  Row: uint64;
begin
  if not assigned(EngineObject()) then begin
    exit;
  end;
  SetLength(a,EngineObject.Height);
  for Row := 0 to pred(EngineObject.Height) do begin
    SetLength( a[Row], EngineObject.Width );
    EngineObject.getElements(Row*EngineObject.Width,EngineObject.Width,a[Row]);
  end;
end;


class operator Matrix.Divide(a: Matrix; b: float): Matrix;
begin
  Result.Assign(a);
  Result.Engine.Division(Result.EngineObject, b);
end;

class operator Matrix.Explicit(a: TArrayOfArrayOfFloat): Matrix;
begin
  Result.EngineObject(Length(a),Length(a[0]));
  Result.UploadData(a);
end;

function Matrix.Engine: IComputeEngine;
begin
  Result := EngineObject.Engine;
end;

function Matrix.EngineObject(Height, Width: uint64): IComputeObject;
begin
  Result := fEngineObject;
  //- If we're requesting 0's, return the existing object if any.
  if (Width=0) or (Height=0) then begin
    exit;
  end;
  //- If the number of elements in the existing object is correct, simply return it.
  if ((Width<>0) and (Height<>0)) and
     (assigned(fEngineObject)) and
     ( (fEngineObject.Width=Width) and (fEngineObject.Height=Height)) then begin
    exit;
  end;
  //- Under any other conditions, create a new object.
  fEngineBuffer := ComputeEngine.getBuffer(Width*Height);
  fEngineObject := fEngineBuffer.getObject(0,Height,Width);
  Result := fEngineObject;
end;

class operator Matrix.Explicit(a: Matrix): TArrayOfArrayOfFloat;
begin
  a.DownloadData(Result);
end;

function Matrix.getElement(idy: uint64; idx: uint64): float;
begin
  Result := EngineObject.Elements[ (idy*EngineObject.Width)+idx ];
end;

function Matrix.Height: uint64;
begin
  Result := 0;
  if assigned(EngineObject()) then begin
    Result := EngineObject.Height;
  end;
end;

class operator Matrix.Implicit(a: TArrayOfArrayOfFloat): Matrix;
begin
  Result.EngineObject(Length(a),Length(a[0]));
  Result.UploadData(a);
end;

class operator Matrix.Implicit(a: Matrix): TArrayOfArrayOfFloat;
begin
  a.DownloadData(Result);
end;

class operator Matrix.Multiply(a: Matrix; b: float): Matrix;
begin
  Result.Assign(a);
  Result.Engine.Multiplication(Result.EngineObject, b);
end;

class operator Matrix.Multiply(a, b: Matrix): Matrix;
begin
 Result.Assign(b);
 Result.Engine.Multiplication(a.EngineObject,Result.EngineObject);
end;

procedure Matrix.setElement(idy: uint64; idx: uint64; const Value: float);
begin
  EngineObject.Elements[ (idy*EngineObject.Width)+idx ] := Value;
end;

class operator Matrix.Subtract(a, b: Matrix): Matrix;
begin
 Result.Assign(b);
 Result.Engine.Subtraction(a.EngineObject,Result.EngineObject);
end;

function Matrix.Transpose: Matrix;
begin
  Result.EngineObject(Width,Height);
  Result.Engine.Copy(Self.EngineObject,Result.EngineObject);
end;

procedure Matrix.UploadData(a: TArrayOfArrayOfFloat);
var
  Row: uint64;
begin
  if not assigned(EngineObject()) then begin
    exit;
  end;
  if Length(a)<1 then begin
    exit;
  end;
  for Row := 0 to pred(Length(a)) do begin
    if Length(a[Row])<>EngineObject.Width then begin
      exit;
    end;
    EngineObject.setElements(Row*EngineObject.Width,a[Row]);
  end;
end;

function Matrix.Width: uint64;
begin
  Result := 0;
  if assigned(EngineObject()) then begin
    Result := EngineObject.Width;
  end;
end;

class operator Matrix.Subtract(a: Matrix; b: float): Matrix;
begin
  Result.Assign(a);
  Result.Engine.Subtraction(Result.EngineObject, b);
end;


end.
