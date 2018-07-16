unit darkvulkangen.ast.typedsymbol.standard;

interface
uses
  darkIO.streams,
  darkvulkangen.ast,
  darkvulkangen.ast.node.standard;

type
  TdvTypedSymbol = class( TdvASTNode, IdvTypedSymbol )
  private
    fName: string;
    fType: string;
  private //- IdvTypedSymbol -//
    function getName: string;
    procedure setName( value: string );
    function getType: string;
    procedure setType( value: string );
    function AsString: string;
  protected
    function InsertChild( node: IdvASTNode ): IdvASTNode; override;
    function WriteToStream( Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32 ): boolean; override;
  public
    constructor Create( Name: string; DataType: string ); reintroduce;
  end;

implementation
uses
  darkLog;

{ TdvTypedSymbol }

function TdvTypedSymbol.AsString: string;
begin
  Result := getName+': '+getType;
end;

constructor TdvTypedSymbol.Create( Name, DataType: string);
begin
  inherited Create;
  fName := Name;
  fType := DataType;
end;

function TdvTypedSymbol.getName: string;
begin
  Result := fName;
end;

function TdvTypedSymbol.getType: string;
begin
  Result := fType;
end;

function TdvTypedSymbol.InsertChild(node: IdvASTNode): IdvASTNode;
begin
  Result := nil;
  Log.Insert(ENoChildren,TLogSeverity.lsError);
end;

procedure TdvTypedSymbol.setName(value: string);
begin
  fName := value;
end;

procedure TdvTypedSymbol.setType(value: string);
begin
  fType := Value;
end;

function TdvTypedSymbol.WriteToStream(Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32): boolean;
begin
  Stream.WriteString(AsString,UnicodeFormat);
  Result := True;
end;

end.
