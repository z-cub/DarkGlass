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
unit darkthreading.threadsystem;
{$ifdef fpc} {$mode delphiunicode} {$endif}

interface
uses
  darkthreading.threadsubsystem,
  darkthreading.messagebus;

type
  ///  <summary>
  ///    Manages a collection of sub-systems to be executed within a pool
  ///    of threads.
  ///  </summary>
  IThreadSystem = interface
    ['{9C1FB3E1-A9BC-4897-BD01-D5EA2933132D}']

    ///  <summary>
    ///    Returns the message bus which is used to allow sub-modules to
    ///    communicate with each other.
    ///  </summary>
    function MessageBus: IMessageBus;

    ///  <summary>
    ///    Installs a subsystem to be executed by the operating threads.
    ///    This method may only be called before the thread system starts
    ///    running.
    ///  </summary>
    function InstallSubSystem( aSubSystem: IThreadSubsystem ): boolean;

    ///  <summary>
    ///    Starts the ancillary threads running. When using the Start()
    ///    method (rather than the run method), the main thread remains with
    ///    the calling application. Sub-systems installed on the main thread
    ///    will not be excuted when using Start()/Stop().
    ///  </summary>
    ///  <remark>
    ///    Between Start() / Stop() the main thread can be progressed manually
    ///    by repeatedly calling the Progress() method.
    ///  </remark>
    procedure Start;

    ///  <summary>
    ///    Stops the ancillary threads which were started with a call to the
    ///    Start() method.
    ///  </summary>
    ///  <remark>
    ///    Between Start() / Stop() the main thread can be progressed manually
    ///    by repeatedly calling the Progress() method.
    ///  </remark>
    procedure Stop;

    /// <summary>
    ///   <para>
    ///     Manually progresses the main thread (executes the main thread
    ///     sub-systems) when called between Start() / Stop() methods. <br />
    ///     This will progress the main thread a single iteration, allowing
    ///     manual progression of the main thread by repeatedly calling
    ///     Progress() between Start() and Stop() methods.
    ///   </para>
    ///   <para>
    ///     The Start() / Progress() / Stop() pattern is mutually exclusive
    ///     to calling the Run() method.
    ///   </para>
    ///   <para>
    ///     So long as there are sub-systems installed on the main thread,
    ///     the following code is an acceptable pattern...
    ///   </para>
    ///   <code lang="Delphi">start;
    /// try
    ///   while Progress do;
    /// finally
    ///   stop;
    /// end; </code>
    /// </summary>
    /// <returns>
    ///   Returns true when there is work remaining to be performed on the main
    ///   thread, else returns false.
    /// </returns>
    function Progress: boolean;

    /// <summary>
    ///   Starts the thread system running. <br />Auxilary threads are started
    ///   first, and then the main thread runs. <br />Execution continues until
    ///   the main thread exits, at which time the Auxilary threads are also
    ///   stopped. <br />Internally, this method executes the following code:
    ///   <code lang="Delphi">start;
    /// try
    ///   while progress do;
    /// finally
    ///   stop;
    /// end;</code>
    ///   This method is mutually exclusive to using the start() / progress() /
    ///   stop() pattern.
    /// </summary>
    procedure Run;
  end;

implementation

end.
