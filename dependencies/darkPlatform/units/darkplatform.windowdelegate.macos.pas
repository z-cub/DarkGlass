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
unit darkplatform.windowdelegate.macos;
{$M+}
interface
{$ifdef MACOS} {$ifndef IOS} {$define OSX} {$endif} {$endif}
{$ifdef OSX}
uses
  Macapi.AppKit,
  Macapi.ObjectiveC,
  Macapi.Foundation,
  Macapi.CocoaTypes,
  System.TypInfo;

type
 WindowDelegate = interface(IObjectiveC)
    ['{9911085C-441D-4C43-A917-43D2A88FC0F0}']
    procedure windowWillClose(Notification: NSNotification); cdecl;
    function windowShouldClose(Sender: Pointer {id}): Boolean; cdecl;
    procedure windowDidBecomeKey(notification: NSNotification); cdecl;
    procedure windowDidResignKey(notification: NSNotification); cdecl;
    procedure windowDidResize(notification: NSNotification); cdecl;
    procedure windowDidMove(notification: NSNotification); cdecl;
    procedure windowDidMiniaturize(notification: NSNotification); cdecl;
    procedure windowDidDeminiaturize(notification: NSNotification); cdecl;
    procedure windowDidEnterFullScreen(notification: NSNotification); cdecl;
    procedure windowDidExitFullScreen(notification: NSNotification); cdecl;
    procedure windowDidChangeBackingProperties(notification: NSNotification); cdecl;
  end;

  TWindowNotification = procedure() of object;
  TWindowQuery = function: boolean of object;

  TWindowDelegate = class(TOCLocal, WindowDelegate)
  private
    fHandleWillClose: TWindowNotification;
    fHandleShouldClose: TWindowQuery;
    fHandleDidBecomeKey: TWindowNotification;
    fHandleDidResignKey: TWindowNotification;
    fHandleDidResize: TWindowNotification;
    fHandleDidMove: TWindowNotification;
    fHandleDidMiniaturize: TWindowNotification;
    fHandleDidDeminiaturize: TWindowNotification;
    fHandleDidEnterFullScreen: TWindowNotification;
    fHandleDidExitFullScreen: TWindowNotification;
    fHandleDidChangeBackingProperties: TWindowNotification;

  public
    procedure windowWillClose(Notification: NSNotification); cdecl;
    function windowShouldClose(Sender: Pointer {id}): Boolean; cdecl;
    procedure windowDidBecomeKey(notification: NSNotification); cdecl;
    procedure windowDidResignKey(notification: NSNotification); cdecl;
    procedure windowDidResize(notification: NSNotification); cdecl;
    procedure windowDidMove(notification: NSNotification); cdecl;
    procedure windowDidMiniaturize(notification: NSNotification); cdecl;
    procedure windowDidDeminiaturize(notification: NSNotification); cdecl;
    procedure windowDidEnterFullScreen(notification: NSNotification); cdecl;
    procedure windowDidExitFullScreen(notification: NSNotification); cdecl;
    procedure windowDidChangeBackingProperties(notification: NSNotification); cdecl;
  public

    constructor Create( HandleShouldClose: TWindowQuery; HandleWillClose, HandleDidBecomeKey, HandleDidResignKey, HandleDidResize, HandleDidMove, HandleDidMiniaturize, HandleDidDeminiaturize, HandleDidEnterFullScreen, HandleDidExitFullScreen, HandleDidChangeBackingProperties: TWindowNotification ); reintroduce;
  end;

{$endif}
implementation
{$ifdef OSX}

{ TWindowDelegate }

constructor TWindowDelegate.Create(HandleShouldClose: TWindowQuery; HandleWillClose, HandleDidBecomeKey, HandleDidResignKey, HandleDidResize, HandleDidMove, HandleDidMiniaturize, HandleDidDeminiaturize, HandleDidEnterFullScreen, HandleDidExitFullScreen, HandleDidChangeBackingProperties: TWindowNotification);
begin
  inherited Create;
  fHandleShouldClose := HandleShouldClose;
  fHandleWillClose := HandleWillClose;
  fHandleDidBecomeKey := HandleDidBecomeKey;
  fHandleDidResignKey := HandleDidResignKey;
  fHandleDidResize := HandleDidResize;
  fHandleDidMove := HandleDidMove;
  fHandleDidMiniaturize := HandleDidMiniaturize;
  fHandleDidDeminiaturize := HandleDidDeminiaturize;
  fHandleDidEnterFullScreen := HandleDidEnterFullScreen;
  fHandleDidExitFullScreen := HandleDidExitFullScreen;
  fHandleDidChangeBackingProperties := HandleDidChangeBackingProperties;
end;

procedure TWindowDelegate.windowDidBecomeKey(notification: NSNotification); cdecl;
begin
  if assigned(fHandleDidBecomeKey) then begin
    fHandleDidBecomeKey();
  end;
end;

procedure TWindowDelegate.windowDidChangeBackingProperties(notification: NSNotification); cdecl;
begin
  if assigned(fHandleDidChangeBackingProperties) then begin
    fHandleDidChangeBackingProperties();
  end;
end;

procedure TWindowDelegate.windowDidDeminiaturize(notification: NSNotification); cdecl;
begin
  if assigned(fHandleDidDeminiaturize) then begin
    fHandleDidDeminiaturize();
  end;
end;

procedure TWindowDelegate.windowDidEnterFullScreen(notification: NSNotification); cdecl;
begin
  if assigned(fHandleDidEnterFullScreen) then begin
    fHandleDidEnterFullScreen();
  end;
end;

procedure TWindowDelegate.windowDidExitFullScreen(notification: NSNotification); cdecl;
begin
  if assigned(fHandleDidExitFullscreen) then begin
    fHandleDidExitFullscreen();
  end;
end;

procedure TWindowDelegate.windowDidMiniaturize(notification: NSNotification); cdecl;
begin
  if assigned(fHandleDidMiniaturize) then begin
    fHandleDidMiniaturize();
  end;
end;

procedure TWindowDelegate.windowDidMove(notification: NSNotification); cdecl;
begin
  if assigned(fHandleDidMove) then begin
    fHandleDidMove();
  end;
end;

procedure TWindowDelegate.windowDidResignKey(notification: NSNotification); cdecl;
begin
  if assigned(fHandleDidResignKey) then begin
    fHandleDidResignKey();
  end;
end;

procedure TWindowDelegate.windowDidResize(notification: NSNotification); cdecl;
begin
  if assigned(fHandleDidResize) then begin
    fHandleDidResize();
  end;
end;

function TWindowDelegate.windowShouldClose(Sender: Pointer): Boolean; cdecl;
begin
  if assigned(fHandleShouldClose) then begin
    Result := fHandleShouldClose();
  end;
end;

procedure TWindowDelegate.windowWillClose(Notification: NSNotification); cdecl;
begin
  if assigned(fHandleWillClose) then begin
    fHandleWillClose();
  end;
end;

{$endif}
end.

