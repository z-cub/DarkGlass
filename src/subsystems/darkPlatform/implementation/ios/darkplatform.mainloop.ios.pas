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
unit darkplatform.mainloop.ios;

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
  darkplatform.displaymanager,
  darkplatform.windowmanager,
  darkplatform.mainloop.common;

type
  TMainLoop = class( TCommonMainLoop )
  private
    fInitialized: boolean;
    fMainTimer: TObject;
    fPool: NSAutoreleasePool;
  private
    procedure DoTimer;
  protected
    procedure iOSInitialized;
    function CreateDisplayManager: IDisplayManager; override;
    function CreateWindowManager: IWindowManager; override;
    procedure HandleOSMessages; override;
    function Execute: boolean; override;
  public
    constructor Create( ExternalChannelName: string ); reintroduce;
    destructor Destroy; override;
  end;

{$endif}
implementation
{$ifdef IOS}
uses
  Macapi.Helpers,
  darkplatform.displaymanager.ios,
  darkplatform.windowmanager.ios;

var
  /// This global reference is used during initialization and then set back
  /// to nil.
  GlobalMainLoopReference: TMainLoop = nil;

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

{ TMainLoop }

constructor TMainLoop.Create( ExternalChannelName: string );
begin
  inherited Create(ExternalChannelName);
  fInitialized := False;
  GlobalMainLoopReference := Self;
  fPool := TNSAutoreleasePool.Create;
  fPool.init;
  TUIAppDelegate.Create;
  fMainTimer := TMainTimerDelegate.Create(DoTimer);
end;

function TMainLoop.CreateDisplayManager: IDisplayManager;
begin
  Result := TDisplayManager.Create;
end;

function TMainLoop.CreateWindowManager: IWindowManager;
begin
  Result := TWindowManager.Create;
end;

destructor TMainLoop.Destroy;
begin
  fPool.release;
  inherited Destroy;
end;

procedure TMainLoop.DoTimer;
begin
  if not fInitialized then begin
    exit;
  end;
  CheckMessages;
end;

function TMainLoop.Execute: boolean;
begin
  Result := False;
  UIApplicationMain( System.ArgCount, System.ArgValues, nil, (StrToNSStr('TUIAppDelegate') as ILocalObject).GetObjectID  );
end;

procedure TMainLoop.HandleOSMessages;
begin
  //- Do Nothing, IOS does not have a central message loop, favoring delegates.
end;

procedure TMainLoop.iOSInitialized;
begin
  fInitialized := True;
  GlobalMainLoopReference := nil;
  SendInitializedMessage;
end;

{$endif}
end.
