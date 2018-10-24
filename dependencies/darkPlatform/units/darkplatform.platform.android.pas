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
unit darkplatform.platform.android;

interface
{$ifdef ANDROID}
uses
  AndroidAPI.Input,
  darkplatform.appglue.android,
  darkplatform.platform,
  darkplatform.displaymanager,
  darkplatform.windowmanager,
  darkplatform.platform.common;

type
  TPlatform = class( TCommonPlatform, IPlatform )
  private
    fApp: pandroid_app;
  protected
    procedure DoApplicationCommand(app: pandroid_app; cmd: int32);
    function DoInputEvent(app: pandroid_app; Event: PAInputEvent ): int32;
  protected //- Overrides of base class -//
    procedure doRun; override;
    function doCreateWindowManager: IWindowManager; override;
    function doCreateDisplayManager: IDisplayManager; override;
  public
    constructor Create; reintroduce;
  end;

{$endif}
implementation
{$ifdef ANDROID}
uses
  AndroidAPI.Looper,
  AndroidAPI.NativeActivity,
  darkplatform.displaymanager.android,
  darkplatform.windowmanager.android,
  darkplatform.window.android;

var
  PlatformRef: TPlatform = nil;

procedure onAppCmd(app: pandroid_app; cmd: Integer); cdecl;
begin
  PlatformRef.DoApplicationCommand(app,cmd);
end;

function onInputEvent(App: PAndroid_app; Event: PAInputEvent): Int32; cdecl;
begin
  Result := PlatformRef.DoInputEvent(app,event);
end;

procedure TPlatform.doRun;
var
  ident : Integer;
  events: Integer;
  source: pandroid_poll_source;
begin
  ident := ALooper_pollAll(1, nil, @events, @source);
  if (ident >= 0) and (source <> nil) then begin
    source.process(fApp, source);
  end;
  doApplicationCommand( fApp, APP_CMD_WINDOW_REDRAW_NEEDED );
end;

function TPlatform.doCreateWindowManager: IWindowManager;
begin
  Result := TWindowManager.Create;
end;

constructor TPlatform.Create;
begin
  inherited Create;
  PlatformRef := Self;
  fApp := PANativeActivity(System.DelphiActivity)^.instance;
  fApp.userData := Self;
  fApp.onAppCmd := OnAppCmd;
  fApp.onInputEvent := onInputEvent;
end;

function TPlatform.doCreateDisplayManager: IDisplayManager;
begin
  Result := TDisplayManager.Create;
end;

function TPlatform.DoInputEvent(app: pandroid_app; Event: PAInputEvent): int32;
begin
  exit;
end;

procedure TPlatform.DoApplicationCommand(app: pandroid_app; cmd: int32);
begin
  if cmd=APP_CMD_INIT_WINDOW then begin
  end;
  if cmd=APP_CMD_WINDOW_REDRAW_NEEDED then begin
  end;
end;


initialization

finalization
  PlatformRef := nil;
{$endif}
end.
