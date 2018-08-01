{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit pkg_darkGlassBindings;

{$warn 5023 off : no warning about unused units}
interface

uses
  darkglass.dynamic, darkglass, darkglass.static, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('pkg_darkGlassBindings', @Register);
end.
