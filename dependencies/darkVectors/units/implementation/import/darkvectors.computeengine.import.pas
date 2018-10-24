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
unit darkvectors.computeengine.import;

interface
uses
  darkHandles,
  darkvectors.plugin,
  darkvectors.imported.import,
  darkvectors.computeengine;

type
  TComputeEngine = class( TInterfacedObject, IComputeEngine, IImported )
  private
    fHandle: THandle;
    fPlugin: IComputePlugin;
  private //- IImported -//
    function getExternalHandle: THandle;
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
    procedure InsertRow( Source: IComputeObject; Target: IComputeObject; RowIndex: uint64 );
    procedure InsertColumn( Source: IComputeObject; Target: IComputeObject; ColumnIndex: uint64 );
    procedure ExtractRow( Source: IComputeObject; Target: IComputeObject; RowIndex: uint64 );
    procedure ExtractColumn( Source: IComputeObject; Target: IComputeObject; ColumnIndex: uint64 );
    procedure Transpose( Source: IComputeObject; Target: IComputeObject );
    procedure AddOnRow( Source: IComputeObject; Target: IComputeObject; RowIndex: uint64 );
    procedure SubtractOnRow( Source: IComputeObject; Target: IComputeObject; RowIndex: uint64 );
    procedure MultiplyOnRow( Source: IComputeObject; Target: IComputeObject; RowIndex: uint64 );
    procedure DivideOnRow( Source: IComputeObject; Target: IComputeObject; RowIndex: uint64 );
    procedure AddOnColumn( Source: IComputeObject; Target: IComputeObject; ColumnIndex: uint64 );
    procedure SubtractOnColumn( Source: IComputeObject; Target: IComputeObject; ColumnIndex: uint64 );
    procedure MultiplyOnColumn( Source: IComputeObject; Target: IComputeObject; ColumnIndex: uint64 );
    procedure DivideOnColumn( Source: IComputeObject; Target: IComputeObject; ColumnIndex: uint64 );
  public
    constructor Create( Plugin: IComputePlugin; Handle: THandle ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  sysutils,
  darkvectors.computebuffer.import;

{ TComputeEngine }

procedure TComputeEngine.Addition(Source, Target: IComputeObject);
begin
  fPlugin.ce_Addition(fHandle,(Source as IImported).getExternalHandle,(Target as IImported).getExternalHandle);
end;

procedure TComputeEngine.Addition(Target: IComputeObject; ScalarValue: float);
begin
  fPlugin.ce_Addition(fHandle,(Target as IImported).getExternalHandle,ScalarValue);
end;

procedure TComputeEngine.AddOnColumn(Source, Target: IComputeObject; ColumnIndex: uint64);
begin
  fPlugin.ce_AddOnColumn(fHandle,(Source as IImported).getExternalHandle,(Target as IImported).getExternalHandle, ColumnIndex);
end;

procedure TComputeEngine.AddOnRow(Source, Target: IComputeObject; RowIndex: uint64);
begin
  fPlugin.ce_AddOnRow(fHandle,(Source as IImported).getExternalHandle,(Target as IImported).getExternalHandle, RowIndex);
end;

procedure TComputeEngine.Copy(Source, Target: IComputeObject);
var
  Size: uint64;
  Buffer: TArrayOfFloat;
begin
  // Check object dimensions match.
  if (Source.Height*Source.Width)<>(Target.Height*Target.Width) then begin
    raise
      Exception.Create('Copy objects failed due to size missmatch.');
  end;
  //- If the objects are not on the same engine, use another (slower)
  //- copy mechanism.
  if (Source.Engine<>(Self as IComputeEngine)) or (Target.Engine<>(Self as IComputeEngine)) then begin
    Size := Source.Width*Source.Height;
    SetLength(Buffer,Size);
    try
      Source.getElements(0,Source.Width*Source.Height,Buffer);
      Target.setElements(0,Buffer);
    finally
      SetLength(Buffer,0);
    end;
  end else begin
    //- Perform copy
    fPlugin.ce_Copy(fHandle,(Source as IImported).getExternalHandle,(Target as IImported).getExternalHandle);
  end;
end;

constructor TComputeEngine.Create(Plugin: IComputePlugin; Handle: THandle);
begin
  inherited Create;
  fPlugin := Plugin;
  fHandle := Handle;
end;

destructor TComputeEngine.Destroy;
begin
  fPlugin.FreeHandle(fHandle);
  fPlugin := nil;
  inherited Destroy;
end;

procedure TComputeEngine.DivideOnColumn(Source, Target: IComputeObject; ColumnIndex: uint64);
begin
  fPlugin.ce_DivideOnColumn(fHandle,(Source as IImported).getExternalHandle,(Target as IImported).getExternalHandle, ColumnIndex);
end;

procedure TComputeEngine.DivideOnRow(Source, Target: IComputeObject; RowIndex: uint64);
begin
  fPlugin.ce_DivideOnRow(fHandle,(Source as IImported).getExternalHandle,(Target as IImported).getExternalHandle, RowIndex);
end;

procedure TComputeEngine.Division(Target: IComputeObject; ScalarValue: float);
begin
  fPlugin.ce_Division(fHandle,(Target as IImported).getExternalHandle,ScalarValue);
end;

procedure TComputeEngine.Division(Source, Target: IComputeObject);
begin
  fPlugin.ce_Division(fHandle,(Source as IImported).getExternalHandle,(Target as IImported).getExternalHandle);
end;

procedure TComputeEngine.DotProduct(SourceA, SourceB, Target: IComputeObject);
begin
  fPlugin.ce_DotProduct(fHandle,(SourceA as IImported).getExternalHandle,(SourceB as IImported).getExternalHandle,(Target  as IImported).getExternalHandle);
end;

procedure TComputeEngine.DotProduct(SourceA, SourceB: IComputeObject; var ScalarResult: float);
begin
  fPlugin.ce_DotProduct(fHandle,(SourceA as IImported).getExternalHandle,(SourceB as IImported).getExternalHandle,ScalarResult);
end;

procedure TComputeEngine.Elu(Target: IComputeObject);
begin
  fPlugin.ce_Elu(fHandle,(Target as IImported).getExternalHandle);
end;

procedure TComputeEngine.EluDerivative(Target: IComputeObject);
begin
  fPlugin.ce_EluDerivative(fHandle,(Target as IImported).getExternalHandle);
end;

procedure TComputeEngine.Exp(Target: IComputeObject);
begin
  fPlugin.ce_Exp(fHandle,(Target as IImported).getExternalHandle);
end;

procedure TComputeEngine.ExtractColumn(Source, Target: IComputeObject; ColumnIndex: uint64);
begin
  fPlugin.ce_ExtractColumn(fHandle,(Source as IImported).getExternalHandle,(Target as IImported).getExternalHandle, ColumnIndex);
end;

procedure TComputeEngine.ExtractRow(Source, Target: IComputeObject; RowIndex: uint64);
begin
  fPlugin.ce_ExtractRow(fHandle,(Source as IImported).getExternalHandle,(Target as IImported).getExternalHandle, RowIndex);
end;

procedure TComputeEngine.Fill(Target: IComputeObject; ScalarValue: float);
begin
  fPlugin.ce_Fill(fHandle,(Target as IImported).getExternalHandle,ScalarValue);
end;

function TComputeEngine.getBuffer(ElementCount: uint64): IComputeBuffer;
var
  BufferHandle: THandle;
  NewBuffer: IComputeBuffer;
begin
  Result := nil;
  BufferHandle := fPlugin.ce_getBuffer(fHandle,ElementCount);
  if BufferHandle=THandles.cNullHandle then begin
    exit;
  end;
  NewBuffer := TComputeBuffer.Create(fPlugin,BufferHandle,Self);
  Result := NewBuffer;
end;

function TComputeEngine.getExternalHandle: THandle;
begin
  Result := fHandle;
end;

function TComputeEngine.getFloatSize: uint8;
begin
  Result := fPlugin.ce_getFloatSize(fHandle);
end;

function TComputeEngine.getFloatType: TFloatType;
begin
  Result := fPlugin.ce_getFloatType(fHandle);
end;

procedure TComputeEngine.getSum(Source: IComputeObject; var ScalarResult: float);
begin
  fPlugin.ce_getSum(fHandle,(Source as IImported).getExternalHandle,ScalarResult);
end;

procedure TComputeEngine.InsertColumn(Source, Target: IComputeObject; ColumnIndex: uint64);
begin
  fPlugin.ce_InsertColumn(fHandle,(Source as IImported).getExternalHandle,(Target as IImported).getExternalHandle, ColumnIndex);
end;

procedure TComputeEngine.InsertRow(Source, Target: IComputeObject; RowIndex: uint64);
begin
  fPlugin.ce_InsertRow(fHandle,(Source as IImported).getExternalHandle,(Target as IImported).getExternalHandle, RowIndex);
end;

procedure TComputeEngine.LinearDerivative(Target: IComputeObject);
begin
  fPlugin.ce_LinearDerivative(fHandle,(Target as IImported).getExternalHandle);
end;

procedure TComputeEngine.Log(Target: IComputeObject);
begin
  fPlugin.ce_Log(fHandle,(Target as IImported).getExternalHandle);
end;

procedure TComputeEngine.Multiplication(Target: IComputeObject; ScalarValue: float);
begin
  fPlugin.ce_Multiplication(fHandle,(Target as IImported).getExternalHandle,ScalarValue);
end;

procedure TComputeEngine.MultiplyOnColumn(Source, Target: IComputeObject; ColumnIndex: uint64);
begin
  fPlugin.ce_MultiplyOnColumn(fHandle,(Source as IImported).getExternalHandle,(Target as IImported).getExternalHandle, ColumnIndex);
end;

procedure TComputeEngine.MultiplyOnRow(Source, Target: IComputeObject; RowIndex: uint64);
begin
  fPlugin.ce_MultiplyOnRow(fHandle,(Source as IImported).getExternalHandle,(Target as IImported).getExternalHandle, RowIndex);
end;

procedure TComputeEngine.Multiplication(Source, Target: IComputeObject);
begin
  fPlugin.ce_Multiplication(fHandle,(Source as IImported).getExternalHandle,(Target as IImported).getExternalHandle);
end;

procedure TComputeEngine.Negate(Target: IComputeObject);
begin
  fPlugin.ce_Negate(fHandle,(Target as IImported).getExternalHandle);
end;

procedure TComputeEngine.Relu(Target: IComputeObject);
begin
  fPlugin.ce_Relu(fHandle,(Target as IImported).getExternalHandle);
end;

procedure TComputeEngine.ReluDerivative(Target: IComputeObject);
begin
  fPlugin.ce_ReluDerivative(fHandle,(Target as IImported).getExternalHandle);
end;

procedure TComputeEngine.ScaledTanh(Target: IComputeObject);
begin
  fPlugin.ce_ScaledTanh(fHandle,(Target as IImported).getExternalHandle);
end;

procedure TComputeEngine.ScaledTanhDerivative(Target: IComputeObject);
begin
  fPlugin.ce_ScaledTanhDerivative(fHandle,(Target as IImported).getExternalHandle);
end;

procedure TComputeEngine.Sigmoid(Target: IComputeObject);
begin
  fPlugin.ce_Sigmoid(fHandle,(Target as IImported).getExternalHandle);
end;

procedure TComputeEngine.SigmoidDerivative(Target: IComputeObject);
begin
  fPlugin.ce_SigmoidDerivative(fHandle,(Target as IImported).getExternalHandle);
end;

procedure TComputeEngine.Softmax(Target: IComputeObject);
begin
  fPlugin.ce_Softmax(fHandle,(Target as IImported).getExternalHandle);
end;

procedure TComputeEngine.Subtraction(Target: IComputeObject; ScalarValue: float);
begin
  fPlugin.ce_Subtraction(fHandle,(Target as IImported).getExternalHandle,ScalarValue);
end;

procedure TComputeEngine.SubtractOnColumn(Source, Target: IComputeObject; ColumnIndex: uint64);
begin
  fPlugin.ce_SubtractOnColumn(fHandle,(Source as IImported).getExternalHandle,(Target as IImported).getExternalHandle, ColumnIndex);
end;

procedure TComputeEngine.SubtractOnRow(Source, Target: IComputeObject; RowIndex: uint64);
begin
  fPlugin.ce_SubtractOnRow(fHandle,(Source as IImported).getExternalHandle,(Target as IImported).getExternalHandle, RowIndex);
end;

procedure TComputeEngine.Subtraction(Source, Target: IComputeObject);
begin
  fPlugin.ce_Subtraction(fHandle,(Source as IImported).getExternalHandle,(Target as IImported).getExternalHandle);
end;

procedure TComputeEngine.Tanh(Target: IComputeObject);
begin
  fPlugin.ce_Tanh(fHandle,(Target as IImported).getExternalHandle);
end;

procedure TComputeEngine.TanhDerivative(Target: IComputeObject);
begin
  fPlugin.ce_TanhDerivative(fHandle,(Target as IImported).getExternalHandle);
end;

procedure TComputeEngine.Transpose(Source, Target: IComputeObject);
begin
  fPlugin.ce_Transpose(fHandle,(Source as IImported).getExternalHandle,(Target as IImported).getExternalHandle);
end;

end.
