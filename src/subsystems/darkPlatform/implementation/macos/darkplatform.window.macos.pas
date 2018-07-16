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
unit darkplatform.window.macos;

interface
{$ifdef MACOS} {$ifndef IOS} {$define OSX} {$endif} {$endif}
{$ifdef OSX}
uses
  Macapi.AppKit,
  Macapi.ObjectiveC,
  Macapi.Foundation,
  Macapi.CocoaTypes,
  darkplatform.windowdelegate.macos,
  darkplatform.display,
  darkplatform.window;

type
  TWindow = class( TInterfacedObject, IWindow )
  private
    fDisplay: IDisplay;
    fHandle: NSWindow;
//    fView: NSView;
    fWindowDelegate: WindowDelegate;
  private //- IWindow -//
    function getOSHandle: pointer;
  private //- Delegate callbacks -//
    procedure HandleWillClose;
    function HandleShouldClose: boolean;
    procedure HandleDidBecomeKey;
    procedure HandleDidResignKey;
    procedure HandleDidResize;
    procedure HandleDidMove;
    procedure HandleDidMiniaturize;
    procedure HandleDidDeminiaturize;
    procedure HandleDidEnterFullScreen;
    procedure HandleDidExitFullScreen;
    procedure HandleDidChangeBackingProperties;
  public
    constructor Create( Display: IDisplay ); reintroduce;
    destructor Destroy; override;
  end;

{$endif}
implementation
{$ifdef OSX}

{ TWindow }

constructor TWindow.Create(Display: IDisplay);
var
  contentSize: NSRect;
begin
  inherited Create;
  fDisplay := Display;
  contentSize := MakeNSRect( 0, 0, 200, 200);
  fHandle := TNSWindow.Wrap(TNSWindow.alloc.initWithContentRect(contentSize, NSTitledWindowMask or NSClosableWindowMask, NSBackingStoreBuffered, True));
  // Create a delegate for the window
  fWindowDelegate := TWindowDelegate.Create( HandleShouldClose, HandleWillClose, HandleDidBecomeKey, HandleDidResignKey, HandleDidResize, HandleDidMove, HandleDidMiniaturize, HandleDidDeminiaturize, HandleDidEnterFullScreen, HandleDidExitFullScreen, HandleDidChangeBackingProperties );
  fHandle.setDelegate(NSWindowDelegate(fWindowDelegate));
  fHandle.setTitle(NSStr('darkglass window'));
//  //- Create an opengl view for the window.
//  fView := TNSView.Wrap(TNSView.Alloc.initWithFrame(contentSize));
//  fHandle.setContentView(fView);
  fHandle.makeKeyAndOrderFront(Self);
end;

destructor TWindow.Destroy;
begin
  fDisplay := nil;
  inherited Destroy;
end;

function TWindow.getOSHandle: pointer;
begin
  Result := fHandle;
end;

procedure TWindow.HandleDidBecomeKey;
begin

end;

procedure TWindow.HandleDidChangeBackingProperties;
begin

end;

procedure TWindow.HandleDidDeminiaturize;
begin

end;

procedure TWindow.HandleDidEnterFullScreen;
begin

end;

procedure TWindow.HandleDidExitFullScreen;
begin

end;

procedure TWindow.HandleDidMiniaturize;
begin

end;

procedure TWindow.HandleDidMove;
begin

end;

procedure TWindow.HandleDidResignKey;
begin

end;

procedure TWindow.HandleDidResize;
begin

end;

function TWindow.HandleShouldClose: boolean;
begin

end;

procedure TWindow.HandleWillClose;
begin

end;

{$endif}
end.
