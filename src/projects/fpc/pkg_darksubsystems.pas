{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit pkg_darkSubSystems;

{$warn 5023 off : no warning about unused units}
interface

uses
  darkPlatform.messages, darkPlatform, darkplatform.display, 
  darkplatform.displaymanager, darkplatform.logfile, darkplatform.window, 
  darkplatform.windowmanager, darkplatform.appglue.android, 
  darkplatform.display.android, darkplatform.displaymanager.android, 
  darkplatform.mainloop.android, darkplatform.window.android, 
  darkplatform.windowmanager.android, darkplatform.displaymanager.common, 
  darkplatform.mainloop.common, darkplatform.windowmanager.common, 
  darkplatform.display.ios, darkplatform.displaymanager.ios, 
  darkplatform.mainloop.ios, darkplatform.window.ios, 
  darkplatform.windowmanager.ios, darkplatform.display.linux, 
  darkplatform.displaymanager.linux, darkplatform.linux.binding.x, 
  darkplatform.linux.binding.xlib, darkplatform.mainloop.linux, 
  darkplatform.window.linux, darkplatform.windowmanager.linux, 
  darkplatform.applicationdelegate.macos, darkplatform.display.macos, 
  darkplatform.displaymanager.macos, darkplatform.mainloop.macos, 
  darkplatform.window.macos, darkplatform.windowdelegate.macos, 
  darkplatform.windowmanager.macos, darkplatform.external.standard, 
  darkplatform.logfile.standard, darkplatform.mainloop.standard, 
  darkplatform.display.windows, darkplatform.displaymanager.windows, 
  darkplatform.mainloop.windows, darkplatform.window.windows, 
  darkplatform.windowmanager.windows, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('pkg_darkSubSystems', @Register);
end.
