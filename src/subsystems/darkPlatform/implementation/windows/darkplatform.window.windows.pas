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
unit darkplatform.window.windows;

interface
{$ifdef MSWINDOWS}
uses
  darkwin32api.types,
  darkwin32api.user32,
  darkplatform.display,
  darkplatform.window;

type
  TWindow = class( TInterfacedObject, IWindow )
  private
    fHandle: Thwnd;
    fDisplay: IDisplay;
  private
    procedure CreateWindow(aTitle: pWideChar; aTop, aLeft, aWidth, aHeight: int32; aFullscreen: boolean);
  protected
    function getOSHandle: pointer;
    function HandleWindowMessage( uMsg: uint32; wParam: TWParam; lParam: TLParam ): NativeUInt;
  public
    constructor Create( aDisplay: IDisplay ); reintroduce;
    destructor Destroy; override;
  end;

{$endif}
implementation
{$ifdef MSWINDOWS}
uses
  darkwin32api.constants,
  darkGraphics.context,
  Classes,
  sysutils;

const
  cDarkGlassClass = 'darkGlass';

var
  WindowList: TList;

constructor TWindow.Create( aDisplay: IDisplay );
begin
  inherited Create;
  fHandle := Thwnd(nil);
  fDisplay := aDisplay;
  WindowList.Add(Self);
  CreateWindow( 'Darkglass test',0,0,200,200,FALSE );
end;

destructor TWindow.Destroy;
begin
  WindowList.Remove(Self);
  DestroyWindow(fHandle);
  inherited Destroy;
end;

function TWindow.getOSHandle: pointer;
begin
  result := pointer(fHandle);
end;

procedure TWindow.CreateWindow( aTitle: pWideChar; aTop, aLeft, aWidth, aHeight: int32; aFullscreen: boolean );
var
  StyleEx: uint32;
begin
  //- Set window style.
  if aFullscreen then begin
    StyleEx := WS_POPUPWINDOW;
    //    fDisplay.SetResolution(aWidth,aHeight); //- change display mode!
  end else begin
    StyleEx := WS_CLIPSIBLINGS or WS_CLIPCHILDREN or WS_OVERLAPPEDWINDOW;
  end;
  //- Call OS to create window
  fHandle := CreateWindowExW( WS_EX_APPWINDOW, cDarkGlassClass, aTitle, StyleEx, aLeft, aTop, aWidth, aHeight, 0, 0, system.MainInstance, nil );
  UpdateWindow(fHandle);
  ShowWindow(fHandle, SW_SHOW);
end;

function TWindow.HandleWindowMessage( uMsg: uint32; wParam: TWParam; lParam: TLParam ): NativeUInt;
var
  Temp: IGraphicsContext;
begin
  case uMsg of

    WM_PAINT: begin
      Temp := TGraphicsContext.Create(pointer(fHandle),TGraphicsAPI.gaVulkan,0,0);
      Temp.Clear;
      Temp := nil;
      Result := 0;
      exit;
    end;

    WM_CLOSE: begin
      SendMessage(System.MainInstance,WM_DESTROY,0,0);
      Result := 0;
    end;

    else begin
      Result := DefWindowProc(fHandle, uMsg, wParam, lParam);
    end;

  end;
end;

function WindowProc( Handle: THWND; uMsg: uint32; wParam: TWParam; lParam: TLParam ): TLResult; stdcall;
var
  idx: uint32;
begin
  if WindowList.Count=0 then begin
    Result := DefWindowProc(Handle, uMsg, wParam, lParam);
    exit;
  end;
  for idx := 0 to pred(WindowList.Count) do begin
    if TWindow(WindowList.Items[idx]).getOSHandle=pointer(Handle) then begin
      Result := TWindow(WindowList.Items[idx]).HandleWindowMessage( uMsg, wParam, lParam );
      Exit;
    end;
  end;
  Result := DefWindowProc(Handle, uMsg, wParam, lParam);
end;

procedure CreateWindowClass;
var
  WndClass: TWndClassW;
begin
  WndClass.style := CS_HREDRAW or CS_VREDRAW or CS_OWNDC;
  WndClass.lpfnWndProc := @WindowProc;
  WndClass.cbClsExtra := 0;
  WndClass.cbWndExtra := 0;
  WndClass.hInstance := System.MainInstance;
  WndClass.hIcon := LoadIconW(0,TMakeIntResource(IDI_APPLICATION));
  WndClass.hCursor := LoadCursorW(0,TMakeIntResource(IDC_ARROW));
  WndClass.hbrBackground := 0;
  WndClass.lpszMenuName := nil;
  WndClass.lpszClassName := cDarkGlassClass;
  if RegisterClassW(WndClass)=0 then begin
    raise
      Exception.Create('Failed to register darkglass window class.');
  end;
end;

procedure DestroyWindowClass;
begin
  darkwin32api.user32.UnregisterClass(cDarkGlassClass,system.MainInstance);
end;

initialization
  CreateWindowClass;
  WindowList := TList.Create;

finalization
  {$ifdef fpc}
  WindowList.Free;
  {$else}
  WindowList.DisposeOf;
  {$endif}
  DestroyWindowClass;

{$endif}
end.
