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
unit darkvectors.computeprovider.external;

interface
uses
  darkvectors.external.binding,
  darkvectors.computeprovider;

type
  TExternalComputeProvider = class( TInterfacedObject, IComputeProvider )
  private
    fBinding: IVectorBinding;
  private
    constructor internalCreate( Binding: IVectorBinding );
  public
    function Create( LibraryName: string ): IComputeProvider; reintroduce;
    destructor Destroy; override;
  end;

implementation

{ TExternalComputeProvider }

function TExternalComputeProvider.Create(LibraryName: string): IComputeProvider;
begin
  Result := nil; //- unless -//
  //- Attempt to create an external binding and load from library -//

end;

destructor TExternalComputeProvider.Destroy;
begin

  inherited;
end;

constructor TExternalComputeProvider.internalCreate(Binding: IVectorBinding);
begin

end;

end.
