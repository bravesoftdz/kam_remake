program RXXEditor;
{$I ..\..\KaM_Remake.inc}
uses
  Forms, Interfaces,
  RXXEditorForm in 'RXXEditorForm.pas' {RXXForm1},
  KM_Log in '..\..\src\KM_Log.pas',
  KM_PNG in '..\..\src\utils\KM_PNG.pas',
  KM_Pics in '..\..\src\utils\KM_Pics.pas',
  KM_Resource in '..\..\src\res\KM_Resource.pas',
  KM_ResCursors in '..\..\src\res\KM_ResCursors.pas',
  KM_ResFonts in '..\..\src\res\KM_ResFonts.pas',
  KM_ResHouses in '..\..\src\res\KM_ResHouses.pas',
  KM_ResKeys in '..\..\src\res\KM_ResKeys.pas',
  KM_ResLocales in '..\..\src\res\KM_ResLocales.pas',
  KM_ResMapElements in '..\..\src\res\KM_ResMapElements.pas',
  KM_ResPalettes in '..\..\src\res\KM_ResPalettes.pas',
  KM_ResSound in '..\..\src\res\KM_ResSound.pas',
  KM_ResSprites in '..\..\src\res\KM_ResSprites.pas',
  KM_ResSpritesEdit in '..\..\src\res\KM_ResSpritesEdit.pas',
  KM_ResTexts in '..\..\src\res\KM_ResTexts.pas',
  KM_ResTileset in '..\..\src\res\KM_ResTileset.pas',
  KM_ResUnits in '..\..\src\res\KM_ResUnits.pas',
  KM_ResWares in '..\..\src\res\KM_ResWares.pas',
  KM_Defaults in '..\..\src\common\KM_Defaults.pas',
  KM_CommonTypes in '..\..\src\common\KM_CommonTypes.pas',
  KM_CommonClasses in '..\..\src\common\KM_CommonClasses.pas',
  KM_CommonUtils in '..\..\src\utils\KM_CommonUtils.pas',
  KM_Points in '..\..\src\common\KM_Points.pas',
  KM_FileIO in '..\..\src\utils\KM_FileIO.pas',
  KM_Outline in '..\..\src\navmesh\KM_Outline.pas',
  KM_PolySimplify in '..\..\src\navmesh\KM_PolySimplify.pas',
  KM_Render in '..\..\src\render\KM_Render.pas',
  KM_RenderControl in '..\..\src\render\KM_RenderControl.pas',
  KM_BinPacking in '..\..\src\utils\KM_BinPacking.pas';

{$IFDEF WDC}
{$R *.res}
{$ENDIF}


begin
  Application.Initialize;
  Application.CreateForm(TRXXForm1, RXXForm1);
  Application.Run;
end.
