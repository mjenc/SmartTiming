unit MylapsSDK;

interface

  {!
   * This file is a part of the Mylaps Development Platform (MDP).
   * Copyright (C) 1999-2014 Track Timing B.V.
   * All rights reserved.
   *
   * This software is confidential and proprietary information of
   * Track Timing B.V. ("Confidential Information"). You shall not
   * disclose such Confidential Information and shall use it only in
   * accordance with the terms of the license agreement you entered
   * into with Track Timing.
   *
   * \file	MylapsSDK.h
   * \brief	This file declares all the public functions that are available for the Mylaps Software Development Kit (SDK).
   * \author	B. Nagels
   * \version	1.0
   * \date	1999-2014
    }
  {* @addtogroup mylapssdkapi
  *  Miscellaneous MTA-SDK functions.
  *  @
   }
  {! Handle to the SDK library, to be used when calling the SDK functions. }
  {! To enforce useful type checking, we make mdp_sdk_handle_t be a pointer to a dummy struct }
  {! This way, mdp_sdk_handle_t's can be assigned, and compared with each other, but not with other types }
  {! Declaring the type to be the typical generic "void *" would lack this type checking }

{! The default port (secure) the appliance listens on. }

const
  External_library='MylapsSDK.dll'; {Setup as you need}

  EDSSERVER_DEFAULT_PORT = 443;
  {! The default port (legacy, insecure, 2.x) the appliance listens on. }
  EDSSERVER_DEFAULT_LEGACY_PORT = 30709;

type
  Pchar  = ^char;

  TDummyPointer = record
    dummy: pointer;
  end;

  mdp_sdk_handle_dummystruct = ^TDummyPointer;
  mdp_sdk_handle_t = ^mdp_sdk_handle_dummystruct;

  Pmta_data_handle_dummystruct = ^Tmta_data_handle_dummystruct;
  Tmta_data_handle_dummystruct = record
    dummy : pointer;
  end;
  Tmta_handle_t = Pmta_data_handle_dummystruct;
  Pmta_handle_t = ^Tmta_handle_t;
  Tmodify_loop_handle_t = ^Tmta_data_handle_dummystruct;

  Tmylaps_sdk_version_t = record
    build : cardinal;
    major : byte;
    minor : byte;
    name : array[0..63] of char;
    status : array[0..31] of char;
  end;
  Pmylaps_sdk_version_t = ^Tmylaps_sdk_version_t;

  TMDP_NOTIFY_TYPE = (MDP_NOTIFY_SELECT, MDP_NOTIFY_INSERT, MDP_NOTIFY_UPDATE,
    MDP_NOTIFY_DELETE, MDP_NOTIFY_CLEAR);
  PMDP_NOTIFY_TYPE = ^TMDP_NOTIFY_TYPE;

  Tavailableappliance_t = packed record
    macaddress: Int64;
    ipaddress: cardinal;
    mode: cardinal;
    buildnumber: cardinal;
    flags: cardinal;
    port: word;
    hostname: array[0..63] of char;
    name: array[0..31] of char;
    releasename: array[0..31] of char;
    systemsetup: array[0..63] of char;
    timezoneid: array[0..63] of char;
    _type: byte;
    padding : array[0..4] of char;
  end;
  Pavailableappliance_t  = ^Tavailableappliance_t;

  size_t = cardinal;

  Tmdp_time_t = Int64;

  Tdevice_t = packed record
    id: Int64;
    systemsetupid: cardinal;
    loopid: cardinal;
    ioterminalid: cardinal;
    rfbasestationid: cardinal;
    reserved1: cardinal;
    reserved2: cardinal;
    _type: cardinal;
    version: cardinal;
    connectionip: cardinal;
    ipaddress: cardinal;
    networkmask: cardinal;
    ntpserver: cardinal;
    flags: cardinal;
    statusflags: cardinal;
    latitude: integer;
    longitude: integer;
    connectionport: word;
    startofsecond: byte;
    syncmethod: byte;
    supportflags: byte;
    name: array[0..31] of char;
    padding: array[0..2] of char;
  end;
  Pdevice_t  = ^Tdevice_t;
  PPdevice_t = ^Pdevice_t;

  TMTAOBJECTDATA = (mtaDevice, mtaIOTerminal, mtaLoop,
    mtaLoopPreset, mtaRFBaseStation, mtaRFBaseStationGroup,
    mtaRFTransponder, mtaTransponder, mtaTransponderGroup,
    mtaBeaconDownloadConfig, mtaSector, mtaSegment,
    mtaSequence, mtaSequenceSegment, mtaTrackSolution,
    mtaTrackSolutionGroup, mtaCompetitor, mtaSystemSetup, mtaSystemSetupPicture);
  PMTAOBJECTDATA = ^TMTAOBJECTDATA;

  TConnectionState = (csInitial,csTryingConnect,csConnectFailed,
      csTryingAuthenticate,csAuthenticationFailed,
      csStreaming,csStoppedStreaming,csAutoReconnect,
      csForceDisconnect,csServerForceDisconnect);

  Pmta_eventdata_handle_dummystruct = ^Tmta_eventdata_handle_dummystruct;
  Tmta_eventdata_handle_dummystruct = record
    dummy : pointer;
  end;
  Tmta_eventdata_handle_t = Pmta_eventdata_handle_dummystruct;
  Pmta_eventdata_handle_t = ^Tmta_eventdata_handle_t;

  TMTAEVENTDATA = (mtaCANMessage,mtaDeviceStatus,mtaIOEvent,
      mtaIOStatus,mtaLoopStatus,mtaLoopTrigger,
      mtaPassing,mtaRFTransponderGPSInfo,mtaTransponderStatus,
      mtaBeaconData,mtaBeaconDownloadStatus,
      mtaBeaconDownloadTrigger,mtaBeaconLog,
      mtaDriverInfo,mtaManualEvent,mtaPassingTrigger,
      mtaTransponderActivity,mtaRFTransponderSpeedInfo);
  PMTAEVENTDATA = ^TMTAEVENTDATA;

  Tpassing_t = packed record
    utctime: Tmdp_time_t;
    timeofday: Tmdp_time_t;
    id: cardinal;
    systemsetupid: cardinal;
    loopid: cardinal;
    rfbasestationid: cardinal;
    transponderid: cardinal;
    transpondershortid: cardinal;
    flags: cardinal;
    userflags: cardinal;
    strength: word;
    hits: word;
    padding: array[0..3] of char;
  end;
  PTpassing_t  = ^Tpassing_t;
  PPTpassing_t = ^PTpassing_t;

  Tpassingtrigger_t = packed record
    utctime: Tmdp_time_t;
    timeofday: Tmdp_time_t;
    id: cardinal;
    systemsetupid: cardinal;
    loopid: cardinal;
    transponderid: cardinal;
    transpondershortid: cardinal;
    flags: cardinal;
    _type: byte;
    padding: array[0..6] of char;
  end;
  Ppassingtrigger_t = ^Tpassingtrigger_t;
  PPpassingtrigger_t = ^Ppassingtrigger_t;

  Ttransponder_t = packed record
    id: cardinal;
    systemsetupid: cardinal;
    shortid: cardinal;
    groupid: cardinal;
    flags: cardinal;
    lastactivitydate: cardinal;
    _label : array[0..15] of char;
 end;
 Ptransponder_t = ^Ttransponder_t;

 Tloop_t = packed record
    id: cardinal;
    systemsetupid: cardinal;
    twowayid: cardinal;
    looppresetid: cardinal;
    order: cardinal;
    flags: cardinal;
    timingflags: cardinal;
    statusflags: cardinal;
    xpos: cardinal;
    ypos: cardinal;
    latitude0: Int32;
    latitude1: Int32;
    longitude0: Int32;
    longitude1: Int32;
    looptrigger: array[0..2] of cardinal;
    squelch: word;
    gatetime: word;
    name: array[0..15] of char;
    description: array[0..51] of char;
    padding: array[0..3] of char;
 end;
 Ploop_t = ^Tloop_t;
 PPloop_t = ^Ploop_t;

 Tloopstatus_t = packed record
    utctime: Tmdp_time_t;
    timeofday: Tmdp_time_t;
    id: cardinal;            // number of status message; gets incremented by one for each message
    systemsetupid: cardinal;
    loopid: cardinal;
    flags: cardinal;
    noise_receiver : array[0..3] of byte;  // average noise level of receiver 0 in dBm (
    padding : array[0..3] of char;
  end;
  Ploopstatus_t = ^Tloopstatus_t;

 Tlooptrigger_t = packed record
    utctime: Tmdp_time_t;
    timeofday: Tmdp_time_t;
    id: cardinal;
    systemsetupid: cardinal;
    triggerid: cardinal;
    loopid: cardinal;
    strength: word;
    temperature: word;
    flags: word;
    padding: array[0..1] of char;
 end;
 Plooptrigger_t = ^Tlooptrigger_t;

 TTRANSPONDERFLAGS_ = (tlfActive = 0, tlfClockSynced = 1, tlfLowBattery = 2, tlfBlocked = 3,
   tlfRunningFromBackup = 4, tlfTwoWayOnBattery = 5, tlfStatusAvailable = 6, tlfLabelSet = 7,
   tlfHighTemperature = 8, tlfIncompatible = 9, tlfUsingDriverID = 10, tlfCanBusError = 11);

  {------------------------------------------------------------------------------------------------- }
  { Initialization specific API. }
  {------------------------------------------------------------------------------------------------- }
  {#include "appliance_structs.h"
  #include "service_structs.h"
   }

  {! Definition of the default notification function (has no parameters, only the context will be echoed and the handle to the host that sends the notification). }
  pfNotifyDefault = procedure (handle:mdp_sdk_handle_t; context:pointer); stdcall;

  {! Definition of the available appliance notification function. }
  pfNotifyAppliance = procedure (handle:mdp_sdk_handle_t; nType: TMDP_NOTIFY_TYPE; appliance:Pavailableappliance_t; context:pointer); stdcall;

  {! Definition of the verify appliance notification function. }
  pfNotifyVerifyAppliance = procedure (handle: mdp_sdk_handle_t; hostname: Pchar; is_verified: boolean; appliance: Pavailableappliance_t; context:pointer); stdcall;

  {! Definition of the device related notification function. }
  pfNotifyDevice = procedure (handle: Tmta_handle_t; nType:TMDP_NOTIFY_TYPE; devicearray: PPdevice_t; count: cardinal; context:pointer); stdcall;

  {! Definition of the connect related notification function. }
  pfNotifyConnect = procedure (handle: Tmta_handle_t; is_connected: boolean; context:pointer); stdcall;

  {! Definition of the connection state related notification function. }
  pfNotifyConnectionState = procedure (handle: Tmta_handle_t; connection_state: cardinal; context:pointer); stdcall;

  {! Definition of the passing related notification function. }
  pfNotifyPassing = procedure (handle: Tmta_eventdata_handle_t; nType:TMDP_NOTIFY_TYPE; const passingarray: PPTpassing_t; count: cardinal; context: pointer); stdcall;

  {! Definition of the passing-trigger related notification function. }
  pfNotifyPassingTrigger = procedure (handle: Tmta_eventdata_handle_t; nType:TMDP_NOTIFY_TYPE; passingtriggerarray: PPpassingtrigger_t; count: cardinal; context: pointer); stdcall;

  {! Definition of the loop related notification function. }
  pfNotifyLoop = procedure (handle: Tmta_handle_t; nType: TMDP_NOTIFY_TYPE; looparray: PPloop_t; count: cardinal; context: pointer); stdcall;

  {! Definition of the current loop status related notification function. }
  pfNotifyLoopStatus = procedure (handle: Tmta_eventdata_handle_t; nType:TMDP_NOTIFY_TYPE; loopstatus: Ploopstatus_t; context: pointer); stdcall;

  {! Definition of the current loop trigger related notification function. }
  pfNotifyLoopTrigger = procedure (handle: Tmta_eventdata_handle_t; nType: TMDP_NOTIFY_TYPE; trigger: Plooptrigger_t; context: pointer); stdcall;


  // General SDK related functions

  {! Get a handle to the Mylaps SDK. This call should be done first since the next calls depend on it. }
  function mdp_sdk_alloc(appname:Pchar; context:pointer): mdp_sdk_handle_t; stdcall; external External_library name '_mdp_sdk_alloc@8';

  {! Deallocate a handle to the Mylaps SDK. This will destroy all client handles. Do NOT call this function from a notification function. Doing so will abort your program. }
  procedure mdp_sdk_dealloc(handle:mdp_sdk_handle_t); stdcall; external External_library name '_mdp_sdk_dealloc@4';

  {! This is the message processing main function. Must be called from within the current (thread) context (if wait is 'true', this call will block until a message is received).
  Use timeout > 0 if you want to wait (block) for a specific time (in micro-seconds}
  procedure mdp_sdk_messagequeue_process(handle:mdp_sdk_handle_t; wait: boolean; timeout:Tmdp_time_t); stdcall; external External_library name '_mdp_sdk_messagequeue_process@16';

  {! Redirect output of internal SDK debugging message(s) to stderr. }
  procedure mdp_sdk_redirect_to_stderr(handle:mdp_sdk_handle_t; redirect:boolean); stdcall; external External_library name '_mdp_sdk_redirect_to_stderr@8';

  {! Get the version of the Mylaps SDK. }
  function mdp_sdk_get_version(handle:mdp_sdk_handle_t): Pmylaps_sdk_version_t; stdcall; external External_library name '_mdp_sdk_get_version@4';

  {! Function to specify a function that should be called when a message is ready to be processed. WARNING: This function runs in the context of the SDK, so you should only
    use it to notify the (main) thread. In the context of the (main) thread, you should be calling host_messagequeue_process() to process the available messages.}
  procedure mdp_sdk_notify_messagequeue(handle:mdp_sdk_handle_t; NotifyMessageAvailable:pfNotifyDefault); stdcall; external External_library name '_mdp_sdk_notify_messagequeue@8';

  {! Function to specify a function that should be called when an available appliance is resolved, updated or removed from the network. }
  procedure mdp_sdk_notify_appliance(handle:mdp_sdk_handle_t; NotifyService:pfNotifyAppliance); stdcall; external External_library name '_mdp_sdk_notify_appliance@8';

  {! Function to specify a function that should be called when an available appliance is verified. Appliance is only valid when is_verified is true. }
  procedure mdp_sdk_notify_verify_appliance(handle:mdp_sdk_handle_t; NotifyVerifyAppliance:pfNotifyVerifyAppliance); stdcall; external External_library name '_mdp_sdk_notify_verify_appliance@8';

  {! Function to convert the mdp_time_t (in microseconds since 1/1/70) to a string. }
  function mdp_get_time_as_string(buf: Pchar; buflength: size_t; time: Tmdp_time_t; adjust_format: boolean; decimals: longint): Pchar; stdcall; external External_library name '_mdp_get_time_as_string@24';

  {! Function to convert the mdp_time_t to a string using the strftime() API. }
  function mdp_get_time_as_strfstring(buf:Pchar; buflength:size_t; time: Tmdp_time_t; format:Pchar): Pchar; stdcall; external External_library name '_mdp_get_time_as_strfstring@20';

  {! Function to convert the mdp_time_t (in microseconds since 1/1/70) and length (in micrometer) to a string. The scale }
  {! can be used to convert the speed from m/s to e.g. km/h (scale = 3.6) or mph (scale = 2.2369362920544). }
  function mdp_get_speed_as_string(buf:Pchar; buflength:size_t; time: Tmdp_time_t; length: Int64; scale:double;
             decimals:longint): Pchar; stdcall; external External_library name '_mdp_get_speed_as_string@36';

  {! Function to convert the mdp_time_t to a string (YYYY-MM-DD) }
  function mdp_get_date_as_string(buf:Pchar; buflength:size_t; time: Tmdp_time_t): Pchar; stdcall; external External_library name '_mdp_get_date_as_string@16';

  {! Function to convert the double to a string. }
  function mdp_double_to_string(buf:Pchar; buflength:size_t; number:double): Pchar; stdcall; external External_library name '_mdp_double_to_string@16';

  {! Function to convert the string to double. }
  function mdp_string_to_double(buf:Pchar):double; stdcall; external External_library name '_mdp_string_to_double@4';

  {! Function to convert an IP address to a string. }
  function mdp_ipaddress_to_string(buf:Pchar; buflength:size_t; ip: cardinal): Pchar; stdcall; external External_library name '_mdp_ipaddress_to_string@12';

  {! Function to convert a string to an IP address. }
  function mdp_string_to_ipaddress(buf:Pchar): cardinal; stdcall; external External_library name '_mdp_string_to_ipaddress@4';

  {! Function to convert a MAC address to a string. }
  function mdp_mac_to_string(buf:Pchar; buflength:size_t; mac: Int64; include_dash: boolean): Pchar; stdcall; external External_library name '_mdp_mac_to_string@20';

  {! Function to convert a int64_t to string. }
  function mdp_int64_to_string(buf:Pchar; buflength:size_t; number: Int64): Pchar; stdcall; external External_library name '_mdp_int64_to_string@16';

  {! Function to convert a string to int64_t. }
  function mdp_string_to_int64(buf:Pchar):Int64; stdcall; external External_library name '_mdp_string_to_int64@4';

  {! Function to get the version as a string. }
  function mdp_version_to_string(buf:Pchar; buflength:size_t; version: cardinal; include_build: boolean): Pchar; stdcall; external External_library name '_mdp_version_to_string@16';

  {! Function to convert the given transponder type to a transponder number. }
  function mdp_string_to_transponder(buf:Pchar; _type: cardinal): cardinal; stdcall; external External_library name '_mdp_string_to_transponder@8';

  {! Function to convert a transponder to an alphanumeric (active) transponder number. }
  function mdp_transponder_to_string(buf:Pchar; buflength:size_t; transponder: cardinal; _type: cardinal): Pchar; stdcall; external External_library name '_mdp_transponder_to_string@16';

  {! Function to get the transponder type as a string. }
  function mdp_transponder_type_to_string(buf:Pchar; buflength:size_t; _type: cardinal): Pchar; stdcall; external External_library name '_mdp_transponder_type_to_string@12';

  {! Function to convert the given loop-trigger to an loop-trigger number. }
  function mdp_string_to_looptrigger(buf:Pchar): cardinal; stdcall; external External_library name '_mdp_string_to_looptrigger@4';

  {! Function to convert an loop-trigger to an alphanumeric loop-trigger number. }
  function mdp_looptrigger_to_string(buf:Pchar; buflength:size_t; looptrigger: cardinal): Pchar; stdcall; external External_library name '_mdp_looptrigger_to_string@12';

  {! Function to check if a key was hit without waiting. }
  function mdp_kbhit:longint; stdcall; external External_library name '_mdp_kbhit@0';

  {! Function to get a key without waiting. }
  function mdp_getch:longint; stdcall; external External_library name '_mdp_getch@0';


  // Available-appliance related functions

  {! Verify if an appliance is available. The user will be notified by the mdp_sdk_notify_verify_appliance function. Returns false if failed. }
  function mdp_sdk_appliance_verify(handle:mdp_sdk_handle_t; hostname:Pchar): boolean; stdcall; external External_library name '_mdp_sdk_appliance_verify@8';

  {!< Returns the first available appliance. Returns NULL at the end. }
  function mdp_sdk_appliance_get_head(handle:mdp_sdk_handle_t): Pavailableappliance_t; stdcall; external External_library name '_mdp_sdk_appliance_get_head@4';

  {!< Returns the next available appliance. Returns NULL at the end. }
  function mdp_sdk_appliance_get_next(handle:mdp_sdk_handle_t): Pavailableappliance_t; stdcall; external External_library name '_mdp_sdk_appliance_get_next@4';

  {!< Find a specific appliance. Returns NULL if not found. }
  function mdp_sdk_appliance_find(handle:mdp_sdk_handle_t; mac: Int64): Pavailableappliance_t; stdcall; external External_library name '_mdp_sdk_appliance_find@12';

  {!< Returns the number of available appliances. }
  function mdp_sdk_appliance_get_count(handle:mdp_sdk_handle_t): cardinal; stdcall; external External_library name '_mdp_sdk_appliance_get_count@4';


  // MTA-Client functions

  {! Get the current synchronized (to the MTA clock) UTC time. }
  function mta_time_get_utc(handle:Tmta_handle_t):Tmdp_time_t; stdcall; external External_library name '_mta_time_get_utc@4';

  {! Get a handle to the Mylaps Timing Appliance (MTA). Returns NULL upon failure. }
  function mta_handle_alloc(sdk_handle: mdp_sdk_handle_t; context:pointer): Tmta_handle_t; stdcall; external External_library name '_mta_handle_alloc@8';

  {! Deallocate a handle to the Mylaps Timing Appliance (MTA). This will close the connection and delete all data associated with this appliance. }
  {! Do NOT call this function from a notification function. Doing so will abort your program. }
  procedure mta_handle_dealloc(sdk_handle: mdp_sdk_handle_t; handle: Tmta_handle_t); stdcall; external External_library name '_mta_handle_dealloc@8';

  {! Notify the program when a device is selected, inserted, updated or deleted. }
  procedure mta_notify_device(handle:Tmta_handle_t; NotifyDevice: pfNotifyDevice); stdcall; external External_library name '_mta_notify_device@8';

  {! Subscribe to specific 'object' data on the system-setup. After subscribing to an object type, }
  {! the client will be notified automatically when changes occur for that specific object. }
  function mta_objectdata_subscribe(handle: Tmta_handle_t; object_type: TMTAOBJECTDATA): boolean; stdcall; external External_library name '_mta_objectdata_subscribe@8';

  {! Un-subscribe from specific 'object' data on the system-setup. After un-subscribing from an object type, }
  {! the client will not be notified anymore and the data will be cleared. }
  function mta_objectdata_unsubscribe(handle: Tmta_handle_t; object_type: TMTAOBJECTDATA): boolean; stdcall; external External_library name '_mta_objectdata_unsubscribe@8';

  {! Try to connect to an x2-server with the supplied username and password. If 'follow_current_systemsetup' is set to true, the application }
  {! will automatically switch to the system-setup that is current in use (and follow it if another system-setup is set to current). }
  function mta_connect(handle:Tmta_handle_t; hostname:Pchar; username:Pchar; password:Pchar; follow_current_systemsetup: boolean): boolean; stdcall; external External_library name '_mta_connect@20';

  {! Disconnect from an MTA. }
  procedure mta_disconnect(handle:Tmta_handle_t); stdcall; external External_library name '_mta_disconnect@4';

  {! Notify the program if the connection is established or dropped. }
  procedure mta_notify_connect(handle: Tmta_handle_t; NotifyConnect: pfNotifyConnect); stdcall; external External_library name '_mta_notify_connect@8';

  {! Notify the program when the state of the connection state has changed. }
  procedure mta_notify_connectionstate(handle: Tmta_handle_t; NotifyConnectionState: pfNotifyConnectionState); stdcall; external External_library name '_mta_notify_connectionstate@8';

  {!< Find a transponder on the current system-setup. Returns NULL if not found. }
  function mta_transponder_find(handle: Tmta_handle_t; id: cardinal): Ptransponder_t; stdcall; external External_library name '_mta_transponder_find@8';

  {! Notify the program when a loop is selected, inserted, updated or deleted. }
  procedure mta_notify_loop(handle: Tmta_handle_t; NotifyLoop: pfNotifyLoop); stdcall; external External_library name '_mta_notify_loop@8';

  {! Notify the program when a loop status record is received. }
  procedure mta_notify_loopstatus(handle: Tmta_eventdata_handle_t; OnNotifyLoopStatus: pfNotifyLoopStatus); stdcall; external External_library name '_mta_notify_loopstatus@8';

  {! Notify the program when a loop trigger is received. }
  procedure mta_notify_looptrigger(handle: Tmta_eventdata_handle_t; NotifyLoopTrigger: pfNotifyLoopTrigger); stdcall; external External_library name '_mta_notify_looptrigger@8';

  {! Notify the program when a passing-trigger is received. }
  procedure mta_notify_passingtrigger(handle: Tmta_eventdata_handle_t; NotifyPassingTrigger: pfNotifyPassingTrigger); stdcall; external External_library name '_mta_notify_passingtrigger@8';

  {! Insert a loop in the current system-setup. To let the system automatically generate an ID, set the ID to UINT32_MAX. The return value will be NULL if the ID is already in use. }
  function mta_loop_insert(handle: Tmta_handle_t; id: cardinal): Tmodify_loop_handle_t; stdcall; external External_library name '_mta_loop_insert@8';

  {! Commit all changes (both object-data and event-data) to the MTA. }
  procedure mta_changes_commit(handle: Tmta_handle_t); stdcall; external External_library name '_mta_changes_commit@4';

  {! Update a loop in the current system-setup. If successful, notify_loop() will be called with MDP_NOTIFY_UPDATE. }
  function mta_loop_update(handle: Tmta_handle_t; id: cardinal): Tmodify_loop_handle_t; stdcall; external External_library name '_mta_loop_update@8';

  {!< Returns the first loop on the current system-setup. Returns NULL at the end. }
  function mta_loop_get_head(handle:Tmta_handle_t):Ploop_t; stdcall; external External_library name '_mta_loop_get_head@4';
  function mta_loop_get_next(handle:Tmta_handle_t):Ploop_t; stdcall; external External_library name '_mta_loop_get_next@4';

  {!< Find a loop on the current system-setup. Returns NULL if not found. }
  function mta_loop_find(handle:Tmta_handle_t; id:cardinal):Ploop_t; stdcall; external External_library name '_mta_loop_find@8';

  {!< Returns the number of loops. }
  function mta_loop_get_count(handle:Tmta_handle_t):cardinal; stdcall; external External_library name '_mta_loop_get_count@4';



  // event data notification specific API

  {! Get a handle to an event-data container for getting live data, returns NULL upon failure. }
  function mta_eventdata_handle_alloc_live(handle: Tmta_handle_t; context:pointer): Tmta_eventdata_handle_t; stdcall; external External_library name '_mta_eventdata_handle_alloc_live@8';

  {! Subscribe to 'event' data on the system-setup (within the specified time-frame, with a maximum of 'request_limit' initially requested items). }
  {! After subscribing to an object type, the client will be notified automatically when changes occur. If 'cache_objects' is set to false, the }
  {! objects will not be stored at the SDK side. This means that the objects only exist during the notification function. }
  function mta_eventdata_subscribe(handle: Tmta_eventdata_handle_t; eventdata_type: TMTAEVENTDATA; request_limit: cardinal; cache_objects: boolean): boolean; stdcall; external External_library name '_mta_eventdata_subscribe@16';

  {! Un-subscribe from 'event' data on the system-setup. After un-subscribing from an object type, the client will not be notified }
  {! anymore and the data will be cleared. }
  function mta_eventdata_unsubscribe(handle: Tmta_eventdata_handle_t; eventdata_type: TMTAEVENTDATA): boolean; stdcall; external External_library name '_mta_eventdata_unsubscribe@8';

  {! Deallocate a handle to the event-data container. This will delete all data associated with this event-data container. }
  {! Do NOT call this function from a notification function. Doing so will abort your program. }
  function mta_eventdata_handle_dealloc(handle: Tmta_handle_t; eventhandle: Tmta_eventdata_handle_t): boolean; stdcall; external External_library name '_mta_eventdata_handle_dealloc@8';

  {! Get a handle to an event-data container for getting live data, but with historical data (resend) from utcfromtime. Returns NULL upon failure. }
  {! The supplied context pointer will be echoed by all notification functions. }
  function mta_eventdata_handle_alloc_live_with_resend(handle: Tmta_handle_t; utcfromtime: Tmdp_time_t; context: pointer): Tmta_eventdata_handle_t; stdcall; external External_library name '_mta_eventdata_handle_alloc_live_with_resend@16';

  {! Notify the program when a passing is received. }
  procedure mta_notify_passing(handle: Tmta_eventdata_handle_t; NotifyPassing: pfNotifyPassing); stdcall; external External_library name '_mta_notify_passing@8';

  {! Get the appliance handle that belongs to the event-data container handle. }
  function mta_eventdata_get_appliance_handle(handle: Tmta_eventdata_handle_t): Tmta_handle_t; stdcall; external External_library name '_mta_eventdata_get_appliance_handle@4';


  // hardware structs

  {!< Get the signal strength (in dBm). }
  function passing_is_low_battery(p: PTpassing_t): boolean; stdcall; external External_library name 'passing_is_low_battery';

  {!< Is the noise level of the can receiver valid? }
  function loopstatus_get_noise_tranx(p: Ploopstatus_t): double; stdcall; external External_library name 'loopstatus_get_noise_tranx';




  {@ }
  {-------------------------------------------------------------------------------------------------  }
  { Include the specific appliance calls.  }
  {-------------------------------------------------------------------------------------------------  }
  {#include "beacon_structs.h"
  #include "hardware_structs.h"
  #include "track_structs.h"

  #include "MTAClientLib.h"
  #include "MTAEventDataLib.h"
  '/

  /** @  }

implementation


end.
