unit darkvulkangen.ast.ifdef.standard;

interface
uses
  darkIO.streams,
  darkvulkangen.ast,
  darkvulkangen.ast.node.standard;

type
  TdvIfDef = class( TdvASTNode, IdvIfDef )
  private
    fOnOneLine: boolean;
    fDefineName: string;
    fDefined: IdvASTNode;
    fUndefined: IdvASTNode;
  private
    function getOnOneLine: boolean;
    procedure setOnOneLine( value: boolean );
    function getDefineName: string;
    procedure setDefineName( value: string );
    function getDefined: IdvASTNode;
    function getUndefined: IdvASTNode;
  protected
    function InsertChild( node: IdvASTNode ): IdvASTNode; override;
    function WriteToStream( Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32 ): boolean; override;
  public
    constructor Create( aDefineName: string ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  darkLog;

{ TdvIfDef }

constructor TdvIfDef.Create( aDefineName: string );
begin
  inherited Create;
  fDefineName := aDefineName;
  fDefined := inherited InsertChild( TdvASTNode.Create );
  fUndefined := inherited InsertChild( TdvASTNode.Create );
  fOnOneLine := True;
end;

destructor TdvIfDef.Destroy;
begin
  fDefined := nil;
  fUndefined := nil;
  inherited Destroy;
end;

function TdvIfDef.getDefined: IdvASTNode;
begin
  Result := fDefined;
end;

function TdvIfDef.getDefineName: string;
begin
  Result := fDefineName;
end;

function TdvIfDef.getOnOneLine: boolean;
begin
  Result := fOnOneLine;
end;

function TdvIfDef.getUndefined: IdvASTNode;
begin
  Result := fUndefined;
end;

function TdvIfDef.InsertChild(node: IdvASTNode): IdvASTNode;
begin
  Result := nil;
  Log.Insert(ENoChildren,TLogSeverity.lsFatal);
end;

procedure TdvIfDef.setDefineName(value: string);
begin
  fDefineName := value;
end;

procedure TdvIfDef.setOnOneLine(value: boolean);
begin
  fOnOneLine := value;
end;

function TdvIfDef.WriteToStream(Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32): boolean;
begin
  Result := False;
  if not WriteBeforeNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  Stream.WriteString(getIndentation(Indentation)+'{$ifdef '+fDefineName+'}',UnicodeFormat);
  if not fOnOneLine then begin
    Stream.WriteString(sLineBreak,UnicodeFormat);
  end;
  if not fDefined.WriteToStream(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  if fUndefined.ChildCount>0 then begin
    Stream.WriteString(getIndentation(Indentation)+'{$else}',UnicodeFormat);
    if not fOnOneLine then begin
      Stream.WriteString(sLineBreak,UnicodeFormat);
    end;
    if not fUndefined.WriteToStream(Stream,UnicodeFormat,Indentation) then begin
      exit;
    end;
  end;
  Stream.WriteString(getIndentation(Indentation)+'{$endif}'+LineBreaks,UnicodeFormat);
  if not WriteAfterNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  Result := True;
end;

end.
