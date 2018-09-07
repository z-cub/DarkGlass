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
unit darkplatform.applicationdelegate.macos;

interface
{$ifdef MACOS} {$ifndef IOS} {$define OSX} {$endif} {$endif}
{$ifdef OSX}
uses
  System.SysUtils,
  Macapi.AppKit,
  Macapi.ObjCRuntime,
  Macapi.ObjectiveC,
  Macapi.Foundation,
  Macapi.CocoaTypes;

type
  TNotificationEvent = procedure of object;

  AppDelegate = interface(NSApplicationDelegate)
    ['{2E84EB44-1E75-45C8-A641-29F2D7D53189}']
    procedure accumulateFires(theTimer: NSTimer); cdecl;
    function applicationShouldTerminate(Notification: NSNotification): NSInteger; cdecl;
    procedure applicationWillFinishLaunching(notification: Pointer); cdecl;
    function applicationShouldTerminateAfterLastWindowClosed(sender: pointer): NSInteger; cdecl;
  end;

  TAppDelegate = class(TOCLocal, AppDelegate)
  private
    fOnInitialize: TNotificationEvent;
    fOnTimer: TNotificationEvent;
  protected
    aTimer: NSTimer;
  public
    // Delegate methods (must be cdecl)
    procedure applicationDidFinishLaunching(Notification: NSNotification); cdecl;
    function applicationShouldTerminate(Notification: NSNotification): NSInteger; cdecl;
    procedure applicationWillTerminate(Notification: NSNotification); cdecl;
    procedure applicationWillFinishLaunching(notification: Pointer); cdecl;
    function applicationDockMenu(sender: NSApplication): NSMenu; cdecl;
    function applicationShouldTerminateAfterLastWindowClosed(sender: pointer): NSInteger; cdecl;
    procedure applicationDidHide(Notification: NSNotification); cdecl;
    procedure applicationDidUnhide(Notification: NSNotification); cdecl;

    // Action methods (must be cdecl)
    procedure accumulateFires(theTimer: NSTimer); cdecl;

    // Constructor and destructor
    constructor Create( OnInitialize: TNotificationEvent; OnTimer: TNotificationEvent ); reintroduce;
    destructor Destroy; override;
  end;

{$endif}
implementation
{$ifdef OSX}

procedure TAppDelegate.accumulateFires(theTimer: NSTimer);
begin
  if assigned(fOnTimer) then begin
    fOnTimer;
  end;
end;

procedure TAppDelegate.applicationDidFinishLaunching(Notification: NSNotification); cdecl;
begin
  if assigned(fOnInitialize) then begin
    fOnInitialize;
  end;
  aTimer := TNSTimer.Wrap(
    TNSTimer.OCClass.scheduledTimerWithTimeInterval(
      0.001, Self.GetObjectID, sel_getUid('accumulateFires:'), nil, True));
end;

procedure TAppDelegate.applicationDidHide(Notification: NSNotification);
begin

end;

procedure TAppDelegate.applicationDidUnhide(Notification: NSNotification);
begin

end;

function TAppDelegate.applicationDockMenu(sender: NSApplication): NSMenu;
begin

end;

function TAppDelegate.applicationShouldTerminate(Notification: NSNotification): NSInteger; cdecl;
begin
  Result := YES;
end;

function TAppDelegate.applicationShouldTerminateAfterLastWindowClosed(sender: pointer): NSInteger;
begin
  Result := YES;
end;

procedure TAppDelegate.applicationWillFinishLaunching(notification: Pointer);
begin

end;

procedure TAppDelegate.applicationWillTerminate(Notification: NSNotification); cdecl;
begin
end;

constructor TAppDelegate.Create( OnInitialize: TNotificationEvent; OnTimer: TNotificationEvent );
begin
  inherited Create;
  fOnInitialize := OnInitialize;
  fOnTimer := OnTimer;
end;

destructor TAppDelegate.Destroy;
begin
  inherited Destroy;
end;

var
  AppKitModule: HModule;

initialization
  AppKitModule := LoadLibrary('/System/Library/Frameworks/AppKit.framework/AppKit');

finalization
  FreeLibrary(AppKitModule);

{$endif}
end.


