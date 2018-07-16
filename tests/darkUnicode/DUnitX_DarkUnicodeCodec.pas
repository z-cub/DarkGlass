unit DUnitX_DarkUnicodeCodec;

interface
uses
  DUnitX.TestFramework,
  DUnitX.Utils,
  darkUnicode;

type

  [TestFixture]
  TTestUnicode = class(TObject)
  public

    [Test]
    [TestCase('Test1','$0024,$')]
    [TestCase('Test2','$20AC,€')]
    [TestCase('Test3','$10437,𐐷')]
    [TestCase('Test4','$24B62,𤭢')]
    procedure Test_EncodeCodepointToString(const CodePoint: uint32; const s: string);

    [Test]
    [TestCase('Test1','$,$0024')]
    [TestCase('Test2','€,$20AC')]
    [TestCase('Test3','𐐷,$10437')]
    [TestCase('Test4','𤭢,$24B62')]
    procedure Test_DecodeCodepointFromString(const s: string; const CodePoint: TUnicodeCodepoint);

    [Test]
    [TestCase('Test1','$65,1')]
    [TestCase('Test2','$1A,1')]
    [TestCase('Test3','$AC82E2,3')]
    [TestCase('Test4','$888D90F0,4')]
    procedure Test_UTF8CharacterLength( var Data: uint32; const ExpectedLen: uint8 );

    [Test]
    [TestCase('Test1','$0024,2')]
    [TestCase('Test2','$20AC,2')]
    [TestCase('Test3','$DC37D801,4')]
    [TestCase('Test4','$DF62D852,4')]
    procedure Test_UTF16LECharacterLength( var Data: uint32; const ExpectedLen: uint8 );

    [Test]
    [TestCase('Test1','$2400,2')]
    [TestCase('Test2','$AC20,2')]
    [TestCase('Test3','$01D837DC,4')]
    [TestCase('Test4','$52D862DF,4')]
    procedure Test_UTF16BECharacterLength( var Data: uint32; const ExpectedLen: uint8 );

    [Test]
    [TestCase('Test1','$24,$0024')]
    [TestCase('Test2','$A2C2,$00A2')]
    [TestCase('Test3','$AC82E2,$20AC')]
    [TestCase('Test4','$888D90F0,$10348')]
    procedure Test_UTF8Decode( var Data: uint32; Expected: TUnicodeCodepoint );

    [Test]
    [TestCase('Test1','$0024,$0024')]
    [TestCase('Test2','$20AC,$20AC')]
    [TestCase('Test3','$DC37D801,$10437')]
    [TestCase('Test4','$DF62D852,$24B62')]
    procedure Test_UTF16LEDecode( var Data: uint32; Expected: TUnicodeCodepoint );

    [Test]
    [TestCase('Test1','$2400,$0024')]
    [TestCase('Test2','$AC20,$20AC')]
    [TestCase('Test3','$37DC01D8,$10437')]
    [TestCase('Test4','$62DF52D8,$24B62')]
    procedure Test_UTF16BEDecode( var Data: uint32; Expected: TUnicodeCodepoint );

    [Test]
    [TestCase('Test1','$00000024,$0024')]
    [TestCase('Test2','$000020AC,$20AC')]
    [TestCase('Test3','$00010437,$10437')]
    [TestCase('Test4','$00024B62,$24B62')]
    procedure Test_UTF32LEDecode( var Data: uint32; Expected: TUnicodeCodepoint );

    [Test]
    [TestCase('Test1','$24000000,$0024')]
    [TestCase('Test2','$AC200000,$20AC')]
    [TestCase('Test3','$37040100,$10437')]
    [TestCase('Test4','$624B0200,$24B62')]
    procedure Test_UTF32BEDecode( var Data: uint32; Expected: TUnicodeCodepoint );

    [Test]
    [TestCase('Test1','$24,$0024')]
    [TestCase('Test2','$A2C2,$00A2')]
    [TestCase('Test3','$AC82E2,$20AC')]
    [TestCase('Test4','$888D90F0,$10348')]
    procedure Test_UTF8Encode(Expected: uint32; Codepoint: TUnicodeCodepoint );

    [Test]
    [TestCase('Test1','$0024,$0024')]
    [TestCase('Test2','$20AC,$20AC')]
    [TestCase('Test3','$DC37D801,$10437')]
    [TestCase('Test4','$DF62D852,$24B62')]
    procedure Test_UTF16LEEncode(Expected: uint32; Codepoint: TUnicodeCodepoint );

    [Test]
    [TestCase('Test1','$2400,$0024')]
    [TestCase('Test2','$AC20,$20AC')]
    [TestCase('Test3','$37DC01D8,$10437')]
    [TestCase('Test4','$62DF52D8,$24B62')]
    procedure Test_UTF16BEEncode(Expected: uint32; Codepoint: TUnicodeCodepoint );

    [Test]
    [TestCase('Test1','$00000024,$0024')]
    [TestCase('Test2','$000020AC,$20AC')]
    [TestCase('Test3','$00010437,$10437')]
    [TestCase('Test4','$00024B62,$24B62')]
    procedure Test_UTF32LEEncode(Expected: uint32; Codepoint: TUnicodeCodepoint );

    [Test]
    [TestCase('Test1','$24000000,$0024')]
    [TestCase('Test2','$AC200000,$20AC')]
    [TestCase('Test3','$37040100,$10437')]
    [TestCase('Test4','$624B0200,$24B62')]
    procedure Test_UTF32BEEncode(Expected: uint32; Codepoint: TUnicodeCodepoint );

    [Test]
    [TestCase('Test1','$65,$65')]
    [TestCase('Test2','$5A,$5A')]
    procedure Test_AnsiDecode( var Data: uint32; Expected: TUnicodeCodepoint );

    [Test]
    [TestCase('Test1','$65,$65')]
    [TestCase('Test2','$5A,$5A')]
    procedure Test_AnsiEncode(Expected: uint32; Codepoint: TUnicodeCodepoint );

    [Test]
    [TestCase('Test1','$BFBBEF,3,True')]
    [TestCase('Test2','$000000,3,False')]
    procedure Test_DecodeBOMUTF8(Data: uint32; Size: uint8; Expected: boolean);

    [Test]
    [TestCase('Test1','$FEFF,2,True')]
    [TestCase('Test2','$0000,2,False')]
    procedure Test_DecodeBOMUTF16LE(Data: uint32; Size: uint8; Expected: boolean);

    [Test]
    [TestCase('Test1','$FFFE,2,True')]
    [TestCase('Test2','$0000,2,False')]
    procedure Test_DecodeBOMUTF16BE(Data: uint32; Size: uint8; Expected: boolean);

    [Test]
    [TestCase('Test1','$0000FEFF,4,True')]
    [TestCase('Test2','$00000000,4,False')]
    procedure Test_DecodeBOMUTF32LE(Data: uint32; Size: uint8; Expected: boolean);

    [Test]
    [TestCase('Test1','$FFFE0000,4,True')]
    [TestCase('Test2','$00000000,4,False')]
    procedure Test_DecodeBOMUTF32BE(Data: uint32; Size: uint8; Expected: boolean);

    [Test]
    [TestCase('Test1','$BFBBEF,3')]
    procedure Test_EncodeBOMUTF8(Expected: uint32; ExpectedSize: uint8);

    [Test]
    [TestCase('Test1','$FEFF,2')]
    procedure Test_EncodeBOMUTF16LE(Expected: uint32; ExpectedSize: uint8);

    [Test]
    [TestCase('Test1','$FFFE,2')]
    procedure Test_EncodeBOMUTF16BE(Expected: uint32; ExpectedSize: uint8);

    [Test]
    [TestCase('Test1','$0000FEFF,4')]
    procedure Test_EncodeBOMUTF32LE(Expected: uint32; ExpectedSize: uint8);

    [Test]
    [TestCase('Test1','$FFFE0000,4')]
    procedure Test_EncodeBOMUTF32BE(Expected: uint32; ExpectedSize: uint8);

  end;

implementation

procedure TTestUnicode.Test_AnsiDecode( var Data: uint32; Expected: TUnicodeCodepoint );
var
  Codepoint: TUnicodeCodepoint;
begin
  Assert.IsTrue(unicode.AnsiDecode(Data,Codepoint));
  Assert.AreEqual(Expected,Codepoint);
end;

procedure TTestUnicode.Test_AnsiEncode(Expected: uint32; Codepoint: TUnicodeCodepoint );
var
  Data: uint32;
  Size: uint8;
begin
  Data := 0;
  Assert.IsTrue(unicode.AnsiEncode(Codepoint,Data,Size));
  Assert.AreEqual(Expected,Data);
end;

procedure TTestUnicode.Test_DecodeBOMUTF16BE(Data: uint32; Size: uint8; Expected: boolean);
begin
  Assert.AreEqual(Expected, unicode.DecodeBOM(Data,TUnicodeFormat.utf16BE,Size))
end;

procedure TTestUnicode.Test_DecodeBOMUTF16LE(Data: uint32; Size: uint8; Expected: boolean);
begin
  Assert.AreEqual(Expected,unicode.DecodeBOM(Data,TUnicodeFormat.utf16LE,Size));
end;

procedure TTestUnicode.Test_DecodeBOMUTF32BE(Data: uint32; Size: uint8; Expected: boolean);
begin
  Assert.AreEqual(Expected,unicode.DecodeBOM(Data,TUnicodeFormat.utf32BE,Size));
end;

procedure TTestUnicode.Test_DecodeBOMUTF32LE(Data: uint32; Size: uint8; Expected: boolean);
begin
  Assert.AreEqual(Expected,unicode.DecodeBOM(Data,TUnicodeFormat.utf32LE,Size));
end;

procedure TTestUnicode.Test_DecodeBOMUTF8(Data: uint32; Size: uint8; Expected: boolean);
begin
  Assert.AreEqual(Expected, unicode.DecodeBOM(Data,TUnicodeFormat.utf8,Size));
end;

procedure TTestUnicode.Test_DecodeCodepointFromString(const s: string; const CodePoint: TUnicodeCodepoint);
var
  c: TUnicodeCodepoint;
  Cursor: int32;
begin
  {$ifdef NEXTGEN}
  Cursor := 0;
  {$else}
  Cursor := 1;
  {$endif}
  Assert.IsTrue(Unicode.DecodeCodepointFromString(c,s,cursor));
  Assert.AreEqual(codepoint,c);
end;

procedure TTestUnicode.Test_EncodeBOMUTF16BE(Expected: uint32; ExpectedSize: uint8);
var
  BOM: uint32;
  Size: uint8;
begin
  BOM := 0;
  Assert.IsTrue(unicode.EncodeBOM(BOM,TUnicodeFormat.utf16BE,Size));
  Assert.AreEqual(ExpectedSize,Size);
  Assert.AreEqual(Expected,BOM);
end;

procedure TTestUnicode.Test_EncodeBOMUTF16LE(Expected: uint32; ExpectedSize: uint8);
var
  BOM: uint32;
  Size: uint8;
begin
  BOM := 0;
  Assert.IsTrue(unicode.EncodeBOM(BOM,TUnicodeFormat.utf16LE,Size));
  Assert.AreEqual(ExpectedSize,Size);
  Assert.AreEqual(Expected,BOM);
end;

procedure TTestUnicode.Test_EncodeBOMUTF32BE(Expected: uint32; ExpectedSize: uint8);
var
  BOM: uint32;
  Size: uint8;
begin
  BOM := 0;
  Assert.IsTrue(Unicode.EncodeBOM(BOM,TUnicodeFormat.utf32BE,Size));
  Assert.AreEqual(ExpectedSize,Size);
  Assert.AreEqual(Expected,BOM);
end;

procedure TTestUnicode.Test_EncodeBOMUTF32LE(Expected: uint32; ExpectedSize: uint8);
var
  BOM: uint32;
  Size: uint8;
begin
  BOM := 0;
  Assert.IsTrue(Unicode.EncodeBOM(BOM,TUnicodeFormat.utf32LE,Size));
  Assert.AreEqual(ExpectedSize,Size);
  Assert.AreEqual(Expected,BOM);
end;

procedure TTestUnicode.Test_EncodeBOMUTF8(Expected: uint32; ExpectedSize: uint8);
var
  BOM: uint32;
  Size: uint8;
begin
  BOM := 0;
  Assert.IsTrue(Unicode.EncodeBOM(BOM,TUnicodeFormat.utf8,Size));
  Assert.AreEqual(ExpectedSize,Size);
  Assert.AreEqual(Expected,BOM);
end;

procedure TTestUnicode.Test_EncodeCodepointToString(const CodePoint: TUnicodeCodepoint; const s: string);
var
  t: string;
begin
  Assert.IsTrue(Unicode.EncodeCodepointToString(Codepoint,t));
  Assert.AreEqual(s,t);
end;

procedure TTestUnicode.Test_UTF16BECharacterLength( var Data: uint32; const ExpectedLen: uint8 );
var
  s: uint8;
begin
  Assert.IsTrue(unicode.UTF16BECharacterLength(Data,s));
  Assert.AreEqual(ExpectedLen,S);
end;

procedure TTestUnicode.Test_UTF16BEDecode;
var
  Codepoint: TUnicodeCodepoint;
begin
  Assert.IsTrue(unicode.UTF16BEDecode(Data,Codepoint));
  Assert.AreEqual(Expected,Codepoint);
end;

procedure TTestUnicode.Test_UTF16BEEncode(Expected: uint32; Codepoint: TUnicodeCodepoint );
var
  Data: uint32;
  Size: uint8;
begin
  Data := 0;
  Assert.IsTrue(unicode.UTF16BEEncode(Codepoint,Data,Size));
  Assert.AreEqual(Expected,Data);
end;

procedure TTestUnicode.Test_UTF16LECharacterLength( var Data: uint32; const ExpectedLen: uint8 );
var
  s: uint8;
begin
  Assert.IsTrue(unicode.UTF16LECharacterLength(Data,s));
  Assert.AreEqual(ExpectedLen,S);
end;

procedure TTestUnicode.Test_UTF16LEDecode( var Data: uint32; Expected: TUnicodeCodepoint );
var
  Codepoint: TUnicodeCodepoint;
begin
  Assert.IsTrue(unicode.UTF16LEDecode(Data,Codepoint));
  Assert.AreEqual(Expected,Codepoint);
end;

procedure TTestUnicode.Test_UTF16LEEncode(Expected: uint32; Codepoint: TUnicodeCodepoint );
var
  Data: uint32;
  Size: uint8;
begin
  Data := 0;
  Assert.IsTrue(unicode.UTF16LEEncode(Codepoint,Data,Size));
  Assert.AreEqual(Expected,Data);
end;

procedure TTestUnicode.Test_UTF32BEDecode( var Data: uint32; Expected: TUnicodeCodepoint );
var
  Codepoint: TUnicodeCodepoint;
begin
  Assert.IsTrue(unicode.UTF32BEDecode(Data,Codepoint));
  Assert.AreEqual(Expected,Codepoint);
end;

procedure TTestUnicode.Test_UTF32BEEncode(Expected: uint32; Codepoint: TUnicodeCodepoint );
var
  Data: uint32;
  Size: uint8;
begin
  Assert.IsTrue(unicode.UTF32BEEncode(Codepoint,Data,Size));
  Assert.AreEqual(Expected,Data);
end;

procedure TTestUnicode.Test_UTF32LEDecode( var Data: uint32; Expected: TUnicodeCodepoint );
var
  Codepoint: TUnicodeCodepoint;
begin
  Assert.IsTrue(unicode.UTF32LEDecode(Data,Codepoint));
  Assert.AreEqual(Expected,Codepoint);
end;

procedure TTestUnicode.Test_UTF32LEEncode(Expected: uint32; Codepoint: TUnicodeCodepoint );
var
  Data: uint32;
  Size: uint8;
begin
  Assert.IsTrue(unicode.UTF32LEEncode(Codepoint,Data,Size));
  Assert.AreEqual(Expected,Data);
end;

procedure TTestUnicode.Test_UTF8CharacterLength( var Data: uint32; const ExpectedLen: uint8 );
var
  s: uint8;
begin
  Assert.IsTrue(unicode.UTF8CharacterLength(Data,s));
  Assert.AreEqual(ExpectedLen,s);
end;

procedure TTestUnicode.Test_UTF8Decode( var Data: uint32; Expected: TUnicodeCodepoint );
var
  Codepoint: TUnicodeCodepoint;
begin
  Assert.IsTrue(unicode.UTF8Decode(Data,Codepoint));
  Assert.AreEqual(Expected,Codepoint);
end;

procedure TTestUnicode.Test_UTF8Encode(Expected: uint32; Codepoint: TUnicodeCodepoint );
var
  Data: uint32;
  Size: uint8;
begin
  Data := 0;
  Assert.IsTrue(unicode.UTF8Encode(Codepoint,Data,Size));
  Assert.AreEqual(Expected,Data);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestUnicode);
end.
