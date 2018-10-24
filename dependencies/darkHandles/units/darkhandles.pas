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
unit darkhandles;
{$ifdef fpc} {$mode delphiunicode} {$endif}

interface

type
  ///  <summary>
  ///    A handle to an object within the darkglass system.
  ///  </summary>
  THandle = nativeuint;

  ///  <summary>
  ///    Namespace class for working with handles.
  ///  </summary>
  THandles = class
  private
    ///  <summary>
    ///    Returns the index of a handle within the handles list.
    ///  </summary>
    class function FindHandle( Handle: THandle; var HandleIndex: uint32 ): boolean;

  public
    const
      cNullHandle: THandle = 0;

  public
    ///  <summary>
    ///    Create a new handle to a darkglass object. (TInterfacedObject)
    ///    Pass in an instance of the object to which the handle refers.
    ///  </summary>
    class function CreateHandle( anInstance: IInterface ): THandle; static;


    ///  <summary>
    ///    Verifies that the handle is of the correct kind.
    ///  </summary>
    class function VerifyHandle( Handle: THandle; const anInterface: TGUID ): boolean; static;

    ///  <summary>
    ///    Returns the object instance for the object behind the handle.
    ///  </summary>
    class function InstanceOf( Handle: THandle ): IInterface;

    ///  <summary>
    ///    Frees the handle and the associated object.
    ///  </summary>
    class procedure FreeHandle( Handle: THandle ); static;
  end;

implementation
uses
  SysUtils,
  darkCollections.list;

type
  IHandleRecord = interface
    ['{8FD6CE52-3105-433D-B376-2B4D3D53F424}']
    function getInstance: IInterface;
    //- Pascal Only, Properties -//
    property Instance: IInterface read getInstance;
  end;

  THandleRecord = class( TInterfacedObject, IHandleRecord )
  private
    fInstance: IInterface;
  private //- IHandleRecord -//
    function getInstance: IInterface;
  public
    constructor Create( anInstance: IInterface ); reintroduce;
    destructor Destroy; override;
  end;

type
  IHandleRecordList = IList<IHandleRecord>;
  THandleRecordList = TList<IHandleRecord>;

var
  Handles: IHandleRecordList = nil;

{ THandles }

class function THandles.CreateHandle( anInstance: IInterface ): THandle;
var
  HandleRecord: IHandleRecord;
begin
  if not assigned(Handles) then begin
    Handles := THandleRecordList.Create(64,False,True);
  end;
  HandleRecord := THandleRecord.Create( anInstance );
  Result := THandle(HandleRecord);
  Handles.Add(HandleRecord);
end;

class function THandles.FindHandle( Handle: THandle; var HandleIndex: uint32 ): boolean;
var
  idx: uint32;
begin
  Result := False;
  for idx := 0 to pred(Handles.Count) do begin
    if THandle(Handles[idx]) = Handle then begin
      HandleIndex := idx;
      Result := True;
      exit;
    end;
  end;
end;

class procedure THandles.FreeHandle(Handle: THandle);
var
  HandleIndex: uint32;
begin
  if not assigned(Handles) then begin
    exit;
  end;
  if Handle=THandles.cNullHandle then begin
    exit;
  end;
  if FindHandle( Handle, HandleIndex ) then begin
    Handles.RemoveItem(HandleIndex);
  end;
end;

class function THandles.InstanceOf(Handle: THandle): IInterface;
var
  HandleRecord: IHandleRecord;
begin
  Result := nil;
  if not assigned(pointer(Handle)) then begin
    exit;
  end;
  HandleRecord := IHandleRecord(Handle);
  Result := HandleRecord.Instance;
end;


class function THandles.VerifyHandle(Handle: THandle; const anInterface: TGUID ): boolean;
begin
  Result := Supports(IHandleRecord(Handle).Instance,anInterface);
end;

{ THandleRecord }

constructor THandleRecord.Create( anInstance: IInterface );
begin
  inherited Create;
  fInstance := anInstance;
end;

destructor THandleRecord.Destroy;
begin
  fInstance := nil;
  inherited Destroy;
end;

function THandleRecord.getInstance: IInterface;
begin
  Result := fInstance;
end;

procedure ClearHandles;
begin
  if not assigned(Handles) then begin
    exit;
  end;
  Handles.Clear;
  Handles := nil;
end;

initialization
finalization
  ClearHandles;
  Handles := nil;

end.
