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
unit darkThreading;
{$ifdef fpc} {$mode delphiunicode} {$endif}

interface
uses
  darkthreading.criticalsection,
  darkthreading.signaledcriticalsection,
  darkthreading.message,
  darkthreading.messagebus,
  darkthreading.messagechannel,
  darkthreading.messagepipe,
  darkthreading.threadmethod,
  darkthreading.threadpool,
  darkthreading.poolthread,
  darkthreading.threadsubsystem,
  darkthreading.threadsystem;


type
  /// <exclude/>
  TThreadExecuteMethod = darkthreading.threadmethod.TThreadExecuteMethod;
  /// <exclude/>
  IThreadMethod = darkthreading.threadmethod.IThreadMethod;
  /// <exclude/>
  ICriticalSection = darkthreading.criticalsection.ICriticalSection;
  /// <exclude/>
  ISignaledCriticalSection = darkthreading.signaledcriticalsection.ISignaledCriticalSection;
  /// <exclude/>
  TMessage = darkthreading.message.TMessage;
  /// <exclude/>
  IMessagePipe = darkthreading.messagepipe.IMessagePipe;
  /// <exclude/>
  TMessageHandler = darkthreading.messagechannel.TMessageHandler;
  /// <exclude/>
  IMessageChannel = darkthreading.messagechannel.IMessageChannel;
  /// <exclude/>
  IMessageBus = darkthreading.messagebus.IMessageBus;
  /// <exclude/>
  IPoolThread = darkthreading.poolthread.IPoolThread;
  /// <exclude/>
  IThreadPool = darkthreading.threadpool.IThreadPool;
  /// <exclude/>
  IThreadSubSystem = darkthreading.threadsubsystem.IThreadSubsystem;
  /// <exclude/>
  IThreadSystem =darkthreading.threadsystem.IThreadSystem;


//------------------------------------------------------------------------------
//  Factories.
//------------------------------------------------------------------------------
type
  TThreadMethod = class
  public
    class function Create: IThreadMethod; static;
  end;

  TCriticalSection = class
  public
    class function Create: ICriticalSection; static;
  end;

  TSignaledCriticalSection = class
  public
    class function Create: ISignaledCriticalSection; static;
  end;

  TThreadPool = class
  public
    class function Create: IThreadPool; static;
  end;

  TThreadSystem = class
  public
    ///  <summary>
    ///    Creates an instance of IThreadSystem with the specified number of
    ///    threads. If the threads parameter is omitted or passed as zero,
    ///    then the number of threads created will be CPUCount * 2.
    ///    ( Except for IOS, in which case the thread count will be
    ///     CPUCount )
    ///  </summary>
    class function Create( Threads: uint32 = 0 ): IThreadSystem; static;
  end;

implementation
uses
  darkthreading.threadpool.standard,
  darkThreading.threadsystem.standard,
  {$ifdef MSWINDOWS}
  darkthreading.threadmethod.windows,
  darkthreading.signaledcriticalsection.windows,
  darkthreading.criticalsection.windows;
  {$else}
  darkthreading.threadmethod.posix,
  darkthreading.signaledcriticalsection.posix,
  darkthreading.criticalsection.posix;
  {$endif}

{ TThreadMethod }

class function TThreadMethod.Create: IThreadMethod;
begin
  {$ifdef MSWINDOWS}
  Result := TWindowsThreadMethod.Create;
  {$else}
  Result := TPosixThreadMethod.Create;
  {$endif}
end;

{ TCriticalSection }

class function TCriticalSection.Create: ICriticalSection;
begin
  {$ifdef MSWINDOWS}
  Result := TWindowsCriticalSection.Create;
  {$else}
  Result := TPosixCriticalSection.Create;
  {$endif}
end;

{ TSignaledCriticalSection }

class function TSignaledCriticalSection.Create: ISignaledCriticalSection;
begin
  {$ifdef MSWINDOWS}
  Result := TWindowsSignaledCriticalSection.Create;
  {$else}
  Result := TPosixSignaledCriticalSection.Create;
  {$endif}
end;

class function TThreadPool.Create: IThreadPool;
begin
  Result := darkthreading.threadpool.standard.TThreadPool.Create;
end;

{  TThreadSystem }

class function TThreadSystem.Create( Threads: uint32 = 0 ): IThreadSystem;
begin
  Result := darkThreading.threadsystem.standard.TThreadSystem.Create( Threads );
end;

end.
