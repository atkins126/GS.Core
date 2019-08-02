///-------------------------------------------------------------------------------
/// Title      : GS.Stream
/// Short Desc : Lowlevel stream type write.
/// Source     : https://github.com/VincentGsell
/// Aim        : - Store type in stream in fast and easy way.
///-------------------------------------------------------------------------------
unit GS.Stream;

{$I GSCore.inc}

interface

{$ifdef FPC}
uses Sysutils, Classes;
{$else}
uses System.Sysutils, System.Classes;
{$endif}

procedure WriteLongInt(Stream: TStream; const Value: LongInt);
procedure WriteInteger(Stream: TStream; const Value: Integer);
procedure WriteInt32(Stream: TStream; const Value: Int32);
procedure WriteInt64(Stream: TStream; const Value: Int64);
procedure WriteUInt64(Stream: TStream; const Value: UInt64);
procedure WriteUInt32(Stream: TStream; const Value: UINT32);
procedure WriteByte(Stream: TStream; const Value: Byte);
procedure WriteBoolean(Stream: TStream; const Value: Boolean);
procedure WriteDouble(Stream: TStream; const Value: Double);
procedure WriteSingle(Stream: TStream; const Value: Single);
procedure WriteDateTime(Stream: TStream; const Value: TDateTime);
function ReadLongInt(Stream: TStream): LongInt;
function ReadInteger(Stream: TStream): Integer;
function ReadInt32(Stream: TStream): Int32;
function ReadInt64(Stream: TStream): Int64;
function ReadUInt64(Stream: TStream): UInt64;
function ReadUint32(Stream: TStream): UInt32;
function ReadByte(Stream: TStream): Byte;
function ReadBoolean(Stream: TStream): Boolean;
function ReadDouble(Stream: TStream): Double;
function ReadSingle(Stream: TStream): Single;
function ReadDateTime(Stream: TStream): TDateTime;

Type TGSStringEncoding = (ASCIIEncoding, AnsiEncoding, UTF7Enconding, UTF8Encoding, UnicodeEncoding);
procedure WriteString(Stream: TStream; Const Data: String; const Encoding : TGSStringEncoding = TGSStringEncoding.UTF8Encoding);
function ReadString(Stream: TStream; const Encoding : TGSStringEncoding = TGSStringEncoding.UTF8Encoding): String;

function ReadBytes(Stream : TStream) : TBytes; //Bytes from stream with size signature.
procedure WriteBytes(stream : TStream; const aBytes : TBytes);

function StreamToBytes(Stream : TStream) : TBytes; //Pure conversion
procedure BytesToStream(stream : TStream; const aBytes : TBytes);

Procedure WriteStream(Stream : TStream; const SourceStream : TMemoryStream);
Procedure ReadStream(Stream : TStream; var DestinationStream : TMemoryStream);

//Write without prefixed size by default.
procedure WriteRAWStringUTF8(Stream : TStream; Const Data : String; Const ByteLenPrefix : Boolean = false);
function ReadRAWStringUTF8(Stream : TStream; Const ByteLenPrefix : Boolean = false) : String;
//Procedure Write_UTF82Bytes(var Buffer : TBytes; const Data : UTF8String); Inline;


Type TUint32Array = Array of Uint32;
function ReadArrayOfUINT32(Stream : TStream) :  TUint32Array;
procedure WriteArrayOfUINT32(Stream : TStream; Const Source : Array of UINT32);

implementation

//Procedure Write_UTF82Bytes(var Buffer : TBytes; const Data : UTF8String);
//begin
//  Move(Data[1], Buffer[0], Length(Data));
//  buffer := TEncoding.UTF8.GetBytes(Data);
//end;

function ReadArrayOfUINT32(Stream : TStream) : TUint32Array;
var l : Uint32;
begin
  l := ReadUint32(Stream);
  if l>0 then
  begin
    SetLength(result,l);
    Stream.Read(result[0],l*SizeOf(UInt32));
  end;
end;

procedure WriteArrayOfUINT32(Stream : TStream; Const Source : Array of UINT32);
var l : Uint32;
begin
  l := Length(Source);
  WriteUint32(Stream,l);
  if l>0 then
  begin
    Stream.Write(source[0],l*SizeOf(Uint32));
  end;
end;

Procedure WriteRAWStringUTF8(Stream : TStream; Const Data : String; Const ByteLenPrefix : Boolean = false);
var b : TStringStream;
    l : UInt32;
begin
   b := TStringStream.Create(UTF8String(Data));
  try
    if ByteLenPrefix then
    begin
      l := UInt32(Abs(b.Size));
      Stream.Write(l,SizeOf(UINT32));
    end;
    Stream.CopyFrom(b,b.Size);
  finally
    FreeAndNil(b);
  end;
end;

function ReadRAWStringUTF8(Stream : TStream; Const ByteLenPrefix : Boolean = false) : String;
var b : TStringStream;
    l  : UInt32;
begin
   l := 0;
   b := TStringStream.Create(UTF8String(' ')); //Force UTF8 encoding.
  try
    if ByteLenPrefix then
    begin
      Stream.read(l,sizeOf(UINT32));
      b.CopyFrom(Stream,l);
    end
    else
    begin
      {$ifdef FPC}
      //b.WriteString('');
      b.CopyFrom(Stream,Stream.Size);
      {$else}
      b.LoadFromStream(Stream);
      {$endif}
    end;
    result := b.DataString;
  finally
    FreeAndNil(b);
  end;
end;



procedure WriteDateTime(Stream: TStream; const Value: TDateTime);
begin
  Stream.Write(Value, SizeOf(TDateTime));
end;

procedure WriteLongInt(Stream: TStream; const Value: LongInt);
begin
  Stream.Write(Value, SizeOf(LongInt));
end;

procedure WriteInteger(Stream: TStream; const Value: Integer);
begin
  Stream.Write(Value, SizeOf(Integer));
end;
procedure WriteInt32(Stream: TStream; const Value: Int32);
begin
  Stream.Write(Value, SizeOf(Int32));
end;

procedure WriteInt64(Stream: TStream; const Value: Int64);
begin
  Stream.Write(Value, SizeOf(Int64));
end;

procedure WriteUInt64(Stream: TStream; const Value: UInt64);
begin
  Stream.Write(Value, SizeOf(UInt64));
end;

procedure WriteUINT32(Stream: TStream; const Value: UINT32);
begin
  Stream.Write(Value, SizeOf(UINT32));
end;

procedure WriteByte(Stream: TStream; const Value: Byte);
begin
  Stream.Write(Value, 1);
end;

procedure WriteBoolean(Stream: TStream; const Value: Boolean);
var b : Byte;
begin
  b := 0;
  if Value then
    b := 1;
  Stream.Write(b, 1);
end;

procedure WriteDouble(Stream: TStream; const Value: Double);
begin
  Stream.Write(Value, SizeOf(Double));
end;

procedure WriteSingle(Stream: TStream; const Value: Single);
begin
  Stream.Write(Value, SizeOf(Single));
end;

function ReadLongInt(Stream: TStream): LongInt;
begin
  Stream.Read(Result, SizeOf(LongInt));
end;

function ReadInteger(Stream: TStream): Integer;
begin
  Stream.Read(Result, SizeOf(Integer));
end;
function ReadInt32(Stream: TStream): Int32;
begin
  Stream.Read(Result, SizeOf(Int32));
end;

function ReadInt64(Stream: TStream): Int64;
begin
  Stream.Read(Result, SizeOf(Int64));
end;

function ReadUInt64(Stream: TStream): UInt64;
begin
  Stream.Read(Result, SizeOf(UInt64));
end;

function ReadUint32(Stream: TStream): UINT32;
begin
  Stream.Read(Result, SizeOf(UINT32));
end;

function ReadByte(Stream: TStream): Byte;
begin
  Stream.Read(Result, 1);
end;

function ReadBoolean(Stream: TStream): Boolean;
var b : Byte;
begin
  Stream.Read(b, 1);
  Result := b > 0;
end;

function ReadDouble(Stream: TStream): Double;
begin
  Stream.Read(Result, SizeOf(Double));
end;

function ReadSingle(Stream: TStream): Single;
begin
  Stream.Read(Result, SizeOf(Single));
end;

function ReadDateTime(Stream: TStream): TDateTime;
begin
  Stream.Read(Result, SizeOf(TDateTime));
end;

function GetEncoding(a : TGSStringEncoding) : TEncoding;
begin
  result := TEncoding.UTF8;
  case a  of
    TGSStringEncoding.ASCIIEncoding: result := TEncoding.ASCII;
    TGSStringEncoding.AnsiEncoding: result := TEncoding.ANSI;
    TGSStringEncoding.UTF7Enconding: result := TEncoding.UTF7;
    TGSStringEncoding.UTF8Encoding: result := TEncoding.UTF8;
    TGSStringEncoding.UnicodeEncoding: result := TEncoding.Unicode;
  end;
end;

procedure WriteString(Stream: TStream; Const Data: String; const Encoding : TGSStringEncoding = TGSStringEncoding.UTF8Encoding);
var b : TStringStream;
    l : UINT32;
begin
 {$ifdef FPC}
 b := TStringStream.Create(UTF8String(Data)); //TODO lencoding , EncodingUTF8, GetEncoding(Encoding)));
 {$else}
 b := TStringStream.Create(Data,GetEncoding(Encoding));
 {$endif}
 try
   l := b.Size;
   Stream.Write(l,SizeOf(UINT32));
   Stream.CopyFrom(b,b.Size);
 finally
   FreeAndNil(b);
 end;
end;

function ReadString(Stream: TStream; const Encoding : TGSStringEncoding = TGSStringEncoding.UTF8Encoding): String;
var
  b : TStringStream;
  i : UINT32;
begin
  result := '';
  Stream.read(i,sizeOf(UINT32));
  if i>0 then
  begin
    {$ifdef FPC}
    b := TStringStream.Create(UTF8String(' ')); //TODO lencoding , EncodingUTF8, GetEncoding(Encoding)));
    {$else}
    b := TStringStream.Create(' ',GetEncoding(Encoding));
    {$endif}
    try
      b.CopyFrom(Stream,i);
      Result := b.DataString;
    finally
      FreeAndNil(b);
    end;
  end;
end;

function ReadBytes(Stream: TStream): TBytes;
var li : Int64;
begin
  if Assigned(Stream) then
  begin
    li := ReadInt64(Stream);
    if li > 0 then
    begin
      SetLength(result, li);
      Stream.Read(pointer(result)^, length(result));
    end;
  end
  else
    SetLength(result, 0);
end;

procedure WriteBytes(stream : TStream; const aBytes : TBytes);
begin
  WriteInt64(Stream, length(aBytes));
  if length(abytes) > 0 then
    stream.Write(pointer(aBytes)^, length(aBytes));
end;

function StreamToBytes(Stream : TStream) : TBytes; //Pure conversion
begin
  if Assigned(Stream) then
  begin
    SetLength(result, Stream.Size-Stream.Position);
    Stream.Read(pointer(result)^, length(result));
  end
  else
    SetLength(result, 0);
end;

procedure BytesToStream(stream : TStream; const aBytes : TBytes);
begin
 if length(abytes) > 0 then
   stream.Write(pointer(aBytes)^, length(aBytes));
end;

Procedure WriteStream(Stream : TStream; const SourceStream : TMemoryStream);
begin
  WriteInt64(Stream, SourceStream.Size-SourceStream.Position);
  Stream.CopyFrom(SourceStream,SourceStream.Size-SourceStream.Position);
end;

Procedure ReadStream(Stream : TStream; var DestinationStream : TMemoryStream);
var il : Int64;
begin
  il := ReadInt64(Stream);
  DestinationStream.CopyFrom(Stream,il);
end;



end.
