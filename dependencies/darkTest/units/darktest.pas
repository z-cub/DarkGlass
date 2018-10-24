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

/// <summary>
///   darkTest is a simlpe wrapper around the dUnit testing framework for
///   Delphi, and the fpUnit framework for freepascal. <br />darkTest therefore
///   provides a compiler agnostic unit testing framework. It also generates
///   appropriate output to trigger a Jenkins build server to send test-failure
///   email notifications.
/// </summary>
unit darktest;
{$ifdef fpc} {$mode objfpc} {$endif}

interface
uses
  darktest.testcase.standard,
  darktest.application;

type
  /// <exclude/>
  ITestApplication = darktest.application.ITestApplication;
  /// <exclude/>
  TTestCase = darktest.testcase.standard.TTestCase;
  /// <exclude/>
  TTestCaseClass = class of TTestCase;

/// <summary>
///   Register a TTestCase derrived class as a test case with the unit-testing
///   framework.
/// </summary>
procedure RegisterTestCase( TestCaseClass: TTestCaseClass; TestSuiteName: string = '' ); overload;

/// <summary>
///   Returns a reference to the singleton instance of the test application
///   class.
/// </summary>
function Application: ITestApplication;

implementation

uses
  {$ifdef fpc}
    testregistry,
    fpcunit,
  {$else}
    TestFramework,
  {$endif}
    darktest.testrunner.standard;

var
  SingletonApplication: ITestApplication;

procedure RegisterTestCase( TestCaseClass: TTestCaseClass; TestSuiteName: string = '' ); overload;
begin
  {$ifdef fpc}
    RegisterTest(TestSuiteName,TestCaseClass);
  {$else}
    TestFramework.RegisterTest(TestCaseClass.Suite);
  {$endif}
end;


function Application: ITestApplication;
begin
  if not assigned(SingletonApplication) then begin
    SingletonApplication := TTestApplication.Create;
  end;
  Result := SingletonApplication;
end;

initialization
  SingletonApplication := nil;

finalization
  SingletonApplication := nil;

end.

