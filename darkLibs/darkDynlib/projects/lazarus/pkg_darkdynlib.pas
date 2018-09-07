{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit pkg_darkdynlib;

{$warn 5023 off : no warning about unused units}
interface

uses
  darkdynlib.dynlib.posix, darkdynlib.dynlib.windows, darkdynlib.dynlib, 
  darkdynlib, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('pkg_darkdynlib', @Register);
end.
