//------------------------------------------------------------------------------
// This file is part of the DarkGlass game engine project.
// More information can be found here: http://chapmanworld.com/darkglass
//
// DarkGlass is licensed under the MIT License:
//
// Copyright 2018 Craig Chapman
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the “Software”),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.
//------------------------------------------------------------------------------
unit darklog.log.standard;

interface
uses
  syncobjs,
  darkCollections.list,
  darkCollections.dictionary,
  darkCollections.utils,
  darkIO.streams,
  darkLog;

type
  ILogTargetList = {$ifdef fpc} specialize {$endif} IList<ILogTarget>;
  TLogTargetList = {$ifdef fpc} specialize {$endif} TList<ILogTarget>;

  TLog = class( TInterfacedObject, ILog )
  private
    fDebugMode: boolean;
    fMessages: IStringDictionary;
    fLogTargets: ILogTargetList;
    fCS: TCriticalSection;
  private //- ILog -//
    function getDebugMode: boolean;
    procedure setDebugMode( value: boolean );
    function LogBind( Name: string; Value: string ): TLogBindParameter;
    procedure Register( EntryClass: TLogEntryClass; DefaultText: string ); overload;
    procedure Register( EntryClass: string; DefaultText: string ); overload;
    function Insert( EntryClass: TLogEntryClass; Severity: TLogSeverity; Additional: array of TLogBindParameter ): string; overload;
    function Insert( EntryClass: TLogEntryClass; Severity: TLogSeverity ): string; overload;
    function Insert( EntryClass: string; Severity: TLogSeverity; Additional: array of TLogBindParameter ): string; overload;
    function Insert( EntryClass: string; Severity: TLogSeverity ): string; overload;
    function SaveTranslationsToFile( Filepath: string; Overwrite: boolean = false ): TTranslationResult;
    function LoadTraslationsFromFile( Filepath: string; var Supurflous: TArrayOfString; var Missing: TArrayOfString ): TTranslationResult;
    procedure AddLogTarget( aLogTarget: ILogTarget );
    procedure RemoveLogTarget( aLogTarget: ILogTarget );
    procedure ClearLogTargets;
  private
    function BindParameters( MessageText: string; Additional: array of TLogBindParameter  ): string;
    function BindParameter(Identifier: string; Additional: array of TLogBindParameter ): string;
    procedure ExportTranslations(FS: IUnicodeStream);
    function ImportTranslations(FS: IUnicodeStream; var Supurflous, Missing: TArrayOfString): TTranslationResult;
    function ImportJSONTranslations(FS: IUnicodeStream; Translations: IStringDictionary): boolean;
    procedure SkipWhitespace(FS: IUnicodeStream);
    function Poke( FS: IUnicodeStream ): char;
    function Expect(FS: IUnicodeStream; aChar: char): boolean;
    function GetJSONPair(FS: IUnicodeStream; var Name, Value: string): boolean;
    function GetJSONString(FS: IUnicodeStream; var aString: string): boolean;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

function Log: ILog;

implementation
uses
  sysutils,
  darkCollections.types,
  darklog.tokenizer.standard;

var
  SingletonLog: ILog = nil;

const
  CR = #13;
  LF = #10;
  TAB = #9;
  CRLF: string = CR + LF;

procedure TLog.ClearLogTargets;
begin
  fCS.Acquire;
  try
    fLogTargets.Clear;
  finally
    fCS.Release;
  end;
end;

constructor TLog.Create;
begin
  inherited Create;
  fCS := TCriticalSection.Create;
  fLogTargets := TLogTargetList.Create;
  fMessages := TStringDictionary.Create;
  fDebugMode := False;
end;

destructor TLog.Destroy;
begin
  {$ifdef fpc}
  fCS.Free;
  {$else}
  fCS.DisposeOf;
  {$endif}
  fMessages := nil;
  fLogTargets := nil;
  inherited Destroy;
end;

procedure TLog.AddLogTarget(aLogTarget: ILogTarget);
begin
  fCS.Acquire;
  try
    fLogTargets.Add(aLogTarget);
  finally
    fCS.Release;
  end;
end;

function TLog.BindParameter( Identifier: string; Additional: array of TLogBindParameter  ): string;
var
  idx: uint32;
  ltIdentifier: string;
begin
  Result := '';
  if Length(Additional)=0 then begin
    Exit;
  end;
  ltIdentifier := Lowercase(Trim(Identifier));
  for idx := 0 to pred(Length(Additional)) do begin
    if Lowercase(Trim(Additional[idx].Name)) = ltIdentifier then begin
      Result := Additional[idx].Value;
      Exit;
    end;
  end;
end;

function TLog.BindParameters( MessageText: string; Additional: array of TLogBindParameter ): string;
var
  Translated: string;
  Tokenizer: ILogMessageTokenizer;
  value: string;
  Token: TMessageToken;
begin
  Value := '';
  Translated := '';
  Tokenizer := TLogMessageTokenizer.Create(MessageText);
  repeat
    Token := Tokenizer.GetNextToken(value);
    case Token of
      tkUnknown: Translated := Translated + Value;
      tkIdentifier: Translated := Translated + BindParameter( Value, Additional );
      tkText: Translated := Translated + Value;
    end;
  until Token = tkEOF;
  Result := Translated;
end;

function TLog.Insert( EntryClass: string; Severity: TLogSeverity; Additional: array of TLogBindParameter ): string;
var
  Identifier: string;
  DefaultText: string;
  MessageText: string;
  idx: uint32;
begin
  Result := '';
  if (Severity = lsDebug) and (not fDebugMode) then begin
    exit;
  end;
  fCS.Acquire;
  try
    // Check that the entry class is registered
    Identifier := Lowercase(Trim(EntryClass));
    if not fMessages.getKeyExists(Identifier) then begin
      //- Insert log message stating that this log entry is not registered.
      Exit;
    end;
    //- Get the translated text and bind parameters to it.
    DefaultText := fMessages.getValueByKey(Identifier).Value;
    MessageText := BindParameters(DefaultText, Additional);
    //- Prefix the severity.
    case Severity of
      lsInfo:    MessageText := '[INFO] '+MessageText;
      lsHint:    MessageText := '[HINT] '+MessageText;
      lsWarning: MessageText := '[WARNING] '+MessageText;
      lsError:   MessageText := '[ERROR] '+MessageText;
      lsFatal:   MessageText := '[FATAL] '+MessageText;
      lsDebug:   MessageText := '[DEBUG] '+MessageText;
    end;
    //- Prefix a timestamp
    MessageText := '('+ string(FormatDateTime('YYYY-MM-DD HH:nn:SS:ssss',Now)) +') ' + MessageText + CR + LF;
    Result := MessageText;
    //- Insert the message into as many LogTargets as are registered.
    if fLogTargets.Count>0 then begin
      for idx := 0 to pred(fLogTargets.Count) do begin
        fLogTargets.Items[idx].Insert(EntryClass,Additional,MessageText);
      end;
    end;
    //- If the message is fatal, raise an exception.
    if Severity=lsFatal then begin
      raise Exception.Create(MessageText);
    end;
  finally
    fCS.Release;
  end;
end;

procedure TLog.ExportTranslations( FS: IUnicodeStream );
var
  idx: uint32;
  Key: string;
  Value: string;
begin
  if fMessages.Count>0 then begin
    FS.WriteBOM(TUnicodeFormat.utf8);
    FS.WriteString( '{'+sLineBreak, TUnicodeFormat.utf8 );
    for idx := 0 to pred(fMessages.Count) do begin
      Key := fMessages.KeyByIndex[idx];
      Value := fMessages.ValueByIndex[idx].Value;
      FS.WriteString( '"'+Key+'": ', TUnicodeFormat.utf8 );
      if idx=pred(fMessages.Count) then begin
        FS.WriteString( '"' + Value +'"'+sLineBreak, TUnicodeFormat.utf8 );
      end else begin
        FS.WriteString( '"' + Value +'",'+sLineBreak, TUnicodeFormat.utf8 );
      end;
    end;
    FS.WriteString( '}', TUnicodeFormat.utf8 );
  end;
end;

function TLog.getDebugMode: boolean;
begin
  Result := fDebugMode;
end;

function TLog.SaveTranslationsToFile(Filepath: string; Overwrite: boolean): TTranslationResult;
var
  FS: IUnicodeStream;
begin
  fCS.Acquire;
  try
    //- Overwrite check.
    if (FileExists(FilePath)) and (not Overwrite) then begin
      Result := TTranslationResult.forCannotOverwrite;
      Exit;
    end;
    //- Open file
    try
      FS := TFileStream.Create(Filepath,False);
    except
      on E: Exception do begin
        Result := TTranslationResult.forPermissionDenied;
        Exit;
      end;
    end;
    //- Export translations to file.
    try
      ExportTranslations( FS );
      Result := TTranslationResult.forSuccess;
    finally
      FS := nil;
    end;
  finally
    fCS.Release;
  end;
end;


procedure TLog.setDebugMode(value: boolean);
begin
  fDebugMode := Value;
end;

function TLog.GetJSONString( FS: IUnicodeStream; var aString: string ): boolean;
var
  CH: char;
  KeepGoing: boolean;
begin
  aString := '';
  SkipWhitespace( FS );
  if FS.getEndOfStream then begin
    Result := False;
    Exit;
  end;
  if not Expect(FS,'"') then begin
    Result := False;
    Exit;
  end;
  Poke(FS);
  //- Gether the string.
  KeepGoing := True;
  while (not FS.getEndOfStream) and (KeepGoing) do begin
	  CH := FS.ReadChar(TUnicodeFormat.utf8);
    if CH<>'"' then begin
      aString := aString + CH;
    end else begin
      KeepGoing := False;
    end;
  end;
  Result := True;
end;

function TLog.GetJSONPair( FS: IUnicodeStream; var Name: string; var Value: string ): boolean;
begin
  SkipWhiteSpace( FS );
  if FS.getEndOfStream then begin
    Result := False;
    Exit;
  end;
  //- Attempt to read a name
  if not GetJSONString( FS, Name ) then begin
    Result := False;
    Exit;
  end;
  //- Expect the divider
  SkipWhiteSpace( FS );
  if not Expect(FS,':') then begin
    Result := False;
    Exit;
  end;
  Poke(FS);
  //- Attempt to read a value
  SkipWhiteSpace( FS );
  if FS.getEndOfStream then begin
    Result := False;
    Exit;
  end;
  if not GetJSONString( FS, Value ) then begin
    Result := False;
    Exit;
  end;
  Result := True;
end;

function TLog.Expect( FS: IUnicodeStream; aChar: char ): boolean;
var
  CH: char;
  CurPos: uint64;
begin
  if FS.getEndOfStream then begin
    Result := False;
    Exit;
  end;
  CurPos := FS.getPosition;
  CH := FS.ReadChar(TUnicodeFormat.utf8);
  FS.setPosition(CurPos);
  Result := CH=aChar;
end;

procedure TLog.SkipWhitespace( FS: IUnicodeStream );
var
  CH: char;
  CurPos: uint64;
begin
  CurPos := FS.getPosition;
  CH := FS.ReadChar(TUnicodeFormat.utf8);
  while (CharInSet(CH,[CR,LF,TAB,' '])) and (not FS.getEndOfStream) do begin
    CurPos := FS.getPosition;
    CH := FS.ReadChar(TUnicodeFormat.utf8);
  end;
  //- back-up to before the previous character.
  FS.setPosition(CurPos);
end;

function TLog.ImportJSONTranslations( FS: IUnicodeStream; Translations: IStringDictionary ): boolean;
var
  Name: string;
  Value: string;
  KeepGoing: boolean;
begin
  Value := '';
  Name := '';
  Result := True; // unless..
  //- Check for open brace.
  SkipWhiteSpace( FS );
  if not Expect(FS,'{') then begin
    Result := False;
    Exit;
  end;
  Poke(FS);
  //- Loop through and get the pairs.
  KeepGoing := True;
  while KeepGoing do begin
    //- Get a pair.
    if not GetJSONPair( FS, Name, Value ) then begin
      Result := False;
      Exit;
    end;
    //- Handle pair here.
    Translations.SetValueByKey(name,TCollectableString.Create(Value));
    //- Look to see if there are more pairs.
    SkipWhiteSpace( FS );
    if FS.getEndOfStream then begin
      Result := False;
      Exit;
    end;
    KeepGoing := Expect(FS,',');
    if KeepGoing then begin
      Poke(FS);
    end;
  end;
  //- Expect the close brace.
  SkipWhitespace(FS);
  if not Expect(FS,'}') then begin
    Result := False;
    Exit;
  end;
end;

function TLog.ImportTranslations( FS: IUnicodeStream; var Supurflous, Missing: TArrayOfString ): TTranslationResult;
var
  Translations: IStringDictionary;
  idx: uint32;
  key: string;
begin
  SetLength(Supurflous,0);
  SetLength(Missing,0);
  //- Check for UTF8 BOM
  if not FS.ReadBOM(TUnicodeFormat.utf8) then begin
    Result := TTranslationResult.forInvalidFile;
    Exit;
  end;
  //- Import JSON translations
  Translations := TStringDictionary.Create;
  try
    if not ImportJSONTranslations( FS, Translations ) then begin
      Result := TTranslationResult.forInvalidFile;
      Exit;
    end;
    //- Comapre array sizes looking for supurflous.
    if fMessages.Count=0 then begin
      if Translations.Count>0 then begin
        Result := TTranslationResult.forMisMatch;
        SetLength(Supurflous,Translations.Count);
        for idx := 0 to pred(Translations.Count) do begin
          Supurflous[idx] := Translations.KeyByIndex[idx];
        end;
        Exit;
      end;
    end;
    //- Compare array sizes looking for missing.
    if Translations.Count=0 then begin
      if fMessages.Count>0 then begin
        Result := TTranslationResult.forMisMatch;
        SetLength(Missing,fMessages.Count);
        for idx := 0 to pred(fMessages.Count) do begin
          Missing[idx] := fMessages.KeyByIndex[idx];
        end;
        Exit;
      end;
    end;
    // If neither array has any entries, the import is a success.
    if (Translations.Count=0) and (fMessages.Count=0) then begin
      Result := TTranslationResult.forSuccess;
      Exit;
    end;
    Result := TTranslationResult.forSuccess;
    //- If we got here, test for supurflous entries in the translation file.
    for idx := 0 to pred(Translations.Count) do begin
      key := Lowercase( Translations.KeyByIndex[idx].Trim );
      if not fMessages.KeyExists[key] then begin
        SetLength(Supurflous,succ(Length(Supurflous)));
        Supurflous[pred(Length(Supurflous))] := key;
        Result := TTranslationResult.forMisMatch;
      end;
    end;
    //- Finally, load the keys in and watch for missing entries in the translation file.
    for idx := 0 to pred(fMessages.Count) do begin
      key := Lowercase(fMessages.KeyByIndex[idx].Trim);
      if Translations.KeyExists[key] then begin
        fMessages.ValueByIndex[idx].Value := Translations.ValueByKey[key].Value;
      end else begin
        Result := TTranslationResult.forMisMatch;
        SetLength(Missing,Succ(Length(Missing)));
        Missing[pred(Length(Missing))] := key;
      end;
    end;
  finally
    Translations := nil;
  end;
end;

function TLog.Insert(EntryClass: TLogEntryClass; Severity: TLogSeverity): string;
begin
  Result := '';
  if Severity = lsDebug then begin
    exit;
  end;
  Result := Insert(EntryClass.ClassName,Severity,[]);
end;

function TLog.LoadTraslationsFromFile(Filepath: string; var Supurflous, Missing: TArrayOfString): TTranslationResult;
var
  FS: IUnicodeStream;
begin
  fCS.Acquire;
  try
    //- Check the file exists
    if not FileExists(FilePath) then begin
      Result := TTranslationResult.forFileNotFound;
      Exit;
    end;
    //- Open file
    try
      FS := TFileStream.Create(FilePath,True);
    except
      on E: Exception do begin
        Result := TTranslationResult.forPermissionDenied;
        Exit;
      end;
    end;
    //- Import translations from file.
    try
      Result := ImportTranslations( FS, Supurflous, Missing );
    finally
      FS := nil;
    end;
  finally
    fCS.Release;
  end;
end;

function TLog.LogBind(Name, Value: string): TLogBindParameter;
begin
  Result.Name := Lowercase(Name.Trim);
  Result.Value := Value;
end;

function TLog.Poke( FS: IUnicodeStream ): char;
begin
  Result := FS.ReadChar(TUnicodeFormat.utf8);
end;

procedure TLog.Register(EntryClass: string; DefaultText: string);
var
  Identifier: string;
begin
  fCS.Acquire;
  try
    //- Add the log class and text.
    Identifier := Lowercase(Trim(EntryClass));
    if fMessages.KeyExists[Identifier] then begin
      raise Exception.Create('Log entry : '+EntryClass+' : is already registered.');
    end;
    fMessages.setValueByKey(Identifier,TCollectableString.Create(DefaultText));
  finally
    fCS.Release;
  end;
end;

procedure TLog.Register(EntryClass: TLogEntryClass; DefaultText: string);
begin
  Register(EntryClass.ClassName,DefaultText);
end;

procedure TLog.RemoveLogTarget(aLogTarget: ILogTarget);
var
  idx: Integer;
begin
  fCS.Acquire;
  try
    if fLogTargets.Count=0 then begin
      Exit;
    end;
    for idx := pred(fLogTargets.Count) downto 0 do begin
      if fLogTargets.Items[idx]=aLogTarget then begin
        fLogTargets.RemoveItem(idx);
      end;
    end;
  finally
    fCS.Release;
  end;
end;

function Log: ILog;
begin
  if not assigned(SingletonLog) then begin
    SingletonLog := TLog.Create;
  end;
  Result := SingletonLog;
end;

function TLog.Insert(EntryClass: string; Severity: TLogSeverity): string;
begin
  Result := '';
  if Severity = lsDebug then begin
    exit;
  end;
  Result := Insert(EntryClass,Severity,[]);
end;

function TLog.Insert(EntryClass: TLogEntryClass; Severity: TLogSeverity; Additional: array of TLogBindParameter): string;
begin
  Result := '';
  if Severity = lsDebug then begin
    exit;
  end;
  Result := Insert(EntryClass.ClassName,Severity,Additional);
end;

initialization

finalization
  SingletonLog := nil;

end.
