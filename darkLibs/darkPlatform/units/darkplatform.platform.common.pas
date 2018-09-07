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
unit darkplatform.platform.common;

interface
uses
  darkplatform.displaymanager,
  darkplatform.windowmanager,
  darkplatform.platform;

type
  ///  <summary>
  ///    Provides common base-class functionality for implementations of
  ///    IPlatform.
  ///  </summary>
  TCommonPlatform = class( TInterfacedObject, IPlatform )
  private
    fFirstRun: boolean;
    fDisplayManager: IDisplayManager;
    fWindowManager: IWindowManager;
  private //- IPlatform -//
    procedure Run;
  protected //- IPlatform -//
    function getDisplayManager: IDisplayManager;
    function getWindowManager: IWindowManager;
  protected //- Override me! -//
    procedure doRun; virtual; abstract;
    function doCreateWindowManager: IWindowManager; virtual; abstract;
    function doCreateDisplayManager: IDisplayManager; virtual; abstract;
  protected //- Call from descendent as required. -//
  public
    constructor Create; reintroduce;
    destructor Destroy; override;

  end;

implementation

{ TCommonPlatform }

constructor TCommonPlatform.Create;
begin
  inherited Create;
  fFirstRun := false;
  fDisplayManager := nil;
  fWindowManager := nil;
end;

destructor TCommonPlatform.Destroy;
begin
  fDisplayManager := nil;
  fWindowManager := nil;
  inherited Destroy;
end;

function TCommonPlatform.getDisplayManager: IDisplayManager;
begin
  if not assigned(fDisplayManager) then begin
    fDisplayManager := doCreateDisplayManager;
  end;
  Result := fDisplayManager;
end;

function TCommonPlatform.getWindowManager: IWindowManager;
begin
  if not assigned(fWindowManager) then begin
    fWindowManager := doCreateWindowManager;
  end;
  Result := fWindowManager;
end;

procedure TCommonPlatform.Run;
begin
  doRun;
end;

end.
