unit SmartTiming.DecoderInterface;

interface

uses
//  DataStructures,
  Classes, SysUtils, StrUtils,
  IdTCPConnection, IdTCPClient, IdBaseComponent, IdComponent, IdCustomTCPServer, IdTCPServer, IdUdpServer,
  IdGlobal, IdSocketHandle;

const

  // MyLaps protocol P3 (source: http://www.hobbytalk.com/bbs1/archive/index.php/t-73738.html)

  // type of record
  TOR_RESET = $00;
  TOR_PASSING = $01;
  TOR_STATUS = $02;
  TOR_VERSION_DECODER = $03;
  TOR_RESEND = $04;
  TOR_FIRST_CONTACT = $45;
  TOR_ERROR = $FFFF;
  TOR_CLEAR_PASSING = $05;
  TOR_WATCHDOG = $18;
  TOR_PING = $20;
  TOR_SIGNALS = $2d;
  TOR_SERVER_SETTINGS = $13;
  TOR_SESSION = $15;
  TOR_GENERAL_SETTINGS = $28;
  TOR_LOOP_TRIGGER = $2f;
  TOR_GPS_INFO = $30;
  TOR_TIMELINE = $4a;
  TOR_GET_TIME = $24;
  TOR_NETWORK_SETTINGS = $16;

  // message type passing
  PASSING_NUMBER = $01; //(4 byte) (example of "FOR" - 0x01(TOF):0x04(length):0x00:0x00:0x00:0x00)
  TRANSPONDER = $03;
  RTC_ID = $13;
  RTC_TIME = $04;    // (8 byte, time microseconds after January 1, 1970 00:00:00 GMT)
  UTC_TIME = $10;    // (8 byte, time microseconds after January 1, 1970 00:00:00 GMT)
  STRENGTH = $05;
  HITS = $06;
  FLAGS = $08;
  CHIP_CODE = $0a;
  USER_FLAG = $0e;
  DRIVER_ID = $0f;
  SPORT = $14;
  VOLTAGE = $30;     // (1 byte, V = (float)voltage/10)
  TEMPERATURE = $31; // (1 byte, T = temperature - 100)
  DECODER_ID = $81;

  // message type status
  STATUS_NOISE = $01;
  STATUS_GPS = $06;          // (1 byte; 0=false, 1=true)
  STATUS_TEMPERATURE = $07;
  STATUS_SATINUSE = $0a;
  STATUS_LOOP_TRIGGERS = $0b;
  STATUS_INPUT_VOLTAGE = $0c;// (1 byte, Voltage = (float)input_voltage/10)

  // message type resend
  RESEND_FROM = $01;
  RESEND_TO = $02;

  // TOR VERSION constants
  TOR_VERSION_DECODER_TYPE = $02;
  TOR_VERSION_DECODER_FIRMWARE = $03;
  TOR_VERSION_DECODER_ID = $81;

  // general message constants
  CONTROLLER_ID = $83;
  REQUEST_ID = $85;

type
  TMyLapsP3Passing = record
    PassingNumber: integer;
    ChipId: string;
    PassingTime: TDateTime;
    SignalStrength: integer;
    Hits: integer;
    Flags: integer;
    Sport: byte;
    Voltage: Double;
    Temperature: integer;
    DecoderId: string;
    TransponderShortId: integer;
    function ToString: string;
  end;

  TMyLapsP3Status = record
    Noise: integer;
    Gps: boolean;
    Temperature: double;
    InputVoltage: double;
    DecoderId: string;
  end;

  TMyLapsP3Decoder = record
    Address: string;
    FirmwareVersion: string;
    DecoderType: string;
    DecoderId: string;
  end;

  TDecoderStatusReceivedEvent = procedure (Status: TMyLapsP3Status) of object;
  TDecoderPassingReceivedEvent = procedure (Passing: TMyLapsP3Passing) of object;
  TDecoderFoundEvent = procedure (ADecoder: TMyLapsP3Decoder) of object;

  TMyLapsP3MessageParser = class
   private
     FOnStatus: TDecoderStatusReceivedEvent;
     FOnPassing: TDecoderPassingReceivedEvent;
     FCrcTable: array[0..255] of word;
     FTimeDeltaDecoderPc: TDateTime;   // time delta between decoder and PC clock
     class function DecodePassingTime(AmbP3Time: string): TDateTime;
     class function EncodePassingTime(ADateTime: TDateTime): string;
     function ParseRecordTypePassing(Body: string): TMyLapsP3Passing;
     function ParseRecordTypeStatus(Body: string): TMyLapsP3Status;
     function ParseRecordTypeVersionDecoder(Body: string): TMyLapsP3Decoder;
     function DeEscapeMessage(Msg: string): string;
     function EscapeMessage(Msg: string): string;
     procedure initTable;
     function CalcCrc16(Msg: AnsiString): word;
   public
     constructor Create;
     procedure AddMessage(Msg: string);
     function AddMessageDecoderSearch(Msg: string): TMyLapsP3Decoder;
     function GetDecoderSearchPhrase: string;
     function GetResendPhrase(FromPassingNr, ToPassingNr: FixedUInt; DecoderId: string): string;
     function GetRtcPhrase: string;
     function GetPassingPhrase(APassing: TMyLapsP3Passing): string;
     property OnStatusReceived: TDecoderStatusReceivedEvent read FOnStatus write FOnStatus;
     property OnPassingReceived: TDecoderPassingReceivedEvent read FOnPassing write FOnPassing;
  end;

  { TMyLapsP3Listener }
  TMyLapsP3Listener = class (TThread)
  private
    FTcpClient: TIdTCPClient;
    FServerPort: word;
    FMessage: string;
    FNewData: string;
    FMyLapsParser: TMyLapsP3MessageParser;
    FDecoderData: TMyLapsP3Decoder;
    procedure PostMessage;
  public
    constructor Create (Decoder: TMyLapsP3Decoder; ServerPort: word); reintroduce;
    destructor Destroy; override;
    procedure Execute; override;
    property MyLapsP3MessageParser: TMyLapsP3MessageParser read FMyLapsParser write FMyLapsParser;
    procedure SendQuery(Msg: string);
    property DecoderData: TMyLapsP3Decoder read FDecoderData;
  end;

  TMyLapsDecoderFinder = class
  private
    FUdpServer: TIdUdpServer;
    FParser: TMyLapsP3MessageParser;
    FOnDecoderFound: TDecoderFoundEvent;
    procedure OnUdpRead(AThread: TIdUDPListenerThread; const AData: TIdBytes; ABinding: TIdSocketHandle);
  public
    constructor Create; virtual;
    destructor Destroy; override;
    property OnDecoderFound: TDecoderFoundEvent read FOnDecoderFound write FOnDecoderFound;
    procedure Update;
  end;

implementation

{==============================================================================}
function TMyLapsP3Passing.ToString: string;
begin
  result := Format('Passing# %d, TxId: %s, TxShortId: %d, Timestamp: %s, Signal: %d, Hits: %d, Flags: %d, Sport: %d, DecoderId: %s',
    [PassingNumber, ChipId,TransponderShortId, DatetimeToStr(PassingTime), SignalStrength,Hits,Flags,Sport,DecoderId]);
end;

{==============================================================================}
constructor TMyLapsP3MessageParser.Create;
begin
  FOnStatus := nil;
  FOnPassing := nil;
  FTimeDeltaDecoderPc := 0.0;
  initTable;
end;

{==============================================================================}
class function TMyLapsP3MessageParser.DecodePassingTime(AmbP3Time: string): TDateTime;
var
  lPassingTime: UInt64;
  lTotalSecondsWithMs: Extended;
  lTotalSeconds: UInt64;
  lSecondsOfDay: Extended;
  lDays: UInt64;
  lMs: UInt64;
const
  cSecsPerDay = 24 * 60 * 60;
begin
  lPassingTime := StrToUInt64('$' + AmbP3Time);
  lTotalSecondsWithMs := lPassingTime / 1000000;
  lTotalSeconds := Trunc(lTotalSecondsWithMs);
  lMs := Trunc((lTotalSecondsWithMs - lTotalSeconds) * 1000);
  lDays := lTotalSeconds div UInt64(cSecsPerDay);
  lSecondsOfDay := lTotalSeconds - (lDays * cSecsPerDay) + (lMs / 1000);
  result := UnixDateDelta + lDays + (lSecondsOfDay / cSecsPerDay);
end;

{==============================================================================}
class function TMyLapsP3MessageParser.EncodePassingTime(ADateTime: TDateTime): string;
var
  lHours, lMinutes, lSeconds, lMs: Word;
  lTotalSecondsWithMs: UInt64;
  lTotalSeconds: UInt64;
  lDays: UInt64;
const
  cSecsPerDay = 24 * 60 * 60;
begin
  lDays := Trunc(ADatetime) - UnixDateDelta;
  DecodeTime(ADateTime, lHours, lMinutes, lSeconds, lMs);
  lTotalSeconds :=
    lDays * cSecsPerDay +
    lHours * 60 * 60 +
    lMinutes * 60 +
    lSeconds;
  lTotalSecondsWithMs := lTotalSeconds * 1000 + lMs;
  result := IntToHex(lTotalSecondsWithMs * 1000);
end;

{==============================================================================}
function TMyLapsP3MessageParser.ParseRecordTypePassing(Body: string): TMyLapsP3Passing;
var i, offset: integer;
    s, d: string;
    FieldOfMessage: integer;
    l: integer;
begin
  // 01.04.11000000.03.04.37774700.04.08.400D72A900000000.05.02.4500.06.02.6C00.08.02.0000.81.04.54020200.02.01.01
  //01.04.F72F0000.0A.08.4B502D3039303434.04.08.68C05AB2DF440500.05.02.A300.06.02.6C00.08.02.0000.14.01.01.81.04.40240400
  //01.04.2B300000.0A.08.4B502D3039303434.04.08.7069674CF1440500.05.02.A100.06.02.6700.08.02.0000.14.01.01.81.04.40240400

  // init
  offset := 0;

  repeat
    // field of message
    s := '$' + MidStr(Body, offset + 1, 2);
    FieldOfMessage := StrToInt(s);
    // length of field
    s := '$' + MidStr(Body, offset + 3, 2);
    l := StrToInt(s);
    // grab data of field
    s := '';
    for i:=l-1 downto 0 do
      s := s + MidStr(Body, offset + 5 + i*2, 2);
    // interpret things
    case FieldOfMessage of
    PASSING_NUMBER:
      result.PassingNumber := StrToInt('$'+s);
    CHIP_CODE:
      begin
        result.ChipId := '';
        for i:=l-1 downto 0 do
        begin
          d := '$' + MidStr(s, 2*i+1, 2);
          result.ChipId := result.ChipId + chr(StrToInt(d));
        end;
      end;
    STRENGTH:
      result.SignalStrength := StrToInt('$' + s);
    RTC_TIME:
      begin
        result.PassingTime := DecodePassingTime(s);
        if FTimeDeltaDecoderPc = 0.0 then FTimeDeltaDecoderPc := result.PassingTime - Now;
          result.PassingTime := result.PassingTime - FTimeDeltaDecoderPc;
      end;
    HITS:
      result.Hits := StrToInt('$' + s);
    FLAGS:
      result.Flags := StrToInt('$' + s);
    SPORT:
      result.Sport := StrToInt('$' + s);
    VOLTAGE:
      result.Voltage := Double(WordRec(s[1]).Lo / 10);
    TEMPERATURE:
      result.Temperature := WordRec(s[1]).Lo - 100;
    DECODER_ID:
      begin
        result.DecoderId := '';
        for i:=l-1 downto 0 do result.DecoderId := result.DecoderId + MidStr(s, i*2+1, 2) + '-';
          result.DecoderId := MidStr(result.DecoderId, 1, length(result.DecoderId) - 1);
      end;
    end;
    //
    offset := offset + 4 + 2*l;
  until offset >= length(Body);
end;

{==============================================================================}
function TMyLapsP3MessageParser.ParseRecordTypeStatus(Body: string): TMyLapsP3Status;
var
  i, offset: integer;
  s: string;
  FieldOfMessage: integer;
  l: integer;
begin
  //    VER LEN  CRC FLOR TOR  FOR
  // 8E.02.1F00.C5F8.0000.0200.01.02.0000.07.02.2900.0C.01.73.06.01.00.81.04.40240400.8F

  // init
  offset := 0;

  repeat
    // field of message
    s := '$' + MidStr(Body, offset + 1, 2);
    FieldOfMessage := StrToInt(s);
    // length of field
    s := '$' + MidStr(Body, offset + 3, 2);
    l := StrToInt(s);
    // grab data of field
    s := '';
    for i:=l-1 downto 0 do
      s := s + MidStr(Body, offset + 5 + i*2, 2);
    // interpret things
    case FieldOfMessage of
    STATUS_NOISE:
      result.Noise := StrToInt('$' + s);
    STATUS_GPS:
      if StrToInt('$' + s) = 1 then
        result.Gps := true
      else
        result.Gps := false;
    STATUS_TEMPERATURE:
      result.Temperature := StrToInt('$' + s) {- 100.0};
    STATUS_INPUT_VOLTAGE:
      result.InputVoltage := StrToInt('$' + s)/10.0;
    DECODER_ID:
      begin
        result.DecoderId := '';
        for i := l - 1 downto 0 do
          result.DecoderId := result.DecoderId + MidStr(s, i*2+1, 2) + '-';
        result.DecoderId := MidStr(result.DecoderId, 1, length(result.DecoderId) - 1);
      end;
    end;
    //
    offset := offset + 4 + 2*l;
  until offset >= length(Body);
end;

{==============================================================================}
function TMyLapsP3MessageParser.ParseRecordTypeVersionDecoder(Body: string): TMyLapsP3Decoder;
var
  i, offset: integer;
  s: string;
  TypeFieldOfRecord: integer;
  l: integer;
begin
// init
offset := 0;

repeat
  // type field of record
  s := '$' + MidStr(Body, offset + 1, 2);
  TypeFieldOfRecord := StrToInt(s);
  // length of field
  s := '$' + MidStr(Body, offset + 3, 2);
  l := StrToInt(s);

  result.Address := '';

  // grab field data
  case TypeFieldOfRecord of
  TOR_VERSION_DECODER_TYPE:
    begin
      result.DecoderType := '';
      for i:=0 to l-1 do
      begin
        s := MidStr(Body, offset+5 + i*2, 2);
        result.DecoderType := result.DecoderType + char(StrToInt('$'+s));
      end;
    end;
  TOR_VERSION_DECODER_FIRMWARE:
    begin
      result.FirmwareVersion := '';
      for i:=0 to l-1 do
      begin
        s := MidStr(Body, offset+5 + i*2, 2);
        result.FirmwareVersion := result.FirmwareVersion + char(StrToInt('$'+s));
      end;
    end;
  TOR_VERSION_DECODER_ID:
    begin
      result.DecoderId := '';
      for i:=0 to l-1 do
      begin
        s := MidStr(Body, offset+5 + i*2, 2);
        result.DecoderId := result.DecoderId + s + '-';
      end;
      result.DecoderId := MidStr(result.DecoderId, 1, length(result.DecoderId) - 1);
    end;
  end;
  //
  offset := offset + 4 + 2*l;
  until offset >= length(Body);
end;

{==============================================================================}
function TMyLapsP3MessageParser.DeEscapeMessage(Msg: string): string;
var i, l, j: integer;
    b: string;
begin
  result := MidStr(Msg, 1, 2);
  l := length(Msg) div 2;
  j := 0;
  i := 1;
  repeat
    b := MidStr(Msg, 2*(i+j)+1, 2);
    if b = '8D' then
    begin
      inc(j);
      b := MidStr(Msg, 2*(i+j)+1, 2);
      result := result + IntToHex(StrToInt('$'+b) - $20, 2);
    end
    else
      result := result + b;
    inc(i);
  until i > (l-j) - 2;
  result := result + MidStr(Msg, length(Msg)-1, 2);
end;

{==============================================================================}
function TMyLapsP3MessageParser.EscapeMessage(Msg: string): string;
var i, l: integer;
    s: string;
begin
  result := MidStr(Msg, 1, 2);
  l := length(Msg) div 2;
  for i:=1 to l-2 do
  begin
    s := MidStr(Msg, 2*i+1, 2);
    if (s = '8E') or (s='8D') or (s='8F') then
      result := result + '8D' + IntToHex((StrToInt('$'+s) + 20), 2)
    else
      result := result + s;
  end;
  result := result + MidStr(Msg, 2*(l-1)+1, 2);
end;

{==============================================================================}
procedure TMyLapsP3MessageParser.AddMessage(Msg: string);
var l: integer;
    s: string;
    IsValid: boolean;
    Version: integer;
    Checksum: integer;
    Flags: integer;
    TypeOfRecord: integer;
    P3Passing: TMyLapsP3Passing;
    P3Status: TMyLapsP3Status;
    P3VersionDecoder: TMyLapsP3Decoder;
    OrigMsg: string;
begin
  try
    //    VER LEN  CRC FLOR TOR  FOR
    // 8E.02.1F00.C5F8.0000.0200.01.02.0000.07.02.2900.0C.01.73.06.01.00.81.04.40240400.8F
    // 8E.02.3A00.0479.0000.0100.01.04.E6330000.0A.08.46432D3932333938.04.8F

    // 8E.02.1D00.48E0.0000.0400.01.04.00010204.02.04.4E000000.81.04.40240400.8F
    // 8E.02.1D00.8350.0000.0400.01.04.00000204.02.04.51000000.81.04.40240400.8F -> answer for "resend 0..1"
    // 8E.02.1D00.A606.0000.0400.01.04.00010204.02.04.52000000.81.04.40240400.8F -> answer for "resend 1..2"

    OrigMsg := Msg;
    Msg := DeEscapeMessage(Msg);
    if length(Msg) >= 23 then
    begin
      // start
      s := '$' + MidStr(Msg, 1, 2);
      if StrToInt(s) <> $8E then IsValid := false;
      // Version
      Version := StrToInt('$' + MidStr(Msg, 3, 2));
      // length of message
      s := '$' + MidStr(Msg, 7, 2) + MidStr(Msg, 5, 2);
      l := StrToInt(s);
      // checksum
      s := '$' + MidStr(Msg, 11, 2) + MidStr(Msg, 9, 2);
      Checksum := StrToInt(s);
      // flags
      s := '$' + MidStr(Msg, 15, 2) + MidStr(Msg, 13, 2);
      Flags := StrToInt(s);
      // TOR (type of record) or message type
      s := '$' + MidStr(Msg, 19, 2) + MidStr(Msg, 17, 2);
      TypeOfRecord := StrToInt(s);

      case TypeOfRecord of
      TOR_PASSING:
        begin
          P3Passing := ParseRecordTypePassing(MidStr(Msg, 21, length(Msg) - 21 - 1));
          if assigned(FOnPassing) then
            FOnPassing(P3Passing);
        end;
      TOR_STATUS:
        begin
          P3Status := ParseRecordTypeStatus(MidStr(Msg, 21, length(Msg) - 21 - 1));
          if assigned(FOnStatus) then
            FOnStatus(P3Status);
        end;
      TOR_VERSION_DECODER:
        P3VersionDecoder := ParseRecordTypeVersionDecoder(MidStr(Msg, 21, length(Msg) - 21 - 1));
      else
        Flags := 0;
      end;
    end;

  except
    s := '';
  end;
end;

{==============================================================================}
function TMyLapsP3MessageParser.AddMessageDecoderSearch(Msg: string): TMyLapsP3Decoder;
var l: integer;
    s: string;
    TypeOfRecord: integer;
begin
  if length(Msg) < 23 then
    Exit;

  // length of message
  s := '$' + MidStr(Msg, 7, 2) + MidStr(Msg, 5, 2);
  l := StrToInt(s);
  // TOR (type of record) or message type
  s := '$' + MidStr(Msg, 19, 2) + MidStr(Msg, 17, 2);
  TypeOfRecord := StrToInt(s);
  //
  case TypeOfRecord of
  TOR_VERSION_DECODER:
    result := ParseRecordTypeVersionDecoder(MidStr(Msg, 21, length(Msg) - 21 - 1));
  end;
end;

{==============================================================================}
function TMyLapsP3MessageParser.GetDecoderSearchPhrase: string;
begin
 // 8E.00.1900.A539.0000.0300.0100.0200.0300.0400.0800.0A00.0C00.8F
 result := '8E001900A53900000300010002000300040008000A000C008F';
end;

{==============================================================================}
function TMyLapsP3MessageParser.GetResendPhrase(FromPassingNr, ToPassingNr: FixedUInt; DecoderId: string): string;
var i: integer;
    crc: word;
    s: string;
begin
  //         VER LEN  CRC FLOR TOR  FOR
  // old: 8E.02.1700.xxxx.0000.0400.01.04.xxxxxxxx.02.04.xxxxxxxx.8F
  // new: 8E.00.1D00.49DF.0000.0400.01.04.xxxxxxxx.02.04.xxxxxxxx.81.04.40240400.8F
  result := '8E001D00000000000400' + '0104';
  s := IntToHex(FromPassingNr, 8);
  for i:=4 downto 1 do
  begin
    result := result + s[i*2-1];
    result := result + s[i*2];
  end;
  result := result + '0204';
  s := IntToHex(ToPassingNr, 8);
  for i:=4 downto 1 do
  begin
    result := result + s[i*2-1];
    result := result + s[i*2];
  end;
  result := result + '8104';
  result := result + DecoderId[1] + DecoderId[2];
  result := result + DecoderId[4] + DecoderId[5];
  result := result + DecoderId[7] + DecoderId[8];
  result := result + DecoderId[10] + DecoderId[11];
  result := result + '8F';
  crc := CalcCrc16(result);
  s := IntToHex(crc, 4);
  result[9] := s[3];
  result[10] := s[4];
  result[11] := s[1];
  result[12] := s[2];
  result := EscapeMessage(result);
end;

{==============================================================================}
function TMyLapsP3MessageParser.GetPassingPhrase(APassing: TMyLapsP3Passing): string;
var
  lCRC: Word;
  s: string;
  i: integer;
begin
  result := '8E025A000000000001000104';

  s := IntToHex(APassing.PassingNumber, 8);
  for i := 4 downto 1 do
  begin
    result := result + s[i*2-1];
    result := result + s[i*2];
  end;

  result := result + '0408' + EncodePassingTime(APassing.PassingTime);
  result := result + '0502' + IntToHex(APassing.SignalStrength, 4);
  result := result + '0602' + IntToHex(APassing.Hits, 4);
  result := result + '0802' + IntToHex(APassing.Flags, 4);
  result := result + '0A';
  result := result + '8104';
  result := result + APassing.DecoderId[1] + APassing.DecoderId[2];
  result := result + APassing.DecoderId[4] + APassing.DecoderId[5];
  result := result + APassing.DecoderId[7] + APassing.DecoderId[8];
  result := result + APassing.DecoderId[10] + APassing.DecoderId[11];
  result := result + '8F';

  s := IntToHex(Length(result), 4);
  result[3] := s[3];
  result[4] := s[4];
  result[5] := s[1];
  result[6] := s[2];

  lCRC := CalcCrc16(result);
  s := IntToHex(lCRC, 4);
  result[9] := s[3];
  result[10] := s[4];
  result[11] := s[1];
  result[12] := s[2];
  result := EscapeMessage(result);
end;

{==============================================================================}
function TMyLapsP3MessageParser.GetRtcPhrase: string;
var crc: word;
    s: string;
begin
  //    VER LEN  CRC FLOR TOR  FOR
  // 8E.00.1900.A539.0000.0300.0100.0200.0300.0400.0800.0A00.0C00.8F (decoder search)
  // 8E.02.1700.xxxx.0000.2400.0100.0200.0300.0400.0800.0A00.0C00.8F (get RTC)
  result := '8E021700000000002400010002000300040008000A000C008F';
  crc := CalcCrc16(result);
  s := IntToHex(crc, 4);
  result[9] := s[3];
  result[10] := s[4];
  result[11] := s[1];
  result[12] := s[2];
  result := EscapeMessage(result);
end;


{$IFOPT R+}
  {$DEFINE RANGEON}
  {$R-}
{$ELSE}
  {$UNDEF RANGEON}
{$ENDIF}
{==============================================================================}
procedure TMyLapsP3MessageParser.initTable;
var i, j: integer;
    crc: word;
begin
  for i:=0 to 255 do
  begin
    crc := i shl 8;
    for j:=0 to 7 do
    begin
      if crc and $8000 > 0 then
        crc := (crc shl 1) xor $1021
      else
        crc := (crc shl 1) xor 0;
    end;
    FCrcTable[i] := crc;
  end;
end;
{$IFDEF RANGEON}
  {$R+}
  {$UNDEF RANGEON}
{$ENDIF}



{$IFOPT R+}
  {$DEFINE RANGEON}
  {$R-}
{$ELSE}
  {$UNDEF RANGEON}
{$ENDIF}
{==============================================================================}
function TMyLapsP3MessageParser.CalcCrc16(Msg: AnsiString): word;
var crc: word;
    i, l: integer;
    b: byte;
begin
  crc := $FFFF;
  l := length(Msg) div 2;
  for i:=0 to l-1 do
  begin
    b := StrToInt('$'+MidStr(Msg, 2*i+1, 2));
    crc := (FCrcTable[(crc shr 8) and 255] xor (crc shl 8)) xor b;
  end;
  result := crc;
end;
{$IFDEF RANGEON}
  {$R+}
  {$UNDEF RANGEON}
{$ENDIF}

{==============================================================================}
constructor TMyLapsP3Listener.Create(Decoder: TMyLapsP3Decoder; ServerPort: word);
begin
  inherited Create(true);
  FTcpClient := TIdTCPClient.Create(nil);
  FDecoderData := Decoder;
  FServerPort := ServerPort;
end;

{==============================================================================}
destructor TMyLapsP3Listener.Destroy;
begin
  FreeAndNil(FTcpClient);
  inherited Destroy;
end;

{==============================================================================}
procedure TMyLapsP3Listener.Execute;
var
  i, j, k: integer;
  InByte: Byte;
begin
  repeat
    try
      if not FTcpClient.Connected then
        FTcpClient.Connect(FDecoderData.Address, FServerPort);

      InByte := FTcpClient.IOHandler.ReadByte;
      FNewData := FNewData + IntToHex(InByte, 2);

      i := PosEx('8E', FNewData);
      if i = 0 then
        Continue;

      k := i;
      repeat
        j := PosEx('8F', FNewData, k);
        if (j-i) mod 2 = 1 then
          k := j + 1;
      until (j = 0) or ((j-i) mod 2 = 0);

      if (j > 0) and ((j-i) mod 2 = 0) then
      begin
        FMessage := MidStr(FNewData, i, j-i+2);
        FNewData := MidStr(FNewData, j+2, length(FNewData)-j-2+1);
        Synchronize(PostMessage);
      end;
    except
    end;
  until Terminated;

  if FTcpClient.Connected then
    FTcpClient.Disconnect;
end;

{==============================================================================}
procedure TMyLapsP3Listener.SendQuery(Msg: string);
var i, l: integer;
    ABuffer: TIdBytes;
    s: string;
begin
  if FTcpClient.Connected then
  begin
    l := length(Msg) div 2;
    setlength(ABuffer, l);
    for i:=0 to l-1 do
    begin
      s := MidStr(Msg, 2*i+1, 2);
      ABuffer[i] := StrToInt('$'+s);
    end;
    FTcpClient.IOHandler.Write(ABuffer, l);
  end;
end;

{==============================================================================}
procedure TMyLapsP3Listener.PostMessage;
begin
  if assigned(FMyLapsParser) then
  begin
    FMyLapsParser.AddMessage(FMessage);
    FMessage := '';
  end;
end;

{ TMyLapsDecoderSearcher }

{==============================================================================}
constructor TMyLapsDecoderFinder.Create;
begin
  inherited;
  FOnDecoderFound := nil;
  FParser := TMyLapsP3MessageParser.Create;
  FUdpServer := TIdUDPServer.Create(nil);
  FUdpServer.ReuseSocket := rsTrue;
  FUdpServer.DefaultPort := 5303;
  FUdpServer.BroadcastEnabled := true;
  FUdpServer.OnUDPRead := OnUdpRead;
  FUdpServer.Active := true;
end;

{==============================================================================}
destructor TMyLapsDecoderFinder.Destroy;
begin
  try
    if assigned(FUdpServer) then
    begin
      FUdpServer.OnUDPRead := nil;
      FUdpServer.Active := false;
      FUdpServer.Bindings.Clear;
      FreeAndNil(FUdpServer);
    end;

    if assigned(FParser) then
      FreeAndNil(FParser);
  finally
    inherited;
  end;
end;

{==============================================================================}
procedure TMyLapsDecoderFinder.OnUdpRead(AThread: TIdUDPListenerThread; const AData: TIdBytes; ABinding: TIdSocketHandle);
var
  lDecoder: TMyLapsP3Decoder;
  lMsg: string;
begin
  lDecoder := FParser.AddMessageDecoderSearch(lMsg);
  lDecoder.Address := ABinding.PeerIP;
  if assigned(FOnDecoderFound) then
    FOnDecoderFound(lDecoder);
end;

{==============================================================================}
procedure TMyLapsDecoderFinder.Update;
var i: integer;
    sReq: string;
    s: string;
    ReqBuf: TIdBytes;
begin
  sReq := FParser.GetDecoderSearchPhrase;
  setlength(ReqBuf, trunc(length(sReq)/2));
  for i:=0 to length(ReqBuf) - 1 do
  begin
    s := MidStr(sReq, 2*i+1, 2);
    ReqBuf[i] := StrToInt('$' + s);
  end;
  FUdpServer.SendBuffer('255.255.255.255', 5403, ReqBuf);
end;

end.
