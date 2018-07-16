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
unit darkplatform.window.ios;

interface
{$ifdef IOS}
uses
  iOSapi.QuartzCore,
  iOSapi.UIKit,
  iOSapi.CoreGraphics,
  darkplatform.display,
  darkplatform.window;

type
  TWindow = class( TInterfacedObject, IWindow )
  private
    fDisplay: IDisplay;
    fHandle: UIWindow;
  private //- IWindow -//
    function getOSHandle: pointer;
  public
    constructor Create( Display: IDisplay ); reintroduce;
    destructor Destroy; override;
  end;

{$endif}
implementation
{$ifdef IOS}
uses
  Macapi.ObjCRuntime,
  iOSapi.CocoaTypes,
  iOSapi.Foundation;

{ TWindow }

constructor TWindow.Create( Display: IDisplay );
var
  bounds : NSRect;
begin
  inherited Create;
  fDisplay := Display;
  // Get screen bounds.
  bounds := TUIScreen.Wrap(TUIScreen.OCClass.mainScreen).bounds;
  // Create window & Store global reference as app main window.
  fHandle := TUIWindow.Wrap(TUIWindow.alloc.initWithFrame( bounds ));
  // Set opacity and background color
  fHandle.setOpaque(true);
  fHandle.setBackgroundColor ( TUIColor.Wrap( TUIColor.OCClass.whiteColor) );
end;

destructor TWindow.Destroy;
begin
  fDisplay := nil;
  inherited Destroy;
end;

function TWindow.getOSHandle: pointer;
begin
  Result  := fHandle;
end;

{$endif}
end.
