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
unit darkvectors.computeengine;

interface

type
  ///  <summary>
  ///    Specifies the float type to be used in the darkMath interfaces.
  ///    Note: This is not necessarily the same float type which is used
  ///    by the selected compute engine implementation internally. The type
  ///    will be appropriately converted by the implementation.
  ///  </summary>
  float = double;

  ///  <summary>
  ///    Represents a dynamic array of floats.
  ///  </summary>
  TArrayOfFloat = array of float;

type
  /// <summary>
  ///   Enumeration of the floating point data type which is supported by a
  ///   math engine. Note that the math engine may use a different float
  ///   type internally, to the one used in the darkMath interfaces.
  ///   The implementation will take care of the type conversion.
  /// </summary>
  TFloatType = (

    /// <summary>
    ///   IEEE-754 half precision floating point. (2-bytes)
    /// </summary>
    ftHalf,

    /// <summary>
    ///   IEEE-754 single precision floating point. (4-bytes)
    /// </summary>
    ftSingle,

    /// <summary>
    ///   IEEE-754 double precision floating point (8-bytes)
    /// </summary>
    ftDouble

  );

  ///  <summary>
  ///    Set type to indicate which floating points are supported by a
  ///    given implementation.
  ///  </summary>
  TFloatTypes = set of TFloatType;

  ///  <exclude/>
  IComputeEngine = interface; // forward.

  ///  <exclude/>
  IComputeObject = interface; // forward.

  ///  <summary>
  ///    Represents a data buffer which has been allocated on the target
  ///    math engine. For example, if computation is to be performed on the
  ///    GPU, then this represents a GPU buffer.
  ///  </summary>
  IComputeBuffer = interface
    ['{BB4313EE-91E7-4A50-8B48-8D3BFDDA2D2F}']

    ///  <summary>
    ///    Returns the size of the float supported by the math engine in bytes.
    ///  </summary>
    function getFloatSize: uint8;

    ///  <summary>
    ///    Used internally by implementations of IComputeEngine to uniquely
    ///    identify this buffer.
    ///  </summary>
    function getHandle: pointer;

    ///  <summary>
    ///    Returns the math engine instance on which this buffer was allocated.
    ///  </summary>
    function getComputeEngine: IComputeEngine;

    ///  <summary>
    ///    Returns the size of the engine buffer in bytes.
    ///  </summary>
    function getSize: uint64;

    ///  <summary>
    ///    Copies a block of data from this buffer at the specified offset,
    ///    into the pre-allocated buffer at the target pointer.
    ///    The number of bytes to be copied is specified by cbBytes.
    ///    Note: When obtaining data directly through this buffer, the data
    ///    will be provided in the floating point format which is supported
    ///    by the implementation. You should check the FloatType property of
    ///    the math engine to determine the appropriate data type.
    ///  </summary>
    procedure getData( TargetPtr: pointer; Offset: uint64; cbBytes: uint64 );

    ///  <summary>
    ///    Copies a block of data from the buffer at the source pointer,
    ///    into this buffer at the specified offset. The number of bytes to
    ///    be copied is specified in cbBytes.
    ///    Note: When providing data directly to this buffer, the data
    ///    must be provided in the floating point format which is supported
    ///    by the implementation. You should check the FloatType property of
    ///    the math engine to determine the appropriate data type.
    ///  </summary>
    procedure setData( SourcePtr: pointer; Offset: uint64; cbBytes: uint64 );

    ///  <summary>
    ///    Returns a math object (vector or matrix) as specified by the width
    ///    and height properties. The size of the object in bytes is determined
    ///    by the following formula  Width * Height * FloatSize.
    ///    OffsetElements specifies the number of floats at which to offset the
    ///    object within this buffer.
    ///  </summary>
    function getObject( OffsetElements: uint64; Height: uint64; Width: uint64 ): IComputeObject;

    //- Pascal only -//

    ///  <summary>
    ///    The handle of the buffer on the target device.
    ///    *Varies among implementations.
    ///  </summary>
    property Handle: pointer read getHandle;

    ///  <summary>
    ///    Provides a reference to the math engine instance to which this
    ///    buffer belongs.
    ///  </summary>
    property Engine: IComputeEngine read getComputeEngine;

    ///  <summary>
    ///    Returns the size of the buffer in bytes.
    ///  </summary>
    property Size: uint64 read getSize;

    ///  <summary>
    ///    Returns the size of a float according to the math engine.
    ///  </summary>
    property FloatSize: uint8 read getFloatSize;
  end;

  ///  <summary>
  ///    Represents an object (Matrix/Vector) which exists within an engine
  ///    buffer.
  ///  </summary>
  IComputeObject = interface
    ['{4909C273-0CA3-4864-A6C9-F619679B62E1}']

    ///  <summary>
    ///    Returns the instance of an IComputeBuffer to which this object
    ///    belongs.
    ///  </summary>
    function getComputeBuffer: IComputeBuffer;

    ///  <summary>
    ///    Returns the math engine to which this object belongs.
    ///  </summary>
    function getComputeEngine: IComputeEngine;

    ///  <summary>
    ///    Returns the offset of this object within the buffer, in bytes.
    ///  </summary>
    function getOffset: uint64;

    ///  <summary>
    ///    Returns an enumeration which determines the actual float type used
    ///    by the engine to which this object belogs. This may be different to
    ///    the float type used to access the data within the object, as methods
    ///    of this object will perform floating point translation
    ///    (by assignment) automatically. For best performance however,
    ///    objects should be accessed using the same data type as the
    ///    math engine, which can be determined through this type.
    ///  </summary>
    function getFloatType: TFloatType;

    ///  <summary>
    ///    Returns the size of the float which is supported by this object.
    ///    (As determined by the owning engine)
    ///  </summary>
    function getFloatSize: uint8;

    ///  <summary>
    ///    Returns the specified number of elements "ElementCount" starting at
    ///    the specified index "ElementIndex" in the Elements array.
    ///  </summary>
    procedure getElements( ElementIndex: uint64; ElementCount: uint64; var Elements: TArrayOfFloat );

    ///  <summary>
    ///    Sets elements in the object beginning at ElementIndex to the
    ///    values in the elements array.
    ///  </summary>
    procedure setElements( ElementIndex: uint64; Elements: TArrayOfFloat );

    ///  <summary>
    ///    Returns the specified element from the object.
    ///  </summary>
    function getElement( ElementIndex: uint64 ): float;

    ///  <summary>
    ///    Sets the specified element in the object.
    ///  </summary>
    procedure setElement( ElementIndex: uint64; value: float );

    ///  <summary>
    ///    Returns the width of this engine object in 'elements', where the
    ///    size of an element is determined by the data-type supported by
    ///    the math engine.
    ///  </summary>
    function getWidth: uint64;

    ///  <summary>
    ///    Returns the height fo this engine object in 'elements', where the
    ///    size of an element is determined by the data-type supported by the
    ///    math engine.
    ///  </summary>
    function getHeight: uint64;

    //- Pascal Only, Properties -//

    ///  <summary>
    ///    Returns a reference to the engine buffer in which this engine object
    ///    is stored.
    ///  </summary>
    property Buffer: IComputeBuffer read getComputeBuffer;

    ///  <summary>
    ///    Returns a reference to the math engine which hosts the buffer in
    ///    which this object is stored. This is the engine that will perform
    ///    computation on this object.
    ///  </summary>
    property Engine: IComputeEngine read getComputeEngine;

    ///  <summary>
    ///    Returns an enumeration which describes the type of floating
    ///    point data stored within this object. This will match the floating
    ///    point data type which is supported by the math engine which will
    ///    perform computation on this object.
    ///  </summary>
    property FloatType: TFloatType read getFloatType;

    ///  <summary>
    ///    Returns the size (in bytes) of the floating point data type which
    ///    is supported by the math engine that will perform computation on
    ///    this object.
    ///  </summary>
    property FloatSize: uint8 read getFloatSize;

    ///  <summary>
    ///    Returns the width of this object in elements.
    ///  </summary>
    property Width: uint64 read getWidth;

    ///  <summary>
    ///    Returns the height of this object in elements.
    ///  </summary>
    property Height: uint64 read getHeight;

    ///  <summary>
    ///    Provides array style access to the elements within this object.
    ///    It is advised to use the getElements() and setElements() methods
    ///    to get and set object data in bulk operations for performance
    ///    reasons, however, this property can be used when only a single
    ///    element must be read or written to.
    ///  </summary>
    property Elements[ index: uint64 ]: float read getElement write setElement;
  end;

  ///  <summary>
  ///    Represents a math engine, which is used to host instances of
  ///    IComputeBuffer, and to perform computation on instances of
  ///    IComputeObject.
  ///  </summary>
  IComputeEngine = interface
  ['{6AA5C4A8-E7F9-416E-AD49-2E567D69EA00}']

    ///  <summary>
    ///    Returns the type of float supported by this engine.
    ///  </summary>
    function getFloatType: TFloatType;

    ///  <summary>
    ///    Returns the size of the supported floating point type in bytes.
    ///  </summary>
    function getFloatSize: uint8;

    ///  <summary>
    ///    Requests a buffer be created on the math engine.
    ///    The size of the buffer is specified in ElementCount, where the
    ///    actual size of an element is determined by FloatSize.
    ///    If the buffer is sucessfully allocated, an instance of
    ///    IComputeBuffer is returned, else the return value is nil.
    ///    If allocation fails, it will be due to either ElementCount*FloatSize
    ///    exceeding MaxAllocation, or due to there being insufficient memory
    ///    available on the target device.
    ///  </summary>
    function getBuffer( ElementCount: uint64 ): IComputeBuffer;

    ///  <summary>
    ///    Calculates the sum of all elements within the Source object and
    ///    places the result in 'ScalarResult'.
    ///  </summary>
    procedure getSum( Source: IComputeObject; var ScalarResult: float ); overload;

    ///  <summary>
    ///    Adds each element of the Source object to the corresponding element
    ///    of the Target object. The source and target objects must be the
    ///    same size.
    ///  </summary>
    procedure Addition( Source: IComputeObject; Target: IComputeObject ); overload;

    ///  <summary>
    ///    Adds ScalarValue to each element of the target object.
    ///  </summary>
    procedure Addition( Target: IComputeObject; ScalarValue: float ); overload;

    ///  <summary>
    ///    Subtracts each element of the source object from the corresponding
    ///    element of the target object. The source and target objects must
    ///    be the same size.
    ///  </summary>
    procedure Subtraction( Source: IComputeObject; Target: IComputeObject ); overload;

    ///  <summary>
    ///    Subtracts the ScarlarValue from each element in the target object.
    ///  </summary>
    procedure Subtraction( Target: IComputeObject; ScalarValue: float ); overload;

    ///  <summary>
    ///    Multiplies each element in the Target object by the corresponding
    ///    element in the source object.
    ///  </summary>
    procedure Multiplication( Source: IComputeObject; Target: IComputeObject ); overload;

    ///  <summary>
    ///    Multiplies each element in the Target object by ScalarValue.
    ///  </summary>
    procedure Multiplication( Target: IComputeObject; ScalarValue: float ); overload;

    ///  <summary>
    ///    Divides each element in the Target object by the corresponding
    ///    element in the Source object.
    ///  </summary>
    procedure Division( Source: IComputeObject; Target: IComputeObject ); overload;

    ///  <summary>
    ///    Divides each element in the Target object by ScalarValue.
    ///  </summary>
    procedure Division( Target: IComputeObject; ScalarValue: float ); overload;

    ///  <summary>
    ///    Performs a Tanh operation on each element of the Target object.
    ///  </summary>
    procedure Tanh( Target: IComputeObject );

    ///  <summary>
    ///    Performs a Tanh operation on each element of the Target object
    ///    scaled to the range -1 .. 1
    ///  </summary>
    procedure ScaledTanh( Target: IComputeObject );

    ///  <summary>
    ///    Performs the sigmoid function on each element of the Target object.
    ///  </summary>
    procedure Sigmoid( Target: IComputeObject  );

    ///  <summary>
    ///    Performs the Relu funciton on each element of the Target object.
    ///  </summary>
    procedure Relu( Target: IComputeObject );

    ///  <summary>
    ///    Performs the Elu function on each element of the Target object.
    ///  </summary>
    procedure Elu( Target: IComputeObject );

    ///  <summary>
    ///    Performs a softmax calculation on the Target object.
    ///  </summary>
    procedure Softmax( Target: IComputeObject );

    ///  <summary>
    ///    Calculates the derivative of TanH on each element of the Target
    ///    object.
    ///  </summary>
    procedure TanhDerivative( Target: IComputeObject );

    ///  <summary>
    ///    Calculates the derivative of TanH scaled to -1..1 on each element
    ///    of the Target object.
    ///  </summary>
    procedure ScaledTanhDerivative( Target: IComputeObject );

    ///  <summary>
    ///    Calculates the derivative of the sigmoid funciton on each element
    ///    of the Target object.
    ///  </summary>
    procedure SigmoidDerivative( Target: IComputeObject );

    ///  <summary>
    ///    Calculates the derivative of the Relu function on each element of
    ///    the Target object.
    ///  </summary>
    procedure ReluDerivative( Target: IComputeObject );

    ///  <summary>
    ///    Calculates the derivative of the Elu function on each element of
    ///    the Target object.
    ///  </summary>
    procedure EluDerivative( Target: IComputeObject );

    ///  <summary>
    ///    Calculates the derivative of linear mapping on each element of
    ///    the Target object.
    ///  </summary>
    procedure LinearDerivative( Target: IComputeObject );

    ///  <summary>
    ///    Sets each element in the Target object to it's natural log.
    ///  </summary>
    procedure Log( Target: IComputeObject );

    ///  <summary>
    ///    Sets each element in the Target object to it's exponent.
    ///  </summary>
    procedure Exp( Target: IComputeObject );

    ///  <summary>
    ///    Sets each element of the target object to ScalarValue.
    ///  </summary>
    procedure Fill( Target: IComputeObject; ScalarValue: float );

    ///  <summary>
    ///    Subtracts each element of the target object from zero.
    ///  </summary>
    procedure Negate( Target: IComputeObject );

    ///  <summary>
    ///    Copies the Source object to the Target object.
    ///    Note the Source and Target objects must be the same size.
    ///  </summary>
    procedure Copy( Source: IComputeObject; Target: IComputeObject );

    ///  <summary>
    ///    Calculates the dot-product of the SourceA and SourceB objects and
    ///    places the result in the Target object.
    ///    This override of the dot-product method should be used when
    ///    expecting the dot-product calculation to generate a matrix or
    ///    vector.
    ///  </summary>
    procedure DotProduct( SourceA: IComputeObject; SourceB: IComputeObject; Target: IComputeObject ); overload;

    ///  <summary>
    ///    Calculates the dot-product of the SourceA and SourceB objects and
    ///    places the result in ScalarResult.
    ///    This override of the dot-product method should be used when
    ///    expecting the dot-product calculation to generate a scalar value.
    ///  </summary>
    procedure DotProduct( SourceA: IComputeObject; SourceB: IComputeObject; var ScalarResult: float ); overload;

    //- Pascal Only -//
    property FloatType: TFloatType read getFloatType;
    property FloatSize: uint8 read getFloatSize;
  end;


implementation

end.
