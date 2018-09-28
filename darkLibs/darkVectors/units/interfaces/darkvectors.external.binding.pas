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
unit darkvectors.external.binding;

interface
uses
  darkDynlib;

type
  ///  <summary>
  ///    IVectorsBinding is an interface which may be passed through module
  ///    boundaries for loading compute engines from external dynamic
  ///    libraries.
  ///  </summary>
  IVectorsBinding = interface
    ['{46330E33-086A-4D58-9C55-1B2587CBF460}']

    //- Provider -//
    function provider_Create: THandle;
    procedure provider_getName( providerHandle: THandle; StringBuffer: pointer; BufferSize: uint32; var Returned: uint64 );
    function provider_getDeviceCount( providerHandle: THandle ): uint64;
    function provider_getDevice( providerHandle: THandle; DeviceIndex: uint64 ): THandle;

    //- Device -//
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

    //- Buffer -//
    function buffer_getFloatSize( bufferHandle: THandle ): uint8;
    function buffer_getHandle( bufferHandle: THandle ): pointer;
    function buffer_getComputeEngine( bufferHandle: THandle ): THandle;
    function buffer_getSize( bufferHandle: THandle ): uint64;
    procedure buffer_getData( bufferHandle: THandle; TargetPtr: pointer; Offset: uint64; cbBytes: uint64 );
    procedure buffer_setData( bufferHandle: THandle; SourcePtr: pointer; Offset: uint64; cbBytes: uint64 );
    function buffer_getObject( bufferHandle: THandle; OffsetElements: uint64; Height: uint64; Width: uint64 ): THandle;

    //- Object -//
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

    //- Engine -//
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

  end;

implementation

end.
