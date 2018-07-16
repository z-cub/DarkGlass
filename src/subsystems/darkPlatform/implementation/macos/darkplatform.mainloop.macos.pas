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
unit darkplatform.mainloop.macos;

interface
{$ifdef MACOS} {$ifndef IOS} {$define OSX} {$endif} {$endif}
{$ifdef OSX}
uses
  Macapi.AppKit,
  Macapi.CoreFoundation,
  Macapi.Foundation,
  Macapi.ObjCRuntime,
  Macapi.CocoaTypes,
  darkthreading,
  darkplatform.applicationdelegate.macos,
  darkplatform.window,
  darkplatform.mainloop.common,
  darkplatform.displaymanager,
  darkplatform.windowmanager;

type
  TMainLoop = class( TCommonMainLoop, IThreadSubSystem )
  private
    fAutoReleasePool: NSAutoReleasePool; //- Auto-release pool for osx objects
    fNSApplication: NSApplication;       //- osx application class
    fApplicationDelegate: AppDelegate;
    procedure DoInitialize;
    procedure DoTimer;
    procedure RedrawWindows;   //- osx application delegate
  protected //- Overrides of TCommonMainLoop -//
    procedure HandleOSMessages; override;
    function CreateDisplayManager: IDisplayManager; override;
    function CreateWindowManager: IWindowManager; override;
    function Execute: boolean; override;
  public
    constructor Create( ExternalChannelName: string ); override;
    destructor Destroy; override;
  end;

{$endif}
implementation
{$ifdef OSX}
uses
  darkplatform.displaymanager.macos,
  darkplatform.windowmanager.macos,
  darkplatform.window.macos;

constructor TMainLoop.Create(ExternalChannelName: string);
begin
  inherited Create(ExternalChannelName);
  fAutoReleasePool := TNSAutoReleasePool.Create;
  fNSApplication := TNSApplication.Wrap(TNSApplication.OCClass.sharedApplication);
  fApplicationDelegate := TAppDelegate.Create(DoInitialize,DoTimer);
  fNSApplication.setDelegate(fApplicationDelegate);
end;

function TMainLoop.CreateDisplayManager: IDisplayManager;
begin
  Result := TDisplayManager.Create;
end;

function TMainLoop.CreateWindowManager: IWindowManager;
begin
  Result := TWindowManager.Create;
end;

destructor TMainLoop.Destroy;
begin
  fAutoReleasePool.drain;
  inherited Destroy;
end;


procedure TMainLoop.HandleOSMessages;
begin
  //- Nothing to see here, macos does not have a central message handler,
  //- but instead uses delegates.
end;

procedure TMainLoop.RedrawWindows;
var
  idx: nativeuint;
  aWindow: IWindow;
//  Message: TOSMessage;
begin
  // Redraw windows
  if fWindowManager.Count=0 then begin
    Exit;
  end;
  for idx := 0 to pred(fWindowManager.count) do begin
    aWindow := fWindowManager.Windows[idx];
    //- MACOS doesn't handle OS messages in the same way as the other
    //- OS's, so we send in a message for the message bus instead.
//    Message.Token := TWindowMessages.MSG_PAINT;
//    aWindow.HandleOSMessage(Message);
  end;
end;

procedure TMainLoop.DoInitialize;
begin
  SendInitializedMessage;
end;

procedure TMainLoop.DoTimer;
begin
  //- Handle messages for the platform.
  CheckMessages;
  // Execute main loop
  RedrawWindows;
end;

function TMainLoop.Execute: boolean;
begin
  //- Send the initialized platform message.
  fNSApplication.Run;
  Result := False;
end;

{$endif}
end.
