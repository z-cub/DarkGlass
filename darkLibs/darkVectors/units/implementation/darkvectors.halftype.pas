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
unit darkvectors.halftype;

interface

type
  half = record
    value: word;
    class operator Implicit(a: single): half;
    class operator Implicit(a: half): single;
    class operator Implicit(a: double): half;
    class operator Implicit(a: half): double;
    {$ifndef CPU64BITS}
    class operator Explicit(a: single): half;
    class operator Explicit(a: half): single;
    class operator Explicit(a: double): half;
    class operator Explicit(a: half): double;
    {$endif}
    class operator Add(a, b: half): half;
    class operator Subtract(a, b: half): half;
    class operator Multiply(a, b: half): half;
    class operator Divide(a, b: half): half;
  end;

const
  HalfMin:     Single = 5.96046448e-08; // Smallest positive half
  HalfMinNorm: Single = 6.10351562e-05; // Smallest positive normalized half
  HalfMax:     Single = 65504.0;        // Largest positive half
  // Smallest positive e for which half (1.0 + e) != half (1.0)
  HalfEpsilon: Single = 0.00097656;
  HalfNaN:     half = ( value: 65535 );
  HalfPosInf:  half = ( value: 31744 );
  HalfNegInf:  half = ( value: 64512 );

implementation

function FloatToHalf(Float: Single): word;
var
  Src: LongWord;
  Sign, Exp, Mantissa: LongInt;
begin
  Src := PLongWord(@Float)^;
  // Extract sign, exponent, and mantissa from Single number
  Sign := Src shr 31;
  Exp := LongInt((Src and $7F800000) shr 23) - 127 + 15;
  Mantissa := Src and $007FFFFF;

  if (Exp > 0) and (Exp < 30) then
  begin
    // Simple case - round the significand and combine it with the sign and exponent
    Result := (Sign shl 15) or (Exp shl 10) or ((Mantissa + $00001000) shr 13);
  end
  else if Src = 0 then
  begin
    // Input float is zero - return zero
    Result := 0;
  end
  else
  begin
    // Difficult case - lengthy conversion
    if Exp <= 0 then
    begin
      if Exp < -10 then
      begin
        // Input float's value is less than HalfMin, return zero
         Result := 0;
      end
      else
      begin
        // Float is a normalized Single whose magnitude is less than HalfNormMin.
        // We convert it to denormalized half.
        Mantissa := (Mantissa or $00800000) shr (1 - Exp);
        // Round to nearest
        if (Mantissa and $00001000) > 0 then
          Mantissa := Mantissa + $00002000;
        // Assemble Sign and Mantissa (Exp is zero to get denormalized number)
        Result := (Sign shl 15) or (Mantissa shr 13);
      end;
    end
    else if Exp = 255 - 127 + 15 then
    begin
      if Mantissa = 0 then
      begin
        // Input float is infinity, create infinity half with original sign
        Result := (Sign shl 15) or $7C00;
      end
      else
      begin
        // Input float is NaN, create half NaN with original sign and mantissa
        Result := (Sign shl 15) or $7C00 or (Mantissa shr 13);
      end;
    end
    else
    begin
      // Exp is > 0 so input float is normalized Single

      // Round to nearest
      if (Mantissa and $00001000) > 0 then
      begin
        Mantissa := Mantissa + $00002000;
        if (Mantissa and $00800000) > 0 then
        begin
          Mantissa := 0;
          Exp := Exp + 1;
        end;
      end;

      if Exp > 30 then
      begin
        // Exponent overflow - return infinity half
        Result := (Sign shl 15) or $7C00;
      end
      else
        // Assemble normalized half
        Result := (Sign shl 15) or (Exp shl 10) or (Mantissa shr 13);
    end;
  end;
end;

function HalfToFloat(Half: word): Single;
var
  Dst, Sign, Mantissa: LongWord;
  Exp: LongInt;
begin
  // Extract sign, exponent, and mantissa from half number
  Sign := Half shr 15;
  Exp := (Half and $7C00) shr 10;
  Mantissa := Half and 1023;

  if (Exp > 0) and (Exp < 31) then
  begin
    // Common normalized number
    Exp := Exp + (127 - 15);
    Mantissa := Mantissa shl 13;
    Dst := (Sign shl 31) or (LongWord(Exp) shl 23) or Mantissa;
    // Result := Power(-1, Sign) * Power(2, Exp - 15) * (1 + Mantissa / 1024);
  end
  else if (Exp = 0) and (Mantissa = 0) then
  begin
    // Zero - preserve sign
    Dst := Sign shl 31;
  end
  else if (Exp = 0) and (Mantissa <> 0) then
  begin
    // Denormalized number - renormalize it
    while (Mantissa and $00000400) = 0 do
    begin
      Mantissa := Mantissa shl 1;
      Dec(Exp);
    end;
    Inc(Exp);
    Mantissa := Mantissa and not $00000400;
    // Now assemble normalized number
    Exp := Exp + (127 - 15);
    Mantissa := Mantissa shl 13;
    Dst := (Sign shl 31) or (LongWord(Exp) shl 23) or Mantissa;
    // Result := Power(-1, Sign) * Power(2, -14) * (Mantissa / 1024);
  end
  else if (Exp = 31) and (Mantissa = 0) then
  begin
    // +/- infinity
    Dst := (Sign shl 31) or $7F800000;
  end
  else //if (Exp = 31) and (Mantisa <> 0) then
  begin
    // Not a number - preserve sign and mantissa
    Dst := (Sign shl 31) or $7F800000 or (Mantissa shl 13);
  end;

  // Reinterpret LongWord as Single
  Result := PSingle(@Dst)^;
end;

{ half }

{$ifndef CPU64BITS}
class operator half.Explicit(a: single): half;
begin
  Result.Value := FloatToHalf(a);
end;

class operator half.Explicit(a: half): single;
begin
  Result := HalfToFloat(a.Value);
end;
{$endif}

class operator half.Add(a, b: half): half;
begin
  Result.value := FloatToHalf( HalfToFloat(a.value) + HalfToFloat(b.value) );
end;

class operator half.Divide(a, b: half): half;
begin
  Result.value := FloatToHalf( HalfToFloat(a.value) / HalfToFloat(b.value) );
end;

{$ifndef CPU64BITS}
class operator half.Explicit(a: half): double;
var
  s: single;
begin
  s := HalfToFloat(a.value);
  Result := S;
end;

class operator half.Explicit(a: double): half;
var
  s: single;
begin
  s := a;
  Result.value := FloatToHalf(s);
end;
{$endif}

class operator half.Implicit(a: half): single;
begin
  Result := HalfToFloat(a.value);
end;

class operator half.Implicit(a: single): half;
begin
  Result.value := FloatToHalf(a);
end;

class operator half.Implicit(a: double): half;
var
  s: single;
begin
  s := a;
  Result.value := FloatToHalf(s);
end;

class operator half.Implicit(a: half): double;
var
  s: single;
begin
  s := HalfToFloat(a.value);
  Result := s;
end;

class operator half.Multiply(a, b: half): half;
begin
  Result.value := FloatToHalf( HalfToFloat(a.value) * HalfToFloat(b.value) );
end;

class operator half.Subtract(a, b: half): half;
begin
  Result.value := FloatToHalf( HalfToFloat(a.value) - HalfToFloat(b.value) );
end;

end.

