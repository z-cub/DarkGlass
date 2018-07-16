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
unit darklog.tokenizer.standard;

interface

type
  TMessageToken = ( tkUnknown, tkEOF, tkText, tkIdentifier );

  ILogMessageTokenizer = interface
    ['{1301B1A4-137B-45F3-9E79-8EE644444DB8}']
    function getNextToken( var Value: string ): TMessageToken;
  end;

  TLogMessageTokenizer = class( TInterfacedObject, ILogMessageTokenizer )
  private
    fText: string;
    fCursor: uint32;
  private
    function getNextToken( var Value: string ): TMessageToken;
    function EOF: boolean;
    function Poke: char;
    function Peek: char;
    procedure Revoke;
    function ParseIdentifier(var Identifier: string): TMessageToken;
  public
    constructor Create( MessageText: string ); reintroduce;
    destructor Destroy; override;
  end;

implementation

{ TLogMessageParser }

constructor TLogMessageTokenizer.Create(MessageText: string);
begin
  inherited Create;
  fText := MessageText;
  {$ifdef NEXTGEN}
  fCursor := 0;
  {$else}
  fCursor := 1;
  {$endif}
end;

destructor TLogMessageTokenizer.Destroy;
begin
  inherited;
end;

function TLogMessageTokenizer.EOF: boolean;
var
  L: uint32;
begin
  L := Length(fText);
  {$ifdef nextgen}
    Result := fCursor>pred(L);
  {$else}
    Result := fCursor>L;
  {$endif}
end;

function TLogMessageTokenizer.Poke: char;
begin
  Result := Peek;
  inc(fCursor);
end;

function TLogMessageTokenizer.Peek: char;
begin
  Result := fText[fCursor];
end;

procedure TLogMessageTokenizer.Revoke;
begin
  dec(fCursor);
end;

function TLogMessageTokenizer.ParseIdentifier( var Identifier: string ): TMessageToken;
begin
  Poke; // remove the bracket.
  Identifier := '';
  while (not EOF) do begin
    if Peek='%' then begin
      Poke; //-Remove the percent.
      if Peek=')' then begin
        Poke; // remove the bracket
        Result := TMessageToken.tkIdentifier;
        Exit;
      end else begin
        Revoke; //- put back the percent
      end;
    end;
    Identifier := Identifier + Poke;
  end;
  Result := TMessageToken.tkUnknown;
end;

function TLogMessageTokenizer.getNextToken(var Value: string): TMessageToken;
var
  Text: string;
begin
  Value := '';
  //- Check for end of string.
  if EOF then begin
    Result := TMessageToken.tkEOF;
    Exit;
  end;
  //- Look for a parameter at the cursor location
  if Peek='(' then begin
    Poke; //- remove the '('
    if Peek='%' then begin
      Result := ParseIdentifier( Value );
      Exit;
    end;
    Revoke; //- It was not a parameter so put the % back.
  end;
  //- initialize the text variable.
  Text := '';
  //- Peek the next character.
  while (not eof) do begin
    if Peek='(' then begin
      Poke; // remove the %
      if not (Peek='%') then begin
        Text := Text + '(';
        Continue;
      end;
      //- We've found a parameter, so return the current token as text.
      Revoke; // restore the %
      Result := TMessageToken.tkText;
      Value := Text;
      Exit;
    end else begin
      Text := Text + Poke;
    end;
  end;
  Value := Text;
  Result := TMessageToken.tkText;
end;

end.
