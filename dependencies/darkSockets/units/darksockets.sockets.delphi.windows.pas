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
unit darksockets.sockets.delphi.windows;

interface
{$ifndef fpc}
{$ifdef MSWINDOWS}
uses
  darksockets.sockets;

type
  TTargetSockets = class( TInterfacedObject, ISockets )
  private //- ISockets
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
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

{$endif}
{$endif}
implementation
{$ifndef fpc}
{$ifdef MSWINDOWS}
uses
  darkIO.buffers;

const
  cDescriptionLen = 256;
  cSysStatusLen  = 128;

const
  cWinsockDLL = 'ws2_32.dll';

{==============================================================================}
{ WINSOCK2 Data Types                                                          }
{==============================================================================}
type
  {#
    @Field( wVersion From MSDN: The version of the Windows Sockets
                     specification that the Ws2_32.dll expects the caller
                     to use. The high-order byte specifies the minor version
                     number; the low-order byte specifies the major version
                     number. )
    @Field( wHighVersion From MSDN: The highest version of the Windows
                         Sockets specification that the Ws2_32.dll can support.
                         The high-order byte specifies the minor version number;
                         the low-order byte specifies the major version number.
                         This is the same value as the wVersion member when the
                         version requested in the wVersionRequested parameter
                         passed to the WSAStartup function is the highest
                         version of the Windows Sockets specification that
                         the Ws2_32.dll can support. )
    @Field( szDescription From MSDN: A NULL-terminated ASCII string into which
                          the Ws2_32.dll copies a description of the Windows
                          Sockets implementation. The text (up to 256
                          characters in length) can contain any characters
                          except control and formatting characters. The most
                          likely use that an application would have for this
                          member is to display it (possibly truncated) in a
                          status message. )
    @Field( szSystemStatus From MSDN: A NULL-terminated ASCII string into which
                           the Ws2_32.dll copies relevant status or
                           configuration information. The Ws2_32.dll should
                           use this parameter only if the information might be
                           useful to the user or support staff. This member
                           should not be considered as an extension of the
                           szDescription parameter. )
    @Field( iMaxSockets From MSDN: The maximum number of sockets that may be
                        opened. This member should be ignored for Windows
                        Sockets version 2 and later. The iMaxSockets member
                        is retained for compatibility with Windows Sockets
                        specification 1.1, but should not be used when
                        developing new applications. No single value can be
                        appropriate for all underlying service providers.
                        The architecture of Windows Sockets changed in
                        version 2 to support multiple providers, and the
                        WSADATA structure no longer applies to a
                        single vendor's stack. )
    @Field( iMaxUpdDg From MSDN: The maximum datagram message size. This
                      member is ignored for Windows Sockets version 2 and
                      later. The iMaxUdpDg member is retained for
                      compatibility with Windows Sockets
                      specification 1.1, but should not be used when
                      developing new applications. The architecture of
                      Windows Sockets changed in version 2 to support
                      multiple providers, and the WSADATA structure no
                      longer applies to a single vendor's stack. For the
                      actual maximum message size specific to a particular
                      Windows Sockets service provider and socket type,
                      applications should use getsockopt to retrieve the
                      value of option SO_MAX_MSG_SIZE after a socket has
                      been created. )
    @Field( lpVendorInfo From MSDN: A pointer to vendor-specific information.
                         This member should be ignored for Windows Sockets
                         version 2 and later. The lpVendorInfo member is
                         retained for compatibility with Windows Sockets
                         specification 1.1. The architecture of Windows
                         Sockets changed in version 2 to support multiple
                         providers, and the WSADATA structure no longer applies
                         to a single vendor's stack. Applications needing to
                         access vendor-specific configuration information
                         should use getsockopt to retrieve the value of
                         option PVD_CONFIG for vendor-specific information. )
  }
  TWSAData = record
    wVersion: uint16;
    wHighVersoin: uint16;
    szDescription: array[0..cDescriptionLen] of uint8;
    szSystemStatus: array[0..cSysStatusLen] of uint8;
    iMaxSockets: uint16;
    iMaxUdpDg: uint16;
    lpVendorInfo: pansichar;
  end;
  pTWSAData = ^TWSAData;

  // types required for address translation...
  TInAddr6 = record
    case integer of
      0: (S6_addr: packed array [0..15] of uint8);
      1: (u6_addr8: packed array [0..15] of uint8);
      2: (u6_addr16: packed array [0..7] of uint16);
      3: (u6_addr32: packed array [0..3] of int32);
  end;

  Tsockaddr_in6 = record
          sin6_family:   uint16;
          sin6_port:     uint16;
          sin6_flowinfo: uint16;
          sin6_addr:     TInAddr6;
          sin6_scope_id: cardinal;
  end;

  TSockAddr = record
    sa_family: uint16;
    sa_data: array [0..13] of AnsiChar;
  end;
  pTSockAddr = ^TSockAddr;

  TSunB = record
    s_b1, s_b2, s_b3, s_b4: uint8;
  end;

  TSunC = record
    s_c1, s_c2, s_c3, s_c4: AnsiChar;
  end;

  TSunW = record
    s_w1, s_w2: uint16;
  end;

  Tin_addr = record
    case Integer of
      0: (S_un_b: TSunB);
      1: (S_un_c: TSunC);
      2: (S_un_w: TSunW);
      3: (S_addr: cardinal);
  end;

  Tsockaddr_in = record
    sin_family: int16;
    sin_port: uint16;
    sin_addr: Tin_addr;
    sin_zero: array [0..7] of AnsiChar;
  end;

  pint32 = ^int32;
  puint32 = ^uint32;

  // Used to type-cast the socket handle
  SocketOf = ^NativeUInt;

var
  wsdata: TWSAData;

{==============================================================================}
{ WINSOCK2 Constants                                                           }
{==============================================================================}

const
  // Winsock constants ..
  {Socket Types}
  cSOCK_STREAM    = 1; { From MSDN - A socket type that provides sequenced, reliable, two-way,
                         connection-based byte streams with an OOB data transmission mechanism.
                         This socket type uses the Transmission Control Protocol (TCP) for the
                         Internet address family (AF_INET or AF_INET6). }
  cSOCK_DGRAM     = 2; { From MSDN - A socket type that supports datagrams, which are connectionless,
                         unreliable buffers of a fixed (typically small) maximum length.
                         This socket type uses the User Datagram Protocol (UDP) for the Internet
                         address family (AF_INET or AF_INET6). }
  cSOCK_RAW       = 3; { From MSDN - A socket type that provides a raw socket that allows an application
                         to manipulate the next upper-layer protocol header. To manipulate the IPv4 header,
                         the IP_HDRINCL socket option must be set on the socket. To manipulate the IPv6
                         header, the IPV6_HDRINCL socket option must be set on the socket. }
  cSOCK_RDM       = 4; { From MSDN - A socket type that provides a reliable message datagram.
                         An example of this type is the Pragmatic General Multicast (PGM) multicast
                         protocol implementation in Windows, often referred to as reliable multicast
                         programming. This type value is only supported if the Reliable Multicast
                         Protocol is installed. }
  cSOCK_SEQPACKET = 5; { From MSDN - A socket type that provides a pseudo-stream packet based
                         on datagrams.) }

  { IP Protocols }
  cIPPROTO_UNSPEC  = 0;   { Unspecified, let the system handle it. }
  cIPPROTO_ICMP    = 1;   { From MSDN - The Internet Control Message Protocol (ICMP). This is a possible
                            value when the af parameter is AF_UNSPEC, AF_INET, or AF_INET6 and the type
                            parameter is SOCK_RAW or unspecified. This protocol value is supported on
                            Windows XP and later. }
  cIPPROTO_IGMP    = 2;   { From MSDN - The Internet Group Management Protocol (IGMP). This is a possible
                            value when the af parameter is AF_UNSPEC, AF_INET, or AF_INET6 and the type
                            parameter is SOCK_RAW or unspecified. This protocol value is supported on
                            Windows XP and later. }
  cBTHPROTO_RFCOMM = 3;   { From MSDN - The Bluetooth Radio Frequency Communications (Bluetooth RFCOMM)
                            protocol. This is a possible value when the af parameter is AF_BTH and the
                            type parameter is SOCK_STREAM. This protocol value is supported on
                            Windows XP with SP2 or later. }
  cIPPROTO_TCP     = 6;   { From MSDN - The Transmission Control Protocol (TCP). This is a possible value
                            when the af parameter is AF_INET or AF_INET6 and the type parameter is
                            SOCK_STREAM. }
  cIPPROTO_UDP     = 17;  { From MSDN - The User Datagram Protocol (UDP). This is a possible value when
                            the af parameter is AF_INET or AF_INET6 and the type parameter is SOCK_DGRAM. }
  cIPPROTO_ICMPV6  = 58;  { From MSDN - The Internet Control Message Protocol Version 6 (ICMPv6).
                            This is a possible value when the af parameter is AF_UNSPEC, AF_INET, or
                            AF_INET6 and the type parameter is SOCK_RAW or unspecified. This protocol
                            value is supported on Windows XP and later. }
  cIPPROTO_RM      = 113; { From MSDN - The PGM protocol for reliable multicast. This is a possible
                            value when the af parameter is AF_INET and the type parameter is SOCK_RDM.
                            On the Windows SDK released for Windows Vista and later, this protocol is
                            also called IPPROTO_PGM. This protocol value is only supported
                          }

  {Address family (domain) constants}
  cAF_UNSPEC    = 0;  { From MSDN - The address family is unspecified. }
  cAF_INET      = 2;  { From MSDN - The Internet Protocol version 4 (IPv4) address family. }
  cAF_IPX       = 6;  { From MSDN - The IPX/SPX address family. This address family is only
                        supported if the NWLink IPX/SPX NetBIOS Compatible Transport protocol is
                        installed. This address family is not supported on Windows Vista and later. }
  cAF_APPLETALK = 16; { From MSDN - The AppleTalk address family. This address family is only
                        supported if the AppleTalk protocol is installed. This address family is not
                        supported on Windows Vista and later. }
  cAF_NETBIOS   = 17; { From MSDN - The NetBIOS address family. This address family is only supported
                        if the Windows Sockets provider for NetBIOS is installed. The Windows Sockets
                        provider for NetBIOS is supported on 32-bit versions of Windows. This provider
                        is installed by default on 32-bit versions of Windows. The Windows Sockets
                        provider for NetBIOS is not supported on 64-bit versions of windows
                        including Windows 7, Windows Server 2008, Windows Vista,
                        Windows Server 2003, or Windows XP. The Windows Sockets provider for
                        NetBIOS only supports sockets where the type parameter is set to SOCK_DGRAM.
                        The Windows Sockets provider for NetBIOS is not directly related to the
                        NetBIOS programming interface. The NetBIOS programming interface is not
                        supported on Windows Vista, Windows Server 2008, and later. }
  cAF_INET6     = 23; { From MSDN - The Internet Protocol version 6 (IPv6) address family. }
  cAF_IRDA      = 26; { From MSDN - The Infrared Data Association (IrDA) address family.
                        This address family is only supported if the computer has an infrared
                        port and driver installed. }
  cAF_BTH       = 32; { From MSDN - The Bluetooth address family. This address family is supported
                        on Windows XP with SP2 or later if the computer has a Bluetooth adapter
                        and driver installed. }

  { Error code constants for winsoc. (see TSocketStatus comments for documentation. }
  cWSA_INVALID_HANDLE         = 6;
  cWSA_NOT_ENOUGH_MEMORY      = 8;
  cWSA_INVALID_PARAMETER      = 87;
  cWSA_OPERATION_ABORTED      = 995;
  cWSA_IO_INCOMPLETE          = 996;
  cWSA_IO_PENDING             = 997;
  cWSAEINTR                   = 10004;
  cWSAEBADF                   = 10009;
  cWSAEACCES                  = 10013;
  cWSAEFAULT                  = 10014;
  cWSAEINVAL                  = 10022;
  cWSAEMFILE                  = 10024;
  cWSAEWOULDBLOCK             = 10035;
  cWSAEINPROGRESS             = 10036;
  cWSAEALREADY                = 10037;
  cWSAENOTSOCK                = 10038;
  cWSAEDESTADDRREQ            = 10039;
  cWSAEMSGSIZE                = 10040;
  cWSAEPROTOTYPE              = 10041;
  cWSAENOPROTOOPT             = 10042;
  cWSAEPROTONOSUPPORT         = 10043;
  cWSAESOCKTNOSUPPORT         = 10044;
  cWSAEOPNOTSUPP              = 10045;
  cWSAEPFNOSUPPORT            = 10046;
  cWSAEAFNOSUPPORT            = 10047;
  cWSAEADDRINUSE              = 10048;
  cWSAEADDRNOTAVAIL           = 10049;
  cWSAENETDOWN                = 10050;
  cWSAENETUNREACH             = 10051;
  cWSAENETRESET               = 10052;
  cWSAECONNABORTED            = 10053;
  cWSAECONNRESET              = 10054;
  cWSAENOBUFS                 = 10055;
  cWSAEISCONN                 = 10056;
  cWSAENOTCONN                = 10057;
  cWSAESHUTDOWN               = 10058;
  cWSAETOOMANYREFS            = 10059;
  cWSAETIMEDOUT               = 10060;
  cWSAECONNREFUSED            = 10061;
  cWSAELOOP                   = 10062;
  cWSAENAMETOOLONG            = 10063;
  cWSAEHOSTDOWN               = 10064;
  cWSAEHOSTUNREACH            = 10065;
  cWSAENOTEMPTY               = 10066;
  cWSAEPROCLIM                = 10067;
  cWSAEUSERS                  = 10068;
  cWSAEDQUOT                  = 10069;
  cWSAESTALE                  = 10070;
  cWSAEREMOTE                 = 10071;
  cWSASYSNOTREADY             = 10091;
  cWSAVERNOTSUPPORTED         = 10092;
  cWSANOTINITIALISED          = 10093;
  cWSAEDISCON                 = 10101;
  cWSAENOMORE                 = 10102;
  cWSAECANCELLED              = 10103;
  cWSAEINVALIDPROCTABLE       = 10104;
  cWSAEINVALIDPROVIDER        = 10105;
  cWSAEPROVIDERFAILEDINIT     = 10106;
  cWSASYSCALLFAILURE          = 10107;
  cWSASERVICE_NOT_FOUND       = 10108;
  cWSATYPE_NOT_FOUND          = 10109;
  cWSA_E_NO_MORE              = 10110;
  cWSA_E_CANCELLED            = 10111;
  cWSAEREFUSED                = 10112;
  cWSAHOST_NOT_FOUND          = 11001;
  cWSATRY_AGAIN               = 11002;
  cWSANO_RECOVERY             = 11003;
  cWSANO_DATA                 = 11004;
  cWSA_QOS_RECEIVERS          = 11005;
  cWSA_QOS_SENDERS            = 11006;
  cWSA_QOS_NO_SENDERS         = 11007;
  cWSA_QOS_NO_RECEIVERS       = 11008;
  cWSA_QOS_REQUEST_CONFIRMED  = 11009;
  cWSA_QOS_ADMISSION_FAILURE  = 11010;
  cWSA_QOS_POLICY_FAILURE     = 11011;
  cWSA_QOS_BAD_STYLE          = 11012;
  cWSA_QOS_BAD_OBJECT         = 11013;
  cWSA_QOS_TRAFFIC_CTRL_ERROR = 11014;
  cWSA_QOS_GENERIC_ERROR      = 11015;
  cWSA_QOS_ESERVICETYPE       = 11016;
  cWSA_QOS_EFLOWSPEC          = 11017;
  cWSA_QOS_EPROVSPECBUF       = 11018;
  cWSA_QOS_EFILTERSTYLE       = 11019;
  cWSA_QOS_EFILTERTYPE        = 11020;
  cWSA_QOS_EFILTERCOUNT       = 11021;
  cWSA_QOS_EOBJLENGTH         = 11022;
  cWSA_QOS_EFLOWCOUNT         = 11023;
  cWSA_QOS_EUNKOWNPSOBJ       = 11024;
  cWSA_QOS_EPOLICYOBJ         = 11025;
  cWSA_QOS_EFLOWDESC          = 11026;
  cWSA_QOS_EPSFLOWSPEC        = 11027;
  cWSA_QOS_EPSFILTERSPEC      = 11028;
  cWSA_QOS_ESDMODEOBJ         = 11029;
  cWSA_QOS_ESHAPERATEOBJ      = 11030;
  cWSA_QOS_RESERVED_PETYPE    = 11031;

  { shutdown option constants }
  cSD_RECEIVE = 0;
  cSD_SEND = 1;
  cSD_BOTH = 2;

  { blocking mode options }
  cFIONBIO = int32($8004667E);
  cFIONREAD = int32($4004667F);
  cBlockingEnabled = 0;
  cBlockingDisabled = 1;

  // many functions test for zero result.
  cINVALID_SOCKET = NativeUInt(-1); //
  cSOCKET_ERROR = -1;
  cSOMAXCONN = $7fffffff;
  cZero = 0;

{==============================================================================}
{ WINSOCK2 Functions                                                           }
{==============================================================================}

function deStartup( wVersionRequested: uint16; lpWSAData: pTWSAData ): int32; stdcall; external cWinsockDLL name 'WSAStartup';
function deCleanup(): int32; stdcall; external cWinsockDLL name 'WSACleanup';
function deGetLastError: int32; stdcall; external cWinsockDLL name 'WSAGetLastError';
function deOpenSocket(Domain, Kind, Protocol: uint32): NativeUInt; stdcall; external cWinsockDLL name 'socket';
function deConnect(Socket: NativeUInt; addr: pTSockAddr; addrlen: int32): int32; stdcall; external cWinsockDLL name 'connect';
function deCloseSocket(Socket: NativeUInt): int32; stdcall; external cWinsockDLL name 'closesocket';
function deShutdown(Socket: NativeUInt; Method: uint32): int32; stdcall; external cWinsockDLL name 'shutdown';
function deListen(Socket: NativeUInt; backlog: int32): int32; stdcall; external cWinsockDLL name 'listen';
function deBind(Socket: NativeUInt; addr: pTSockAddr; addrlen: int32): int32; stdcall; external cWinsockDLL name 'bind';
function deAccept(Socket: NativeUInt; addr: PTSockAddr; addrlen: pint32): NativeUInt; stdcall; external cWinsockDLL name 'accept';
function deGetsockopt(Socket: NativeUInt; level, optname: int32; optval: PAnsiChar; optlen: pint32): int32; stdcall; external cWinsockDLL name 'getsockopt';
function deRecv(Socket: NativeUInt; buf: pointer; len, flags: int32): int32; stdcall; external cWinsockDLL name 'recv';
function deRecvfrom(Socket: NativeUInt; buf: pointer; len, flags: int32; from: pTSockAddr; fromlen: pint32): int32; stdcall; external cWinsockDLL name 'recvfrom';
function deSend(Socket: NativeUInt; buf: pointer; len, flags: int32): int32; stdcall; external cWinsockDLL name 'send';
function deSendto(Socket: NativeUInt; buf: pointer; len, flags: int32; toaddr: pTSockAddr; tolen: int32): int32; stdcall; external cWinsockDLL name 'sendto';
function deSetsockopt(Socket: NativeUInt; level, optname: int32; optval: PAnsiChar; optlen: int32): int32; stdcall; external cWinsockDLL name 'setsockopt';
function deInetAddr(cp: pansichar): cardinal; stdcall; external cWinsockDLL name 'inet_addr';
function deHtoNS( host: uint16 ): uint16; stdcall; external cWinsockDLL name 'htons';
function deInetNtoa(inaddr: Tin_addr): PAnsiChar; stdcall; external cWinsockDLL name 'inet_ntoa';
function deStringToAddress( lpstr: pansichar; Domain: int32; lpproto: pointer; lpsockaddr: pointer; lpint: pint32 ): int32; stdcall; external cWinsockDLL name 'WSAStringToAddressA';
function deAddressToString( lpsockaddr: pointer; dwAddressLength: uint32; lpProtocolInfo: pointer; lpszAddressString: pansichar; lpdwAddressStringLength: puint32 ): int32; stdcall; external cWinsockDLL name 'WSAAddressToStringA';
function deIOCTL(Socket: NativeUInt; cmd: int32; var argp: uint32): int32; stdcall; external cWinsockDLL name 'ioctlsocket';

{==============================================================================}
// UTILITY FUNCTIONS
{==============================================================================}

function SocketStatus(Status: int32): TSocketStatus;
begin
   case Status of
     cWSA_INVALID_HANDLE:         Result := ssInvalidHandle;
     cWSA_NOT_ENOUGH_MEMORY:      Result := ssNotEnoughMemory;
     cWSA_INVALID_PARAMETER:      Result := ssInvalidParameter;
     cWSA_OPERATION_ABORTED:      Result := ssOperationAborted;
     cWSA_IO_INCOMPLETE:          Result := ssIOIncomplete;
     cWSA_IO_PENDING:             Result := ssIOPending;
     cWSAEINTR:                   Result := ssInterruptException;
     cWSAEBADF:                   Result := ssBadFileException;
     cWSAEACCES:                  Result := ssAccessDeniedException;
     cWSAEFAULT:                  Result := ssBadAddress;
     cWSAEINVAL:                  Result := ssInvalidArgument;
     cWSAEMFILE:                  Result := ssTooManySockets;
     cWSAEWOULDBLOCK:             Result := ssWouldBlock;
     cWSAEINPROGRESS:             Result := ssInProgress;
     cWSAEALREADY:                Result := ssAlreadyInProgress;
     cWSAENOTSOCK:                Result := ssNotSocket;
     cWSAEDESTADDRREQ:            Result := ssDestAddrReq;
     cWSAEMSGSIZE:                Result := ssMessageSize;
     cWSAEPROTOTYPE:              Result := ssWrongProtocol;
     cWSAENOPROTOOPT:             Result := ssBadProtocolOption;
     cWSAEPROTONOSUPPORT:         Result := ssProtocolNotSupported;
     cWSAESOCKTNOSUPPORT:         Result := ssSocketTypeNotSuppored;
     cWSAEOPNOTSUPP:              Result := ssOperationNotSupported;
     cWSAEPFNOSUPPORT:            Result := ssProtocolNotSupported;
     cWSAEAFNOSUPPORT:            Result := ssDomainNotSupprted;
     cWSAEADDRINUSE:              Result := ssAddressInUse;
     cWSAEADDRNOTAVAIL:           Result := ssAddressNotAvail;
     cWSAENETDOWN:                Result := ssNetworkDown;
     cWSAENETUNREACH:             Result := ssNetworkUnreachable;
     cWSAENETRESET:               Result := ssConnectionDroppedOnReset;
     cWSAECONNABORTED:            Result := ssSoftwareConnectionAbord;
     cWSAECONNRESET:              Result := ssConnectionResetByPeer;
     cWSAENOBUFS:                 Result := ssNoBufferSpace;
     cWSAEISCONN:                 Result := ssSocketAlreadyConnected;
     cWSAENOTCONN:                Result := ssSocketNotConnected;
     cWSAESHUTDOWN:               Result := ssSocketIsShutdown;
     cWSAETOOMANYREFS:            Result := ssTooManyReferences;
     cWSAETIMEDOUT:               Result := ssConnectionTimeout;
     cWSAECONNREFUSED:            Result := ssConnectionRefused;
     cWSAELOOP:                   Result := ssCannotTranslateName;
     cWSAENAMETOOLONG:            Result := ssNameTooLong;
     cWSAEHOSTDOWN:               Result := ssHostIsDown;
     cWSAEHOSTUNREACH:            Result := ssHostUnreachable;
     cWSAENOTEMPTY:               Result := ssDirectoryNotEmpty;
     cWSAEPROCLIM:                Result := ssTooManyProcesses;
     cWSAEUSERS:                  Result := ssUserQuotaExceeded;
     cWSAEDQUOT:                  Result := ssDiskQuotaExceeded;
     cWSAESTALE:                  Result := ssStaleFileHandle;
     cWSAEREMOTE:                 Result := ssItemIsRemote;
     cWSASYSNOTREADY:             Result := ssSubSysNotReady;
     cWSAVERNOTSUPPORTED:         Result := ssUnsupportedVersion;
     cWSANOTINITIALISED:          Result := ssNotInitialized;
     cWSAEDISCON:                 Result := ssDisconnecting;
     cWSAENOMORE:                 Result := ssNoMoreResults;
     cWSAECANCELLED:              Result := ssCallCancelled;
     cWSAEINVALIDPROCTABLE:       Result := ssInvalidProcTable;
     cWSAEINVALIDPROVIDER:        Result := ssInvalidServiceProvider;
     cWSAEPROVIDERFAILEDINIT:     Result := ssProvierFailedInit;
     cWSASYSCALLFAILURE:          Result := ssSystemCallFailure;
     cWSASERVICE_NOT_FOUND:       Result := ssServiceNotFound;
     cWSATYPE_NOT_FOUND:          Result := ssTypeNotFound;
     cWSA_E_NO_MORE:              Result := ssNoMoreResultsE;
     cWSA_E_CANCELLED:            Result := ssCallCancelled;
     cWSAEREFUSED:                Result := ssQueryRefused;
     cWSAHOST_NOT_FOUND:          Result := ssHostNotFound;
     cWSATRY_AGAIN:               Result := ssNonAuthorativeHost;
     cWSANO_RECOVERY:             Result := ssNoRecover;
     cWSANO_DATA:                 Result := ssNoData;
     cWSA_QOS_RECEIVERS:          Result := ssQoSReceivers;
     cWSA_QOS_SENDERS:            Result := ssQoSSenders;
     cWSA_QOS_NO_SENDERS:         Result := ssNoQoSSenders;
     cWSA_QOS_NO_RECEIVERS:       Result := ssQoSNoReceivers;
     cWSA_QOS_REQUEST_CONFIRMED:  Result := ssQoSRequestConfirmed;
     cWSA_QOS_ADMISSION_FAILURE:  Result := ssQoSAdmissionFailure;
     cWSA_QOS_POLICY_FAILURE:     Result := ssQoSPolicyFailure;
     cWSA_QOS_BAD_STYLE:          Result := ssQoSBadStyle;
     cWSA_QOS_BAD_OBJECT:         Result := ssQoSBadObject;
     cWSA_QOS_TRAFFIC_CTRL_ERROR: Result := ssQoSTrafficCtrlError;
     cWSA_QOS_GENERIC_ERROR:      Result := ssQoSGenericError;
     cWSA_QOS_ESERVICETYPE:       Result := ssQoSServiceTypeError;
     cWSA_QOS_EFLOWSPEC:          Result := ssQoSEFlowSpecError;
     cWSA_QOS_EPROVSPECBUF:       Result := ssQoSProviderBufferInvalid;
     cWSA_QOS_EFILTERSTYLE:       Result := ssQoSInvalidFilterStyle;
     cWSA_QOS_EFILTERTYPE:        Result := ssQosInvalidFilterType;
     cWSA_QOS_EFILTERCOUNT:       Result := ssQoSIncorrectFilterCount;
     cWSA_QOS_EOBJLENGTH:         Result := ssQoSInvalidObjectLenght;
     cWSA_QOS_EFLOWCOUNT:         Result := ssQoSIncorrectFlowCount;
     cWSA_QOS_EUNKOWNPSOBJ:       Result := ssQoSUnknownObject;
     cWSA_QOS_EPOLICYOBJ:         Result := ssQoSInvalidPolicyObject;
     cWSA_QOS_EFLOWDESC:          Result := ssQoSInvalidFlowDescriptor;
     cWSA_QOS_EPSFLOWSPEC:        Result := ssQoSInvalidFlowProviderSpec;
     cWSA_QOS_EPSFILTERSPEC:      Result := ssQoSInvalidProviderFilterSpec;
     cWSA_QOS_ESDMODEOBJ:         Result := ssQoSInvalidShapeDiscardModeObject;
     cWSA_QOS_ESHAPERATEOBJ:      Result := ssQoSInvalidShapeRatingObject;
     cWSA_QOS_RESERVED_PETYPE:    Result := ssQoSReservedPolicyElememtType;
    else                          Result := TSocketStatus.ssUnknown;
  end;
end;


function IPv4StringToAddress( aIPAddress: string; var SAddr: Tsockaddr_in ): boolean;
var
  b: IUnicodeBuffer;
begin
  b := TBuffer.Create(Succ(Length(aIPAddress)));
  try
    b.FillMem(0);
    b.WriteString(aIPAddress,TUnicodeFormat.utfANSI);
    SAddr.sin_addr.S_addr := deInetAddr(pansichar(b.getDataPointer));
  finally
    b := nil; // disposes the allocated memory
  end;
  Result := True;
end;

function IPv6StringToAddress( aIPAddress: string; var SAddr: TSockaddr_in6 ): boolean;
var
  SAddrLen: int32;
  b: IUnicodeBuffer;
begin
  Result := False; // unless..
  SAddrLen := Sizeof(TSockaddr_in6);
  b := TBuffer.Create(Succ(Length(aIPAddress)));
  try
    b.FillMem(0);
    b.WriteString(aIPAddress,TUnicodeFormat.utfANSI);
    if not deStringToAddress(pansichar(b.getDataPointer),cAF_INET6,nil,@SAddr,@SAddrLen) = cZero then begin
      Exit;
    end;
    Result := True;
  finally
    b := nil; // disposes the allocated memory.
  end;
end;

function Ipv4AddressToString( Addr: Tsockaddr_in; var aIPAddress: string ): boolean;
begin
  aIPAddress := string(deINetNtoa(Addr.sin_addr));
  Result := True;
end;

function Ipv6AddressToString( SAddr: TSockaddr_in6; var aIPAddress: string ): boolean;
const
  cBufSize = 200;
var
  b: IUnicodeBuffer;
  addrsize: uint32;
  strlen: uint32;
begin
  Result := False;
  b := TBuffer.Create(cBufSize);
  try
    addrsize := Sizeof(SAddr);
    strlen := cBufSize;
    if deAddressToString( @sAddr, addrsize, nil, b.getDataPointer, @strlen )<>cZero then begin
      exit;
    end;
    aIPAddress := b.ReadString(TUnicodeFormat.utfANSI,True,cBufSize);
    Result := True;
  finally
    b := nil; // dispose the allocated memory.
  end;
end;

function BindIPv4( var Socket: TSocket; NetAddress: TNetworkAddress ): TSocketStatus;
var
  SAddr: Tsockaddr_in;
begin
  FillChar(SAddr,Sizeof(SAddr),0);
  SAddr.sin_family:=cAF_INET;
  if IPv4StringToAddress( NetAddress.IPAddress, SAddr ) then begin
    SAddr.sin_port := deHtoNS(NetAddress.Port); //- SET PORT NUMBER
    //- Bind the socket.
    if deBind(SocketOf(@Socket.Handle)^,@SAddr,Sizeof(SAddr))=cZero then begin
       Result := TSocketStatus.ssSuccess;
    end
     else begin
      Result := SocketStatus(deGetLastError);
    end;
  end else begin
    Result := TSocketStatus.ssBadAddress;
  end;
end;

function BindIPv6( var Socket: TSocket; NetAddress: TNetworkAddress ): TSocketStatus;
var
  SAddr6: TSockaddr_in6;
begin
  FillChar(SAddr6,sizeof(SAddr6),0);
  SAddr6.sin6_family:=cAF_INET6;
  if IPv6StringToAddress( NetAddress.IPAddress, SAddr6 ) then begin
    SAddr6.sin6_port:=deHtoNS(NetAddress.Port); //- SET PORT NUMBER
    //- Bind the socket.
    if deBind(SocketOf(@Socket.Handle)^,@SAddr6,Sizeof(SAddr6))=cZero then begin
      Result := TSocketStatus.ssSuccess;
    end else begin
      Result := SocketStatus(deGetLastError);
    end;
  end else begin
    Result := TSocketStatus.ssBadAddress;
  end;
end;

function IPv4Accept( Socket: TSocket; var NewSocket: TSocket; var NewNetAddress: TNetworkAddress ): TSocketStatus;
var
  SAddr: Tsockaddr_in;
  Size: int32;
begin
  Size := Sizeof(SAddr);
  SocketOf(@NewSocket.Handle)^:=deAccept(SocketOf(@Socket.Handle)^,@SAddr,@Size);
  if SocketOf(@NewSocket.Handle)^=cINVALID_SOCKET then begin
    Result := SocketStatus(deGetLastError);
  end else begin
    Result := TSocketStatus.ssSuccess;
    // if possible, recover the incoming connection IP:Port
    if Size>cZero then begin
      NewNetAddress.Port := SAddr.sin_port;
      Ipv4AddressToString( SAddr, NewNetAddress.IPAddress );
    end else begin
      NewNetAddress.Port := 0;
      NewNetAddress.IPAddress := '';
    end;
  end;
end;

function IPv6Accept( Socket: TSocket; var NewSocket: TSocket; var NewNetAddress: TNetworkAddress ): TSocketStatus;
var
  SAddr6: Tsockaddr_in6;
  Size: int32;
begin
  Size := Sizeof(SAddr6);
  SocketOf(@NewSocket.Handle)^:=deAccept(SocketOf(@Socket.Handle)^,@SAddr6,@Size);
  if SocketOf(@NewSocket.Handle)^=cINVALID_SOCKET then begin
    Result := SocketStatus(deGetLastError);
  end else begin
    Result := TSocketStatus.ssSuccess;
    // if possible, recover the incoming connection IP:Port
    if Size>cZero then begin
      NewNetAddress.Port := SAddr6.sin6_port;
      Ipv6AddressToString( SAddr6, NewNetAddress.IPAddress );
    end else begin
      NewNetAddress.Port := 0;
      NewNetAddress.IPAddress := '';
    end;
  end;
end;

function ConnectIPv4( Socket: TSocket; NetAddress: TNetworkAddress): TSocketStatus;
var
  SAddr: Tsockaddr_in;
begin
  FillChar(SAddr,Sizeof(SAddr),0);
  SAddr.sin_family:=cAF_INET;
  if IPv4StringToAddress( NetAddress.IPAddress, SAddr ) then begin
    SAddr.sin_port := deHtoNS(NetAddress.Port); //- SET PORT NUMBER
    //- Connect the socket.
    if deConnect(SocketOf(@Socket.Handle)^,@SAddr,Sizeof(SAddr))=cZero then begin
       Result := TSocketStatus.ssSuccess;
    end else begin
      Result := SocketStatus(deGetLastError);
    end;
  end else begin
    Result := TSocketStatus.ssBadAddress;
  end;
end;

function ConnectIPv6(Socket: TSocket; NetAddress: TNetworkAddress): TSocketStatus;
var
  SAddr6: TSockaddr_in6;
begin
  FillChar(SAddr6,Sizeof(SAddr6),0);
  SAddr6.sin6_family:=cAF_INET6;
  if IPv6StringToAddress(NetAddress.IPAddress, SAddr6 ) then begin
    SAddr6.sin6_port:=deHtoNS(NetAddress.Port); //- SET PORT NUMBER
    //- Connect
    if deConnect(SocketOf(@Socket.Handle)^,@SAddr6,Sizeof(SAddr6))=cZero then begin
      Result := TSocketStatus.ssSuccess;
    end else begin
      Result := SocketStatus(deGetLastError);
    end;
  end else begin
    Result := TSocketStatus.ssBadAddress;
  end;
end;


{==============================================================================}
{==============================================================================}

constructor TTargetSockets.Create;
begin
  inherited Create;
end;

function TTargetSockets.DataWaiting( Socket: TSocket ): int32;
var
  bytes: uint32;
begin
  bytes := 0;
  deIOCTL(SocketOf(@Socket.Handle)^, cFIONREAD, bytes);
  Result := bytes;
end;

destructor TTargetSockets.Destroy;
begin
  inherited Destroy;
end;

function TTargetSockets.Blocking(Socket: TSocket; IsBlocking: boolean): TSocketStatus;
var
  iMode: uint32;
begin
  if IsBlocking then begin
    iMode := cBlockingEnabled;
  end else begin
    iMode := cBlockingDisabled;
  end;
  if deIOCTL(SocketOf(@Socket.Handle)^, cFIONBIO, iMode)<>cSOCKET_ERROR then begin
    Result := TSocketStatus.ssSuccess;
  end else begin
    Result := SocketStatus(deGetLastError);
  end;
end;

{ TPlatformSocket }
function TTargetSockets.Accept(Socket: TSocket; var NewSocket: TSocket; var NewNetAddress: TNetworkAddress): TSocketStatus;
begin
  case Socket.Domain of
    sdIPv4: Result := IPv4Accept( Socket, NewSocket, NewNetAddress );
    sdIPv6: Result := IPv6Accept( Socket, NewSocket, NewNetAddress );
//    sdUnspecified: ;
//    sdInfrared: ;
//    sdBluetooth: ;
//    sdAppleTalk: ;
//    sdNetBios: ;
//    sdIPX: ;
//    sdASH: ;
//    sdATMPVC: ;
//    sdATMSVC: ;
//    sdAX25: ;
//    sdBRIDGE: ;
//    sdDECnet: ;
//    sdAECONET: ;
//    sdKEY: ;
//    sdLLC: ;
//    sdLOCAL: ;
//    sdNETBEUI: ;
//    sdNETLINK: ;
//    sdNETROM: ;
//    sdPACKET: ;
//    sdPPPOX: ;
//    sdROSE: ;
//    sdROUTE: ;
//    sdSECURITY: ;
//    sdSNA: ;
//    sdTIPC: ;
//    sdUNIX: ;
//    sdWANPIPE: ;
//    sdX25: ;
    else begin
      Result := TSocketStatus.ssUnsupDomain;
    end;
  end;
end;

function TTargetSockets.Bind(Socket: TSocket; NetAddress: TNetworkAddress): TSocketStatus;
begin
  case Socket.Domain of
    sdIPv4: Result := BindIPv4( Socket, NetAddress );
    sdIPv6: Result := BindIPv6( Socket, NetAddress );
    // Not supported (yet)
//    sdUnspecified: ;
//    sdInfrared: ;
//    sdBluetooth: ;
//    sdAppleTalk: ;
//    sdNetBios: ;
//    sdIPX: ;
//    sdASH: ;
//    sdATMPVC: ;
//    sdATMSVC: ;
//    sdAX25: ;
//    sdBRIDGE: ;
//    sdDECnet: ;
//    sdAECONET: ;
//    sdKEY: ;
//    sdLLC: ;
//    sdLOCAL: ;
//    sdNETBEUI: ;
//    sdNETLINK: ;
//    sdNETROM: ;
//    sdPACKET: ;
//    sdPPPOX: ;
//    sdROSE: ;
//    sdROUTE: ;
//    sdSECURITY: ;
//    sdSNA: ;
//    sdTIPC: ;
//    sdUNIX: ;
//    sdWANPIPE: ;
//    sdX25: ;
    else begin
      Result := ssUnsupDomain;
      Exit;
    end;
  end;
end;

function TTargetSockets.Close(Socket: TSocket): TSocketStatus;
begin
  if deCloseSocket(SocketOf(@Socket.Handle)^)=cZero then begin
    Result := TSocketStatus.ssSuccess;
  end else begin
    Result := SocketStatus(deGetLastError);
  end;
end;

function TTargetSockets.CreateSocket(var Socket: TSocket): TSocketStatus;
var
  SocketKind: uint32;
  SocketProtocol: uint32;
  SocketDomain: uint32;
begin

  { Try to determine the socket type }
  case Socket.Kind of
    skDatagram: SocketKind := cSOCK_DGRAM;
    skStream: SocketKind := cSOCK_STREAM;
    skRaw: SocketKind := cSOCK_RAW;
    skRDM: SocketKind := cSOCK_RDM;
    skSeqPacket: SocketKind := cSOCK_SEQPACKET;
    else begin
      Result := ssUnsupSockType;
      Exit;
    end;
  end;

  {# Try to determine the packet protocol }
  case Socket.Protocol of
    ppUnSpec: SocketProtocol := cIPPROTO_UNSPEC;
    ppICMP: SocketProtocol := cIPPROTO_ICMP;
    ppIGMP: SocketProtocol := cIPPROTO_IGMP;
    ppRFCOMM: SocketProtocol := cBTHPROTO_RFCOMM;
    ppTCP: SocketProtocol := cIPPROTO_TCP;
    ppUDP: SocketProtocol := cIPPROTO_UDP;
    ppICMPV6: SocketProtocol := cIPPROTO_ICMPV6;
    ppRM: SocketProtocol := cIPPROTO_RM;
    else begin
      Result := ssUnsupProtocol;
      Exit;
    end;
  end;

  { Try to determine the socket domain }
  case Socket.Domain of
    sdUnspecified: SocketDomain := cAF_UNSPEC;
    sdIPv4: SocketDomain := cAF_INET;
    sdIPv6: SocketDomain := cAF_INET6;
    sdInfrared: SocketDomain := cAF_IRDA;
    sdBluetooth: SocketDomain := cAF_BTH;
    sdAppleTalk: SocketDomain := cAF_APPLETALK;
    sdNetBios: SocketDomain := cAF_NETBIOS;
    sdIPX: SocketDomain := cAF_IPX;
    else begin
      Result := ssUnsupDomain;
      Exit;
    end;
  end;

  //- Create the soccket
  SocketOf(@Socket.Handle)^ := deOpenSocket(SocketDomain,SocketKind,SocketProtocol);
  if SocketOf(@Socket.Handle)^=cINVALID_SOCKET then begin
    Result := SocketStatus(deGetLastError);
  end else begin
    Result := TSocketStatus.ssSuccess;
  end;
end;

function TTargetSockets.Shutdown(Socket: TSocket; Opts: TShutdownOptions): TSocketStatus;
var
  shutdownOpt: int32;
begin
  case Opts of
    soSending: shutdownOpt := cSD_RECEIVE;
    soReceiving: shutdownOpt := cSD_SEND;
    else begin
     shutdownOpt := cSD_BOTH;
    end;
  end;
  // make the call and return the result.
  if deShutdown(SocketOf(@Socket.Handle)^,shutdownOpt)=cZero then begin
    Result := TSocketStatus.ssSuccess;
  end else begin
    Result := SocketStatus(deGetLastError());
  end;
end;

function TTargetSockets.Listen(Socket: TSocket): TSocketStatus;
begin
  if deListen(SocketOf(@Socket.Handle)^,cSOMAXCONN)=cZero then begin
    Result := TSocketStatus.ssSuccess;
  end else begin
    Result := TSocketStatus(deGetLastError);
  end;
end;


function TTargetSockets.Connect(Socket: TSocket; NetAddress: TNetworkAddress): TSocketStatus;
begin
  case Socket.Domain of
    sdIPv4: Result := ConnectIPv4( Socket, NetAddress );
    sdIPv6: Result := ConnectIPv6( Socket, NetAddress );
    // Not supported (yet)
//    sdUnspecified: ;
//    sdInfrared: ;
//    sdBluetooth: ;
//    sdAppleTalk: ;
//    sdNetBios: ;
//    sdIPX: ;
//    sdASH: ;
//    sdATMPVC: ;
//    sdATMSVC: ;
//    sdAX25: ;
//    sdBRIDGE: ;
//    sdDECnet: ;
//    sdAECONET: ;
//    sdKEY: ;
//    sdLLC: ;
//    sdLOCAL: ;
//    sdNETBEUI: ;
//    sdNETLINK: ;
//    sdNETROM: ;
//    sdPACKET: ;
//    sdPPPOX: ;
//    sdROSE: ;
//    sdROUTE: ;
//    sdSECURITY: ;
//    sdSNA: ;
//    sdTIPC: ;
//    sdUNIX: ;
//    sdWANPIPE: ;
//    sdX25: ;
    else begin
      Result := ssUnsupDomain;
      Exit;
    end;
  end;

end;

function TTargetSockets.Recv(Socket: TSocket; Data: pointer; MaxSize: int32; var Recvd: int32): TSocketStatus;
var
  iResult : int32;
begin
  Recvd := 0;
  iResult := deRecv(SocketOf(@Socket.Handle)^,Data,MaxSize,0); // todo - correct flags
  if iResult = cSOCKET_ERROR then begin
    Result := SocketStatus(deGetLastError);
  end else if iResult=cZero then begin
    Result := TSocketStatus.ssSocketClosed;
  end else begin
    Recvd := iResult;
    Result := TSocketStatus.ssSuccess;
  end;
end;

function TTargetSockets.Send(Socket: TSocket; Data: pointer; Size: int32; var Sent: int32): TSocketStatus;
var
  iResult : int32;
begin
  Sent := 0;
  iResult := deSend(SocketOf(@Socket.Handle)^,Data,Size,0); // todo - correct flags
  if iResult = cSOCKET_ERROR then begin
    Result := SocketStatus(deGetLastError);
  end else begin
    Sent := iResult;
    Result := TSocketStatus.ssSuccess;
  end;
end;

initialization
  deStartup($0002 {version 2}, @wsdata); // initializes winsock

finalization
  deCleanup; // finalizes winsock

{$endif}
{$endif}
end.


