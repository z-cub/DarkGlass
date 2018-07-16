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
unit darkplatform.external.standard;

interface
uses
  darkThreading;

type
  ///  <summary>
  ///    The callback prototype, used as a callback function for the main
  ///    application while the dark glass engine is running.
  ///  </summary>
  TExternalMessageHandler = function (aMessage: TMessage): nativeuint;

type
  TExternalMessages = class( TInterfacedObject, IThreadSubSystem )
  private
    fExternalChannelName: string;
    fExternalChannel: IMessageChannel;
    fExternalMessageHandler: TExternalMessageHandler;
  private //- IThreadSubSystem -//
    function MainThread: boolean;
    function Dedicated: boolean;
    function Install( MessageBus: IMessageBus ): boolean;
    function Initialize( MessageBus: IMessageBus ): boolean;
    function Execute: boolean;
    procedure Finalize;
  private
    function HandleExternalMessages(aMessage: TMessage): nativeuint;
  public
    constructor Create( ExternalChannelName: string; ExternalMessageHandler: TExternalMessageHandler );
    destructor Destroy; override;
  end;

implementation

{ TExternalMessages }

constructor TExternalMessages.Create( ExternalChannelName: string; ExternalMessageHandler: TExternalMessageHandler);
begin
  inherited Create;
  fExternalChannelName := ExternalChannelName;
  fExternalChannel := nil;
  fExternalMessageHandler := ExternalMessageHandler;
end;

function TExternalMessages.Dedicated: boolean;
begin
  Result := True;
end;

destructor TExternalMessages.Destroy;
begin
  fExternalChannel := nil;
  fExternalMessageHandler := nil;
  inherited Destroy;
end;

function TExternalMessages.Execute: boolean;
begin
  Result := True;
  fExternalChannel.GetMessage(HandleExternalMessages);
end;

procedure TExternalMessages.Finalize;
begin

end;

function TExternalMessages.HandleExternalMessages(aMessage: TMessage): nativeuint;
begin
  Result := 0;
  if not assigned(fExternalMessageHandler) then begin
    exit;
  end;
  Result := fExternalMessageHandler( aMessage );
end;

function TExternalMessages.Initialize(MessageBus: IMessageBus): boolean;
begin
  Result := True;
end;

function TExternalMessages.Install(MessageBus: IMessageBus): boolean;
begin
  Result := False;
  fExternalChannel := MessageBus.CreateChannel(fExternalChannelName);
  if not assigned(fExternalChannel) then begin
    exit;
  end;
  Result := True;
end;

function TExternalMessages.MainThread: boolean;
begin
  Result := False;
end;

end.
