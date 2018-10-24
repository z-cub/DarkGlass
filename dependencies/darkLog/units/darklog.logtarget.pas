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
unit darklog.logtarget;
{$ifdef fpc} {$mode delphiunicode} {$endif}

interface
uses
  darklog.types;

type
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


implementation

end.
