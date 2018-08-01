{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit pkg_darkLibs;

{$warn 5023 off : no warning about unused units}
interface

uses
  darkcollections.dictionary, darkcollections.list, 
  darkcollections.ringbuffer, darkcollections.stack, darkcollections.types, 
  darkcollections.utils, darkDynlib, darkdynlib.dynlib.posix, 
  darkdynlib.dynlib.windows, darkHandles, darkio.buffers, darkio.streams, 
  darkio.buffer.standard, darkio.cyclicbuffer.standard, 
  darkio.filestream.standard, darkio.memorystream.standard, 
  darkio.stream.custom, darkio.unicodestream.custom, 
  darklog.logtarget.console, darklog.logtarget.logfile, 
  darklog.logtarget.stream, darklog, darklog.log.standard, 
  darklog.logtarget.console.standard, darklog.logtarget.logfile.standard, 
  darklog.logtarget.stream.standard, darklog.tokenizer.standard, 
  darkThreading, darkthreading.criticalsection.posix, 
  darkthreading.signaledcriticalsection.posix, 
  darkthreading.threadmethod.posix, darkThgreading.messaging.internal, 
  darkThreading.messagebus.standard, darkThreading.messagechannel.standard, 
  darkThreading.messagepipe.standard, darkThreading.threadpool.standard, 
  darkThreading.threadsystem.standard, darkthreading.criticalsection.windows, 
  darkThreading.signaledcriticalsection.windows, 
  darkthreading.threadmethod.windows, darkUnicode, darkUnicode.codec.standard, 
  darkwin32api.advapi32, darkwin32api.constants, darkwin32api.gdi32, 
  darkwin32api.kernel32, darkwin32api.types, darkwin32api.user32, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('pkg_darkLibs', @Register);
end.
