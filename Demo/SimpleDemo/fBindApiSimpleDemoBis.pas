{*****************************************************************************}
{       BindAPI                                                               }
{       Copyright (C) 2020 Paolo Morandotti                                   }
{       Unit fBindApiSimpleDemoBis                                               }
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
unit fBindApiSimpleDemoBis;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, fBindApiSimpleDemo, Vcl.Samples.Spin,
  plBindAPI.Attributes, plBindAPI.AutoBinder, Vcl.ComCtrls;

type
  [ClassBind(True, 'TTestController', True)]
  [ClassBind(True, 'TTestSecond')]
  [BindMemberFrom(True, 'edtTarget2.Text', 'LowerText')]
  [BindMemberFrom(True, 'edtTarget2a.Text', 'UpperText')]
  [BindMemberFrom('edtSame.Text', 'TestObject.IntProp')]
  [BindMemberFrom(True, 'edtDouble.Text', 'DoubleValue')]
  [BindMemberTo(True, 'edtSource2.Text', 'CurrentText')]
  [BindMemberTo(True, 'memSource.Text', 'TestObject.Text')]
  [BindMemberFrom(True, 'memTarget.Text', 'TestObject.Text')]
  [BindMemberTo(True, 'speValue.Value', 'TestObject.IntProp')]
  [BindMemberTo(True, 'speValue.Value', 'NewValue')]
  [BindMemberTo(True, 'speValue.Value', 'DoubleValue', 'DoubleOf')]
  [BindMember(True, 'edtBidirectional.Text', 'StrBidirectional', '', 'TTestSecond')]
  [BindMember(True, 'edtBidirectional2.Text', 'StrBidirectional', '', 'TTestSecond')]
  [BindMemberFrom(True, 'lblInt.Caption', 'NewValue')]
  [MethodBind(True, 'btnTest.OnClick', 'TestEventBind')]
{$IFDEF USE_INTERNAL_PROP}
  [BindMemberTo(False, 'Value', 'NewValue')]
  [BindMemberTo(False, 'DoubleValue', 'DoubleOf')]
  [BindMemberTo(False, 'DoubleValue', 'DoubleOf')]
  [BindMemberTo(False, 'SourceText', 'CurrentText')]
  [BindMemberFrom(False, 'LowerText', 'LowerText')]
  [BindMemberFrom(False, 'UpperText', 'UpperText')]
{$ENDIF}
  TfrmBindApiSimpleDemo1 = class(TfrmBindApiSimpleDemo)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmBindApiSimpleDemo1: TfrmBindApiSimpleDemo1;

implementation

{$R *.dfm}

end.
