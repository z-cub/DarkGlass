unit darkvulkangen.ast.astlabel.standard;

interface
uses
  darkIO.streams,
  darkvulkangen.ast,
  darkvulkangen.ast.node.standard;

type
  TdvLabel = class( TdvASTNode, IdvLabel )
  private
    fDelimiter: string;
    fLabelName: string;
  private //- IdvLabel
    function getLabelName: string;
    procedure setLabelName( value: string );
    function getDelimiter: string;
    procedure setDelimiter( value: string );
  protected
    function InsertChild( node: IdvASTNode ): IdvASTNode; override;
    function WriteToStream( Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32 ): boolean; override;
  public
    constructor Create( aLabelName: string ); reintroduce;
  end;

implementation
uses
  darkLog,
  sysutils;

{ TdvLabel }

constructor TdvLabel.Create(aLabelName: string);
begin
  inherited Create;
  fDelimiter := '';
  fLabelName := aLabelName;
  setLineBreaks(1);
end;

function TdvLabel.getDelimiter: string;
begin
  Result := fDelimiter;
end;

function TdvLabel.getLabelName: string;
begin
  Result := fLabelName;
end;

function TdvLabel.InsertChild(node: IdvASTNode): IdvASTNode;
begin
  Result := nil;
  Log.Insert(ENoChildren,TLogSeverity.lsFatal);
end;

procedure TdvLabel.setDelimiter(value: string);
begin
  fDelimiter := value;
end;

procedure TdvLabel.setLabelName(value: string);
begin
  fLabelName := Value;
end;

function TdvLabel.WriteToStream(Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32): boolean;
begin
  Result := False;
  if not WriteBeforeNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  Stream.WriteString(getIndentation(Indentation)+fLabelName,UnicodeFormat);
  Stream.WriteString(fDelimiter,UnicodeFormat);
  Stream.WriteString(LineBreaks,UnicodeFormat);
  if not WriteAfterNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  Result := True;
end;

end.
