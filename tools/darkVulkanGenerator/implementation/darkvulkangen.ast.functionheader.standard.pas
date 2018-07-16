unit darkvulkangen.ast.functionheader.standard;

interface
uses
  darkIO.streams,
  darkvulkangen.ast,
  darkvulkangen.ast.node.standard;

type
  TdvFunctionHeader = class( TdvASTNode, IdvFunctionHeader )
  private
    fName: string;
    fReturnType: string;
  private //- IdvFunctionHeader -//
    function getReturnType: string;
    procedure setReturnType( value: string );
    function getName: string;
    procedure setName( value: string );
  protected
    function WriteToStream( Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32 ): boolean; override;
  public
    constructor Create( name: string ); reintroduce;
  end;

implementation
uses
  sysutils;

{ TdvFunctionHeader }

constructor TdvFunctionHeader.Create(name: string);
begin
  inherited Create;
  setReturnType('');
  setName(Name);
end;

function TdvFunctionHeader.getName: string;
begin
  Result := fName;
end;

function TdvFunctionHeader.getReturnType: string;
begin
  if fReturnType='' then begin
    Result := 'void';
  end else begin
    Result := fReturnType;
  end;
end;

procedure TdvFunctionHeader.setName(value: string);
begin
  fName := Value;
end;

procedure TdvFunctionHeader.setReturnType(value: string);
begin
  if Uppercase(Trim(Value))='VOID' then begin
    fReturnType := '';
  end else begin
    fReturnType := Value;
  end;
end;

function TdvFunctionHeader.WriteToStream(Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32): boolean;
var
  idx: uint32;
begin
  Result := False;
  // Write the before node
  if not WriteBeforeNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  //- Write the keyword.
  if getReturnType='' then begin
    Stream.WriteString(getIndentation(Indentation)+'procedure '+fName,UnicodeFormat);
  end else begin
    Stream.WriteString(getIndentation(Indentation)+'function '+fName,UnicodeFormat);
  end;
  //- Write the parameters ( children ).
  if getChildCount>0 then begin
    Stream.WriteString('( ',UnicodeFormat);
    for idx := 0 to pred(getChildCount) do begin
      if not getChild(idx).WriteToStream(Stream, UnicodeFormat, 0 ) then begin
        exit;
      end;
      if idx<pred(getChildCount) then begin
        Stream.WriteString('; ',UnicodeFormat);
      end;
    end;
    Stream.WriteString(' )',UnicodeFormat);
  end;
  //- Write the keyword.
  if fReturnType<>'' then begin
    Stream.WriteString(': '+fReturnType,UnicodeFormat);
  end;
  //- Write the semi and after node
  Stream.WriteString(';'+LineBreaks,UnicodeFormat);
  if not WriteAfterNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  Result := True;
end;

end.

