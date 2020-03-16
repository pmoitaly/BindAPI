unit Test.Controller;

interface

uses
  System.Classes, System.RTTI, plBindAPI.ClassFactory;

type

  TFieldObject = class
  private
    FInt: Integer;
    FStr: string;
  public
    property IntProp: Integer read FInt write FInt;
    property StrProp: string read FStr write FStr;
  end;

  TTestController = class(TInterfacedObject)
    function DoubleOf(const NewValue, OldValue: TValue): TValue;
    procedure TestEventBind(Sender: TObject);
  private
    FCurrentText: string;
    FDoubleValue: integer;
    FLowerText: string;
    FNewValue: integer;
    FTestObject: TFieldObject;
    FUpperText: string;
    procedure SetCurrentText(const Value: string);
  public
    constructor Create;
    destructor Destroy; override;
    property CurrentText: string read FCurrentText write SetCurrentText;
    property UpperText: string read FUpperText write FUpperText;
    property LowerText: string read FLowerText write FLowerText;
    property NewValue: integer read FNewValue write FNewValue;
    property DoubleValue: integer read FDoubleValue write FDoubleValue;
    property TestObject: TFieldObject read FTestObject write FTestObject;
  end;
implementation

uses
  System.SysUtils, Vcl.Dialogs;

{ TTestController }

constructor TTestController.Create;
begin
  inherited;
  FTestObject := TFieldObject.Create;
end;

destructor TTestController.Destroy;
begin
  TestObject.Free;
  inherited;
end;

function TTestController.DoubleOf(const NewValue, OldValue: TValue): TValue;
begin
  Result := NewValue.AsInteger * 2;
end;

procedure TTestController.SetCurrentText(const Value: string);
begin
  FCurrentText := Value;
  FLowerText := AnsiLowerCase(Value);
  FUpperText := AnsiUpperCase(Value);
end;

procedure TTestController.TestEventBind(Sender: TObject);
begin
  FLowerText := '';
  FUpperText := '';
  ShowMessage('Done.');
end;

initialization
  TplClassManager.RegisterClass(TTestController, true);

end.
