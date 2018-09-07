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
unit darkglass.static;
{$ifdef fpc} {$mode delphi} {$endif}

interface

implementation
uses
  darkGlass.engine,
  darkGlass;

initialization
                 dgVersionMajor := @darkGlass.engine.dgVersionMajor;
                 dgVersionMinor := @darkGlass.engine.dgVersionMinor;
                   dgInitialize := @darkGlass.engine.dgInitialize;
                     dgFinalize := @darkGlass.engine.dgFinalize;
                     dgProgress := @darkGlass.engine.dgProgress;
                          dgRun := @darkGlass.engine.dgRun;
               dgGetMessagePipe := @darkGlass.engine.dgGetMessagePipe;
                  dgSendMessage := @darkGlass.engine.dgSendMessage;
              dgSendMessageWait := @darkGlass.engine.dgSendMessageWait;
                   dgFreeHandle := @darkGlass.engine.dgFreeHandle;

end.
