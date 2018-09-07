//------------------------------------------------------------------------------
// This file is part of the DarkGlass game engine project.
// More information can be found here: http://chapmanworld.com/darkglass
//
// DarkGlass is licensed under the MIT License:
//
// Copyright 2018 Craig Chapman
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the �Software�),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED �AS IS�, WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.
//------------------------------------------------------------------------------
unit darklog.logentry;
{$ifdef fpc} {$mode delphiunicode} {$endif}

interface
uses
  darklog.types;

type
  ///  <summary>
  ///    A base class to derrive custom log entries from.
  ///  </summary>
  ELogEntry = class( TInterfacedObject, IInterface )
  public
    constructor Register( EntryMessage: string );
    constructor Create( Severity: TLogSeverity; Parameters: array of TLogBindParameter ); reintroduce; overload;
    constructor Create( Severity: TLogSeverity ); reintroduce; overload;
  end;

  ///  <summary>
  ///    The class type of a log entry for registration and insertion of
  ///    log entries.
  ///  </summary>
  TLogEntryClass = class of ELogEntry;


implementation
uses
  darklog.log.standard;

constructor ELogEntry.Create(Severity: TLogSeverity; Parameters: array of TLogBindParameter);
begin
  inherited Create;
  Log.Insert( TLogEntryClass(ClassType), Severity, Parameters );
end;

constructor ELogEntry.Create(Severity: TLogSeverity);
begin
  inherited Create;
  Log.Insert( TLogEntryClass(ClassType), Severity );
end;

constructor ELogEntry.Register(EntryMessage: string);
begin
  inherited Create;
  Log.Register( TLogEntryClass(ClassType), EntryMessage);
end;

end.
