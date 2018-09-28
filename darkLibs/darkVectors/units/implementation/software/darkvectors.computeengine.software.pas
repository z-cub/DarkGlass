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
unit darkvectors.computeengine.software;

interface
uses
  darkvectors.computeengine;

type
  TComputeEngine = class( TInterfacedObject, IComputeEngine )
  private
    fFloatType: TFloatType;
  private // utilities.
    procedure ValidObject( EngineObject: IComputeObject ); inline;
    procedure SizeMatch(SizeA, SizeB: uint64); inline;

    function GetObjectPointer(anObject: IComputeObject): pointer; inline;
    function AsPtr( anObject: IComputeObject; ElementIndex: uint64 ): pointer; inline;
    function XYPtr( anObject: IComputeObject; Idx: uint64; Idy: uint64 ): pointer; inline;

    procedure DotProductMatrix(SourceA, SourceB, Target: IComputeObject);
    procedure DotProductMatrixVector(SourceA, SourceB, Target: IComputeObject);

  private //- IComputeEngine -//
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
  public
    constructor Create(FloatType: TFloatType);
    destructor Destroy; override;
  end;


implementation
uses
  sysutils,
  math,
  darkvectors.halftype,
  darkvectors.computebuffer.software,
  darkIO.buffers;


procedure TComputeEngine.ValidObject( EngineObject: IComputeObject );
begin
  if EngineObject.Engine<>(Self as IComputeEngine) then begin
    raise
      Exception.Create('Software: Math engine mismatch.');
  end;
end;

procedure TComputeEngine.SizeMatch( SizeA: uint64; SizeB: uint64 );
begin
  if SizeA<>SizeB then begin
    raise
      Exception.Create('Software: Engine object sizes do not meet operation requirements.');
  end;
end;

function TComputeEngine.GetObjectPointer( anObject: IComputeObject ): pointer;
begin
  Result := pointer(nativeuint( IBuffer(anObject.Buffer.getHandle).DataPtr ) + anObject.getOffset);
end;

procedure TComputeEngine.Addition(Source, Target: IComputeObject);
var
  idx: uint32;
  ElementCount: uint32;
begin
  //- Validate
  ValidObject(Source);
  ValidObject(Target);
  ElementCount := Source.Height*Source.Width;
  SizeMatch( ElementCount, Target.Height * Target.Width );
  //- Loop all elements in source and target
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
      ftHalf:     half(AsPtr(Target,idx)^)     := half(AsPtr(Target,idx)^)     + half(AsPtr(Source,idx)^);
      ftSingle:   single(AsPtr(Target,idx)^)   := single(AsPtr(Target,idx)^)   + single(AsPtr(Source,idx)^);
      ftDouble:   double(AsPtr(Target,idx)^)   := double(AsPtr(Target,idx)^)   + double(AsPtr(Source,idx)^);
    end;
  end;
end;


procedure TComputeEngine.Addition(Target: IComputeObject; ScalarValue: float);
var
  idx: uint32;
  ElementCount: uint32;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
          ftHalf: half(AsPtr(Target,idx)^)     := half(AsPtr(Target,idx)^)     + ScalarValue;
        ftSingle: single(AsPtr(Target,idx)^)   := single(AsPtr(Target,idx)^)   + ScalarValue;
        ftDouble: double(AsPtr(Target,idx)^)   := double(AsPtr(Target,idx)^)   + ScalarValue;
    end;
  end;
end;

procedure TComputeEngine.Copy(Source, Target: IComputeObject);
begin
  //- Validate
  ValidObject(Source);
  ValidObject(Target);
  SizeMatch( Source.Height*Source.Width, Target.Height*Target.Width );
  //- Perform copy
  Move( GetObjectPointer(Source)^, GetObjectPointer(Target)^, Source.Engine.FloatSize * Source.Width * Source.Height );
end;

constructor TComputeEngine.Create( FloatType: TFloatType );
var
  TempUID: TGUID;
begin
  inherited Create;
  CreateGUID(TempUID);
  fFloatType := FloatType;
end;

destructor TComputeEngine.Destroy;
begin
  inherited Destroy;
end;

procedure TComputeEngine.Division(Source, Target: IComputeObject);
var
  idx: uint32;
  ElementCount: uint32;
begin
  //- Validate
  ValidObject(Source);
  ValidObject(Target);
  ElementCount := Source.Height*Source.Width;
  SizeMatch( ElementCount, Target.Height * Target.Width );
  //- Loop all elements in source and target
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
        ftHalf: half(AsPtr(Target,idx)^)       := half(AsPtr(Target,idx)^)   / half(AsPtr(Source,idx)^);
      ftSingle: single(AsPtr(Target,idx)^)     := single(AsPtr(Target,idx)^) / single(AsPtr(Source,idx)^);
      ftDouble: double(AsPtr(Target,idx)^)     := double(AsPtr(Target,idx)^) / double(AsPtr(Source,idx)^);
    end;
  end;
end;


procedure TComputeEngine.Division(Target: IComputeObject; ScalarValue: float);
var
  idx: uint32;
  ElementCount: uint32;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
        ftHalf: half(AsPtr(Target,idx)^)       := half(AsPtr(Target,idx)^)   / ScalarValue;
      ftSingle: single(AsPtr(Target,idx)^)     := single(AsPtr(Target,idx)^) / ScalarValue;
      ftDouble: double(AsPtr(Target,idx)^)     := double(AsPtr(Target,idx)^) / ScalarValue;
    end;
  end;
end;


procedure TComputeEngine.Elu(Target: IComputeObject);
var
  idx: uint32;
  ElementCount: uint32;
  aSingle: single;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of

      ftHalf: begin
        aSingle := half(AsPtr(Target,idx)^);
        if (aSingle<0) then begin
          half(AsPtr(Target,idx)^) := system.exp( half(AsPtr(Target,idx)^)-1 );
        end;
      end;

      ftSingle: begin
        if (single(AsPtr(Target,idx)^)<0) then begin
          single(AsPtr(Target,idx)^) := system.exp( single(AsPtr(Target,idx)^)-1 );
        end;
      end;

      ftDouble: begin
        if (double(AsPtr(Target,idx)^)<0) then begin
          double(AsPtr(Target,idx)^) := system.exp( double(AsPtr(Target,idx)^)-1 );
        end;
      end;

    end;
  end;
end;

procedure TComputeEngine.EluDerivative(Target: IComputeObject);
var
  idx: uint32;
  ElementCount: uint32;
  aSingle: single;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of

      ftHalf: begin
        aSingle := half(AsPtr(Target,idx)^);
        if aSingle>0 then begin
          half(AsPtr(Target,idx)^):=1;
        end else begin
          half(AsPtr(Target,idx)^):=half(AsPtr(Target,idx)^)+1;
        end;
      end;

      ftSingle: begin
        if single(AsPtr(Target,idx)^)>0 then begin
          single(AsPtr(Target,idx)^):=1;
        end else begin
          single(AsPtr(Target,idx)^):=single(AsPtr(Target,idx)^)+1;
        end;
      end;

      ftDouble: begin
        if double(AsPtr(Target,idx)^)>0 then begin
          double(AsPtr(Target,idx)^):=1;
        end else begin
          double(AsPtr(Target,idx)^):=double(AsPtr(Target,idx)^)+1;
        end;
      end;

    end;
  end;
end;

procedure TComputeEngine.Exp(Target: IComputeObject);
var
  idx: uint32;
  ElementCount: uint32;
  S: single;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop elements and perform exponent.
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
        ftHalf: begin
          S := half(AsPtr(Target,idx)^);
          half(AsPtr(Target,idx)^) := system.exp( S );
        end;
      ftSingle: begin
        single(AsPtr(Target,idx)^) := system.exp( single(AsPtr(Target,idx)^) );
      end;
      ftDouble: begin
        double(AsPtr(Target,idx)^) := system.exp( double(AsPtr(Target,idx)^) );
      end;
    end;
  end;
end;

procedure TComputeEngine.Fill(Target: IComputeObject; ScalarValue: float);
var
  idx: uint32;
  ElementCount: uint32;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
          ftHalf: half(AsPtr(Target,idx)^)     := ScalarValue;
        ftSingle: single(AsPtr(Target,idx)^)   := ScalarValue;
        ftDouble: double(AsPtr(Target,idx)^)   := ScalarValue;
    end;
  end;
end;

function TComputeEngine.getBuffer(ElementCount: uint64): IComputeBuffer;
begin
  Result := TComputeBuffer.Create( Self,  ElementCount*getFloatSize );
end;

function TComputeEngine.AsPtr(anObject: IComputeObject; ElementIndex: uint64): pointer;
begin
  Result := pointer(
    (nativeuint( IBuffer(anObject.Buffer.getHandle).DataPtr )+anObject.getOffset) +
    (anObject.Engine.FloatSize * ElementIndex)
  );
end;

function TComputeEngine.XYPtr(anObject: IComputeObject; Idx, Idy: uint64): pointer;
begin
  Result := pointer(
    (nativeuint( IBuffer(anObject.Buffer.getHandle).DataPtr )+anObject.getOffset) +
    ((anObject.Engine.FloatSize * Idy * anObject.Width) + (anObject.Engine.FLoatSize * Idx))
  );
end;

function TComputeEngine.getFloatSize: uint8;
begin
  Result := 0;
  case getFloatType of
    ftHalf: Result := 2;
    ftSingle: Result := 4;
    ftDouble: Result := 8;
  end;
end;

function TComputeEngine.getFloatType: TFloatType;
begin
  Result := TFloatType.ftSingle;
end;

procedure TComputeEngine.LinearDerivative(Target: IComputeObject);
var
  idx: uint32;
  ElementCount: uint32;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
      ftHalf: half(AsPtr(Target,idx)^)         := 1;
      ftSingle: single(AsPtr(Target,idx)^)     := 1;
      ftDouble: double(AsPtr(Target,idx)^)     := 1;
    end;
  end;
end;

procedure TComputeEngine.Log(Target: IComputeObject);
var
  idx: uint32;
  ElementCount: uint32;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
          ftHalf: half(AsPtr(Target,idx)^)     := ln(half(AsPtr(Target,idx)^));
        ftSingle: single(AsPtr(Target,idx)^)   := ln(single(AsPtr(Target,idx)^));
        ftDouble: double(AsPtr(Target,idx)^)   := ln(double(AsPtr(Target,idx)^));
    end;
  end;
end;

procedure TComputeEngine.Multiplication(Target: IComputeObject; ScalarValue: float);
var
  idx: uint32;
  ElementCount: uint32;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
          ftHalf: half(AsPtr(Target,idx)^)     := half(AsPtr(Target,idx)^)   * ScalarValue;
        ftSingle: single(AsPtr(Target,idx)^)   := single(AsPtr(Target,idx)^) * ScalarValue;
        ftDouble: double(AsPtr(Target,idx)^)   := double(AsPtr(Target,idx)^) * ScalarValue;
    end;
  end;
end;

procedure TComputeEngine.Multiplication(Source, Target: IComputeObject);
var
  idx: uint32;
  ElementCount: uint32;
begin
  //- Validate
  ValidObject(Source);
  ValidObject(Target);
  ElementCount := Source.Height*Source.Width;
  SizeMatch( ElementCount, Target.Height * Target.Width );
  //- Loop all elements in source and target
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
          ftHalf: half(AsPtr(Target,idx)^)     := half(AsPtr(Target,idx)^)     * half(AsPtr(Source,idx)^);
        ftSingle: single(AsPtr(Target,idx)^)   := single(AsPtr(Target,idx)^)   * single(AsPtr(Source,idx)^);
        ftDouble: double(AsPtr(Target,idx)^)   := double(AsPtr(Target,idx)^)   * double(AsPtr(Source,idx)^);
    end;
  end;
end;


procedure TComputeEngine.Negate(Target: IComputeObject);
var
  idx: uint32;
  ElementCount: uint32;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
          ftHalf: half(AsPtr(Target,idx)^)     := 0-half(AsPtr(Target,idx)^);
        ftSingle: single(AsPtr(Target,idx)^)   := 0-single(AsPtr(Target,idx)^);
        ftDouble: double(AsPtr(Target,idx)^)   := 0-double(AsPtr(Target,idx)^);
    end;
  end;
end;

procedure TComputeEngine.Relu(Target: IComputeObject);
var
  idx: uint32;
  ElementCount: uint32;
  aSingle: single;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
      ftHalf: begin
        aSingle := half(AsPtr(Target,idx)^);
        if (aSingle<0) then begin
          half(AsPtr(Target,idx)^) := 0;
        end;
      end;
      ftSingle: begin
        if (single(AsPtr(Target,idx)^)<0) then begin
          single(AsPtr(Target,idx)^) := 0;
        end;
      end;
      ftDouble: begin
        if (double(AsPtr(Target,idx)^)<0) then begin
          double(AsPtr(Target,idx)^) := 0;
        end;
      end;
    end;
  end;
end;

procedure TComputeEngine.ReluDerivative(Target: IComputeObject);
var
  idx: uint32;
  ElementCount: uint32;
  aSingle: single;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
      ftHalf: begin
        aSingle := half(AsPtr(Target,idx)^);
        if aSingle>0 then begin
          half(AsPtr(Target,idx)^):=1;
        end else begin
          half(AsPtr(Target,idx)^):=0;
        end;
      end;
      ftSingle: begin
        if single(AsPtr(Target,idx)^)>0 then begin
          single(AsPtr(Target,idx)^):=1;
        end else begin
          single(AsPtr(Target,idx)^):=0;
        end;
      end;
      ftDouble: begin
        if double(AsPtr(Target,idx)^)>0 then begin
          double(AsPtr(Target,idx)^):=1;
        end else begin
          double(AsPtr(Target,idx)^):=0;
        end;
      end;
    end;
  end;
end;


procedure TComputeEngine.ScaledTanh(Target: IComputeObject);
var
  idx: uint32;
  ElementCount: uint32;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
      ftHalf: begin
        half(AsPtr(Target,idx)^) := 1.7159*math.tanh(half(AsPtr(Target,idx)^)*0.66667);
      end;
      ftSingle: begin
        single(AsPtr(Target,idx)^) := 1.7159*math.tanh(single(AsPtr(Target,idx)^)*0.66667);
      end;
      ftDouble: begin
        double(AsPtr(Target,idx)^) := 1.7159*math.tanh(double(AsPtr(Target,idx)^)*0.66667);
      end;
    end;
  end;
end;


procedure TComputeEngine.ScaledTanhDerivative(Target: IComputeObject);
var
  idx: uint32;
  ElementCount: uint32;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
      ftHalf: begin
        half(AsPtr(Target,idx)^) := (0.66667*(1.7159-1/1.7159*  half(AsPtr(Target,idx)^)*half(AsPtr(Target,idx)^)));
      end;
      ftSingle: begin
        single(AsPtr(Target,idx)^) := (0.66667*(1.7159-1/1.7159*single(AsPtr(Target,idx)^)*single(AsPtr(Target,idx)^)));
      end;
      ftDouble: begin
        double(AsPtr(Target,idx)^) := (0.66667*(1.7159-1/1.7159*double(AsPtr(Target,idx)^)*double(AsPtr(Target,idx)^)));
      end;
    end;
  end;
end;

procedure TComputeEngine.Sigmoid(Target: IComputeObject);
var
  idx: uint32;
  ElementCount: uint32;
  aSingle: single;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
      ftHalf: begin
        aSingle := half(AsPtr(Target,idx)^);
        aSingle := (1.0/(1+system.exp(-aSingle)));
        half(AsPtr(Target,idx)^) := aSingle;
      end;
      ftSingle: begin
        single(AsPtr(Target,idx)^) := (1.0/(1+system.exp(-single(AsPtr(Target,idx)^))));
      end;
      ftDouble: begin
        double(AsPtr(Target,idx)^) := (1.0/(1+system.exp(-double(AsPtr(Target,idx)^))));
      end;
    end;
  end;
end;


procedure TComputeEngine.SigmoidDerivative(Target: IComputeObject);
var
  idx: uint32;
  ElementCount: uint32;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
      ftHalf: begin
        half(AsPtr(Target,idx)^) := (half(AsPtr(Target,idx)^)*(1-half(AsPtr(Target,idx)^)));
      end;
      ftSingle: begin
        single(AsPtr(Target,idx)^) := (single(AsPtr(Target,idx)^)*(1-single(AsPtr(Target,idx)^)));
      end;
      ftDouble: begin
        double(AsPtr(Target,idx)^) := (double(AsPtr(Target,idx)^)*(1-double(AsPtr(Target,idx)^)));
      end;
    end;
  end;
end;

procedure TComputeEngine.Softmax(Target: IComputeObject);
var
  S: float;
begin
  Self.Exp(Target);
  Self.getSum(Target,S);
  Self.Division(Target,S);
end;

procedure TComputeEngine.Subtraction(Target: IComputeObject; ScalarValue: float);
var
  idx: uint32;
  ElementCount: uint32;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
        ftHalf: half(AsPtr(Target,idx)^)       := half(AsPtr(Target,idx)^)   - ScalarValue;
      ftSingle: single(AsPtr(Target,idx)^)     := single(AsPtr(Target,idx)^) - ScalarValue;
      ftDouble: double(AsPtr(Target,idx)^)     := double(AsPtr(Target,idx)^) - ScalarValue;
    end;
  end;
end;


procedure TComputeEngine.Subtraction(Source, Target: IComputeObject);
var
  idx: uint32;
  ElementCount: uint32;
begin
  //- Validate
  ValidObject(Source);
  ValidObject(Target);
  ElementCount := Source.Height*Source.Width;
  SizeMatch( ElementCount, Target.Height * Target.Width );
  //- Loop all elements in source and target
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
        ftHalf: half(AsPtr(Target,idx)^)   := half(AsPtr(Target,idx)^)   - half(AsPtr(Source,idx)^);
      ftSingle: single(AsPtr(Target,idx)^) := single(AsPtr(Target,idx)^) - single(AsPtr(Source,idx)^);
      ftDouble: double(AsPtr(Target,idx)^) := double(AsPtr(Target,idx)^) - double(AsPtr(Source,idx)^);
    end;
  end;
end;


procedure TComputeEngine.Tanh(Target: IComputeObject);
var
  idx: uint32;
  ElementCount: uint32;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
          ftHalf: half(AsPtr(Target,idx)^)     := math.tanh(half(AsPtr(Target,idx)^));
        ftSingle: single(AsPtr(Target,idx)^)   := math.tanh(single(AsPtr(Target,idx)^));
        ftDouble: double(AsPtr(Target,idx)^)   := math.tanh(double(AsPtr(Target,idx)^));
    end;
  end;
end;

procedure TComputeEngine.TanhDerivative(Target: IComputeObject);
var
  idx: uint32;
  ElementCount: uint32;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
          ftHalf: half(AsPtr(Target,idx)^)     := (1- half(AsPtr(Target,idx)^)*half(AsPtr(Target,idx)^));
        ftSingle: single(AsPtr(Target,idx)^)   := (1- single(AsPtr(Target,idx)^)*single(AsPtr(Target,idx)^));
        ftDouble: double(AsPtr(Target,idx)^)   := (1- double(AsPtr(Target,idx)^)*double(AsPtr(Target,idx)^));
    end;
  end;
end;

procedure TComputeEngine.getSum( Source: IComputeObject; var ScalarResult: float );
var
  idx: uint32;
  ElementCount: uint32;
begin
  //- Validate
  ValidObject(Source);
  ElementCount := Source.Height*Source.Width;
  //- Loop all elements in Source
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
          ftHalf: ScalarResult := ScalarResult + half(AsPtr(Source,idx)^);
        ftSingle: ScalarResult := ScalarResult + single(AsPtr(Source,idx)^);
        ftDouble: ScalarResult := ScalarResult + double(AsPtr(Source,idx)^);
    end;
  end;
end;

procedure TComputeEngine.DotProductMatrix( SourceA: IComputeObject; SourceB: IComputeObject; Target: IComputeObject );
var
  TargetColumn: uint64;
  TargetRow: uint64;
  SourceColumn: uint64;
begin
  //- Ensure all three objects are valid.
  ValidObject(SourceA);
  ValidObject(SourceB);
  ValidObject(Target);
  //- Ensure the Width of A matches the height of B.
  SizeMatch(SourceA.Width,SourceB.Height);
  //- Ensure the target is the correct dimensions for the result.
  SizeMatch(Target.Width, SourceB.Width);
  SizeMatch(Target.Height, SourceA.Height);
  Self.Fill(Target,0);
  //- Now we can loop the elements in each object to calculate the results
  for TargetColumn := 0 to pred(Target.Width) do begin
    for TargetRow := 0 to pred(Target.Height) do begin
      for SourceColumn := 0 to pred(SourceA.Width) do begin
        case getFloatType of

              ftHalf: half(XYPtr(Target,TargetColumn,TargetRow)^) :=
                      half(XYPtr(Target,TargetColumn,TargetRow)^) +
                      half(XYPtr(SourceA,SourceColumn,TargetRow)^) *
                      half(XYPtr(SourceB,TargetColumn,SourceColumn)^);

            ftSingle: single(XYPtr(Target,TargetColumn,TargetRow)^) :=
                      single(XYPtr(Target,TargetColumn,TargetRow)^) +
                      single(XYPtr(SourceA,SourceColumn,TargetRow)^) *
                      single(XYPtr(SourceB,TargetColumn,SourceColumn)^);

            ftDouble: double(XYPtr(Target,TargetColumn,TargetRow)^) :=
                      double(XYPtr(Target,TargetColumn,TargetRow)^) +
                      double(XYPtr(SourceA,SourceColumn,TargetRow)^) *
                      double(XYPtr(SourceB,TargetColumn,SourceColumn)^);
        end;
      end;
    end;
  end;
end;


procedure TComputeEngine.DotProductMatrixVector(SourceA, SourceB, Target: IComputeObject);
var
  TargetColumn: uint64;
  TargetRow: uint64;
  SourceColumn: uint64;
begin
  //- Ensure all three objects are valid.
  ValidObject(SourceA);
  ValidObject(SourceB);
  ValidObject(Target);
  //- Ensure the Width of A matches the height of B.
  SizeMatch(SourceA.Width,SourceB.Height);
  //- Ensure the target is the correct dimensions for the result.
  SizeMatch(Target.Width, 1);
  SizeMatch(Target.Height, SourceA.Height);
  //- Clear the target.
  Self.Fill(Target,0);
  //- Now we can loop the elements in each object to calculate the results.
  for TargetColumn := 0 to pred(Target.Width) do begin
    for TargetRow := 0 to pred(Target.Height) do begin
      for SourceColumn := 0 to pred(SourceA.Width) do begin
        case getFloatType of
              ftHalf: half(XYPtr(Target,TargetColumn,TargetRow)^) := half(XYPtr(Target,TargetColumn,TargetRow)^) + half(XYPtr(SourceA,SourceColumn,TargetRow)^) * half(XYPtr(SourceB,0,SourceColumn)^);
            ftSingle: single(XYPtr(Target,TargetColumn,TargetRow)^) := single(XYPtr(Target,TargetColumn,TargetRow)^) + single(XYPtr(SourceA,SourceColumn,TargetRow)^) * single(XYPtr(SourceB,0,SourceColumn)^);
            ftDouble: double(XYPtr(Target,TargetColumn,TargetRow)^) := double(XYPtr(Target,TargetColumn,TargetRow)^) + double(XYPtr(SourceA,SourceColumn,TargetRow)^) * double(XYPtr(SourceB,0,SourceColumn)^);
        end;
      end;
    end;
  end;
end;


procedure TComputeEngine.DotProduct( SourceA: IComputeObject; SourceB: IComputeObject; Target: IComputeObject );
var
  AMatrix: boolean;
  BMatrix: boolean;
begin
  AMatrix := False;
  BMatrix := False;
  if (SourceA.Width>1) and (SourceA.Height>1) then begin
    AMatrix := True;
  end;
  if (SourceB.Width>1) and (SourceB.Height>1) then begin
    BMatrix := True;
  end;
  if (AMatrix and (not BMatrix)) or
     (BMatrix and (not AMatrix)) then begin
    //- Here we're performing the product of a matrix and a vector.
    //- The order of the two is not important, so we'll always provide the
    //- Matrix first and the vector second.
    if AMatrix then begin
      DotProductMatrixVector(SourceA,SourceB,Target);
    end else begin
      DotProductMatrixVector(SourceB,SourceA,Target);
    end;
  end else if AMatrix and BMatrix then begin
    DotProductMatrix(SourceA,SourceB,Target);
  end else begin
    SizeMatch(0,1); // Generate size-mismatch error because vector.vector=scalar, use other method.
  end;
end;

procedure TComputeEngine.DotProduct( SourceA: IComputeObject; SourceB: IComputeObject; var ScalarResult: float );
var
  ElementIndex: uint64;
begin
  ScalarResult := 0.00000;
  //- Ensure both objects are valid.
  ValidObject(SourceA);
  ValidObject(SourceB);
  //- Ensure the number of elements in A matches the number in B.
  SizeMatch(SourceA.Width*SourceA.Height, SourceB.Width*SourceB.Height);
  //- Now we can loop the elements in each object to calculate the results.
  for ElementIndex := 0 to pred(SourceA.Width*SourceA.Height) do begin
    case getFloatType of
          ftHalf: ScalarResult := ScalarResult + half(AsPtr(SourceA,ElementIndex)^)   * half(AsPtr(SourceB,ElementIndex)^);
        ftSingle: ScalarResult := ScalarResult + single(AsPtr(SourceA,ElementIndex)^) * single(AsPtr(SourceB,ElementIndex)^);
        ftDouble: ScalarResult := ScalarResult + double(AsPtr(SourceA,ElementIndex)^) * double(AsPtr(SourceB,ElementIndex)^);
    end;
  end;
end;


end.
