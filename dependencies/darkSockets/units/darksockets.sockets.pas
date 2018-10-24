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
unit darksockets.sockets;

interface
uses
  darkLog;

type
  ///  <summary>
  ///    Error message logged when an attempt to translate an address from
  ///    a string to a socket address, or back, fails.
  ///  </summary>
  EAddressTranslation = class(ELogEntry);

  ///  <summary>
  ///  </summary>
  ESocketResourceError = class(ELogEntry);

  ///  <summary>
  ///    Error message logged when a worker thread fails to shutdown correctly.
  ///  </summary>
  EShutdownThread = class(ELogEntry);

  ///  <summary>
  ///    Error message logged when an attempt to accept an incomming socket
  ///    connection fails.
  ///  </summary>
  EAcceptFailed = class(ELogEntry);

type
  ///  <summary>
  ///    Represents a socket handle.
  ///  </summary>
  {$ifdef mswindows}
    TSocketHandle = array[0..7] of byte;
  {$else}
    TSocketHandle = int32;
  {$endif}

  /// <summary>
  ///   The socket domain indicates the type of address being used to initiate
  ///   a socket.
  /// </summary>
  TSocketDomain =
    (
    /// <summary>
    ///   The address family is unspecified.
    /// </summary>
    sdUnspecified,
	  /// <summary>
	  ///   The Internet Protocol version 4 (IPv4) address family.
	  /// </summary>
	  sdIPv4,
	  /// <summary>
	  ///   The Internet Protocol version 6 (IPv6) address family.
	  /// </summary>
	  sdIPv6,
	  /// <summary>
	  ///   The Infrared Data Association (IrDA) address family. This address
	  ///   family is only supported if the computer has an infrared port and
	  ///   driver installed.
	  /// </summary>
	  sdInfrared,
	  /// <summary>
	  ///   The Bluetooth address family. This address family is if the computer
	  ///   has a Bluetooth adapter and driver installed.
	  /// </summary>
	  sdBluetooth,
    /// <summary>
    ///   Address family Appletalk DDP
    /// </summary>
    sdAppleTalk,
	  /// <summary>
	  ///   <para>
	  ///     From MSDN: <br /><br />The NetBIOS address family. This address
	  ///     family is only supported if the Windows Sockets provider for
	  ///     NetBIOS is installed.
	  ///   </para>
	  ///   <para>
	  ///     <br />The Windows Sockets provider for NetBIOS is supported on
	  ///     32-bit <br />versions of Windows. This provider is installed by
	  ///     default on 32-bit versions of Windows.
	  ///   </para>
	  ///   <para>
	  ///     The Windows Sockets provider for NetBIOS is not supported on
	  ///     64-bit versions of windows including Windows 7, Windows Server
	  ///     2008, Windows Vista, Windows Server 2003, or Windows XP.
	  ///   </para>
	  ///   <para>
	  ///     The Windows Sockets provider for NetBIOS only supports sockets
	  ///     where the type parameter is set to SOCK_DGRAM.
	  ///   </para>
	  ///   <para>
	  ///     The Windows Sockets provider for NetBIOS is not directly related
	  ///     to the NetBIOS programming interface. The NetBIOS programming
	  ///     interface is not supported on Windows Vista, Windows Server 2008,
	  ///     and later.
	  ///   </para>
	  /// </summary>
	  sdNetBios,
	  /// <summary>
	  ///   <para>
	  ///     From MSDN:
	  ///   </para>
	  ///   <para>
	  ///     <br />The IPX/SPX address family. This address family is only
	  ///     supported if the NWLink IPX/SPX NetBIOS Compatible Transport
	  ///     protocol is installed. <br /><br />This address family is not
	  ///     supported on Windows Vista and later.
	  ///   </para>
	  /// </summary>
	  sdIPX,
	  /// <summary>
	  ///   Ash
	  /// </summary>
	  sdASH,
	  /// <summary>
	  ///   ATM PVCs
	  /// </summary>
	  sdATMPVC,
    /// <summary>
    ///   ATM SVCs
    /// </summary>
    sdATMSVC,
	  /// <summary>
	  ///   Amateur Radio AX.25
	  /// </summary>
	  sdAX25,
	  /// <summary>
	  ///   Multiprotocol bridge
	  /// </summary>
	  sdBRIDGE,
	  /// <summary>
	  ///   Reserved for DECnet project.
	  /// </summary>
	  sdDECnet,
	  /// <summary>
	  ///   Acorn Econet
	  /// </summary>
	  sdAECONET,
    /// <summary>
    ///   PF_KEY key management API
    /// </summary>
    sdKEY,
	  /// <summary>
	  ///   Linux LLC
	  /// </summary>
	  sdLLC,
	  /// <summary>
	  ///   Unix socket
	  /// </summary>
	  sdLOCAL,
	  /// <summary>
	  ///   Reserved for 802.2LLC project
	  /// </summary>
	  sdNETBEUI,
	  sdNETLINK,
    /// <summary>
    ///   Amateur radio NetROM
    /// </summary>
    sdNETROM,
	  /// <summary>
	  ///   Packet family
	  /// </summary>
	  sdPACKET,
	  /// <summary>
	  ///   PPPoX sockets
	  /// </summary>
	  sdPPPOX,
	  /// <summary>
	  ///   Amateur Radio X.25 PLP
	  /// </summary>
	  sdROSE,
	  /// <summary>
	  ///   Alias to emulate 4.4BSD.
	  /// </summary>
	  sdROUTE,
    /// <summary>
    ///   Security callback pseudo AF
    /// </summary>
    sdSECURITY,
	  /// <summary>
	  ///   Linux SNA project
	  /// </summary>
	  sdSNA,
	  /// <summary>
	  ///   TIPC sockets
	  /// </summary>
	  sdTIPC,
	  /// <summary>
	  ///   Unix domain sockets
	  /// </summary>
	  sdUNIX,
	  /// <summary>
	  ///   Wanpipe API Sockets
	  /// </summary>
	  sdWANPIPE,
    /// <summary>
    ///   Reserved for X.25 project
    /// </summary>
    sdX25
    );

  /// <summary>
  ///   The type of socket to create.
  /// </summary>
  TSocketKind = (
   /// <summary>
   ///   Datagram (connectionless) socket (UDP)
   /// </summary>
   skDatagram,
	 /// <summary>
	 ///   Stream (connection) type socket (TCP)
	 /// </summary>
	 skStream,
	 /// <summary>
	 ///   Raw socket
	 /// </summary>
	 skRaw,
	 /// <summary>
	 ///   Reliably-delivered message
	 /// </summary>
	 skRDM,
	 /// <summary>
	 ///   Sequential packet socket
	 /// </summary>
	 skSeqPacket
  );

  /// <summary>
  ///   Enumeration representing a socket protocol.
  /// </summary>
  TPacketProtocol =
    (
    /// <summary>
    ///   Unspecified, let the system handle it.
    /// </summary>
    ppUnSpec,
	  /// <summary>
	  ///   <para>
	  ///     Internet Control Message Protocol. <br /><br />From MSDN <br /><br />
	  ///     The Internet Control Message Protocol (ICMP). This is a possible
	  ///     value when the af parameter is AF_UNSPEC, AF_INET, or AF_INET6 and
	  ///     the type parameter is SOCK_RAW or unspecified.
	  ///   </para>
	  ///   <para>
	  ///     This protocol value is supported on Windows XP and later.
	  ///   </para>
	  /// </summary>
	  ppICMP,
	  /// <summary>
	  ///   <para>
	  ///     From MSDN
	  ///   </para>
	  ///   <para>
	  ///     <br />The Internet Group Management Protocol (IGMP). This is a
	  ///     possible value when the af parameter is AF_UNSPEC, AF_INET, or
	  ///     AF_INET6 and the type parameter is SOCK_RAW or unspecified. This
	  ///     protocol value is supported on Windows XP and later. <br />
	  ///   </para>
	  /// </summary>
	  ppIGMP,
	  /// <summary>
	  ///   From MSDN <br /><br />The Bluetooth Radio Frequency Communications
	  ///   (Bluetooth RFCOMM) <br />protocol. This is a possible value when the
	  ///   af parameter is AF_BTH and the type parameter is SOCK_STREAM. This
	  ///   protocol value is supported on Windows XP with SP2 or later.s <br />
	  /// </summary>
	  ppRFCOMM,
	  /// <summary>
	  ///   From MSDN <br /><br />The Transmission Control Protocol (TCP). This is
	  ///   a possible value when the af parameter is AF_INET or AF_INET6 and the
	  ///   type parameter is SOCK_STREAM.
	  /// </summary>
	  ppTCP,
	  /// <summary>
	  ///   <para>
	  ///     From MSDN:
	  ///   </para>
	  ///   <para>
	  ///     The User Datagram Protocol (UDP). This is a possible value when
	  ///     the af parameter is AF_INET or AF_INET6 and the type parameter is
	  ///     SOCK_DGRAM..
	  ///   </para>
	  /// </summary>
	  ppUDP,
	  /// <summary>
	  ///   <para>
	  ///     From MSDN <br /><br />The Internet Control Message Protocol
	  ///     Version 6 (ICMPv6). <br /><br />
	  ///   </para>
	  ///   <para>
	  ///     This is a possible value when the af parameter is AF_UNSPEC,
	  ///     AF_INET, or AF_INET6 and the type parameter is SOCK_RAW or
	  ///     unspecified. This protocol value is supported on Windows XP and
	  ///     later.
	  ///   </para>
	  /// </summary>
	  ppICMPV6,
    /// <summary>
    ///   <para>
    ///     From MSDN <br /><br />
    ///   </para>
    ///   <para>
    ///     The PGM protocol for reliable multicast. This is a possible value
    ///     when the af parameter is AF_INET and the type parameter is
    ///     SOCK_RDM. <br /><br />On the Windows SDK released for Windows
    ///     Vista and later, this protocol is also called IPPROTO_PGM. This
    ///     protocol value is only supported.
    ///   </para>
    /// </summary>
    ppRM,
	  /// <summary>
	  ///   Authentication header.
	  /// </summary>
	  ppAH,
	  /// <summary>
	  ///   Compression Header Protocol.
	  /// </summary>
	  ppCOMP,
	  /// <summary>
	  ///   IPv6 destination options.
	  /// </summary>
	  ppDSTOPTS,
	  /// <summary>
	  ///   Exterior Gateway Protocol.
	  /// </summary>
	  ppEGP,
	  /// <summary>
	  ///   Encapsulation Header.
	  /// </summary>
	  ppENCAP,
	  /// <summary>
	  ///   Encapsulating security payload.
	  /// </summary>
	  ppESP,
    /// <summary>
    ///   IPv6 fragmentation header.
    /// </summary>
    ppFRAGMENT,
	  /// <summary>
	  ///   General Routing Encapsulation.
	  /// </summary>
	  ppGRE,
	  /// <summary>
	  ///   IPv6 Hop-by-Hop options.
	  /// </summary>
	  ppHOPOPTS,
	  /// <summary>
	  ///   XNS IDP protocol.
	  /// </summary>
	  ppIDP,
	  /// <summary>
	  ///   IPIP tunnels (older KA9Q tunnels use 94).
	  /// </summary>
	  ppIPIP,
	  /// <summary>
	  ///   IPv6 header.
	  /// </summary>
	  ppIPV6,
	  /// <summary>
	  ///   Multicast Transport Protocol.
	  /// </summary>
	  ppMTP,
    /// <summary>
    ///   IPv6 no next header.
    /// </summary>
    ppNONE,
	  /// <summary>
	  ///   Protocol Independent Multicast.
	  /// </summary>
	  ppPIM,
	  /// <summary>
	  ///   PUP protocol.
	  /// </summary>
	  ppPUP,
	  /// <summary>
	  ///   Raw IP packets.
	  /// </summary>
	  ppRAW,
	  /// <summary>
	  ///   IPv6 routing header.
	  /// </summary>
	  ppROUTING,
	  /// <summary>
	  ///   Reservation Protocol.
	  /// </summary>
	  ppRSVP,
	  /// <summary>
	  ///   Stream Control Transmission Protocol.
	  /// </summary>
	  ppSCTP,
    /// <summary>
    ///   SO Transport Protocol Class 4.
    /// </summary>
    ppTP
    );


  /// <summary>
  ///   Represents an IP address.
  /// </summary>
  TNetworkAddress = record
    /// <summary>
    ///   The actual IP Address as a string for translation
    /// </summary>
    IPAddress: string;

    /// <summary>
    ///   The port number being used.
    /// </summary>
    Port: uint32;
  end;


  /// <summary>
  ///   Enumeration used to return the status of a socket operation.
  /// </summary>
  TSocketStatus =
    (
    /// <summary>
    ///   No error occurred.
    /// </summary>
    ssSuccess,
	  /// <summary>
	  ///   We don't know what wen't wrong!
	  /// </summary>
	  ssUnknown,
	  ssSocketClosed,
	  ssUnsupSockType,
	  ssUnsupProtocol,
    ssUnsupDomain,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSA_INVALID_HANDLE == Specified event object
	  ///   handle is invalid. An application attempts to use an event object, but
	  ///   the specified handle is not valid. Note that this error is returned by
	  ///   the operating system, so the error number may change in future
	  ///   releases of Windows.
	  /// </summary>
	  ssInvalidHandle,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSA_NOT_ENOUGH_MEMORY = Insufficient memory
	  ///   available. An application used a Windows Sockets function that
	  ///   directly maps to a Windows function. The Windows function is
	  ///   indicating a lack of required memory resources. Note that this error
	  ///   is returned by the operating system, so the error number may change in
	  ///   future releases of Windows.
	  /// </summary>
	  ssNotEnoughMemory,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSA_INVALID_PARAMETER == One or more
	  ///   parameters are invalid. An application used a Windows Sockets function
	  ///   which directly maps to a Windows function. The Windows function is
	  ///   indicating a problem with one or more parameters. Note that this error
	  ///   is returned by the operating system, so the error number may change in
	  ///   future releases of Windows.
	  /// </summary>
	  ssInvalidParameter,
    /// <summary>
    ///   Winsock Error, from MSDN: WSA_OPERATION_ABORTED == Overlapped
    ///   operation aborted. An overlapped operation was canceled due to the
    ///   closure of the socket, or the execution of the SIO_FLUSH command in
    ///   WSAIoctl. Note that this error is returned by the operating system,
    ///   so the error number may change in future releases of Windows.
    /// </summary>
    ssOperationAborted,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSA_IO_INCOMPLETE == Overlapped I/O event
	  ///   object not in signaled state. The application has tried to determine
	  ///   the status of an overlapped operation which is not yet completed.
	  ///   Applications that use WSAGetOverlappedResult (with the fWait flag set
	  ///   to FALSE) in a polling mode to determine when an overlapped operation
	  ///   has completed, get this error code until the operation is complete.
	  ///   Note that this error is returned by the operating system, so the error
	  ///   number may change in future releases of Windows.
	  /// </summary>
	  ssIOIncomplete,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSA_IO_PENDING == Overlapped operations will
	  ///   complete later. The application has initiated an overlapped operation
	  ///   that cannot be completed immediately. A completion indication will be
	  ///   given later when the operation has been completed. Note that this
	  ///   error is returned by the operating system, so the error number may
	  ///   change in future releases of Windows.
	  /// </summary>
	  ssIOPending,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAEINTR == Interrupted function call. A
	  ///   blocking operation was interrupted by a call to WSACancelBlockingCall.
	  /// </summary>
	  ssInterruptException,
    /// <summary>
    ///   Winsock Error, from MSDN: WSAEBADF == File handle is not valid. The
    ///   file handle supplied is not valid.
    /// </summary>
    ssBadFileException,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAEACCES == Permission denied. An attempt
	  ///   was made to access a socket in a way forbidden by its access
	  ///   permissions. An example is using a broadcast address for sendto
	  ///   without broadcast permission being set using setsockopt(SO_BROADCAST).
	  ///   Another possible reason for the WSAEACCES error is that when the bind
	  ///   function is called (on Windows NT 4.0 with SP4 and later), another
	  ///   application, service, or kernel mode driver is bound to the same
	  ///   address with exclusive access. Such exclusive access is a new feature
	  ///   of Windows NT 4.0 with SP4 and later, and is implemented by using the
	  ///   SO_EXCLUSIVEADDRUSE option.
	  /// </summary>
	  ssAccessDeniedException,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAEFAULT == Bad address. The system
	  ///   detected an invalid pointer address in attempting to use a pointer
	  ///   argument of a call. This error occurs if an application passes an
	  ///   invalid pointer value, or if the length of the buffer is too small.
	  ///   For instance, if the length of an argument, which is a sockaddr
	  ///   structure, is smaller than the sizeof(sockaddr).
	  /// </summary>
	  ssBadAddress,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAEINVAL == Invalid argument. Some invalid
	  ///   argument was supplied (for example, specifying an invalid level to the
	  ///   setsockopt function). In some instances, it also refers to the current
	  ///   state of the socket—for instance, calling accept on a socket that is
	  ///   not listening.
	  /// </summary>
	  ssInvalidArgument,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAEMFILE == Too many open files. Too many
	  ///   open sockets. Each implementation may have a maximum number of socket
	  ///   handles available, either globally, per process, or per thread.
	  /// </summary>
	  ssTooManySockets,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAEWOULDBLOCK == Resource temporarily
	  ///   unavailable. This error is returned from operations on nonblocking
	  ///   sockets that cannot be completed immediately, for example recv when no
	  ///   data is queued to be read from the socket. It is a nonfatal error, and
	  ///   the operation should be retried later. It is normal for WSAEWOULDBLOCK
	  ///   to be reported as the result from calling connect on a nonblocking
	  ///   SOCK_STREAM socket, since some time must elapse for the connection to
	  ///   be established.
	  /// </summary>
	  ssWouldBlock,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAEINPROGRESS == Operation now in progress.
	  ///   A blocking operation is currently executing. Windows Sockets only
	  ///   allows a single blocking operation—per- task or thread—to be
	  ///   outstanding, and if any other function call is made (whether or not it
	  ///   references that or any other socket) the function fails with the
	  ///   WSAEINPROGRESS error.
	  /// </summary>
	  ssInProgress,
    /// <summary>
    ///   Winsock Error, from MSDN: WSAEALREADY == Operation already in
    ///   progress. An operation was attempted on a nonblocking socket with an
    ///   operation already in progress—that is, calling connect a second time
    ///   on a nonblocking socket that is already connecting, or canceling an
    ///   asynchronous request (WSAAsyncGetXbyY) that has already been canceled
    ///   or completed.
    /// </summary>
    ssAlreadyInProgress,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAENOTSOCK == Socket operation on
	  ///   nonsocket. An operation was attempted on something that is not a
	  ///   socket. Either the socket handle parameter did not reference a valid
	  ///   socket, or for select, a member of an fd_set was not valid.
	  /// </summary>
	  ssNotSocket,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAEDESTADDRREQ == Destination address
	  ///   required. A required address was omitted from an operation on a
	  ///   socket. For example, this error is returned if sendto is called with
	  ///   the remote address of ADDR_ANY.
	  /// </summary>
	  ssDestAddrReq,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAEMSGSIZE == Message too long. A message
	  ///   sent on a datagram socket was larger than the internal message buffer
	  ///   or some other network limit, or the buffer used to receive a datagram
	  ///   was smaller than the datagram itself.
	  /// </summary>
	  ssMessageSize,
    /// <summary>
    ///   Winsock Error, from MSDN: WSAEPROTOTYPE == Protocol wrong type for
    ///   socket. A protocol was specified in the socket function call that
    ///   does not support the semantics of the socket type requested. For
    ///   example, the ARPA Internet UDP protocol cannot be specified with a
    ///   socket type of SOCK_STREAM.
    /// </summary>
    ssWrongProtocol,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAENOPROTOOPT == Bad protocol option. An
	  ///   unknown, invalid or unsupported option or level was specified in a
	  ///   getsockopt or setsockopt call.
	  /// </summary>
	  ssBadProtocolOption,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAEPFNOSUPPORT == Protocol family not
	  ///   supported. The protocol family has not been configured into the system
	  ///   or no implementation for it exists. This message has a slightly
	  ///   different meaning from WSAEAFNOSUPPORT. However, it is interchangeable
	  ///   in most cases, and all Windows Sockets functions that return one of
	  ///   these messages also specify WSAEAFNOSUPPORT.
	  /// </summary>
	  ssProtocolNotSupported,
    /// <summary>
    ///   Winsock Error, from MSDN: WSAESOCKTNOSUPPORT == Socket type not
    ///   supported. The support for the specified socket type does not exist
    ///   in this address family. For example, the optional type SOCK_RAW might
    ///   be selected in a socket call, and the implementation does not support
    ///   SOCK_RAW sockets at all.
    /// </summary>
    ssSocketTypeNotSuppored,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAEOPNOTSUPP == Operation not supported.
	  ///   The attempted operation is not supported for the type of object
	  ///   referenced. Usually this occurs when a socket descriptor to a socket
	  ///   that cannot support this operation is trying to accept a connection on
	  ///   a datagram socket.
	  /// </summary>
	  ssOperationNotSupported,
	  ssProtocolNotSupportedE,
    /// <summary>
    ///   Winsock Error, from MSDN: WSAEAFNOSUPPORT == Address family not
    ///   supported by protocol family. An address incompatible with the
    ///   requested protocol was used. All sockets are created with an
    ///   associated address family (that is, AF_INET for Internet Protocols)
    ///   and a generic protocol type (that is, SOCK_STREAM). This error is
    ///   returned if an incorrect protocol is explicitly requested in the
    ///   socket call, or if an address of the wrong family is used for a
    ///   socket, for example, in sendto.
    /// </summary>
    ssDomainNotSupprted,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAEADDRINUSE == Address already in use.
	  ///   Typically, only one usage of each socket address (protocol/IP
	  ///   address/port) is permitted. This error occurs if an application
	  ///   attempts to bind a socket to an IP address/port that has already been
	  ///   used for an existing socket, or a socket that was not closed properly,
	  ///   or one that is still in the process of closing. For server
	  ///   applications that need to bind multiple sockets to the same port
	  ///   number, consider using setsockopt (SO_REUSEADDR). Client applications
	  ///   usually need not call bind at all—connect chooses an unused port
	  ///   automatically. When bind is called with a wildcard address (involving
	  ///   ADDR_ANY), a WSAEADDRINUSE error could be delayed until the specific
	  ///   address is committed. This could happen with a call to another
	  ///   function later, including connect, listen, WSAConnect, or WSAJoinLeaf.
	  /// </summary>
	  ssAddressInUse,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAEADDRNOTAVAIL = Cannot assign requested
	  ///   address. The requested address is not valid in its context. This
	  ///   normally results from an attempt to bind to an address that is not
	  ///   valid for the local computer. This can also result from connect,
	  ///   sendto, WSAConnect, WSAJoinLeaf, or WSASendTo when the remote address
	  ///   or port is not valid for a remote computer (for example, address or
	  ///   port 0).
	  /// </summary>
	  ssAddressNotAvail,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAENETDOWN == Network is down. A socket
	  ///   operation encountered a dead network. This could indicate a serious
	  ///   failure of the network system (that is, the protocol stack that the
	  ///   Windows Sockets DLL runs over), the network interface, or the local
	  ///   network itself.
	  /// </summary>
	  ssNetworkDown,
    /// <summary>
    ///   Winsock Error, from MSDN: WSAENETUNREACH == Network is unreachable. A
    ///   socket operation was attempted to an unreachable network. This
    ///   usually means the local software knows no route to reach the remote
    ///   host.
    /// </summary>
    ssNetworkUnreachable,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAENETRESET == Network dropped connection
	  ///   on reset. The connection has been broken due to keep-alive activity
	  ///   detecting a failure while the operation was in progress. It can also
	  ///   be returned by setsockopt if an attempt is made to set SO_KEEPALIVE on
	  ///   a connection that has already failed.
	  /// </summary>
	  ssConnectionDroppedOnReset,
    /// <summary>
    ///   Winsock Error, from MSDN: WSAECONNABORTED == Software caused
    ///   connection abort. An established connection was aborted by the
    ///   software in your host computer, possibly due to a data transmission
    ///   time-out or protocol error.
    /// </summary>
    ssSoftwareConnectionAbord,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAECONNRESET == Connection reset by peer.
	  ///   An existing connection was forcibly closed by the remote host. This
	  ///   normally results if the peer application on the remote host is
	  ///   suddenly stopped, the host is rebooted, the host or remote network
	  ///   interface is disabled, or the remote host uses a hard close (see
	  ///   setsockopt for more information on the SO_LINGER option on the remote
	  ///   socket). This error may also result if a connection was broken due to
	  ///   keep-alive activity detecting a failure while one or more operations
	  ///   are in progress. Operations that were in progress fail with
	  ///   WSAENETRESET. Subsequent operations fail with WSAECONNRESET.
	  /// </summary>
	  ssConnectionResetByPeer,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAENOBUFS == No buffer space available. An
	  ///   operation on a socket could not be performed because the system lacked
	  ///   sufficient buffer space or because a queue was full.
	  /// </summary>
	  ssNoBufferSpace,
    /// <summary>
    ///   Winsock Error, from MSDN: WSAEISCONN == Socket is already connected.
    ///   A connect request was made on an already-connected socket. Some
    ///   implementations also return this error if sendto is called on a
    ///   connected SOCK_DGRAM socket (for SOCK_STREAM sockets, the to
    ///   parameter in sendto is ignored) although other implementations treat
    ///   this as a legal occurrence.
    /// </summary>
    ssSocketAlreadyConnected,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAENOTCONN == Socket is not connected. A
	  ///   request to send or receive data was disallowed because the socket is
	  ///   not connected and (when sending on a datagram socket using sendto) no
	  ///   address was supplied. Any other type of operation might also return
	  ///   this error—for example, setsockopt setting SO_KEEPALIVE if the
	  ///   connection has been reset.
	  /// </summary>
	  ssSocketNotConnected,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAESHUTDOWN == Cannot send after socket
	  ///   shutdown. A request to send or receive data was disallowed because the
	  ///   socket had already been shut down in that direction with a previous
	  ///   shutdown call. By calling shutdown a partial close of a socket is
	  ///   requested, which is a signal that sending or receiving, or both have
	  ///   been discontinued.
	  /// </summary>
	  ssSocketIsShutdown,
    /// <summary>
    ///   Winsock Error, from MSDN: WSAETOOMANYREFS == Too many references. Too
    ///   many references to some kernel object.
    /// </summary>
    ssTooManyReferences,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAETIMEDOUT == Connection timed out. A
	  ///   connection attempt failed because the connected party did not properly
	  ///   respond after a period of time, or the established connection failed
	  ///   because the connected host has failed to respond.
	  /// </summary>
	  ssConnectionTimeout,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAECONNREFUSED == Connection refused. No
	  ///   connection could be made because the target computer actively refused
	  ///   it. This usually results from trying to connect to a service that is
	  ///   inactive on the foreign host—that is, one with no server application
	  ///   running.
	  /// </summary>
	  ssConnectionRefused,
    /// <summary>
    ///   Winsock Error, from MSDN: WSAELOOP == Cannot translate name. Cannot
    ///   translate a name.
    /// </summary>
    ssCannotTranslateName,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAENAMETOOLONG == Name too long. A name
	  ///   component or a name was too long.
	  /// </summary>
	  ssNameTooLong,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAEHOSTDOWN == Host is down. A socket
	  ///   operation failed because the destination host is down. A socket
	  ///   operation encountered a dead host. Networking activity on the local
	  ///   host has not been initiated. These conditions are more likely to be
	  ///   indicated by the error WSAETIMEDOUT.
	  /// </summary>
	  ssHostIsDown,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAEHOSTUNREACH == No route to host. A
	  ///   socket operation was attempted to an unreachable host. See
	  ///   WSAENETUNREACH.
	  /// </summary>
	  ssHostUnreachable,
    /// <summary>
    ///   Winsock Error, from MSDN: WSAENOTEMPTY == Directory not empty. Cannot
    ///   remove a directory that is not empty.
    /// </summary>
    ssDirectoryNotEmpty,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAEPROCLIM == Too many processes. A Windows
	  ///   Sockets implementation may have a limit on the number of applications
	  ///   that can use it simultaneously. WSAStartup may fail with this error if
	  ///   the limit has been reached.
	  /// </summary>
	  ssTooManyProcesses,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAEUSERS == User quota exceeded. Ran out of
	  ///   user quota.
	  /// </summary>
	  ssUserQuotaExceeded,
    /// <summary>
    ///   Winsock Error, from MSDN: WSAEDQUOT == Disk quota exceeded. Ran out
    ///   of disk quota.
    /// </summary>
    ssDiskQuotaExceeded,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAESTALE == Stale file handle reference.
	  ///   The file handle reference is no longer available.
	  /// </summary>
	  ssStaleFileHandle,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAEREMOTE == 10071 Item is remote. The item
	  ///   is not available locally.
	  /// </summary>
	  ssItemIsRemote,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSASYSNOTREADY == Network subsystem is
	  ///   unavailable. This error is returned by WSAStartup if the Windows
	  ///   Sockets implementation cannot function at this time because the
	  ///   underlying system it uses to provide network services is currently
	  ///   unavailable. Users should check: That the appropriate Windows Sockets
	  ///   DLL file is in the current path. That they are not trying to use more
	  ///   than one Windows Sockets implementation simultaneously. If there is
	  ///   more than one Winsock DLL on your system, be sure the first one in the
	  ///   path is appropriate for the network subsystem currently loaded. The
	  ///   Windows Sockets implementation documentation to be sure all necessary
	  ///   components are currently installed and configured correctly.
	  /// </summary>
	  ssSubSysNotReady,
    /// <summary>
    ///   Winsock Error, from MSDN: WSAVERNOTSUPPORTED == Winsock.dll version
    ///   out of range. The current Windows Sockets implementation does not
    ///   support the Windows Sockets specification version requested by the
    ///   application. Check that no old Windows Sockets DLL files are being
    ///   accessed.
    /// </summary>
    ssUnsupportedVersion,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSANOTINITIALISED == Successful WSAStartup
	  ///   not yet performed. Either the application has not called WSAStartup or
	  ///   WSAStartup failed. The application may be accessing a socket that the
	  ///   current active task does not own (that is, trying to share a socket
	  ///   between tasks), or WSACleanup has been called too many times.
	  /// </summary>
	  ssNotInitialized,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAEDISCON == Graceful shutdown in progress.
	  ///   Returned by WSARecv and WSARecvFrom to indicate that the remote party
	  ///   has initiated a graceful shutdown sequence.
	  /// </summary>
	  ssDisconnecting,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAENOMORE == No more results. No more
	  ///   results can be returned by the WSALookupServiceNext function.
	  /// </summary>
	  ssNoMoreResults,
    /// <summary>
    ///   Winsock Error, from MSDN: WSAECANCELLED == Call has been canceled. A
    ///   call to the WSALookupServiceEnd function was made while this call was
    ///   still processing. The call has been canceled.
    /// </summary>
    ssCallCancelled,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAEINVALIDPROCTABLE == Procedure call table
	  ///   is invalid. The service provider procedure call table is invalid. A
	  ///   service provider returned a bogus procedure table to Ws2_32.dll. This
	  ///   is usually caused by one or more of the function pointers being NULL.
	  /// </summary>
	  ssInvalidProcTable,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAEINVALIDPROVIDER == Service provider is
	  ///   invalid. The requested service provider is invalid. This error is
	  ///   returned by the WSCGetProviderInfo and WSCGetProviderInfo32 functions
	  ///   if the protocol entry specified could not be found. This error is also
	  ///   returned if the service provider returned a version number other than
	  ///   2.0.
	  /// </summary>
	  ssInvalidServiceProvider,
    /// <summary>
    ///   Winsock Error, from MSDN: WSAEPROVIDERFAILEDINIT == Service provider
    ///   failed to initialize. The requested service provider could not be
    ///   loaded or initialized. This error is returned if either a service
    ///   provider's DLL could not be loaded (LoadLibrary failed) or the
    ///   provider's WSPStartup or NSPStartup function failed.
    /// </summary>
    ssProvierFailedInit,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSASYSCALLFAILURE == System call failure. A
	  ///   system call that should never fail has failed. This is a generic error
	  ///   code, returned under various conditions. Returned when a system call
	  ///   that should never fail does fail. For example, if a call to
	  ///   WaitForMultipleEvents fails or one of the registry functions fails
	  ///   trying to manipulate the protocol/namespace catalogs. Returned when a
	  ///   provider does not return SUCCESS and does not provide an extended
	  ///   error code. Can indicate a service provider implementation error.
	  /// </summary>
	  ssSystemCallFailure,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSASERVICE_NOT_FOUND == Service not found.
	  ///   No such service is known. The service cannot be found in the specified
	  ///   name space.
	  /// </summary>
	  ssServiceNotFound,
    /// <summary>
    ///   Winsock Error, from MSDN: WSATYPE_NOT_FOUND == Class type not found.
    ///   The specified class was not found.
    /// </summary>
    ssTypeNotFound,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSA_E_NO_MORE == No more results. No more
	  ///   results can be returned by the WSALookupServiceNext function.
	  /// </summary>
	  ssNoMoreResultsE,
	  ssCallCancelledE,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSAEREFUSED == Database query was refused. A
	  ///   database query failed because it was actively refused.
	  /// </summary>
	  ssQueryRefused,
    /// <summary>
    ///   Winsock Error, from MSDN: WSAHOST_NOT_FOUND == Host not found. No
    ///   such host is known. The name is not an official host name or alias,
    ///   or it cannot be found in the database(s) being queried. This error
    ///   may also be returned for protocol and service queries, and means that
    ///   the specified name could not be found in the relevant database.
    /// </summary>
    ssHostNotFound,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSATRY_AGAIN == Nonauthoritative host not
	  ///   found. This is usually a temporary error during host name resolution
	  ///   and means that the local server did not receive a response from an
	  ///   authoritative server. A retry at some time later may be successful.
	  /// </summary>
	  ssNonAuthorativeHost,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSANO_RECOVERY == This is a nonrecoverable
	  ///   error. This indicates that some sort of nonrecoverable error occurred
	  ///   during a database lookup. This may be because the database files (for
	  ///   example, BSD-compatible HOSTS, SERVICES, or PROTOCOLS files) could not
	  ///   be found, or a DNS request was returned by the server with a severe
	  ///   error.
	  /// </summary>
	  ssNoRecover,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSANO_DATA ==Valid name, no data record of
	  ///   requested type. The requested name is valid and was found in the
	  ///   database, but it does not have the correct associated data being
	  ///   resolved for. The usual example for this is a host name-to-address
	  ///   translation attempt (using gethostbyname or WSAAsyncGetHostByName)
	  ///   which uses the DNS (Domain Name Server). An MX record is returned but
	  ///   no A record—indicating the host itself exists, but is not directly
	  ///   reachable.
	  /// </summary>
	  ssNoData,
    /// <summary>
    ///   Winsock Error, from MSDN: WSA_QOS_RECEIVERS == QoS receivers. At
    ///   least one QoS reserve has arrived. <br />
    /// </summary>
    ssQoSReceivers,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSA_QOS_SENDERS == QoS senders. At least one
	  ///   QoS send path has arrived.
	  /// </summary>
	  ssQoSSenders,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSA_QOS_NO_SENDERS == No QoS senders. There
	  ///   are no QoS senders.
	  /// </summary>
	  ssNoQoSSenders,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSA_QOS_NO_RECEIVERS == QoS no receivers.
	  ///   There are no QoS receivers.
	  /// </summary>
	  ssQoSNoReceivers,
    /// <summary>
    ///   Winsock Error, from MSDN: WSA_QOS_REQUEST_CONFIRMED == QoS request
    ///   confirmed. The QoS reserve request has been confirmed.
    /// </summary>
    ssQoSRequestConfirmed,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSA_QOS_ADMISSION_FAILURE == QoS admission
	  ///   error. A QoS error occurred due to lack of resources.
	  /// </summary>
	  ssQoSAdmissionFailure,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSA_QOS_POLICY_FAILURE == QoS policy
	  ///   failure. The QoS request was rejected because the policy system
	  ///   couldn't allocate the requested resource within the existing policy.
	  /// </summary>
	  ssQoSPolicyFailure,
    /// <summary>
    ///   Winsock Error, from MSDN: WSA_QOS_BAD_STYLE == QoS bad style. An
    ///   unknown or conflicting QoS style was encountered.
    /// </summary>
    ssQoSBadStyle,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSA_QOS_BAD_OBJECT == QoS bad object. A
	  ///   problem was encountered with some part of the filterspec or the
	  ///   provider-specific buffer in general.
	  /// </summary>
	  ssQoSBadObject,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSA_QOS_TRAFFIC_CTRL_ERROR == QoS traffic
	  ///   control error. An error with the underlying traffic control (TC) API
	  ///   as the generic QoS request was converted for local enforcement by the
	  ///   TC API. This could be due to an out of memory error or to an internal
	  ///   QoS provider error.
	  /// </summary>
	  ssQoSTrafficCtrlError,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSA_QOS_GENERIC_ERROR == QoS generic error.
	  ///   A general QoS error.
	  /// </summary>
	  ssQoSGenericError,
    /// <summary>
    ///   Winsock Error, from MSDN: WSA_QOS_ESERVICETYPE == QoS service type
    ///   error. An invalid or unrecognized service type was found in the QoS
    ///   flowspec.
    /// </summary>
    ssQoSServiceTypeError,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSA_QOS_EFLOWSPEC == QoS flowspec error. An
	  ///   invalid or inconsistent flowspec was found in the QOS structure.
	  /// </summary>
	  ssQoSEFlowSpecError,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSA_QOS_EPROVSPECBUF == Invalid QoS provider
	  ///   buffer. An invalid QoS provider-specific buffer.
	  /// </summary>
	  ssQoSProviderBufferInvalid,
    /// <summary>
    ///   Winsock Error, from MSDN: WSA_QOS_EFILTERSTYLE == Invalid QoS filter
    ///   style. An invalid QoS filter style was used. <br />
    /// </summary>
    ssQoSInvalidFilterStyle,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSA_QOS_EFILTERTYPE == Invalid QoS filter
	  ///   type. An invalid QoS filter type was used.
	  /// </summary>
	  ssQosInvalidFilterType,
    /// <summary>
    ///   Winsock Error, from MSDN: WSA_QOS_EFILTERCOUNT == Incorrect QoS
    ///   filter count. An incorrect number of QoS FILTERSPECs were specified
    ///   in the FLOWDESCRIPTOR.
    /// </summary>
    ssQoSIncorrectFilterCount,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSA_QOS_EOBJLENGTH == Invalid QoS object
	  ///   length. An object with an invalid ObjectLength field was specified in
	  ///   the QoS provider-specific buffer.
	  /// </summary>
	  ssQoSInvalidObjectLenght,
    /// <summary>
    ///   Winsock Error, from MSDN: WSA_QOS_EFLOWCOUNT == Incorrect QoS flow
    ///   count. An incorrect number of flow descriptors was specified in the
    ///   QoS structure.
    /// </summary>
    ssQoSIncorrectFlowCount,
	  /// <summary>
	  ///   sWinsock Error, from MSDN: WSA_QOS_EUNKOWNPSOBJ == Unrecognized QoS
	  ///   object. An unrecognized object was found in the QoS provider-specific
	  ///   buffer.
	  /// </summary>
	  ssQoSUnknownObject,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSA_QOS_EPOLICYOBJ == Invalid QoS policy
	  ///   object. An invalid policy object was found in the QoS
	  ///   provider-specific buffer.
	  /// </summary>
	  ssQoSInvalidPolicyObject,
    /// <summary>
    ///   Winsock Error, from MSDN: WSA_QOS_EFLOWDESC == Invalid QoS flow
    ///   descriptor. An invalid QoS flow descriptor was found in the flow
    ///   descriptor list.
    /// </summary>
    ssQoSInvalidFlowDescriptor,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSA_QOS_EPSFLOWSPEC == Invalid QoS
	  ///   provider-specific flowspec. An invalid or inconsistent flowspec was
	  ///   found in the QoS provider-specific buffer.
	  /// </summary>
	  ssQoSInvalidFlowProviderSpec,
    /// <summary>
    ///   Winsock Error, from MSDN: WSA_QOS_EPSFILTERSPEC == Invalid QoS
    ///   provider-specific filterspec. An invalid FILTERSPEC was found in the
    ///   QoS provider-specific buffer.
    /// </summary>
    ssQoSInvalidProviderFilterSpec,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSA_QOS_ESDMODEOBJ == Invalid QoS shape
	  ///   discard mode object. An invalid shape discard mode object was found in
	  ///   the QoS provider-specific buffer.
	  /// </summary>
	  ssQoSInvalidShapeDiscardModeObject,
    /// <summary>
    ///   Winsock Error, from MSDN: WSA_QOS_ESHAPERATEOBJ == Invalid QoS
    ///   shaping rate object. An invalid shaping rate object was found in the
    ///   QoS provider-specific buffer.
    /// </summary>
    ssQoSInvalidShapeRatingObject,
	  /// <summary>
	  ///   Winsock Error, from MSDN: WSA_QOS_RESERVED_PETYPE == Reserved policy
	  ///   QoS element type. A reserved policy element was found in the QoS
	  ///   provider-specific buffer.
	  /// </summary>
	  ssQoSReservedPolicyElememtType
    );


  /// <summary>
  ///   Used to specify options to the Shutdown() method, which is able to
  ///   shutdown sending data, receiving data, or both. This is usually called
  ///   before Close() when ending a socket.
  /// </summary>
  TShutdownOptions = (
    /// <summary>
    ///   soSending Shutdown sending.
    ///  </summary>
    soSending,
    /// <summary>
    ///   soReceiving Shutdown receiving.
    ///  </summary>
    soReceiving,
    /// <summary>
    ///   soBoth Shutdown both sending and receiving.
    ///  </summary>
    soBoth
  );


  /// <summary>
  ///   Stores information regarding a socket.
  /// </summary>
  TSocket = record
    Handle: TSocketHandle;
    Domain: TSocketDomain;
    Kind: TSocketKind;
    Protocol: TPacketProtocol;
  end;

type

  /// <summary>
  ///   IdeSocketUtils is an interface which behaves as a namespace for the
  ///   methods of the sockets library.
  /// </summary>
  ISockets = interface
    ['{66CF0983-321F-4E09-A2F4-BA0FA0E53A7E}']
    function CreateSocket( var Socket: TSocket ): TSocketStatus;
    function Shutdown( Socket: TSocket; Opts: TShutdownOptions ): TSocketStatus;
    function Bind( Socket: TSocket; NetAddress: TNetworkAddress ): TSocketStatus;
    function Listen( Socket: TSocket ): TSocketStatus;
    function Accept( Socket: TSocket; var NewSocket: TSocket; var NewNetAddress: TNetworkAddress ): TSocketStatus;
    function Connect( Socket: TSocket; NetAddress: TNetworkAddress ): TSocketStatus;
    function Close( Socket: TSocket ): TSocketStatus;
    function Send( Socket: TSocket; Data: pointer; Size: int32; var Sent: int32 ): TSocketStatus;
    function Recv( Socket: TSocket; Data: pointer; MaxSize: int32; var Recvd: int32 ): TSocketStatus;
    function Blocking( Socket: TSocket; IsBlocking: boolean ): TSocketStatus;
    function DataWaiting( Socket: TSocket ): int32;
  end;

implementation
uses
  darkLog.log.standard;

initialization
  Log.Register(EAddressTranslation,'Address translation failed. Domain: (%domain%). Address: (%address%)');
  Log.Register(ESocketResourceError,'Failed to dispose of socket. (%additional%))');
  Log.Register(EShutdownThread,'Failed to shutdown socket.');
  Log.Register(EAcceptFailed,'Failed to accept client connection.');

end.




