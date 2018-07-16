program BasicPlatform;
{$APPTYPE CONSOLE}
uses
  darkThreading,
  darkPlatform,
  darkPlatform.messages,
  System.SysUtils;

var
  ThreadSystem: IThreadSystem;

function HandleMessage( aMessage: TMessage ): nativeuint;
var
  PlatformPipe: IMessagePipe;
  Response: nativeuint;
begin
  Result := 0;
  case aMessage.Value of

    MSG_PLATFORM_INITIALIZED: begin
      PlatformPipe := ThreadSystem.MessageBus.GetMessagePipe('platform');
      Response := PlatformPipe.SendMessageWait( MSG_PLATFORM_CREATE_WINDOW, 100, 100, 0, 0 );
    end

    else begin
      Result := 0;
    end;
  end;
end;

begin
  ThreadSystem := TThreadSystem.Create(0);
  TDarkPlatform.Initialize(ThreadSystem,HandleMessage);
  ThreadSystem.Run;
end.
