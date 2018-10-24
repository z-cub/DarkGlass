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
unit darkthreading.threadmethod;
{$ifdef fpc} {$mode delphiunicode} {$endif}

interface

type
  ///  <summary>
  ///    The thread execute method callback, used by IThreadMethod.
  ///  </summary>
  TThreadExecuteMethod = function(): boolean of object;

  ///  <summary>
  ///    IThreadMethod represents a long running thread, which will
  ///    repeatedly call an external execute method, until that method
  ///    returns false.
  ///  </summary>
  IThreadMethod = interface
    ['{FB86E522-F520-4496-AC08-CAAE6FA0C11A}']

    ///  <summary>
    ///    Causes the running thread to shut down.
    ///  </summary>
    function Terminate( Timeout: uint32 = 25 ): boolean;

    ///  <summary>
    ///    Returns a reference to the method to be executed.
    ///  </summary>
    function getExecuteMethod: TThreadExecuteMethod;

    ///  <summary>
    ///    Sets the reference for the method to be executed.
    ///  </summary>
    procedure setExecuteMethod( value: TThreadExecuteMethod );

    //- Pascal Only, Properties -//
    property ExecuteMethod: TThreadExecuteMethod read getExecuteMethod write setExecuteMethod;
  end;

implementation

end.
