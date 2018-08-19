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
unit darkgraphics.context.dummy;
//------------------------------------------------------------------------------
//- Dummy context using Win32 gdi instructions to paint the window!
//- This will be removed as real contexts are added to take it's place.
//------------------------------------------------------------------------------

interface
uses
  Windows,
  darkgraphics.context;

type
  TDummyGraphicsContext = class( TInterfacedObject, IGraphicsContext )
  private
    fWindowHandle: hwnd;
    fClearColor: TRGBA;
  private
    procedure setClearColor( Color: TRGBA );
    procedure Clear;
  public
    constructor Create( OSWindow: pointer ); reintroduce;
    destructor Destroy; override;
  end;

implementation

{ TDummyGraphicsContext }

procedure TDummyGraphicsContext.Clear;
var
  ahdc: hdc;
  apaintStruct: PaintStruct;
  aBrush: HBrush;
begin
  aBrush := CreateSolidBrush(RGB(fClearColor.r,fClearColor.g,fClearColor.b));
  try
    ahdc := BeginPaint(fWindowHandle,apaintStruct);
    try
      FillRect(ahdc,apaintStruct.rcPaint,aBrush);
    finally
      EndPaint(fWindowHandle,apaintStruct);
    end;
  finally
    DeleteObject(aBrush);
  end;
end;

constructor TDummyGraphicsContext.Create(OSWindow: pointer);
begin
  inherited Create;
  fWindowHandle := hwnd(OSWindow);
  fClearColor.r := 255;
  fClearColor.g := 0;
  fClearColor.b := 0;
  fClearColor.a := 255;
end;

destructor TDummyGraphicsContext.Destroy;
begin
  inherited Destroy;
end;

procedure TDummyGraphicsContext.setClearColor(Color: TRGBA);
begin
  fClearColor.r := Color.r;
  fClearColor.g := Color.g;
  fClearColor.b := Color.b;
  fClearColor.a := Color.a;
end;

end.
