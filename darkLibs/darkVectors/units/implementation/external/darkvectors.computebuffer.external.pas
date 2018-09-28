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
unit darkvectors.computebuffer.external;

interface
uses
  darkvectors.computeengine;

type
  TComputeEngine = class( TInterfacedObject, IComputeEngine )
  private
    function getFloatType: TFloatType;
    function getFloatSize: uint8;
    function getBuffer( ElementCount: uint64 ): IComputeBuffer;
    procedure getSum( Source: IComputeObject; var ScalarResult: float ); overload;
    procedure Addition( Source: IComputeObject; Target: IComputeObject ); overload;
    procedure Addition( Target: IComputeObject; ScalarValue: float ); overload;
    procedure Subtraction( Source: IComputeObject; Target: IComputeObject ); overload;
    procedure Subtraction( Target: IComputeObject; ScalarValue: float ); overload;
    procedure Multiplication( Source: IComputeObject; Target: IComputeObject ); overload;
    procedure Multiplication( Target: IComputeObject; ScalarValue: float ); overload;
    procedure Division( Source: IComputeObject; Target: IComputeObject ); overload;
    procedure Division( Target: IComputeObject; ScalarValue: float ); overload;
    procedure Tanh( Target: IComputeObject );
    procedure ScaledTanh( Target: IComputeObject );
    procedure Sigmoid( Target: IComputeObject  );
    procedure Relu( Target: IComputeObject );
    procedure Elu( Target: IComputeObject );
    procedure Softmax( Target: IComputeObject );
    procedure TanhDerivative( Target: IComputeObject );
    procedure ScaledTanhDerivative( Target: IComputeObject );
    procedure SigmoidDerivative( Target: IComputeObject );
    procedure ReluDerivative( Target: IComputeObject );
    procedure EluDerivative( Target: IComputeObject );
    procedure LinearDerivative( Target: IComputeObject );
    procedure Log( Target: IComputeObject );
    procedure Exp( Target: IComputeObject );
    procedure Fill( Target: IComputeObject; ScalarValue: float );
    procedure Negate( Target: IComputeObject );
    procedure Copy( Source: IComputeObject; Target: IComputeObject );
    procedure DotProduct( SourceA: IComputeObject; SourceB: IComputeObject; Target: IComputeObject ); overload;
    procedure DotProduct( SourceA: IComputeObject; SourceB: IComputeObject; var ScalarResult: float ); overload;
  end;

implementation

{ TComputeEngine }

procedure TComputeEngine.Addition(Source, Target: IComputeObject);
begin

end;

procedure TComputeEngine.Addition(Target: IComputeObject; ScalarValue: float);
begin

end;

procedure TComputeEngine.Copy(Source, Target: IComputeObject);
begin

end;

procedure TComputeEngine.Division(Target: IComputeObject; ScalarValue: float);
begin

end;

procedure TComputeEngine.Division(Source, Target: IComputeObject);
begin

end;

procedure TComputeEngine.DotProduct(SourceA, SourceB, Target: IComputeObject);
begin

end;

procedure TComputeEngine.DotProduct(SourceA, SourceB: IComputeObject; var ScalarResult: float);
begin

end;

procedure TComputeEngine.Elu(Target: IComputeObject);
begin

end;

procedure TComputeEngine.EluDerivative(Target: IComputeObject);
begin

end;

procedure TComputeEngine.Exp(Target: IComputeObject);
begin

end;

procedure TComputeEngine.Fill(Target: IComputeObject; ScalarValue: float);
begin

end;

function TComputeEngine.getBuffer(ElementCount: uint64): IComputeBuffer;
begin

end;

function TComputeEngine.getFloatSize: uint8;
begin

end;

function TComputeEngine.getFloatType: TFloatType;
begin

end;

procedure TComputeEngine.getSum(Source: IComputeObject;
  var ScalarResult: float);
begin

end;

procedure TComputeEngine.LinearDerivative(Target: IComputeObject);
begin

end;

procedure TComputeEngine.Log(Target: IComputeObject);
begin

end;

procedure TComputeEngine.Multiplication(Target: IComputeObject;
  ScalarValue: float);
begin

end;

procedure TComputeEngine.Multiplication(Source, Target: IComputeObject);
begin

end;

procedure TComputeEngine.Negate(Target: IComputeObject);
begin

end;

procedure TComputeEngine.Relu(Target: IComputeObject);
begin

end;

procedure TComputeEngine.ReluDerivative(Target: IComputeObject);
begin

end;

procedure TComputeEngine.ScaledTanh(Target: IComputeObject);
begin

end;

procedure TComputeEngine.ScaledTanhDerivative(Target: IComputeObject);
begin

end;

procedure TComputeEngine.Sigmoid(Target: IComputeObject);
begin

end;

procedure TComputeEngine.SigmoidDerivative(Target: IComputeObject);
begin

end;

procedure TComputeEngine.Softmax(Target: IComputeObject);
begin

end;

procedure TComputeEngine.Subtraction(Target: IComputeObject;
  ScalarValue: float);
begin

end;

procedure TComputeEngine.Subtraction(Source, Target: IComputeObject);
begin

end;

procedure TComputeEngine.Tanh(Target: IComputeObject);
begin

end;

procedure TComputeEngine.TanhDerivative(Target: IComputeObject);
begin

end;

end.
