unit darkvulkangen.ast.comment.standard;

interface
uses
  darkIO.streams,
  darkvulkangen.ast,
  darkvulkangen.ast.node.standard;

type
  TdvASTComment = class( TdvASTNode, IdvASTComment )
  private
    fCommentString: string;
  private //- IdvASTComment
    function getCommentString: string;
    procedure setCommentString( value: string );
  protected
    function InsertChild(node: IdvASTNode): IdvASTNode; override;
    function WriteToStream( Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32 ): boolean; override;
  public
    constructor Create( aCommentString: string ); reintroduce;
    destructor Destroy; override;

  end;

implementation
uses
  darkLog,
  sysutils;

{ TdvASTComment }

constructor TdvASTComment.Create(aCommentString: string);
begin
  inherited Create;
  fCommentString := aCommentString;
  SetLineBreaks(2);
end;

destructor TdvASTComment.Destroy;
begin
  inherited Destroy;
end;


function TdvASTComment.getCommentString: string;
begin
  Result := fCommentString;
end;

procedure TdvASTComment.setCommentString(value: string);
begin
  fCommentString := value;
end;

function TdvASTComment.InsertChild(node: IdvASTNode): IdvASTNode;
begin
  Result := nil;
  Log.Insert(ENoChildren,TLogSeverity.lsError);
end;

function TdvASTComment.WriteToStream(Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32): boolean;
begin
  Result := False;
  if not WriteBeforeNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  if Trim(fCommentString)<>'' then begin
    Stream.WriteString(getIndentation(Indentation)+'{'+sLineBreak,UnicodeFormat);
    inc(Indentation,cIndentationStep);
    Stream.WriteString(getIndentation(Indentation)+fCommentString,UnicodeFormat);
    dec(Indentation,cIndentationStep);
    Stream.WriteString(getIndentation(Indentation)+sLineBreak+'}'+LineBreaks,UnicodeFormat);
  end;
  if not WriteAfterNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  Result := True;
end;

end.

