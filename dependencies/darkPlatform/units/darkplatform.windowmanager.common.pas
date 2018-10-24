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
unit darkplatform.windowmanager.common;

interface
uses
  darkcollections.types,
  darkplatform.display,
  darkplatform.window,
  darkplatform.windowmanager;

type
  TCommonWindowManager = class( TInterfacedObject, IWindowManager )
  private
    fWindows: ICollection;
  protected //- IWindowManager -//
    function getCount: uint32;
    function getWindow( idx: uint32 ): IWindow;
  protected //- IWindowManager, override-me -//
    function CreateWindow( Display: IDisplay ): IWindow; virtual; abstract;
  protected
    function AddWindow( aWindow: IWindow ): IWindow;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  darkcollections.list;

type
  IWindowList = {$ifdef fpc} specialize {$endif} IList<IWindow>;
  TWindowList = {$ifdef fpc} specialize {$endif} TList<IWindow>;


{ TCommonWindowManager }

function TCommonWindowManager.AddWindow(aWindow: IWindow): IWindow;
begin
  IWindowList(fWindows).Add(aWindow);
  Result := aWindow;
end;

constructor TCommonWindowManager.Create;
begin
  inherited Create;
  fWindows := TWindowList.Create(4,False,True);
end;

destructor TCommonWindowManager.Destroy;
begin
  fWindows := nil;
  inherited Destroy;
end;

function TCommonWindowManager.getCount: uint32;
begin
  Result := IWindowList(fWindows).Count;
end;

function TCommonWindowManager.getWindow(idx: uint32): IWindow;
begin
  Result := IWindowList(fWindows).Items[idx];
end;

end.

