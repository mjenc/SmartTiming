unit DecoderInterface;

interface

uses
  DataStructures, DatabaseAccess, Utilities,
  MylapsSDK,
  Forms, Vcl.Dialogs, Classes, SysUtils, StrUtils, ComCtrls, StdCtrls, ExtCtrls, System.TimeSpan,
  IdTCPConnection, IdTCPClient, IdBaseComponent, IdComponent, IdCustomTCPServer, IdTCPServer, IdUdpServer,
  IdGlobal, IdSocketHandle, System.SyncObjs, AdPort, Math, System.DateUtils,
  Winapi.Windows, Winapi.MMSystem;

const

  // MyLaps protocol P3 (source: http://www.hobbytalk.com/bbs1/archive/index.php/t-73738.html)

  // "TOR", i.e. "type of record" constants
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

  // message type "PASSING" constants
  PASSING_NUMBER = $01; //(4 byte) (example of "FOR" - 0x01(TOF):0x04(length):0x00:0x00:0x00:0x00)
  TRANSPONDER_ID_TYPE_TRANX = $03;
  TRANSPONDER_ID_TYPE_PROCHIPFLEXCHIP = $0a;
  RTC_ID = $13;
  RTC_TIME = $04;    // (8 byte, time microseconds after January 1, 1970 00:00:00 GMT)
  UTC_TIME = $10;    // (8 byte, time microseconds after January 1, 1970 00:00:00 GMT)
  STRENGTH = $05;
  HITS = $06;
  FLAGS = $08;
  USER_FLAG = $0e;
  DRIVER_ID = $0f;
  SPORT = $14;
  VOLTAGE = $30;     // (1 byte, V = (float)voltage/10)
  TEMPERATURE = $31; // (1 byte, T = temperature - 100)
  DECODER_ID = $81;

  // message type "STATUS" constants
  STATUS_NOISE = $01;
  STATUS_GPS = $06;          // (1 byte; 0=false, 1=true)
  STATUS_TEMPERATURE = $07;
  STATUS_SATINUSE = $0a;
  STATUS_LOOP_TRIGGERS = $0b;
  STATUS_INPUT_VOLTAGE = $0c;// (1 byte, Voltage = (float)input_voltage/10)

  // message type "RESEND" constants
  RESEND_FROM = $01;
  RESEND_TO = $02;

  // message type "RTC" constants
  FOM_RTC = $01;

  // message type "Session" constants
  LAST_PASSING_INDEX = $04;

  // TOR VERSION constants
  TOR_VERSION_DECODER_TYPE = $02;
  TOR_VERSION_DECODER_FIRMWARE = $03;
  TOR_VERSION_DECODER_ID = $81;

  // general message constants
  CONTROLLER_ID = $83;
  REQUEST_ID = $85;

type
     TMyLapsProtocol = (mlpP3, mlpX2);
     TDecderType = (dcUnknown, dcChipX, dcProChipSmart, dcX2);
     TDecoderListenerBase = class (TThread)
       private
         FMessage: string;
         FDecoderData: TDecoderData;
         FRtcQuerySendTime: TDateTime;
         FDecoderType: TDecderType;
       public
         constructor Create (DecoderData: TDecoderData); reintroduce;
         destructor Destroy; override;
         property DecoderData: TDecoderData read FDecoderData;
         property DecoderType: TDecderType read FDecoderType;
         procedure SendQuery(Msg: string); virtual; abstract;
         property RtcQuerySendTime: TDateTime read FRtcQuerySendTime;
     end;
     TDecoderListeners = array of TDecoderListenerBase;



     { TMyLapsP3MessageParser }

     TMyLapsP3Passing = record
       PassingNumber: integer;
       TransponderId: string;
       PassingTime: TDateTime;
       SignalStrength: integer;
       Hits: integer;
       Sport: byte;
       DecoderId: string;
       LowBattWarning: boolean;
     end;
     TMyLapsP3Passings = array of TMyLapsP3Passing;

     TMyLapsP3Status = record
       Noise: integer;
       Gps: boolean;
       Temperature: double;
       InputVoltage: double;
       DecoderId: string;
     end;

     TMyLapsP3VersionDecoder = record
       FirmwareVersion: string;
       DecoderType: string;   // "ProChip Smart Decoder" or "ChipX Decoder"
       DecoderId: string;
     end;

     TMyLapsP3RealTimeClock = record
       CurrentDecoderTime: TDateTime;
       DecoderId: string;
     end;

     TMyLapsP3Session = record
       LastPassingIndex: integer;
       DecoderId: string;
     end;

     TDecoderInfo = record
       IpAddress: string;
       Username: string;
       Password: string;
       DecoderVersion: TMyLapsP3VersionDecoder;
       BeepOnPassing: boolean;
       TimeHorizon: TDateTime;
     end;
     TDecoderInfos = array of TDecoderInfo;

     TDecoderStatusReceivedEvent = procedure (Status: TMyLapsP3Status) of object;
     TDecoderPassingReceivedEvent = procedure (Passing: TMyLapsP3Passing) of object;
     TDecoderRealTimeClockReceivedEvent = procedure (DecoderTime: TMyLapsP3RealTimeClock) of object;
     TDecoderSessionReceivedEvent = procedure (Session: TMyLapsP3Session) of object;
     TDecoderResponseTestEvent = procedure (TestPassed: boolean) of object;

     TMyLapsP3MessageParser = class
       private
         FOnStatus: TDecoderStatusReceivedEvent;
         FOnPassing: TDecoderPassingReceivedEvent;
         FOnRtc: TDecoderRealTimeClockReceivedEvent;
         FOnSession: TDecoderSessionReceivedEvent;
         FCrcTable: array[0..255] of word;
         FTimeDeltaDecoderPc: TTimeSpan; // time delta between decoder and PC clock
         function DecodePassingTime(AmbP3Time: string): TDateTime;
         function ParseRecordTypePassing(Body: string): TMyLapsP3Passing;
         function ParseRecordTypeStatus(Body: string): TMyLapsP3Status;
         function ParseRecordTypeVersionDecoder(Body: string): TMyLapsP3VersionDecoder;
         function ParseRecordTypeGetRtc(Body: string): TMyLapsP3RealTimeClock;
         function ParseRecordTypeSession(Body: string): TMyLapsP3Session;
         function DeEscapeMessage(Msg: string): string;
         function EscapeMessage(Msg: string): string;
         procedure initTable;
         function CalcCrc16(Msg: AnsiString): word;
       public
         constructor Create; virtual;
         procedure AddMessage(Msg: string; DecoderData: TDecoderData);
         function AddMessageDecoderSearch(Msg: string): TMyLapsP3VersionDecoder;
         function GetDecoderSearchPhrase: string;
         function GetResendPhrase(FromPassingNr, ToPassingNr: FixedUInt; DecoderId: string): string;
         function GetRtcPhrase: string;
         function GetSessionPhrase(DecoderId: string): string;
         property OnStatusReceived: TDecoderStatusReceivedEvent read FOnStatus write FOnStatus;
         property OnPassingReceived: TDecoderPassingReceivedEvent read FOnPassing write FOnPassing;
         property OnRealTimeClockReadingReceived: TDecoderRealTimeClockReceivedEvent read FOnRtc write FOnRtc;
         property OnSessionDataReceived: TDecoderSessionReceivedEvent read FOnSession write FOnSession;
         function ReverseParseRecordTypeVersionDecoder(FirmwareVersion, DecoderType, DecoderId: string): TIdBytes;
         property TimeDeltaDecoderPc: TTimeSpan read FTimeDeltaDecoderPc;
     end;



     { TMyLapsX2EventManager }

     TMyLapsX2EventManager = class
       private
         FOnPassing: TDecoderPassingReceivedEvent;
         FTimeDeltaDecoderPc: TTimeSpan;   // time delta between X2 server time domain and PC clock
         FIsSynched: boolean;
         FOnStatus: TDecoderStatusReceivedEvent;
         FRaceBase: TRaceBase;
         FResending: boolean;
         FLastStatus: array of TMyLapsP3Status;
         FBeepingOnPassingDecoderIds: TIntegerArray;
         procedure PlayShortBeep;
         function IsInBeepList(DecoderId: integer): boolean;
       public
         constructor Create; virtual;
         property TimeDeltaDecoderPc: TTimeSpan read FTimeDeltaDecoderPc;
         property OnPassingReceived: TDecoderPassingReceivedEvent read FOnPassing write FOnPassing;
         property OnStatusReceived: TDecoderStatusReceivedEvent read FOnStatus write FOnStatus;
         procedure AddPassing(Passing: TMyLapsP3Passing; CheckResend: boolean);
         procedure AddStatus(Status: TMyLapsP3Status);
         property RaceBase: TRaceBase write FRaceBase;
         property Resending: boolean write FResending;
         procedure BeepOnPassing(DecoderId: string; DoBeep: boolean);
     end;



     { TMyLapsP3Listener }

     TMyLapsP3Listener = class (TDecoderListenerBase)
       private
         FTcpClient: TIdTCPClient;
         FListBoxRawData: TListBox;
         FServerPort: word;
         FMessage: string;
         FNewData: string;
         FMyLapsParser: TMyLapsP3MessageParser;
         FQueryServerQueue: TStringList;
         FCriticalSection: TCriticalSection;
         FGetRtcPhrase: string;
         procedure PostMessage;
         procedure PostNewData;
         procedure SetMyLapsParser(const Value: TMyLapsP3MessageParser);
       public
         constructor Create (DecoderData: TDecoderData; ServerPort: word); reintroduce;
         destructor Destroy; override;
         procedure Execute; override;
         property MyLapsP3MessageParser: TMyLapsP3MessageParser read FMyLapsParser write SetMyLapsParser;
         property ListBoxRawData: TListBox read FListBoxRawData write FListBoxRawData;
         procedure SendQuery(Msg: string); override;
         property DecoderData: TDecoderData read FDecoderData;
     end;
     TMyLapsP3Listeners = array of TMyLapsP3Listener;



     { TMyLapsX2Listener }

     TMyLapsX2Listener = class (TDecoderListenerBase)    // dummy class just to store decoder data
       private
         FDecoderData: TDecoderData;
       public
         constructor Create (DecoderData: TDecoderData); reintroduce;
         procedure Execute; override;
         property DecoderData: TDecoderData read FDecoderData;
     end;



     { TMyLapsX2Connector }

     TX2Connection = record
       app_handle: Tmta_handle_t;
       sdk_handle: mdp_sdk_handle_t;
       event_handle: Tmta_eventdata_handle_t;
       Resending: boolean;
       LastContact: TDateTime;
       ServerIp: string;
       LoopId: TStringArray;
     end;
     TX2Connections = array of TX2Connection;

     TMyLapsX2Connector = class
       private
         FX2Connections: TX2Connections;
       public
         constructor Create;
         destructor Destroy;
         procedure Connect(IpAddress, Username, Password: string; TimeHorizon: TDateTime);
         procedure SubscribeLoop(LoopId, ServerIp: string);
         procedure ProcessMessages;
     end;



     { TMyLapsDecoderSearcher }

     TMyLapsDecoderSearcher = class
       private
         FUdpServer: TIdUdpServer;
         FParser: TMyLapsP3MessageParser;
         FDecoderInfos: TDecoderInfos;
         FOnDecoderFound: TNotifyEvent;
         FX2ServerReconnectTimeHorizon: TDateTime;  // only for X2 system
         procedure OnUdpRead(AThread: TIdUDPListenerThread; const AData: TIdBytes; ABinding: TIdSocketHandle);
         function GetAddress(i: integer): string;
         function GetData(i: integer): TMyLapsP3VersionDecoder;
         function GetInfo(i: integer): TDecoderInfo;
         function GetCount: integer;
       public
         constructor Create; virtual;
         destructor Destroy; override;
         property DecoderIpAddress[i: integer]: string read GetAddress;
         property DecoderData[i: integer]: TMyLapsP3VersionDecoder read GetData;
         property DecoderInfo[i: integer]: TDecoderInfo read GetInfo;
         property Count: integer read GetCount;
         property OnDecoderFound: TNotifyEvent read FOnDecoderFound write FOnDecoderFound;
         procedure Update;
         procedure UpdateX2(IpAddress, Username, Password: AnsiString; BeepOnPassing: boolean = false; TimeHorizon: TDateTime = 0.0);
         property X2ServerReconnectTimeHorizon: TDateTime read FX2ServerReconnectTimeHorizon write FX2ServerReconnectTimeHorizon;
         procedure Clear;
     end;



     { TMandigoMessageParser }

     TMandigoMessageParser = class
       private
         FOnPassing: TDecoderPassingReceivedEvent;
         FOnRtc: TDecoderRealTimeClockReceivedEvent;
         FTimeDeltaDecoderPc: TTimeSpan; // time delta between decoder and PC clock
         FDecoderId: string;
         function ParseRecordTypePassing(Msg: string): TMyLapsP3Passing;
         function ParseRecordTypeGetRtc(Msg: string): TMyLapsP3RealTimeClock;
       public
         constructor Create; virtual;
         procedure AddMessage(Msg: string; DecoderData: TDecoderData);
         property OnPassingReceived: TDecoderPassingReceivedEvent read FOnPassing write FOnPassing;
         property OnRealTimeClockReadingReceived: TDecoderRealTimeClockReceivedEvent read FOnRtc write FOnRtc;
         property TimeDeltaDecoderPc: TTimeSpan read FTimeDeltaDecoderPc;
         property DecoderId: string read FDecoderId write FDecoderId;
         function GetRtcPhrase: string;
     end;



     { TMandigoDecoderListener }

     TMandigoDecoderListener = class (TDecoderListenerBase)
       private
         FComPort: TApdComPort;
         FListBoxRawData: TListBox;
         FMessage: string;
         FNewData: string;
         FMandigoMessageParser: TMandigoMessageParser;
         FDecoderData: TDecoderData;
         FQueryServerQueue: TStringList;
         FCriticalSection: TCriticalSection;
         FGetRtcPhrase: string;
         procedure PostMessage;
         procedure PostNewData;
         procedure SetMandigoParser(const Value: TMandigoMessageParser);
         function ReadLine(TimeOutMs: integer): string;
       public
         constructor Create (DecoderData: TDecoderData; ComPort: word); reintroduce;
         destructor Destroy; override;
         procedure Execute; override;
         property MandigoMessageParser: TMandigoMessageParser read FMandigoMessageParser write SetMandigoParser;
         property ListBoxRawData: TListBox read FListBoxRawData write FListBoxRawData;
         procedure SendQuery(Msg: string); override;
         property DecoderData: TDecoderData read FDecoderData;
     end;



     { TRaceResultsMessageParser }

     TRaceResultsMessageParser = class
       private
         FOnPassing: TDecoderPassingReceivedEvent;
         FOnStatus: TDecoderStatusReceivedEvent;
         FOnRtc: TDecoderRealTimeClockReceivedEvent;
         FTimeDeltaDecoderPc: TTimeSpan; // time delta between decoder and PC clock
         FDecoderId: string;
       public
         constructor Create; virtual;
         procedure AddMessage(Msg: string; DecoderData: TDecoderData);
         property OnPassingReceived: TDecoderPassingReceivedEvent read FOnPassing write FOnPassing;
         property OnStatusReceived: TDecoderStatusReceivedEvent read FOnStatus write FOnStatus;
         property OnRealTimeClockReadingReceived: TDecoderRealTimeClockReceivedEvent read FOnRtc write FOnRtc;
         property TimeDeltaDecoderPc: TTimeSpan read FTimeDeltaDecoderPc;
         property DecoderId: string read FDecoderId write FDecoderId;
     end;


     { TRaceResultListener }

     TRaceResultListener = class (TDecoderListenerBase)
       private
         FTcpClient: TIdTCPClient;
         FListBoxRawData: TListBox;
         FServerPort: word;
         FMessage: string;
         FNewData: string;
         FQueryServerQueue: TStringList;
         FCriticalSection: TCriticalSection;
         FRaceResultsMessageParser: TRaceResultsMessageParser;
         procedure PostMessage;
         procedure PostNewData;
       public
         constructor Create (DecoderData: TDecoderData; ServerPort: word); reintroduce;
         destructor Destroy; override;
         procedure Execute; override;
         property RaceResultsMessageParser: TRaceResultsMessageParser read FRaceResultsMessageParser write FRaceResultsMessageParser;
         property ListBoxRawData: TListBox read FListBoxRawData write FListBoxRawData;
         procedure SendQuery(Msg: string); override;
         property DecoderData: TDecoderData read FDecoderData;
     end;
     TRaceResultListeners = array of TRaceResultListener;



     { TTransponderMultiplexer }

     TTransponderReference = record
       InCode: string;
       OutCode: string;
     end;
     TTransponderReferences = array of TTransponderReference;

     TTransponderMultiplexer = class
       private
         FTransponderReferences: TTransponderReferences;
         FCount: integer;
       public
         constructor Create; virtual;
         procedure SetTransponderReference(InCode, OutCode: string);
         procedure DeleteTransponderReference(InCode: string);
         property Count: integer read FCount;
         function GetOutCode(InCode: string): string;
         function GetTransponderReference(index: integer): TTransponderReference;
     end;



var GlobalMyLapsX2EventManager: TMyLapsX2EventManager;


implementation

var {GlobalDecoderInfos: TX2DecoderInfos;}
    CriticalSectionX2Event: TCriticalSection;

{ TMyLapsP3MessageParser }

constructor TMyLapsP3MessageParser.Create;
begin
 inherited;
 FOnStatus := nil;
 FOnPassing := nil;
 FOnRtc := nil;
 FOnSession := nil;
 FTimeDeltaDecoderPc := TTimeSpan.Zero;
 initTable;
end;



function TMyLapsP3MessageParser.DecodePassingTime(AmbP3Time: string): TDateTime;
var PassingTimeUs, UsPerDay: UInt64;
    FullDays: UInt64;
    FracDays, f: extended;
begin
 PassingTimeUs := StrToUInt64('$' + AmbP3Time);
 UsPerDay := UInt64(24)*3600*1000000;
 FullDays := PassingTimeUs div UsPerDay;
 f := 24.0;
 f := f*3600.0;
 f := f*1000000.0;
 FracDays := (PassingTimeUs mod UsPerDay)/f;
 result := EncodeDate(1970, 1, 1) + FullDays + FracDays;
end;



function TMyLapsP3MessageParser.ParseRecordTypePassing(Body: string): TMyLapsP3Passing;
var i, offset: integer;
    s, d: string;
    FieldOfMessage: integer;
    l: integer;
begin
 // 01.04.11000000.03.04.37774700.04.08.400D72A900000000.05.02.4500.06.02.6C00.08.02.0000.81.04.54020200.02.01.01
 // 01.04.F72F0000.0A.08.4B502D3039303434.04.08.68C05AB2DF440500.05.02.A300.06.02.6C00.08.02.0000.14.01.01.81.04.40240400
 // 01.04.2B300000.0A.08.4B502D3039303434.04.08.7069674CF1440500.05.02.A100.06.02.6700.08.02.0000.14.01.01.81.04.40240400
 //
 // "switch" passing:
 // 01.04.99130000.03.04.08270000.04.08.38357E2CDA4E0500.08.02.0000.14.01.50.81.04.40240400.8F
 //
 // TranX-Chip (Leihkart) '01.04.4D320000.03.04.52B52F00.04.08.D04D8211C4840500.05.02.AE00.06.02.C700.08.02.0000.81.04.BF0A0400'
 // Transponder: 3126610 = 2FB552

 // init
 offset := 0;
 result.PassingTime := 0.0;
 result.LowBattWarning := false;

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
    TRANSPONDER_ID_TYPE_TRANX:
     begin
      result.TransponderId := '';
      d := '$';
      for i:=0 to l-1 do d := d + MidStr(s, 2*i+1, 2);
      result.TransponderId := IntToStr(StrToInt(d));
      // Tapeswitch connection: on decoder SubD15 plug, bridge pins 13 and 15
      //      and connect tapeswitch terminals to pins 12 and 5
      if result.TransponderId = '9992' then result.TransponderId := 'Switch'
      else if result.TransponderId = '9993' then result.TransponderId := 'SyncPulse'
      // CAUTION: photo cell input, not switch - but treated just like switch
      else if result.TransponderId = '9991' then result.TransponderId := 'FinishCamStart';
     end;
    TRANSPONDER_ID_TYPE_PROCHIPFLEXCHIP:
     begin
      result.TransponderId := '';
      for i:=l-1 downto 0 do
       begin
        d := '$' + MidStr(s, 2*i+1, 2);
        result.TransponderId := result.TransponderId + chr(StrToInt(d));
       end;
     end;
    STRENGTH:
     result.SignalStrength := StrToInt('$' + s);
    RTC_TIME:            // time of internal clock as manually adjusted
      if result.PassingTime = 0.0
        then result.PassingTime := DecodePassingTime(s);
    UTC_TIME:            // GPS time - when available (GPS receiver plugged in and satellites fixed)
      result.PassingTime := DecodePassingTime(s);
    HITS:
     result.Hits := StrToInt('$' + s);
    FLAGS:               // bit 0 'high' indicates low battery
     result.LowBattWarning := (StrToInt('$' + s) and 1) <> 0;
    SPORT:
     result.Sport := StrToInt('$' + s);
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



function TMyLapsP3MessageParser.ParseRecordTypeStatus(Body: string): TMyLapsP3Status;
var i, offset: integer;
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
      if StrToInt('$' + s) = 1 then result.Gps := true else result.Gps := false;
    STATUS_TEMPERATURE:
      result.Temperature := StrToInt('$' + s);
    STATUS_INPUT_VOLTAGE:
      result.InputVoltage := StrToInt('$' + s)/10.0;
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



function TMyLapsP3MessageParser.ParseRecordTypeVersionDecoder(Body: string): TMyLapsP3VersionDecoder;
// 8E02.4800.F1170000.0300.010114020D4368697058204465636F6465720309342E332E3132303138040480A12B58080833C552F24C42D46A0A027C410C04090000008104402404008F
var i, offset: integer;
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



function TMyLapsP3MessageParser.ReverseParseRecordTypeVersionDecoder(FirmwareVersion, DecoderType, DecoderId: string): TIdBytes;
var i: integer;
    s: string;
begin
 s := '8E02.4800.F1170000.0300.01.01.14.02.0D.4368697058204465636F646572.03.09.342E332E3132303138.04.04.80A12B58.08.08.33C552F24C42D46A.0A.02.7C41.0C.04.09000000.81.04.402404008F';
 s := '8E024800F11700000300';
 s := s + '8104';
 s := s + MidStr(DecoderId, 1, 2);
 s := s + MidStr(DecoderId, 4, 2);
 s := s + MidStr(DecoderId, 7, 2);
 s := s + MidStr(DecoderId, 10, 2);
 s := s + IntToHex(TOR_VERSION_DECODER_TYPE, 2);
 s := s + IntToHex(length(DecoderType), 2);
 for i:=1 to length(DecoderType) do
   s := s + IntToHex(ord(DecoderType[i]), 2);
 s := s + IntToHex(TOR_VERSION_DECODER_FIRMWARE, 2);
 s := s + IntToHex(length(FirmwareVersion), 2);
 for i:=1 to length(FirmwareVersion) do
   s := s + IntToHex(ord(FirmwareVersion[i]), 2);
 s := s + '8F';
 setlength(result, length(s) shr 1);
 for i:=0 to (length(s) shr 1) - 1 do result[i] := StrToInt('$'+MidStr(s, 2*i+1, 2));
end;



function TMyLapsP3MessageParser.ParseRecordTypeGetRtc(Body: string): TMyLapsP3RealTimeClock;
var i, offset: integer;
    s, d: string;
    FieldOfMessage: integer;
    l: integer;
begin
 //                           <BODY...
 //                           FOM
 // 8E.02.1F00.0D33.0000.2400.01.08.604B65A2B64A0500.04.02.0000.81.04.40240400.8F -> answer for GetRtc

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
    FOM_RTC:
     begin
      result.CurrentDecoderTime := DecodePassingTime(s);
     end;
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



function TMyLapsP3MessageParser.ParseRecordTypeSession(Body: string): TMyLapsP3Session;
var i, offset: integer;
    s, d: string;
    FieldOfMessage: integer;
    l: integer;
begin
 //                                                                        last passing index     MAC
 // 8E.02.3300.95E0.0000.1500.02.04.3271F455.01.04.01000000.03.04.00000000.04.04.120A0000.81.04.9B0F0200.85.08.0100000000000000.8F
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
    LAST_PASSING_INDEX:
     begin
      result.LastPassingIndex := StrToInt('$'+s);
     end;
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
    else result := result + b;
  inc(i);
 until i > (l-j) - 2;
 result := result + MidStr(Msg, length(Msg)-1, 2);
end;



function TMyLapsP3MessageParser.EscapeMessage(Msg: string): string;
var i, l: integer;
    s: string;
begin
 result := MidStr(Msg, 1, 2);
 l := length(Msg) div 2;
 for i:=1 to l-2 do
  begin
    s := MidStr(Msg, 2*i+1, 2);
    if (s = '8E') or (s='8D') or (s='8F') then result := result + '8D' + IntToHex((StrToInt('$'+s) + $20), 2)
      else result := result + s;
  end;
 result := result + MidStr(Msg, 2*(l-1)+1, 2);
end;



procedure TMyLapsP3MessageParser.AddMessage(Msg: string; DecoderData: TDecoderData);
var l: integer;
    s: string;
    IsValid: boolean;
    Version: integer;
    Checksum: integer;
    Flags: integer;
    TypeOfRecord: integer;
    P3Passing: TMyLapsP3Passing;
    P3Status: TMyLapsP3Status;
    P3VersionDecoder: TMyLapsP3VersionDecoder;
    P3Rtc: TMyLapsP3RealTimeClock;
    P3Session: TMyLapsP3Session;
    OrigMsg: string;
begin
 try
  //    VER LEN  CRC FLOR TOR  FOR
  // 8E.02.1F00.C5F8.0000.0200.01.02.0000.07.02.2900.0C.01.73.06.01.00.81.04.40240400.8F
  // 8E.02.3A00.0479.0000.0100.01.04.E6330000.0A.08.46432D3932333938.04.8F

  // 8E.02.1D00.48E0.0000.0400.01.04.00010204.02.04.4E000000.81.04.40240400.8F
  // 8E.02.1D00.8350.0000.0400.01.04.00000204.02.04.51000000.81.04.40240400.8F -> answer for "resend 0..1"
  // 8E.02.1D00.A606.0000.0400.01.04.00010204.02.04.52000000.81.04.40240400.8F -> answer for "resend 1..2"

  // 8E.02.1F00.0D33.0000.2400.01.08.604B65A2B64A0500.04.02.0000.81.04.40240400.8F -> answer for GetRtc
  //                                                                         Passing number        MAC
  // 8E.02.3300.95E0.0000.1500.02.04.3271F455.01.04.01000000.03.04.00000000.04.04.120A0000.81.04.9B0F0200.85.08.0100000000000000.8F

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
        if not DecoderData.UseSoftwareSynch then
          begin
           // set FTimeDeltaDecoderPC upon FIRST CONTACT (make sure only ONE INSTANCE of this class is used in main!)
           if FTimeDeltaDecoderPc.Ticks = 0 then FTimeDeltaDecoderPc := TTimeSpan.Subtract(P3Passing.PassingTime, Now);
           // apply correction
           P3Passing.PassingTime := P3Passing.PassingTime - FTimeDeltaDecoderPc;
          end
          else begin
           P3Passing.PassingTime := P3Passing.PassingTime - DecoderData.DeltaTimeWithPc;
          end;
        if assigned(FOnPassing) then FOnPassing(P3Passing);
       end;
     TOR_STATUS:
       begin
        P3Status := ParseRecordTypeStatus(MidStr(Msg, 21, length(Msg) - 21 - 1));
        if assigned(FOnStatus) then FOnStatus(P3Status);
       end;
     TOR_VERSION_DECODER:
       begin
        P3VersionDecoder := ParseRecordTypeVersionDecoder(MidStr(Msg, 21, length(Msg) - 21 - 1));
       end;
     TOR_GET_TIME:
       begin
        P3Rtc := ParseRecordTypeGetRtc(MidStr(Msg, 21, length(Msg) - 21 - 1));
        if assigned(FOnRtc) then FOnRtc(P3Rtc);
       end;
     TOR_SESSION:
       begin
         P3Session := ParseRecordTypeSession(MidStr(Msg, 21, length(Msg) - 21 - 1));
         if assigned(FOnSession) then FOnSession(P3Session);
       end
     else begin
       Flags := 0;
     end;
    end;
   end;

 except
  s := '';
 end;
end;



function TMyLapsP3MessageParser.AddMessageDecoderSearch(Msg: string): TMyLapsP3VersionDecoder;
// 8E02.4800.F1170000.0300.01.01.14.02.0D.4368697058204465636F646572.03.09.342E332E3132303138.04.04.80A12B58.08.08.33C552F24C42D46A.0A.02.7C41.0C.04.09000000.81.04.40240400.8F
var l: integer;
    s: string;
    TypeOfRecord: integer;
begin
  //
  Msg := DeEscapeMessage(Msg);
  if length(Msg) >= 23 then
   begin
    // length of message
    s := '$' + MidStr(Msg, 7, 2) + MidStr(Msg, 5, 2);
    l := StrToInt(s);
    // TOR (type of record) or message type
    s := '$' + MidStr(Msg, 19, 2) + MidStr(Msg, 17, 2);
    TypeOfRecord := StrToInt(s);
    //
    case TypeOfRecord of
     TOR_VERSION_DECODER:
       begin
        result := ParseRecordTypeVersionDecoder(MidStr(Msg, 21, length(Msg) - 21 - 1));
       end;
    end;
   end;
end;



function TMyLapsP3MessageParser.GetDecoderSearchPhrase: string;
begin
 // 8E.00.1900.A539.0000.0300.0100.0200.0300.0400.0800.0A00.0C00.8F
 result := '8E001900A53900000300010002000300040008000A000C008F';
end;




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


function TMyLapsP3MessageParser.GetSessionPhrase(DecoderId: string): string;
var crc: word;
    s: string;
begin
  //    VER LEN  CRC FLOR TOR  FOR
  // 8E.00.2B00.9134.0000.1500.01.04.01000000.02.04.3271F455.0300.0400.81.04.9B0F0200.85.08.0100000000000000.8F
  //result := '8E001D00000000001500010002043271F4550300040081049B0F02008F';
  result := '8E001D00000000001500010002043271F45503000400'; //81049B0F02008F';
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



{$IFOPT R+}
  {$DEFINE RANGEON}
  {$R-}
{$ELSE}
  {$UNDEF RANGEON}
{$ENDIF}
procedure TMyLapsP3MessageParser.initTable;
var i, j: integer;
    crc: word;
begin
 for i:=0 to 255 do
  begin
   crc := i shl 8;
   for j:=0 to 7 do
    begin
      if crc and $8000 > 0 then crc := (crc shl 1) xor $1021
        else crc := (crc shl 1) xor 0;
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






{ TDecoderListenerBase }

constructor TDecoderListenerBase.Create(DecoderData: TDecoderData);
begin
 inherited Create(true);
 FDecoderData := DecoderData;
 if FDecoderData.DecoderType = 'ChipX Decoder' then FDecoderType := dcChipX
  else if FDecoderData.DecoderType = 'ProChip Smart Decoder' then FDecoderType := dcProChipSmart
    else FDecoderType := dcUnknown;
end;



destructor TDecoderListenerBase.Destroy;
begin
  inherited;
end;






{ TMyLapsP3Listener }

constructor TMyLapsP3Listener.Create(DecoderData: TDecoderData; ServerPort: word);
begin
 inherited Create(DecoderData);
 FTcpClient := TIdTCPClient.Create(nil);
 FTcpClient.ConnectTimeout := 1000;
 FTcpClient.ReadTimeout := 1000;
 FServerPort := ServerPort;
 FListBoxRawData := nil;
 FQueryServerQueue := TStringList.Create;
 FCriticalSection := TCriticalSection.Create;
end;



destructor TMyLapsP3Listener.Destroy;
begin
 FreeAndNil(FTcpClient);
 FreeAndNil(FQueryServerQueue);
 FreeAndNil(FCriticalSection);
 inherited Destroy;
end;



procedure TMyLapsP3Listener.Execute;
var i, j, k, l: integer;
    InByte: Byte;
    ExpectedMsgLengthBytes: integer;
    s: string;
    ABuffer: TIdBytes;
    sdk_handle: mdp_sdk_handle_t;
    app_handle: Tmta_handle_t;
    event_handle: Tmta_eventdata_handle_t;
    appname: AnsiString;
    ip, user, pw: AnsiString;
    app: Pavailableappliance_t;
    utcfromtime: Tmdp_time_t;
    Start: TDateTime;
    id: cardinal;
    LastContact: TDateTime;
begin
   repeat
    try
    if FTcpClient.Connected then
     begin
      try
        InByte := FTcpClient.IOHandler.ReadByte;
        FNewData := FNewData + IntToHex(InByte, 2);
        //if assigned(FListBoxRawData) then Synchronize(PostNewData);    // just for debug purposes
        i := PosEx('8E', FNewData);
        if i > 0 then
          begin
           k := i;
           repeat
            j := PosEx('8F', FNewData, k);
            if (j-i) mod 2 = 1 then k := j + 1;
           until (j = 0) or ((j-i) mod 2 = 0) ;
           if (j > 0) and ((j-i) mod 2 = 0) then
            begin
              FMessage := MidStr(FNewData, i, j-i+2);
              FNewData := MidStr(FNewData, j+2, length(FNewData)-j-2+1);
              Synchronize(PostMessage);
            end;
          end;
        // write to decoder (or relay)
        {if FCriticalSection.TryEnter} FCriticalSection.Enter; {then}
         try
           if FQueryServerQueue.Count > 0 then
            begin
             for i:=0 to FQueryServerQueue.Count - 1 do
              begin
               // string to TIdBytes
               l := length(FQueryServerQueue[i]) div 2;
               setlength(ABuffer, l);
               for j:=0 to l-1 do
                begin
                 s := MidStr(FQueryServerQueue[i], 2*j+1, 2);
                 ABuffer[j] := StrToInt('$'+s);
                end;
               // send TIdBytes
               if FQueryServerQueue[i] = FGetRtcPhrase then FRtcQuerySendTime := Now;
               FTcpClient.IOHandler.Write(ABuffer, l);
              end;
             FQueryServerQueue.Clear;
            end;
         finally
           FCriticalSection.Leave;
         end;
      except

      end;
     end
     else
     FTcpClient.Connect(FDecoderData.Address, FServerPort);
    except

    end;
   until Terminated;
   if FTcpClient.Connected then FTcpClient.Disconnect;
end;



procedure TMyLapsP3Listener.SendQuery(Msg: string);
begin
 FCriticalSection.Enter;
 try
  FQueryServerQueue.Add(Msg);
 finally
  FCriticalSection.Leave;
 end;
end;



procedure TMyLapsP3Listener.SetMyLapsParser(const Value: TMyLapsP3MessageParser);
begin
 FMyLapsParser := Value;
 FGetRtcPhrase := FMyLapsParser.GetRtcPhrase;
end;



procedure TMyLapsP3Listener.PostMessage;
begin
 if assigned(FMyLapsParser) and (not Terminated) then
  begin
   FMyLapsParser.AddMessage(FMessage, FDecoderData);
   FMessage := '';
  end;
end;



procedure TMyLapsP3Listener.PostNewData;
begin
 if assigned(FListBoxRawData) then FListBoxRawData.Items.Add(FNewData);
end;






{ TMyLapsDecoderSearcher }

constructor TMyLapsDecoderSearcher.Create;
begin
 inherited;
 setlength(FDecoderInfos, 0);
 FOnDecoderFound := nil;
 FParser := TMyLapsP3MessageParser.Create;
 FUdpServer := TIdUDPServer.Create(nil);
 FUdpServer.ReuseSocket := rsTrue;
 FUdpServer.DefaultPort := 5303;
 FUdpServer.BroadcastEnabled := true;
 FUdpServer.OnUDPRead := OnUdpRead;
 FUdpServer.Active := true;
end;



destructor TMyLapsDecoderSearcher.Destroy;
begin
 if assigned(FParser) then FreeAndNil(FParser);
 if assigned(FUdpServer) then
  begin
   FUdpServer.OnUDPRead := nil;
   FUdpServer.Active := false;
   FUdpServer.Bindings.Clear;
   FreeAndNil(FUdpServer);
  end;
 inherited;
end;



procedure TMyLapsDecoderSearcher.OnUdpRead(AThread: TIdUDPListenerThread; const AData: TIdBytes; ABinding: TIdSocketHandle);
var i, j: integer;
    IsKnown: boolean;
    Msg: string;
begin
 IsKnown := false;
 for i:=0 to length(FDecoderInfos) - 1 do
   if FDecoderInfos[i].IpAddress = ABinding.PeerIP then IsKnown := true;
 if not IsKnown then
  begin
    i := length(FDecoderInfos);
    setlength(FDecoderInfos, i+1);
    FDecoderInfos[i].IpAddress := ABinding.PeerIP;
    Msg := '';
    for j:=0 to length(AData) - 1 do Msg := Msg + IntToHex(AData[j], 2);
    FDecoderInfos[i].DecoderVersion := FParser.AddMessageDecoderSearch(Msg);
  end;
 if assigned(FOnDecoderFound) and not IsKnown then FOnDecoderFound(self);
end;



procedure TMyLapsDecoderSearcher.Update;
var i: integer;
    sReq: string;
    s: string;
    ReqBuf: TIdBytes;
    NetworkAdapters: TNetworkAdapters;
    AdapterIp, SubnetMask: cardinal;
    BroadcastIp: cardinal;
begin
 // init
 setlength(FDecoderInfos, 0);
 // fetch search phrase for decoder
 sReq := FParser.GetDecoderSearchPhrase;
 setlength(ReqBuf, trunc(length(sReq)/2));
 for i:=0 to length(ReqBuf) - 1 do
  begin
   s := MidStr(sReq, 2*i+1, 2);
   ReqBuf[i] := StrToInt('$' + s);
  end;
 // send "limited broadcast"
 FUdpServer.SendBuffer('255.255.255.255', 5403, ReqBuf);
 // loop all network interfaces and send "directed broadcast"
 if GetNetworkAdapters(NetworkAdapters) then
  for i:=0 to length(NetworkAdapters) - 1 do
   begin
    AdapterIp := IpStrToInt(NetworkAdapters[i].IP);
    SubnetMask := IpStrToInt(NetworkAdapters[i].SubnetMask);
    BroadcastIp := (AdapterIp and SubnetMask) or (not SubnetMask);
    if AdapterIp > 0 then FUdpServer.SendBuffer(IntToIpStr(BroadcastIp), 5403, ReqBuf);
   end;
end;



procedure TMyLapsDecoderSearcher.UpdateX2(IpAddress, Username, Password: AnsiString; BeepOnPassing: boolean; TimeHorizon: TDateTime);
var i, j, k, oldlength: integer;
    sdk_handle: mdp_sdk_handle_t;
    app_handle: Tmta_handle_t;
    event_handle: Tmta_eventdata_handle_t;
    appname: AnsiString;
    connected: boolean;
    app: Pavailableappliance_t;
    loop: Ploop_t;
    IsKnown: boolean;
    name: AnsiString;
    bytes: array[0..15] of byte;
begin
 //
 oldlength := length(FDecoderInfos);
 appname := 'Spins';
 try
  sdk_handle := mdp_sdk_alloc(PChar(appname), self);
  app_handle := mta_handle_alloc(sdk_handle, self);
  event_handle := mta_eventdata_handle_alloc_live(app_handle, self);

	mta_objectdata_subscribe(app_handle, mtaLoop);

  if mta_connect(app_handle, PChar(IpAddress), PChar(Username), PChar(Password), true) then
   begin
    // process message loop to query decoder data
    for i:=0 to 50 do
     begin
      mdp_sdk_messagequeue_process(sdk_handle, true, 100000);
     end;
    // try to get data
    loop := mta_loop_get_head(app_handle);
    while loop <> nil do
      begin
       // insert in list
       IsKnown := false;
       j := 0;
       while (j < length(FDecoderInfos)) and (not IsKnown) do
        begin
          if FDecoderInfos[j].DecoderVersion.DecoderId = IntToStr(loop.twowayid) then IsKnown := true;
          inc(j);
        end;
       if not IsKnown then
        begin
          setlength(FDecoderInfos, length(FDecoderInfos) + 1);
          FDecoderInfos[high(FDecoderInfos)].DecoderVersion.DecoderType := 'X2 decoder';
          FDecoderInfos[high(FDecoderInfos)].IpAddress := IpAddress;
          FDecoderInfos[high(FDecoderInfos)].Username := Username;
          FDecoderInfos[high(FDecoderInfos)].Password := Password;
          FDecoderInfos[high(FDecoderInfos)].DecoderVersion.DecoderId := IntToStr(loop.twowayid);
          FDecoderInfos[high(FDecoderInfos)].BeepOnPassing := BeepOnPassing;
          FDecoderInfos[high(FDecoderInfos)].TimeHorizon := TimeHorizon;
        end;
       loop := mta_loop_get_next(app_handle);
      end;
   //end;
   end
   else MessageDlg('Connection failed!', mtError, [mbOk], 0);

   if length(FDecoderInfos) > oldlength then
    if assigned(FOnDecoderFound) then FOnDecoderFound(self);

 finally
  mta_disconnect(app_handle);
  mta_objectdata_unsubscribe(app_handle, mtaLoop);
  mta_eventdata_handle_dealloc(app_handle, event_handle);
  mta_handle_dealloc(sdk_handle, app_handle);
  mdp_sdk_dealloc(sdk_handle);
 end;

end;



procedure TMyLapsDecoderSearcher.Clear;
begin
 setlength(FDecoderInfos, 0);
end;



function TMyLapsDecoderSearcher.GetAddress(i: integer): string;
begin
 if (i >= 0) and (i < length(FDecoderInfos)) then result := FDecoderInfos[i].IpAddress else result := '';
end;


function TMyLapsDecoderSearcher.GetData(i: integer): TMyLapsP3VersionDecoder;
begin
 if (i >= 0) and (i < length(FDecoderInfos)) then result := FDecoderInfos[i].DecoderVersion;
end;


function TMyLapsDecoderSearcher.GetInfo(i: integer): TDecoderInfo;
begin
 if (i >= 0) and (i < length(FDecoderInfos)) then
  begin
    result.IpAddress := FDecoderInfos[i].IpAddress;
    result.Username := FDecoderInfos[i].Username;
    result.Password := FDecoderInfos[i].Password;
    result.DecoderVersion := FDecoderInfos[i].DecoderVersion;
    result.BeepOnPassing := FDecoderInfos[i].BeepOnPassing;
    result.TimeHorizon := FDecoderInfos[i].TimeHorizon;
  end;
end;



function TMyLapsDecoderSearcher.GetCount: integer;
begin
 result := length(FDecoderInfos);
end;






{ TTransponderMultiplexer }

constructor TTransponderMultiplexer.Create;
begin
 setlength(FTransponderReferences, 0);
 FCount := 0;
end;



procedure TTransponderMultiplexer.SetTransponderReference(InCode, OutCode: string);
var i: integer;
    IsFound: boolean;
begin
 i := 0;
 IsFound := false;
 while (i < FCount) and (not IsFound) do
  begin
   if FTransponderReferences[i].InCode = InCode then
    begin
     IsFound := true;
     FTransponderReferences[i].OutCode := OutCode;
    end;
   inc(i);
  end;
 if not IsFound then
  begin
   inc(FCount);
   setlength(FTransponderReferences, FCount);
   FTransponderReferences[FCount-1].InCode := InCode;
   FTransponderReferences[FCount-1].OutCode := OutCode;
  end;
end;



procedure TTransponderMultiplexer.DeleteTransponderReference(InCode: string);
var i, j: integer;
    IsFound: boolean;
begin
 i := 0; j := 0;
 IsFound := false;
 while (i < FCount) and (not IsFound) do
  begin
   if FTransponderReferences[i].InCode = InCode then
    begin
     IsFound := true;
     j := i;
    end;
   inc(i);
  end;
 if IsFound then
  begin
   for i:=j to FCount-2 do FTransponderReferences[i] := FTransponderReferences[i+1];
   dec(FCount);
   setlength(FTransponderReferences, FCount);
  end;
end;



function TTransponderMultiplexer.GetOutCode(InCode: string): string;
var i: integer;
    IsFound: boolean;
begin
 result := InCode;
 IsFound := false;
 i := 0;
 while (not IsFound) and (i < FCount) do
  begin
   if FTransponderReferences[i].InCode = InCode then
    begin
     result := FTransponderReferences[i].OutCode;
     IsFound := true;
    end;
   inc(i);
  end;
end;



function TTransponderMultiplexer.GetTransponderReference(index: integer): TTransponderReference;
begin
 if (index >= 0) and (index < FCount) then result := FTransponderReferences[index];
end;






{ TMandigoDecoderListener }

constructor TMandigoDecoderListener.Create(DecoderData: TDecoderData; ComPort: word);
begin
 inherited Create(DecoderData);
 FDecoderData := DecoderData;
 FComPort := TApdComPort.Create(nil);
 FComPort.ComNumber := ComPort;
 FComPort.Baud := 38400;
 FComPort.DataBits := 8;
 FComPort.StopBits := 1;
 FComPort.Parity := pNone;
 FComPort.HWFlowOptions := [];
 FComPort.PromptForPort := false;
 FQueryServerQueue := TStringList.Create;
 FCriticalSection := TCriticalSection.Create;
end;



destructor TMandigoDecoderListener.Destroy;
begin
  if assigned(FComPort) then FreeAndNil(FComPort);
  FreeAndNil(FQueryServerQueue);
  FreeAndNil(FCriticalSection);
  inherited;
end;



procedure TMandigoDecoderListener.Execute;
var i, j: integer;
    res: string;
    IsDecoderBootComplete: boolean;
begin
 // wait for decoder to be available and responding once
 IsDecoderBootComplete := false;
 repeat
  if FComPort.Open then
   begin
    FComPort.PutChar('z');    // fetch RTC
    res := ReadLine(1000);
    if length(res) = 10 then IsDecoderBootComplete := true;
   end
   else FComPort.Open := true;
 until Terminated or IsDecoderBootComplete;

 // enter infinite loop
 repeat
  try
  if FComPort.Open then
   begin
    try
     FComPort.PutChar('j');    // fetch "next runner"
     res := ReadLine(1000);
     if length(res) = 34 then
       begin
         FMessage := res;
         Synchronize(PostMessage);
       end;

     // write to decoder (or relay)
     {if FCriticalSection.TryEnter} FCriticalSection.Enter; {then}
       try
         if FQueryServerQueue.Count > 0 then
          begin
           for i:=0 to FQueryServerQueue.Count - 1 do
            begin
             res := FQueryServerQueue[i];
             for j:=1 to length(res) do FComPort.PutChar(AnsiChar(res[j]));
             if FQueryServerQueue[i] = FGetRtcPhrase then FRtcQuerySendTime := Now;
             res := ReadLine(1000);
             FMessage := res;
             Synchronize(PostMessage);
            end;
           FQueryServerQueue.Clear;
          end;
       finally
         FCriticalSection.Leave;
       end;
    except

    end;
   end
   else FComPort.Open := true;
  except

  end;
 until Terminated;
 //
 if FComPort.Open then FComPort.Open := false;
end;



procedure TMandigoDecoderListener.PostMessage;
begin
 if assigned(FMandigoMessageParser) and (not Terminated) then
  begin
   FMandigoMessageParser.AddMessage(FMessage, FDecoderData);
   FMessage := '';
  end;
end;



procedure TMandigoDecoderListener.PostNewData;
begin
 if assigned(FListBoxRawData) then FListBoxRawData.Items.Add(FNewData);
end;



function TMandigoDecoderListener.ReadLine(TimeOutMs: integer): string;
// tries to read a string from decoder for a defined duration
var StartTime: TDateTime;
    EndOfLineDetected: boolean;
begin
 StartTime := Now;
 result := '';
 repeat
  if FComPort.CharReady then result := result + FComPort.GetChar;
  EndOfLineDetected := false;
  if length(result) > 3 then
   if result[high(result)] = #0 then
    if result[high(result)-1] = #10 then
     if result[high(result)-2] = #13 then EndOfLineDetected := true;
 until EndOfLineDetected or (Now-StartTime > TimeOutMs/(24.0*3600*1000)) or Terminated;
 if EndOfLineDetected then result := MidStr(result, 1, length(result)-3) else result := '';
end;



procedure TMandigoDecoderListener.SendQuery(Msg: string);
begin
 FCriticalSection.Enter;
 try
  FQueryServerQueue.Add(Msg);
 finally
  FCriticalSection.Leave;
 end;
end;



procedure TMandigoDecoderListener.SetMandigoParser(const Value: TMandigoMessageParser);
begin
 FMandigoMessageParser := Value;
 FMandigoMessageParser.DecoderId := FDecoderData.DecoderId;
 FGetRtcPhrase := Value.GetRtcPhrase;
end;




{ TMandigoMessageParser }

constructor TMandigoMessageParser.Create;
begin
 inherited;
 FOnPassing := nil;
 FOnRtc := nil;
 FTimeDeltaDecoderPc := TTimeSpan.Zero;
end;



function TMandigoMessageParser.GetRtcPhrase: string;
begin
 result := 'z';
end;



procedure TMandigoMessageParser.AddMessage(Msg: string; DecoderData: TDecoderData);
var l: integer;
    s: string;
    P3Passing: TMyLapsP3Passing;
    P3Rtc: TMyLapsP3RealTimeClock;
    msec, frac: Cardinal;
    Diff: TTimeSpan;
begin
 try
  if length(Msg) = 34 then
   begin
    if MidStr(Msg, 1, 6) <> '------' then
     begin
      P3Passing := ParseRecordTypePassing(Msg);
      P3Passing.DecoderId := DecoderData.DecoderId;
      if not DecoderData.UseSoftwareSynch then
        begin
         // set FTimeDeltaDecoderPC upon FIRST CONTACT (make sure only ONE INSTANCE of this class is used in main!)
         if FTimeDeltaDecoderPc.Ticks = 0 then
          begin
           FTimeDeltaDecoderPc := TTimeSpan.Subtract(P3Passing.PassingTime, Now);
           msec := abs(FTimeDeltaDecoderPc.Milliseconds);
           frac := msec mod 100;
           Diff := TTimeSpan.FromMilliseconds(frac);
           FTimeDeltaDecoderPc := FTimeDeltaDecoderPc + Diff
          end;
         // apply correction
         P3Passing.PassingTime := P3Passing.PassingTime - FTimeDeltaDecoderPc;
        end
        else begin
         P3Passing.PassingTime := P3Passing.PassingTime - DecoderData.DeltaTimeWithPc;
        end;
      if assigned(FOnPassing) then FOnPassing(P3Passing);
     end;
   end
   else if length(Msg) = 10 then
     begin
      P3Rtc := ParseRecordTypeGetRtc(Msg);
      P3Rtc.DecoderId := DecoderData.DecoderId;
      if assigned(FOnRtc) then FOnRtc(P3Rtc);
     end;
 except
  s := '';
 end;
end;



function TMandigoMessageParser.ParseRecordTypePassing(Msg: string): TMyLapsP3Passing;
var s: string;
    fs: TFormatSettings;
    NowToday: TDateTime;
    year, month, day: word;
    hour, minute, sec, msec: word;
begin
 try
   // passing nr
   s := MidStr(Msg, 1, 6);
   result.PassingNumber := StrToInt(s);
   // passing time
   NowToday := Now;
   DecodeDate(NowToday, year, month, day);
   s := MidStr(Msg, 8, 8);
   hour := StrToInt(MidStr(s, 1, 2));
   minute := StrToInt(MidStr(s, 4, 2));
   sec := StrToInt(MidStr(s, 7, 2));
   s := MidStr(Msg, 17, 1) + '00';
   msec := StrToInt(s);
   result.PassingTime := EncodeDateTime(year, month, day, hour, minute, sec, msec);
   // transponder ID
   result.TransponderId := MidStr(Msg, 19, 16);
   //
   result.SignalStrength := 0;
   result.Hits := 0;
   result.Sport := 0;
   result.DecoderId := FDecoderId;
   result.LowBattWarning := false;
 except
  result.PassingTime := 0.0;
 end;
end;



function TMandigoMessageParser.ParseRecordTypeGetRtc(Msg: string): TMyLapsP3RealTimeClock;
var s: string;
    fs: TFormatSettings;
begin
 try
   s := MidStr(Msg, 1, 8);
   result.CurrentDecoderTime := Date;
   fs.TimeSeparator := ':';
   fs.ShortTimeFormat := 'hh:nn:ss';
   result.CurrentDecoderTime := result.CurrentDecoderTime + Sign(result.CurrentDecoderTime)*StrToTime(s, fs);
   s := MidStr(Msg, 10, 1) + '00';
   result.CurrentDecoderTime := result.CurrentDecoderTime + Sign(result.CurrentDecoderTime)*StrToInt(s)/(24.0*3600.0*1000.0);
 except
   result.CurrentDecoderTime := 0.0;
 end;
end;






{ TMyLapsX2EventManager }

constructor TMyLapsX2EventManager.Create;
begin
 inherited;
 FTimeDeltaDecoderPc := TTimeSpan.Zero;
 FIsSynched := false;
 setlength(FLastStatus, 0);
 setlength(FBeepingOnPassingDecoderIds, 0);
end;



function TMyLapsX2EventManager.IsInBeepList(DecoderId: integer): boolean;
var i: integer;
begin
 result := false;
 i := 0;
 while (i < length(FBeepingOnPassingDecoderIds)) and (not result) do
  begin
   if FBeepingOnPassingDecoderIds[i] = DecoderId then result := true;
   inc(i);
  end;
end;



procedure TMyLapsX2EventManager.PlayShortBeep;
var hFind, hRes: THandle;
    Sound: PWideChar;
begin
 hFind := FindResource(HInstance, 'beep_short', RT_RCDATA);
 if hFind <> 0 then
  begin
   hRes := LoadResource(HInstance, hFind);
   if hRes <> 0 then
    begin
     Sound := LockResource(hRes);
     if assigned(Sound) then PlaySound(Sound, hRes, SND_ASYNC or SND_MEMORY);
     UnlockResource(hRes);
    end;
   FreeResource(hFind);
  end;
end;



procedure TMyLapsX2EventManager.AddPassing(Passing: TMyLapsP3Passing; CheckResend: boolean);
var IsNewPassing: boolean;
begin
 // set FTimeDeltaDecoderPC upon FIRST CONTACT (make sure only ONE INSTANCE of this class is used in main!)
 if not FIsSynched then
  begin
   FTimeDeltaDecoderPc := TTimeSpan.Subtract(Passing.PassingTime, Now);
   FIsSynched := true;
  end;
 // apply correction
 Passing.PassingTime := Passing.PassingTime - FTimeDeltaDecoderPc;
 // evaluate resending
 if {FResending} CheckResend then
  begin
   IsNewPassing := not FRaceBase.PassingStored(Passing.PassingTime, 5000, Passing.TransponderId);
   if IsNewPassing then FResending := false;
  end
  else IsNewPassing := true;
 // fire event
 if assigned(FOnPassing) and IsNewPassing then FOnPassing(Passing);
 // beep
 if IsInBeepList(StrToInt(Passing.DecoderId)) and IsNewPassing then PlayShortBeep;
end;



procedure TMyLapsX2EventManager.AddStatus(Status: TMyLapsP3Status);
var i, j: integer;
    IsFound: boolean;
begin
 IsFound := false;
 i := 0; j := 0;
 while (i < length(FLastStatus)) and (not IsFound) do
  begin
   if FLastStatus[i].DecoderId = Status.DecoderId then
    begin
      FLastStatus[i].Noise := Status.Noise;
      if Status.Temperature > 0.0 then FLastStatus[i].Temperature := Status.Temperature;
      j := i;
      IsFound := true;
    end;
   inc(i);
  end;
 if not IsFound then
  begin
   j := length(FLastStatus);
   setlength(FLastStatus, j+1);
   FLastStatus[j].Noise := Status.Noise;
   FLastStatus[j].Temperature := Status.Temperature;
   FLastStatus[j].DecoderId := Status.DecoderId;
  end;
 if assigned(FOnStatus) then
   FOnStatus(FLastStatus[j]);
end;



procedure TMyLapsX2EventManager.BeepOnPassing(DecoderId: string; DoBeep: boolean);
var i, t, k: integer;
    IsFound: boolean;
    New: TIntegerArray;
begin
 IsFound := false;
 i := 0;
 t := StrToInt(DecoderId);
 while (i < length(FBeepingOnPassingDecoderIds)) and (not IsFound) do
  begin
   if FBeepingOnPassingDecoderIds[i] = t then IsFound := true;
   inc(i);
  end;
 if (not IsFound) and DoBeep then
  begin
    setlength(FBeepingOnPassingDecoderIds, length(FBeepingOnPassingDecoderIds) + 1);
    FBeepingOnPassingDecoderIds[high(FBeepingOnPassingDecoderIds)] := t;
  end;
 if IsFound and (not DoBeep) then
  begin
   setlength(New, length(FBeepingOnPassingDecoderIds) - 1);
   i := 0;
   k := 0;
   while i < length(New) do
    begin
     if FBeepingOnPassingDecoderIds[k] <> t then
      begin
       New[i] := FBeepingOnPassingDecoderIds[k];
       inc(i);
      end;
     inc(k);
    end;
   FBeepingOnPassingDecoderIds := New;
  end;

end;









{ TRaceResultListener }

constructor TRaceResultListener.Create(DecoderData: TDecoderData; ServerPort: word);
begin
 inherited Create(DecoderData);
 FTcpClient := TIdTCPClient.Create(nil);
 FTcpClient.ConnectTimeout := 1000;
 FTcpClient.ReadTimeout := 1000;
 FServerPort := ServerPort;
 FListBoxRawData := nil;
 FQueryServerQueue := TStringList.Create;
 FCriticalSection := TCriticalSection.Create;
end;



destructor TRaceResultListener.Destroy;
begin
 FreeAndNil(FTcpClient);
 FreeAndNil(FQueryServerQueue);
 FreeAndNil(FCriticalSection);
 inherited Destroy;
end;



procedure TRaceResultListener.Execute;
var i, j, k, l: integer;
    InByte: Byte;
    ExpectedMsgLengthBytes: integer;
    s: string;
    ABuffer: TIdBytes;
    ExpectedNextPassingNumber: cardinal;
    AvailablePassingsCount: cardinal;
begin
 ExpectedNextPassingNumber := 0;
 repeat
   try
    if FTcpClient.Connected then
     begin
      try
        // query decoder for new passings
        FTcpClient.IOHandler.WriteLnRFC('PASSINGS');
        s := FTcpClient.IOHandler.ReadLn;
        j := PosEx('PASSINGS;', s);
        if j > 0 then
         begin
          try
           s := MidStr(s, j+9, length(s) - (j+9));
           AvailablePassingsCount := StrToUInt(s);
           if AvailablePassingsCount > ExpectedNextPassingNumber then
            begin
             FTcpClient.IOHandler.WriteLnRFC(IntToStr(ExpectedNextPassingNumber));
             FMessage := 'Passing&' + FTcpClient.IOHandler.ReadLn;
             PostMessage;
            end;
          except
           FTcpClient.Disconnect;
          end;
         end
         else FTcpClient.Disconnect;
        // write to decoder (or relay)
        {if FCriticalSection.TryEnter} FCriticalSection.Enter; {then}
        { try
           if FQueryServerQueue.Count > 0 then
            begin
             for i:=0 to FQueryServerQueue.Count - 1 do
              begin
               // string to TIdBytes
               l := length(FQueryServerQueue[i]) div 2;
               setlength(ABuffer, l);
               for j:=0 to l-1 do
                begin
                 s := MidStr(FQueryServerQueue[i], 2*j+1, 2);
                 ABuffer[j] := StrToInt('$'+s);
                end;
               // send TIdBytes
               if FQueryServerQueue[i] = FGetRtcPhrase then FRtcQuerySendTime := Now;
               FTcpClient.IOHandler.Write(ABuffer, l);
              end;
             FQueryServerQueue.Clear;
            end;
         finally
           FCriticalSection.Leave;
         end; }
      except

      end;
     end
     else begin
      FTcpClient.Connect(FDecoderData.Address, FServerPort);
      if FTcpClient.Connected then
       begin
        FTcpClient.IOHandler.WriteLnRFC('SETPROTOCOL;2.0');
        s := FTcpClient.IOHandler.ReadLn;
        if s = 'SETPROTOCOL;2.0' then
         begin
          FTcpClient.IOHandler.WriteLnRFC('STARTOPERATION');
          s := FTcpClient.IOHandler.ReadLn;
          if PosEx('STARTOPERATION;OK;', s) > 0 then
           begin

           end
           else FTcpClient.Disconnect;
         end
         else FTcpClient.Disconnect;
       end;
     end;
   except

   end;
 until Terminated;
 if FTcpClient.Connected then FTcpClient.Disconnect;
end;



procedure TRaceResultListener.PostMessage;
begin
 if assigned(FRaceResultsMessageParser) and (not Terminated) then
  begin
   FRaceResultsMessageParser.AddMessage(FMessage, FDecoderData);
   FMessage := '';
  end;
end;



procedure TRaceResultListener.PostNewData;
begin
 //
end;



procedure TRaceResultListener.SendQuery(Msg: string);
begin

end;



{ TRaceResultsMessageParser }

constructor TRaceResultsMessageParser.Create;
begin
 inherited;
 FOnStatus := nil;
 FOnPassing := nil;
 FOnRtc := nil;
 //FOnSession := nil;
 FTimeDeltaDecoderPc := TTimeSpan.Zero;
end;



procedure TRaceResultsMessageParser.AddMessage(Msg: string; DecoderData: TDecoderData);
var i, j: integer;
    k: byte;
    MessageType, Token, sDate, sTime: string;
    Passing: TMyLapsP3Passing;
    value: double;
begin
 i := PosEx('&', Msg);
 if i > 0 then
  begin
   MessageType := MidStr(Msg, 1, i-1);
   if (MessageType = 'Passing') and assigned(FOnPassing) then
    begin
     // PassingNo (race-results)
     j := i+1;
     i := PosEx(';', Msg, i+1);
     Token := MidStr(Msg, j, i-j);
     Passing.PassingNumber := StrToInt(Token);
     // Bib/TranspCode (race-results)
     j := i+1;
     i := PosEx(';', Msg, i+1);
     Token := MidStr(Msg, j, i-j);
     Passing.TransponderId := Token;
     // Date (race-results)
     j := i+1;
     i := PosEx(';', Msg, i+1);
     Token := MidStr(Msg, j, i-j);
     sDate := Token;
     // Time (race-results)
     j := i+1;
     i := PosEx(';', Msg, i+1);
     Token := MidStr(Msg, j, i-j);
     sTime := Token;
     // EventId (race-results)
     j := i+1;
     i := PosEx(';', Msg, i+1);
     // Hits (race-results)
     j := i+1;
     i := PosEx(';', Msg, i+1);
     Token := MidStr(Msg, j, i-j);
     Passing.Hits := StrToUInt(Token);
     // MaxRSSI (race-results)
     j := i+1;
     i := PosEx(';', Msg, i+1);
     Token := MidStr(Msg, j, i-j);
     k := StrToUint(Token);
     k := (k shr 4) and 7;
     Passing.SignalStrength := -90 + 4*k; // 2.4GHz strength in dBm; range: -90..-58 with -58 being the strongest signal (good)
     // InternalData (race-results)
     j := i+1;
     i := PosEx(';', Msg, i+1);
     // IsActive (race-results) (1 iff this passing is from active transponder)
     j := i+1;
     i := PosEx(';', Msg, i+1);
     // Channel (race-results)
     j := i+1;
     i := PosEx(';', Msg, i+1);
     // LoopId (race-results)
     j := i+1;
     i := PosEx(';', Msg, i+1);
     Token := MidStr(Msg, j, i-j);
     Passing.DecoderId := Token;
     // LoopOnly (race-results) (1 iff this detection was generated in store mode)
     j := i+1;
     i := PosEx(';', Msg, i+1);
     // WakeupCounter (race-results)
     j := i+1;
     i := PosEx(';', Msg, i+1);
     // Battery (race-results)
     j := i+1;
     i := PosEx(';', Msg, i+1);
     Token := MidStr(Msg, j, i-j);
     sDate := Token;
     //
     FOnPassing(Passing);
    end;
  end;
end;



function MyLapsX2TimeToDelphiTime(X2Time: Tmdp_time_t): TDateTime;
var t: extended;
    p: Int64;
    fulldays, fracdays: Int64;
    fromDateTime, toDateTime: TDateTime;
begin
 fromDateTime := EncodeDateTime(1970, 1, 1, 0, 0, 0, 0);     // MyLapsX2 datetime origin
 toDateTime := EncodeDateTime(1899, 12, 30, 12, 0, 0, 0);    // Delphi datetime origin
 p := Int64(24)*3600*1000000;
 fulldays := X2Time div p;
 fracdays := X2Time mod p;
 t := fulldays + fracdays/p + 14.0/24.0;                     // days since 1.1.1970
 t := t + fromDateTime - toDateTime;                         // add days between 30.12.1899 and 1.1.1970
 result := TDateTime(t);
end;






procedure OnNotifyLoopTrigger(handle: Tmta_eventdata_handle_t;
  nType: TMDP_NOTIFY_TYPE; trigger: Plooptrigger_t; context: pointer); stdcall;
var i: integer;
    Status: TMyLapsP3Status;
    app_handle: Tmta_handle_t;
    loop: Ploop_t;
begin
 if nType <> MDP_NOTIFY_CLEAR then
  begin
   Status.Noise := trigger.strength;
   Status.Temperature := trigger.temperature;
   app_handle := mta_eventdata_get_appliance_handle(handle);
   loop := mta_loop_find(app_handle, trigger.loopid);
   if assigned(loop) then Status.DecoderId := IntToStr(loop.twowayid)
     else Status.DecoderId := '0';
   //
   if assigned(GlobalMyLapsX2EventManager) then
     GlobalMyLapsX2EventManager.AddStatus(Status);
   //
  end;
end;




procedure OnNotifyLoopStatus(handle: Tmta_eventdata_handle_t;
  nType: TMDP_NOTIFY_TYPE; loopstatus: Ploopstatus_t; context: pointer); stdcall;
// gets called every once in a while
var i: integer;
    Status: TMyLapsP3Status;
    p: PByte;
    noise: double;
    app_handle: Tmta_handle_t;
    loop: Ploop_t;
begin
 if nType <> MDP_NOTIFY_CLEAR then
  begin
   Status.Noise := round((loopstatus.noise_receiver[1] / 2.0));   // index 1: TranX noise; unit: -dBm
   app_handle := mta_eventdata_get_appliance_handle(handle);
   loop := mta_loop_find(app_handle, loopstatus.loopid);
   if assigned(loop) then Status.DecoderId := IntToStr(loop.twowayid)
     else Status.DecoderId := '0';
   if assigned(GlobalMyLapsX2EventManager) then
     GlobalMyLapsX2EventManager.AddStatus(Status);
  end;
end;



procedure OnNotifyPassing(handle: Tmta_eventdata_handle_t; nType: TMDP_NOTIFY_TYPE;
  const passingarray: PPTpassing_t; count: cardinal; context: pointer); stdcall;
var i: integer;
    app_handle: Tmta_handle_t;
    Passing: TMyLapsP3Passing;
    mypassing: PTpassing_t;
    transponder: Ptransponder_t;
    loop: Ploop_t;
    p: pointer;
begin
 if (nType = MDP_NOTIFY_INSERT) or (nType = MDP_NOTIFY_SELECT) then
  if count > 0 then
   begin
    app_handle := mta_eventdata_get_appliance_handle(handle);
    for i:=0 to count - 1 do
      begin
        p := passingarray;
        inc(PByte(p), i*4);
        mypassing := PTPassing_t(p^);
        transponder := mta_transponder_find(app_handle, mypassing^.transponderid);
        Passing.PassingNumber := mypassing^.id;
        Passing.TransponderId := IntToStr(transponder.id);
        Passing.PassingTime := MyLapsX2TimeToDelphiTime(mypassing^.utctime);
        Passing.SignalStrength := mypassing^.strength;
        Passing.Hits := mypassing^.hits;
        loop := mta_loop_find(app_handle, mypassing^.loopid);
        if assigned(loop) then Passing.DecoderId := IntToStr(loop.twowayid)
          else Passing.DecoderId := '0';
        Passing.LowBattWarning := (mypassing^.flags and (1 shl ord((tlfLowBattery))) = (1 shl ord(tlfLowBattery)));
        //
        if assigned(GlobalMyLapsX2EventManager) then
          GlobalMyLapsX2EventManager.AddPassing(Passing, nType = MDP_NOTIFY_SELECT);
      end;
   end;
end;






{ TMyLapsX2Connector }

constructor TMyLapsX2Connector.Create;
begin
 setlength(FX2Connections, 0);
end;



destructor TMyLapsX2Connector.Destroy;
var i: integer;
begin
 for i:=0 to length(FX2Connections) - 1 do
  begin
   // request the data from the MTA (can be called at any time)
   mta_objectdata_unsubscribe(FX2Connections[i].app_handle, mtaLoop);
   mta_objectdata_unsubscribe(FX2Connections[i].app_handle, mtaTransponder);

   // subscribe to events
   mta_eventdata_unsubscribe(FX2Connections[i].event_handle, mtaLoopStatus);
   mta_eventdata_unsubscribe(FX2Connections[i].event_handle, mtaLoopTrigger);
   mta_eventdata_unsubscribe(FX2Connections[i].event_handle, mtaPassing);

   // dealloc
   mta_eventdata_handle_dealloc(FX2Connections[i].app_handle, FX2Connections[i].event_handle);

   mta_disconnect(FX2Connections[i].app_handle);

   mta_handle_dealloc(FX2Connections[i].sdk_handle, FX2Connections[i].app_handle);
   mdp_sdk_dealloc(FX2Connections[i].sdk_handle);
  end;
end;




procedure TMyLapsX2Connector.ProcessMessages;
var i, j, k: integer;
    loop: Ploop_t;
    Status: TMyLapsP3Status;
begin
 for i:=0 to length(FX2Connections) - 1 do
  begin
   // pump message queue
   mdp_sdk_messagequeue_process(FX2Connections[i].sdk_handle, false, 100000);

   // check whether the decoder still responds
   if assigned(GlobalMyLapsX2EventManager) then
    if Now - FX2Connections[i].LastContact > 5.0/(24.0*3600) then
      begin
       loop := mta_loop_get_head(FX2Connections[i].app_handle);
       while assigned(loop) do
        begin
         Status.Temperature := 0.0;
         Status.DecoderId := IntToStr(loop.twowayid);
         GlobalMyLapsX2EventManager.AddStatus(Status);
         FX2Connections[i].LastContact := Now;
         loop := mta_loop_get_next(FX2Connections[i].app_handle);
        end;
    end;
  end;
end;



procedure TMyLapsX2Connector.SubscribeLoop(LoopId, ServerIp: string);
var i, j: integer;
    IsDispatched: boolean;
begin
 i:=0;
 IsDispatched := false;
 while (i < length(FX2Connections)) and (not IsDispatched) do
  begin
   if FX2Connections[i].ServerIp = ServerIp then
    begin
     IsDispatched := false;
     j := 0;
     while (j < length(FX2Connections[i].LoopId)) and (not IsDispatched) do
      begin
       if FX2Connections[i].LoopId[j] = LoopId then IsDispatched := true;
       inc(j);
      end;
     if not IsDispatched then
      begin
       mta_loop_insert(FX2Connections[i].app_handle, StrToInt(LoopId));
       mta_changes_commit(FX2Connections[i].app_handle);
       j := length(FX2Connections[i].LoopId);
       setlength(FX2Connections[i].LoopId, j+1);
       FX2Connections[i].LoopId[j] := LoopId;
      end;
    end;
   inc(i);
  end;
end;



procedure TMyLapsX2Connector.Connect(IpAddress, Username, Password: string; TimeHorizon: TDateTime);
var i: integer;
    appname: AnsiString;
    ip, user, pw: AnsiString;
    app: Pavailableappliance_t;
    utcfromtime: Tmdp_time_t;
    Start: TDateTime;
    id: cardinal;
    IsConnected: boolean;
    //currentX2Time: TDateTime;
begin
  // don't allow multiple connections to one X2 server
  IsConnected := false;
  i := 0;
  while (i < length(FX2Connections)) and (not IsConnected) do
   begin
    if FX2Connections[i].ServerIp = IpAddress then IsConnected := true;
    inc(i);
   end;

  if not IsConnected then
   begin
    //
    i := length(FX2Connections);
    setlength(FX2Connections, i+1);

    appname := ExtractFileName(Application.ExeName);
    FX2Connections[i].LastContact := Now;
    FX2Connections[i].ServerIp := IpAddress;

    FX2Connections[i].sdk_handle := mdp_sdk_alloc(PChar(appname), self);
    FX2Connections[i].app_handle := mta_handle_alloc(FX2Connections[i].sdk_handle, self);

    // request the data from the MTA (can be called at any time)
    mta_objectdata_subscribe(FX2Connections[i].app_handle, mtaLoop);
    mta_objectdata_subscribe(FX2Connections[i].app_handle, mtaTransponder);

    // connect to the MTA
    ip := IpAddress;
    user := Username;
    pw := Password;
    mta_connect(FX2Connections[i].app_handle, PChar(ip), PChar(user), PChar(pw), true);

    if TimeHorizon > 0.0 then
     begin
      //currentX2Time := MyLapsX2TimeToDelphiTime(mta_time_get_utc(FX2Connections[i].app_handle));
      utcfromtime := mta_time_get_utc(FX2Connections[i].app_handle) - Round(TimeHorizon*24.0*3600.0*1000000.0);
      //currentX2Time := MyLapsX2TimeToDelphiTime(utcfromtime);
      FX2Connections[i].event_handle := mta_eventdata_handle_alloc_live_with_resend(FX2Connections[i].app_handle, utcfromtime, self);
      FX2Connections[i].Resending := true;
     end
     else FX2Connections[i].event_handle := mta_eventdata_handle_alloc_live(FX2Connections[i].app_handle, self);

    // register event handler
    mta_notify_loopstatus(FX2Connections[i].event_handle, OnNotifyLoopStatus); // "notify the program when a loop status record is received"
    mta_notify_looptrigger(FX2Connections[i].event_handle, OnNotifyLoopTrigger); // "notify the program when a loop trigger is received"
    mta_notify_passing(FX2Connections[i].event_handle, OnNotifyPassing); // "notify the program when a passing is received"

    // subscribe to events
    mta_eventdata_subscribe(FX2Connections[i].event_handle, mtaLoopStatus, 0, false);
    mta_eventdata_subscribe(FX2Connections[i].event_handle, mtaLoopTrigger, 0, false);
    if TimeHorizon > 0.0
      then mta_eventdata_subscribe(FX2Connections[i].event_handle, mtaPassing, 10000, false)
      else mta_eventdata_subscribe(FX2Connections[i].event_handle, mtaPassing, 0, false);
   end;
end;





{ TMyLapsX2Listener }

constructor TMyLapsX2Listener.Create(DecoderData: TDecoderData);
begin
 inherited Create(DecoderData);
 FDecoderType := dcX2;
end;


procedure TMyLapsX2Listener.Execute;
begin
 //
end;




initialization

  GlobalMyLapsX2EventManager := TMyLapsX2EventManager.Create;




finalization

  if assigned(GlobalMyLapsX2EventManager) then FreeAndNil(GlobalMyLapsX2EventManager);



end.
