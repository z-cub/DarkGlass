unit darkvulkangen.ast.compoundstatement.standard;

interface
uses
  darkIO.streams,
  darkvulkangen.ast,
  darkvulkangen.ast.node.standard;

type
  TdvCompoundStatement = class( TdvASTNode, IdvCompoundStatement )
  private
    fContent: string;
  private //- IdvCompoundStatement -//
    function getContent: string;
    procedure setContent( value: string );
  protected
    function InsertChild( node: IdvASTNode ): IdvASTNode; override;
    function WriteToStream( Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32 ): boolean; override;
  end;

implementation
uses
  darkLog;

{ TdvCompoundStatement }

function TdvCompoundStatement.getContent: string;
begin
  Result := fContent;
end;

function TdvCompoundStatement.InsertChild(node: IdvASTNode): IdvASTNode;
begin
  Result := nil;
  Log.Insert(ENoChildren,TLogSeverity.lsError);
end;

procedure TdvCompoundStatement.setContent(value: string);
begin
  fContent := value;
end;

function TdvCompoundStatement.WriteToStream(Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32): boolean;
begin
  Stream.WriteString(getIndentation(Indentation)+'begin'+sLineBreak,UnicodeFormat);
  inc(Indentation,cIndentationStep);
  Stream.WriteString(getIndentation(Indentation)+fContent+sLineBreak,UnicodeFormat);
  dec(Indentation,cIndentationStep);
  Stream.WriteString(getIndentation(Indentation)+'end;'+LineBreaks,UnicodeFormat);
  Result := True;
end;

end.

