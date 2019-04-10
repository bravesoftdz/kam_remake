unit KM_HTTPClient;
{$I KaM_Remake.inc}
interface
uses
  Classes, SysUtils,
  {$IFDEF WDC} KM_HTTPClientOverbyte {$ELSE} KM_HTTPClientLNet {$ENDIF};

type
  //General wrapper for Delphi/Lazarus implementations
  TKMHTTPClient = class
  private
    fClient: {$IFDEF WDC} TKMHTTPClientOverbyte {$ELSE} TKMHTTPClientLNet {$ENDIF} ;
    fOnError,
    fOnReceive: TGetStrProc;
    procedure Error(const S: string);
    procedure GetCompleted(const S: string);
  public
    constructor Create;
    destructor Destroy; override;

    procedure GetURL(aURL: string; aIsUTF8: Boolean);
    procedure UpdateStateIdle;

    property OnError:   TGetStrProc write fOnError;
    property OnReceive: TGetStrProc write fOnReceive;
  end;


implementation


constructor TKMHTTPClient.Create;
begin
  inherited;
  fClient                := {$IFDEF WDC} TKMHTTPClientOverbyte {$ELSE} TKMHTTPClientLNet {$ENDIF} .Create;
  fClient.OnGetCompleted := GetCompleted;
  fClient.OnError        := Error;
end;


destructor TKMHTTPClient.Destroy;
begin
  fClient.Free;
  inherited;
end;


procedure TKMHTTPClient.GetURL(aURL: string; aIsUTF8: Boolean);
begin
  fClient.GetURL(aUrl, aIsUTF8);
end;


procedure TKMHTTPClient.GetCompleted(const S: string);
begin
  if Assigned(fOnReceive) then fOnReceive(S);
end;


procedure TKMHTTPClient.Error(const S: string);
begin
  if Assigned(fOnError) then fOnError(S);
end;


procedure TKMHTTPClient.UpdateStateIdle;
begin
  {$IFDEF FPC} fClient.UpdateStateIdle; {$ENDIF}
end;


end.

