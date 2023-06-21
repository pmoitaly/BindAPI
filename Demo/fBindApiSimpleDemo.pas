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
unit fBindApiSimpleDemo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Samples.Spin,
  plBindAPI.Attributes, plBindAPI.CoreBinder, plBindAPI.AutoBinder,
  plBindAPI.ClassFactory, Vcl.ExtCtrls;

type
  [ClassBind(True, 'TTestController', True)]
  [ClassBind(True, 'TTestSecond')]
  [BindFieldFrom(False, 'edtTarget2.Text', 'LowerText')]
  [BindFieldFrom(False, 'edtTarget2a.Text', 'UpperText')]
  [BindFieldTo(False, 'edtSource2.Text', 'CurrentText')]
  [BindFieldFrom('edtSame.Text', 'TestObject.IntProp')]
  [BindFieldFrom(True, 'edtDouble.Text', 'DoubleValue')]
  [BindFieldTo(False, 'speValue.Value', 'TestObject.IntProp')]
  [BindFieldTo(False, 'speValue.Value', 'NewValue')]
  [BindFieldTo(False, 'speValue.Value', 'DoubleValue', 'DoubleOf')]
  [EventBind(True, 'btnTest.OnClick', 'TestEventBind')]
  [EventBind(False, 'btnTest.OnClick', 'SetSourceText')]
  TfrmBindApiSimpleDemo = class(TForm)
    lblCounter2: TLabel;
    edtSource2: TEdit;
    edtTarget2: TEdit;
    edtTarget2a: TEdit;
    btnTest: TButton;
    edtSame: TEdit;
    [BindFieldTo('Value', 'TestObject.IntProp')]
    speValue: TSpinEdit;
    edtDouble: TEdit;
    [BindField('Text', 'StrBidirectional', '', 'TTestSecond')]
    edtBidirectional: TEdit;
    [BindField('Text', 'StrBidirectional', '', 'TTestSecond')]
    edtBidirectional2: TEdit;
    bvlInput: TBevel;
    bvlOutput: TBevel;
    [BindFieldFrom(True, 'Caption', 'NewValue')]
    lblInt: TLabel;
    lblIndirectBinding: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    function GetSourceText: string;
    procedure SetSourceText(const Value: string);
    function GetLowerText: string;
    function GetUpperText: string;
    procedure SetLowerText(const Value: string);
    procedure SetUpperText(const Value: string);
    function GetValue: Integer;
    procedure SetValue(const Value: Integer);
  published
    { Public declarations }
    [BindPropertyTo('CurrentText')]
    property SourceText: string read GetSourceText write SetSourceText;
    [BindPropertyFrom('LowerText')]
    property LowerText: string read GetLowerText write SetLowerText;
    [BindPropertyFrom('UpperText')]
    property UpperText: string read GetUpperText write SetUpperText;
    [BindPropertyTo(True, 'NewValue')]
    [BindPropertyTo('DoubleValue', 'DoubleOf')]
    property Value: Integer read GetValue write SetValue;
  end;

var
  frmBindApiSimpleDemo: TfrmBindApiSimpleDemo;

implementation

uses
  plBindAPI.BindManagement;

{$R *.dfm}

procedure TfrmBindApiSimpleDemo.FormCreate(Sender: TObject);
begin
  {Remember: if the bound class is not a singleton, the binder is
   responsible of its destruction}
  // TplBindManager.Binder.Interval := 1;
  if not (csDesigning in ComponentState) then
    TplBindManager.Bind(Self);
end;

procedure TfrmBindApiSimpleDemo.FormDestroy(Sender: TObject);
begin
  TplBindManager.Unbind(Self);
end;

function TfrmBindApiSimpleDemo.GetLowerText: string;
begin
  Result := edtTarget2.Text;
end;

function TfrmBindApiSimpleDemo.GetSourceText: string;
begin
  Result := edtSource2.Text;
end;

function TfrmBindApiSimpleDemo.GetUpperText: string;
begin
  Result := edtTarget2a.Text;
end;

function TfrmBindApiSimpleDemo.GetValue: Integer;
begin
  Result := speValue.Value;
end;

procedure TfrmBindApiSimpleDemo.SetLowerText(const Value: string);
begin
  edtTarget2.Text := Value;
end;

procedure TfrmBindApiSimpleDemo.SetSourceText(const Value: string);
begin
  edtSource2.Text := Value;
end;

procedure TfrmBindApiSimpleDemo.SetUpperText(const Value: string);
begin
  edtTarget2a.Text := Value;
end;

procedure TfrmBindApiSimpleDemo.SetValue(const Value: Integer);
begin
  speValue.Value := Value;
end;

end.
