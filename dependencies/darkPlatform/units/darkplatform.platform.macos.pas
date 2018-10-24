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
unit darkplatform.platform.macos;

interface
{$ifdef MACOS}
 {$ifndef IOS}
uses
  darkplatform.platform,
  darkplatform.displaymanager,
  darkplatform.windowmanager,
  darkplatform.platform.common,
  darkplatform.applicationdelegate.macos,
  Macapi.AppKit,
  Macapi.CoreFoundation,
  Macapi.Foundation,
  Macapi.ObjCRuntime,
  Macapi.CocoaTypes;

type
  TPlatform = class( TCommonPlatform, IPlatform )
  private
    fAutoReleasePool: NSAutoReleasePool; //- Auto-release pool for osx objects
    fNSApplication: NSApplication;       //- osx application class
    fApplicationDelegate: AppDelegate;
  private
    procedure DoInitialize;
    procedure DoTimer;
    procedure RedrawWindows;   //- essentially WM_PAINT
  protected //- Overrides of base class -//
    procedure doRun; override;
    function doCreateWindowManager: IWindowManager; override;
    function doCreateDisplayManager: IDisplayManager; override;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

 {$endif}
{$endif}
implementation
{$ifdef MACOS}
 {$ifndef IOS}
uses
  darkplatform.window,
  darkplatform.displaymanager.macos,
  darkplatform.windowmanager.macos,
  darkplatform.window.macos;

constructor TPlatform.Create;
begin
  inherited Create;
  fAutoReleasePool := TNSAutoReleasePool.Create;
  fNSApplication := TNSApplication.Wrap(TNSApplication.OCClass.sharedApplication);
  fApplicationDelegate := TAppDelegate.Create(DoInitialize,DoTimer);
  fNSApplication.setDelegate(fApplicationDelegate);
end;

destructor TPlatform.Destroy;
begin
  fAutoReleasePool.drain;
  inherited Destroy;
end;

procedure TPlatform.doRun;
begin
  fNSApplication.Run;
end;

procedure TPlatform.DoInitialize;
begin
  //-
end;

procedure TPlatform.DoTimer;
begin
  // Execute main loop
  RedrawWindows;
end;

procedure TPlatform.RedrawWindows;
var
  idx: nativeuint;
  aWindow: IWindow;
begin
  // Redraw windows
  if getWindowManager.Count=0 then begin
    Exit;
  end;
  for idx := 0 to pred(getWindowManager.count) do begin
    aWindow := getWindowManager.Windows[idx];
  end;
end;


function TPlatform.doCreateWindowManager: IWindowManager;
begin
  Result := TWindowManager.Create;
end;

function TPlatform.doCreateDisplayManager: IDisplayManager;
begin
  Result := TDisplayManager.Create;
end;

 {$endif}
{$endif}
end.
