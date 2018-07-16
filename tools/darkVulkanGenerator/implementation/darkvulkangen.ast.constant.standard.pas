unit darkvulkangen.ast.constant.standard;

interface
uses
  darkIO.streams,
  darkLog,
  darkvulkangen.ast,
  darkvulkangen.ast.node.standard;

type
  TdvConstant = class( TdvASTNode, IdvConstant )
  private
    fName: string;
    fValue: string;
  private //- IdvConstant -//
    function getName: string;
    procedure setName( value: string );
    function getValue: string;
    procedure setValue( value: string );
  protected
    function InsertChild( node: IdvASTNode ): IdvASTNode; override;
    function WriteToStream( Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32 ): boolean; override;
  public
    constructor Create( Name: string; Value: string ); reintroduce;
  end;

implementation
uses
  sysutils;

{ TdvConstant }

constructor TdvConstant.Create(Name, Value: string);
begin
  inherited Create;
  SetName(Name);
  SetValue(Value)
end;

function TdvConstant.getName: string;
begin
  Result := fName;
end;

function TdvConstant.getValue: string;
begin
  Result := fValue;
end;

function TdvConstant.InsertChild(node: IdvASTNode): IdvASTNode;
begin
  Result := nil;
  Log.Insert(ENoChildren,TLogSeverity.lsError);
end;

procedure TdvConstant.setName(value: string);
begin
  fName := value;
end;

procedure TdvConstant.setValue(value: string);
begin
  fValue := Value;
  //- Convert binary.
  if Pos('0x',fValue)=1 then begin
    Delete(fValue,1,2);
    fValue := '$'+fValue;
    exit;
  end;
end;

function TdvConstant.WriteToStream(Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32): boolean;
begin
  Result := False;
  if not WriteBeforeNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  Stream.WriteString(getIndentation(Indentation)+fName+' = '+fValue+';'+sLineBreak,UnicodeFormat);
  if not WriteAfterNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  Result := True;
end;

end.

