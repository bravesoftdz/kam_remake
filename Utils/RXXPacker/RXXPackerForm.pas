unit RXXPackerForm;
{$I ..\..\KaM_Remake.inc}
interface
uses
  Classes, Controls, Dialogs,
  ExtCtrls, Forms, Graphics, Spin, StdCtrls, SysUtils, TypInfo,
  {$IFDEF MSWindows} Windows, {$ENDIF}
  {$IFDEF FPC} LResources, LCLIntf, {$ENDIF}
  RXXPackerProc, KM_Defaults, KM_Log, KM_Pics, KM_ResPalettes, KM_ResSprites;

type
  TRXXForm1 = class(TForm)
    btnPackRXX: TButton;
    ListBox1: TListBox;
    Label1: TLabel;
    btnUpdateList: TButton;
    procedure btnPackRXXClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnUpdateListClick(Sender: TObject);
  private
    fPalettes: TKMResPalettes;
    fRxxPacker: TRXXPacker;
    procedure UpdateList;
  end;

  {$IFDEF FPC}
  TRXTypeRecord = record
    Id: Integer;
  end;
  PRXTypeRecord = ^TRXTypeRecord;
  {$ENDIF}

var
  RXXForm1: TRXXForm1;

implementation
{$R *.dfm}
uses KM_ResHouses, KM_ResUnits, KM_Points;


procedure TRXXForm1.UpdateList;
var
  RT: TRXType;
  {$IFDEF FPC}
  CurRTR: PRXTypeRecord;
  {$ENDIF}
begin
  ListBox1.Items.Clear;
  for RT := Low(TRXType) to High(TRXType) do
    if (RT = rxTiles) //Tiles are always in the list
      or FileExists(ExeDir + 'SpriteResource' + DirectorySeparator + RXInfo[RT].FileName + '.rx') then
      {$IFDEF WDC}
      ListBox1.Items.AddPair(GetEnumName(TypeInfo(TRXType), Integer(RT)), IntToStr(Integer(RT)));
      {$ENDIF}
      {$IFDEF FPC}
      begin
        New(CurRTR);
        CurRTR.Id := Integer(RT);
        ListBox1.Items.AddObject(GetEnumName(TypeInfo(TRXType), Integer(RT)), TObject(CurRTR));
      end;
      {$ENDIF}

  if ListBox1.Items.Count = 0 then
  begin
    ShowMessage('No .RX file was found in'+#10+ExeDir + 'SpriteResource' + DirectorySeparator);
    btnPackRXX.Enabled := false;
  end
  else
  begin
    btnPackRXX.Enabled := true;
    ListBox1.ItemIndex := 0;
    ListBox1.SelectAll;
  end;
end;


procedure TRXXForm1.btnUpdateListClick(Sender: TObject);
begin
  btnUpdateList.Enabled := false;

  UpdateList;

  btnUpdateList.Enabled := true;
end;

procedure TRXXForm1.FormCreate(Sender: TObject);
begin
  ExeDir := ExpandFileName(ExtractFilePath(ParamStr(0)) + '..' + DirectorySeparator + '..' + DirectorySeparator);

  Caption := 'RXX Packer (' + GAME_REVISION + ')';

  //Although we don't need them in this tool, these are required to load sprites
  gLog := TKMLog.Create(ExeDir + 'RXXPacker.log');

  fRXXPacker := TRXXPacker.Create;
  fPalettes  := TKMResPalettes.Create;
  fPalettes.LoadPalettes(ExeDir + 'data' + DirectorySeparator + 'gfx' + DirectorySeparator);

  UpdateList;
end;


procedure TRXXForm1.FormDestroy(Sender: TObject);
{$IFDEF WDC}
begin
{$ENDIF}
{$IFDEF FPC}
var
  I: Integer;
begin
  for I := 0 to ListBox1.Items.Count - 1 do
    Dispose(PRXTypeRecord(ListBox1.Items.Objects[I]));
{$ENDIF}
  FreeAndNil(fPalettes);
  FreeAndNil(gLog);
  FreeAndNil(fRXXPacker);
end;


procedure TRXXForm1.btnPackRXXClick(Sender: TObject);
var
  RT: TRXType;
  I,J: Integer;
  Tick: Cardinal;
begin
  btnPackRXX.Enabled := False;
  Tick := GetTickCount;

  Assert(DirectoryExists(ExeDir + 'SpriteResource' + DirectorySeparator),
         'Cannot find ' + ExeDir + 'SpriteResource' + DirectorySeparator + ' folder.'+#10#13+
         'Please make sure this folder exists.');

  for I := 0 to ListBox1.Items.Count - 1 do
    if ListBox1.Selected[I] then
    begin
      {$IFDEF WDC}
      J := StrToInt(ListBox1.Items.ValueFromIndex[I]);
      {$ENDIF}
      {$IFDEF FPC}
      J := PRXTypeRecord(ListBox1.Items.Objects[I]).Id;
      {$ENDIF}
      RT := TRXType(J);

      fRxxPacker.Pack(RT, fPalettes);

      ListBox1.Selected[I] := False;
      ListBox1.Update;
      ListBox1.Refresh;
    end;

  Label1.Caption := IntToStr(GetTickCount - Tick) + ' ms';
  btnPackRXX.Enabled := True;
end;


{$IFDEF FPC}
initialization
  {$i RXXPackerForm.lrs}
{$ENDIF}


end.
