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
unit darkgraphics.context;

interface

type
  TGraphicsAPI = (
    gaVulkan,
    gaOpenGL,
    gaOpenGLES,
    gaDirectX
  );

  TRGBA = record
    r: uint8;
    g: uint8;
    b: uint8;
    a: uint8;
  end;

type
  IGraphicsContext = interface
    ['{429E7898-EAB1-4C5E-9262-3CCF163FAE51}']

    procedure setClearColor( Color: TRGBA );
    procedure Clear;
  end;

type
  ///  <summary>
  ///    Represents a factory class for creating graphics contexts.
  ///  </summary>
  TGraphicsContext = class( TInterfacedObject )
  public
    class function Create( OSWindowHandle: pointer; API: TGraphicsAPI; MinVersionMajor: uint32; MinVersionMinor: uint32 ): IGraphicsContext;
  end;

implementation
uses
  darkgraphics.context.dummy;

{ TGraphicsContext }

class function TGraphicsContext.Create( OSWindowHandle: pointer; API: TGraphicsAPI; MinVersionMajor, MinVersionMinor: uint32 ): IGraphicsContext;
begin
  Result := TDummyGraphicsContext.Create( OSWindowHandle );
end;

end.
