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
unit darkplatform.platform.ios;

interface
{$ifdef IOS}
uses
  Macapi.ObjectiveC,
  Macapi.ObjCRuntime,
  iOSapi.CocoaTypes,
  iOSapi.Foundation,
  iOSapi.QuartzCore,
  iOSapi.UIKit,
  iOSapi.CoreGraphics,
  darkplatform.platform,
  darkplatform.displaymanager,
  darkplatform.windowmanager,
  darkplatform.platform.common;

type
  TPlatform = class( TCommonPlatform, IPlatform )
  private
    fInitialized: boolean;
    fMainTimer: TObject;
    fPool: NSAutoreleasePool;
  private
    procedure DoTimer;
  protected
    procedure iOSInitialized;
  protected //- Overrides of base class -//
    procedure doRun; override;
    function doCreateWindowManager: IWindowManager; override;
    function doCreateDisplayManager: IDisplayManager; override;
  public
    constructor Create; reintroduce;
    destructor Destroy;
  end;

{$endif}
implementation
{$ifdef IOS}
uses
  Macapi.Helpers,
  darkplatform.displaymanager.ios,
  darkplatform.windowmanager.ios,
  darkplatform.window.ios;

var
  /// This global reference is used during initialization and then set back
  /// to nil.
  GlobalMainLoopReference: TPlatform = nil;

//------------------------------------------------------------------------------
// IOS Application delegate stuff...
//------------------------------------------------------------------------------

type
  UIAppDelegate = interface(IObjectiveC)
    function application_didFinishLaunchingWithOptions(Sender: UIApplication; didFinishLaunchingWithOptions: NSDictionary): Boolean; cdecl; overload;
  end;

  TUIAppDelegate = class(TOCLocal,UIAppDelegate)
  public
    [MethodName('application:didFinishLaunchingWithOptions:')]
    function application_didFinishLaunchingWithOptions(Sender: UIApplication; didFinishLaunchingWithOptions: NSDictionary): Boolean; cdecl;
  end;

  TTimerEvent = procedure of object;

  IMainTimerDelegate = interface( IObjectiveC )
    ['{E7D84192-8507-4757-8D55-A568432A0B83}']
    procedure doTimer( timer: NSTimer ); cdecl;
  end;

  TMainTimerDelegate = class( TOCLocal, IMainTimerDelegate )
  private
    FNSTimer: NSTimer;
    fOnTimer: TTimerEvent;
  public
    constructor Create( OnTimerEvent: TTimerEvent ); reintroduce;
    destructor Destroy; override;
    procedure doTimer( timer: NSTimer ); cdecl;
  end;


function TUIAppDelegate.application_didFinishLaunchingWithOptions(Sender: UIApplication; didFinishLaunchingWithOptions: NSDictionary): Boolean; cdecl;
begin
  Result := False;
  //- Make it visible
  if assigned(GlobalMainLoopReference) then begin
    GlobalMainLoopReference.iOSInitialized;
    Result := True;
  end;
end;

constructor TMainTimerDelegate.Create( OnTimerEvent: TTimerEvent );
var
  Interval: int32;
begin
  inherited Create;
  fOnTimer := OnTimerEvent;
  Interval := 1;
  FNSTimer := TNSTimer.Wrap( TNSTimer.OCClass.scheduledTimerWithTimeInterval( Interval / 1000, Self.GetObjectID, Sel_getUid( 'doTimer:' ), nil, true ) );
end;

destructor TMainTimerDelegate.Destroy;
begin
  if assigned( FNSTimer ) then begin
    FNSTimer.invalidate;
    FNSTimer := nil;
  end;
end;

procedure TMainTimerDelegate.doTimer( timer: NSTimer ); cdecl;
begin
  if assigned(fOnTimer) then begin
    fOnTimer;
  end;
end;
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

constructor TPlatform.Create;
begin
  inherited Create;
  fInitialized := False;
  GlobalMainLoopReference := Self;
  fPool := TNSAutoreleasePool.Create;
  fPool.init;
  TUIAppDelegate.Create;
  fMainTimer := TMainTimerDelegate.Create(DoTimer);
end;

destructor TPlatform.Destroy;
begin
  fPool.release;
  inherited Destroy;
end;

procedure TPlatform.DoTimer;
begin
  if not fInitialized then begin
    exit;
  end;
end;

procedure TPlatform.iOSInitialized;
begin
  fInitialized := True;
  GlobalMainLoopReference := nil;
end;

procedure TPlatform.doRun;
begin
  UIApplicationMain( System.ArgCount, System.ArgValues, nil, (StrToNSStr('TUIAppDelegate') as ILocalObject).GetObjectID  );
end;

function TPlatform.doCreateWindowManager: IWindowManager;
begin
  Result := TWindowManager.Create;
end;

function TPlatform.doCreateDisplayManager: IDisplayManager;
begin
  Result := TDisplayManager.Create;
end;

{$endif}
end.
