unit darkvulkangen.generator.standard;

interface
uses
  darkvulkangen.generator;

type
  TdvHeaderGenerator = class( TInterfacedObject, IdvHeaderGenerator )
  private //- IdvHeaderGenerator -//
    function Generate( InputFile: string; OutputDirectory: string ): boolean;
  end;

implementation
uses
  darkvulkangen.xml,
  darkvulkangen.ast;

{ TdvHeaderGenerator }

function TdvHeaderGenerator.Generate(InputFile, OutputDirectory: string): boolean;
var
  AST: IdvASTRootNode;
  Parser: IdvXMLParser;
  Parsed: boolean;
  Generated: boolean;
begin
  AST := TdvASTRootNode.Create;
  Parser := TdvXMLParser.Create(InputFile);
  try
    //- Attempt to parse the XML file to the AST.
    Parsed := Parser.Parse(AST);
    //- Attempt to output the AST.
    Generated := AST.WriteToDirectory( OutputDirectory, 0 );
  finally
    Parser := nil;
    AST := nil;
  end;
  Result := (Parsed AND Generated);
end;

end.
