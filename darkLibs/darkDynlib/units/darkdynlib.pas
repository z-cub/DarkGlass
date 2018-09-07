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
/// <summary>
///   Delphi platform-agnostic wrapper classes around OS dynamic library
///   loading functions.
/// </summary>
unit darkdynlib;
{$ifdef fpc} {$mode delphiunicode} {$endif}

interface
uses
  darkdynlib.dynlib;

type
  /// <exclude/>
  IDynLib = darkdynlib.dynlib.IDynlib;

type
  /// <summary>
  ///   Provides a platform agnostic implementation of IDynLib. <br />TDynLib
  ///   is a factory class, providing the Create() method to resemble a
  ///   standard class constructor.
  /// </summary>
  TDynLib = class
  public
    /// <exclude />
    class function Create: IDynlib; static;
  end;

implementation
{$ifdef MSWINDOWS}
uses
  darkDynlib.dynlib.windows;
{$else}
uses
  darkDynlib.dynlib.posix;
{$endif}

class function TDynLib.Create: IDynlib;
begin
{$ifdef MSWINDOWS}
  Result := TWindowsDynLib.Create;
{$else}
  Result := TPosixDynLib.Create;
{$endif}
end;

end.
