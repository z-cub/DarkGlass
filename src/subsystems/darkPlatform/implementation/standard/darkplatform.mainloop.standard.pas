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
unit darkplatform.mainloop.standard;

interface
uses
{$ifdef MSWINDOWS}
  darkplatform.mainloop.windows;
{$endif}
{$ifdef LINUX}
  darkplatform.mainloop.linux;
{$endif}
{$ifdef ANDROID}
  darkplatform.mainloop.android;
{$endif}
{$ifdef IOS}
  darkplatform.mainloop.ios;
{$endif}
{$ifdef MACOS}
  {$ifndef IOS}
  darkplatform.mainloop.macos;
  {$endif}
{$endif}

type
{$ifdef MSWINDOWS}
  TMainLoop = darkplatform.mainloop.windows.TMainLoop;
{$endif}
{$ifdef LINUX}
  TMainLoop = darkplatform.mainloop.linux.TMainLoop;
{$endif}
{$ifdef ANDROID}
  TMainLoop = darkplatform.mainloop.android.TMainLoop;
{$endif}
{$ifdef IOS}
  TMainLoop = darkplatform.mainloop.ios.TMainLoop;
{$endif}
{$ifdef MACOS}
  {$ifndef IOS}
  TMainLoop = darkplatform.mainloop.macos.TMainLoop;
  {$endif}
{$endif}

implementation

end.
