unit darkvulkangen.ast._function.standard;

interface
uses
  darkIO.streams,
  darkvulkangen.ast,
  darkvulkangen.ast.node.standard;

type
  TdvFunction = class( TdvASTNode, IdvFunction )
  private
    fHeader: IdvFunctionHeader;
    fBody: IdvCompoundStatement;
  private
    function getBodySection: IdvCompoundStatement;
    function getHeader: IdvFunctionHeader; //- IdvFuntion -//
  protected
    function InsertChild( node: IdvASTNode ): IdvASTNode; override;
  public
    constructor Create( name: string ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  darkLog,
  darkvulkangen.ast.functionheader.standard,
  darkvulkangen.ast.compoundstatement.standard;

{ TdvFunction }

constructor TdvFunction.Create( name: string );
begin
  inherited Create;
  fHeader := inherited InsertChild( TdvFunctionHeader.Create( name ) ) as IdvFunctionHeader;
  fBody := inherited InsertChild( TdvCompoundStatement.Create ) as IdvCompoundStatement;
  fBody.LineBreaks := 2;
end;

destructor TdvFunction.Destroy;
begin
  fBody := nil;
  fHeader := nil;
  inherited Destroy;
end;

function TdvFunction.getBodySection: IdvCompoundStatement;
begin
  Result := fBody;
end;

function TdvFunction.getHeader: IdvFunctionHeader;
begin
  Result := fHeader;
end;

function TdvFunction.InsertChild(node: IdvASTNode): IdvASTNode;
begin
  Result := nil;
  Log.Insert(ENoChildren,TLogSeverity.lsError);
end;


end.

