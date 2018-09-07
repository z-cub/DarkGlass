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
unit darkThreading.threadpool.standard;
{$ifdef fpc} {$mode objfpc} {$endif}

interface
uses
  darkCollections.types,
  darkThreading;


type
  TThreadPool = class( TInterfacedObject, IThreadPool )
  private
    fRunning: boolean;
    fThreads: ICollection;
    fThreadMethods: array of IThreadMethod;
  private
    procedure CreateThreadMethods;
    procedure DisposeThreadMethods;
  private //- IThreadPool -//
    function getThreadCount: uint32;
    function getThread( idx: uint32 ): IPoolThread;
    function InstallThread( aThread: IPoolThread ): boolean;
    function Start: boolean;
    procedure Stop;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  sysutils,
  darkCollections.list,
  darkThreading.messagebus.standard,
{$ifdef MSWINDOWS}
  darkThreading.threadmethod.windows;
{$else}
  darkThreading.threadmethod.posix;
{$endif}

type
{$ifdef MSWINDOWS}
  TThreadMethod = TWindowsThreadMethod;
{$else}
  TThreadMethod = TPosixThreadMethod;
{$endif}

type
  IPoolThreadList = {$ifdef fpc} specialize {$endif} IList<IPoolThread>;
  TPoolThreadList = {$ifdef fpc} specialize {$endif} TList<IPoolThread>;

type
  TPoolThread = class( TThreadMethod )
  private
    fSubSystem: IPoolThread;
  private
    function InternalExecute: boolean;
  public
    constructor Create( SubSystem: IPoolThread );
  end;

constructor TPoolThread.Create(SubSystem: IPoolThread);
begin
  inherited Create;
  fSubSystem := SubSystem;
  inherited setExecuteMethod({$ifdef fpc}@{$endif}InternalExecute);
end;

function TPoolThread.InternalExecute: boolean;
begin
  Result := False;
  if not assigned(fSubSystem) then begin
    exit;
  end;
  Result := fSubSystem.Execute;
end;

constructor TThreadPool.Create;
begin
  inherited Create;
  fThreads := TPoolThreadList.Create;
  fRunning := False;
  SetLength(fThreadMethods,0);
end;

procedure TThreadPool.CreateThreadMethods;
var
  idx: int32;
begin
  if fRunning then begin
    exit;
  end;
  if IPoolThreadList(fThreads).Count=0 then begin
    exit;
  end;
  SetLength(fThreadMethods,IPoolThreadList(fThreads).Count);
  for idx := 0 to pred(IPoolThreadList(fThreads).Count) do begin
    fThreadMethods[idx] := TPoolThread.Create( IPoolThreadList(fThreads).Items[idx] );
  end;
  fRunning := True;
end;

destructor TThreadPool.Destroy;
begin
  if fRunning then begin
    Stop;
  end;
  fRunning := False;
  fThreads := nil;
  SetLength(fThreadMethods,0);
  inherited Destroy;
end;

procedure TThreadPool.DisposeThreadMethods;
var
  idx: int32;
begin
  if not fRunning then begin
    exit;
  end;
  if Length(fThreadMethods)=0 then begin
    exit;
  end;
  for idx := 0 to pred(Length(fThreadMethods)) do begin
    if not fThreadMethods[idx].Terminate(3000) then begin
      raise
        Exception.Create('Thread failed to terminate.');
    end;
  end;
end;

function TThreadPool.getThread(idx: uint32): IPoolThread;
begin
  Result := IPoolThreadList(fThreads).Items[idx];
end;

function TThreadPool.getThreadCount: uint32;
begin
  Result := IPoolThreadList(fThreads).Count;
end;

function TThreadPool.InstallThread(aThread: IPoolThread): boolean;
begin
  Result := False;
  if fRunning then begin
    exit;
  end;
  IPoolThreadList(fThreads).Add(aThread);
end;

function TThreadPool.Start: boolean;
var
  idx: int32;
  InitializeFailed: boolean;
begin
  Result := False;
  InitializeFailed := False;
  for idx := 0 to pred(IPoolThreadList(fThreads).Count) do begin
    if not IPoolThreadList(fThreads).Items[idx].Initialize then begin
      InitializeFailed := True;
    end;
  end;
  if InitializeFailed then begin
    Exit;
  end;
   Result := True;
  CreateThreadMethods;
end;

procedure TThreadPool.Stop;
var
  idx: int32;
begin
  DisposeThreadMethods;
  if IPoolThreadList(fThreads).Count=0 then begin
    exit;
  end;
  for idx := 0 to pred(IPoolThreadList(fThreads).Count) do begin
    IPoolThreadList(fThreads).Items[idx].Finalize;
  end;
end;

end.
