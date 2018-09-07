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
unit darktcp.command;

interface
uses
  darkIO.buffers,
  darkTcp.connection;

type
  ///  <summary>
  ///    Datatype used to indicate the type of command being sent/received.
  ///    See TTCPCommand.SendCommand()
  ///  </summary>
  TCommandToken = uint32;

  ///  <summary>
  ///    TTCPCommand behaves as a namespace for methods that support
  ///    transmission and reception of 'commands' across a TCP connection.
  ///    See SendCommand() and ReceiveCommand().
  ///  </summary>
  TTCPCommand = class
  public

    ///  <summary>
    ///    Attempts to send a command to the tcp connection. This could be
    ///    an instruction sent from the client to a server, or it could be
    ///    the server response to a command from the client.
    ///    The command may be any operation you wish, where the value of the
    ///    CommandToken parameter is used to enumerate the possible commands.
    ///    Along with the command, you may send a buffer of data in the
    ///    CommandData parameter, this data may be interpreted on the other
    ///    end of the connection based on the CommandToken which accompanies it.
    ///  </summary>
    class function SendCommand( Connection: ITCPConnection; CommandToken: TCommandToken; CommandData: IUnicodeBuffer ): boolean;

    ///  <summary>
    ///    Attempts to Receive a command from the tcp connection.
    ///    See the SendCommand() method for more information regarding command
    ///    structure.
    ///  </summary>
    class function ReceiveCommand( Connection: ITCPConnection; var CommandToken: TCommandToken; CommandData: IUnicodeBuffer ): boolean;
  end;

implementation

const
  cBlockSize = 1024;

{ TTCPCommand }

class function TTCPCommand.ReceiveCommand(Connection: ITCPConnection; var CommandToken: uint32; CommandData: IUnicodeBuffer): boolean;
var
  TempBuffer: IUnicodeBuffer;
  TotalSize: uint32;
  TotalRecv: uint32;
begin
  Result := False;
  CommandData.Size := 0;
  if not assigned(Connection) then begin
    exit;
  end;
  //- Get some data from the server.
  TempBuffer := Connection.Recv(cBlockSize);
  //- We expect at least enough data to indicate the size of the data packet and the command.
  if (not assigned(TempBuffer)) or
     (TempBuffer.Size<(sizeof(uint32)+Sizeof(TCommandToken))) then begin
    exit;
  end;
  //- The first few bytes of the buffer contain the total size of the data.
  TotalRecv := TempBuffer.Size;
  TempBuffer.ExtractData(@TotalSize,0,sizeof(uint32));
  TempBuffer.ExtractData(@CommandToken,sizeof(uint32),sizeof(TCommandToken));
  //- Add the data to the response, excluding the TotalSize variable.
  CommandData.Size := TempBuffer.Size-(Sizeof(uint32)+sizeof(TCommandToken));
  if CommandData.Size=0 then begin
    Result := True;
    exit;
  end;
  TempBuffer.ExtractData(CommandData.DataPtr,sizeof(uint32)+sizeof(TCommandToken),CommandData.Size);
  //- Do we have all the data?
  if TotalRecv=TotalSize then begin
    Result := True;
    exit;
  end;
  //- So collect the remaining data..
  repeat
    TempBuffer := Connection.Recv(cBlockSize);
    if not assigned(TempBuffer) then begin
      continue;
    end;
    if TempBuffer.Size=0 then begin
      continue;
    end;
    CommandData.AppendData(TempBuffer.DataPtr,TempBuffer.Size);
    inc(TotalRecv,TempBuffer.Size);
  until TotalRecv>=TotalSize;
  Result := True;
end;


class function TTCPCommand.SendCommand(Connection: ITCPConnection; CommandToken: TCommandToken; CommandData: IUnicodeBuffer): boolean;
var
  TotalSize: uint32;
  SendBuffer: IUnicodeBuffer;
  TempBuffer: IUnicodeBuffer;
  Remaining: uint32;
  CurrentOffset: uint32;
  SourceOffset: uint32;
begin
  Result := False;
  if not assigned(Connection) then begin
    exit;
  end;
  //- The size of the request is the size of the Operation token added
  //- to a uint32 (containing the size) and then added to the size of the
  //- request buffer.
  if assigned(CommandData) then begin
    TotalSize := sizeof(TCommandToken)+ sizeof(uint32) + CommandData.Size;
  end else begin
    TotalSize := sizeof(TCommandToken)+ sizeof(uint32);
  end;
  //- We're going to send the request in blocks of cBlockSize
  //- If TotalSize<cBlockSize then just send it!
  if TotalSize<cBlockSize then begin
    SendBuffer := TBuffer.Create(0);
    SendBuffer.AppendData(@TotalSize,sizeof(uint32));
    SendBuffer.AppendData(@CommandToken,sizeof(TCommandToken));
    if assigned(CommandData) then begin
      SendBuffer.AppendData(CommandData.DataPtr,CommandData.Size);
    end;
    Result := Connection.Send(SendBuffer)=SendBuffer.Size;
    exit;
  end;
  if not assigned(CommandData) then begin
    Result := True;
    exit;
  end;
  //- If the total size > cBlockSize, then we're going to have to send the data
  //- in chunks. The first block is customized, so lets send that first.
  SendBuffer := TBuffer.Create(cBlockSize);
  SendBuffer.InsertData(@TotalSize,CurrentOffset,Sizeof(uint32));
  inc(CurrentOffset,sizeof(uint32));
  SendBuffer.InsertData(@CommandToken,CurrentOffset,Sizeof(TCommandToken));
  inc(CurrentOffset,sizeof(TCommandToken));
  TempBuffer := TBuffer.Create(cBlockSize-CurrentOffset);
  try
    CommandData.ExtractData(TempBuffer.DataPtr,0,TempBuffer.Size);
    Remaining := CommandData.Size-TempBuffer.Size;
    SourceOffset := TempBuffer.Size;
    SendBuffer.InsertData(TempBuffer.DataPtr,CurrentOffset,TempBuffer.Size);
    if Connection.Send(SendBuffer)<>SendBuffer.Size then begin
      exit;
    end;
  finally
    TempBuffer := nil;
  end;
  //- Now send the remaining complete blocks of data.
  while Remaining>cBlockSize do begin
    CommandData.ExtractData(SendBuffer.DataPtr,SourceOffset,cBlockSize);
    inc(SourceOffset,cBlockSize);
    dec(Remaining,cBlockSize);
    if Connection.Send(SendBuffer)<>SendBuffer.Size then begin
      exit;
    end;
  end;
  //- Now send the remaining data.
  if Remaining=0 then begin
    Result := True;
    exit;
  end;
  SendBuffer.Size := Remaining;
  CommandData.ExtractData(SendBuffer.DataPtr,SourceOffset,SendBuffer.Size);
  Result := Connection.Send(SendBuffer)=SendBuffer.Size;
  SendBuffer := nil;
end;

end.
