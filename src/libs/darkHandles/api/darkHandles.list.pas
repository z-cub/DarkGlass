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
unit darkHandles.list;

interface

const
  cDefaultGranularity = 128;

type
  ///  <summary>
  ///    Represents a thread-safe (critical section) list of handles.
  ///    This list 'owns' the handles, in that it will free them when they
  ///    are deleted, or when the list is disposed.
  ///  </summary>
  IHandleList = interface
    ['{890BC4EA-F082-43B3-B6CC-070856733F57}']

    ///  <summary>
    ///    Adds a handle to this list.
    ///  </summary>
    procedure Add( aHandle: THandle );

    ///  <summary>
    ///    Returns the number of handles held in this list.
    ///  </summary>
    function getCount: nativeuint;

    ///  <summary>
    ///    Returns a handle from this list.
    ///  </summary>
    function getHandle( index: nativeuint ): THandle;

    //- Pascal only, properties -//
    property Count: nativeuint read getCount;
    property Handles[ index: nativeuint ]: THandle read getHandle;
  end;

type
  THandleList = class
  public
    class function Create( Granularity: nativeuint = cDefaultGranularity ): IHandleList;
  end;

implementation
uses
  darkHandles,
  darkThreading;

type
  TListOfHandles = class( TInterfacedObject, IHandleList )
  private
    fHandles: array of THandle;
    fCount: nativeuint;
    fHandlesCS: ICriticalSection;
    fGranularity: nativeuint;
  private
    procedure Add( aHandle: THandle );
    function getCount: nativeuint;
    function getHandle( index: nativeuint ): THandle;
  public
    constructor Create( Granularity: nativeuint ); reintroduce;
    destructor Destroy; override;
  end;


{ TListOfHandles }

procedure TListOfHandles.Add(aHandle: THandle);
begin
  fHandlesCS.Acquire;
  try
    if fCount>=Length(fHandles) then begin
      SetLength(fHandles,Length(fHandles)+fGranularity);
    end;
    fHandles[fCount]:=aHandle;
    inc(fCount);
  finally
    fHandlesCS.Release;
  end;
end;

constructor TListOfHandles.Create(Granularity: nativeuint);
begin
  inherited Create;
  fCount := 0;
  fGranularity := Granularity;
  SetLength(fHandles,fGranularity);
  fHandlesCS := TCriticalSection.Create;
end;

destructor TListOfHandles.Destroy;
var
  idx: nativeuint;
begin
  //- Free all handles.
  if fCount>0 then begin
    for idx := 0 to pred(fCount) do begin
      THandles.FreeHandle(fHandles[idx]);
    end;
  end;
  SetLength(fHandles,0);
  inherited Destroy;
end;


function TListOfHandles.getCount: nativeuint;
begin
  Result := fCount;
end;

function TListOfHandles.getHandle(index: nativeuint): THandle;
begin
  if index<fCount then begin
    Result := fHandles[index];
  end else begin
    Result := THandles.cNullHandle;
  end;
end;

{ THandleList }

class function THandleList.Create( Granularity: nativeuint ): IHandleList;
begin
  Result := TListOfHandles.Create( Granularity );
end;


end.
