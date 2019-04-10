unit KM_HTTPClientLNet;
{$I KaM_Remake.inc}
interface
uses
  Classes, SysUtils, lNet, URLUtils, lHTTP;

type
  TKMHTTPClientLNet = class
  private
    fHTTPClient:     TLHTTPClient;
    fHTTPBuffer:     AnsiString;
    fOnError,
    fOnGetCompleted: TGetStrProc;
    fIsUTF8:         Boolean;
    procedure HTTPClientDoneInput(aSocket: TLHTTPClientSocket);
    procedure HTTPClientError(const msg: string; aSocket: TLSocket);
    function HTTPClientInput(aSocket: TLHTTPClientSocket; aBuffer: PChar; aSize: Integer): Integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure GetURL(aURL: string; aIsUTF8: Boolean);
    procedure UpdateStateIdle;

    property OnError:        TGetStrProc write fOnError;
    property OnGetCompleted: TGetStrProc write fOnGetCompleted;
  end;

implementation


constructor TKMHTTPClientLNet.Create;
begin
  inherited Create;
  fHTTPClient             := TLHTTPClient.Create(nil);
  fHTTPClient.Timeout     := 0;
  fHTTPClient.OnInput     := HTTPClientInput;
  fHTTPClient.OnError     := HTTPClientError;
  fHTTPClient.OnDoneInput := HTTPClientDoneInput;
end;


destructor TKMHTTPClientLNet.Destroy;
begin
  fHTTPClient.Free;
  inherited;
end;


procedure TKMHTTPClientLNet.GetURL(aURL: string; aIsUTF8: Boolean);
var
  Proto, User, Pass, Host, Port, Path: string;
begin
  fHTTPClient.Disconnect(True); //If we were doing something, stop it
  fIsUTF8     := aIsUTF8;
  fHTTPBuffer := '';
  ParseURL(aURL, Proto, User, Pass, Host, Port, Path);
  fHTTPClient.Host := Host;
  fHTTPClient.URI  := Path;
  fHTTPClient.Port := StrToIntDef(Port, 80);
  fHTTPClient.SendRequest;
end;


procedure TKMHTTPClientLNet.HTTPClientDoneInput(aSocket: TLHTTPClientSocket);
var
  ReturnString: UnicodeString;
begin
  aSocket.Disconnect;

  if fIsUTF8 then
    ReturnString := UTF8Decode(fHTTPBuffer)
  else
    ReturnString := UnicodeString(fHTTPBuffer);

  if Assigned(fOnGetCompleted) then
    fOnGetCompleted(ReturnString);

  fHTTPBuffer := '';
end;


procedure TKMHTTPClientLNet.HTTPClientError(const msg: string; aSocket: TLSocket);
begin
  if Assigned(fOnError) then fOnError(msg);
end;


function TKMHTTPClientLNet.HTTPClientInput(aSocket: TLHTTPClientSocket; aBuffer: PChar; aSize: Integer): Integer;
var
  oldLength: DWord;
begin
  if aSize > 0 then
  begin
    oldLength := Length(fHTTPBuffer);
    setlength(fHTTPBuffer, oldLength + aSize);
    move(aBuffer^, fHTTPBuffer[oldLength + 1], aSize);
  end;

  Result := aSize; // tell the http buffer we read it all
end;


procedure TKMHTTPClientLNet.UpdateStateIdle;
begin
  fHTTPClient.CallAction; //Process network events
end;


end.
 
