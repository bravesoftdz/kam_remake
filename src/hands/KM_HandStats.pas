unit KM_HandStats;
{$I KaM_Remake.inc}
interface
uses
  KM_WareDistribution,
  KM_ResWares, KM_ResHouses,
  KM_CommonClasses, KM_CommonTypes, KM_Defaults;


//These are stats for each player
type
  TKMHouseStats = packed record
    Planned,             //Houseplans were placed
    PlanRemoved,         //Houseplans were removed
    Started,             //Construction started
    Ended,               //Construction ended (either done or destroyed/cancelled)
    Initial,             //created by script on mission start
    Built,               //constructed by player
    SelfDestruct,        //deconstructed by player
    Lost,                //lost from attacks and self-demolished
    Closed,              //closed for worker
    Destroyed: Cardinal; //damage to other players
  end;

  TKMUnitStats = packed record
    Initial,          //Provided at mission start
    Training,         //Currently in training queue
    Trained,          //Trained by player
    Lost,             //Died of hunger or killed
    Killed: Cardinal; //Killed (incl. self)
  end;

  TKMWareStats = packed record
    Initial: Cardinal;
    Produced: Cardinal;
    Consumed: Cardinal;
  end;

  // Army chart kind
  TKMChartArmyKind = (
    cak_Instantaneous, // Charts of in game warriors quantities
    cak_Total,         // Charts of total army trained (includes initial army)
    cak_Defeated,
    cak_Lost);

  //Player statistics (+ ratios, house unlock, trade permissions)
  TKMHandStats = class
  private
    fChartCount: Integer;
    fChartCapacity: Integer;
    fChartHouses: TKMCardinalArray;
    fChartCitizens: TKMCardinalArray;
    fChartArmy: array[TKMChartArmyKind] of array[WARRIOR_MIN..WARRIOR_MAX] of TKMCardinalArray;
    fChartWares: array [WARE_MIN..WARE_MAX] of TKMCardinalArray;
    // No need to save fArmyEmpty array, as it will be still same after load and 1 HandStats update (which we always do on game exit)
    // It's important to use cak_Total instead of cak_Instantenious, because Inst. can be empty even after load and 1 update state!
    fArmyEmpty: array[cak_Total..cak_Lost] of array [WARRIOR_MIN..WARRIOR_MAX] of Boolean;

    Houses: array [TKMHouseType] of TKMHouseStats;
    Units: array [HUMANS_MIN..HUMANS_MAX] of TKMUnitStats;
    Wares: array [WARE_MIN..WARE_MAX] of TKMWareStats;
    MilitiaTrainedInTownHall: Cardinal;

    fWareDistribution: TKMWareDistribution;
    function GetChartWares(aWare: TKMWareType): TKMCardinalArray;
    function GetChartArmy(aChartKind: TKMChartArmyKind; aWarrior: TKMUnitType): TKMCardinalArray;
    function GetArmyChartValue(aChartKind: TKMChartArmyKind; aUnitType: TKMUnitType): Integer;
  public
    constructor Create;
    destructor Destroy; override;

    //Input reported by Player
    procedure WareInitial(aRes: TKMWareType; aCount: Cardinal);
    procedure WareProduced(aRes: TKMWareType; aCount: Cardinal);
    procedure WareConsumed(aRes: TKMWareType; aCount: Cardinal = 1);
    procedure HousePlanned(aType: TKMHouseType);
    procedure HousePlanRemoved(aType: TKMHouseType);
    procedure HouseStarted(aType: TKMHouseType);
    procedure HouseClosed(aWasClosed: Boolean; aType: TKMHouseType);
    procedure HouseEnded(aType: TKMHouseType);
    procedure HouseCreated(aType: TKMHouseType; aWasBuilt: Boolean);
    procedure HouseLost(aType: TKMHouseType);
    procedure HouseSelfDestruct(aType: TKMHouseType);
    procedure HouseDestroyed(aType: TKMHouseType);
    procedure UnitCreated(aType: TKMUnitType; aWasTrained: Boolean; aFromTownHall: Boolean = False);
    procedure UnitAddedToTrainingQueue(aType: TKMUnitType);
    procedure UnitRemovedFromTrainingQueue(aType: TKMUnitType);
    procedure UnitLost(aType: TKMUnitType);
    procedure UnitKilled(aType: TKMUnitType);

    property WareDistribution: TKMWareDistribution read fWareDistribution;

    //Output
    function GetHouseQty(aType: TKMHouseType): Integer; overload;
    function GetHouseOpenedQty(aType: TKMHouseType): Integer; overload;
    function GetHouseQty(aType: array of TKMHouseType): Integer; overload;
    function GetHouseWip(aType: TKMHouseType): Integer; overload;
    function GetHousePlans(aType: TKMHouseType): Integer; overload;
    function GetHouseWip(aType: array of TKMHouseType): Integer; overload;
    function GetHouseTotal(aType: TKMHouseType): Integer;
    function GetUnitQty(aType: TKMUnitType): Integer;
    function GetUnitWip(aType: TKMUnitType): Integer;
    function GetUnitKilledQty(aType: TKMUnitType): Integer;
    function GetUnitLostQty(aType: TKMUnitType): Integer;
    function GetWareBalance(aRT: TKMWareType): Integer;
    function GetArmyCount: Integer;
    function GetCitizensCount: Integer;

    function GetCitizensTrained: Cardinal;
    function GetCitizensLost: Cardinal;
    function GetCitizensKilled: Cardinal;
    function GetHousesBuilt: Cardinal;
    function GetHousesLost: Cardinal;
    function GetHousesDestroyed: Cardinal;
    function GetWarriorsTrained: Cardinal;
    function GetWarriorsTotal(aWarriorType: TKMUnitType): Cardinal;
    function GetWarriorsKilled: Cardinal;
    function GetWarriorsLost: Cardinal;
    function GetWaresProduced(aRT: TKMWareType): Cardinal;
    function GetCivilProduced: Cardinal;
    function GetWeaponsProduced: Cardinal;
    function GetWarfareProduced: Cardinal;

    property ChartCount: Integer read fChartCount;
    property ChartHouses: TKMCardinalArray read fChartHouses;
    property ChartCitizens: TKMCardinalArray read fChartCitizens;
    property ChartWares[aWare: TKMWareType]: TKMCardinalArray read GetChartWares;

    property ChartArmy[aChartKind: TKMChartArmyKind; aWarrior: TKMUnitType]: TKMCardinalArray read GetChartArmy;
    function ChartWaresEmpty(aWare: TKMWareType): Boolean;
    function ChartArmyEmpty(aChartKind: TKMChartArmyKind; aWarrior: TKMUnitType): Boolean;

    procedure Save(SaveStream: TKMemoryStream);
    procedure Load(LoadStream: TKMemoryStream);

    procedure UpdateState;
  end;


implementation
uses
  SysUtils,
  KM_Resource;


{ TKMHandStats }
constructor TKMHandStats.Create;
var
  WT: TKMUnitType;
  CKind: TKMChartArmyKind;
begin
  inherited;

  fWareDistribution := TKMWareDistribution.Create;

  for CKind := cak_Total to cak_Lost do
    for WT := WARRIOR_MIN to WARRIOR_MAX do
      fArmyEmpty[CKind,WT] := True;
end;


destructor TKMHandStats.Destroy;
begin
  FreeAndNil(fWareDistribution);
  inherited;
end;


procedure TKMHandStats.HousePlanned(aType: TKMHouseType);
begin
  Inc(Houses[aType].Planned);
end;


procedure TKMHandStats.HousePlanRemoved(aType: TKMHouseType);
begin
  Inc(Houses[aType].PlanRemoved);
end;


//New house in progress
procedure TKMHandStats.HouseStarted(aType: TKMHouseType);
begin
  Inc(Houses[aType].Started);
end;


//House building process was ended. We don't really know if it was canceled or destroyed or finished
//Other House** methods will handle that
procedure TKMHandStats.HouseEnded(aType: TKMHouseType);
begin
  Inc(Houses[aType].Ended);
end;


//House closed for worker
procedure TKMHandStats.HouseClosed(aWasClosed: Boolean; aType: TKMHouseType);
begin
  if aWasClosed then
    Inc(Houses[aType].Closed)
  else
    Dec(Houses[aType].Closed)
end;


//New house, either built by player or created by mission script
procedure TKMHandStats.HouseCreated(aType: TKMHouseType; aWasBuilt:boolean);
begin
  if aWasBuilt then
    Inc(Houses[aType].Built)
  else
    Inc(Houses[aType].Initial);
end;


//Destroyed by enemy
procedure TKMHandStats.HouseLost(aType: TKMHouseType);
begin
  Inc(Houses[aType].Lost);
end;


procedure TKMHandStats.HouseSelfDestruct(aType: TKMHouseType);
begin
  Inc(Houses[aType].SelfDestruct);
end;


//Player has destroyed an enemy house
procedure TKMHandStats.HouseDestroyed(aType: TKMHouseType);
begin
  Inc(Houses[aType].Destroyed);
end;


procedure TKMHandStats.UnitAddedToTrainingQueue(aType: TKMUnitType);
begin
  Inc(Units[aType].Training);
end;


procedure TKMHandStats.UnitRemovedFromTrainingQueue(aType: TKMUnitType);
begin
  Dec(Units[aType].Training);
end;


procedure TKMHandStats.UnitCreated(aType: TKMUnitType; aWasTrained: Boolean; aFromTownHall: Boolean = False);
begin
  if aWasTrained then
  begin
    Inc(Units[aType].Trained);
    if aFromTownHall and (aType = ut_Militia) then
      Inc(MilitiaTrainedInTownHall);
  end else
    Inc(Units[aType].Initial);
end;


procedure TKMHandStats.UnitLost(aType: TKMUnitType);
begin
  Inc(Units[aType].Lost);
end;


procedure TKMHandStats.UnitKilled(aType: TKMUnitType);
begin
  Inc(Units[aType].Killed);
end;


procedure TKMHandStats.WareInitial(aRes: TKMWareType; aCount: Cardinal);
begin
  if aRes <> wt_None then
    Inc(Wares[aRes].Initial, aCount);
end;


procedure TKMHandStats.WareProduced(aRes: TKMWareType; aCount: Cardinal);
var R: TKMWareType;
begin
  if aRes <> wt_None then
    case aRes of
      wt_All:     for R := WARE_MIN to WARE_MAX do
                    Inc(Wares[R].Produced, aCount);
      WARE_MIN..
      WARE_MAX:   Inc(Wares[aRes].Produced, aCount);
      else        raise Exception.Create('Cant''t add produced ware ' + gRes.Wares[aRes].Title);
    end;
end;


procedure TKMHandStats.WareConsumed(aRes: TKMWareType; aCount: Cardinal = 1);
begin
  if aRes <> wt_None then
    Inc(Wares[aRes].Consumed, aCount);
end;


//How many complete houses are there
function TKMHandStats.GetHouseQty(aType: TKMHouseType): Integer;
var H: TKMHouseType;
begin
  Result := 0;
  case aType of
    htNone:    ;
    htAny:     for H := HOUSE_MIN to HOUSE_MAX do
                  Inc(Result, Houses[H].Initial + Houses[H].Built - Houses[H].SelfDestruct - Houses[H].Lost);
    else        Result := Houses[aType].Initial + Houses[aType].Built - Houses[aType].SelfDestruct - Houses[aType].Lost;
  end;
end;


//How many complete opened houses are there
function TKMHandStats.GetHouseOpenedQty(aType: TKMHouseType): Integer;
var H: TKMHouseType;
begin
  Result := 0;
  case aType of
    htNone:    ;
    htAny:     for H := HOUSE_MIN to HOUSE_MAX do
                  Inc(Result, Houses[H].Initial + Houses[H].Built - Houses[H].SelfDestruct - Houses[H].Lost - Houses[H].Closed);
    else        Result := Houses[aType].Initial + Houses[aType].Built - Houses[aType].SelfDestruct - Houses[aType].Lost - Houses[aType].Closed;
  end;
end;


//How many complete houses there are
function TKMHandStats.GetHouseQty(aType: array of TKMHouseType): Integer;
var
  I: Integer;
  H: TKMHouseType;
begin
  Result := 0;
  if (Length(aType) = 0) then
    raise Exception.Create('Quering wrong house type')
  else
  if (Length(aType) = 1) and (aType[0] = htAny) then
  begin
    for H := HOUSE_MIN to HOUSE_MAX do
      Inc(Result, Houses[H].Initial + Houses[H].Built - Houses[H].SelfDestruct - Houses[H].Lost);
  end
  else
  for I := Low(aType) to High(aType) do
  if aType[I] in [HOUSE_MIN..HOUSE_MAX] then
    Inc(Result, Houses[aType[I]].Initial + Houses[aType[I]].Built - Houses[aType[I]].SelfDestruct - Houses[aType[I]].Lost)
  else
    raise Exception.Create('Quering wrong house type');
end;


//How many houses are planned and in progress
function TKMHandStats.GetHouseWip(aType: TKMHouseType): Integer;
var H: TKMHouseType;
begin
  Result := 0;
  case aType of
    htNone:    ;
    htAny:     for H := HOUSE_MIN to HOUSE_MAX do
                  Inc(Result, Houses[H].Started + Houses[H].Planned - Houses[H].Ended - Houses[H].PlanRemoved);
    else        Result := Houses[aType].Started + Houses[aType].Planned - Houses[aType].Ended - Houses[aType].PlanRemoved;
  end;
end;


//How many house plans player has at certain moment...
function TKMHandStats.GetHousePlans(aType: TKMHouseType): Integer;
begin
  Result := Houses[aType].Planned - Houses[aType].PlanRemoved;
end;


//How many houses are planned in progress and ready
function TKMHandStats.GetHouseTotal(aType: TKMHouseType): Integer;
begin
  Result := GetHouseQty(aType) + GetHouseWip(aType);
end;


//How many houses are planned and in progress
function TKMHandStats.GetHouseWip(aType: array of TKMHouseType): Integer;
var
  I: Integer;
  H: TKMHouseType;
begin
  Result := 0;
  if (Length(aType) = 0) then
    raise Exception.Create('Quering wrong house type')
  else
  if (Length(aType) = 1) and (aType[0] = htAny) then
  begin
    for H := HOUSE_MIN to HOUSE_MAX do
      Inc(Result, Houses[H].Started + Houses[H].Planned - Houses[H].Ended - Houses[H].PlanRemoved);
  end
  else
  for I := Low(aType) to High(aType) do
  if aType[I] in [HOUSE_MIN..HOUSE_MAX] then
    Inc(Result, Houses[aType[I]].Started + Houses[aType[I]].Planned - Houses[aType[I]].Ended - Houses[aType[I]].PlanRemoved)
  else
    raise Exception.Create('Quering wrong house type');
end;


function TKMHandStats.GetUnitQty(aType: TKMUnitType): Integer;
var
  UT: TKMUnitType;
begin
  Result := 0;
  case aType of
    ut_None: ;
    ut_Any:     for UT := HUMANS_MIN to HUMANS_MAX do
                  Inc(Result, Units[UT].Initial + Units[UT].Trained - Units[UT].Lost);
    else        begin
                  Result := Units[aType].Initial + Units[aType].Trained - Units[aType].Lost;
                  if aType = ut_Recruit then
                    for UT := WARRIOR_EQUIPABLE_MIN to WARRIOR_EQUIPABLE_MAX do
                      if UT = ut_Militia then
                        Dec(Result, Units[UT].Trained - MilitiaTrainedInTownHall) //Do not count militia, trained in TownHall, only in Barracks
                      else
                        Dec(Result, Units[UT].Trained); //Trained soldiers use a recruit
                end;
  end;
end;


function TKMHandStats.GetUnitWip(aType: TKMUnitType): Integer;
var
  UT: TKMUnitType;
begin
  Result := 0;
  case aType of
    ut_None: ;
    ut_Any:     for UT := HUMANS_MIN to HUMANS_MAX do
                  Inc(Result, Units[UT].Training);
    else        Result := Units[aType].Training;
  end;
end;


function TKMHandStats.GetUnitKilledQty(aType: TKMUnitType): Integer;
begin
  Result := Units[aType].Killed;
end;


function TKMHandStats.GetUnitLostQty(aType: TKMUnitType): Integer;
begin
  Result := Units[aType].Lost;
end;


//How many wares player has right now
function TKMHandStats.GetWareBalance(aRT: TKMWareType): Integer;
var
  RT: TKMWareType;
begin
  Result := 0;
  case aRT of
    wt_None:    ;
    wt_All:     for RT := WARE_MIN to WARE_MAX do
                  Inc(Result, Wares[RT].Initial + Wares[RT].Produced - Wares[RT].Consumed);
    wt_Warfare: for RT := WARFARE_MIN to WARFARE_MAX do
                  Inc(Result, Wares[RT].Initial + Wares[RT].Produced - Wares[RT].Consumed);
    else        Result := Wares[aRT].Initial + Wares[aRT].Produced - Wares[aRT].Consumed;
  end;
end;


function TKMHandStats.GetArmyCount: Integer;
var UT: TKMUnitType;
begin
  Result := 0;
  for UT := WARRIOR_MIN to WARRIOR_MAX do
    Inc(Result, GetUnitQty(UT));
end;


function TKMHandStats.GetCitizensCount: Integer;
var UT: TKMUnitType;
begin
  Result := 0;
  for UT := CITIZEN_MIN to CITIZEN_MAX do
    Inc(Result, GetUnitQty(UT));
end;


//The value includes only citizens, Warriors are counted separately
function TKMHandStats.GetCitizensTrained: Cardinal;
var UT: TKMUnitType;
begin
  Result := 0;
  for UT := CITIZEN_MIN to CITIZEN_MAX do
    Inc(Result, Units[UT].Trained);
end;


function TKMHandStats.GetCitizensLost: Cardinal;
var UT: TKMUnitType;
begin
  Result := 0;
  for UT := CITIZEN_MIN to CITIZEN_MAX do
    Inc(Result, Units[UT].Lost);
end;


function TKMHandStats.GetCitizensKilled: Cardinal;
var UT: TKMUnitType;
begin
  Result := 0;
  for UT := CITIZEN_MIN to CITIZEN_MAX do
    Inc(Result, Units[UT].Killed);
end;


function TKMHandStats.GetHousesBuilt: Cardinal;
var HT: TKMHouseType;
begin
  Result := 0;
  for HT := HOUSE_MIN to HOUSE_MAX do
    Inc(Result, Houses[HT].Built);
end;


function TKMHandStats.GetHousesLost: Cardinal;
var HT: TKMHouseType;
begin
  Result := 0;
  for HT := HOUSE_MIN to HOUSE_MAX do
    Inc(Result, Houses[HT].Lost);
end;


function TKMHandStats.GetHousesDestroyed: Cardinal;
var HT: TKMHouseType;
begin
  Result := 0;
  for HT := HOUSE_MIN to HOUSE_MAX do
    Inc(Result, Houses[HT].Destroyed);
end;


//The value includes all Warriors
function TKMHandStats.GetWarriorsTrained: Cardinal;
var UT: TKMUnitType;
begin
  Result := 0;
  for UT := WARRIOR_MIN to WARRIOR_MAX do
    Inc(Result, Units[UT].Trained);
end;


function TKMHandStats.GetWarriorsTotal(aWarriorType: TKMUnitType): Cardinal;
begin
  Result := Units[aWarriorType].Initial + Units[aWarriorType].Trained;
end;


function TKMHandStats.GetWarriorsLost: Cardinal;
var UT: TKMUnitType;
begin
  Result := 0;
  for UT := WARRIOR_MIN to WARRIOR_MAX do
    Inc(Result, Units[UT].Lost);
end;


function TKMHandStats.GetWarriorsKilled: Cardinal;
var UT: TKMUnitType;
begin
  Result := 0;
  for UT := WARRIOR_MIN to WARRIOR_MAX do
    Inc(Result, Units[UT].Killed);
end;


function TKMHandStats.GetWaresProduced(aRT: TKMWareType): Cardinal;
var RT: TKMWareType;
begin
  Result := 0;
  case aRT of
    wt_None:    ;
    wt_All:     for RT := WARE_MIN to WARE_MAX do
                  Inc(Result, Wares[RT].Produced);
    wt_Warfare: for RT := WARFARE_MIN to WARFARE_MAX do
                  Inc(Result, Wares[RT].Produced);
    else        Result := Wares[aRT].Produced;
  end;
end;


//Everything except weapons
function TKMHandStats.GetCivilProduced: Cardinal;
var RT: TKMWareType;
begin
  Result := 0;
  for RT := WARE_MIN to WARE_MAX do
  if not (RT in [WEAPON_MIN..WEAPON_MAX]) then
    Inc(Result, Wares[RT].Produced);
end;


//KaM includes all weapons and armor, but not horses
function TKMHandStats.GetWeaponsProduced: Cardinal;
var RT: TKMWareType;
begin
  Result := 0;
  for RT := WEAPON_MIN to WEAPON_MAX do
    Inc(Result, Wares[RT].Produced);
end;


function TKMHandStats.GetWarfareProduced: Cardinal;
var RT: TKMWareType;
begin
  Result := 0;
  for RT := WARFARE_MIN to WARFARE_MAX do
    Inc(Result, Wares[RT].Produced);
end;


function TKMHandStats.GetChartWares(aWare: TKMWareType): TKMCardinalArray;
var
  RT: TKMWareType;
  I: Integer;
begin
  case aWare of
    WARE_MIN..WARE_MAX: Result := fChartWares[aWare];
    wt_All:             begin
                          //Create new array and fill it (otherwise we assign pointers and corrupt data)
                          SetLength(Result, fChartCount);
                          for I := 0 to fChartCount - 1 do
                            Result[I] := 0;
                          for RT := WARE_MIN to WARE_MAX do
                          for I := 0 to fChartCount - 1 do
                            Result[I] := Result[I] + fChartWares[RT][I];
                        end;
    wt_Warfare:         begin
                          //Create new array and fill it (otherwise we assign pointers and corrupt data)
                          SetLength(Result, fChartCount);
                          for I := 0 to fChartCount - 1 do
                            Result[I] := 0;
                          for RT := WARFARE_MIN to WARFARE_MAX do
                          for I := 0 to fChartCount - 1 do
                            Result[I] := Result[I] + fChartWares[RT][I];
                        end;
    wt_Food:            begin
                          //Create new array and fill it (otherwise we assign pointers and corrupt data)
                          SetLength(Result, fChartCount);
                          for I := 0 to fChartCount - 1 do
                            Result[I] := fChartWares[wt_Bread][I] + fChartWares[wt_Sausages][I] + fChartWares[wt_Wine][I] + fChartWares[wt_Fish][I];
                        end;
    else                begin
                          //Return empty array
                          SetLength(Result, fChartCount);
                          for I := 0 to fChartCount - 1 do
                            Result[I] := 0;
                        end;
  end;
end;


function TKMHandStats.GetChartArmy(aChartKind: TKMChartArmyKind; aWarrior: TKMUnitType): TKMCardinalArray;
var
  WT: TKMUnitType;
  I: Integer;
begin
  case aWarrior of
    WARRIOR_MIN..WARRIOR_MAX: Result := fChartArmy[aChartKind,aWarrior];
    ut_Any:                   begin
                                //Create new array and fill it (otherwise we assign pointers and corrupt data)
                                SetLength(Result, fChartCount);
                                for I := 0 to fChartCount - 1 do
                                  Result[I] := 0;
                                for WT := WARRIOR_MIN to WARRIOR_MAX do
                                  for I := 0 to fChartCount - 1 do
                                    Result[I] := Result[I] + fChartArmy[aChartKind,WT,I];
                              end;
    else                      begin
                                //Return empty array
                                SetLength(Result, fChartCount);
                                for I := 0 to fChartCount - 1 do
                                  Result[I] := 0;
                              end;
  end;
end;


function TKMHandStats.ChartWaresEmpty(aWare: TKMWareType): Boolean;
var
  RT: TKMWareType;
begin
  case aWare of
    WARE_MIN..WARE_MAX: Result := (fChartCount = 0) or (ChartWares[aWare][fChartCount-1] = 0);
    wt_All:             begin
                          Result := True;
                          if fChartCount > 0 then
                            for RT := WARE_MIN to WARE_MAX do
                              if ChartWares[RT][fChartCount-1] <> 0 then
                                Result := False;
                        end;
    wt_Warfare:         begin
                          Result := True;
                          if fChartCount > 0 then
                            for RT := WARFARE_MIN to WARFARE_MAX do
                              if ChartWares[RT][fChartCount-1] <> 0 then
                                Result := False;
                        end;
    wt_Food:            Result := (fChartCount = 0) or
                                  (ChartWares[wt_Wine][fChartCount-1] +
                                   ChartWares[wt_Bread][fChartCount-1] +
                                   ChartWares[wt_Sausages][fChartCount-1] +
                                   ChartWares[wt_Fish][fChartCount-1] = 0);
    else                Result := True;
  end;
end;


function GetArmyEmptyCKind(aChartKind: TKMChartArmyKind): TKMChartArmyKind;
begin
  //Total and Instantaneous are always empty at the same time, so we can use only one of them
  //Important is that Total will be not empty even after game load, but instantenious could be empty after load.
  //That is why we can omit saving fArmyEmpty array, and need to use Total instead of Instantenious for fArmyEmpty
  if aChartKind = cak_Instantaneous then
    Result := cak_Total
  else
    Result := aChartKind;
end;


function TKMHandStats.ChartArmyEmpty(aChartKind: TKMChartArmyKind; aWarrior: TKMUnitType): Boolean;
var
  WT: TKMUnitType;
  CKind: TKMChartArmyKind;
begin
  CKind := GetArmyEmptyCKind(aChartKind);
  case aWarrior of
    WARRIOR_MIN..WARRIOR_MAX:
                        Result := (fChartCount = 0) or (fArmyEmpty[CKind,aWarrior]);
    ut_Any:             begin
                          Result := True;
                          if fChartCount > 0 then
                            for WT := WARRIOR_MIN to WARRIOR_MAX do
                              if not fArmyEmpty[CKind,WT] then
                              begin
                                Result := False;
                                Break;
                              end;
                        end;
    else                Result := True;
  end;
end;


procedure TKMHandStats.Save(SaveStream: TKMemoryStream);
var
  R: TKMWareType;
  W: TKMUnitType;
  CKind: TKMChartArmyKind;
begin
  SaveStream.WriteA('PlayerStats');
  SaveStream.Write(Houses, SizeOf(Houses));
  SaveStream.Write(Units, SizeOf(Units));
  SaveStream.Write(Wares, SizeOf(Wares));
  SaveStream.Write(MilitiaTrainedInTownHall);
  fWareDistribution.Save(SaveStream);

  SaveStream.Write(fChartCount);
  if fChartCount <> 0 then
  begin
    SaveStream.Write(fChartHouses[0], SizeOf(fChartHouses[0]) * fChartCount);
    SaveStream.Write(fChartCitizens[0], SizeOf(fChartCitizens[0]) * fChartCount);

    for R := WARE_MIN to WARE_MAX do
      SaveStream.Write(fChartWares[R][0], SizeOf(fChartWares[R][0]) * fChartCount);

    for CKind := Low(TKMChartArmyKind) to High(TKMChartArmyKind) do
      for W := WARRIOR_MIN to WARRIOR_MAX do
        SaveStream.Write(fChartArmy[CKind,W,0], SizeOf(fChartArmy[CKind,W,0]) * fChartCount);
  end;
end;


procedure TKMHandStats.Load(LoadStream: TKMemoryStream);
var
  I: TKMWareType;
  W: TKMUnitType;
  CKind: TKMChartArmyKind;
begin
  LoadStream.ReadAssert('PlayerStats');
  LoadStream.Read(Houses, SizeOf(Houses));
  LoadStream.Read(Units, SizeOf(Units));
  LoadStream.Read(Wares, SizeOf(Wares));
  LoadStream.Read(MilitiaTrainedInTownHall);
  fWareDistribution.Load(LoadStream);

  LoadStream.Read(fChartCount);
  if fChartCount <> 0 then
  begin
    fChartCapacity := fChartCount;
    SetLength(fChartHouses, fChartCount);
    SetLength(fChartCitizens, fChartCount);
    LoadStream.Read(fChartHouses[0], SizeOf(fChartHouses[0]) * fChartCount);
    LoadStream.Read(fChartCitizens[0], SizeOf(fChartCitizens[0]) * fChartCount);
    for I := WARE_MIN to WARE_MAX do
    begin
      SetLength(fChartWares[I], fChartCount);
      LoadStream.Read(fChartWares[I][0], SizeOf(fChartWares[I][0]) * fChartCount);
    end;
    for CKind := Low(TKMChartArmyKind) to High(TKMChartArmyKind) do
      for W := WARRIOR_MIN to WARRIOR_MAX do
      begin
        SetLength(fChartArmy[CKind,W], fChartCount);
        LoadStream.Read(fChartArmy[CKind,W,0], SizeOf(fChartArmy[CKind,W,0]) * fChartCount);
      end;
  end;
end;


function TKMHandStats.GetArmyChartValue(aChartKind: TKMChartArmyKind; aUnitType: TKMUnitType): Integer;
begin
  case aChartKind of
    cak_Instantaneous:  Result := GetUnitQty(aUnitType);
    cak_Total:          Result := GetWarriorsTotal(aUnitType);
    cak_Defeated:       Result := GetUnitKilledQty(aUnitType);
    cak_Lost:           Result := GetUnitLostQty(aUnitType);
    else                raise Exception.Create('Unknowkn chart army kind');
  end;
end;


procedure TKMHandStats.UpdateState;
var
  I: TKMWareType;
  W: TKMUnitType;
  ArmyQty: Integer;
  CKind, ArmyEmptyCKind: TKMChartArmyKind;
begin
  //Store player stats in Chart

  //Grow the list
  if fChartCount >= fChartCapacity then
  begin
    fChartCapacity := fChartCount + 32;
    SetLength(fChartHouses, fChartCapacity);
    SetLength(fChartCitizens, fChartCapacity);
    for I := WARE_MIN to WARE_MAX do
      SetLength(fChartWares[I], fChartCapacity);
    for CKind := Low(TKMChartArmyKind) to High(TKMChartArmyKind) do
      for W := WARRIOR_MIN to WARRIOR_MAX do
        SetLength(fChartArmy[CKind,W], fChartCapacity);
  end;
  fChartHouses[fChartCount] := GetHouseQty(htAny);
  //We don't want recruits on the citizens Chart on the results screen.
  //If we include recruits the citizens Chart drops by 50-100 at peacetime because all the recruits
  //become soldiers, and continually fluctuates. Recruits dominate the Chart, meaning you can't use
  //it for the intended purpose of looking at your villagers. The army Chart already indicates when
  //you trained soldiers, no need to see big variations in the citizens Chart because of recruits.
  fChartCitizens[fChartCount] := GetCitizensCount - GetUnitQty(ut_Recruit);

  for I := WARE_MIN to WARE_MAX do
    fChartWares[I, fChartCount] := Wares[I].Produced;

  for CKind := Low(TKMChartArmyKind) to High(TKMChartArmyKind) do
    for W := WARRIOR_MIN to WARRIOR_MAX do
    begin
      ArmyQty := GetArmyChartValue(CKind,W);
      fChartArmy[CKind, W, fChartCount] := ArmyQty;
      // for Army empty we use special CKind, because Total equipped and Instantenious are empty simultaneously
      ArmyEmptyCKind := GetArmyEmptyCKind(CKind);
      if (fArmyEmpty[ArmyEmptyCKind,W] and (ArmyQty > 0)) then
        fArmyEmpty[ArmyEmptyCKind,W] := False;
    end;

  Inc(fChartCount);
end;


end.
