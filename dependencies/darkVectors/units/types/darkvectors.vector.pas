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
  ///    Represents a vector of floats.
  ///    When a Vector is first assigned, it is automatically allocated on the
  ///    currently selected compute engine (see ComputeEngine).
  ///    Data is only transferred to and from the compute engine when
  ///    assignment is done, or the elements are accessed via the
  ///    Elements property.
  ///  </summary>
  Vector = record
  private
    fEngineBuffer: IComputeBuffer;
    fEngineObject: IComputeObject;
  private
    function Engine: IComputeEngine;
    procedure UploadData( a: TArrayOfFloat );
    procedure DownloadData( var a: TArrayOfFloat );
    function getElement(idx: uint64): float;
    procedure setElement(idx: uint64; const Value: float);
  private
    function Initialized: boolean;

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

    ///  <summary>
    ///    Returns the sum of the elements of the vector.
    ///  </summary>
    function Sum: float;

    ///  <summary>
    ///    Performs the TanH function on the elements of this vector.
    ///  </summary>
    procedure Tanh;

    ///  <summary>
    ///    Performs the ScaledTanH function on the elements of this vector.
    ///  </summary>
    procedure ScaledTanh;

    ///  <summary>
    ///    Performs the Sigmoid function on the elements of this vector.
    ///  </summary>
    procedure Sigmoid;

    ///  <summary>
    ///    Performs the Relu function on the elements of this vector.
    ///  </summary>
    procedure Relu;

    ///  <summary>
    ///    Performs the Elu function on the elements of this vector.
    ///  </summary>
    procedure Elu;

    ///  <summary>
    ///    Performs the Softmax function on this vector.
    ///  </summary>
    procedure Softmax;

    ///  <summary>
    ///    Calculates the derivative of the TanH function on the elements of this vector.
    ///  </summary>
    procedure TanhDerivative;

    ///  <summary>
    ///    Calculates the derivative of the Scaled TanH function on the elements of this vector.
    ///  </summary>
    procedure ScaledTanhDerivative;

    ///  <summary>
    ///    Calculates the derivative of the Sigmoid function on the elements of this vector.
    ///  </summary>
    procedure SigmoidDerivative;

    ///  <summary>
    ///    Calculates the derivative of the Relu function on the elements of this vector.
    ///  </summary>
    procedure ReluDerivative;

    ///  <summary>
    ///    Calculates the derivative of the Elu function on the elements of this vector.
    ///  </summary>
    procedure EluDerivative;

    ///  <summary>
    ///    Calculates the derivative of linear mapping on the elements of this vector.
    ///  </summary>
    procedure LinearDerivative;

    ///  <summary>
    ///    Calculates the natural log of the vector elements.
    ///  </summary>
    procedure Log;

    ///  <summary>
    ///    Calculates the exponent of the vector elements.
    ///  </summary>
    procedure Exp;

    ///  <summary>
    ///    Fills the vector with the specified value.
    ///  </summary>
    procedure Fill(ScalarValue: float);

    ///  <summary>
    ///    Subtracts each element of the vector from zero (thus negating).
    ///  </summary>
    procedure Negate;

  public
    ///  <exlude/>
    ///  Do not use (exposed for access from matrix type)
    function EngineObject( Elements: uint64 = 0 ): IComputeObject;

    ///  <summary>
    ///    Assigns the values of the source vector to this one.
    ///  </summary>
    procedure Assign( SourceVector: Vector );

    ///  <summary>
    ///    Calculates the dot product of the vector b with this one, and returns
    ///    the scalar result.
    ///  </summary>
    function dotProduct( b: Vector ): float;

    ///  <summary>
    ///    Returns the number of elements in this vector.
    ///  </summary>
    function Count: uint64;

    ///  <summary>
    ///    Creates a new vector which has the specified number of elements.
    ///    You may set the optional Fill parameter to specify the value which
    ///    should fill the new vector.
    ///  </summary>
    class function Create( Elements: uint64; Fill: float = 0.0 ): Vector; static;

    ///  <summary>
    ///    Array style access to the elements of the vector.
    ///  </summary>
    property Elements[ idx: uint64 ]: float read getElement write setElement; default;
  end;

implementation
uses
  darkVectors;

{ Vector }

function Vector.Initialized: boolean;
begin
  Result := assigned(fEngineObject);
end;

procedure Vector.LinearDerivative;
begin
  if not Initialized then begin
    exit;
  end;
  Engine.LinearDerivative(EngineObject);
end;

procedure Vector.Log;
begin
  if not Initialized then begin
    exit;
  end;
  Engine.Log(EngineObject);
end;

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
  if Initialized then begin
    Result := EngineObject.Height * EngineObject.Width;
  end;
end;

class function Vector.Create(Elements: uint64; Fill: float): Vector;
begin
  Result.EngineObject(Elements);
  Result.Engine.Fill(Result.EngineObject(), Fill );
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
  if not Initialized then begin
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

procedure Vector.Elu;
begin
  if not Initialized then begin
    exit;
  end;
  Engine.Elu(EngineObject);
end;

procedure Vector.EluDerivative;
begin
  if not Initialized then begin
    exit;
  end;
  Engine.EluDerivative(EngineObject);
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
     (Initialized) and
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

procedure Vector.Exp;
begin
  if not Initialized then begin
    exit;
  end;
  Engine.Exp(EngineObject);
end;

class operator Vector.Explicit(a: Vector): TArrayOfFloat;
begin
  a.DownloadData(Result);
end;

procedure Vector.Fill(ScalarValue: float);
begin
  if not Initialized then begin
    exit;
  end;
  Engine.Fill(EngineObject,ScalarValue);
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

procedure Vector.Negate;
begin
  if not Initialized then begin
    exit;
  end;
  Engine.Negate(EngineObject);
end;

procedure Vector.Relu;
begin
  if not Initialized then begin
    exit;
  end;
  Engine.Relu(EngineObject);
end;

procedure Vector.ReluDerivative;
begin
  if not Initialized then begin
    exit;
  end;
  Engine.ReluDerivative(EngineObject);
end;

procedure Vector.ScaledTanh;
begin
  if not Initialized then begin
    exit;
  end;
  Engine.ScaledTanH(EngineObject);
end;

procedure Vector.ScaledTanhDerivative;
begin
  if not Initialized then begin
    exit;
  end;
  Engine.ScaledTanhDerivative(EngineObject);
end;

procedure Vector.setElement(idx: uint64; const Value: float);
begin
  EngineObject.Elements[idx] := Value;
end;

procedure Vector.Sigmoid;
begin
  if not Initialized then begin
    exit;
  end;
  Engine.Sigmoid(EngineObject);
end;

procedure Vector.SigmoidDerivative;
begin
  if not Initialized then begin
    exit;
  end;
  Engine.SigmoidDerivative(EngineObject);
end;

procedure Vector.Softmax;
begin
  if not Initialized then begin
    exit;
  end;
  Engine.Softmax(EngineObject);
end;

class operator Vector.Subtract(a, b: Vector): Vector;
begin
 Result.Assign(a);
 Result.Engine.Subtraction(b.EngineObject, Result.EngineObject);
end;


function Vector.Sum: float;
begin
  Engine.getSum(Self.EngineObject(),Result);
end;

procedure Vector.Tanh;
begin
  if not Initialized then begin
    exit;
  end;
  Engine.Tanh(EngineObject);
end;

procedure Vector.TanhDerivative;
begin
  if not Initialized then begin
    exit;
  end;
  Engine.TanhDerivative(EngineObject);
end;

procedure Vector.UploadData(a: TArrayOfFloat);
begin
  if not Initialized then begin
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
