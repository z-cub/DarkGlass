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
unit darkvectors.external.binding.export;

interface
uses
  darkHandles,
  darkvectors.computeprovider,
  darkvectors.aliases,
  darkvectors.external.binding;

type
  ///  <summary>
  ///    Event assigned to the constructor of TExternalBindingExport in order
  ///    to provide the mechanism by which the compute provider is created
  ///    within the dynamic library.
  ///  </summary>
  TOnCreateProvider = function: IComputeProvider;

  ///  <summary>
  ///    Implementation of IVectorsBinding which is able to take an
  ///    implementation of IComputeProvider and associated interfaces,
  ///    and export them from the dynamic library.
  ///  </summary>
  TExternalBindingExport = class( TInterfacedObject, IVectorsBinding )
  private
    fOnCreateProvider: TOnCreateProvider;
  private
    function provider_Create: THandle;
    procedure provider_getName( providerHandle: THandle; StringBuffer: pointer; BufferSize: uint32; var Returned: uint64 );
    function provider_getDeviceCount( providerHandle: THandle ): uint64;
    function provider_getDevice( providerHandle: THandle; DeviceIndex: uint64 ): THandle;
    procedure device_getName( deviceHandle: THandle; StringBuffer: pointer; BufferSize: uint32; var Returned: uint64 );
    procedure device_getVendor( deviceHandle: THandle; StringBuffer: pointer; BufferSize: uint32; var Returned: uint64 );
    function device_getClockSpeed: uint32;
    function device_getCoreCount: uint32;
    function device_getMemorySize: uint64;
    function device_getMaxAllocation: uint64;
    function device_getMemoryInUse: uint64;
    function device_getMemoryAvailable: uint64;
    function device_getSupportedTypes: TFloatTypes;
    function device_getEngine( FloatType: TFloatType ): THandle;
    function buffer_getFloatSize( bufferHandle: THandle ): uint8;
    function buffer_getHandle( bufferHandle: THandle ): pointer;
    function buffer_getComputeEngine( bufferHandle: THandle ): THandle;
    function buffer_getSize( bufferHandle: THandle ): uint64;
    procedure buffer_getData( bufferHandle: THandle; TargetPtr: pointer; Offset: uint64; cbBytes: uint64 );
    procedure buffer_setData( bufferHandle: THandle; SourcePtr: pointer; Offset: uint64; cbBytes: uint64 );
    function buffer_getObject( bufferHandle: THandle; OffsetElements: uint64; Height: uint64; Width: uint64 ): THandle;
    function object_getComputeBuffer( objectHandle: THandle ): THandle;
    function object_getComputeEngine( objectHandle: THandle ): THandle;
    function object_getOffset( objectHandle: THandle ): uint64;
    function object_getFloatType( objectHandle: THandle ): TFloatType;
    function object_getFloatSize( objectHandle: THandle ): uint8;
    procedure object_getElements( objectHandle: THandle; ElementIndex: uint64; ElementCount: uint64; var Elements: TArrayOfFloat );
    procedure object_setElements( objectHandle: THandle; ElementIndex: uint64; Elements: TArrayOfFloat );
    function object_getElement( objectHandle: THandle; ElementIndex: uint64 ): float;
    procedure object_setElement( objectHandle: THandle; ElementIndex: uint64; value: float );
    function object_getWidth( objectHandle: THandle ): uint64;
    function object_getHeight( objectHandle: THandle ): uint64;
    function engine_getFloatType( engineHandle: THandle ): TFloatType;
    function engine_getFloatSize( engineHandle: THandle ): uint8;
    function engine_getBuffer( engineHandle: THandle; ElementCount: uint64 ): THandle;
    procedure engine_getSum( engineHandle: THandle; Source: THandle; var ScalarResult: float ); overload;
    procedure engine_Addition( engineHandle: THandle; Source: THandle; Target: THandle ); overload;
    procedure engine_Addition( engineHandle: THandle; Target: THandle; ScalarValue: float ); overload;
    procedure engine_Subtraction( engineHandle: THandle; Source: THandle; Target: THandle ); overload;
    procedure engine_Subtraction( engineHandle: THandle; Target: THandle; ScalarValue: float ); overload;
    procedure engine_Multiplication( engineHandle: THandle; Source: THandle; Target: THandle ); overload;
    procedure engine_Multiplication( engineHandle: THandle; Target: THandle; ScalarValue: float ); overload;
    procedure engine_Division( engineHandle: THandle; Source: THandle; Target: THandle ); overload;
    procedure engine_Division( engineHandle: THandle; Target: THandle; ScalarValue: float ); overload;
    procedure engine_Tanh( engineHandle: THandle; Target: THandle );
    procedure engine_ScaledTanh( engineHandle: THandle; Target: THandle );
    procedure engine_Sigmoid( engineHandle: THandle; Target: THandle  );
    procedure engine_Relu( engineHandle: THandle; Target: THandle );
    procedure engine_Elu( engineHandle: THandle; Target: THandle );
    procedure engine_Softmax( engineHandle: THandle; Target: THandle );
    procedure engine_TanhDerivative( engineHandle: THandle; Target: THandle );
    procedure engine_ScaledTanhDerivative( engineHandle: THandle; Target: THandle );
    procedure engine_SigmoidDerivative( engineHandle: THandle; Target: THandle );
    procedure engine_ReluDerivative( engineHandle: THandle; Target: THandle );
    procedure engine_EluDerivative( engineHandle: THandle; Target: THandle );
    procedure engine_LinearDerivative( engineHandle: THandle; Target: THandle );
    procedure engine_Log( engineHandle: THandle; Target: THandle );
    procedure engine_Exp( engineHandle: THandle; Target: THandle );
    procedure engine_Fill( engineHandle: THandle; Target: THandle; ScalarValue: float );
    procedure engine_Negate( engineHandle: THandle; Target: THandle );
    procedure engine_Copy( engineHandle: THandle; Source: THandle; Target: THandle );
    procedure engine_DotProduct( engineHandle: THandle; SourceA: THandle; SourceB: THandle; Target: THandle ); overload;
    procedure engine_DotProduct( engineHandle: THandle; SourceA: THandle; SourceB: THandle; var ScalarResult: float ); overload;
  public
    constructor Create( OnCreateProvider: TOnCreateProvider ); reintroduce;
    destructor Destroy; override;
  end;


implementation


{ TExternalBindingExport }

function TExternalBindingExport.buffer_getComputeEngine(bufferHandle: THandle): THandle;
begin

end;

procedure TExternalBindingExport.buffer_getData(bufferHandle: THandle; TargetPtr: pointer; Offset, cbBytes: uint64);
begin

end;

function TExternalBindingExport.buffer_getFloatSize(bufferHandle: THandle): uint8;
begin

end;

function TExternalBindingExport.buffer_getHandle(bufferHandle: THandle): pointer;
begin

end;

function TExternalBindingExport.buffer_getObject(bufferHandle: THandle; OffsetElements, Height, Width: uint64): THandle;
begin

end;

function TExternalBindingExport.buffer_getSize(bufferHandle: THandle): uint64;
begin

end;

procedure TExternalBindingExport.buffer_setData(bufferHandle: THandle; SourcePtr: pointer; Offset, cbBytes: uint64);
begin

end;

constructor TExternalBindingExport.Create(OnCreateProvider: TOnCreateProvider);
begin
  inherited Create;
  fOnCreateProvider := OnCreateProvider;
end;

destructor TExternalBindingExport.Destroy;
begin
  fOnCreateProvider := nil;
  inherited Destroy;
end;

function TExternalBindingExport.device_getClockSpeed: uint32;
begin

end;

function TExternalBindingExport.device_getCoreCount: uint32;
begin

end;

function TExternalBindingExport.device_getEngine(FloatType: TFloatType): THandle;
begin

end;

function TExternalBindingExport.device_getMaxAllocation: uint64;
begin

end;

function TExternalBindingExport.device_getMemoryAvailable: uint64;
begin

end;

function TExternalBindingExport.device_getMemoryInUse: uint64;
begin

end;

function TExternalBindingExport.device_getMemorySize: uint64;
begin

end;

procedure TExternalBindingExport.device_getName(deviceHandle: THandle; StringBuffer: pointer; BufferSize: uint32; var Returned: uint64);
begin

end;

function TExternalBindingExport.device_getSupportedTypes: TFloatTypes;
begin

end;

procedure TExternalBindingExport.device_getVendor(deviceHandle: THandle; StringBuffer: pointer; BufferSize: uint32; var Returned: uint64);
begin

end;

procedure TExternalBindingExport.engine_Addition(engineHandle, Source, Target: THandle);
begin

end;

procedure TExternalBindingExport.engine_Addition(engineHandle, Target: THandle; ScalarValue: float);
begin

end;

procedure TExternalBindingExport.engine_Copy(engineHandle, Source, Target: THandle);
begin

end;

procedure TExternalBindingExport.engine_Division(engineHandle, Target: THandle; ScalarValue: float);
begin

end;

procedure TExternalBindingExport.engine_Division(engineHandle, Source, Target: THandle);
begin

end;

procedure TExternalBindingExport.engine_DotProduct(engineHandle, SourceA, SourceB: THandle; var ScalarResult: float);
begin

end;

procedure TExternalBindingExport.engine_DotProduct(engineHandle, SourceA, SourceB, Target: THandle);
begin

end;

procedure TExternalBindingExport.engine_Elu(engineHandle, Target: THandle);
begin

end;

procedure TExternalBindingExport.engine_EluDerivative(engineHandle, Target: THandle);
begin

end;

procedure TExternalBindingExport.engine_Exp(engineHandle, Target: THandle);
begin

end;

procedure TExternalBindingExport.engine_Fill(engineHandle, Target: THandle; ScalarValue: float);
begin

end;

function TExternalBindingExport.engine_getBuffer(engineHandle: THandle; ElementCount: uint64): THandle;
begin

end;

function TExternalBindingExport.engine_getFloatSize(engineHandle: THandle): uint8;
begin

end;

function TExternalBindingExport.engine_getFloatType(engineHandle: THandle): TFloatType;
begin

end;

procedure TExternalBindingExport.engine_getSum(engineHandle, Source: THandle; var ScalarResult: float);
begin

end;

procedure TExternalBindingExport.engine_LinearDerivative(engineHandle, Target: THandle);
begin

end;

procedure TExternalBindingExport.engine_Log(engineHandle, Target: THandle);
begin

end;

procedure TExternalBindingExport.engine_Multiplication(engineHandle, Target: THandle; ScalarValue: float);
begin

end;

procedure TExternalBindingExport.engine_Multiplication(engineHandle, Source, Target: THandle);
begin

end;

procedure TExternalBindingExport.engine_Negate(engineHandle, Target: THandle);
begin

end;

procedure TExternalBindingExport.engine_Relu(engineHandle, Target: THandle);
begin

end;

procedure TExternalBindingExport.engine_ReluDerivative(engineHandle, Target: THandle);
begin

end;

procedure TExternalBindingExport.engine_ScaledTanh(engineHandle, Target: THandle);
begin

end;

procedure TExternalBindingExport.engine_ScaledTanhDerivative(engineHandle, Target: THandle);
begin

end;

procedure TExternalBindingExport.engine_Sigmoid(engineHandle, Target: THandle);
begin

end;

procedure TExternalBindingExport.engine_SigmoidDerivative(engineHandle, Target: THandle);
begin

end;

procedure TExternalBindingExport.engine_Softmax(engineHandle, Target: THandle);
begin

end;

procedure TExternalBindingExport.engine_Subtraction(engineHandle, Target: THandle; ScalarValue: float);
begin

end;

procedure TExternalBindingExport.engine_Subtraction(engineHandle, Source, Target: THandle);
begin

end;

procedure TExternalBindingExport.engine_Tanh(engineHandle, Target: THandle);
begin

end;

procedure TExternalBindingExport.engine_TanhDerivative(engineHandle, Target: THandle);
begin

end;

function TExternalBindingExport.object_getComputeBuffer(objectHandle: THandle): THandle;
begin

end;

function TExternalBindingExport.object_getComputeEngine(objectHandle: THandle): THandle;
begin

end;

function TExternalBindingExport.object_getElement(objectHandle: THandle; ElementIndex: uint64): float;
begin

end;

procedure TExternalBindingExport.object_getElements(objectHandle: THandle; ElementIndex, ElementCount: uint64; var Elements: TArrayOfFloat);
begin

end;

function TExternalBindingExport.object_getFloatSize(objectHandle: THandle): uint8;
begin

end;

function TExternalBindingExport.object_getFloatType(objectHandle: THandle): TFloatType;
begin

end;

function TExternalBindingExport.object_getHeight(objectHandle: THandle): uint64;
begin

end;

function TExternalBindingExport.object_getOffset(objectHandle: THandle): uint64;
begin

end;

function TExternalBindingExport.object_getWidth(objectHandle: THandle): uint64;
begin

end;

procedure TExternalBindingExport.object_setElement(objectHandle: THandle; ElementIndex: uint64; value: float);
begin

end;

procedure TExternalBindingExport.object_setElements(objectHandle: THandle; ElementIndex: uint64; Elements: TArrayOfFloat);
begin

end;

function TExternalBindingExport.provider_Create: THandle;
begin


end;

function TExternalBindingExport.provider_getDevice(providerHandle: THandle; DeviceIndex: uint64): THandle;
begin

end;

function TExternalBindingExport.provider_getDeviceCount(providerHandle: THandle): uint64;
begin

end;

procedure TExternalBindingExport.provider_getName(providerHandle: THandle; StringBuffer: pointer; BufferSize: uint32; var Returned: uint64);
begin

end;

end.
