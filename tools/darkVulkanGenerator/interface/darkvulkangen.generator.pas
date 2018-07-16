unit darkvulkangen.generator;

interface

type
  IdvHeaderGenerator = interface
    ['{48F3BAEA-BAB7-4BE3-94D3-A16D4C6954FE}']

    ///  <summary>
    ///    Attempts to generate a Delphi vulkan header from the vk.xml
    ///    input file.
    ///  </summary>
    function Generate( InputFile: string; OutputDirectory: string ): boolean;
  end;

type
  TdvHeaderGenerator = class
    function Create: IdvHeaderGenerator;
  end;

implementation
uses
  darkvulkangen.generator.standard;

{ TdvHeaderGenerator }

function TdvHeaderGenerator.Create: IdvHeaderGenerator;
begin
  Result := darkvulkangen.generator.standard.TdvHeaderGenerator.Create;
end;

end.
