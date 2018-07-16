unit darkvulkangen.ast.ifndef.standard;

interface
uses
  darkIO.streams,
  darkvulkangen.ast,
  darkvulkangen.ast.node.standard;

type
  TdvIfNDef = class( TdvASTNode, IdvIfNDef )
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

{ TdvIfNDef }

constructor TdvIfNDef.Create( aDefineName: string );
begin
  inherited Create;
  fDefineName := aDefineName;
  fDefined := inherited InsertChild( TdvASTNode.Create );
  fUndefined := inherited InsertChild( TdvASTNode.Create );
  fOnOneLine := True;
end;

destructor TdvIfNDef.Destroy;
begin
  fDefined := nil;
  fUndefined := nil;
  inherited Destroy;
end;

function TdvIfNDef.getDefined: IdvASTNode;
begin
  Result := fDefined;
end;

function TdvIfNDef.getDefineName: string;
begin
  Result := fDefineName;
end;

function TdvIfNDef.getOnOneLine: boolean;
begin
  Result := fOnOneLine;
end;

function TdvIfNDef.getUndefined: IdvASTNode;
begin
  Result := fUndefined;
end;

function TdvIfNDef.InsertChild(node: IdvASTNode): IdvASTNode;
begin
  Result := nil;
  Log.Insert(ENoChildren,TLogSeverity.lsFatal);
end;

procedure TdvIfNDef.setDefineName(value: string);
begin
  fDefineName := value;
end;

procedure TdvIfNDef.setOnOneLine(value: boolean);
begin
  fOnOneLine := value;
end;

function TdvIfNDef.WriteToStream(Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32): boolean;
begin
  Result := False;
  if not WriteBeforeNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  Stream.WriteString(getIndentation(Indentation)+'{$ifndef '+fDefineName+'}',UnicodeFormat);
  if not fOnOneLine then begin
    Stream.WriteString(sLineBreak,UnicodeFormat);
  end;
  if not fUnDefined.WriteToStream(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  if fDefined.ChildCount>0 then begin
    Stream.WriteString(getIndentation(Indentation)+'{$else}',UnicodeFormat);
    if not fOnOneLine then begin
      Stream.WriteString(sLineBreak,UnicodeFormat);
    end;
    if not fDefined.WriteToStream(Stream,UnicodeFormat,Indentation) then begin
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

