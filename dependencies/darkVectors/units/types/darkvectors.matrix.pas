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

  ///  <summary>
  ///    Represents a matrix of floats.
  ///    When a Matrix is first assigned, it is automatically allocated on the
  ///    currently selected compute engine (see ComputeEngine).
  ///    Data is only transferred to and from the compute engine when
  ///    assignment is done, or the elements are accessed via the
  ///    Elements property.
  ///  </summary>
  Matrix = record
  private
    fEngineBuffer: IComputeBuffer;
    fEngineObject: IComputeObject;
  private
    function Engine: IComputeEngine;
    function EngineObject( Height: uint64 = 0; Width: uint64 = 0 ): IComputeObject;
    procedure UploadData( a: TArrayOfArrayOfFloat );
    procedure DownloadData( var a: TArrayOfArrayOfFloat );
    procedure Assign( SourceMatrix: Matrix );
    function getElement(idy: uint64; idx: uint64): float;
    procedure setElement(idy: uint64; idx: uint64; const Value: float);
    function Initialized: boolean;
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
    ///  <summary>
    ///    Returns a new vector which contains the dot product of this
    ///    matrix with the provided vector.
    ///  </summary>
    function dotProduct(b: Vector): Vector; overload;

    ///  <summary>
    ///    Returns a new matrix which is the dot product of this one with
    ///    the provided multiplier matrix.
    ///  </summary>
    function dotProduct(b: Matrix): Matrix; overload;

    ///  <summary>
    ///    Returns a new matrix with the same content as this one, but with
    ///    the dimensions transposed.
    ///  </summary>
    function Transpose: Matrix;

    ///  <summary>
    ///    Returns a new vector containing the contents of the specified
    ///    matrix row.
    ///  </summary>
    function ExtractRow( Row: uint64 ): Vector;

    ///  <summary>
    ///    Returns a new vector containing the contents of the specified
    ///    matrix column.
    ///  </summary>
    function ExtractColumn( Column: uint64 ): Vector;

    ///  <summary>
    ///    Overwrites the specified row of the matrix with the
    ///    provided vector.
    ///  </summary>
    procedure InsertRow( Row: uint64; Value: Vector );

    ///  <summary>
    ///    Overwrites the specified column of the matrix with
    ///    the provided vector.
    ///  </summary>
    procedure InsertColumn( Column: uint64; Value: Vector );

    ///  <summary>
    ///    Element wise addition of vector to row of matrix.
    ///  </summary>
    procedure AddVectorToRow( Row: uint64; Value: Vector );

    ///  <summary>
    ///    Element wise subtraction of vector from row of matrix.
    ///  </summary>
    procedure SubtractVectorFromRow( Row: uint64; Value: Vector );

    ///  <summary>
    ///    Element wise multiplication of row of matrix by vector.
    ///  </summary>
    procedure MultiplyRowByVector( Row: uint64; Value: Vector );

    ///  <summary>
    ///    Element wise division of row of matrix by vector.
    ///  </summary>
    procedure DivideRowByVector( Row: uint64; Value: Vector );

    ///  <summary>
    ///    Element wise addition of vector to column of matrix.
    ///  </summary>
    procedure AddVectorToColumn( Column: uint64; Value: Vector );

    ///  <summary>
    ///    Element wise subtraction of vector from column of matrix.
    ///  </summary>
    procedure SubtractVectorFromColumn( Column: uint64; Value: Vector );

    ///  <summary>
    ///    Element wise multiplication of column of matrix by vector.
    ///  </summary>
    procedure MultiplyColumnByVector( Column: uint64; Value: Vector );

    ///  <summary>
    ///    Element wise division of column of matrix by vector.
    ///  </summary>
    procedure DivideColumnByVector( Column: uint64; Value: Vector );

    ///  <summary>
    ///    Returns the width of the matrix.
    ///  </summary>
    function Width: uint64;

    ///  <summary>
    ///    Returns the height of the matrix.
    ///  </summary>
    function Height: uint64;

    ///  <summary>
    ///    Creates a new matrix which has the specified dimensions.
    ///    You may set the optional Fill parameter to specify the value which
    ///    should fill the new matrix.
    ///  </summary>
    class function Create( Height: uint64; Width: uint64; Fill: float = 0.0 ): Matrix; static;

    ///  <summary>
    ///    Array style access to the elements of the matrix by Row x Column index.
    ///  </summary>
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

procedure Matrix.AddVectorToColumn(Column: uint64; Value: Vector);
begin
  Engine.AddOnColumn(Value.EngineObject,Self.EngineObject,Column);
end;

procedure Matrix.AddVectorToRow(Row: uint64; Value: Vector);
begin
  Engine.AddOnRow(Value.EngineObject,Self.EngineObject,Row);
end;

procedure Matrix.Assign(SourceMatrix: Matrix);
begin
  EngineObject( SourceMatrix.Height, SourceMatrix.Width ).Engine.Copy( SourceMatrix.EngineObject(), EngineObject() );
end;

class function Matrix.Create(Height, Width: uint64; Fill: float = 0.0): Matrix;
begin
  Result.EngineObject(Height,Width);
  Result.Engine.Fill(Result.EngineObject(), Fill );
end;

class operator Matrix.Divide(a, b: Matrix): Matrix;
begin
 Result.Assign(b);
 Result.Engine.Division(a.EngineObject,Result.EngineObject);
end;

procedure Matrix.DivideColumnByVector(Column: uint64; Value: Vector);
begin
  Engine.DivideOnColumn(Value.EngineObject,Self.EngineObject,Column);
end;

procedure Matrix.DivideRowByVector(Row: uint64; Value: Vector);
begin
  Engine.DivideOnRow(Value.EngineObject,Self.EngineObject,Row);
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
  if not Initialized then begin
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
     (Initialized) and
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

function Matrix.ExtractColumn(Column: uint64): Vector;
begin
  Result.EngineObject(Self.Height);
  Engine.ExtractColumn(Self.EngineObject,Result.EngineObject,Column);
end;

function Matrix.ExtractRow(Row: uint64): Vector;
begin
  Result.EngineObject(Self.Width);
  Engine.ExtractRow(Self.EngineObject,Result.EngineObject,Row);
end;

function Matrix.getElement(idy: uint64; idx: uint64): float;
begin
  Result := EngineObject.Elements[ (idy*EngineObject.Width)+idx ];
end;

function Matrix.Initialized: boolean;
begin
  Result := assigned(fEngineObject);
end;

procedure Matrix.InsertColumn(Column: uint64; Value: Vector);
begin
  Engine.InsertColumn(Value.EngineObject,Self.EngineObject,Column);
end;

procedure Matrix.InsertRow(Row: uint64; Value: Vector);
begin
  Engine.InsertRow(Value.EngineObject,Self.EngineObject,Row);
end;

function Matrix.Height: uint64;
begin
  Result := 0;
  if Initialized then begin
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

procedure Matrix.MultiplyColumnByVector(Column: uint64; Value: Vector);
begin
  Engine.MultiplyOnColumn(Value.EngineObject,Self.EngineObject,Column);
end;

procedure Matrix.MultiplyRowByVector(Row: uint64; Value: Vector);
begin
  Engine.MultiplyOnRow(Value.EngineObject,Self.EngineObject,Row);
end;

procedure Matrix.setElement(idy: uint64; idx: uint64; const Value: float);
begin
  EngineObject.Elements[ (idy*EngineObject.Width)+idx ] := Value;
end;

class operator Matrix.Subtract(a, b: Matrix): Matrix;
begin
 Result.Assign(a);
 Result.Engine.Subtraction(b.EngineObject,Result.EngineObject);
end;

procedure Matrix.SubtractVectorFromColumn(Column: uint64; Value: Vector);
begin
  Engine.SubtractOnColumn(Value.EngineObject,Self.EngineObject,Column);
end;

procedure Matrix.SubtractVectorFromRow(Row: uint64; Value: Vector);
begin
  Engine.SubtractOnRow(Value.EngineObject,Self.EngineObject,Row);
end;

function Matrix.Transpose: Matrix;
begin
  Result.EngineObject(Width,Height);
  Result.Engine.Transpose( Self.EngineObject, Result.EngineObject );
end;

procedure Matrix.UploadData(a: TArrayOfArrayOfFloat);
var
  Row: uint64;
begin
  if not Initialized then begin
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
  if Initialized then begin
    Result := EngineObject.Width;
  end;
end;

class operator Matrix.Subtract(a: Matrix; b: float): Matrix;
begin
  Result.Assign(a);
  Result.Engine.Subtraction(Result.EngineObject, b);
end;


end.
