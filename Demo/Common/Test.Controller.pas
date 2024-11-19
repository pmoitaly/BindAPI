{*****************************************************************************}
{       BindAPI                                                               }
{       Copyright (C) 2020 Paolo Morandotti                                   }
{       Unit Test.Controller                                                  }
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
unit Test.Controller;

interface

uses
  System.Classes, System.RTTI;

type

  TFieldObject = class
  private
    FInt: Integer;
    FStr: string;
    FText: string;
  public
    property IntProp: Integer read FInt write FInt;
    property StrProp: string read FStr write FStr;
    property Text: string read FText write FText;
  end;

  TTestController = class(TInterfacedObject)
    function DoubleOf(const NewValue, OldValue: TValue): TValue;
    procedure TestEventBind(Sender: TObject);
  private
    FCurrentText: string;
    FDoubleValue: integer;
    FLowerText: string;
    FNewValue: integer;
    FTestIndex: array[0..2] of string;
    FTestObject: TFieldObject;
    FUpperText: string;
    function GetTestIndex(index: integer): string;
    procedure SetCurrentText(const Value: string);
    procedure SetTestIndex(index: integer; const Value: string);
  public
    constructor Create;
    destructor Destroy; override;
    property CurrentText: string read FCurrentText write SetCurrentText;
    property DoubleValue: integer read FDoubleValue write FDoubleValue;
    property LowerText: string read FLowerText write FLowerText;
    property NewValue: integer read FNewValue write FNewValue;
    property TestIndex[index: integer]: string read GetTestIndex write SetTestIndex;
    property TestObject: TFieldObject read FTestObject write FTestObject;
    property UpperText: string read FUpperText write FUpperText;
  end;

  TTestSecond = class(TInterfacedObject)
  private
    FStrBidirectional: string;
    FTabStyle: Integer;
  public
    procedure SetTabStyle(const Value: Integer);
    property StrBidirectional: string read FStrBidirectional write FStrBidirectional;
    property TabStyle: Integer read FTabStyle write SetTabStyle;
  end;

implementation

uses
  System.SysUtils, Dialogs;

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
  case NewValue.TypeInfo.Kind of
    tkInteger, tkInt64: Result := NewValue.AsInteger * 2;
    tkFloat: Result := NewValue.AsExtended * 2;
    else
      Result := NewValue;
  end;

end;

function TTestController.GetTestIndex(index: integer): string;
begin
  Result := FTestIndex[index];
end;

procedure TTestController.SetCurrentText(const Value: string);
begin
  FCurrentText := Value;
  FLowerText := AnsiLowerCase(Value);
  FUpperText := AnsiUpperCase(Value);
end;

procedure TTestController.SetTestIndex(index: integer; const Value: string);
begin
  FTestIndex[index] := Value;
end;

procedure TTestController.TestEventBind(Sender: TObject);
begin
  FLowerText := '';
  FUpperText := '';
  ShowMessage('Done.');
end;

procedure TTestSecond.SetTabStyle(const Value: Integer);
begin
  FTabStyle := Abs(Value) mod 3;
end;


end.
