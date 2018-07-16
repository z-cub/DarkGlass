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
unit darkcollections.types;

interface

type
  /// <summary>
  ///   This interface does nothing other than to provide an interface from
  ///   which other collection interfaces may be derrived. (See remarks)
  /// </summary>
  /// <remarks>
  ///   ICollection is useful for providing a reference to a collection
  ///   regardless of the collection type. <br />Because many collections are
  ///   drawn from generics, this allows you to keep a 'counted' reference to
  ///   the collection in the interface section of a unit, while specializing
  ///   the collection within the implementation section.
  /// </remarks>
  /// <example>
  ///   <code lang="Delphi">interface
  /// uses
  ///   darkCollections;
  /// type
  ///   TMyClass = class
  ///   private
  ///     fMyCollection: ICollection;
  ///   public
  ///     constructor Create;
  ///   end;
  /// implementation
  /// uses
  ///   darkCollections.list,
  ///   darkCollections.list.standard;
  /// type
  ///   IMyList = {$ifdef fpc} specialize {$endif} ISomeClassList&lt;TSomeClass&gt;;
  ///   TMyList = {$ifdef fpc} specialize {$endif} TSomeClassList&lt;TSomeClass&gt;;
  /// constructor TMyClass.Create;
  /// begin
  ///   inherited;
  ///   fMyCollection := TMyList.Create;
  ///   IMyList(fMyCollection).Add( TSomeClass.Create );
  /// end;
  /// end.</code>
  /// </example>
  ICollection = interface
    ['{B21B7438-044D-4D3A-8CD2-973DC7C5B1CA}']
  end;

  /// <summary>
  ///   The generic <see cref="darkcollections.collectable">ICollectable</see>
  ///   &lt;&gt; interface, which can be used to create a reference counted
  ///   version of some arbitrary base data type, which can then be used within
  ///   specializations of the generic collection types.
  /// </summary>
  /// <typeparam name="T">
  ///   The parameterized data type to be used when specializing the <see cref="darkCollections.collectable.ICollectable&lt;T&gt;">
  ///   ICollectable</see>&lt;&gt; generic interface.
  /// </typeparam>
  /// <example>
  ///   See <see cref="darkCollections.ICollectableString">ICollectableString</see>
  ///    and <see cref="darkCollections.ICollectableVariant">
  ///   ICollectableVariant</see>.
  /// </example>
  /// <seealso cref="darkCollections.ICollectableString">
  ///   ICollectableString
  /// </seealso>
  /// <seealso cref="darkCollections.ICollectableVariant">
  ///   ICollectableVariant
  /// </seealso>
 {$ifdef fpc} generic {$endif}
  ICollectable<T> = interface
    ['{4A803D4B-BC66-47CA-9354-FBD5449FDB11}']
    function getValue: T;
    procedure setValue( value: T );

    //- pascal only properties -//
    /// <summary>
    ///   Get or Set the value which is represented by this interface (data
    ///   type specified by <see cref="darkCollections.collectable.ICollectable&lt;T&gt;">
    ///   T</see> when specializing <see cref="darkCollections.collectable.ICollectable&lt;T&gt;">
    ///   ICollectable</see>)
    /// </summary>
    property Value: T read getValue write setValue;
  end;

  ///  <summary>
  ///    Standard implmentation of ICollectable<T>
  ///  </summary>
  {$ifdef fpc} generic {$endif}
  TCollectable<T> = class( TInterfacedObject, {$ifdef fpc} specialize {$endif} ICollectable<T> )
  private
    fValue: T;
  private
    function getValue: T;
    procedure setValue( value: T );
  public
    constructor Create( value: T ); reintroduce;
  end;

  ///  <summary>
  ///    An implementation of ICollectableString stores a string value in
  ///    interface form, suitable for inclusion into a collection.
  ///  </summary>
  ICollectableString   = {$ifdef fpc} specialize {$endif} ICollectable<string>;

  ///  <summary>
  ///    Implements ICollectableString
  ///  </summary>
  TCollectableString   = {$ifdef fpc} specialize {$endif} TCollectable<string>;

  ///  <summary>
  ///    An implementation of ICollectableVariant stores a variant value in
  ///    interface form, suitable for inclusion into a collection.
  ///  </summary>
  ICollectableVariant  = {$ifdef fpc} specialize {$endif} ICollectable<Variant>;

  ///  <summary>
  ///    Implements ICollectableVariant
  ///  </summary>
  TCollectableVariant  = {$ifdef fpc} specialize {$endif} TCollectable<Variant>;



implementation

{$ifdef fpc}
constructor TCollectable.Create( value: T );
{$else}
constructor TCollectable<T>.Create( value: T );
{$endif}
begin
  inherited Create;
  setValue(value);
end;

{$ifdef fpc}
function TCollectable.getValue: T;
{$else}
function TCollectable<T>.getValue: T;
{$endif}
begin
  Result := fValue;
end;

{$ifdef fpc}
procedure TCollectable.setValue(value: T);
{$else}
procedure TCollectable<T>.setValue(value: T);
{$endif}
begin
  fValue := value;
end;


end.
