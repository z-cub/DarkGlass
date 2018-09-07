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
unit darktest.testlistener.standard;

interface
{$ifdef fpc}
uses
  classes,
  fpcunit,
  fpcunitreport;

type
  /// <exclude/>
  TDarkTestListener = class(TCustomResultsWriter, ITestListener)
  public //- ITestListener -//
    procedure AddFailure(ATest: TTest; AFailure: TTestFailure); override;
    procedure AddError(ATest: TTest; AError: TTestFailure); override;
    procedure StartTest(ATest: TTest); override;
    procedure EndTest(ATest: TTest); override;
    procedure StartTestSuite(ATestSuite: TTestSuite); override;
    procedure EndTestSuite(ATestSuite: TTestSuite); override;
  private
    fTabLevel: uint32;
    fTestFailed: boolean;
    fTestErrored: boolean;
    fTotalSuiteTests: uint32;
    fTotalSuiteErrors: uint32;
    fTotalSuiteFailures: uint32;
    fTotalTests: uint32;
    fTotalErrors: uint32;
    fTotalFailures: uint32;
    fOutputTest: string;
  private
    fName: string;
    function TabSpaces: string;

  public
    property Name: string read fName write fName;
    procedure Initialize;
    procedure Finalize;
  public
    function Results: uint32;
  end;

{$endif}
implementation
{$ifdef fpc}
uses
  SysUtils;

{$hints off}
procedure TDarkTestListener.AddFailure(ATest: TTest; AFailure: TTestFailure);
begin
  fTestFailed := True;
  inc(fTotalSuiteFailures);
  inc(fTotalFailures);
end;
{$hints on}

{$hints off}
procedure TDarkTestListener.AddError(ATest: TTest; AError: TTestFailure);
begin
  fTestErrored := True;
  inc(fTotalSuiteErrors);
  inc(fTotalErrors);
end;
{$hints on}

procedure TDarkTestListener.StartTest(ATest: TTest);
begin
  fTestFailed := False;
  fTestErrored := False;
	inc(fTotalSuiteTests);
  inc(fTotalTests);
  fOutputTest := '<test name="'+string(ATest.TestName)+'"';
end;

{$hints off}
procedure TDarkTestListener.EndTest(ATest: TTest);
begin
  if fTestErrored then begin
    fOutputTest := fOutputTest+' status="ERROR"/>';
  end else
  if fTestFailed then begin
    fOutputTest := fOutputTest+' status="FAILED"/>';
  end else begin
    fOutputTest := fOutputTest+' status="PASSED"/>';
  end;
  Writeln(TabSpaces+fOutputTest);
end;
{$hints on}

procedure TDarkTestListener.StartTestSuite(ATestSuite: TTestSuite);
begin
  if Trim(ATestSuite.TestSuiteName)<>'' then begin
    fTotalSuiteTests := 0;
    fTotalSuiteErrors := 0;
    fTotalSuiteFailures := 0;
    Writeln(TabSpaces+'<suite name="'+string(ATestSuite.TestSuiteName)+'">');
    inc(fTabLevel,2);
  end;
end;

procedure TDarkTestListener.EndTestSuite(ATestSuite: TTestSuite);
begin
  if Trim(ATestSuite.TestSuiteName)<>'' then begin
    Writeln( TabSpaces+'<summary tests="'+IntToStr(fTotalSuiteTests)+
                       '" sucesses="'+IntToStr(fTotalSuiteTests-(fTotalSuiteErrors+fTotalSuiteFailures))+
                       '" errors="'+IntToStr(fTotalSuiteErrors)+
                       '" failures="'+IntToStr(fTotalSuiteFailures)+
                       '" />' );
    dec(fTabLevel,2);
    Writeln(TabSpaces+'</suite>');
  end;
end;

function TDarkTestListener.TabSpaces: string;
var
  idx: uint32;
begin
  Result := '';
  for idx := 0 to pred(fTabLevel) do begin
    Result := Result + ' ';
  end;
end;

procedure TDarkTestListener.Initialize;
begin
  fTabLevel := 0;
  Writeln('<TestSuite name="'+Name+'">');
  inc(fTabLevel,2);
  // initialize
  fTotalSuiteTests := 0;
  fTotalSuiteErrors := 0;
  fTotalSuiteFailures := 0;
  fTotalTests := 0;
  fTotalErrors := 0;
  fTotalFailures := 0;
end;

procedure TDarkTestListener.Finalize;
begin
  Writeln( TabSpaces+'<summary tests="'+IntToStr(fTotalTests)+
                     '" Successes="'+IntToStr( fTotalTests-(fTotalErrors+fTotalFailures) )+
                     '" Errors="'+IntToStr( fTotalErrors )+
                     '" Failures="'+IntToStr( fTotalFailures )+
                     '"/>');
  fTabLevel := 0;
  Writeln('</TestSuite>');
end;

function TDarkTestListener.Results: uint32;
begin
  Results := fTotalErrors + fTotalFailures;
end;

{$endif}
end.

