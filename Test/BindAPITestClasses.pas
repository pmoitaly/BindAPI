{ **************************************************************************** }
{ BindAPI                                                                      }
{ Copyright (C) 2020 Paolo Morandotti                                          }
{ Unit BindAPITestClasses                                                      }
{ **************************************************************************** }
{                                                                              }
{ Permission is hereby granted, free of charge, to any person obtaining        }
{ a copy of this software and associated documentation files (the "Software"), }
{ to deal in the Software without restriction, including without limitation    }
{ the rights to use, copy, modify, merge, publish, distribute, sublicense,     }
{ and/or sell copies of the Software, and to permit persons to whom the        }
{ Software is furnished to do so, subject to the following conditions:         }
{                                                                              }
{ The above copyright notice and this permission notice shall be included in   }
{ all copies or substantial portions of the Software.                          }
{                                                                              }
{ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS      }
{ OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  }
{ FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE  }
{ AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER       }
{ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING      }
{ FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS }
{ IN THE SOFTWARE.                                                             }
{ **************************************************************************** }
unit BindAPITestClasses;

interface

uses
  Classes, RTTI,
  StdCtrls,
  plBindAPI.Attributes;

type
  TTestRecord = record
    Name: string;
    Age: Integer;
  end;

  TTestIndex = (tiFirst, tiSecond, tiThird);
  TTestIndexArray = array[tiFirst..tiThird] of integer;

  TInternalClass = class
  private
    FName: string;
    FAge: Integer;
    FStrings: TStrings;
    procedure GetStrings(const Value: TStrings);
    function GetNumbers(Index: TTestIndex): integer;
  public
    constructor Create;
    destructor Destroy; override;
    property Age: Integer read FAge write FAge;
    property Name: string read FName write FName;
    property Numbers[Index: TTestIndex]: integer read GetNumbers;
    property Strings: TStrings read FStrings write GetStrings;

  end;
  { Active class: set values to ClassB and read results }

  { Passive class }
  TTestClassTarget = class
    procedure TestEventBind(Sender: TObject);
  private
    FstrTarget: string;
    FrecTarget: TTestRecord;
    FdblTarget: Double;
    FintTarget: Integer;
    FEventFiredTarget: Boolean;
    FintTarget3: Integer;
    FobjTarget: TInternalClass;
    FBridgeObjTarget: TInternalClass;
  public
    constructor Create;
    destructor Destroy; override;
    property BridgeObjTarget: TInternalClass read FBridgeObjTarget write FBridgeObjTarget;
    property DblTarget: Double read FdblTarget write FdblTarget;
    property EventFiredTarget: Boolean read FEventFiredTarget;
    property IntTarget: Integer read FintTarget write FintTarget;
    property IntTarget3: Integer read FintTarget3 write FintTarget3;
    property RecTarget: TTestRecord read FrecTarget write FrecTarget;
    property ObjTarget: TInternalClass read FobjTarget write FobjTarget;
    property StrTarget: string read FstrTarget write FstrTarget;
    function DoubleOf(const NewValue, OldValue: TValue): TValue;
    function ToName(const NewValue, OldValue: TValue): TValue;
    function TripleOf(const NewValue, OldValue: TValue): TValue;
  end;

  [BindClassAttribute(True, 'TTestClassTarget')]
  TTestClassSource = class
    [BindMethod(True, 'OnClick', 'TestEventBind')]
    btnTest: TButton;
  private
    FdblPropOut: Double;
    FintPropOut: Integer;
    FrecPropOut: TTestRecord;
    FstrPropOut: string;
    FdblPropIn: Double;
    FintPropIn: Integer;
    FstrPropIn: string;
    FrecPropIn: TTestRecord;
    FdblPropIn2: Double;
    FintPropIn2: Integer;
    FunboundProp: string;
    FEventFired: Boolean;
    FintPropIn3: Integer;
    FobjPropOut: TInternalClass;
    FobjPropIn: TInternalClass;
    FOnEvent: TNotifyEvent;
    FThirdString: string;
    FFirstString: string;
    FFourthString: string;
    FSecondString: string;
    FBridgeObjPropOut: TInternalClass;
    FBridgeObjPropIn: TInternalClass;
  public
    constructor Create(AnInt: Integer; AStr: string; ADbl: Double);
    destructor Destroy; override;
    { bound TO the target }
    [BindMemberTo(True, '.', 'dblTarget')]
    property DblPropOut: Double read FdblPropOut write FdblPropOut;
    [BindMemberTo(True, '.', 'intTarget')]
    [BindMemberTo(True, '.', 'intTarget3', 'TripleOf')]
    property IntPropOut: Integer read FintPropOut write FintPropOut;
    [BindMemberTo(True, '.', 'BridgeObjTarget')]
    property BridgeObjPropOut: TInternalClass read FBridgeObjPropOut write FBridgeObjPropOut;
    [BindMemberTo(True, 'Age', 'ObjTarget.Age')]
    property ObjPropOut: TInternalClass read FobjPropOut write FobjPropOut;
    [BindMemberTo(True, '.', 'RecTarget')]
    property RecPropOut: TTestRecord read FrecPropOut write FrecPropOut;
    [BindMemberTo(True, '.', 'StrTarget')]
    property StrPropOut: string read FstrPropOut write FstrPropOut;
    { bound FROM the target }
    [BindMemberFrom(True, '.', 'dblTarget')]
    property DblPropIn: Double read FdblPropIn write FdblPropIn;
    [BindMemberFrom(True, '.', 'dblTarget', 'DoubleOf')]
    property DblPropIn2: Double read FdblPropIn2 write FdblPropIn2;
    [BindMemberFrom(True, '.', 'intTarget')]
    property IntPropIn: Integer read FintPropIn write FintPropIn;
    [BindMemberFrom(True, '.', 'intTarget', 'DoubleOf')]
    property IntPropIn2: Integer read FintPropIn2 write FintPropIn2;
    [BindMemberFrom(True, '.', 'IntTarget3')]
    property IntPropIn3: Integer read FintPropIn3 write FintPropIn3;
    [BindMemberFrom(True, 'Age', 'ObjTarget.Age')]
    property ObjPropIn: TInternalClass read FobjPropIn write FobjPropIn;
    [BindMemberFrom(True, '', 'BridgeObjTarget')]
    property BridgeObjPropIn: TInternalClass read FBridgeObjPropIn write FBridgeObjPropIn;
    [BindMemberFrom(True, '.', 'RecTarget')]
    property RecPropIn: TTestRecord read FrecPropIn write FrecPropIn;
    [BindMemberFrom(True, '.', 'StrTarget')]
    property StrPropIn: string read FstrPropIn write FstrPropIn;
    {Bound to verify Indexed properties}
    [BindMemberFrom(True, '.', 'ObjTarget.Strings.Strings[0]')]
    property FirstString: string read FFirstString write FFirstString;
    [BindMemberFrom(False, '.', 'ObjTarget.Strings.Strings[1]')]
    property SecondString: string read FSecondString write FSecondString;
    [BindMemberFrom(False, '.', 'ObjTarget.Strings.Strings[2]')]
    property ThirdString: string read FThirdString write FThirdString;
    [BindMemberFrom(False, '.', 'ObjTarget.Strings.Strings[3]')]
    property FourthString: string read FFourthString write FFourthString;
    { Bound to verify event }
    [BindMemberFrom(False, '.', 'EventFiredTarget')]
    property EventFired: Boolean read FEventFired write FEventFired;
    { unbound }
    [BindMemberFrom(False, '.', 'StrTarget')]
    property UnboundProp: string read FunboundProp write FunboundProp;
  published
    property OnEvent: TNotifyEvent read FOnEvent write FOnEvent;
  end;

  TTestClassC = class
  private
    FStrBidirectional: string;
    FIntProp: integer;
  public
    property StrBidirectional: string read FStrBidirectional
      write FStrBidirectional;
    property IntProp: integer read FIntProp write FIntProp;
  end;

const
  TEST_ARRAY: TTestIndexArray = (1,2,3);

implementation

Uses
  SysUtils;

{ TTestClassTarget }

constructor TTestClassTarget.Create;
begin
  inherited;
  ObjTarget := TInternalClass.Create;
end;

destructor TTestClassTarget.Destroy;
begin
  FreeAndNil(ObjTarget);
  inherited;
end;

function TTestClassTarget.DoubleOf(const NewValue, OldValue: TValue): TValue;
begin
  case NewValue.Kind of
    tkInteger:
      Result := NewValue.AsInteger * 2;
    tkInt64:
      Result := NewValue.AsInt64 * 2;
    tkFloat:
      Result := NewValue.AsType<Double> * 2;
  end;
end;

procedure TTestClassTarget.TestEventBind(Sender: TObject);
begin
  FEventFiredTarget := not FEventFiredTarget;
end;

function TTestClassTarget.ToName(const NewValue, OldValue: TValue): TValue;
begin
  Result := NewValue.AsString + ' (No Rec)';
end;

function TTestClassTarget.TripleOf(const NewValue, OldValue: TValue): TValue;
begin
  case NewValue.Kind of
    tkInteger:
      Result := NewValue.AsInteger * 3;
    tkInt64:
      Result := NewValue.AsInt64 * 3;
    tkFloat:
      Result := NewValue.AsType<Double> * 3;
  end;
end;

{ TTestClassSource }

constructor TTestClassSource.Create(AnInt: Integer; AStr: string; ADbl: Double);
begin
  FdblPropOut := ADbl;
  FintPropOut := AnInt;
  FrecPropOut.Name := AStr + ' (Rec)';
  FrecPropOut.Age := AnInt + 1;
  FstrPropOut := AStr;
  btnTest := TButton.Create(nil);
  btnTest.Name := 'BbtnTest';
  FBridgeObjPropOut := TInternalClass.Create;
  FobjPropOut := TInternalClass.Create;
  FobjPropIn := TInternalClass.Create;
  FobjPropOut.Name := AStr + ' (Obj)';
  FobjPropOut.Age := AnInt + 11;
end;

destructor TTestClassSource.Destroy;
begin
  FBridgeObjPropOut.Free;
  FobjPropOut.Free;
  FobjPropIn.Free;
  btnTest.Free;
  inherited;
end;

{ TTestClassC }

{ TInternalClass }

constructor TInternalClass.Create;
begin
  FStrings := TStringList.Create;
  FStrings.Add('The first string');
  FStrings.Add('The second string');
  FStrings.Add('The third string');
  FStrings.Add('The fourth string');
end;

destructor TInternalClass.Destroy;
begin
  FStrings.Free;
  inherited;
end;

function TInternalClass.GetNumbers(Index: TTestIndex): integer;
begin
  Result := TEST_ARRAY[Index];
end;

procedure TInternalClass.GetStrings(const Value: TStrings);
begin
  FStrings.Assign(Value);
end;


end.
