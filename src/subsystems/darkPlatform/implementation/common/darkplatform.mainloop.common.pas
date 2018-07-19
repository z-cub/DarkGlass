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
unit darkplatform.mainloop.common;

interface
uses
  SyncObjs,
  darkThreading,
  darkplatform.window,
  darkplatform.displaymanager,
  darkplatform.windowmanager;

type
  TCommonMainLoop = class( TInterfacedObject, IThreadSubSystem )
  private //- Platform Message Channel
    fFirstRun: boolean;
    fPlatformChannel: IMessageChannel;
    fExternalPipe: IMessagePipe;
    fExternalChannelName: string;

  protected //- Window & Display management -//
    fDisplayManager: IDisplayManager;
    fWindowManager: IWindowManager;
  private
  private
    function doCreateWindow( ParamA: NativeUInt; ParamB: NativeUInt ): nativeuint;
    function HandlePlatformMessages( aMessage: TMessage ): nativeuint;
  protected //- For use from descendent -//
    //- Handles messages sent to the platform channel.
    procedure CheckMessages;
    procedure SendInitializedMessage;
  protected //- IThreadSubSystem -//
    function MainThread: boolean;
    function Dedicated: boolean;
    function Install( MessageBus: IMessageBus ): boolean; virtual;
    function Initialize( MessageBus: IMessageBus ): boolean; virtual;
    function Execute: boolean; virtual;
    procedure Finalize; virtual;

  protected //- Override me -//
    function CreateDisplayManager: IDisplayManager; virtual; abstract;
    function CreateWindowManager: IWindowManager; virtual; abstract;
    procedure HandleOSMessages; virtual; abstract;

  public
    constructor Create( ExternalChannelName: string ); reintroduce; virtual;
    destructor Destroy; override;
  end;

implementation
uses
  SysUtils,
  darkplatform.logfile,
  darkplatform.logfile.standard,
  darkHandles,
  darkIO.Buffers,
  darkPlatform.messages;

{ TCommonMainLoop }

const
  cPlatformChannel = 'platform';

procedure TCommonMainLoop.CheckMessages;
begin
  if fPlatformChannel.MessagesWaiting then begin
    fPlatformChannel.GetMessage(HandlePlatformMessages);
  end;
end;

constructor TCommonMainLoop.Create( ExternalChannelName: string );
begin
  inherited Create;
  fFirstRun := True;
  fPlatformChannel := nil;
  fExternalChannelName := ExternalChannelName;
  fDisplayManager := CreateDisplayManager;
  fWindowManager := CreateWindowManager;
end;

function TCommonMainLoop.Dedicated: boolean;
begin
  Result := False;
end;

destructor TCommonMainLoop.Destroy;
begin
  fPlatformChannel := nil;
  fExternalPipe := nil;
  fDisplayManager := nil;
  fWindowManager := nil;
  inherited Destroy;
end;

function TCommonMainLoop.doCreateWindow(ParamA: NativeUInt; ParamB: NativeUInt): nativeuint;
var
  NewWindow: IWindow;
begin
  NewWindow := fWindowManager.CreateWindow(fDisplayManager.Displays[0]);
  Result := NativeUInt(pointer(NewWindow));
end;

function TCommonMainLoop.Execute: boolean;
begin
  Result := True;
  if fFirstRun then begin
    fFirstRun := False;
    SendInitializedMessage;
  end;
  //- Handle messages from the OS.
  HandleOSMessages;
  //- Handle messages for platform
  CheckMessages;
  //- Render
  Sleep(0);
end;

procedure TCommonMainLoop.Finalize;
begin
  fPlatformChannel := nil;
  fExternalPipe := nil;
end;

function TCommonMainLoop.HandlePlatformMessages( aMessage: TMessage ): nativeuint;

  function PAnsiCharParamToString( pSrc: nativeuint ): string;
  var
    L: uint32;
    Buffer: IUnicodeBuffer;
    Filename: string;
  begin
    L := StrLen( PAnsiChar(aMessage.ParamA) );
    Buffer := TBuffer.Create(succ(L));
    Buffer.FillMem(0);
    Buffer.InsertData(Pointer(aMessage.ParamA),0,L);
    Result := Buffer.ReadString(TUnicodeFormat.utfANSI,TRUE);
  end;

var
  Filename: string;
  LogMessage: string;
  LogFile: ILogFile;

begin
  //- Handle Message.
  case aMessage.Value of

    TPlatform.MSG_PLATFORM_GET_LOGFILE_HANDLE: begin
      FileName := PAnsiCharParamToString( aMessage.ParamA );
      Result := THandles.CreateHandle( TLogFile.Create(Filename) );
    end;


    TPlatform.MSG_PLATFORM_LOG: begin
      LogMessage := PAnsiCharParamToString( aMessage.ParamA );
      if THandles.VerifyHandle( aMessage.ParamB, ILogFile ) then begin
        LogFile := THandles.InstanceOf( aMessage.ParamB ) as ILogFile;
        LogFile.WriteToLog(LogMessage);
      end;
    end;

    TPlatform.MSG_PLATFORM_CREATE_WINDOW: Result := doCreateWindow( aMessage.ParamA, aMessage.ParamB );
    else begin
      Result := 0;
    end;
  end;
end;

function TCommonMainLoop.Initialize( MessageBus: IMessageBus ): boolean;
begin
  fExternalPipe := MessageBus.GetMessagePipe(fExternalChannelName);
  Result := assigned(fPlatformChannel) and
            assigned(fExternalPipe);
end;

function TCommonMainLoop.Install( MessageBus: IMessageBus ): boolean;
begin
  Result := False;
  fPlatformChannel := MessageBus.CreateChannel(cPlatformChannel);
  if not assigned(fPlatformChannel) then begin
    exit;
  end;
  Result := True;
end;

function TCommonMainLoop.MainThread: boolean;
begin
  Result := True;
end;

procedure TCommonMainLoop.SendInitializedMessage;
begin
  fExternalPipe.SendMessage(TPlatform.MSG_PLATFORM_INITIALIZED);
end;

end.
