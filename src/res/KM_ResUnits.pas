unit KM_ResUnits;
{$I KaM_Remake.inc}
interface
uses
  Classes, SysUtils,
  KM_CommonClasses, KM_CommonTypes, KM_Defaults, KM_Points,
  KM_ResWares;


//Used to separate close-combat units from archers (they use different fighting logic)
type
  TFightType = (ft_Melee, ft_Ranged);

  TKMUnitDat = packed record
    HitPoints, Attack, AttackHorse, x4, Defence, Speed, x7, Sight: SmallInt;
    x9, x10: ShortInt;
    CanWalkOut, x11: SmallInt;
  end;

  TKMUnitSprite = packed record
    Act: array [TKMUnitActionType] of packed record
      Dir: array [dir_N..dir_NW] of TKMAnimLoop;
    end;
  end;

  TKMUnitSprite2 = array [1..18] of SmallInt; //Sound indices vs sprite ID

  TKMUnitSpec = class
  private
    fUnitType: TKMUnitType;
    fUnitDat: TKMUnitDat;
    fUnitSprite: TKMUnitSprite;
    fUnitSprite2: TKMUnitSprite2;
    function GetAllowedPassability: TKMTerrainPassability;
    function GetDescription: UnicodeString;
    function GetDesiredPassability: TKMTerrainPassability;
    function GetFightType: TFightType;
    function GetGUIIcon: Word;
    function GetGUIScroll: Word;
    function GetMinimapColor: Cardinal;
    function GetMiningRange: Byte;
    function GetSpeed: Single;
    function GetUnitAnim(aAction: TKMUnitActionType; aDir: TKMDirection): TKMAnimLoop;
    function GetUnitTextID: Integer;
    function GetUnitName: UnicodeString;
  public
    constructor Create(aType: TKMUnitType);
    function IsValid: Boolean;
    function IsAnimal: Boolean;
    function IsCitizen: Boolean;
    function IsWarrior: Boolean;
    function IsWarriorEquipable: Boolean;
    function GetDefenceVsProjectiles(aIsBolt: Boolean): Single;
    procedure LoadFromStream(Stream: TMemoryStream);
    //Derived from KaM
    property HitPoints:smallint read fUnitDat.HitPoints;
    property Attack:smallint read fUnitDat.Attack;
    property AttackHorse:smallint read fUnitDat.AttackHorse;
    property Defence:smallint read fUnitDat.Defence;
    property Description: UnicodeString read GetDescription;
    property Sight:smallint read fUnitDat.Sight;
    //Additional properties added by Remake
    property AllowedPassability:TKMTerrainPassability read GetAllowedPassability;
    property DesiredPassability:TKMTerrainPassability read GetDesiredPassability;
    property FightType:TFightType read GetFightType;
    property GUIIcon:word read GetGUIIcon;
    property GUIScroll:word read GetGUIScroll;
    property MinimapColor: Cardinal read GetMinimapColor;
    property MiningRange:byte read GetMiningRange;
    property Speed:single read GetSpeed;
    function SupportsAction(aAct: TKMUnitActionType):boolean;
    property UnitAnim[aAction:TKMUnitActionType; aDir:TKMDirection]: TKMAnimLoop read GetUnitAnim;
    property GUIName: UnicodeString read GetUnitName;
    property GUITextID: Integer read GetUnitTextID;
  end;


  TKMResUnits = class
  private
    fCRC: Cardinal;
    fItems: array [TKMUnitType] of TKMUnitSpec;
    fSerfCarry: array [WARE_MIN..WARE_MAX, dir_N..dir_NW] of TKMAnimLoop;
    function LoadUnitsDat(const aPath: UnicodeString): Cardinal;
    function GetItem(aType: TKMUnitType): TKMUnitSpec; inline;
    function GetSerfCarry(aType: TKMWareType; aDir: TKMDirection): TKMAnimLoop;
  public
    constructor Create;
    destructor Destroy; override;

    property Items[aType: TKMUnitType]: TKMUnitSpec read GetItem; default;
    property SerfCarry[aType: TKMWareType; aDir: TKMDirection]: TKMAnimLoop read GetSerfCarry;
    property CRC: Cardinal read fCRC; //Return hash of all values

    procedure ExportCSV(const aPath: UnicodeString);
  end;

const
  //This is a map of the valid values for !SET_UNIT,
  //TSK did not had place for new warriors that were inserted in the middle(!)
  UnitOldIndexToType: array[0..31] of TKMUnitType = (
    ut_Serf,ut_Woodcutter,ut_Miner,ut_AnimalBreeder,ut_Farmer,
    ut_Lamberjack,ut_Baker,ut_Butcher,ut_Fisher,ut_Worker,
    ut_StoneCutter,ut_Smith,ut_Metallurgist,ut_Recruit, //Units
    ut_Militia,ut_AxeFighter,ut_Swordsman,ut_Bowman,ut_Arbaletman,
    ut_Pikeman,ut_Hallebardman,ut_HorseScout,ut_Cavalry,ut_Barbarian, //Troops
    ut_Wolf,ut_Fish,ut_Watersnake,ut_Seastar,ut_Crab,
    ut_Waterflower,ut_Waterleaf,ut_Duck); //Animals

  //and the corresponing unit that will be created (matches KaM behavior)
  UnitTypeToOldIndex: array[TKMUnitType] of integer = (
  -1, -1, //ut_None, ut_Any
  0,1,2,3,4,5,6,7,8,9,10,11,12,13, //Citizens
  14,15,16,17,18,19,20,21,22,23, //Warriors
  -1,-1,-1,-1, {-1,-1,} //TPR warriors (can't be placed with SET_UNIT)
  24,25,26,27,28,29,30,31); //Animals

  //This is a map of the valid values for !SET_GROUP, and the corresponing unit that will be created (matches KaM behavior)
  UnitIndexToType: array[0..40] of TKMUnitType = (
    ut_Serf,ut_Woodcutter,ut_Miner,ut_AnimalBreeder,ut_Farmer,
    ut_Lamberjack,ut_Baker,ut_Butcher,ut_Fisher,ut_Worker,
    ut_StoneCutter,ut_Smith,ut_Metallurgist,ut_Recruit, //Units
    ut_Militia,ut_AxeFighter,ut_Swordsman,ut_Bowman,ut_Arbaletman,
    ut_Pikeman,ut_Hallebardman,ut_HorseScout,ut_Cavalry,ut_Barbarian, //TSK Troops
    ut_Peasant,ut_Slingshot,ut_MetalBarbarian,ut_Horseman,
    {ut_Catapult,ut_Ballista}ut_None,ut_None, //Placeholder for Seige weapons
    ut_Wolf, ut_Fish, ut_Watersnake, ut_Seastar, ut_Crab,
    ut_Waterflower, ut_Waterleaf, ut_Duck,
    ut_None, ut_None, ut_None
    );

  UnitTypeToIndex: array[TKMUnitType] of ShortInt = (
  -1, -1, //ut_None, ut_Any
  0,1,2,3,4,5,6,7,8,9,10,11,12,13, //Citizens
  14,15,16,17,18,19,20,21,22,23, //Warriors
  24,25,26,27, {28,29,} //TPR warriors
  30,31,32,33,34,35,36,37); //Animals


  //Number means ResourceType as it is stored in Barracks, hence it's not rt_Something
  TroopCost: array [ut_Militia..ut_Cavalry, 1..4] of TKMWareType = (
    (wt_Axe,          wt_None,        wt_None,  wt_None ), //Militia
    (wt_Shield,       wt_Armor,       wt_Axe,   wt_None ), //Axefighter
    (wt_MetalShield,  wt_MetalArmor,  wt_Sword, wt_None ), //Swordfighter
    (wt_Armor,        wt_Bow,         wt_None,  wt_None ), //Bowman
    (wt_MetalArmor,   wt_Arbalet,     wt_None,  wt_None ), //Crossbowman
    (wt_Armor,        wt_Pike,        wt_None,  wt_None ), //Lance Carrier
    (wt_MetalArmor,   wt_Hallebard,   wt_None,  wt_None ), //Pikeman
    (wt_Shield,       wt_Armor,       wt_Axe,   wt_Horse), //Scout
    (wt_MetalShield,  wt_MetalArmor,  wt_Sword, wt_Horse)  //Knight
  );

  //TownHall units troops cost (number of gold chests needed)
  TH_TroopCost: array[0..5] of Byte = (
    3, 3, 3, 5, 10, 10
  );

  //The frame shown when a unit is standing still in ua_Walk. Same for all units!
  UnitStillFrames: array [TKMDirection] of Byte = (0,3,2,2,1,6,7,6,6);


implementation
uses
  KromUtils, KM_ResTexts;


{ TKMUnitsDatClass }
constructor TKMUnitSpec.Create(aType: TKMUnitType);
begin
  inherited Create;
  fUnitType := aType;
end;


function TKMUnitSpec.IsValid: boolean;
begin
  Result := not (fUnitType in [ut_None, ut_Any]);
end;


function TKMUnitSpec.IsAnimal: boolean;
begin
  Result := fUnitType in [ANIMAL_MIN..ANIMAL_MAX];
end;


function TKMUnitSpec.IsCitizen: boolean;
begin
  Result := fUnitType in [CITIZEN_MIN..CITIZEN_MAX];
end;


function TKMUnitSpec.IsWarrior: boolean;
begin
  Result := fUnitType in [WARRIOR_MIN..WARRIOR_MAX];
end;


function TKMUnitSpec.IsWarriorEquipable: boolean;
begin
  Result := fUnitType in [WARRIOR_EQUIPABLE_MIN..WARRIOR_EQUIPABLE_MAX];
end;


function TKMUnitSpec.GetDefenceVsProjectiles(aIsBolt: Boolean): Single;
begin
  Result := Defence;
  //Shielded units get a small bonus
  if fUnitType in [ut_AxeFighter, ut_Swordsman, ut_HorseScout, ut_Cavalry] then
    if aIsBolt then
      Result := Result + 0.25
    else
      Result := Result + 1;
end;


procedure TKMUnitSpec.LoadFromStream(Stream: TMemoryStream);
begin
  Stream.Read(fUnitDat, SizeOf(TKMUnitDat));
  Stream.Read(fUnitSprite, SizeOf(TKMUnitSprite));
  Stream.Read(fUnitSprite2, SizeOf(TKMUnitSprite2));
end;


function TKMUnitSpec.SupportsAction(aAct: TKMUnitActionType): Boolean;
const UnitSupportedActions: array [TKMUnitType] of TKMUnitActionTypeSet = (
    [], [], //None, Any
    [ua_Walk, ua_Die, ua_Eat, ua_WalkArm], //Serf
    [ua_Walk, ua_Work, ua_Die, ua_Work1, ua_Eat..ua_WalkTool2],
    [ua_Walk, ua_Die, ua_Eat],
    [ua_Walk, ua_Die, ua_Eat],
    [ua_Walk, ua_Work, ua_Die..ua_WalkBooty2],
    [ua_Walk, ua_Die, ua_Eat],
    [ua_Walk, ua_Die, ua_Eat],
    [ua_Walk, ua_Die, ua_Eat],
    [ua_Walk, ua_Work, ua_Die, ua_Work1..ua_WalkBooty],
    [ua_Walk, ua_Work, ua_Die, ua_Eat, ua_Work1, ua_Work2],
    [ua_Walk, ua_Work, ua_Die, ua_Work1, ua_Eat..ua_WalkBooty],
    [ua_Walk, ua_Die, ua_Eat],
    [ua_Walk, ua_Die, ua_Eat],
    [ua_Walk, ua_Spec, ua_Die, ua_Eat], //Recruit
    [ua_Walk, ua_Work, ua_Spec, ua_Die, ua_Eat], //Militia
    [ua_Walk, ua_Work, ua_Spec, ua_Die, ua_Eat], //Axeman
    [ua_Walk, ua_Work, ua_Spec, ua_Die, ua_Eat], //Swordsman
    [ua_Walk, ua_Work, ua_Spec, ua_Die, ua_Eat], //Bowman
    [ua_Walk, ua_Work, ua_Spec, ua_Die, ua_Eat], //Crossbowman
    [ua_Walk, ua_Work, ua_Die, ua_Eat],
    [ua_Walk, ua_Work, ua_Die, ua_Eat],
    [ua_Walk, ua_Work, ua_Die, ua_Eat],
    [ua_Walk, ua_Work, ua_Die, ua_Eat], //Cavalry
    [ua_Walk, ua_Work, ua_Spec, ua_Die, ua_Eat], //Barbarian
    [ua_Walk, ua_Work, ua_Die, ua_Eat], //Rebel
    [ua_Walk, ua_Work, ua_Spec, ua_Die, ua_Eat], //Slingshot
    [ua_Walk, ua_Work, ua_Spec, ua_Die, ua_Eat], //Warrior
    [ua_Walk, ua_Work, ua_Die, ua_Eat],
    [ua_Walk], [ua_Walk], [ua_Walk], [ua_Walk], [ua_Walk], [ua_Walk], [ua_Walk], [ua_Walk]); //Animals
begin
  Result := aAct in UnitSupportedActions[fUnitType];
end;


function TKMUnitSpec.GetAllowedPassability: TKMTerrainPassability;
//Defines which animal prefers which terrain
const AnimalTerrain: array[ANIMAL_MIN .. ANIMAL_MAX] of TKMTerrainPassability = (
    tpWolf, tpFish, tpFish, tpFish, tpCrab, tpFish, tpFish, tpFish);
begin
  case fUnitType of
    ANIMAL_MIN..ANIMAL_MAX:  Result := AnimalTerrain[fUnitType]; //Animals
    else                     Result := tpWalk; //Worker, Warriors
  end;
end;


//Where unit would like to be
function TKMUnitSpec.GetDesiredPassability: TKMTerrainPassability;
begin
  if fUnitType in [CITIZEN_MIN..CITIZEN_MAX] - [ut_Worker] then
    Result := tpWalkRoad //Citizens except Worker
  else
    Result := GetAllowedPassability; //Workers, warriors, animals
end;


function TKMUnitSpec.GetFightType: TFightType;
const WarriorFightType: array[WARRIOR_MIN..WARRIOR_MAX] of TFightType = (
    ft_Melee,ft_Melee,ft_Melee, //Militia, AxeFighter, Swordsman
    ft_Ranged,ft_Ranged,        //Bowman, Arbaletman
    ft_Melee,ft_Melee,          //Pikeman, Hallebardman,
    ft_Melee,ft_Melee,          //HorseScout, Cavalry,
    ft_Melee,                   //Barbarian
    ft_Melee,                   //Peasant
    ft_Ranged,                  //ut_Slingshot
    ft_Melee,                   //ut_MetalBarbarian
    ft_Melee                    //ut_Horseman
    {ft_Ranged,ft_Ranged,       //ut_Catapult, ut_Ballista,}
    );
begin
  Assert(fUnitType in [Low(WarriorFightType)..High(WarriorFightType)]);
  Result := WarriorFightType[fUnitType];
end;


function TKMUnitSpec.GetGUIIcon: Word;
begin
  case fUnitType of
    ut_None, ut_Any:  Result := 0;
    ut_Barbarian:     Result := 70;
  else
    if IsCitizen then
      Result := 141 + UnitTypeToIndex[fUnitType]
    else if IsWarriorEquipable then
      Result := 47 + UnitTypeToIndex[fUnitType]
    else if IsWarrior then
      Result := 55 + UnitTypeToIndex[fUnitType]
    else
      Result := 0;
  end;
end;


function TKMUnitSpec.GetGUIScroll: Word;
begin
  if IsValid then
    Result := 521 + UnitTypeToIndex[fUnitType]
  else
    Result := 0;
end;


//Units are rendered on minimap with their team color
//Animals don't have team and thus are rendered in their own prefered clors
function TKMUnitSpec.GetMinimapColor: Cardinal;
const
  MMColor:array[TKMUnitType] of Cardinal = (
    0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,
    0,0,0,0,0,0,0,0,0,0,
    $B0B0B0,$B08000,$B08000,$80B0B0,$00B0B0,$B080B0,$00B000,$80B0B0); //Exact colors can be tweaked
begin
  Result := MMColor[fUnitType] or $FF000000;
end;


//Unit mining ranges. (measured from KaM)
function TKMUnitSpec.GetMiningRange: byte;
begin
  case fUnitType of
    ut_Woodcutter:  Result := 10;
    ut_Farmer:      Result := 10;
    ut_Stonecutter: Result := 16;
    ut_Fisher:      Result := 14;
    else            raise Exception.Create(GUIName + ' has no mining range');
  end;
end;


function TKMUnitSpec.GetSpeed: single;
begin
  Result := fUnitDat.Speed / 240;
end;


function TKMUnitSpec.GetUnitAnim(aAction: TKMUnitActionType; aDir: TKMDirection): TKMAnimLoop;
begin
  Assert(aDir <> dir_NA);
  Assert(aAction in [Low(TKMUnitActionType)..High(TKMUnitActionType)]);
  Result := fUnitSprite.Act[aAction].Dir[aDir];
end;


function TKMUnitSpec.GetUnitTextID: Integer;
begin
  if IsValid then
    case fUnitType of
      ut_Wolf:        Result := TX_UNITS_WOLF;
      ut_Fish:        Result := TX_UNITS_FISH;
      ut_Watersnake:  Result := TX_UNITS_WATERSNAKE;
      ut_Seastar:     Result := TX_UNITS_SEASTAR;
      ut_Crab:        Result := TX_UNITS_CRAB;
      ut_Waterflower: Result := TX_UNITS_WATERFLOWER;
      ut_Waterleaf:   Result := TX_UNITS_WATERLEAF;
      ut_Duck:        Result := TX_UNITS_DUCK;
      else            Result := TX_UNITS_NAMES__29 + UnitTypeToIndex[fUnitType];
    end
  else
    Result := -1;
end;


function TKMUnitSpec.GetUnitName: UnicodeString;
begin
  case fUnitType of
    ut_Any:             Result := gResTexts[TX_UNITS_ALL];
    ut_None:            Result := 'N/A';
    else                Result := gResTexts[GetUnitTextID];
  end;
end;


function TKMUnitSpec.GetDescription: UnicodeString;
begin
  if IsValid and not IsAnimal then
    Result := gResTexts[TX_UNITS_DESCRIPTIONS__13 + UnitTypeToIndex[fUnitType]]
  else
    Result := 'N/A';
end;


{ TKMUnitsDatCollection }
constructor TKMResUnits.Create;
var
  U: TKMUnitType;
begin
  inherited;

  for U := Low(TKMUnitType) to High(TKMUnitType) do
    fItems[U] := TKMUnitSpec.Create(U);

  fCRC := LoadUnitsDat(ExeDir+'data' + PathDelim + 'defines' + PathDelim + 'unit.dat');
  fItems[ut_HorseScout].fUnitDat.Sight := 16;
  fItems[ut_Horseman].fUnitDat.Attack := 35;
  fItems[ut_Peasant].fUnitDat.AttackHorse := 55;
  //ExportCSV(ExeDir+'units.csv');
end;


destructor TKMResUnits.Destroy;
var U:TKMUnitType;
begin
  for U := Low(TKMUnitType) to High(TKMUnitType) do
    fItems[U].Free;

  inherited;
end;


procedure TKMResUnits.ExportCSV(const aPath: UnicodeString);
var ft:textfile; ii:TKMUnitType;
begin
    AssignFile(ft,aPath); rewrite(ft);
    writeln(ft,'Name;HitPoints;Attack;AttackHorse;Defence;Speed;Sight;');
    for ii:=Low(TKMUnitType) to High(TKMUnitType) do
    if Items[ii].IsValid then
    begin
      write(ft,Items[ii].GUIName+';');
      write(ft,inttostr(Items[ii].HitPoints)+';');
      write(ft,inttostr(Items[ii].Attack)+';');
      write(ft,inttostr(Items[ii].AttackHorse)+';');
      //write(ft,inttostr(Items[ii].x4)+';');
      write(ft,inttostr(Items[ii].Defence)+';');
      write(ft,floattostr(Items[ii].Speed)+';');
      //write(ft,inttostr(Items[ii].x7)+';');
      write(ft,inttostr(Items[ii].Sight)+';');
      //write(ft,inttostr(Items[ii].x9)+';');
      //write(ft,inttostr(Items[ii].x10)+';');
      //write(ft,inttostr(Items[ii].CanWalkOut)+';');
      //write(ft,inttostr(Items[ii].x11)+';');
      //for kk:=1 to 18 do
      //  write(ft,inttostr(UnitSprite2[ii,kk])+';');
      writeln(ft);
    end;
    closefile(ft);

    {AssignFile(ft,ExeDir+'Units.txt'); rewrite(ft);
    for ii:=Low(TKMUnitType) to High(TKMUnitType) do
    if UnitsDat[ii].IsValid then
    begin
      writeln(ft);
      writeln(ft);
      writeln(ft,'NewUnit'+inttostr(ii));
      for kk:=1 to 14 do
      for hh:=1 to 8 do
      //  if UnitSprite[ii].Act[kk].Dir[hh].Step[1]>0 then
          begin
            write(ft,inttostr(kk)+'.'+inttostr(hh)+#9);
            for jj:=1 to 30 do
            if UnitSprite[ii].Act[kk].Dir[hh].Step[jj]>0 then //write(ft,'#');
            write(ft,inttostr(UnitSprite[ii].Act[kk].Dir[hh].Step[jj])+'. ');
            write(ft,inttostr(UnitSprite[ii].Act[kk].Dir[hh].Count)+' ');
            write(ft,inttostr(UnitSprite[ii].Act[kk].Dir[hh].MoveX)+' ');
            write(ft,inttostr(UnitSprite[ii].Act[kk].Dir[hh].MoveY)+' ');
            writeln(ft);
          end;
    end;
    closefile(ft);}
end;


function TKMResUnits.GetSerfCarry(aType: TKMWareType; aDir: TKMDirection): TKMAnimLoop;
begin
  Assert(aType in [WARE_MIN .. WARE_MAX]);
  Result := fSerfCarry[aType, aDir];
end;


function TKMResUnits.GetItem(aType: TKMUnitType): TKMUnitSpec;
begin
  Result := fItems[aType];
end;


function TKMResUnits.LoadUnitsDat(const aPath: UnicodeString): Cardinal;
const UNIT_DAT_COUNT = 41;
var
  S: TKMemoryStream;
  I: Integer;
begin
  Assert(FileExists(aPath));

  S := TKMemoryStream.Create;
  try
    S.LoadFromFile(aPath);

    S.Read(fSerfCarry, SizeOf(fSerfCarry){28*8*70});

    for I := 0 to UNIT_DAT_COUNT - 1 do
    if UnitIndexToType[I] <> ut_None then
      fItems[UnitIndexToType[I]].LoadFromStream(S)
    else //Skip
      S.Seek(SizeOf(TKMUnitDat) + SizeOf(TKMUnitSprite) + SizeOf(TKMUnitSprite2), soFromCurrent);

    Result := Adler32CRC(S);
  finally
    S.Free;
  end;
end;


end.
