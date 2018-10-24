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
unit darkvectors;

interface
uses
  darkvectors.computeprovider,
  darkvectors.computedevice,
  darkvectors.computeengine,
  darkvectors.computeproviders.singleton,
  darkvectors.computeprovider.software,
  darkvectors.computeprovider.import,
  darkvectors.vector,
  darkvectors.matrix;


type
  ///  <summary>
  ///    Alias of the floating point type which was used to compile darkMath.
  ///  </summary>
  float = darkvectors.computeengine.float;
  TArrayOfFloat = darkvectors.computeengine.TArrayOfFloat;


  TFloatType = darkvectors.computeengine.TFloatType;
  TFloatTypes = darkvectors.computeengine.TFloatTypes;

  ///  <summary>
  ///    Represents a vector of floating point numbers.
  ///  </summary>
  Vector = darkvectors.vector.Vector;

  ///
  ///  <summary>
  ///    Represents a matrix of floating point numbers.
  ///  </summary>
  Matrix = darkvectors.matrix.Matrix;

  ///
  IComputeEngine = darkvectors.computeengine.IComputeEngine;
  IComputeDevice = darkvectors.computedevice.IComputeDevice;
  IComputeProvider = darkvectors.computeprovider.IComputeProvider;
  ComputeProviders = darkvectors.computeproviders.singleton.ComputeProviders;
  TSoftwareComputeProvider = darkvectors.computeprovider.software.TSoftwareComputeProvider;
  TPluginComputeProvider = darkvectors.computeprovider.import.TComputeProvider;


  function VectorToStr( V: Vector ): string;
  function MatrixToStr( M: Matrix ): String;

var
  ///
  ///  <summary>
  ///    ComputeEngine must be set before using Vectors or Matrices, as the
  ///    Vector and Matrix types use ComputeEngine to allocate memory on the
  ///    appropriate computation device.
  ///  </summary>
  ComputeEngine: IComputeEngine = nil;

implementation
uses
  sysutils;

function PadString( S: string; Width: uint32 ): string; inline;
var
  idx: uint32;
begin
  Result := '';
  if Length(S)<Width then begin
    for idx := 0 to pred((Width-Length(S))) do begin
      Result := Result + ' ';
    end;
  end;
  Result := Result + S;
end;

function VectorToStr( V: Vector ): string;
var
  idx: uint64;
begin
  Result := '[ ';
  for idx := 0 to pred(v.Count) do begin
    Result := Result + FloatToStr(v[idx]);
    if idx<pred(v.count) then begin
      Result := Result + ' , ';
    end;
  end;
  Result := Result + ' ]';
end;

function MatrixToStr( M: Matrix ): String;
var
  idy: uint64;
  idx: uint64;
  CharWidth: uint32;
  T: uint32;
begin
  //- Measure numbers first to get column width.
  CharWidth := 0;
  for idy := 0 to pred(M.Height) do begin
    for idx := 0 to pred(M.Width) do begin
      T := Length( FloatToStr( M[idy,idx] ) );
      if T>CharWidth then begin
        CharWidth := T;
      end;
    end;
  end;
  //- Now build result string.
  for idy := 0 to pred( M.Height ) do begin
    if idy>0 then begin
      Result := Result + '';
    end;
    Result := Result + ' [ ';
    for idx := 0 to pred(M.Width) do begin
      Result := Result + PadString( FloatToStr(M[idy,idx]), CharWidth );
      if idx<pred(M.Width) then begin
        Result := Result + ',';
      end;
    end;
    Result := Result + ' ]';
    if idy<pred(M.Height) then begin
      Result := Result + sLineBreak;
    end;
  end;
end;


initialization
  ComputeEngine := ComputeProviders.Add(TSoftwareComputeProvider.Create).Devices[0].getEngine(TFloatType.ftSingle);

finalization
  ComputeEngine := nil;
end.
