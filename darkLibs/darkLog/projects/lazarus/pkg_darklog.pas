{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit pkg_darklog;

{$warn 5023 off : no warning about unused units}
interface

uses
  darklog.logtarget.stream, darklog.logtarget.stream.standard, darklog, 
  darklog.tokenizer.standard, darklog.log.standard, darklog.logtarget.console, 
  darklog.logtarget.console.standard, darklog.logtarget.logfile, 
  darklog.logtarget.logfile.standard, darklog.log, darklog.logentry, 
  darklog.logtarget, darklog.types, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('pkg_darklog', @Register);
end.
