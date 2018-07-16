unit darkvulkangen.ast.define.standard;

interface
uses
  darkIO.streams,
  darkLog,
  darkvulkangen.ast,
  darkvulkangen.ast.node.standard;

type
  TdvDefine = class( TdvASTNode, IdvDefine )
  private
    fDefineName: string;
  private //- IdvDefine -//
    function getDefineName: string;
    procedure setDefineName( value: string );
  protected
    function InsertChild( node: IdvASTNode ): IdvASTNode; override;
    function WriteToStream( Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32 ): boolean; override;
  public
    constructor Create( aDefine: string ); reintroduce;
  end;

implementation

{ TdvDefine }

constructor TdvDefine.Create(aDefine: string);
begin
  inherited Create;
  fDefineName := aDefine;
end;

function TdvDefine.getDefineName: string;
begin
  Result := fDefineName;
end;

function TdvDefine.InsertChild(node: IdvASTNode): IdvASTNode;
begin
  Result := nil;
  Log.Insert(ENoChildren,TLogSeverity.lsError);
end;

procedure TdvDefine.setDefineName(value: string);
begin
  fDefineName := Value;
end;

function TdvDefine.WriteToStream(Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32): boolean;
begin
  Result := False;
  if not WriteBeforeNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  Stream.WriteString(getIndentation(Indentation)+'{$define '+fDefineName+'}',UnicodeFormat);
  if not WriteAfterNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  Result := True;
end;

end.

