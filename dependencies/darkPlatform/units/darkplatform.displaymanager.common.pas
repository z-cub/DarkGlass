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
unit darkplatform.displaymanager.common;

interface
uses
  darkcollections.types,
  darkplatform.display,
  darkplatform.displaymanager;

type
  TCommonDisplayManager = class( TInterfacedObject, IDisplayManager )
  private
    fDisplays: ICollection;
  protected //- IDisplayManager -//
    function getCount: uint32;
    function getDisplay( idx: uint32 ): IDisplay;
  protected //- Call from override -//
    function AddDisplay( aDisplay: IDisplay ): IDisplay;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  darkcollections.list;

type
  IDisplayList = {$ifdef fpc} specialize {$endif} IList<IDisplay>;
  TDisplayList = {$ifdef fpc} specialize {$endif} TList<IDisplay>;

{ TCommonDisplayManager }

function TCommonDisplayManager.AddDisplay(aDisplay: IDisplay): IDisplay;
begin
  IDisplayList(fDisplays).Add(aDisplay);
  Result := aDisplay;
end;

constructor TCommonDisplayManager.Create;
begin
  inherited Create;
  fDisplays := TDisplayList.Create(6,false,true);
end;

destructor TCommonDisplayManager.Destroy;
begin
  fDisplays := nil;
  inherited Destroy;
end;

function TCommonDisplayManager.getCount: uint32;
begin
  Result := IDisplayList(fDisplays).Count;
end;

function TCommonDisplayManager.getDisplay(idx: uint32): IDisplay;
begin
  Result := IDisplayList(fDisplays).Items[idx];
end;

end.
