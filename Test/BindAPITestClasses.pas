{*****************************************************************************}
{       BindAPI                                                               }
{       Copyright (C) 2020 Paolo Morandotti                                   }
{       Unit BindAPITestClasses                                               }
{*****************************************************************************}
{                                                                             }
{Permission is hereby granted, free of charge, to any person obtaining        }
{a copy of this software and associated documentation files (the "Software"), }
{to deal in the Software without restriction, including without limitation    }
{the rights to use, copy, modify, merge, publish, distribute, sublicense,     }
{and/or sell copies of the Software, and to permit persons to whom the        }
{Software is furnished to do so, subject to the following conditions:         }
{                                                                             }
{The above copyright notice and this permission notice shall be included in   }
{all copies or substantial portions of the Software.                          }
{                                                                             }
{THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS      }
{OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  }
{FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE  }
{AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER       }
{LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING      }
{FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS }
{IN THE SOFTWARE.                                                             }
{*****************************************************************************}
unit BindAPITestClasses;

interface

uses
  System.Classes, System.RTTI,
  VCL.StdCtrls,
  plBindAPI.Attributes;

type
  TTestRecord = record
    Name: string;
    Age: Integer;
  end;

  TInternalClass = class
  private
    FName: string;
    FAge: Integer;
  public
    property Name: string read FName write FName;
    property Age: Integer read FAge write FAge;
  end;
  {Active class: set values to ClassB and read results}

  {Passive class}
  TTestClassA = class
    procedure TestEventBind(Sender: TObject);
  private
    FstrTarget: string;
    FrecTarget: TTestRecord;
    FdblTarget: Double;
    FintTarget: Integer;
    FEventFiredTarget: Boolean;
    FintTarget3: Integer;
    FobjTarget: TInternalClass;
  public
    constructor Create;
    destructor Destroy; override;
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

  [ClassBindAttribute(True, 'TTestClassC')]
  TTestClassB = class
          [EventBind(True, 'OnClick', 'TestEventBind')]
          [BindPropertyTo(True, 'dblTarget')]
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
  public
    constructor Create(AnInt: Integer; AStr: string; ADbl: Double);
    destructor Destroy; override;
    {bound TO the target}
                [BindPropertyTo(True, 'dblTarget')]
    property DblPropOut: Double read FdblPropOut write FdblPropOut;
                [BindPropertyTo(True, 'intTarget')]
                [BindPropertyTo(True, 'intTarget3', 'TripleOf')]
    property IntPropOut: Integer read FintPropOut write FintPropOut;
                [BindPropertyTo(True, 'ObjTarget')]
    property ObjPropOut: TInternalClass read FobjPropOut write FobjPropOut;
                [BindPropertyTo(True, 'RecTarget')]
    property RecPropOut: TTestRecord read FrecPropOut write FrecPropOut;
                [BindPropertyTo(True, 'StrTarget')]
    property StrPropOut: string read FstrPropOut write FstrPropOut;
    {bound FROM the target}
                [BindPropertyFrom(True, 'dblTarget')]
    property DblPropIn: Double read FdblPropIn write FdblPropIn;
                [BindPropertyFrom(True, 'dblTarget', 'DoubleOf')]
    property DblPropIn2: Double read FdblPropIn2 write FdblPropIn2;
                [BindPropertyFrom(True, 'intTarget')]
    property IntPropIn: Integer read FintPropIn write FintPropIn;
                [BindPropertyFrom(True, 'intTarget', 'DoubleOf')]
    property IntPropIn2: Integer read FintPropIn2 write FintPropIn2;
                [BindPropertyFrom(True, 'IntTarget3')]
    property IntPropIn3: Integer read FintPropIn3 write FintPropIn3;
                [BindPropertyFrom(True, 'RecTarget')]
    property ObjPropIn: TInternalClass read FobjPropIn write FobjPropIn;
    property RecPropIn: TTestRecord read FrecPropIn write FrecPropIn;
                [BindPropertyFrom(True, 'StrTarget')]
    property StrPropIn: string read FstrPropIn write FstrPropIn;
    {Bound to verify event}
                [BindPropertyFrom(True, 'EventFiredTarget')]
    property EventFired: Boolean read FEventFired write FEventFired;
    {unbound}
                [BindPropertyFrom(False, 'StrTarget')]
    property UnboundProp: string read FunboundProp write FUnboundProp;
  end;

  TTestClassC = class
  private
    FStrBidirectional: string;
  public
    property StrBidirectional: string read FStrBidirectional write FStrBidirectional;
  end;

implementation

{ TTestClassA }

constructor TTestClassA.Create;
begin
  inherited;
  ObjTarget := TInternalClass.Create;
end;

destructor TTestClassA.Destroy;
begin
  ObjTarget.Free;
  inherited;
end;

function TTestClassA.DoubleOf(const NewValue, OldValue: TValue): TValue;
begin
  case NewValue.Kind of
    tkInteger: Result := NewValue.AsInteger * 2;
    tkInt64: Result := NewValue.AsInt64 * 2;
    tkFloat: Result := NewValue.AsType<Double> * 2;
  end;
end;

procedure TTestClassA.TestEventBind(Sender: TObject);
begin
  FEventFiredTarget := not FEventFiredTarget;
end;

function TTestClassA.ToName(const NewValue, OldValue: TValue): TValue;
begin
  Result := NewValue.AsString + ' (No Rec)';
end;

function TTestClassA.TripleOf(const NewValue, OldValue: TValue): TValue;
begin
  case NewValue.Kind of
    tkInteger: Result := NewValue.AsInteger * 3;
    tkInt64: Result := NewValue.AsInt64 * 3;
    tkFloat: Result := NewValue.AsType<Double> * 3;
  end;
end;

{ TTestClassB }

constructor TTestClassB.Create(AnInt: Integer; AStr: string; ADbl: Double);
begin
  FdblPropOut := ADbl;
  FintPropOut := AnInt;
  FrecPropOut.Name := AStr + ' (Rec)';
  FrecPropOut.Age := AnInt + 1;
  FstrPropOut := AStr;
  btnTest := TButton.Create(nil);
  FobjPropOut := TInternalClass.Create;
  FobjPropIn := TInternalClass.Create;
  FobjPropOut.Name := AStr + ' (Obj)';
  FobjPropOut.Age := AnInt + 11;
end;

destructor TTestClassB.Destroy;
begin
  FobjPropOut.Free;
  FobjPropIn.Free;
  btnTest.Free;
  inherited;
end;



{ TTestClassC }

end.
