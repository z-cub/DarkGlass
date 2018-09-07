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
unit darkmath.providers;

interface
uses
  darkmath.provider;

type
  ///  <summary>
  ///    ComputeProviders is a namespace class which provides access to a
  ///    global registry of compute providers.
  ///  </summary>
  ComputeProviders = class
  public
    class function Count: uint64; static;
    class function Provider( idx: uint64 ): IComputeProvider; static;
    class procedure Add( aProvider: IComputeProvider ); static;
  end;

implementation
uses
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

class function ComputeProviders.Provider( idx: uint64 ): IComputeProvider;
begin
  Result := SingletonProviders.Items[idx];
end;

class procedure ComputeProviders.Add( aProvider: IComputeProvider );
begin
  SingletonProviders.Add(aProvider);
end;

initialization

finalization
  fComputeProviders := nil;
end.
