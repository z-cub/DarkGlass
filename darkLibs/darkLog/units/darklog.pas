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
{$ifdef fpc} {$mode delphiunicode} {$endif}

interface
uses
  darklog.types,
  darklog.logentry,
  darklog.logtarget,
  darklog.log;

type
  /// <exclude/>
  TArrayOfString = darklog.types.TArrayOfString;
  /// <exclude/>
  TLogSeverity = darklog.types.TLogSeverity;
  /// <exclude/>
  TLogBindParameter = darklog.types.TLogBindParameter;
  /// <exclude/>
  TArrayOfLogBindParameter = darklog.types.TLogBindParameter;
  /// <exclude/>
  TTranslationResult = darklog.types.TTranslationResult;
  /// <exclude/>
  ELogEntry = darklog.logentry.ELogEntry;
  /// <exclude/>
  TLogEntryClass = darklog.logentry.TLogEntryClass;
  /// <exclude/>
  ILogTarget = darklog.logtarget.ILogTarget;
  /// <exclude/>
  ILog = darklog.log.ILog;


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



end.
