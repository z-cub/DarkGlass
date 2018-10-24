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
unit darkthreading.messagepipe;
{$ifdef fpc} {$mode delphiunicode} {$endif}

interface

type
  ///  <summary>
  ///    An implementation of IMessagePipe represents a sender which is able
  ///    to send message into a message channel.
  ///  </summary>
  IMessagePipe = interface
    ['{0BA78A88-4082-4B7E-BD07-3920CE7440B4}']

    ///  <summary>
    ///    Sends a message into the message pipe and waits until the message
    ///    has been handled. The message handler may return a result value
    ///    in the result of this method.
    ///  </summary>
    function SendMessageWait( MessageValue: nativeuint; ParamA: nativeuint = 0; ParamB: nativeuint = 0; ParamC: nativeuint = 0; ParamD: nativeuint = 0 ): nativeuint;

    ///  <summary>
    ///    Sends a message into the message pipe.
    ///    Returns TRUE if the message was successfully sent, otherwise
    ///    returns FALSE. This method returns immediately and therefore does not
    ///    wait for a response.
    ///  </summary>
    function SendMessage( MessageValue: nativeuint; ParamA: nativeuint = 0; ParamB: nativeuint = 0; ParamC: nativeuint = 0; ParamD: nativeuint = 0 ): boolean;

  end;

implementation

end.
