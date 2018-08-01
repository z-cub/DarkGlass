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
unit darkplatform.displaymanager.windows;

interface
{$ifdef MSWINDOWS}
uses
  darkplatform.display,
  darkplatform.displaymanager,
  darkplatform.displaymanager.common;

type
  TDisplayManager = class( TCommonDisplayManager )
  private
    procedure CreateDisplayWithDimensions(Name: string; left, top, right, bottom: int32);
  public
    constructor Create; reintroduce;
  end;

{$endif}
implementation
{$ifdef MSWINDOWS}
uses
  SysUtils,
  classes,
  darkWin32api.types,
  darkWin32api.user32,
  darkplatform.display.windows;

function MonitorEnumProc( Handle: THandle; hdcMonitor: THDC; lprcMonitor: pRect; dwData: TLParam ): longbool; stdcall;
var
  MonitorInfo: TMonitorInfoEx;
  Str: string;
begin
  Result := True;
  FillChar(MonitorInfo,sizeof(TMonitorInfoEx),0);
  MonitorInfo.cbSize := SizeOf(TMonitorInfoEx);
  if GetMonitorInfo(Handle, @MonitorInfo) then begin
    Str := MonitorInfo.szDevice;
    TDisplayManager(pointer(dwData)).CreateDisplayWithDimensions(Str,lprcMonitor^.left,lprcMonitor^.top,lprcMonitor^.right,lprcMonitor^.bottom);
  end else begin
    RaiseLastOSError;
  end;
end;

procedure TDisplayManager.CreateDisplayWithDimensions( Name: string; left: int32; top: int32; right: int32; bottom: int32 );
begin
  AddDisplay(TDisplay.Create(getCount, Name, left, top, right, bottom ));
end;

constructor TDisplayManager.Create;
begin
  inherited Create;
  EnumDisplayMonitors(0,nil, {$ifdef fpc}@{$endif}MonitorEnumProc,TLParam(Self));
end;

{$endif}
end.
