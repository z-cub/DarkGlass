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
unit darkthreading.messagechannel;
{$ifdef fpc} {$mode delphiunicode} {$endif}

interface
uses
  darkthreading.messagepipe,
  darkthreading.message;

type
  ///  <summary>
  ///    Callback used to handle messages coming from a message channel.
  ///  </summary>
  TMessageHandler = function (aMessage: TMessage): nativeuint of object;

  ///  <summary>
  ///    An implementation of IMessageChannel represents a listener for a
  ///    channel of messages. The listener may be used by a single thread only.
  ///    See IMessagePipe for multiple sender.
  ///  </summary>
  IMessageChannel = interface
    ['{69D9504A-3DCC-4294-8D9C-29020D8FB997}']

    ///  <summary>
    ///    Creates and returns a new instance of IMessagePipe which is able
    ///    to send messages into the channel.
    ///  </summary>
    function GetMessagePipe: IMessagePipe;

    ///  <summary>
    ///    Checks all message pipes connected to the channel for new incomming
    ///    messages. This method will block execution and sleep the thread
    ///    until new messages are available.
    ///  </summary>
    procedure GetMessage( Handler: TMessageHandler );

    ///  <summary>
    ///    Checks all message pipes connected to the channel for new incomming
    ///    messages. If a new message is available, MessagesWaiting will return
    ///    TRUE, otherwise FALSE.
    ///  </summary>
    function MessagesWaiting: boolean;
  end;

implementation

end.
