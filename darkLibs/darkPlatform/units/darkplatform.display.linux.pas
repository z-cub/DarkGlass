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
unit darkplatform.display.linux;

interface
{$ifdef LINUX}
uses
  darkXLib.xlib,
  darkplatform.display;

type
  TDisplay = class( TInterfacedObject, IDisplay )
  private
    fWidth: int32;
    fHeight: int32;
    fDefault: boolean;
    fDisplayServer: Display;
    fScreenNumber: int32;
    fScreen: pScreen;
    fName: string;
  private //- IDisplay -//
    function getName: string;
    function getOSHandle: pointer;
    function getOSID: pointer;
  public
    constructor Create( DisplayServer: Display; ScreenNumber: int32 ); reintroduce;
    destructor Destroy; override;
  end;

{$endif}
implementation
{$ifdef LINUX}
uses
  sysutils;

{ TDisplay }

constructor TDisplay.Create( DisplayServer: Display; ScreenNumber: int32 );
begin
  inherited Create;
  fDisplayServer := DisplayServer;
  fScreenNumber := ScreenNumber;
  fScreen := XScreenOfDisplay(fDisplayServer,fScreenNumber);
  //- Is this the default display (screen)?
  if XDefaultScreenOfDisplay(fDisplayServer)=fScreen then begin
    fDefault := True;
  end else begin
    fDefault := False;
  end;
  //- Get the name of the display (screen).
  case fScreenNumber of
   0: fName := 'primary';
   1: fName := 'secondary';
   2: fName := 'tertiary';
   3: fName := 'quaternary';
   4: fName := 'quinary';
   5: fName := 'senary';
   6: fName := 'septenary';
   7: fName := 'octonary';
   8: fName := 'nonary';
   9: fName := 'denary';
   10: fName := 'eleventh';
   11: fName := 'duodenary';
   else begin
     fName := IntToStr(ScreenNumber);
   end;
  end;
  //- Get the screen dimensions
  fWidth := XDisplayWidth( DisplayServer, ScreenNumber );
  fHeight := XDisplayHeight( DisplayServer, ScreenNumber );
end;

destructor TDisplay.Destroy;
begin
  inherited Destroy;
end;

function TDisplay.getName: string;
begin
  Result := fName;
end;

function TDisplay.getOSHandle: pointer;
begin
  Result := @fDisplayServer;
end;

function TDisplay.getOSID: pointer;
begin
  Result := @fScreenNumber;
end;

{$endif}
end.
