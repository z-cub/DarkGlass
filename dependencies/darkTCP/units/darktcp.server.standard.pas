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
unit darktcp.server.standard;

interface
uses
  darkCollections.types,
  darkSockets,
  darkTcp.server,
  darkTcp.types,
  darkTcp.connection;

type
  TTCPServer = class( TInterfacedObject, ITCPServer )
  private
    fSockets: ISockets;
    fSocket: TSocket;
    fClients: ICollection;
    fEnabled: boolean;
    fProtocol: TInternetProtocol;
    fAddress: string;
    fPort: uint32;
    fBlocking: boolean;
    fOnConnectionLost: TConnectionLostEvent;
  private //- ITCPServer
    function getEnabled: boolean;
    function getAddress: string;
    function getPort: uint32;
    function getProtocol: TInternetProtocol;
    function getBlocking: boolean;
    function getClientCount: uint32;
    function getClient( idx: uint32 ): ITCPConnection;
    procedure setEnabled( value: boolean );
    procedure setAddress( value: string );
    procedure setPort( value: uint32 );
    procedure setProtocol( value: TInternetProtocol );
    procedure setBlocking( value: boolean );
    function getOnConnectionLost: TConnectionLostEvent;
    procedure setOnConnectionLost( value: TConnectionLostEvent );
    function Accept: ITCPConnection;
  private
    procedure DoDisconnection( Disconnected: ITCPConnection );
    procedure Shutdown;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  sysutils,
  darkCollections.list,
  darkLog,
  darkIO.buffers,
  darkSockets.sockets.standard;

type
  ETCPServerSocketsError = class(ELogEntry);

//============================================================================//
// Client connection implementation of ITCPConnection
//============================================================================//
type
  TTCPConnection = class( TInterfacedObject, ITCPConnection )
  private
    fSockets: ISockets;
    fSocket: TSocket;
    fAddress: TNetworkAddress;
    fBlocking: boolean;
    fOnConnectionLost: TConnectionLostEvent;
    fServerConnectionLostEvent: TConnectionLostEvent;
  private //- ITCPConnection
    function Recv( max: int32 ): IUnicodeBuffer;
    function Send( aBuffer: IUnicodeBuffer ): int32;
    function getAddress: string;
    function getPort: uint32;
    function getProtocol: TInternetProtocol;
    function getBlocking: boolean;
    procedure DoClientDisconnect;
    function getOnConnectionLost: TConnectionLostEvent;
    procedure setOnConnectionLost( value: TConnectionLostEvent );
  public
    constructor Create( aSockets: ISockets; aSocket: TSocket; anAddress: TNetworkAddress; ablocking: boolean; ServerConnectionLostEvent: TConnectionLostEvent ); reintroduce;
    destructor Destroy; override;
  end;

{ TTCPConnection }

constructor TTCPConnection.Create( aSockets: ISockets; aSocket: TSocket; anAddress: TNetworkAddress; ablocking: boolean; ServerConnectionLostEvent: TConnectionLostEvent );
begin
  inherited Create;
  fServerConnectionLostEvent := ServerConnectionLostEvent;
  fOnConnectionLost := nil;
  fSockets := aSockets;
  fSocket := aSocket;
  fAddress := anAddress;
  fBlocking := aBlocking;
end;

destructor TTCPConnection.Destroy;
begin
  if assigned(fSockets) then begin
    fSockets.Close(fSocket);
    fSockets.Shutdown(fSocket,TShutdownOptions.soBoth);
  end;
  fSockets := nil;
  inherited Destroy;
end;

function TTCPConnection.getAddress: string;
begin
  Result := fAddress.IPAddress;
end;

function TTCPConnection.getBlocking: boolean;
begin
  Result := fBlocking;
end;

function TTCPConnection.getOnConnectionLost: TConnectionLostEvent;
begin
  Result := fOnConnectionLost;
end;

function TTCPConnection.getPort: uint32;
begin
  Result := fAddress.Port;
end;

function TTCPConnection.getProtocol: TInternetProtocol;
begin
  if fSocket.Domain=TSocketDomain.sdIPv4 then begin
    Result := TInternetProtocol.IPv4;
  end else begin
    Result := TInternetProtocol.IPv6;
  end;
end;

procedure TTCPConnection.DoClientDisconnect;
begin
  if assigned(fServerConnectionLostEvent) then begin
    fServerConnectionLostEvent( Self );
  end;
  if assigned(fOnConnectionLost) then begin
    fOnConnectionLost( Self );
  end;
end;

function TTCPConnection.Recv( max: int32 ): IUnicodeBuffer;
var
  Recvd: int32;
  Stat: TSocketStatus;
  Buffer: IUnicodeBuffer;
begin
  Recvd := 0;
  Result := nil;
  if not assigned(fSockets) then begin
    Exit;
  end;
  Buffer := TBuffer.Create(max);
  Stat := fSockets.Recv(fSocket,Buffer.getDataPointer,Buffer.Size,Recvd);
  //- Check for typical connection error states..
  if (Stat=TSocketStatus.ssConnectionResetByPeer) or (Stat=TSocketStatus.ssConnectionDroppedOnReset) or (Stat=TSocketStatus.ssSocketClosed) then begin
    DoClientDisconnect;
    Exit;
  end;
  //- Wouldblock indicates zero data, but in non-blocking mode so simply continue.
  if (Stat=TSocketStatus.ssWouldBlock) then begin
    Exit;
  end;
  if not (Stat=TSocketStatus.ssSuccess) then begin
    Log.Insert(ETCPServerSocketsError,TLogSeverity.lsError,[Log.LogBind('error','errno: '+IntToStr(int32(stat)))]);
    Exit;
  end;
  if Buffer.Size=0 then begin
    //- Disconnect detected.
    Exit;
  end;
  Buffer.Size := Recvd;
  Result := Buffer;
end;

function TTCPConnection.Send(aBuffer: IUnicodeBuffer): int32;
var
  Sent: int32;
  Stat: TSocketStatus;
begin
  Sent := 0;
  if not assigned(fSockets) then begin
    Result := 0;
    Exit;
  end;
  Stat := fSockets.Send(fSocket,aBuffer.getDataPointer,aBuffer.Size,sent);
  if not (Stat=TSocketStatus.ssSuccess) then begin
    Log.Insert(ETCPServerSocketsError,TLogSeverity.lsError,[Log.LogBind('error','errno: '+IntToStr(int32(stat)))]);
  end;
  Result := Sent;
end;

procedure TTCPConnection.setOnConnectionLost(value: TConnectionLostEvent);
begin
  fOnConnectionLost := Value;
end;

//============================================================================//
//============================================================================//

type
  IConnectionList = {$ifdef fpc} specialize {$endif} IList<ITCPConnection>;
  TConnectionList = {$ifdef fpc} specialize {$endif} TList<ITCPConnection>;

{ TTCPServer }

function TTCPServer.Accept: ITCPConnection;
var
  Stat: TSocketStatus;
  NewSocket: TSocket;
  NewNetAddress: TNetworkAddress;
  NewClient: ITCPConnection;
begin
  if not getEnabled then begin
    Result := nil;
    Exit;
  end;
  {$ifdef fpc}{$hints off}{$endif}
  Stat := fSockets.Accept(fSocket,NewSocket,NewNetAddress);
  {$ifdef fpc}{$hints on}{$endif}
  if Stat=TSocketStatus.ssWouldBlock then begin
    Result := nil;
    Exit;
  end;
  if not (Stat=TSocketStatus.ssSuccess) then begin
    Log.Insert(ETCPServerSocketsError,TLogSeverity.lsError,[Log.LogBind('error','errno: '+IntToStr(int32(stat)))]);
  end;
  //- A new socket connection has been created.
  NewClient := TTCPConnection.Create(fSockets,NewSocket,NewNetAddress,getBlocking,{$ifdef fpc}@{$endif}DoDisconnection);
  IConnectionList(fClients).Add(NewClient);
  Result := NewClient;
end;

constructor TTCPServer.Create;
begin
  inherited Create;
  fOnConnectionLost := nil;
  fEnabled := False;
  fProtocol := TInternetProtocol.IPv6;
  fAddress := '0:0:0:0:0:0:0:1';
  fPort := 53281;
  fBlocking := False;
  fClients := TConnectionList.Create;
  fSockets := TSockets.Create;
end;

destructor TTCPServer.Destroy;
begin
  Shutdown;
  inherited Destroy;
end;

procedure TTCPServer.DoDisconnection( Disconnected: ITCPConnection );
var
  idx: uint32;
  Clients: IConnectionList;
begin
  try
    if assigned(fOnConnectionLost) then begin
      fOnConnectionLost( Disconnected );
    end;
  finally
    Clients := IConnectionList(fClients);
    for idx := pred(Clients.Count) downto 0 do begin
      if Clients.Items[idx]=Disconnected then begin
        Clients.RemoveItem(idx);
      end;
    end;
  end;
end;

function TTCPServer.getAddress: string;
begin
  Result := fAddress;
end;

function TTCPServer.getBlocking: boolean;
begin
  Result := fBlocking;
end;

function TTCPServer.getClient(idx: uint32): ITCPConnection;
begin
  result := IConnectionList(fClients).Items[idx];
end;

function TTCPServer.getClientCount: uint32;
begin
  Result := IConnectionList(fClients).Count;
end;

function TTCPServer.getEnabled: boolean;
begin
  Result := fEnabled;
end;

function TTCPServer.getOnConnectionLost: TConnectionLostEvent;
begin
  Result := fOnConnectionLost;
end;

function TTCPServer.getPort: uint32;
begin
  Result := fPort;
end;

function TTCPServer.getProtocol: TInternetProtocol;
begin
  Result := fProtocol;
end;

procedure TTCPServer.setAddress(value: string);
begin
  Shutdown;
  fAddress := Value;
end;

procedure TTCPServer.setBlocking(value: boolean);
begin
  if fBlocking=value then begin
    Exit;
  end;
  if not getEnabled then begin
    fBlocking := Value;
    Exit;
  end;
  fSockets.Blocking(fSocket,value);
end;

procedure TTCPServer.setEnabled(value: boolean);
var
  Stat: TSocketStatus;
  NetAddress: TNetworkAddress;
begin
  if value=getEnabled then begin
    Exit;
  end;
  if value then begin
    //- Set protocol
    case getProtocol of
      TInternetProtocol.IPv4: fSocket.Domain := TSocketDomain.sdIPv4;
      TInternetProtocol.IPv6: fSocket.Domain := TSocketDomain.sdIPv6;
    end;
    //- Set kind and protocol
    fSocket.Kind := TSocketKind.skStream;
    fSocket.Protocol := TPacketProtocol.ppTCP;
    //- Create the socket
    Stat := fSockets.CreateSocket(fSocket);
    if not (Stat=TSocketStatus.ssSuccess) then begin
      Log.Insert(ETCPServerSocketsError,TLogSeverity.lsError,[Log.LogBind('error','errno: '+IntToStr(int32(stat)))]);
      Exit;
    end;
    //- Bind the socket
    NetAddress.IPAddress := getAddress;
    NetAddress.Port := getPort;
    Stat := fSockets.Bind(fSocket,NetAddress);
    if not (Stat=TSocketStatus.ssSuccess) then begin
      Log.Insert(ETCPServerSocketsError,TLogSeverity.lsError,[Log.LogBind('error','errno: '+IntToStr(int32(stat)))]);
      Exit;
    end;
    //- Set blocking / non blocking
    Stat := fSockets.Blocking(fSocket,getBlocking);
    if not (Stat=TSocketStatus.ssSuccess) then begin
      Log.Insert(ETCPServerSocketsError,TLogSeverity.lsError,[Log.LogBind('error','errno: '+IntToStr(int32(stat)))]);
      Exit;
    end;
    //- Listen on the socket.
    Stat := fSockets.Listen(fSocket);
    if not (Stat=TSocketStatus.ssSuccess) then begin
      Log.Insert(ETCPServerSocketsError,TLogSeverity.lsError,[Log.LogBind('error','errno: '+IntToStr(int32(stat)))]);
      Exit;
    end;
    fEnabled := True;
  end else begin
    Shutdown;
  end;
end;

procedure TTCPServer.setOnConnectionLost(value: TConnectionLostEvent);
begin
  fOnConnectionLost := value;
end;

procedure TTCPServer.setPort(value: uint32);
begin
  Shutdown;
  fPort := Value;
end;

procedure TTCPServer.setProtocol(value: TInternetProtocol);
begin
  Shutdown;
  fProtocol := value;
end;

procedure TTCPServer.Shutdown;
begin
  if not getEnabled then begin
    Exit;
  end;
  fSockets.Close(fSocket);
  fSockets.Shutdown(fSocket,TShutdownOptions.soBoth);
end;


initialization
  Log.Register(ETCPServerSocketsError,'A socket error occurred: (%error%).');

end.
