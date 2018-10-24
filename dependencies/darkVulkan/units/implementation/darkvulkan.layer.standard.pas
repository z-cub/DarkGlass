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
unit darkvulkan.layer.standard;

interface
uses
  darkIO.buffers,
  darkvulkan.layer;

type
  TvkLayer = class( TInterfacedObject, IvkLayer )
  private
    fName: IUnicodeBuffer;
    fDescription: string;
    fImplementation: uint32;
    fSpec: uint32;
  private //- IvkLayer -//
    function getNameAsPAnsiChar: pointer;
    function getName: string;
    function getSpecVersion: uint32;
    function getImplementationVersion: uint32;
    function getDescription: string;
  public
    constructor Create( Name, Description: string; ImplementationVersion, SpecVersion: uint32 ); reintroduce;
    destructor Destroy; override;

  end;


implementation

{ TvkLayer }

constructor TvkLayer.Create(Name, Description: string; ImplementationVersion, SpecVersion: uint32);
begin
  inherited Create;
  fName := TBuffer.Create(succ(Length(Name)));
  fName.WriteString(Name,TUnicodeFormat.utfANSI);
  fDescription := Description;
  fImplementation := ImplementationVersion;
  fSpec := SpecVersion;
end;

destructor TvkLayer.Destroy;
begin
  fName := nil;
  inherited;
end;

function TvkLayer.getDescription: string;
begin
  Result := fDescription;
end;

function TvkLayer.getImplementationVersion: uint32;
begin
  Result := fImplementation;
end;

function TvkLayer.getName: string;
begin
  Result := fName.ReadString(TUnicodeFormat.utfAnsi,True);
end;

function TvkLayer.getNameAsPAnsiChar: pointer;
begin
  Result := fName.DataPtr;
end;

function TvkLayer.getSpecVersion: uint32;
begin
  Result := fSpec;
end;

end.
