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
unit darktcp;

interface
uses
  darkTcp.types,
  darkTcp.connection,
  darkTcp.server,
  darkTcp.client,
  darkTcp.command;


type
  //- TCP Server & Client
  TInternetProtocol        = darkTcp.types.TInternetProtocol;
  ITCPConnection           = darkTcp.connection.ITCPConnection;
  ITCPServer               = darkTcp.server.ITCPServer;
  ITCPClient               = darkTcp.client.ITCPClient;
  TTCPCommand              = darkTcp.command.TTCPCommand;
  TCommandToken            = darkTcp.command.TCommandToken;

function TCPServer( Protocol: TInternetProtocol; Address: string; Port: uint32 ): ITCPServer;
function TCPClient( Protocol: TInternetProtocol; Address: string; Port: uint32 ): ITCPClient;

implementation
uses
  darkTcp.server.standard,
  darkTcp.client.standard;

function TCPServer( Protocol: TInternetProtocol; Address: string; Port: uint32 ): ITCPServer;
begin
  Result := TTCPServer.Create;
  Result.Protocol := Protocol;
  Result.Address := Address;
  Result.Port := Port;
end;

function TCPClient( Protocol: TInternetProtocol; Address: string; Port: uint32 ): ITCPClient;
begin
  Result := TTCPClient.Create;
  Result.Protocol := Protocol;
  Result.Address := Address;
  Result.Port := Port;
end;

end.
