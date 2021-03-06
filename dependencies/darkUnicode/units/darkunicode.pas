﻿//------------------------------------------------------------------------------
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
/// <summary>
///   Provides the types required for working with the unicode codec.
/// </summary>
unit darkunicode;
{$ifdef fpc} {$mode delphiunicode} {$endif}

interface
uses
  darkunicode.codec;

type
  TUnicodeFormat = darkunicode.codec.TUnicodeFormat;
  TUnicodeCodePoint = darkunicode.codec.TUnicodeCodePoint;
  IUnicodeCodec = darkunicode.codec.IUnicodeCodec;

function Unicode: IUnicodeCodec;

implementation
uses
  darkunicode.codec.standard;

var
  /// <exclude />
  SingletonUnicodeCodec: IUnicodeCodec = nil;

function Unicode: IUnicodeCodec;
begin
  if not assigned(SingletonUnicodeCodec) then begin
    SingletonUnicodeCodec := TUnicodeCodec.Create;
  end;
  Result := SingletonUnicodeCodec;
end;

initialization
  SingletonUnicodeCodec := nil;

finalization
  SingletonUnicodeCodec := nil;

end.
