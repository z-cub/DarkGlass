{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit pkg_darkgraphics;

{$warn 5023 off : no warning about unused units}
interface

uses
  darkgraphics.context.dummy, darkgraphics.context, 
  darkgraphics.context.vulkan, darkgraphics.colors, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('pkg_darkgraphics', @Register);
end.
