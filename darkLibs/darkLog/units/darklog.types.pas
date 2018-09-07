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
unit darklog.types;
{$ifdef fpc} {$mode delphiunicode} {$endif}

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


implementation

end.
