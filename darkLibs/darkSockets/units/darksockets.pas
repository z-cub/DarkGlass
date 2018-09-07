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
unit darksockets;

interface
uses
  darkSockets.sockets;

type
  //- Specific to sockets.
  TSocketHandle            = darkSockets.sockets.TSocketHandle;
  TSocketDomain            = darkSockets.sockets.TSocketDomain;
  TSocketKind              = darkSockets.sockets.TSocketKind;
  TPacketProtocol          = darkSockets.sockets.TPacketProtocol;
  TNetworkAddress          = darkSockets.sockets.TNetworkAddress;
  TSocketStatus            = darkSockets.sockets.TSocketStatus;
  TShutdownOptions         = darkSockets.sockets.TShutdownOptions;
  TSocket                  = darkSockets.sockets.TSocket;
  ISockets                 = darkSockets.sockets.ISockets;

function Sockets: ISockets;

implementation
uses
  darkSockets.sockets.standard;

function Sockets: ISockets;
begin
  Result := TSockets.Create;
end;

end.
