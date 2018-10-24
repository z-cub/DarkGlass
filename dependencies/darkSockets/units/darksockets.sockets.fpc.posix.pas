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
unit darksockets.sockets.fpc.posix;

interface
{$IFDEF LINUX}
{$ifdef FPC}
uses
  de.sockets.sockets;

type

  { TTargetSockets }

  TTargetSockets = class( TInterfacedObject, ISockets )
  private // ISockets
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
{$ifdef LINUX}
{$ifdef fpc}
uses
  de.text,
  de.log,
  de.coax,
  BaseUnix,
  sockets;

type
  TSocket = de.sockets.sockets.TSocket;

type
  SocketOf = ^int32; // socket type is int32 (cint)

const
  // many functions test against zero for a result.
  cZero = 0;
  cINVALID_SOCKET = -1; // -1 ok on all but windows
  cSOCKET_ERROR = -1;
  // parameters to shutdown
  cSD_RECEIVE = 0;
  cSD_SEND = 1;
  cSD_BOTH = 2;

const
  FIONBIO = $5421;
  FIONREAD = $541B;

{==============================================================================}
{==============================================================================}

function SocketStatus(Status: int32): TSocketStatus;
begin
  case Status of
    EsockEACCESS:         Result := TSocketStatus.ssAccessDeniedException; // Access forbidden error
    EsockEBADF:           Result := TSocketStatus.ssBadFileException; // Alias: bad file descriptor
    EsockEFAULT:          Result := TSocketStatus.ssBadAddress; // Alias: an error occurred
    EsockEINTR:           Result := TSocketStatus.ssInterruptException; // Alias : operation interrupted
    EsockEINVAL:          Result := TSocketStatus.ssInvalidArgument; // Alias: Invalid value specified
    EsockEMFILE:          Result := TSocketStatus.ssBadFileException; // Error code ?
    EsockEMSGSIZE:        Result := TSocketStatus.ssMessageSize; // Wrong message size error
    EsockENOBUFS:         Result := TSocketStatus.ssNoBufferSpace; // No buffer space available error
    EsockENOTCONN:        Result := TSocketStatus.ssSocketNotConnected; // Not connected error
    EsockENOTSOCK:        Result := TSocketStatus.ssNotSocket; // File descriptor is not a socket error
    EsockEPROTONOSUPPORT: Result := TSocketStatus.ssProtocolNotSupported; // Protocol not supported error
    EsockEWOULDBLOCK:     Result := TSocketStatus.ssWouldBlock; // Operation would block error
    else                  Result := TSocketStatus.ssUnknown;
  end;
end;

function GetLastError: int32;
begin
  Result := sockets.socketerror;
end;

function IPv4StringToAddress( aIPAddress: string; var SAddr: sockaddr_in ): boolean;
var
  IPArray: TArrayOfString;
begin
  Result := False;
    // Break up the IP Address
  IPArray := text.Explode('.',aIPAddress);
  if length(IPArray)<>4 then begin
    Log.Insert(EAddressTranslation,TLogSeverity.lsFatal,[LogBind('domain','IPv4'), LogBind('address',aIPAddress)]);
    Exit;
  end;
  SAddr.sin_addr.s_bytes[1] := Coax.ToInteger(IPArray[0]);
  SAddr.sin_addr.s_bytes[2] := Coax.ToInteger(IPArray[1]);
  SAddr.sin_addr.s_bytes[3] := Coax.ToInteger(IPArray[2]);
  SAddr.sin_addr.s_bytes[4] := Coax.ToInteger(IPArray[3]);
  Result := True;
end;

function IPv6StringToAddress( aIPAddress: string; var SAddr: sockaddr_in6 ): boolean;
var
  IPArray: TArrayOfString;
begin
  Result := False; // unless..
  // Break up the IP Address
  IPArray := text.Explode(':',aIPAddress);
  if length(IPArray)<>8 then begin
    Log.Insert(EAddressTranslation,TLogSeverity.lsFatal,[ LogBind('domain','IPv6'), LogBind('address',aIPAddress) ]);
    Exit;
  end;
    SAddr.sin6_addr := Sockets.StrToHostAddr6(string(aIPAddress));
  Result := True;
end;

function IPv4AddressToString( SAddr: sockaddr_in; var aIPAddress: string): boolean;
begin
  Result := True;
  aIPAddress := Coax.ToString(SAddr.sin_addr.s_bytes[1])+'.'+
    Coax.ToString(SAddr.sin_addr.s_bytes[2])+'.'+
    Coax.ToString(SAddr.sin_addr.s_bytes[3])+'.'+
    Coax.ToString(SAddr.sin_addr.s_bytes[4]);
end;

function IPv6AddressToString( SAddr: sockaddr_in6; var aIPAddress: string): boolean;
begin
  Result := True;
  aIPAddress := Coax.ToString(SAddr.sin6_addr.s6_addr16[0])+':'+
  Coax.ToString(SAddr.sin6_addr.s6_addr16[1])+':'+
  Coax.ToString(SAddr.sin6_addr.s6_addr16[2])+':'+
  Coax.ToString(SAddr.sin6_addr.s6_addr16[3])+':'+
  Coax.ToString(SAddr.sin6_addr.s6_addr16[4])+':'+
  Coax.ToString(SAddr.sin6_addr.s6_addr16[5])+':'+
  Coax.ToString(SAddr.sin6_addr.s6_addr16[6])+':'+
  Coax.ToString(SAddr.sin6_addr.s6_addr16[7]);
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
    if sockets.fpbind(SocketOf(@Socket.Handle)^,@SAddr,Sizeof(SAddr))=cZero then begin
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
    if sockets.fpbind(SocketOf(@Socket.Handle)^,@SAddr6,Sizeof(SAddr6))=cZero then begin
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
  Size: uint32;
  SAddr: sockaddr_in;
begin
  Size := Sizeof(SAddr);
  SocketOf(@NewSocket.Handle)^:=sockets.fpaccept(SocketOf(@Socket.Handle)^,@SAddr,@Size);
  if SocketOf(@NewSocket.Handle)^=cINVALID_SOCKET then begin
    Result := SocketStatus(GetLastError);
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
  SAddr6: sockaddr_in6;
  Size: int32;
begin
  Size := Sizeof(SAddr6);
  SocketOf(@NewSocket.Handle)^:=sockets.fpaccept(SocketOf(@Socket.Handle)^,@SAddr6,@Size);
  if SocketOf(@NewSocket.Handle)^=cINVALID_SOCKET then begin
    Result := SocketStatus(GetLastError);
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
  SAddr: sockaddr_in;
begin
  FillChar(SAddr,Sizeof(SAddr),0);
  SAddr.sin_family:=AF_INET;
  if IPv4StringToAddress( NetAddress.IPAddress, SAddr ) then begin
    SAddr.sin_port := sockets.HtoNS(NetAddress.Port); //- SET PORT NUMBER
    //- Connect the socket.
    if sockets.fpconnect(SocketOf(@Socket.Handle)^,@SAddr,Sizeof(SAddr))=cZero then begin
       Result := TSocketStatus.ssSuccess;
    end else begin
      Result := SocketStatus(GetLastError);
    end;
  end else begin
    Result := TSocketStatus.ssBadAddress;
  end;
end;

function ConnectIPv6(Socket: TSocket; NetAddress: TNetworkAddress): TSocketStatus;
var
  SAddr6: Sockaddr_in6;
begin
  FillChar(SAddr6,Sizeof(SAddr6),0);
  SAddr6.sin6_family:=AF_INET6;
  if IPv6StringToAddress( NetAddress.IPAddress, SAddr6 ) then begin
    SAddr6.sin6_port:=sockets.HtoNS(NetAddress.Port); //- SET PORT NUMBER
    //- Connect
    if sockets.fpConnect(SocketOf(@Socket.Handle)^,@SAddr6,Sizeof(SAddr6))=cZero then begin
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
begin
  Result := TSocketStatus.ssSuccess; //[TODO] test for errors and return appropriate result.
  // which mode
  if IsBlocking then begin
    Flags:=fpFCntl(SocketOf(@Socket.Handle)^,F_GETFL);
    Flags:=Flags xor O_NONBLOCK;
    fpFCntl(SocketOf(@Socket.Handle)^,F_SETFL,Flags);
  end else begin
    Flags:=fpFCntl(SocketOf(@Socket.Handle)^,F_GETFL);
    Flags:=Flags or O_NONBLOCK;
    fpFCntl(SocketOf(@Socket.Handle)^,F_SETFL,Flags);
  end;
end;

function TTargetSockets.DataWaiting(Socket: TSocket): int32;
var
  bytes: int32;
begin
  FpIOCtl(Socket.Handle, FIONREAD, @bytes);
  Result := bytes;
end;

function TTargetSockets.Accept(Socket: TSocket; var NewSocket: TSocket; var NewNetAddress: TNetworkAddress): TSocketStatus;
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

function TTargetSockets.Close(Socket: TSocket): TSocketStatus;
begin
  if sockets.CloseSocket(SocketOf(@Socket.Handle)^)=cZero then begin
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
    ppCOMP: SocketProtocol := IPPROTO_COMP;
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
    ppSCTP: SocketProtocol := IPPROTO_SCTP;
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
    sdInfrared: SocketDomain := AF_IRDA;
    sdBluetooth: SocketDomain := AF_BLUETOOTH;
    sdAppleTalk: SocketDomain := AF_APPLETALK;
    sdIPX: SocketDomain := AF_IPX;
    sdASH: SocketDomain := AF_ASH;
    sdATMPVC: SocketDomain := AF_ATMPVC;
    sdATMSVC: SocketDomain := AF_ATMSVC;
    sdAX25: SocketDomain := AF_AX25;
    sdBRIDGE: SocketDomain := AF_BRIDGE;
    sdDECnet: SocketDomain := AF_DECnet;
    sdAECONET: SocketDomain := AF_ECONET;
    sdKEY: SocketDomain := AF_KEY;
    sdLLC: SocketDomain := AF_LLC;
    sdLOCAL: SocketDomain := AF_LOCAL;
    sdNETBEUI: SocketDomain := AF_NETBEUI;
    sdNETLINK: SocketDomain := AF_NETLINK;
    sdNETROM: SocketDomain := AF_NETROM;
    sdPACKET: SocketDomain := AF_PACKET;
    sdPPPOX: SocketDomain := AF_PPPOX;
    sdROSE: SocketDomain := AF_ROSE;
    sdROUTE: SocketDomain := AF_ROUTE;
    sdSECURITY: SocketDomain := AF_SECURITY;
    sdSNA: SocketDomain := AF_SNA;
    sdTIPC: SocketDomain := AF_TIPC;
    sdUNIX: SocketDomain := AF_UNIX;
    sdWANPIPE: SocketDomain := AF_WANPIPE;
    sdX25: SocketDomain := AF_X25;
    else begin
      Result := ssUnsupDomain;
      Exit;
    end;
  end;

  //- Create the soccket
  SocketOf(@Socket.Handle)^ := fpsocket(SocketDomain,SocketKind,SocketProtocol);
  if SocketOf(@Socket.Handle)^<cZero then begin
    Result := SocketStatus(GetLastError());
  end else begin
    Result := ssSuccess;
  end;
end;

function TTargetSockets.Shutdown(Socket: TSocket; Opts: TShutdownOptions): TSocketStatus;
var
  shutdownOpt: int32;
begin
  case Opts of
    soSending: shutdownOpt := cSD_RECEIVE;
    soReceiving: shutdownOpt := cSD_SEND;
    soBoth: shutdownOpt := cSD_BOTH;
  end;
  // make the call and return the result.
  if sockets.fpshutdown(SocketOf(@Socket.Handle)^,shutdownOpt)=cZero then begin
    Result := TSocketStatus.ssSuccess;
  end else begin
    Result := SocketStatus(GetLastError());
  end;
end;

function TTargetSockets.Listen(Socket: TSocket): TSocketStatus;
begin
  if sockets.fplisten(SocketOf(@Socket)^,SOMAXCONN)=cZero then begin
    Result := TSocketStatus.ssSuccess;
  end else begin
    Result := SocketStatus(GetLastError);
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
  iResult := Sockets.fprecv(SocketOf(@Socket.Handle)^,Data,MaxSize,0);
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
  iResult := sockets.fpSend(SocketOf(@Socket.Handle)^,Data,Size,0);
  if iResult = cSOCKET_ERROR then begin
    Result := SocketStatus(GetLastError);
  end else begin
    Sent := iResult;
    Result := TSocketStatus.ssSuccess;
  end;
end;

{$endif}
{$endif}
end.


