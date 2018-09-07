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
unit darklog.logtarget.stream.standard;
{$ifdef fpc} {$mode delphiunicode} {$endif}

interface
uses
  darkIO.streams,
  darkLog.logtarget,
  darkLog.types;

type
  TStreamLogTarget = class( TInterfacedObject, ILogTarget )
  private
    fFormat: TUnicodeFormat;
    fStreamRef: IUnicodeStream;
  private //- ILogTarget -//
    procedure Insert( MessageClass: string; MessageVariables: array of TLogBindParameter; MessageText: string );
  public
    constructor Create( OutputStream: IUnicodeStream; Format: TUnicodeFormat ); reintroduce;
    destructor Destroy; override;
  end;

implementation

constructor TStreamLogTarget.Create(OutputStream: IUnicodeStream; Format: TUnicodeFormat);
begin
  inherited Create;
  fStreamRef := OutputStream;
  fFormat := Format;
end;

destructor TStreamLogTarget.Destroy;
begin
  fStreamRef := nil;
  inherited Destroy;
end;

procedure TStreamLogTarget.Insert( MessageClass: string; MessageVariables: array of TLogBindParameter; MessageText: string );
begin
  if not assigned(fStreamRef) then begin
    exit;
  end;
  fStreamRef.WriteString(MessageText,fFormat);
end;

end.
