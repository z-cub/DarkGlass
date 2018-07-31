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
unit darklog;

interface

type
  TArrayOfString = array of string;

  ///  <summary>
  ///    An enumerated type used to indicate the severity of a log message
  ///    entered into the log.
  ///    Note: lsDebug severity log entries are ignored unless the log is
  ///    put into debugging mode (by setting it's debug mode property).
  ///  </summmary>
  TLogSeverity = ( lsInfo, lsHint, lsWarning, lsError, lsFatal, lsDebug );

  ///  <summary>
  ///    Bind parameters are used to inject parameters into a log message.
  ///  </summary>
  TLogBindParameter = record
    Name: string;
    Value: string;
  end;

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

  ///  <summary>
  ///    An array of bind parameters for injection into a log message.
  ///  </summary>
  TArrayOfLogBindParameter = array of TLogBindParameter;

  ///  <summary>
  ///    Used as a status variable when working with log translation files.
  ///  </sumamry>
  TTranslationResult = (
    forUnknown, //- An unknown error occured during the file operation.
    forInvalidFile, //- The file format is not valid.
    forCannotOverwrite, //- The Overwrite parameter for the calling operation is set false, and the file already exists.
    forPermissionDenied, //- Unable to access the file due to OS filesystem permissions.
    forFileNotFound, //- Unable to load the file as it cannot be found.
    forSuccess, //- The operation succeeded as expected.
    forMisMatch //- There are either entries missing in the translation file, or there are too many entries in the translation file (or both). The missing and supurflous entries arrays are set to indicate those entries which are mismatched.
  );

  ILogTarget = interface
    ['{B860E1A5-7245-4FC9-9EB1-66CC6E1F447F}']

    ///  <summary>
    ///    Implementations of ILogTarget should implement this method to
    ///    insert entries into the log. The MessageText parameter contains
    ///    the completed and translated message, and is the only parameter
    ///    which is required to be inserted. The parameters MessageClass and
    ///    MessageVariables are provided for more advanced use-cases, such as
    ///    message intercepters for reporting.
    ///  </summary>
    procedure Insert( MessageClass: string; MessageVariables: array of TLogBindParameter; MessageText: string );
  end;

  ILog = interface
    ['{587FD133-6206-461F-A9F7-7D07CF60F93B}']

    ///  Used when binding parameters into a log message.
    function LogBind( Name: string; Value: string ): TLogBindParameter;

    ///  <summary>
    ///    Registers a class of log entry with the log, along with the default
    ///    text for the log entry. A log entry class must be registered before
    ///    it may be inserted.
    ///    You may insert parameters to be bound to values at the time of
    ///    insertion into the DefaultText. To do so, insert the '(%' characters
    ///    followed by the parameter name, and then the '%)' characters.
    ///    For example: An error occurred while (%while%)
    ///    When a log entry is inserted for this class, the "while" parameter
    ///    may be substituted using LogBind().
    ///    Example:
    ///    Log.Insert( TMyEntryClass, lsInfo, [ LogBind('while','compiling') ] );
    ///  </summary>
    procedure Register( EntryClass: TLogEntryClass; DefaultText: string ); overload;

    ///  <summary>
    ///    Inserts a log entry into the log.
    ///    The EntryClass parameter is used to determine the default text for
    ///    the log entry as specified when the EntryClass was registered
    ///    with the Register() message. This default text may be overriden if
    ///    a translation file has been loaded.
    ///    The severity parameter is an enumeration type used to differentiate
    ///    between simple informative messages and errors when inserted into
    ///    the log.
    ///    The additional parameter is an array of parameters to be inserted
    ///    into the log message text. The array has a stride of two, where
    ///    the first entry is the name of a parameter within the message text
    ///    and the second is the value to substitute that in place of the
    ///    parameter.
    ///    Returns the string that is actually inserted, after translation.
    ///  </summary>
    function Insert( EntryClass: TLogEntryClass; Severity: TLogSeverity; Additional: array of TLogBindParameter ): string; overload;

    ///  <summary>
    ///    As the above Insert method, but no additional parameters are provided.
    ///    This method is convenient for log entries which do not require parameters.
    ///  </summary>
    function Insert( EntryClass: TLogEntryClass; Severity: TLogSeverity ): string; overload;

    ///  <summary>
    ///    Saves the log messages into a file, which may then be translated
    ///    to another language and loaded using a call to LoadTranslationsFile()
    ///  </summary>
    function SaveTranslationsToFile( Filepath: string; Overwrite: boolean = false ): TTranslationResult;

    ///  <summary>
    ///    Loads log messages from a file, replacing those already registered
    ///    with the system. Note that log messages for which a class is not
    ///    registered will be ignored. Log messages for which there is no
    ///    translation will be left at their default values.
    ///    When the log translation is loaded but has either missing or
    ///    supurflous entries in the file, the Missing and,or Supurflous arrays
    ///    are returned accordingly. Check the result enumeration to detect
    ///    cases in which messages are supurflously loaded, or are missing.
    ///  </summary>
    function LoadTraslationsFromFile( Filepath: string; var Supurflous: TArrayOfString; var Missing: TArrayOfString ): TTranslationResult;

    ///  <summary>
    ///    Adds a target for log messages.
    ///  </summary>
    procedure AddLogTarget( aLogTarget: ILogTarget );

    ///  <summary>
    ///    Removes a log target by reference.
    ///  </summary>
    procedure RemoveLogTarget( aLogTarget: ILogTarget );

    ///  <summary>
    ///    Clears all log targets.
    ///  </summary>
    procedure ClearLogTargets;

  end;

///  <summary>
///    Scope convenience wrapper around the ILog.LogBind() method of the
///    singleton instance of ILog.
///  </summary>
function LogBind( Name: string; Value: string ): TLogBindParameter;

///  <summary>
///    Returns the singleton instance of ILog.
///  </summary>
function Log: ILog;

implementation
uses
  darklog.log.standard;

function Log: ILog;
begin
  Result := darklog.log.standard.Log;
end;

function LogBind( Name: string; Value: string ): TLogBindParameter;
begin
  Result := Log.LogBind(Name,Value);
end;

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
