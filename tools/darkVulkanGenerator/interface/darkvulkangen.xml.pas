unit darkvulkangen.xml;

interface
uses
  darkvulkangen.ast;

type
  ///  <summary>
  ///    Implementations of IdvXMLParser are intended to parse the
  ///    vk.xml file from kronos group, and to generate an abstract
  ///    syntax tree (AST) representing the output unit to be generated.
  ///  </summary>
  IdvXMLParser = interface
    function Parse( ASTRoot: IdvASTRootNode ): boolean;
  end;

  ///  <summary>
  ///    Factory for creating instances of IdvXMLParser.
  ///  </summary>
  TdvXMLParser = class
    class function Create( InputFile: string ): IdvXMLParser;
  end;


implementation
uses
  darkvulkangen.xml.standard;

{ TdvXMLParser }

class function TdvXMLParser.Create( InputFile: string ): IdvXMLParser;
begin
  result := darkvulkangen.xml.standard.TdvXMLParser.Create(Inputfile);
end;

end.
