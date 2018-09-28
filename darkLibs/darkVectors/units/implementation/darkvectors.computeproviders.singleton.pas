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
unit darkvectors.computeproviders.singleton;

interface
uses
  darkvectors.computeprovider;

type
  ///  <summary>
  ///    ComputeProviders is a namespace class which provides access to a
  ///    global registry of compute providers.
  ///  </summary>
  ComputeProviders = class
  public
    ///  <summary>
    ///    Case insensitive search for a compute provider by name.
    ///  </summary>
    class function Find( ProviderName: string ): IComputeProvider; static;

    ///  <summary>
    ///    Returns the number of registered compute providers.
    ///  </summary>
    class function Count: uint64; static;

    ///  <summary>
    ///    Returns a compute provider by it's index.
    ///  </summary>
    class function getProvider( idx: uint64 ): IComputeProvider; static;

    ///  <summary>
    ///    Used to add providers to the ComputeProviders collection.
    ///  </summary>
    class function Add( aProvider: IComputeProvider ): IComputeProvider; static;

    ///  <summary>
    ///    Returns a compute provider by it's index.
    ///  </summary>
    class property Provider[ idx: uint64 ]: IComputeProvider read getProvider;
  end;

implementation
uses
  sysutils,
  darkCollections.list;

type
  IProviderList = IList<IComputeProvider>;
  TProviderList = TList<IComputeProvider>;

var
  fComputeProviders: IProviderList = nil;

function SingletonProviders: IProviderList; inline;
begin
  if not assigned(fComputeProviders) then begin
    fComputeProviders := TProviderList.Create;
  end;
  Result := fComputeProviders;
end;

class function ComputeProviders.Count: uint64;
begin
  Result := SingletonProviders.Count;
end;

class function ComputeProviders.Find(ProviderName: string): IComputeProvider;
var
  utSearch: string;
  idx: uint64;
begin
  Result := nil;
  if Count=0 then begin
    exit;
  end;
  utSearch := Uppercase(Trim(ProviderName));
  for idx := 0 to pred(Count) do begin
    if Uppercase(Trim(getProvider(idx).Name))=utSearch then begin
      Result := ComputeProviders.getProvider(idx);
      exit;
    end;
  end;
end;

class function ComputeProviders.getProvider( idx: uint64 ): IComputeProvider;
begin
  Result := SingletonProviders.Items[idx];
end;

class function ComputeProviders.Add( aProvider: IComputeProvider ): IComputeProvider;
begin
  SingletonProviders.Add(aProvider);
  Result := aProvider;
end;

initialization

finalization
  fComputeProviders := nil;
end.
