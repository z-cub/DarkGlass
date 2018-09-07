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
unit darkglass.platform.subsystem;

interface
uses
  darkThreading;

type
  TPlatformSubSystem = class( TInterfacedObject, IThreadSubSystem )
  private
    fShutdown: boolean;
    fMessageChannel: IMessageChannel;
  private //- IThreadSubSystem -//
    function MainThread: boolean;
    function Dedicated: boolean;
    function Install( MessageBus: IMessageBus ): boolean;
    function Initialize( MessageBus: IMessageBus ): boolean;
    function Execute: boolean;
    procedure Finalize;
  private //- Message handling -//
    function HandleMessage(aMessage: TMessage): nativeuint;
    function doCreateWindow(aMessage: TMessage): nativeuint;
  public
    constructor Create; reintroduce;
  end;

implementation
uses
  darkHandles,
  darkPlatform,
  darkglass.platform.messages;

{ TPlatformSubSystem }

constructor TPlatformSubSystem.Create;
begin
  inherited Create;
  fShutdown := False;
  fMessageChannel := nil;
end;

function TPlatformSubSystem.Dedicated: boolean;
begin
  Result := False; //- Main loop lives on same thread -//
end;

function TPlatformSubSystem.doCreateWindow( aMessage: TMessage ): nativeuint;
var
  AWindow: IWindow;
begin
  AWindow := Platform.WindowManager.CreateWindow(Platform.DisplayManager.Displays[0]);
  Result := darkHandles.THandles.CreateHandle(AWindow);
end;

function TPlatformSubSystem.HandleMessage(aMessage: TMessage): nativeuint;
begin
  Result := 0;
  case aMessage.Value of
    MSG_PLATFORM_CREATE_WINDOW: Result := doCreateWindow( aMessage );
  end;
end;

function TPlatformSubSystem.Execute: boolean;
begin
  //- Check for shutdown condition.
  Result := False;
  if fShutdown then begin
    exit;
  end;
  //- Check for messages to platform
  while fMessageChannel.MessagesWaiting do begin
    fMessageChannel.GetMessage(HandleMessage);
  end;
  //
  Platform.Run;
  //- All done here
  Result := True;
end;

procedure TPlatformSubSystem.Finalize;
begin
  //- Nothing to see here.
end;

function TPlatformSubSystem.Initialize(MessageBus: IMessageBus): boolean;
begin
  Result := True;
end;

function TPlatformSubSystem.Install(MessageBus: IMessageBus): boolean;
begin
  Result := False;
  fMessageChannel := MessageBus.CreateChannel('platform');
  if not assigned(fMessageChannel) then begin
    exit;
  end;
  Result := True;
end;

function TPlatformSubSystem.MainThread: boolean;
begin
  Result := True; //- We should be on the main (UI) thread -//
end;

end.
