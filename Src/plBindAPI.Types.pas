unit plBindAPI.Types;

interface

uses
  System.Rtti;

type


{$REGION 'Methods'}
  TplBridgeFunction = function(const NewValue, OldValue: TValue): TValue of object;
{$ENDREGION}
{$REGION 'Interfaces'}
  IplAutoBinder = interface
    ['{64BF1986-35A2-48D4-9558-2EBDB345EFEB}']
    procedure Bind(ASource: TObject; const APropertySource: string; ATarget: TObject; const APropertyTarget: string; AFunction: TplBridgeFunction = nil);
    procedure BindObject(ASource, aTarget: TObject);
    function Count: integer;
    procedure Start(const SleepInterval: Integer);
    procedure Stop;
    procedure UnbindSource(ASource: TObject);
    procedure UnbindTarget(ATarget: TObject);
    procedure UpdateValues;
  end;
{$ENDREGION}

implementation

end.
