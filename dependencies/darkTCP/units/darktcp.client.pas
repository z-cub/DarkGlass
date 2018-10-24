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
unit darktcp.client;

interface
uses
  darkTcp.types,
  darkTcp.connection;

type
  ITCPClient = interface( ITCPConnection )
    ['{329591CD-503D-4B9F-8795-7C17D689AB3E}']
    //- Getters and setters
    ///  <summary>
    ///    Returns true if the client is currently connected to a server, else
    ///    returns false.
    ///  </summary>
    function getConnected: boolean;

    ///  <summary>
    ///    Setting connected to true causes the client to attempt a connection
    ///    to a server. The address, port and protocol used for the connection
    ///    are specified through the properties (and associated getters/setters)
    ///    of Address, Port, Protocol. The Blocking property is also used to
    ///    indicate if the connection should be synchronous or asynchronous
    ///    in nature.
    ///    Setting connected to false will cause the client to disconnect from
    ///    the server.
    ///  </summary>
    procedure setConnected( value: boolean );

    ///  <summary>
    ///    Sets the address to which this client should connect when it's
    ///    connected property is set true. If the client is already
    ///    connected to a server, the connection will be terminated when
    ///    altering the address.
    ///  </summary>
    procedure setAddress( value: string );

    ///  <summary>
    ///    Sets the port number on which the client should connect to a server
    ///    when it's connected property is set true. If the client is already
    ///    connected to a server, the connection will be terminated when
    ///    altering the port.
    ///  </summary>
    procedure setPort( value: uint32 );

    ///  <summary>
    ///    Sets the TCP protocol version (IPv4/IPv6) which is used by this
    ///    client to connect to a server. If the client is already
    ///    connected to a server, the connection will be terminated when
    ///    altering the protocol.
    ///  </summary>
    procedure setProtocol( value: TInternetProtocol );

    ///  <summary>
    ///    Sets the blocking mode of the client connection to the server, where
    ///    TRUE sets synchronous mode, and FALSE sets asynchronous mode.
    ///    Note that you should check that blocking was set as requested
    ///    by calling getBlocking (or reading the Blocking property), as some
    ///    connections may not support the requested mode.
    ///  </summary>
    procedure setBlocking( value: boolean );

    ///  <summary>
    ///    Returns the number of bytes of data currently waiting to be read
    ///    from the socket.
    ///  </summary>
    function getBytesOnSocket: int32;

    //- Pascal only properties -//

    ///  <summary>
    ///    Get/Set the connected status of this connection to the server.
    ///    Setting this property to TRUE will cause the client to attempt
    ///    to connect to the server (if not already connected). Setting
    ///    conneted to FALSE will disconnect the client from the server if it
    ///    is already connected. When setting this property you should read it
    ///    again to confirm that it was altered as required. For example,
    ///    when setting connected to TRUE, it will revert back to FALSE if the
    ///    client was unable to connect to the server for any reason.
    ///  </summary>
    property Connected: boolean read getConnected write setConnected;

    ///  <summary>
    ///    Get or Set the IPAddress of the server that this client should
    ///    connect to. Setting this property will cause an existing connection
    ///    to be terminated.
    ///  </summary>
    property Address: string read getAddress write setAddress;

    ///  <summary>
    ///    Get or set the TCP/IP Port number on which to connect to the
    ///    server. Setting this property will cause an existing connection to
    ///    be terminated.
    ///  </summary>
    property Port: uint32 read getPort write setPort;

    ///  <summary>
    ///    Set or get the TCP/IP protocol version (IPv4/IPv6) which is to be
    ///    used to connect to the server. Setting this property will cause an
    ///    existing connection to be terminated.
    ///  </summary>
    property Protocol: TInternetProtocol read getProtocol write setProtocol;

    ///  <summary>
    ///    Get or Set the blocking mode of the connection, where blocking (TRUE)
    ///    is synchronous, and non-blocking (FALSE) is asynchronous.
    ///    Some connections may not support both modes, you should check that
    ///    this property successfully changed after setting it.
    ///  </summary>
    property Blocking: boolean read getBlocking write setBlocking;

    ///  <summary>
    ///    Returns the number of bytes waiting to be read from the socket.
    ///    This can be used in blocking mode to prevent a blocking call to
    ///    Recieve data when there is no data.
    ///  </summary>
    property BytesOnSocket: int32 read getBytesOnSocket;
  end;

implementation

end.
