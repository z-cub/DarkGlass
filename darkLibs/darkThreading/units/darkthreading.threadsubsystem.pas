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
unit darkthreading.threadsubsystem;
{$ifdef fpc} {$mode delphiunicode} {$endif}

interface
uses
  darkthreading.messagebus;

type
  ///  <summary>
  ///    Implement IThreadSubsystem to provide functionality to be executed
  ///    within a thread system (IThreadSystem)
  ///  </summary>
  IThreadSubSystem = interface
    ['{9CBE79FE-CDAA-4D25-A269-F2A199A16E74}']

    ///  <summary>
    ///    Return true if this thread sub-system must run in the main thread.
    ///  </summary>
    function MainThread: boolean;

    ///  <summary>
    ///    Return true if this thread sub-system must have it's own dedicated
    ///    thread.
    ///  </summary>
    function Dedicated: boolean;

    ///  <summary>
    ///    The thread system will call this method when the subsystem is
    ///    first installed. This method is always called by the main thread
    ///    as it is called before the auxilary threads are running.
    ///  </summary>
    function Install( MessageBus: IMessageBus ): boolean;

    ///  <summary>
    ///    The operating thread for this thread sub-system will call this
    ///    method immediately after the thread starts running.
    ///  </summary>
    function Initialize( MessageBus: IMessageBus ): boolean;

    ///  <summary>
    ///    The operating thread for this thread sub-system will call this
    ///    method repeatedly during the lifetime of the thread. If this
    ///    method returns true, execution will continue. If this method
    ///    returns false, then this thread sub-system will be removed from
    ///    it's operating thread and will no longer be executed.
    ///  </summary>
    function Execute: boolean;

    ///  <summary>
    ///    The operating thread will call this method when the subsystem is
    ///    being shut down, either because the thread is terminating, or
    ///    when this thread sub-system returns false from it's execute method.
    ///  </summary>
    procedure Finalize;
  end;

implementation

end.
