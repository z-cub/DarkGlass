unit darkvulkangen.ast.parameter.standard;

interface
uses
  darkIO.streams,
  darkvulkangen.ast,
  darkvulkangen.ast.node.standard;

type
  TdvParameter = class( TdvASTNode, IdvParameter )
  private
    fProtection: TParameterProtection;
    fTypedSymbol: IdvTypedSymbol;
  private
    function getTypedSymbol: IdvTypedSymbol;
    function getProtection: TParameterProtection;
    procedure setProtection( value: TParameterProtection );
    function AsString: string;
  protected
    function InsertChild( node: IdvASTNode ): IdvASTNode; override;
    function WriteToStream( Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32 ): boolean; override;
  public
    constructor Create( name: string; datatype: string; Protection: TParameterProtection = TParameterProtection.ppNone ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  darkvulkangen.ast.typedsymbol.standard,
  darkLog;

{ TdvParameter }

function TdvParameter.AsString: string;
begin
  case fProtection of
    ppOut: Result := 'out ';
    ppIn: Result := 'const ';
    ppVar: Result := 'var ';
    else begin
      Result := '';
    end;
  end;
  Result := Result + fTypedSymbol.AsString;
end;

constructor TdvParameter.Create( Name: string; Datatype: string; Protection: TParameterProtection = TParameterProtection.ppNone );
begin
   inherited Create;
   fTypedSymbol := TdvTypedSymbol.Create( Name, Datatype );
   fProtection := Protection;
end;

destructor TdvParameter.Destroy;
begin
  fTypedSymbol := nil;
  inherited Destroy;
end;

function TdvParameter.getProtection: TParameterProtection;
begin
  Result := fProtection;
end;

function TdvParameter.getTypedSymbol: IdvTypedSymbol;
begin
  Result := fTypedSymbol;
end;

function TdvParameter.InsertChild(node: IdvASTNode): IdvASTNode;
begin
  Result := nil;
  Log.Insert(ENoChildren,TLogSeverity.lsError);
end;

procedure TdvParameter.setProtection(value: TParameterProtection);
begin
  fProtection := Value;
end;

function TdvParameter.WriteToStream(Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32): boolean;
begin
  Stream.WriteString(AsString,UnicodeFormat);
  Result := True;
end;

end.

