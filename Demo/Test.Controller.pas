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
