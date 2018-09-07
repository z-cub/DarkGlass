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
unit darktest.testrunner.standard;

interface
uses
  {$ifdef fpc}
    classes,
    fpcunit,
  {$endif}
    darktest;

type
  /// <exclude/>
  TTestApplication = class( TInterfacedObject, ITestApplication )
  private //- ITestApplication -//
    fName: string;
    function Run: uint32;
    function getName: string;
    procedure setName( aName: string );
  end;

implementation
uses
{$ifdef fpc}
  consoletestrunner,
  fpcunitreport,
  testregistry,
  darktest.testlistener.standard;
{$else}
  TestFramework,
  TextTestRunner;
{$endif}


function TTestApplication.Run: uint32;
{$ifdef fpc}
var
  fListener: TDarkTestListener;
  testResult: TTestResult;
begin
  fListener := TDarkTestListener.Create(nil);
  try
    testResult := TTestResult.Create;
    try
      fListener.Name := getName;
      fListener.Initialize;
      // Create the listener to listen to the results.
      testResult.AddListener(fListener);
      // Run the tests.
      GetTestRegistry.Run(testResult);
      // Capture the results.
      Result := fListener.Results;
    finally
      testResult.Free;
    end;
    fListener.Finalize;
  finally
    fListener.Free;
  end;
end;
{$else}
var
  R: TTestResult;
begin
  R := TextTestRunner.RunRegisteredTests();
  Result := R.ErrorCount + R.FailureCount;
end;
{$endif}

function TTestApplication.getName: string;
begin
  Result := fName;
end;

procedure TTestApplication.setName(aName: string);
begin
  fName := aName;
end;

end.

