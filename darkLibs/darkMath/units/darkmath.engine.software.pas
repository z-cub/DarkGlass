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
unit darkmath.engine.software;
{$ifdef fpc} {$ifdef CPU64} {$define CPU64BITS} {$endif} {$endif}

interface
uses
  darkmath.engine;

type
  TMathEngine = class( TInterfacedObject, IMathEngine )
  private
    fFloatType: TFloatType;
  private
    procedure IncPtrFloatSize( var P: pointer );
    procedure ValidObject( EngineObject: IMathEngineObject );
    function GetObjectPointer( anObject: IMathEngineObject ): pointer;
    procedure SizeMatch( SizeA: uint32; SizeB: uint32 );
  private //- IMathEngine -//
    function getFloatType: TFloatType;
    function getFloatSize: uint8;
    function getBuffer( cbSize: uint64 ): IMathEngineBuffer;
    procedure getSum( Source: IMathEngineObject; var ScalarResult: float ); overload;
    procedure Addition( Source: IMathEngineObject; Target: IMathEngineObject ); overload;
    procedure Addition( Target: IMathEngineObject; ScalarValue: float ); overload;
    procedure Subtraction( Source: IMathEngineObject; Target: IMathEngineObject ); overload;
    procedure Subtraction( Target: IMathEngineObject; ScalarValue: float ); overload;
    procedure Multiplication( Source: IMathEngineObject; Target: IMathEngineObject ); overload;
    procedure Multiplication( Target: IMathEngineObject; ScalarValue: float ); overload;
    procedure Division( Source: IMathEngineObject; Target: IMathEngineObject ); overload;
    procedure Division( Target: IMathEngineObject; ScalarValue: float ); overload;
    procedure Tanh( Target: IMathEngineObject );
    procedure ScaledTanh( Target: IMathEngineObject );
    procedure Sigmoid( Target: IMathEngineObject  );
    procedure Relu( Target: IMathEngineObject );
    procedure Elu( Target: IMathEngineObject );
    procedure Softmax( Target: IMathEngineObject );
    procedure TanhDerivative( Target: IMathEngineObject );
    procedure ScaledTanhDerivative( Target: IMathEngineObject );
    procedure SigmoidDerivative( Target: IMathEngineObject );
    procedure ReluDerivative( Target: IMathEngineObject );
    procedure EluDerivative( Target: IMathEngineObject );
    procedure LinearDerivative( Target: IMathEngineObject );
    procedure Log( Target: IMathEngineObject );
    procedure Exp( Target: IMathEngineObject );
    procedure Fill( Target: IMathEngineObject; ScalarValue: float );
    procedure Negate( Target: IMathEngineObject );
    procedure Copy( Source: IMathEngineObject; Target: IMathEngineObject );
    procedure DotProduct( SourceA: IMathEngineObject; SourceB: IMathEngineObject; Target: IMathEngineObject ); overload;
    procedure DotProduct( SourceA: IMathEngineObject; SourceB: IMathEngineObject; var ScalarResult: float ); overload;
  public
    constructor Create(FloatType: TFloatType);
    destructor Destroy; override;
  end;


implementation
uses
  sysutils,
  math,
  darkmath.halftype,
  darkmath.buffer.software,
  darkIO.buffers;


procedure TMathEngine.IncPtrFloatSize( var P: pointer );
begin
  p := pointer( nativeuint(P) + getFloatSize );
end;

procedure TMathEngine.ValidObject( EngineObject: IMathEngineObject );
begin
  if EngineObject.Engine<>(Self as IMathEngine) then begin
    raise
      Exception.Create('Software: Math engine mismatch.');
  end;
end;

procedure TMathEngine.SizeMatch( SizeA: uint32; SizeB: uint32 );
begin
  if SizeA<>SizeB then begin
    raise
      Exception.Create('Software: Engine object sizes do not meet operation requirements.');
  end;
end;

function TMathEngine.GetObjectPointer( anObject: IMathEngineObject ): pointer;
begin
  Result := pointer(nativeuint( IBuffer(anObject.Buffer.getHandle).DataPtr ) + anObject.getOffset);
end;

procedure TMathEngine.Addition(Source, Target: IMathEngineObject);
var
  idx: uint32;
  ElementCount: uint32;
  SourcePtr: pointer;
  TargetPtr: pointer;
begin
  //- Validate
  ValidObject(Source);
  ValidObject(Target);
  ElementCount := Source.Height*Source.Width;
  SizeMatch( ElementCount, Target.Height * Target.Width );
  //- Loop all elements in source and target
  SourcePtr := GetObjectPointer(Source);
  TargetPtr := GetObjectPointer(Target);
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
        ftHalf: half(TargetPtr^)   := half(TargetPtr^)   + half(SourcePtr^);
      ftSingle: single(TargetPtr^) := single(TargetPtr^) + single(SourcePtr^);
      ftDouble: double(TargetPtr^) := double(TargetPtr^) + double(SourcePtr^);
      {$ifdef CPU64BITS} ftExtended: extended(TargetPtr^) := extended(TargetPtr^) + extended(SourcePtr^); {$endif}
    end;
    IncPtrFloatSize(SourcePtr);
    IncPtrFloatSize(TargetPtr);
  end;
end;


procedure TMathEngine.Addition(Target: IMathEngineObject; ScalarValue: float);
var
  idx: uint32;
  ElementCount: uint32;
  TargetPtr: pointer;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  TargetPtr := GetObjectPointer(Target);
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
        ftHalf: half(TargetPtr^)   := half(TargetPtr^)   + ScalarValue;
      ftSingle: single(TargetPtr^) := single(TargetPtr^) + ScalarValue;
      ftDouble: double(TargetPtr^) := double(TargetPtr^) + ScalarValue;
      {$ifdef CPU64BITS} ftExtended: extended(TargetPtr^) := extended(TargetPtr^) + ScalarValue; {$endif}
    end;
    IncPtrFloatSize(TargetPtr);
  end;
end;

procedure TMathEngine.Copy(Source, Target: IMathEngineObject);
var
  SourceObjectPtr: pointer;
  TargetObjectPtr: pointer;
begin
  //- Validate
  ValidObject(Source);
  ValidObject(Target);
  SizeMatch( Source.Height*Source.Width, Target.Height * Target.Width );
  //- Perform copy
  SourceObjectPtr := GetObjectPointer(Source);
  TargetObjectPtr := GetObjectPointer(Target);
  Move( SourceObjectPtr^, TargetObjectPtr^, Source.Engine.FloatSize * Source.Width * Source.Height );
end;

constructor TMathEngine.Create( FloatType: TFloatType );
var
  TempUID: TGUID;
begin
  inherited Create;
  CreateGUID(TempUID);
  fFloatType := FloatType;
end;

destructor TMathEngine.Destroy;
begin
  inherited Destroy;
end;

procedure TMathEngine.Division(Source, Target: IMathEngineObject);
var
  idx: uint32;
  ElementCount: uint32;
  SourcePtr: pointer;
  TargetPtr: pointer;
begin
  //- Validate
  ValidObject(Source);
  ValidObject(Target);
  ElementCount := Source.Height*Source.Width;
  SizeMatch( ElementCount, Target.Height * Target.Width );
  //- Loop all elements in source and target
  SourcePtr := GetObjectPointer(Source);
  TargetPtr := GetObjectPointer(Target);
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
        ftHalf: half(TargetPtr^)   := half(TargetPtr^)   / half(SourcePtr^);
      ftSingle: single(TargetPtr^) := single(TargetPtr^) / single(SourcePtr^);
      ftDouble: double(TargetPtr^) := double(TargetPtr^) / double(SourcePtr^);
      {$ifdef CPU64BITS} ftExtended: extended(TargetPtr^) := extended(TargetPtr^) / extended(SourcePtr^); {$endif}
    end;
    IncPtrFloatSize(SourcePtr);
    IncPtrFloatSize(TargetPtr);
  end;
end;


procedure TMathEngine.Division(Target: IMathEngineObject; ScalarValue: float);
var
  idx: uint32;
  ElementCount: uint32;
  TargetPtr: pointer;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  TargetPtr := GetObjectPointer(Target);
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
        ftHalf: half(TargetPtr^)   := half(TargetPtr^)   / ScalarValue;
      ftSingle: single(TargetPtr^) := single(TargetPtr^) / ScalarValue;
      ftDouble: double(TargetPtr^) := double(TargetPtr^) / ScalarValue;
      {$ifdef CPU64BITS} ftExtended: extended(TargetPtr^) := extended(TargetPtr^) / ScalarValue; {$endif}
    end;
    IncPtrFloatSize(TargetPtr);
  end;
end;


procedure TMathEngine.Elu(Target: IMathEngineObject);
var
  idx: uint32;
  ElementCount: uint32;
  TargetPtr: pointer;
  aSingle: single;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  TargetPtr := GetObjectPointer(Target);
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of

      ftHalf: begin
        aSingle := half(TargetPtr^);
        if (aSingle<0) then begin
          half(TargetPtr^) := system.exp( half(TargetPtr^)-1 );
        end;
      end;

      ftSingle: begin
        if (single(TargetPtr^)<0) then begin
          single(TargetPtr^) := system.exp( single(TargetPtr^)-1 );
        end;
      end;

      ftDouble: begin
        if (double(TargetPtr^)<0) then begin
          double(TargetPtr^) := system.exp( double(TargetPtr^)-1 );
        end;
      end;

      {$ifdef CPU64BITS}
      ftExtended: begin
        if (extended(TargetPtr^)<0) then begin
          extended(TargetPtr^) := system.exp( extended(TargetPtr^)-1 );
        end;
      end;
      {$endif}

    end;
    IncPtrFloatSize(TargetPtr);
  end;
end;

procedure TMathEngine.EluDerivative(Target: IMathEngineObject);
var
  idx: uint32;
  ElementCount: uint32;
  TargetPtr: pointer;
  aSingle: single;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  TargetPtr := GetObjectPointer(Target);
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of

      ftHalf: begin
        aSingle := half(TargetPtr^);
        if aSingle>0 then begin
          half(TargetPtr^):=1;
        end else begin
          half(TargetPtr^):=half(TargetPtr^)+1;
        end;
      end;

      ftSingle: begin
        if single(TargetPtr^)>0 then begin
          single(TargetPtr^):=1;
        end else begin
          single(TargetPtr^):=single(TargetPtr^)+1;
        end;
      end;

      ftDouble: begin
        if double(TargetPtr^)>0 then begin
          double(TargetPtr^):=1;
        end else begin
          double(TargetPtr^):=double(TargetPtr^)+1;
        end;
      end;

      {$ifdef CPU64BITS}
      ftExtended: begin
        if extended(TargetPtr^)>0 then begin
          extended(TargetPtr^):=1;
        end else begin
          extended(TargetPtr^):=extended(TargetPtr^)+1;
        end;
      end;
      {$endif}

    end;
    IncPtrFloatSize(TargetPtr);
  end;
end;

procedure TMathEngine.Exp(Target: IMathEngineObject);
var
  idx: uint32;
  ElementCount: uint32;
  TargetPtr: pointer;
  S: single;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop elements and perform exponent.
  TargetPtr := GetObjectPointer(Target);
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
        ftHalf: begin
          S := half(TargetPtr^);
          half(TargetPtr^) := system.exp( S );
        end;
      ftSingle: begin
        single(TargetPtr^) := system.exp( single(TargetPtr^) );
      end;
      ftDouble: begin
        double(TargetPtr^) := system.exp( double(TargetPtr^) );
      end;
      {$ifdef CPU64BITS}
      ftExtended: begin
        extended(TargetPtr^) := system.exp( extended(TargetPtr^) );
      end;
      {$endif}
    end;
    IncPtrFloatSize(TargetPtr);
  end;
end;

procedure TMathEngine.Fill(Target: IMathEngineObject; ScalarValue: float);
var
  idx: uint32;
  ElementCount: uint32;
  TargetPtr: pointer;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  TargetPtr := GetObjectPointer(Target);
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of

      ftHalf: begin
        half(TargetPtr^) := ScalarValue;
      end;

      ftSingle: begin
        single(TargetPtr^) := ScalarValue;
      end;

      ftDouble: begin
        double(TargetPtr^) := ScalarValue;
      end;

      {$ifdef CPU64BITS}
      ftExtended: begin
        extended(TargetPtr^) := ScalarValue;
      end;
      {$endif}

    end;
    IncPtrFloatSize(TargetPtr);
  end;
end;

function TMathEngine.getBuffer(cbSize: uint64): IMathEngineBuffer;
begin
  Result := TMathEngineBuffer.Create( Self,  cbSize );
end;

function TMathEngine.getFloatSize: uint8;
begin
  Result := 0;
  case getFloatType of
    ftHalf: Result := 2;
    ftSingle: Result := 4;
    ftDouble: Result := 8;
    {$ifdef CPU64BITS}
    ftExtended: Result := 10;
    {$endif}
  end;
end;

function TMathEngine.getFloatType: TFloatType;
begin
  Result := TFloatType.ftSingle;
end;

procedure TMathEngine.LinearDerivative(Target: IMathEngineObject);
var
  idx: uint32;
  ElementCount: uint32;
  TargetPtr: pointer;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  TargetPtr := GetObjectPointer(Target);
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of

      ftHalf: begin
        half(TargetPtr^) := 1;
      end;

      ftSingle: begin
        single(TargetPtr^) := 1;
      end;

      ftDouble: begin
        double(TargetPtr^) := 1;
      end;

      {$ifdef CPU64BITS}
      ftExtended: begin
        extended(TargetPtr^) := 1;
      end;
      {$endif}

    end;
    IncPtrFloatSize(TargetPtr);
  end;
end;

procedure TMathEngine.Log(Target: IMathEngineObject);
var
  idx: uint32;
  ElementCount: uint32;
  TargetPtr: pointer;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  TargetPtr := GetObjectPointer(Target);
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
      ftHalf: begin
        half(TargetPtr^) := ln(half(TargetPtr^));
      end;

      ftSingle: begin
        single(TargetPtr^) := ln(single(TargetPtr^));
      end;

      ftDouble: begin
        double(TargetPtr^) := ln(double(TargetPtr^));
      end;

      {$ifdef CPU64BITS}
      ftExtended: begin
        extended(TargetPtr^) := ln(extended(TargetPtr^));
      end;
      {$endif}

    end;
    IncPtrFloatSize(TargetPtr);
  end;
end;

procedure TMathEngine.Multiplication(Target: IMathEngineObject; ScalarValue: float);
var
  idx: uint32;
  ElementCount: uint32;
  TargetPtr: pointer;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  TargetPtr := GetObjectPointer(Target);
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
        ftHalf: half(TargetPtr^)   := half(TargetPtr^)   * ScalarValue;
      ftSingle: single(TargetPtr^) := single(TargetPtr^) * ScalarValue;
      ftDouble: double(TargetPtr^) := double(TargetPtr^) * ScalarValue;
      {$ifdef CPU64BITS} ftExtended: extended(TargetPtr^) := extended(TargetPtr^) * ScalarValue; {$endif}
    end;
    IncPtrFloatSize(TargetPtr);
  end;
end;

procedure TMathEngine.Multiplication(Source, Target: IMathEngineObject);
var
  idx: uint32;
  ElementCount: uint32;
  SourcePtr: pointer;
  TargetPtr: pointer;
begin
  //- Validate
  ValidObject(Source);
  ValidObject(Target);
  ElementCount := Source.Height*Source.Width;
  SizeMatch( ElementCount, Target.Height * Target.Width );
  //- Loop all elements in source and target
  SourcePtr := GetObjectPointer(Source);
  TargetPtr := GetObjectPointer(Target);
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
        ftHalf: half(TargetPtr^)   := half(TargetPtr^)   * half(SourcePtr^);
      ftSingle: single(TargetPtr^) := single(TargetPtr^) * single(SourcePtr^);
      ftDouble: double(TargetPtr^) := double(TargetPtr^) * double(SourcePtr^);
      {$ifdef CPU64BITS} ftExtended: extended(TargetPtr^) := extended(TargetPtr^) * extended(SourcePtr^); {$endif}
    end;
    IncPtrFloatSize(SourcePtr);
    IncPtrFloatSize(TargetPtr);
  end;
end;


procedure TMathEngine.Negate(Target: IMathEngineObject);
var
  idx: uint32;
  ElementCount: uint32;
  TargetPtr: pointer;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  TargetPtr := GetObjectPointer(Target);
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of

      ftHalf: begin
        half(TargetPtr^) := 0-half(TargetPtr^);
      end;

      ftSingle: begin
        single(TargetPtr^) := 0-single(TargetPtr^);
      end;

      ftDouble: begin
        double(TargetPtr^) := 0-double(TargetPtr^);
      end;

      {$ifdef CPU64BITS}
      ftExtended: begin
        extended(TargetPtr^) := 0-extended(TargetPtr^);
      end;
      {$endif}

    end;
    IncPtrFloatSize(TargetPtr);
  end;
end;

procedure TMathEngine.Relu(Target: IMathEngineObject);
var
  idx: uint32;
  ElementCount: uint32;
  TargetPtr: pointer;
  aSingle: single;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  TargetPtr := GetObjectPointer(Target);
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of

      ftHalf: begin
        aSingle := half(TargetPtr^);
        if (aSingle<0) then begin
          half(TargetPtr^) := 0;
        end;
      end;

      ftSingle: begin
        if (single(TargetPtr^)<0) then begin
          single(TargetPtr^) := 0;
        end;
      end;

      ftDouble: begin
        if (double(TargetPtr^)<0) then begin
          double(TargetPtr^) := 0;
        end;
      end;

      {$ifdef CPU64BITS}
      ftExtended: begin
        if (extended(TargetPtr^)<0) then begin
          extended(TargetPtr^) := 0;
        end;
      end;
      {$endif}

    end;
    IncPtrFloatSize(TargetPtr);
  end;
end;

procedure TMathEngine.ReluDerivative(Target: IMathEngineObject);
var
  idx: uint32;
  ElementCount: uint32;
  TargetPtr: pointer;
  aSingle: single;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  TargetPtr := GetObjectPointer(Target);
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of

      ftHalf: begin
        aSingle := half(TargetPtr^);
        if aSingle>0 then begin
          half(TargetPtr^):=1;
        end else begin
          half(TargetPtr^):=0;
        end;
      end;

      ftSingle: begin
        if single(TargetPtr^)>0 then begin
          single(TargetPtr^):=1;
        end else begin
          single(TargetPtr^):=0;
        end;
      end;

      ftDouble: begin
        if double(TargetPtr^)>0 then begin
          double(TargetPtr^):=1;
        end else begin
          double(TargetPtr^):=0;
        end;
      end;

      {$ifdef CPU64BITS}
      ftExtended: begin
        if extended(TargetPtr^)>0 then begin
          extended(TargetPtr^):=1;
        end else begin
          extended(TargetPtr^):=0;
        end;
      end;
      {$endif}

    end;
    IncPtrFloatSize(TargetPtr);
  end;
end;


procedure TMathEngine.ScaledTanh(Target: IMathEngineObject);
var
  idx: uint32;
  ElementCount: uint32;
  TargetPtr: pointer;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  TargetPtr := GetObjectPointer(Target);
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of

      ftHalf: begin
        half(TargetPtr^) := 1.7159*math.tanh(half(TargetPtr^)*0.66667);
      end;

      ftSingle: begin
        single(TargetPtr^) := 1.7159*math.tanh(single(TargetPtr^)*0.66667);
      end;

      ftDouble: begin
        double(TargetPtr^) := 1.7159*math.tanh(double(TargetPtr^)*0.66667);
      end;

      {$ifdef CPU64BITS}
      ftExtended: begin
        extended(TargetPtr^) := 1.7159*math.tanh(extended(TargetPtr^)*0.66667);
      end;
      {$endif}

    end;
    IncPtrFloatSize(TargetPtr);
  end;
end;


procedure TMathEngine.ScaledTanhDerivative(Target: IMathEngineObject);
var
  idx: uint32;
  ElementCount: uint32;
  TargetPtr: pointer;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  TargetPtr := GetObjectPointer(Target);
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of

      ftHalf: begin
        half(TargetPtr^) := (0.66667*(1.7159-1/1.7159*  half(TargetPtr^)*half(TargetPtr^)));
      end;

      ftSingle: begin
        single(TargetPtr^) := (0.66667*(1.7159-1/1.7159*single(TargetPtr^)*single(TargetPtr^)));
      end;

      ftDouble: begin
        double(TargetPtr^) := (0.66667*(1.7159-1/1.7159*double(TargetPtr^)*double(TargetPtr^)));
      end;

      {$ifdef CPU64BITS}
      ftExtended: begin
        extended(TargetPtr^) := (0.66667*(1.7159-1/1.7159*extended(TargetPtr^)*extended(TargetPtr^)));
      end;
      {$endif}

    end;
    IncPtrFloatSize(TargetPtr);
  end;
end;

procedure TMathEngine.Sigmoid(Target: IMathEngineObject);
var
  idx: uint32;
  ElementCount: uint32;
  TargetPtr: pointer;
  aSingle: single;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  TargetPtr := GetObjectPointer(Target);
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of

      ftHalf: begin
        aSingle := half(TargetPtr^);
        aSingle := (1.0/(1+system.exp(-aSingle)));
        half(TargetPtr^) := aSingle;
      end;

      ftSingle: begin
        single(TargetPtr^) := (1.0/(1+system.exp(-single(TargetPtr^))));
      end;

      ftDouble: begin
        double(TargetPtr^) := (1.0/(1+system.exp(-double(TargetPtr^))));
      end;

      {$ifdef CPU64BITS}
      ftExtended: begin
        extended(TargetPtr^) := (1.0/(1+system.exp(-extended(TargetPtr^))));
      end;
      {$endif}

    end;
    IncPtrFloatSize(TargetPtr);
  end;
end;


procedure TMathEngine.SigmoidDerivative(Target: IMathEngineObject);
var
  idx: uint32;
  ElementCount: uint32;
  TargetPtr: pointer;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  TargetPtr := GetObjectPointer(Target);
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of

      ftHalf: begin
        half(TargetPtr^) := (half(TargetPtr^)*(1-half(TargetPtr^)));
      end;

      ftSingle: begin
        single(TargetPtr^) := (single(TargetPtr^)*(1-single(TargetPtr^)));
      end;

      ftDouble: begin
        double(TargetPtr^) := (double(TargetPtr^)*(1-double(TargetPtr^)));
      end;

      {$ifdef CPU64BITS}
      ftExtended: begin
        extended(TargetPtr^) := (extended(TargetPtr^)*(1-extended(TargetPtr^)));
      end;
      {$endif}

    end;
    IncPtrFloatSize(TargetPtr);
  end;
end;

procedure TMathEngine.Softmax(Target: IMathEngineObject);
var
  S: float;
begin
  Self.Exp(Target);
  Self.getSum(Target,S);
  Self.Division(Target,S);
end;

procedure TMathEngine.Subtraction(Target: IMathEngineObject; ScalarValue: float);
var
  idx: uint32;
  ElementCount: uint32;
  TargetPtr: pointer;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  TargetPtr := GetObjectPointer(Target);
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
        ftHalf: half(TargetPtr^)   := half(TargetPtr^)   - ScalarValue;
      ftSingle: single(TargetPtr^) := single(TargetPtr^) - ScalarValue;
      ftDouble: double(TargetPtr^) := double(TargetPtr^) - ScalarValue;
      {$ifdef CPU64BITS} ftExtended: extended(TargetPtr^) := extended(TargetPtr^) - ScalarValue; {$endif}
    end;
    IncPtrFloatSize(TargetPtr);
  end;
end;


procedure TMathEngine.Subtraction(Source, Target: IMathEngineObject);
var
  idx: uint32;
  ElementCount: uint32;
  SourcePtr: pointer;
  TargetPtr: pointer;
begin
  //- Validate
  ValidObject(Source);
  ValidObject(Target);
  ElementCount := Source.Height*Source.Width;
  SizeMatch( ElementCount, Target.Height * Target.Width );
  //- Loop all elements in source and target
  SourcePtr := GetObjectPointer(Source);
  TargetPtr := GetObjectPointer(Target);
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of
        ftHalf: half(TargetPtr^)   := half(TargetPtr^)   - half(SourcePtr^);
      ftSingle: single(TargetPtr^) := single(TargetPtr^) - single(SourcePtr^);
      ftDouble: double(TargetPtr^) := double(TargetPtr^) - double(SourcePtr^);
      {$ifdef CPU64BITS} ftExtended: extended(TargetPtr^) := extended(TargetPtr^) - extended(SourcePtr^); {$endif}
    end;
    IncPtrFloatSize(SourcePtr);
    IncPtrFloatSize(TargetPtr);
  end;
end;


procedure TMathEngine.Tanh(Target: IMathEngineObject);
var
  idx: uint32;
  ElementCount: uint32;
  TargetPtr: pointer;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  TargetPtr := GetObjectPointer(Target);
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of

      ftHalf: begin
        half(TargetPtr^) := math.tanh(half(TargetPtr^));
      end;

      ftSingle: begin
        single(TargetPtr^) := math.tanh(single(TargetPtr^));
      end;

      ftDouble: begin
        double(TargetPtr^) := math.tanh(double(TargetPtr^));
      end;

      {$ifdef CPU64BITS}
      ftExtended: begin
        extended(TargetPtr^) := math.tanh(extended(TargetPtr^));
      end;
      {$endif}

    end;
    IncPtrFloatSize(TargetPtr);
  end;
end;

procedure TMathEngine.TanhDerivative(Target: IMathEngineObject);
var
  idx: uint32;
  ElementCount: uint32;
  TargetPtr: pointer;
begin
  //- Validate
  ValidObject(Target);
  ElementCount := Target.Height*Target.Width;
  //- Loop all elements in source and target
  TargetPtr := GetObjectPointer(Target);
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of

      ftHalf: begin
        half(TargetPtr^) := (1-half(TargetPtr^)*half(TargetPtr^));
      end;

      ftSingle: begin
        single(TargetPtr^) := (1-single(TargetPtr^)*single(TargetPtr^));
      end;

      ftDouble: begin
        double(TargetPtr^) := (1- double(TargetPtr^)*double(TargetPtr^));
      end;

      {$ifdef CPU64BITS}
      ftExtended: begin
        extended(TargetPtr^) := (1- extended(TargetPtr^)*extended(TargetPtr^));
      end;
      {$endif}

    end;
    IncPtrFloatSize(TargetPtr);
  end;
end;

procedure TMathEngine.getSum( Source: IMathEngineObject; var ScalarResult: float );
var
  idx: uint32;
  ElementCount: uint32;
  SourcePtr: pointer;
begin
  //- Validate
  ValidObject(Source);
  ElementCount := Source.Height*Source.Width;
  //- Loop all elements in Source
  SourcePtr := GetObjectPointer(Source);
  for idx := 0 to pred(ElementCount) do begin
    case getFloatType of

      ftHalf: begin
        ScalarResult := ScalarResult + half(SourcePtr^);
      end;

      ftSingle: begin
        ScalarResult := ScalarResult + single(SourcePtr^);
      end;

      ftDouble: begin
        ScalarResult := ScalarResult + double(SourcePtr^);
      end;

      {$ifdef CPU64BITS}
      ftExtended: begin
        ScalarResult := ScalarResult + extended(SourcePtr^);
      end;
      {$endif}

    end;
    IncPtrFloatSize(SourcePtr);
  end;
end;


procedure TMathEngine.DotProduct( SourceA: IMathEngineObject; SourceB: IMathEngineObject; Target: IMathEngineObject );
begin
  //-
end;

procedure TMathEngine.DotProduct( SourceA: IMathEngineObject; SourceB: IMathEngineObject; var ScalarResult: float );
begin
  //-
end;


end.
