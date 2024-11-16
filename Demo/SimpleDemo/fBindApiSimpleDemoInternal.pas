{*****************************************************************************}
{       BindAPI                                                               }
{       Copyright (C) 2020 Paolo Morandotti                                   }
{       Unit fBindApiSimpleDemo                                               }
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
unit fBindApiSimpleDemoInternal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Samples.Spin,
  plBindAPI.Attributes, plBindAPI.CoreBinder, plBindAPI.AutoBinder,
  plBindAPI.ClassFactory, Vcl.ExtCtrls, Vcl.AppEvnts;

type
  [ClassBind(True, 'TTestController', True)]
  [ClassBind(True, 'TTestSecond')]
  TfrmBindApiSimpleDemoInternal = class(TForm)
    lblCounter2: TLabel;
    [BindMemberTo(True, 'Text', 'CurrentText')]
    edtSource2: TEdit;
    [BindMemberFrom(True, 'Text', 'LowerText')]
    edtTarget2: TEdit;
    [BindMemberFrom(True, 'Text', 'UpperText')]
    edtTarget2a: TEdit;
    [MethodBind(True, 'OnClick', 'TestEventBind')]
    btnTest: TButton;
    [BindMemberFrom('Text', 'TestObject.IntProp')]
    edtSame: TEdit;
    [BindMemberTo(True, 'Value', 'TestObject.IntProp')]
    [BindMemberTo(True, 'Value', 'NewValue')]
    [BindMemberTo(True, 'Value', 'DoubleValue', 'DoubleOf')]
    speValue: TSpinEdit;
    [BindMemberFrom(True, 'Text', 'DoubleValue')]
    edtDouble: TEdit;
    [BindMember('Text', 'StrBidirectional', '', 'TTestSecond')]
    edtBidirectional: TEdit;
    [BindMember('Text', 'StrBidirectional', '', 'TTestSecond')]
    edtBidirectional2: TEdit;
    bvlInput: TBevel;
    bvlOutput: TBevel;
    [BindMemberFrom('Caption', 'NewValue')]
    lblInt: TLabel;
    edtFromArray1: TEdit;
    edtFromArray2: TEdit;
    edtFromArray3: TEdit;
    edtToArray1: TEdit;
    edtToArray2: TEdit;
    edtToArray3: TEdit;
    lblBinderInterval: TLabel;
    speInterval: TSpinEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure speIntervalChange(Sender: TObject);
  private
    { Private declarations }
    [BindPropertyTo(False, 'TestIndex')]
    FStringArrayTo: array[0..2] of string;
    FStringArrayFrom: array[0..2] of string;
    function GetSourceText: string;
    procedure SetSourceText(const Value: string);
    function GetLowerText: string;
    function GetUpperText: string;
    procedure SetLowerText(const Value: string);
    procedure SetUpperText(const Value: string);
    function GetValue: Integer;
    procedure SetValue(const Value: Integer);
    function GetStringArrayTo(index: integer): string;
    procedure SetStringArrayTo(index: integer; const Value: string);  public
    function GetStringArrayFrom(index: integer): string;
    procedure SetStringArrayFrom(index: integer; const Value: string);  public
    [BindMemberTo(False, '', 'CurrentText')]
    property StringArrayTo[index: integer]: string read GetStringArrayTo write SetStringArrayTo;
    property StringArrayFrom[index: integer]: string read GetStringArrayFrom write SetStringArrayTo;
  published
    { Public declarations }
    [BindMemberTo('', 'CurrentText')]
    property SourceText: string read GetSourceText write SetSourceText;
    [BindMemberFrom('', 'LowerText')]
    property LowerText: string read GetLowerText write SetLowerText;
    [BindMemberFrom('', 'UpperText')]
    property UpperText: string read GetUpperText write SetUpperText;
    [BindMemberTo('', 'NewValue')]
    [BindMemberTo('', 'DoubleValue', 'DoubleOf')]
    property Value: Integer read GetValue write SetValue;
  end;

var
  frmBindApiSimpleDemoInternal: TfrmBindApiSimpleDemoInternal;

implementation

uses
  plBindAPI.BindManagement;

{$R *.dfm}

procedure TfrmBindApiSimpleDemoInternal.FormCreate(Sender: TObject);
begin
  {Remember: if the bound class is not a singleton, the binder is
   responsible of its destruction}
  TplBindManager.Bind(Self);
  FStringArrayTo[0] := 'Uno';
  FStringArrayTo[1] := 'Due';
  FStringArrayTo[2] := 'Tre';
  speInterval.Value := TPlBindManager.Interval;
end;

procedure TfrmBindApiSimpleDemoInternal.FormDestroy(Sender: TObject);
begin
  TplBindManager.Unbind(Self);
end;

function TfrmBindApiSimpleDemoInternal.GetLowerText: string;
begin
  Result := edtTarget2.Text;
end;

function TfrmBindApiSimpleDemoInternal.GetSourceText: string;
begin
  Result := edtSource2.Text;
end;

function TfrmBindApiSimpleDemoInternal.GetStringArrayFrom(index: integer): string;
begin
  Result := FStringArrayFrom[index];
end;

function TfrmBindApiSimpleDemoInternal.GetStringArrayTo(index: integer): string;
begin
  Result := FStringArrayTo[index];
end;

function TfrmBindApiSimpleDemoInternal.GetUpperText: string;
begin
  Result := edtTarget2a.Text;
end;

function TfrmBindApiSimpleDemoInternal.GetValue: Integer;
begin
  Result := speValue.Value;
end;

procedure TfrmBindApiSimpleDemoInternal.SetLowerText(const Value: string);
begin
  edtTarget2.Text := Value;
end;

procedure TfrmBindApiSimpleDemoInternal.SetSourceText(const Value: string);
begin
  edtSource2.Text := Value;
end;

procedure TfrmBindApiSimpleDemoInternal.SetStringArrayFrom(index: integer;
  const Value: string);
begin
  FStringArrayFrom[index] := Value;
  case index of
    0: edtFromArray1.Text := Value;
    1: edtFromArray2.Text := Value;
    else edtFromArray3.Text := Value;
  end;
end;

procedure TfrmBindApiSimpleDemoInternal.SetStringArrayTo(index: integer;
  const Value: string);
begin
  FStringArrayTo[index] := Value;
  case index of
    0: edtToArray1.Text := Value;
    1: edtToArray2.Text := Value;
    else edtToArray3.Text := Value;
  end;
end;

procedure TfrmBindApiSimpleDemoInternal.SetUpperText(const Value: string);
begin
  edtTarget2a.Text := Value;
end;

procedure TfrmBindApiSimpleDemoInternal.SetValue(const Value: Integer);
begin
  speValue.Value := Value;
end;

procedure TfrmBindApiSimpleDemoInternal.speIntervalChange(Sender: TObject);
begin
  TplBindManager.Interval := speInterval.Value;
end;

end.
