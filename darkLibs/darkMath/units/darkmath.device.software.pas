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
unit darkmath.device.software;
{$ifdef fpc} {$ifdef CPU64} {$define CPU64BITS} {$endif} {$endif}

interface
uses
  darkmath.engine,
  darkmath.device;

type
  TComputeDevice = class( TInterfacedObject, IComputeDevice )
  private
    fHalfMathEngine: IMathEngine;
    fSingleMathEngine: IMathEngine;
    fDoubleMathEngine: IMathEngine;
    {$ifdef CPU64BITS} fExtendedMathEngine: IMathEngine; {$endif}
  private //- IComputeDevice -//
   function getName: string;
   function getVendor: string;
   function getClockSpeed: uint32;
   function getCoreCount: uint32;
   function getMemorySize: uint64;
   function getMaxAllocation: uint64;
   function getMemoryInUse: uint64;
   function getMemoryAvailable: uint64;
   function getSupportedTypes: TFloatTypes;
   function getEngine( FloatType: TFloatType ): IMathEngine;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  {$ifdef MSWINDOWS}
  windows,
  registry,
  {$endif}
  darkMath.engine.software;


{ TComputeDevice }

{$ifdef MSWINDOWS}
function GetCPUSpeed: int32;
var
  Reg : TRegistry;
begin
 Result := 0;
 Reg := TRegistry.Create(KEY_QUERY_VALUE);
 try
  Reg.RootKey := HKEY_LOCAL_MACHINE;
  if Reg.OpenKeyReadOnly('HARDWARE\DESCRIPTION\System\CentralProcessor\0') then
   begin
    Result := Reg.ReadInteger('~MHz');
    Reg.CloseKey;
   end;
 finally
  Reg.Free;
 end;
end;
{$endif}

constructor TComputeDevice.Create;
begin
  inherited Create;
  fHalfMathEngine := nil;
  fSingleMathEngine := nil;
  fDoubleMathEngine := nil;
end;

destructor TComputeDevice.Destroy;
begin
  fHalfMathEngine := nil;
  fSingleMathEngine := nil;
  fDoubleMathEngine := nil;
  inherited Destroy;
end;

function TComputeDevice.getClockSpeed: uint32;
begin
  Result := GetCPUSpeed;
end;

function TComputeDevice.getCoreCount: uint32;
begin
  Result := System.CPUCount;
end;

function TComputeDevice.getEngine(FloatType: TFloatType): IMathEngine;
begin
  Result := nil;
  case FloatType of

    ftHalf: begin
      if not assigned(fHalfMathEngine) then begin
        fHalfMathEngine := TMathEngine.Create( FloatType );
      end;
      Result := fHalfMathEngine;
    end;

    ftSingle: begin
      if not assigned(fSingleMathEngine) then begin
        fSingleMathEngine := TMathEngine.Create( FloatType );
      end;
      Result := fSingleMathEngine;
    end;

    ftDouble: begin
      if not assigned(fDoubleMathEngine) then begin
        fDoubleMathEngine := TMathEngine.Create( FloatType );
      end;
      Result := fDoubleMathEngine;
    end;

    {$ifdef CPU64BITS}
    ftExtended: begin
      if not assigned(fExtendedMathEngine) then begin
        fExtendedMathEngine := TMathEngine.Create( FloatType );
      end;
      Result := fExtendedMathEngine;
    end;
    {$endif}

  end;
end;

function TComputeDevice.getMaxAllocation: uint64;
begin
  Result := $FFFFFFFFFFFFFFFF;
end;

function TComputeDevice.getMemoryAvailable: uint64;
{$ifdef MSWINDOWS}
var
  RamStats: TMemoryStatus;
begin
  GlobalMemoryStatus(RamStats);
  Result := RamStats.dwAvailPhys;
end;
{$else}
begin
 . //- compile error
end;
{$endif}

function TComputeDevice.getMemoryInUse: uint64;
{$ifdef MSWINDOWS}
var
  RamStats: TMemoryStatus;
begin
  GlobalMemoryStatus(RamStats);
  Result := RamStats.dwMemoryLoad;
end;
{$else}
begin
 . //- compile error
end;
{$endif}

function TComputeDevice.getMemorySize: uint64;
{$ifdef MSWINDOWS}
var
  RamStats: TMemoryStatus;
begin
  GlobalMemoryStatus(RamStats);
  Result := RamStats.dwTotalPhys;
end;
{$else}
begin
 . //- compile error
end;
{$endif}

function TComputeDevice.getName: string;
begin
  Result := 'CPU';
end;

function TComputeDevice.getSupportedTypes: TFloatTypes;
begin
  Result := [ TFloatType.ftHalf, TFloatType.ftSingle, TFloatType.ftDouble ];
  {$ifdef CPU64BITS}
  Result := [ TFloatType.ftHalf, TFloatType.ftSingle, TFloatType.ftDouble, TFloatType.ftExtended ];
  {$endif}
end;

function TComputeDevice.getVendor: string;
begin
  Result := '(>E) >igital Envy Software'
end;

end.
