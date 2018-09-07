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
unit darksockets.sockets.delphi.posix;

interface
{$ifndef FPC}
{$ifndef MSWINDOWS}
uses
  de.types,
  de.sockets.sockets;

type
  TTargetSockets = class( TInterfacedObject, ISockets )
  private  // ISockets
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
{$ifndef FPC}
{$ifndef MSWINDOWS}
uses
  de.text,
  de.log,
  de.coax,
  Posix.SysSocket,
  Posix.ArpaInet, // for htons
  Posix.Base,
  Posix.SysTypes,
  Posix.NetinetIn;

const
  FIONBIO = $5421;
  FIONREAD = $541B;

const
  EPERM           = 1;
  ENOENT          = 2;
  ESRCH           = 3;
  EINTR           = 4;
  EIO             = 5;
  ENXIO           = 6;
  E2BIG           = 7;
  ENOEXEC         = 8;
  EBADF           = 9;
  ECHILD          = 10;
  EAGAIN          = 11;
  ENOMEM          = 12;
  EACCESS         = 13;
  EFAULT          = 14;
  ENOTBLK         = 15;
  EBUSY           = 16;
  EEXIST          = 17;
  EXDEV           = 18;
  ENODEV          = 19;
  ENOTDIR         = 20;
  EISDIR          = 21;
  EINVAL          = 22;
  ENFILE          = 23;
  EMFILE          = 24;
  ENOTTY          = 25;
  ETXTBSY         = 26;
  EFBIG           = 27;
  ENOSPC          = 28;
  ESPIPE          = 29;
  EROFS           = 30;
  EMLINK          = 31;
  EPIPE           = 32;
  EDOM            = 33;
  ERANGE          = 34;
  EDEADLK         = 35;
  ENAMETOOLONG    = 36;
  ENOLCK          = 37;
  ENOSYS          = 38;
  ENOTEMPTY       = 39;
  ELOOP           = 40;
  EWOULDBLOCK     = EAGAIN;
  ENOMSG          = 42;
  EIDRM           = 43;
  ECHRNG          = 44;
  EL2NSYNC        = 45;
  EL3HLT          = 46;
  EL3RST          = 47;
  ELNRNG          = 48;
  EUNATCH         = 49;
  ENOCSI          = 50;
  EL2HLT          = 51;
  EBADE           = 52;
  EBADR           = 53;
  EXFULL          = 54;
  ENOANO          = 55;
  EBADRQC         = 56;
  EBADSLT         = 57;
  EDEADLOCK       = EDEADLK;
  EBFONT          = 59;
  ENOSTR          = 60;
  ENODATA         = 61;
  ETIME           = 62;
  ENOSR           = 63;
  ENONET          = 64;
  ENOPKG          = 65;
  EREMOTE         = 66;
  ENOLINK         = 67;
  EADV            = 68;
  ESRMNT          = 69;
  ECOMM           = 70;
  EPROTO          = 71;
  EMULTIHOP       = 72;
  EDOTDOT         = 73;
  EBADMSG         = 74;
  EOVERFLOW       = 75;
  ENOTUNIQ        = 76;
  EBADFD          = 77;
  EREMCHG         = 78;
  ELIBACC         = 79;
  ELIBBAD         = 80;
  ELIBSCN         = 81;
  ELIBMAX         = 82;
  ELIBEXEC        = 83;
  EILSEQ          = 84;
  ERESTART        = 85;
  ESTRPIPE        = 86;
  EUSERS          = 87;
  ENOTSOCK        = 88;
  EDESTADDRREQ    = 89;
  EMSGSIZE        = 90;
  EPROTOTYPE      = 91;
  ENOPROTOOPT     = 92;
  EPROTONOSUPPORT = 93;
  ESOCKTNOSUPPORT = 94;
  EOPNOTSUPP      = 95;
  EPFNOSUPPORT    = 96;
  EAFNOSUPPORT    = 97;
  EADDRINUSE      = 98;
  EADDRNOTAVAIL   = 99;
  ENETDOWN        = 100;
  ENETUNREACH     = 101;
  ENETRESET       = 102;
  ECONNABORTED    = 103;
  ECONNRESET      = 104;
  ENOBUFS         = 105;
  EISCONN         = 106;
  ENOTCONN        = 107;
  ESHUTDOWN       = 108;
  ETOOMANYREFS    = 109;
  ETIMEDOUT       = 110;
  ECONNREFUSED    = 111;
  EHOSTDOWN       = 112;
  EHOSTUNREACH    = 113;
  EALREADY        = 114;
  EINPROGRESS     = 115;
  ESTALE          = 116;
  EUCLEAN         = 117;
  ENOTNAM         = 118;
  ENAVAIL         = 119;
  EISNAM          = 120;
  EREMOTEIO       = 121;
  EDQUOT          = 122;
  ENOMEDIUM       = 123;
  EMEDIUMTYPE     = 124;

  // many functions test against zero for a result.
  cZero = 0;
  cINVALID_SOCKET = -1; // -1 ok on all but windows
  cSOCKET_ERROR = -1;
  // parameters to shutdown
  cSD_RECEIVE = 0;
  cSD_SEND = 1;
  cSD_BOTH = 2;

function ioctl(fd: Integer; request: Integer): Integer; varargs; cdecl; external libc name 'ioctl';

{==============================================================================}
{==============================================================================}

function IPv4StringToAddress( aIPAddress: TString; var SAddr: sockaddr_in ): boolean;
var
  IPArray: TArrayOfString;
  B1, B2, B3, B4: uint8;
begin
  Result := True;
    // Break up the IP Address
  IPArray := text.Explode('.',aIPAddress);
  if length(IPArray)<>4 then begin
    Result := False;
    Log.Insert(EAddressTranslation,TLogSeverity.lsFatal,[LogBind('domain','IPv4'),LogBind('address',aIPAddress)]);
    Exit;
  end;
  B1 := Coax.ToInteger(IPArray[0]);
  B2 := Coax.ToInteger(IPArray[1]);
  B3 := Coax.ToInteger(IPArray[2]);
  B4 := Coax.ToInteger(IPArray[3]);
  SAddr.sin_addr.s_addr := htonl((Cardinal(B1) shl 24) or (Cardinal(B2) shl 16) or (Cardinal(B3) shl 8) or Cardinal(B4));
end;

function IPv6StringToAddress( aIPAddress: TString; var SAddr: sockaddr_in6 ): boolean;
var
  SAddrLen: integer;
  IPArray: TArrayOfString;
  i: uint32;
begin
  Result := False; // unless..
  // Break up the IP Address
  IPArray := text.Explode(':',aIPAddress);
  if length(IPArray)<>8 then begin
    Log.Insert(EAddressTranslation,TLogSeverity.lsFatal,[ LogBind('domain','IPv6'), LogBind('address',aIPAddress) ]);
    Exit;
  end;
  for i := 0 to pred(Length(IPArray)) do begin
    {$ifdef macos}
      SAddr.sin6_addr.__s6_addr16[i] := htons(Coax.ToInteger('$'+text.UppercaseTrim(IPArray[i])));
    {$else}
      SAddr.sin6_addr.s6_addr16[i] := htons(Coax.ToInteger('$'+text.UppercaseTrim(IPArray[i])));
    {$endif}
  end;
  Result := True;
end;

function IPv4AddressToString(SAddr: sockaddr_in; var aIPAddress: TString): boolean;
begin
  aIPAddress := TString(inet_ntoa(SAddr.sin_addr));
  Result := True;
end;

function IPv6AddressToString( SAddr: sockaddr_in6; var aIPAddress: TString): boolean;
begin
  {$ifdef macos}
    aIPAddress := Coax.ToString(SAddr.sin6_addr.__s6_addr16[0])+':'+
    Coax.ToString(SAddr.sin6_addr.__s6_addr16[1])+':'+
    Coax.ToString(SAddr.sin6_addr.__s6_addr16[2])+':'+
    Coax.ToString(SAddr.sin6_addr.__s6_addr16[3])+':'+
    Coax.ToString(SAddr.sin6_addr.__s6_addr16[4])+':'+
    Coax.ToString(SAddr.sin6_addr.__s6_addr16[5])+':'+
    Coax.ToString(SAddr.sin6_addr.__s6_addr16[6])+':'+
    Coax.ToString(SAddr.sin6_addr.__s6_addr16[7]);
  {$else}
  aIPAddress := Coax.ToString(SAddr.sin6_addr.s6_addr16[0])+':'+
    Coax.ToString(SAddr.sin6_addr.s6_addr16[1])+':'+
    Coax.ToString(SAddr.sin6_addr.s6_addr16[2])+':'+
    Coax.ToString(SAddr.sin6_addr.s6_addr16[3])+':'+
    Coax.ToString(SAddr.sin6_addr.s6_addr16[4])+':'+
    Coax.ToString(SAddr.sin6_addr.s6_addr16[5])+':'+
    Coax.ToString(SAddr.sin6_addr.s6_addr16[6])+':'+
    Coax.ToString(SAddr.sin6_addr.s6_addr16[7]);
  {$endif}
end;


function SocketStatus(Status: int32): TSocketStatus;
begin
  case Status of
    EACCESS:         Result := TSocketStatus.ssAccessDeniedException; // Access forbidden error
    EBADF:           Result := TSocketStatus.ssBadFileException; // Alias: bad file descriptor
    EFAULT:          Result := TSocketStatus.ssBadAddress; // Alias: an error occurred
    EINTR:           Result := TSocketStatus.ssInterruptException; // Alias : operation interrupted
    EINVAL:          Result := TSocketStatus.ssInvalidArgument; // Alias: Invalid value specified
    EMFILE:          Result := TSocketStatus.ssBadFileException; // Error code ?
    EMSGSIZE:        Result := TSocketStatus.ssMessageSize; // Wrong message size error
    ENOBUFS:         Result := TSocketStatus.ssNoBufferSpace; // No buffer space available error
    ENOTCONN:        Result := TSocketStatus.ssSocketNotConnected; // Not connected error
    ENOTSOCK:        Result := TSocketStatus.ssNotSocket; // File descriptor is not a socket error
    EPROTONOSUPPORT: Result := TSocketStatus.ssProtocolNotSupported; // Protocol not supported error
    EWOULDBLOCK:     Result := TSocketStatus.ssWouldBlock; // Operation would block error
    else             Result := TSocketStatus.ssUnknown;
  end;
end;

function BindIPv4( var Socket: TSocket; NetAddress: TNetworkAddress ): TSocketStatus;
var
  SAddr: sockaddr_in;
begin
  FillChar(SAddr,Sizeof(SAddr),0);
  SAddr.sin_family:=AF_INET;
  if IPv4StringToAddress( NetAddress.IPAddress, SAddr ) then begin
    SAddr.sin_port:=htons(NetAddress.Port); //- SET PORT NUMBER
    //- Bind the socket.
    if Posix.SysSocket.Bind(Socket.Handle,sockaddr(SAddr),Sizeof(SAddr))=cZero then begin
      Result := TSocketStatus.ssSuccess;
    end else begin
      Result := SocketStatus(GetLastError);
    end;
  end else begin
    Result := TSocketStatus.ssBadAddress;
  end;
end;

function BindIPv6( var Socket: TSocket; NetAddress: TNetworkAddress ): TSocketStatus;
var
  SAddr6: sockaddr_in6;
begin
  FillChar(SAddr6,Sizeof(SAddr6),0);
  SAddr6.sin6_family:=AF_INET6;
  if IPv6StringToAddress( NetAddress.IPAddress, SAddr6 ) then begin
    SAddr6.sin6_port:=htons(NetAddress.Port); //- SET PORT NUMBER
    //- Bind the socket.
    if Posix.SysSocket.bind(Socket.Handle,sockaddr((@SAddr6)^),Sizeof(SAddr6))=cZero then begin
      Result := TSocketStatus.ssSuccess;
    end else begin
      Result := SocketStatus(GetLastError);
    end;
  end else begin
    Result := TSocketStatus.ssBadAddress;
  end;
end;

function IPv4Accept( Socket: TSocket; var NewSocket: TSocket; var NewNetAddress: TNetworkAddress ): TSocketStatus;
var
  Size: socklen_t;
  SAddr: sockaddr;
  SAddrIn: sockaddr_in;
begin
  Size := Sizeof(SAddr);
  NewSocket.Handle:=Posix.SysSocket.accept(Socket.Handle,SAddr,Size);
  if NewSocket.Handle=cINVALID_SOCKET then begin
    Result := SocketStatus(GetLastError);
  end else begin
    Result := TSocketStatus.ssSuccess;
    // if possible, recover the incoming connection IP:Port
    if Size>cZero then begin
      SAddrIn := sockaddr_in( pointer(@SAddr)^ );
      NewNetAddress.Port := SAddrIn.sin_port;
      Ipv4AddressToString( SAddrIn, NewNetAddress.IPAddress );
    end else begin
      NewNetAddress.Port := 0;
      NewNetAddress.IPAddress := '';
    end;
  end;
end;

function IPv6Accept( Socket: TSocket; var NewSocket: TSocket; var NewNetAddress: TNetworkAddress ): TSocketStatus;
var
  SAddr: sockaddr;
  Size: socklen_t;
  SAddr6: sockaddr_in6;
begin
  Size := Sizeof(SAddr);
  NewSocket.Handle:=Posix.SysSocket.accept(Socket.Handle,SAddr,Size);
  if NewSocket.Handle=cINVALID_SOCKET then begin
    Result := SocketStatus(GetLastError);
  end else begin
    Result := TSocketStatus.ssSuccess;
    // if possible, recover the incoming connection IP:Port
    if Size>cZero then begin
      SAddr6 := sockaddr_in6( pointer(@SAddr)^ );
      NewNetAddress.Port := SAddr6.sin6_port;
      Ipv6AddressToString( SAddr6, NewNetAddress.IPAddress );
    end else begin
      NewNetAddress.Port := 0;
      NewNetAddress.IPAddress := '';
    end;
  end;
end;

function ConnectIPv4(Socket: TSocket; NetAddress: TNetworkAddress): TSocketStatus;
var
  SAddr: sockaddr_in;
begin
  FillChar(SAddr,Sizeof(SAddr),0);
  SAddr.sin_family := AF_INET;
  if IPv4StringToAddress( NetAddress.IPAddress, SAddr ) then begin
    SAddr.sin_port := HtoNS(NetAddress.Port); //- SET PORT NUMBER
    //- Connect the socket.
    if Posix.SysSocket.connect(Socket.Handle,sockaddr((@SAddr)^),Sizeof(SAddr))=cZero then begin
       Result := TSocketStatus.ssSuccess;
    end else begin
      Result := SocketStatus(GetLastError);
    end;
  end else begin
    Result := TSocketStatus.ssBadAddress;
  end;
end;

function ConnectIPv6( Socket: TSocket; NetAddress: TNetworkAddress): TSocketStatus;
var
  SAddr6: Sockaddr_in6;
begin
  FillChar(SAddr6,Sizeof(SAddr6),0);
  SAddr6.sin6_family:=AF_INET6;
  if IPv6StringToAddress( NetAddress.IPAddress, SAddr6 ) then begin
    SAddr6.sin6_port:=HtoNS(NetAddress.Port); //- SET PORT NUMBER
    //- Connect
    if Posix.SysSocket.connect(Socket.Handle,sockaddr((@SAddr6)^),Sizeof(SAddr6))=cZero then begin
      Result := TSocketStatus.ssSuccess;
    end else begin
      Result := SocketStatus(GetLastError);
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

destructor TTargetSockets.Destroy;
begin
  inherited Destroy;
end;


function TTargetSockets.Blocking(Socket: TSocket; IsBlocking: boolean): TSocketStatus;
var
  Flags: uint32;
  opt: int32;
begin
    if IsBlocking then begin
      opt := 0;
    end else begin
      opt := 1;
    end;
    case ioctl(Socket.Handle,FIONBIO,@opt) of
                 0: Result := TSocketStatus.ssSuccess;
//          EsockEBADF: Result := TSocketStatus.ssBadFileException; // Alias: bad file descriptor
//         EsockEFAULT: Result := TSocketStatus.ssBadAddress; // Alias: an error occurred
//         EsockEINVAL: Result := TSocketStatus.ssInvalidArgument; // Alias: Invalid value specified
      else Result := TSocketStatus.ssUnknown;
    end;
end;

function TTargetSockets.Accept( Socket: TSocket; var NewSocket: TSocket; var NewNetAddress: TNetworkAddress): TSocketStatus;
begin
  case Socket.Domain of
    sdIPv4: Result := IPv4Accept( Socket, NewSocket, NewNetAddress );
    sdIPv6: Result := IPv6Accept( Socket, NewSocket, NewNetAddress );
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
     else begin
      Result := ssUnsupDomain;
      Exit;
    end;
  end;
end;

function TTargetSockets.Listen(Socket: TSocket): TSocketStatus;
begin
  if Posix.SysSocket.listen(Socket.Handle,SOMAXCONN)=cZero then begin
    Result := TSocketStatus.ssSuccess;
  end else begin
    Result := SocketStatus(GetLastError);
  end;
end;

function TTargetSockets.Close(Socket: TSocket): TSocketStatus;
begin
  if Posix.SysSocket.Shutdown(Socket.Handle, 1)=cZero then begin
    Result := TSocketStatus.ssSuccess;
  end else begin
    Result := SocketStatus(GetLastError);
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
    skDatagram: SocketKind := SOCK_DGRAM;
    skStream: SocketKind := SOCK_STREAM;
    skRaw: SocketKind := SOCK_RAW;
    skRDM: SocketKind := SOCK_RDM;
    skSeqPacket: SocketKind := SOCK_SEQPACKET;
    else begin
      Result := ssUnsupSockType;
      Exit;
    end;
  end;

  {# Try to determine the packet protocol }
  case Socket.Protocol of
    ppUnSpec: SocketProtocol := IPPROTO_IP;
    ppICMP: SocketProtocol := IPPROTO_ICMP;
    ppIGMP: SocketProtocol := IPPROTO_IGMP;
    ppTCP: SocketProtocol := IPPROTO_TCP;
    ppUDP: SocketProtocol := IPPROTO_UDP;
    ppICMPV6: SocketProtocol := IPPROTO_ICMPV6;
    ppAH: SocketProtocol := IPPROTO_AH;
    {$ifndef macos}
    ppCOMP: SocketProtocol := IPPROTO_COMP;
    {$endif}
    ppDSTOPTS: SocketProtocol := IPPROTO_DSTOPTS;
    ppENCAP: SocketProtocol := IPPROTO_ENCAP;
    ppESP: SocketProtocol := IPPROTO_ESP;
    ppFRAGMENT: SocketProtocol := IPPROTO_FRAGMENT;
    ppGRE: SocketProtocol := IPPROTO_GRE;
    ppHOPOPTS: SocketProtocol := IPPROTO_HOPOPTS;
    ppIDP: SocketProtocol := IPPROTO_IDP;
    ppIPIP: SocketProtocol := IPPROTO_IPIP;
    ppIPV6: SocketProtocol := IPPROTO_IPV6;
    ppMTP: SocketProtocol := IPPROTO_MTP;
    ppNONE: SocketProtocol := IPPROTO_NONE;
    ppPIM: SocketProtocol := IPPROTO_PIM;
    ppPUP: SocketProtocol := IPPROTO_PUP;
    ppRAW: SocketProtocol := IPPROTO_RAW;
    ppROUTING: SocketProtocol := IPPROTO_ROUTING;
    ppRSVP: SocketProtocol := IPPROTO_RSVP;
//      ppSCTP: SocketProtocol := IPPROTO_SCTP;
    ppTP: SocketProtocol := IPPROTO_TP;
    else begin
      Result := ssUnsupProtocol;
      Exit;
    end;
  end;

  { Try to determine the socket domain }
  case Socket.Domain of
    sdUnspecified: SocketDomain := AF_UNSPEC;
    sdIPv4: SocketDomain := AF_INET;
    sdIPv6: SocketDomain := AF_INET6;
//      sdInfrared: SocketDomain := AF_IRDA;
//      sdBluetooth: SocketDomain := AF_BLUETOOTH;
//      sdAppleTalk: SocketDomain := AF_APPLETALK;
//      sdIPX: SocketDomain := AF_IPX;
//      sdASH: SocketDomain := AF_ASH;
//      sdATMPVC: SocketDomain := AF_ATMPVC;
//      sdATMSVC: SocketDomain := AF_ATMSVC;
//      sdAX25: SocketDomain := AF_AX25;
//      sdBRIDGE: SocketDomain := AF_BRIDGE;
//      sdDECnet: SocketDomain := AF_DECnet;
//      sdAECONET: SocketDomain := AF_ECONET;
//      sdKEY: SocketDomain := AF_KEY;
//      sdLLC: SocketDomain := AF_LLC;
//      sdLOCAL: SocketDomain := AF_LOCAL;
//      sdNETBEUI: SocketDomain := AF_NETBEUI;
//      sdNETLINK: SocketDomain := AF_NETLINK;
//      sdNETROM: SocketDomain := AF_NETROM;
//      sdPACKET: SocketDomain := AF_PACKET;
//      sdPPPOX: SocketDomain := AF_PPPOX;
//      sdROSE: SocketDomain := AF_ROSE;
//      sdROUTE: SocketDomain := AF_ROUTE;
//      sdSECURITY: SocketDomain := AF_SECURITY;
//      sdSNA: SocketDomain := AF_SNA;
//      sdTIPC: SocketDomain := AF_TIPC;
//      sdUNIX: SocketDomain := AF_UNIX;
//      sdWANPIPE: SocketDomain := AF_WANPIPE;
//      sdX25: SocketDomain := AF_X25;
      else begin
        Result := ssUnsupDomain;
        Exit;
      end;
  end;

  //- Create the soccket
  Socket.Handle := Posix.SysSocket.Socket(SocketDomain,SocketKind,SocketProtocol);
  if Socket.Handle<cZero then begin
    Result := SocketStatus(GetLastError());
  end else begin
    Result := ssSuccess;
  end;
end;

function TTargetSockets.Shutdown(Socket: TSocket; Opts: TShutdownOptions): TSocketStatus;
var
  shutdownOpt: int32;
begin
  shutdownOpt := 0;
  case Opts of
    soSending: shutdownOpt := cSD_RECEIVE;
    soReceiving: shutdownOpt := cSD_SEND;
    soBoth: shutdownOpt := cSD_BOTH;
  end;
  // make the call and return the result.
  if Posix.SysSocket.shutdown(Socket.Handle,shutdownOpt)=cZero then begin
    Result := TSocketStatus.ssSuccess;
  end else begin
    Result := SocketStatus(GetLastError());
  end;
end;

function TTargetSockets.Connect(Socket: TSocket; NetAddress: TNetworkAddress): TSocketStatus;
begin
  case Socket.Domain of
    sdIPv4: Result := ConnectIPv4( Socket, NetAddress );
    sdIPv6: Result := ConnectIPv6( Socket, NetAddress );
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
  iResult := Posix.SysSocket.recv(Socket.Handle,Data^,MaxSize,0);
  if iResult = cSOCKET_ERROR then begin
    Result := SocketStatus(GetLastError);
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
  iResult := Posix.SysSocket.send(Socket.Handle,Data^,Size,0);
  if iResult = cSOCKET_ERROR then begin
    Result := SocketStatus(GetLastError);
  end else begin
    Sent := iResult;
    Result := TSocketStatus.ssSuccess;
  end;
end;

function TTargetSockets.DataWaiting( Socket: TSocket ): int32;
var
  bytes: int32;
begin
  ioctl(Socket.Handle, FIONREAD, @bytes);
  Result := bytes;
end;

{$endif}
{$endif}
end.


