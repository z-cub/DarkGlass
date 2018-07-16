unit darkvulkangen.ast.unitsection.standard;

interface
uses
  darkIO.streams,
  darkvulkangen.ast,
  darkvulkangen.ast.node.standard;

type
  TdvASTUnitSection = class( TdvASTNode, IdvASTUnitSection )
  private
    fSectionKind: TASTUnitSectionKind;
    fUsesList: IdvUsesList;
  private //- IdvASTUnitSection -//
    function getKind: TASTUnitSectionKind;
    function getUsesList: IdvUsesList;
    function getConstants: IdvConstants;
    function getTypes: IdvTypeDefs;
  protected
    function WriteToStream(Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32): boolean; override;
  public
    constructor Create( aSectionKind: TASTUnitSectionKind ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  sysutils;

{ TdvASTUnit }

constructor TdvASTUnitSection.Create( aSectionKind: TASTUnitSectionKind );
begin
  inherited Create;
  fSectionKind := aSectionKind;
  case fSectionKind of
    usInterface: fUsesList := InsertChild( TdvUsesList.Create ) as IdvUsesList;
    usImplementation: fUsesList := InsertChild( TdvUsesList.Create ) as IdvUsesList;
    else begin
      fUsesList := nil;
    end;
  end;
  SetLineBreaks(2);
end;

destructor TdvASTUnitSection.Destroy;
begin
  fUsesList := nil;
  inherited Destroy;
end;


function TdvASTUnitSection.getConstants: IdvConstants;
begin
  if getChildCount>0 then begin
    if Supports(getChild(pred(getChildCount)),IdvConstants) then begin
      Result := getChild(pred(getChildCount)) as IdvConstants;
      exit;
    end;
  end;
  Result := InsertChild(TdvConstants.Create) as IdvConstants;
end;

function TdvASTUnitSection.getKind: TASTUnitSectionKind;
begin
  Result := fSectionKind;
end;

function TdvASTUnitSection.getTypes: IdvTypeDefs;
begin
  if getChildCount>0 then begin
    if Supports(getChild(pred(getChildCount)),IdvTypeDefs) then begin
      Result := getChild(pred(getChildCount)) as IdvTypeDefs;
      exit;
    end;
  end;
  Result := InsertChild(TdvTypeDefs.Create) as IdvTypeDefs;
end;


function TdvASTUnitSection.getUsesList: IdvUsesList;
begin
  Result := fUsesList;
end;

function TdvASTUnitSection.WriteToStream(Stream: IUnicodeStream; UnicodeFormat: TUnicodeFormat; Indentation: uint32): boolean;
begin
  Result := False;
  if not WriteBeforeNode(Stream,UnicodeFormat, Indentation) then begin
    exit;
  end;
  case fSectionKind of
    usInterface: Stream.WriteString(getIndentation(Indentation)+'interface'+LineBreaks,UnicodeFormat);
    usImplementation: Stream.WriteString(getIndentation(Indentation)+'implementation'+LineBreaks,UnicodeFormat);
    usInitialization: Stream.WriteString(getIndentation(Indentation)+'initialization'+LineBreaks,UnicodeFormat);
    usFinalization: Stream.WriteString(getIndentation(Indentation)+'finalization'+LineBreaks,UnicodeFormat);
  end;
  //- Write the elements within the node.
  if not inherited WriteToStream( Stream, UnicodeFormat, Indentation ) then begin
    exit;
  end;
  Stream.WriteString(sLineBreak,UnicodeFormat);
  //- Write the after node.
  if not WriteAfterNode(Stream,UnicodeFormat,Indentation) then begin
    exit;
  end;
  Result := True;
end;

end.
