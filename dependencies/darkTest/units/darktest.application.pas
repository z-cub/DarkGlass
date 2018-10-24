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
unit darktest.application;

interface

type
  /// <summary>
  ///   The ITestApplication interface represents the unit test application.
  /// </summary>
  ITestApplication = interface
    ['{DBA5EC47-8908-41E6-9443-676BAF0082D3}']

    /// <summary>
    ///   Call Run() to execute all unit tests in the application.
    ///   As a return value, Run() returns the sum of all errors and/or
    ///   failures raised in the unit test cases. This value may be returned
    ///   as an application exit code for reporting to continuos integration
    ///   servers.
    /// </summary>
    function Run: uint32;

    function getName: string;
    procedure setName( aName: string );

    //- Properties -//
    property Name: string read getName write setName;
  end;

implementation

end.

