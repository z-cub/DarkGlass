//------------------------------------------------------------------------------
// This file is part of the DarkGlass game engine project.
// More information can be found here: http://chapmanworld.com/darkglass
//
// DarkGlass is licensed under the MIT License:
//
// Copyright 2018 Craig Chapman
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the �Software�),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED �AS IS�, WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.
//------------------------------------------------------------------------------
unit darkglass.engine;

interface
uses
  darkHandles,
  darkThreading,
  darkPlatform;

const
  cMaxStringLength = 255;

/// <summary>
///   Returns the major part of the library version number. For example, if the
///   version number is 2.5 this function returns 2.
/// </summary>
/// <returns>
///   See description.
/// </returns>
/// <remarks>
///   This function is exposed as an exported symbol from the library.
/// </remarks>
function dgVersionMajor: uint32; {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif} export;

/// <summary>
///   Returns the minor part of the library version number. For example, if the
///   version number is 2.5 this function returns 5.
/// </summary>
/// <returns>
///   See description.
/// </returns>
/// <remarks>
///   This function is exposed as an exported symbol from the library.
/// </remarks>
function dgVersionMinor: uint32; {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif} export;

///  <summary>
///    Initializes the DarkGlass engine.
///    You must call dgInitialize() before calling dgRun()
///  </summary>
procedure dgInitialize; {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif} export;

///  <summary>
///    Finalizes the DarkGlass engine.
///    You must call dgFinalize() after calling dgRun()
///  </summary>
procedure dgFinalize; {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif} export;

///  <summary>
///    This procedure progresses the darkGlass engine's main thread by a single
///    execution cycle. This is useful for integration of the darkGlass
///    sub-systems with an external 'main loop', which is necessary for the
///    darkIDE. Repeatedly call dgProgress for so long as it returns TRUE.
///    When dgProgress returns FALSE, this is an indication that the main
///    thread no longer has work to do and the engine should be shut down.
///    As a convenience, the dgRun() function remains available to continually
///    call dgProgress as an alternative mechanism for executing the main
///    thread.
///  </summary>
function dgProgress: boolean; {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif} export;

/// <summary>
///   This procedure passes execution to the run method of the global IPlatform
///   instance, which subsequently passes execution to the application main
///   loop. This procedure will therefore not return until execution of the
///   application has ended.
/// </summary>
/// <remarks>
///   This function is exposed as an exported symbol from the library.
/// </remarks>
procedure dgRun; {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif} export;

///  <summary>
///    This function returns a handle to a commincation channel, allowing
///    messages to be sent into the communication channel.
///  </summary>
function dgGetMessagePipe( lpszChannelName: pointer ): THandle; {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif} export;

///  <summary>
///    Sends a message into the specified message pipe.
///    This function immediately returns without waiting for a response from
///    the message channel. If the message cannot be sent, this function returns
///    false, else it returns true on successful transmission of the message.
///  </summary>
function dgSendMessage( PipeHandle: THandle; MessageValue, ParamA, ParamB, ParamC, ParamD: nativeuint ): boolean;  {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif} export;

///  <summary>
///    Sends a message into the specified message pipe.
///    This function will wait for a response from the message channel.
///  </summary>
function dgSendMessageWait( PipeHandle: THandle; MessageValue, ParamA, ParamB, ParamC, ParamD: nativeuint ): nativeuint;  {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif} export;

///  <summary>
///    This procedure frees a handle to an object within the system.
///  </summary>
procedure dgFreeHandle( Handle: THandle ); {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif} export;


implementation
uses
  darkIO.buffers,
  darkglass.platform.subsystem,
  sysutils;

const
  cVersionMajor = 1;
  cVersionMinor = 0;

var
  ThreadSystem: IThreadSystem = nil;

function dgVersionMajor: uint32; {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif}
begin
  Result := cVersionMajor;
end;

function dgVersionMinor: uint32; {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif}
begin
  Result := cVersionMinor;
end;

function dgProgress: boolean; {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif}
begin
  Result := False;
  if not assigned(ThreadSystem) then begin
    exit;
  end;
  Result := ThreadSystem.Progress;
end;

procedure dgRun; {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif}
begin
  while dgProgress do;
end;

procedure dgInitialize; {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif}
begin
  ThreadSystem := TThreadSystem.Create;
  ThreadSystem.InstallSubSystem(TPlatformSubSystem.Create);
  ThreadSystem.Start;
end;

procedure dgFinalize; {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif}
begin
  ThreadSystem.Stop;
  ThreadSystem := nil;
end;

function dgGetMessagePipe( lpszChannelName: pointer ): THandle; {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif}
var
  ChannelName: string;
  ChannelNameBuffer: IUnicodeBuffer;
  StrLen: uint32;
  PtrData: ^uint8;
  KeepGoing: boolean;
  Pipe: IMessagePipe;
begin
  Result := THandles.cNullHandle;
  if not assigned(ThreadSystem) then begin
    raise
      Exception.Create('Did you call dgInitialize()?');
    exit;
  end;
  strlen := 0;
  PtrData := lpszChannelName;
  KeepGoing := True;
  while (strlen<cMaxStringLength) and KeepGoing do begin
    if PtrData^=0 then begin
      KeepGoing := False;
      Continue;
    end;
    inc(strLen);
    inc(PtrData);
  end;
  if KeepGoing then begin
    exit;
  end;
  ChannelNameBuffer := TBuffer.Create(0);
  ChannelNameBuffer.AppendData(lpszChannelName,strlen);
  ChannelName := ChannelNameBuffer.ReadString(TUnicodeFormat.utf8);
  Pipe := ThreadSystem.MessageBus.GetMessagePipe(ChannelName);
  if not assigned(Pipe) then begin
    exit;
  end;
  Result := THandles.CreateHandle(Pipe);
end;

procedure dgFreeHandle( Handle: THandle ); {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif}
begin
  THandles.FreeHandle(Handle);
end;

function dgSendMessage( PipeHandle: THandle; MessageValue, ParamA, ParamB, ParamC, ParamD: nativeuint ): boolean;  {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif} export;
begin
  if not assigned(ThreadSystem) then begin
    raise
      Exception.Create('Did you call dgInitialize()?');
    exit;
  end;
  if not THandles.VerifyHandle( PipeHandle, IMessagePipe ) then begin
    raise
      Exception.Create('Invalid handle for message pipe.');
  end;
  Result := (THandles.InstanceOf(PipeHandle) as IMessagePipe).SendMessage( MessageValue, ParamA, ParamB, ParamC, ParamD );
end;

function dgSendMessageWait( PipeHandle: THandle; MessageValue, ParamA, ParamB, ParamC, ParamD: nativeuint ): nativeuint;  {$ifdef MSWINDOWS} stdcall; {$else} cdecl; {$endif} export;
begin
  if not assigned(ThreadSystem) then begin
    raise
      Exception.Create('Did you call dgInitialize()?');
    exit;
  end;
  if not THandles.VerifyHandle( PipeHandle, IMessagePipe ) then begin
    raise
      Exception.Create('Invalid handle for message pipe.');
  end;
  Result := (THandles.InstanceOf(PipeHandle) as IMessagePipe).SendMessageWait( MessageValue, ParamA, ParamB, ParamC, ParamD );
end;

exports
  dgVersionMajor,
  dgVersionMinor,
  dgInitialize,
  dgFinalize,
  dgProgress,
  dgRun,
  dgGetMessagePipe,
  dgSendMessage,
  dgSendMessageWait,
  dgFreeHandle;

end.
