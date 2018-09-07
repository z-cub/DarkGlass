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
unit darkthreading.threadpool;
{$ifdef fpc} {$mode delphiunicode} {$endif}

interface
uses
  darkthreading.poolthread;

type
  ///  <summary>
  ///    Manages a pool of processing threads operating on a pool of ISubSystem.
  ///  </summary>
  IThreadPool = interface
    ['{F397A185-FD7E-4748-BA1F-B79D46348F34}']

    ///  <summary>
    ///    Returns the numnber of IPoolThreads that have been installed.
    ///  </summary>
    function getThreadCount: uint32;

    ///  <summary>
    ///    Returns one of the pool thread instances by index.
    ///  </summary>
    function getThread( idx: uint32 ): IPoolThread;

    ///  <summary>
    ///    Installs a thread into the thread pool.
    ///  </summary>
    function InstallThread( aSubSytem: IPoolThread ): boolean;

    ///  <summary>
    ///    Start the threads running.
    ///  </summary>
    function Start: boolean;

    ///  <summary>
    ///    Terminates the running threads and disposes the subsystems.
    ///  </summary>
    procedure Stop;

    //- Pascal Only, Properties -//
    property ThreadCount: uint32 read getThreadCount;
    property Threads[ idx: uint32 ]: IPoolThread read getThread;
  end;

implementation

end.
