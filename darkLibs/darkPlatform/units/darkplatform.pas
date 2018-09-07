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
unit darkPlatform;

interface
uses
  darkplatform.display,
  darkplatform.window,
  darkplatform.displaymanager,
  darkplatform.windowmanager,
  darkplatform.platform;

type
 IPlatform       = darkplatform.platform.IPlatform;
 IDisplay        = darkplatform.display.IDisplay;
 IWindow         = darkplatform.window.IWindow;
 IDisplayManager = darkplatform.displaymanager.IDisplayManager;
 IWindowManager  = darkplatform.windowmanager.IWindowManager;


///  <summary>
///    Returns a singleton instance of IPlatform.
///  </summary>
function Platform: IPlatform;

implementation
uses //- This will error on build if there are no matching conditions.
  {$ifdef MSWINDOWS}
  darkplatform.platform.windows;
  {$endif}
  {$ifdef LINUX}
  darkplatform.platform.linux;
  {$endif}
  {$ifdef ANDROID}
  darkplatform.platform.android;
  {$endif}
  {$ifdef MACOS}
    {$ifdef IOS}
    darkplatform.platform.ios;
    {$else}
    darkplatform.platform.macos;
    {$endif}
  {$endif}


var
  SingletonPlatform: IPlatform = nil;

function Platform: IPlatform;
begin
  if not assigned(SingletonPlatform) then begin
    {$ifdef MSWINDOWS}          SingletonPlatform := darkplatform.platform.windows.TPlatform.Create;  {$endif}
    {$ifdef LINUX}              SingletonPlatform := darkplatform.platform.linux.TPlatform.Create;    {$endif}
    {$ifdef ANDROID}            SingletonPlatform := darkplatform.platform.android.TPlatform.Create;  {$endif}
    {$ifdef MACOS} {$ifdef IOS} SingletonPlatform := darkplatform.platform.ios.TPlatform.Create;
    {$else}                     SingletonPlatform := darkplatform.platform.macos.TPlatform.Create;    {$endif} {$endif}
  end;
  Result := SingletonPlatform;
end;

initialization

finalization
  SingletonPlatform := nil;

end.

