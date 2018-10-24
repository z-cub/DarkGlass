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
unit darktcp.connection;

interface
uses
  darkIO.buffers,
  darkTcp.types;

type
  ITCPConnection = interface; //- Forward

  ///  <summary>
  ///    Event fired when an ITCPConnection class has lost it's socket
  ///    connection due to error or the other end of the connection
  ///    disconnecting.
  ///  </summary>
  TConnectionLostEvent = procedure( Disconnected: ITCPConnection ) of object;

  /// <summary>
  ///   Represents a TCP socket connection. (Either a client connected to an
  ///   ITCPServer, or as part of an ITCPClient).
  /// </summary>
  ITCPConnection = interface
    ['{ED3CEE00-7FCA-4C18-A417-8D24E301E3F3}']

    /// <summary>
    ///   Receives a buffer of data from this connection. <br />If the
    ///   connection socket is a synchronous socket, this method blocks until
    ///   data is received. <br /><br />If the connection socket is an
    ///   asynchronous socket, this method may return nil to indicate that
    ///   there is no data to be received.
    /// </summary>
    /// <param name="max">
    ///   sIndicates the maximum number of bytes to receive.
    /// </param>
    function Recv( max: int32 ): IUnicodeBuffer;

    /// <summary>
    ///   <para>
    ///     Sends a buffer of data through this socket connection and returns
    ///     the number of bytes sent.
    ///   </para>
    ///   <para>
    ///     Compare the result against the size of the buffer intended to be
    ///     transmitted. If these values differ, there may have been an error
    ///     transmitting the data, and the result of Send() indicates how
    ///     much data was transmitted. An error message will be inserted into
    ///     the darkLog when data could not be entirely transmitted.
    ///   </para>
    /// </summary>
    function Send( aBuffer: IUnicodeBuffer ): int32;

    /// <summary>
    ///   Returns the network address of the device on the other end of this
    ///   socket connection. For example, if this ITCPConnection is returned
    ///   from an ITCPServer.Accept() method call, this property represents the
    ///   address of the connecting client.
    /// </summary>
    function getAddress: string;

    /// <summary>
    ///   Returns the port number on the other end of the socket connection.
    ///   For example, if this ITCPConnection is returned from a
    ///   ITCPServer.Accept() method, this property represents the outgoing
    ///   port number of the client connection.
    /// </summary>
    function getPort: uint32;

    /// <summary>
    ///   Returns the TCP/IP protocol version used for this connection.
    /// </summary>
    function getProtocol: TInternetProtocol;

    /// <summary>
    ///   Returns true of this is a synchronous connection, or else returns
    ///   false.
    /// </summary>
    function getBlocking: boolean;

    ///  <summary>
    ///    Gets the event handler which is fired when a network connection
    ///    error occurs, or the other end of the socket disconnects.
    ///  </summary>
    function getOnConnectionLost: TConnectionLostEvent;

    ///  <summary>
    ///    Sets the event handler which is fired when a network connection
    ///    error occurs, or the end of the socket disconnects.
    ///  </summary>
    procedure setOnConnectionLost( value: TConnectionLostEvent );

    /// <summary>
    ///   Returns the network address of the device on the other end of this
    ///   socket connection. For example, if this ITCPConnection is returned
    ///   from an ITCPServer.Accept() method call, this property represents the
    ///   address of the connecting client.
    /// </summary>
    property Address: string read getAddress;

    /// <summary>
    ///   Returns the port number on the other end of the socket connection.
    ///   For example, if this ITCPConnection is returned from a
    ///   ITCPServer.Accept() method, this property represents the outgoing
    ///   port number of the client connection.
    /// </summary>
    property Port: uint32 read getPort;

    /// <summary>
    ///   Returns the TCP/IP protocol version used for this connection.
    /// </summary>
    property Protocol: TInternetProtocol read getProtocol;

    /// <summary>
    ///   Returns true of this is a synchronous connection, or else returns
    ///   false.
    /// </summary>
    property Blocking: boolean read getBlocking;

    ///  <summary>
    ///    Get or set the event handler which is fired when the connection is
    ///    lost because the other end disconnects, or due to connection
    ///    error.
    ///  </summary>
    property OnConnectionLost: TConnectionLostEvent read getOnConnectionLost write setOnConnectionLost;
  end;


implementation

end.
