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
unit darktcp.server;

interface
uses
  darkTcp.types,
  darkTcp.connection;

type
  /// <summary>
  ///   This interface represents a server side tcp socket which is able to
  ///   accept incoming connections and send or recieve data through those
  ///   connections.
  /// </summary>
  ITCPServer = interface
    ['{7906F36C-C59D-4F2D-B42A-0F591B00D0E9}']

    /// <summary>
    ///   Returns TRUE if the server socket is open and awating connections,
    ///   else returns FALSE.
    /// </summary>
    function getEnabled: boolean;

    /// <summary>
    ///   Returns the internet address or "domain" of the server, or rather,
    ///   the address to which the server socket is bound when enabled.
    /// </summary>
    function getAddress: string;

    /// <summary>
    ///   Returns the port number on which the server socket will listen for
    ///   incoming connections.
    /// </summary>
    function getPort: uint32;

    /// <summary>
    ///   Returns a TInternetProtocol enumeration specifying the Internet
    ///   Protocol version which will be used by the server socket.
    /// </summary>
    function getProtocol: TInternetProtocol;

    /// <summary>
    ///   Returns TRUE if the server uszes a synchronous socket.
    /// </summary>
    function getBlocking: boolean;

    /// <summary>
    ///   Returns the number of clients connected to this server.
    ///   CAUTION: When looping over the clients to recieve data from them,
    ///   be sure to perform the loop from ClientCount downto zero, rather than
    ///   zero to ClientCount. The client recieve call is used to detect
    ///   disconnected clients, which will be removed from the server clients
    ///   list.
    /// </summary>
    function getClientCount: uint32;

    /// <summary>
    ///   Returns an instance of ITCPConnection representing a client connected
    ///   to this server, by index.
    ///   CAUTION: When looping over the clients to recieve data from them,
    ///   be sure to perform the loop from ClientCount downto zero, rather than
    ///   zero to ClientCount. The client recieve call is used to detect
    ///   disconnected clients, which will be removed from the server clients
    ///   list.
    /// </summary>
    /// <param name="idx">
    ///   The index of the client connection to return.
    /// </param>
    function getClient( idx: uint32 ): ITCPConnection;

    /// <summary>
    ///   <para>
    ///     Sets the Enabled property. When set TRUE the sever socket will be
    ///     bound and begin listening, using the Address, Port and Protocols
    ///     sepcified in their respective properties.
    ///   </para>
    ///   <para>
    ///     Should the server fail to bind or listen for incoming
    ///     connections, an error will be inserted into the log and the
    ///     Enabled property will revert to False.
    ///   </para>
    ///   <para>
    ///     When set FALSE this property will dispose of the listening server
    ///     socket.
    ///   </para>
    /// </summary>
    procedure setEnabled( value: boolean );

    /// <summary>
    ///   Sets the address to which the server socket should be bound. Note
    ///   that if the server socket is already listening for connections, it
    ///   will be disposed of when setting the address.
    /// </summary>
    procedure setAddress( value: string );

    /// <summary>
    ///   Sets the port to which the server socket should be bound. Note that
    ///   if the server socket is already listening for connections, it will be
    ///   disposed of when setting the port.
    /// </summary>
    procedure setPort( value: uint32 );

    /// <summary>
    ///   Sets the IP protocol to use when binding and listening on the server
    ///   socket. Note that if the server socket is already listening for
    ///   connections, it will be disposed of when setting the IP Protocol.
    /// </summary>
    procedure setProtocol( value: TInternetProtocol );

    /// <summary>
    ///   When set TRUE the server socket will be a synchronous socket when the
    ///   server is enabled. When set FALSE the server will be asynchronous.
    ///   This primarily affects the Accept method, determining if the method
    ///   is blocking or not, but will also affect the Recv() and Send()
    ///   methods of any client connections formed.
    /// </summary>
    procedure setBlocking( value: boolean );

    /// <summary>
    ///   <para>
    ///     If the server socket is listening and a client is waiting to
    ///     connect, accept will cause the client to be accepted. <br /><br />
    ///     An instance of ITCPConnection is created and returned to
    ///     represent the client which has been accepted.
    ///   </para>
    ///   <para>
    ///     If the server is not listening, then nil is returned.
    ///   </para>
    ///   <para>
    ///     If the server is listening and in 'non-blocking' mode, but there
    ///     are no clients waiting to connect, then nil is returned.
    ///   </para>
    ///   <para>
    ///     If the server is listening and in blocking mode, the accept
    ///     method will block execution until a client is connected.
    ///   </para>
    /// </summary>
    function Accept: ITCPConnection;

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

    //- pascal only properties -//

    /// <summary>
    ///   Returns the number of clients connected to this server.
    ///   CAUTION: When looping over the clients to recieve data from them,
    ///   be sure to perform the loop from ClientCount downto zero, rather than
    ///   zero to ClientCount. The client recieve call is used to detect
    ///   disconnected clients, which will be removed from the server clients
    ///   list.
    /// </summary>
    property ClientCount: uint32 read getClientCount;

    /// <summary>
    ///   Returns an instance of ITCPConnection representing a client connected
    ///   to this server, by index.
    ///   CAUTION: When looping over the clients to recieve data from them,
    ///   be sure to perform the loop from ClientCount downto zero, rather than
    ///   zero to ClientCount. The client recieve call is used to detect
    ///   disconnected clients, which will be removed from the server clients
    ///   list.
    /// </summary>
    property Client[ idx: uint32 ]: ITCPConnection read getClient;

    /// <summary>
    ///   <para>
    ///     When set TRUE the server binds and begins listening on the
    ///     specified Address and Port using the specified Protocol. If the
    ///     binding or listening process fails, the property will immediately
    ///     revert to a FALSE state and an error message will be inserted in
    ///     the darkLog.
    ///   </para>
    ///   <para>
    ///     When set FALSE the listening server socket is closed.
    ///   </para>
    /// </summary>
    property Enabled: boolean read getEnabled write setEnabled;

    /// <summary>
    ///   Set or Get the address to which the server socket will bind when
    ///   Enabled is set TRUE. <br />Note that adjusting this property while
    ///   the server is listening will cause the server socket to be closed and
    ///   the enabled property to be set FALSE.
    /// </summary>
    /// <remarks>
    ///   A fully qualified IP Address is required. This includes addresses in
    ///   the IPv6 protocol which can typically be abbreviated by omitting
    ///   parts of the IP, for this property all parts must be present.
    /// </remarks>
    property Address: string read getAddress write setAddress;

    /// <summary>
    ///   Get or Set the port to which the server socket will bind when Enabled
    ///   is set TRUE. <br />Note that adjusting this property while the server
    ///   is listening will cause the server socket to be closed and the
    ///   enabled property to be set FALSE. <br />
    /// </summary>
    property Port: uint32 read getPort write setPort;


    /// <summary>
    ///   <para>
    ///     Get or Set the internet protocol to be used when the server
    ///     socket is bound to its address.
    ///   </para>
    ///   <para>
    ///     Note that adjusting this property while the server is listening
    ///     will cause the server socket to be closed and the enabled
    ///     property to be set FALSE. <br />
    ///   </para>
    /// </summary>
    property Protocol: TInternetProtocol read getProtocol write setProtocol;


    /// <summary>
    ///   Set or Get the blocking nature of the server socket. If set TRUE the
    ///   socket is blocking (synchronous), or else the server socket is
    ///   non-blocking (asynchronous).
    /// </summary>
    property Blocking: boolean read getBlocking write setBlocking;

    ///  <summary>
    ///    Get or Set the event handler which is fired when a connection is
    ///    lost, either because the client disconnected, or due to a network
    ///    error.
    ///  </summary>
    property OnConnectionLost: TConnectionLostEvent read getOnConnectionLost write setOnConnectionLost;
  end;

implementation

end.
