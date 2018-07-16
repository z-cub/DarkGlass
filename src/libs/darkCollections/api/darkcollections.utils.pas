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
unit darkcollections.utils;

interface
uses
  darkcollections.types,
  darkcollections.list,
  darkcollections.stack,
  darkcollections.dictionary;

type
  IStringList          = {$ifdef fpc} specialize {$endif} IList<ICollectableString>;
  IStringStack         = {$ifdef fpc} specialize {$endif} IStack<ICollectableString>;
  IStringDictionary    = {$ifdef fpc} specialize {$endif} IDictionary<ICollectableString>;
  IVariantList         = {$ifdef fpc} specialize {$endif} IList<ICollectableVariant>;
  IVariantStack        = {$ifdef fpc} specialize {$endif} IStack<ICollectableVariant>;
  IVariantDictionary   = {$ifdef fpc} specialize {$endif} IDictionary<ICollectableVariant>;
  TStringList          = {$ifdef fpc} specialize {$endif} TList<ICollectableString>;
  TStringStack         = {$ifdef fpc} specialize {$endif} TStack<ICollectableString>;
  TStringDictionary    = {$ifdef fpc} specialize {$endif} TDictionary<ICollectableString>;
  TVariantList         = {$ifdef fpc} specialize {$endif} TList<ICollectableVariant>;
  TVariantStack        = {$ifdef fpc} specialize {$endif} TStack<ICollectableVariant>;
  TVariantDictionary   = {$ifdef fpc} specialize {$endif} TDictionary<ICollectableVariant>;

implementation

end.
