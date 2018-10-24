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
unit darkplatform.window.linux;

interface
{$ifdef linux}
uses
  darkXLib.x,
  darkXLib.xlib,
  darkplatform.display,
  darkplatform.window;

type
  TWindow = class( TInterfacedObject, IWindow )
  private
    fAtom: Atom;
    fDisplayServer: Display;
    fScreenNumber: int32;
    fDisplay: IDisplay;
    fHandle: Window;
  private //- IWindow -//
    procedure CreateWindow;
    function getOSHandle: pointer;
  public
    constructor Create( aDisplay: IDisplay ); reintroduce;
    destructor Destroy; override;
  end;

{$endif}
implementation
{$ifdef linux}
uses
  sysutils;

{ TWindow }

constructor TWindow.Create( aDisplay: IDisplay );
begin
  inherited Create;
  fDisplay := aDisplay;
  fDisplayServer := Display((fDisplay.getOSHandle)^);
  fScreenNumber := int32((fDisplay.getOSID)^);
  CreateWindow;
end;

destructor TWindow.Destroy;
begin

  inherited Destroy;
end;

const
  cWM_DELETE_WINDOW {$ifdef fpc}: pansichar {$endif} = 'WM_DELETE_WINDOW';
  cDarkglass {$ifdef fpc}: pansichar {$endif} = 'Darkglass!';

procedure TWindow.CreateWindow;
var
  _visual: Visual;
  Attributes: XSetWindowAttributes;
  Depth: int32;
begin
  _visual := DefaultVisual(fDisplayServer,fScreenNumber);
  Depth := DefaultDepth(fDisplayServer,fScreenNumber);
	Attributes.background_pixel := XWhitePixel(fDisplayServer,fScreenNumber);

  fHandle := XCreateWindow(
      fDisplayServer,
      XRootWindow(fDisplayServer,fScreenNumber),
      0,0,400,400,
      5,
      Depth,
      InputOutput,
      _visual,
      CWBackPixel,
      @Attributes);

  case fHandle of
	    BadAlloc: raise Exception.Create('Bad Alloc');
      BadColor: raise Exception.Create('Bad Color');
     BadCursor: raise Exception.Create('Bad Cursor');
      BadMatch: raise Exception.Create('Bad Match');
     BadPixmap: raise Exception.Create('Bad Pixmap');
      BadValue: raise Exception.Create('Bad Value');
     BadWindow: raise Exception.Create('Bad Window');
  end;

  XSelectInput( fDisplayServer, fHandle, ExposureMask or KeyPressMask or StructureNotifyMask );
  {$ifdef fpc}
  fAtom := XInternAtom( DisplayServer, @cWM_DELETE_WINDOW, xFalse);
  {$else}
  fAtom := XInternAtom( fDisplayServer, Pointer(MarshaledAString(UTF8Encode(cWM_DELETE_WINDOW))), xFalse);
  {$endif}
  XSetWMProtocols( fDisplayServer, fHandle, @fAtom, 1);
  {$ifdef fpc}
  XStoreName( fDisplayServer, fHandle, @cDarkglass );
  {$else}
  XStoreName( fDisplayServer, fHandle, Pointer(MarshaledAString(UTF8Encode(cDarkglass))));
  {$endif}

  if (XMapWindow(fDisplayServer,fHandle)=BadWindow) then begin
    raise Exception.Create('Bad Window');
  end;
end;

function TWindow.getOSHandle: pointer;
begin
  Result := pointer(fHandle);
end;

{$endif}
end.
