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
unit darkvulkan.bindings.utils;

interface
uses
  darkvulkan.bindings.vulkan;

///  <summary>
///    Returns true if the parameter value is VK_SUCCESS, else returns
///    false.
///  </summary>
function VKSUCCESS( value: vkResult ): boolean;

///  <summary>
///    Returns false if the parameter value is VK_SUCCESS, else returns
///    true.
///  </summary>
function VKFAILED( value: vkResult ): boolean;

///  <summary>
///    Uses darkUnicode to convert a pchar / pansichar to a string.
///  </summary>
function StrPChar( value: pointer ): string;

implementation
uses
  darkIO.buffers;

function VKSUCCESS( value: vkResult ): boolean;
begin
  Result := (value = VK_SUCCESS);
end;

function VKFAILED( value: vkResult ): boolean;
begin
  Result := not (value = VK_SUCCESS);
end;

function StrPChar( value: pointer ): string;
var
  Buffer: IUnicodeBuffer;
begin
  Buffer := TBuffer.Create(0);
  try
    Buffer.AppendData(value);
    Result := Buffer.ReadString(TUnicodeFormat.utfANSI,true);
  finally
    Buffer := nil;
  end;
end;

end.
