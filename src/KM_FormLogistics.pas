unit KM_FormLogistics;

interface
uses
  {$IFDEF FPC} LResources, {$ENDIF}
  {$IFDEF MSWindows} Windows, Messages, {$ENDIF}
  {$IFDEF Unix} LCLIntf, LCLType, {$ENDIF}
  SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, ComCtrls;

type
  TFormLogistics = class(TForm)
    ListView: TListView;
  private

  public

  end;

var
  FormLogistics: TFormLogistics;

implementation
{$IFDEF WDC}
  {$R *.dfm}
{$ENDIF}

uses KM_HandLogistics;

{$IFDEF FPC}
initialization
{$I KM_FormLogistics.lrs}
{$ENDIF}

end.
