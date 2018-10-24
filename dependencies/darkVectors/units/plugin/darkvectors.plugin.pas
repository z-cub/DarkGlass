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
unit darkvectors.plugin;

interface
uses
  darkvectors.computeengine,
  darkPlugins.plugin;

type
  IComputePlugin = interface( IPlugin )
    ['{13B0DC50-7202-45A4-9E59-3D1760FA6020}']

    //- Free any handles allocated -//
    procedure FreeHandle( Handle: THandle );

    //- Compute Provider -//
    function cp_create: THandle;
    procedure cp_getName( Provider: THandle; lpName: pointer; var Bytes: uint32 );
    function cp_getDeviceCount( Provider: THandle ): uint64;
    function cp_getDevice( Provider: THandle; DeviceIndex: uint64 ): THandle;

    //- Compute Device -//
    procedure cd_getName( Device: THandle; lpName: pointer; var Bytes: uint32 );
    procedure cd_getVendor( Device: THandle; lpVendor: pointer; var Bytes: uint32 );
    function cd_getClockSpeed( Device: THandle ): uint32;
    function cd_getCoreCount( Device: THandle ): uint32;
    function cd_getMemorySize( Device: THandle ): uint64;
    function cd_getMaxAllocation( Device: THandle ): uint64;
    function cd_getMemoryInUse( Device: THandle ): uint64;
    function cd_getMemoryAvailable( Device: THandle ): uint64;
    function cd_getSupportedTypes( Device: THandle ): TFloatTypes;
    function cd_getEngine( Device: THandle; FloatType: TFloatType ): THandle;

    //- Compute Buffer -//
    function cb_getObject( Buffer: THandle; OffsetElements: uint64; Height: uint64; Width: uint64 ): THandle;
    function cb_getHandle( Buffer: THandle ): pointer;
    function cb_getSize( Buffer: THandle ): uint64;
    function cb_getFloatSize( Buffer: THandle ): uint8;
    procedure cb_getData( Buffer: THandle; TargetPtr: pointer; Offset: uint64; cbBytes: uint64 );
    procedure cb_setData( Buffer: THandle; SourcePtr: pointer; Offset: uint64; cbBytes: uint64 );

    //- Compute Engine -//
    function ce_getFloatType( Engine: THandle ): TFloatType;
    function ce_getFloatSize( Engine: THandle ): uint8;
    function ce_getBuffer( Engine: THandle; ElementCount: uint64 ): THandle;
    procedure ce_getSum( Engine: THandle; Source: THandle; var ScalarResult: float ); overload;
    procedure ce_Addition( Engine: THandle; Source: THandle; Target: THandle ); overload;
    procedure ce_Addition( Engine: THandle; Target: THandle; ScalarValue: float ); overload;
    procedure ce_Subtraction( Engine: THandle; Source: THandle; Target: THandle ); overload;
    procedure ce_Subtraction( Engine: THandle; Target: THandle; ScalarValue: float ); overload;
    procedure ce_Multiplication( Engine: THandle; Source: THandle; Target: THandle ); overload;
    procedure ce_Multiplication( Engine: THandle; Target: THandle; ScalarValue: float ); overload;
    procedure ce_Division( Engine: THandle; Source: THandle; Target: THandle ); overload;
    procedure ce_Division( Engine: THandle; Target: THandle; ScalarValue: float ); overload;
    procedure ce_Tanh( Engine: THandle; Target: THandle );
    procedure ce_ScaledTanh( Engine: THandle; Target: THandle );
    procedure ce_Sigmoid( Engine: THandle; Target: THandle  );
    procedure ce_Relu( Engine: THandle; Target: THandle );
    procedure ce_Elu( Engine: THandle; Target: THandle );
    procedure ce_Softmax( Engine: THandle; Target: THandle );
    procedure ce_TanhDerivative( Engine: THandle; Target: THandle );
    procedure ce_ScaledTanhDerivative( Engine: THandle; Target: THandle );
    procedure ce_SigmoidDerivative( Engine: THandle; Target: THandle );
    procedure ce_ReluDerivative( Engine: THandle; Target: THandle );
    procedure ce_EluDerivative( Engine: THandle; Target: THandle );
    procedure ce_LinearDerivative( Engine: THandle; Target: THandle );
    procedure ce_Log( Engine: THandle; Target: THandle );
    procedure ce_Exp( Engine: THandle; Target: THandle );
    procedure ce_Fill( Engine: THandle; Target: THandle; ScalarValue: float );
    procedure ce_Negate( Engine: THandle; Target: THandle );
    procedure ce_Copy( Engine: THandle; Source: THandle; Target: THandle );
    procedure ce_DotProduct( Engine: THandle; SourceA: THandle; SourceB: THandle; Target: THandle ); overload;
    procedure ce_DotProduct( Engine: THandle; SourceA: THandle; SourceB: THandle; var ScalarResult: float ); overload;
    procedure ce_InsertRow( Engine: THandle; Source: THandle; Target: THandle; RowIndex: uint64 );
    procedure ce_InsertColumn( Engine: THandle; Source: THandle; Target: THandle; ColumnIndex: uint64 );
    procedure ce_ExtractRow( Engine: THandle; Source: THandle; Target: THandle; RowIndex: uint64 );
    procedure ce_ExtractColumn( Engine: THandle; Source: THandle; Target: THandle; ColumnIndex: uint64 );
    procedure ce_Transpose( Engine: THandle; Source: THandle; Target: THandle );
    procedure ce_AddOnRow( Engine: THandle; Source: THandle; Target: THandle; RowIndex: uint64 );
    procedure ce_SubtractOnRow( Engine: THandle; Source: THandle; Target: THandle; RowIndex: uint64 );
    procedure ce_MultiplyOnRow( Engine: THandle; Source: THandle; Target: THandle; RowIndex: uint64 );
    procedure ce_DivideOnRow( Engine: THandle; Source: THandle; Target: THandle; RowIndex: uint64 );
    procedure ce_AddOnColumn( Engine: THandle; Source: THandle; Target: THandle; ColumnIndex: uint64 );
    procedure ce_SubtractOnColumn( Engine: THandle; Source: THandle; Target: THandle; ColumnIndex: uint64 );
    procedure ce_MultiplyOnColumn( Engine: THandle; Source: THandle; Target: THandle; ColumnIndex: uint64 );
    procedure ce_DivideOnColumn( Engine: THandle; Source: THandle; Target: THandle; ColumnIndex: uint64 );

    //- Compute Object -//
    function co_getOffset( ComputeObject: THandle ): uint64;
    function co_getFloatType( ComputeObject: THandle ): TFloatType;
    function co_getFloatSize( ComputeObject: THandle ): uint8;
    procedure co_getElements( ComputeObject: THandle; ElementIndex: uint64; ElementCount: uint64; var Elements: TArrayOfFloat );
    procedure co_setElements( ComputeObject: THandle; ElementIndex: uint64; Elements: TArrayOfFloat );
    function co_getElement( ComputeObject: THandle; ElementIndex: uint64 ): float;
    procedure co_setElement( ComputeObject: THandle; ElementIndex: uint64; value: float );
    function co_getWidth( ComputeObject: THandle ): uint64;
    function co_getHeight( ComputeObject: THandle ): uint64;
  end;

implementation

end.
