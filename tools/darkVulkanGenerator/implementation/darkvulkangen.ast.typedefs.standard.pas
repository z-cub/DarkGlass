unit darkvulkangen.ast.typedefs.standard;

interface
uses
  darkIO.streams,
  darkLog,
  darkvulkangen.ast,
  darkvulkangen.ast.node.standard;

type
  TdvTypeDefs = class( TdvASTNode, IdvTypeDefs )
  protected
    function WriteToStream( Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32 ): boolean; override;
  end;

implementation

{ TdvTypeDefs }

function TdvTypeDefs.WriteToStream(Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32): boolean;
var
  idx: uint32;
begin
  Result := False;
  if not WriteBeforeNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  Stream.WriteString(sLineBreak+getIndentation(Indentation)+'type'+sLineBreak,UnicodeFormat);
  if getChildCount>0 then begin
    inc(Indentation,cIndentationStep);
    for idx := 0 to pred(getChildCount) do begin
      if not getChild(idx).WriteToStream(Stream,UnicodeFormat,Indentation) then begin
        exit;
      end;
    end;
    dec(Indentation,cIndentationStep);
  end;
  Stream.WriteString(LineBreaks,UnicodeFormat);
  if not WriteAfterNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  Result := True;
end;

end.

