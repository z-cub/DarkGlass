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
unit darktcp.client.standard;

interface
uses
  darkIO.buffers,
  darkSockets,
  darkTcp.connection,
  darkTcp.types,
  darkTcp.client;

type
  TTCPClient = class( TInterfacedObject, ITCPClient )
  private
    fAddress: string;
    fPort: uint32;
    fProtocol: TInternetProtocol;
    fBlocking: boolean;
    fConnected: boolean;
    fSockets: ISockets;
    fSocket: TSocket;
    fOnConnectionLost: TConnectionLostEvent;
  private //- ITCPConnection -//
    function Recv( max: int32 ): IUnicodeBuffer;
    function Send( aBuffer: IUnicodeBuffer ): int32;
    function getAddress: string;
    function getPort: uint32;
    function getProtocol: TInternetProtocol;
    function getBlocking: boolean;
    function getOnConnectionLost: TConnectionLostEvent;
    procedure setOnConnectionLost( value: TConnectionLostEvent );
  private //- ITCPClient -//
    function getBytesOnSocket: int32;
    function getConnected: boolean;
    procedure setConnected( value: boolean );
    procedure setAddress( value: string );
    procedure setPort( value: uint32 );
    procedure setProtocol( value: TInternetProtocol );
    procedure setBlocking( value: boolean );
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;


implementation
uses
  sysutils,
  darkLog,
  darkSockets.sockets.standard;


type
  ETCPClientSocketsError = class(ELogEntry);

{ TTCPClient }

constructor TTCPClient.Create;
begin
  inherited Create;
  fOnConnectionLost := nil;
  fAddress := '127.0.0.1';
  fPort := 53281;
  fProtocol := TInternetProtocol.IPv4;
  fBlocking := False;
  fConnected := False;
  fSockets := TSockets.Create;
end;

destructor TTCPClient.Destroy;
begin
  if getConnected then begin
    setConnected(FALSE);
  end;
  fSockets := nil;
  inherited Destroy;
end;

function TTCPClient.getAddress: string;
begin
  Result := fAddress;
end;

function TTCPClient.getBlocking: boolean;
begin
  Result := fBlocking;
end;

function TTCPClient.getBytesOnSocket: int32;
begin
  Result := fSockets.DataWaiting(fSocket);
end;

function TTCPClient.getConnected: boolean;
begin
  Result := fConnected;
end;

function TTCPClient.getOnConnectionLost: TConnectionLostEvent;
begin
  Result := fOnConnectionLost;
end;

function TTCPClient.getPort: uint32;
begin
  Result := fPort;
end;

function TTCPClient.getProtocol: TInternetProtocol;
begin
  Result := fProtocol;
end;

function TTCPClient.Recv(max: int32): IUnicodeBuffer;
var
  Recvd: int32;
  Stat: TSocketStatus;
  RecvBuffer: array of uint8;
begin
  Recvd := 0;
  Result := nil;
  if not getConnected then begin
    exit;
  end;
  if not assigned(fSockets) then begin
    Exit;
  end;
  SetLength(RecvBuffer,max);
  try
    Stat := fSockets.Recv(fSocket,@RecvBuffer[0],max,Recvd);
    if (Stat=TSocketStatus.ssWouldBlock) then begin
      Exit;
    end;
    if not (Stat=TSocketStatus.ssSuccess) then begin
      if assigned(fOnConnectionLost) then begin
        fOnConnectionLost(Self as ITCPConnection);
      end;
      Log.Insert(ETCPClientSocketsError,TLogSeverity.lsError,[LogBind('error','errno: '+IntToStr(int32(stat)))]);
      Exit;
    end;
    if Recvd=0 then begin
      Exit;
    end;
    //- Create result buffer
    Result := TBuffer.Create(Recvd);
    Result.InsertData(@RecvBuffer[0],0,Recvd);
  finally
    SetLength(RecvBuffer,0);
  end;
end;

function TTCPClient.Send(aBuffer: IUnicodeBuffer): int32;
var
  Sent: int32;
  Stat: TSocketStatus;
begin
  Sent := 0;
  Result := 0;
  if not getConnected then begin
    Exit;
  end;
  if not assigned(fSockets) then begin
    Exit;
  end;
  Stat := fSockets.Send(fSocket,aBuffer.getDataPointer,aBuffer.Size,sent);
  if not (Stat=TSocketStatus.ssSuccess) then begin
    Log.Insert(ETCPClientSocketsError,TLogSeverity.lsError,[LogBind('error','errno: '+IntToStr(int32(stat)))]);
  end;
  Result := Sent;
end;

procedure TTCPClient.setAddress(value: string);
begin
  if getConnected then begin
    setConnected(FALSE);
  end;
  fAddress := value;
end;

procedure TTCPClient.setBlocking(value: boolean);
var
  Stat: TSocketStatus;
begin
  if value then begin
    if getBlocking then begin
      Exit;
    end;
    if Self.getConnected then begin
      stat := fSockets.Blocking(fSocket,TRUE);
      if not (Stat=TSocketStatus.ssSuccess) then begin
        Log.Insert(ETCPClientSocketsError,TLogSeverity.lsError,[LogBind('error','errno: '+IntToStr(int32(stat)))]);
        Exit;
      end;
      fBlocking := True;
    end else begin
      fBlocking := True;
    end;
  end else begin
    if not getBlocking then begin
      Exit;
    end;
    stat := fSockets.Blocking(fSocket,FALSE);
    if not (Stat=TSocketStatus.ssSuccess) then begin
      Log.Insert(ETCPClientSocketsError,TLogSeverity.lsError,[LogBind('error','errno: '+IntToStr(int32(stat)))]);
      Exit;
    end;
    fBlocking := False;
  end;
end;

procedure TTCPClient.setConnected(value: boolean);
var
  Stat: TSocketStatus;
  NetAddress: TNetworkAddress;
begin
  fConnected := False;
  if value then begin
    if getConnected then begin
      Exit;
    end;
    //- Set protocol
    case getProtocol of
      TInternetProtocol.IPv4: fSocket.Domain := TSocketDomain.sdIPv4;
      TInternetProtocol.IPv6: fSocket.Domain := TSocketDomain.sdIPv6;
    end;
    //- Set kind and protocol
    fSocket.Kind := TSocketKind.skStream;
    fSocket.Protocol := TPacketProtocol.ppTCP;
    //- Set the address
    NetAddress.IPAddress := getAddress;
    NetAddress.Port := getPort;
    //- Create the socket
    Stat := fSockets.CreateSocket(fSocket);
    if not (Stat=TSocketStatus.ssSuccess) then begin
      Log.Insert(ETCPClientSocketsError,TLogSeverity.lsError,[LogBind('error','errno: '+IntToStr(int32(stat)))]);
      Exit;
    end;
    //- Set blocking / non blocking
    Stat := fSockets.Blocking(fSocket,getBlocking);
    if not (Stat=TSocketStatus.ssSuccess) then begin
      Log.Insert(ETCPClientSocketsError,TLogSeverity.lsError,[LogBind('error','errno: '+IntToStr(int32(stat)))]);
      Exit;
    end;
    //- Connect the socket
    Stat := fSockets.Connect(fSocket,NetAddress);
    if (Stat<>TSocketStatus.ssSuccess) or ((Stat=TSocketStatus.ssWouldBlock) and (not getBlocking)) then begin
      Log.Insert(ETCPClientSocketsError,TLogSeverity.lsError,[LogBind('error','errno: '+IntToStr(int32(stat)))]);
      exit;
    end;
    fConnected := True;
  end else begin
    if not getConnected then begin
      Exit;
    end;
    Stat := fSockets.Close(fSocket);
    if not (Stat=TSocketStatus.ssSuccess) then begin
      Log.Insert(ETCPClientSocketsError,TLogSeverity.lsError,[LogBind('error','errno: '+IntToStr(int32(stat)))]);
      Exit;
    end;
    fConnected := False;
  end;
end;

procedure TTCPClient.setOnConnectionLost(value: TConnectionLostEvent);
begin
  fOnConnectionLost := Value;
end;

procedure TTCPClient.setPort(value: uint32);
begin
  if (getConnected) then begin
    setConnected(FALSE);
  end;
  fPort := value;
end;

procedure TTCPClient.setProtocol(value: TInternetProtocol);
begin
  if (getConnected) then begin
    setConnected(FALSE);
  end;
  fProtocol := value;
end;

initialization
  Log.Register(ETCPClientSocketsError,'A socket error occurred: (%error%).');

end.
