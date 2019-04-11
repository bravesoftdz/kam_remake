unit KM_DedicatedServer;
{$I KaM_Remake.inc}
interface
uses
  SysUtils, Classes, Math,
  {$IFDEF MSWindows} Windows, {$ENDIF}
  KM_NetServer, KM_MasterServer, KM_NetUDP, KM_CommonTypes, KM_Defaults;

type
  TKMDedicatedServer = class
  private
    fLastPing,
    fLastAnnounce:     Cardinal;
    fNetServer:        TKMNetServer;
    fMasterServer:     TKMMasterServer;
    fUDPAnnounce:      TKMNetUDPAnnounce;
    fOnMessage:        TUnicodeStringEvent;
    fPublishServer,
    fBroadcastLocal:   Boolean;
    fAnnounceInterval,
    fPingInterval,
    fPort:             Word;
    fServerName:       AnsiString;
    procedure StatusMessage(const aData: string);
    procedure MasterServerError(const aData: string);
  public
    constructor Create(aMaxRooms, aKickTimeout, aPingInterval, aAnnounceInterval: Word;
                       const aMasterServerAddress: string; const aHTMLStatusFile: string;
                       const aWelcomeMessage: UnicodeString; aDedicated: Boolean);
    destructor Destroy; override;

    procedure Start(const aServerName: AnsiString; const aPort: Word; aPublishServer, aBroadcastLocal: Boolean);
    procedure Stop;
    procedure UpdateState;
    procedure UpdateSettings(const aServerName: AnsiString; aPublishServer, aBroadcastLocal: Boolean;
                             aKickTimeout, aPingInterval, aAnnounceInterval: Word; const aMasterServerAddress: string;
                             const aHTMLStatusFile: string; const aWelcomeMessage: UnicodeString);
    property OnMessage: TUnicodeStringEvent write fOnMessage;
    
    procedure GetServerInfo(var aList: TList);
    function IsListening: Boolean;
  end;


implementation
uses
  KM_Utils;

const
  // Enforce a minimum so our master server doesn't get spammed
  MINIMUM_ANNOUNCE_INTERVAL = 180;


//Announce interval of -1 means the server will not be published (LAN)
constructor TKMDedicatedServer.Create(aMaxRooms, aKickTimeout, aPingInterval, aAnnounceInterval: Word;
                                      const aMasterServerAddress: string; const aHTMLStatusFile: string;
                                      const aWelcomeMessage: UnicodeString; aDedicated: Boolean);
begin
  inherited Create;
  fNetServer            := TKMNetServer.Create(aMaxRooms, aKickTimeout, aHTMLStatusFile, aWelcomeMessage);
  fMasterServer         := TKMMasterServer.Create(aMasterServerAddress, aDedicated);
  fMasterServer.OnError := MasterServerError;
  fUDPAnnounce          := TKMNetUDPAnnounce.Create;
  fUDPAnnounce.OnError  := StatusMessage;

  fAnnounceInterval := Max(MINIMUM_ANNOUNCE_INTERVAL, aAnnounceInterval);
  fPingInterval     := aPingInterval;
  fLastPing         := 0;
  fLastAnnounce     := 0;
end;


destructor TKMDedicatedServer.Destroy;
begin
  FreeAndNil(fNetServer);
  FreeAndNil(fMasterServer);
  FreeAndNil(fUDPAnnounce);
  StatusMessage('Server destroyed');
  inherited;
end;


procedure TKMDedicatedServer.Start(const aServerName: AnsiString; const aPort: Word; aPublishServer, aBroadcastLocal: Boolean);
begin
  fPort                      := aPort;
  fServerName                := aServerName;
  fPublishServer             := aPublishServer;
  fBroadcastLocal            := aBroadcastLocal;
  fNetServer.OnStatusMessage := StatusMessage;
  fNetServer.StartListening(fPort, fServerName);

  if fBroadcastLocal then
    fUDPAnnounce.StartAnnouncing(fPort, fServerName);
end;


procedure TKMDedicatedServer.Stop;
begin
  fNetServer.StopListening;
  fNetServer.ClearClients;

  if fBroadcastLocal or fUDPAnnounce.Announcing then
    fUDPAnnounce.StopAnnouncing;

  StatusMessage('Stopped listening');
end;


procedure TKMDedicatedServer.UpdateState;
var
  TickCount: Cardinal;
begin
  fNetServer.UpdateStateIdle;
  fMasterServer.UpdateStateIdle;

  if fBroadcastLocal and fUDPAnnounce.Announcing then
    fUDPAnnounce.UpdateStateIdle;

  if not fNetServer.Listening then
    Exit; //Do not measure pings or announce the server if we are not listening

  TickCount := TimeGet;

  if GetTimeSince(fLastPing) >= fPingInterval then
  begin
    fNetServer.MeasurePings;
    fLastPing := TickCount;
  end;

  if fPublishServer and (GetTimeSince(fLastAnnounce) >= fAnnounceInterval * 1000) then
  begin
    fMasterServer.AnnounceServer(
      UnicodeString(fServerName),
      fPort,
      fNetServer.GetPlayerCount,
      fAnnounceInterval + 20
    );
    fLastAnnounce := TickCount;
  end;
end;


procedure TKMDedicatedServer.UpdateSettings(const aServerName: AnsiString; aPublishServer, aBroadcastLocal: Boolean;
                                            aKickTimeout, aPingInterval, aAnnounceInterval: Word; const aMasterServerAddress: string;
                                            const aHTMLStatusFile: string; const aWelcomeMessage: UnicodeString);
begin
  fAnnounceInterval                 := Max(MINIMUM_ANNOUNCE_INTERVAL, aAnnounceInterval);
  fPingInterval                     := aPingInterval;
  fMasterServer.MasterServerAddress := aMasterServerAddress;
  fServerName                       := aServerName;
  fPublishServer                    := aPublishServer;
  fBroadcastLocal                   := aBroadcastLocal;

  fNetServer.UpdateSettings(aKickTimeout, aHTMLStatusFile, aWelcomeMessage, aServerName);
  fUDPAnnounce.UpdateSettings(aServerName);

  if aBroadcastLocal then
  begin
    if not fUDPAnnounce.Announcing then
       fUDPAnnounce.StartAnnouncing(fPort, fServerName);
  end else if fUDPAnnounce.Announcing then
    fUDPAnnounce.StopAnnouncing;

  fLastAnnounce := 0; //Make the server announce itself next update so the changes are sent to the master server ASAP
end;


procedure TKMDedicatedServer.StatusMessage(const aData: string);
begin
  if Assigned(fOnMessage) then
    fOnMessage(aData);
end;


procedure TKMDedicatedServer.MasterServerError(const aData: string);
begin
  StatusMessage('HTTP Master Server: ' + aData);
end;


procedure TKMDedicatedServer.GetServerInfo(var aList: TList);
begin
  fNetServer.GetServerInfo(aList);
end;


function TKMDedicatedServer.IsListening: Boolean;
begin
  Result := fNetServer.Listening;
end;


end.
