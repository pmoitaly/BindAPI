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
  Winapi.Windows, Winapi.Messages,
  System.Variants, System.Classes,
  Vcl.Graphics, Vcl.ExtCtrls, Vcl.Samples.Spin, Vcl.ComCtrls,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  plBindAPI.Attributes, Vcl.Menus, Vcl.Buttons;

type
  [BindDefaultClass(True, 'TTestController')]
  [BindClass(True, 'TSimpleDemoFormController', 'GUIController')]
  [BindClass(True, 'TTestSecond')]
  [BindMemberTo(True, 'edtSource2.Text', 'CurrentText')]
  [BindMemberFrom(True, 'edtTarget2.Text', 'LowerText')]
  [BindMemberFrom(True, 'edtTarget2a.Text', 'UpperText')]
  [BindMemberTo(True, 'memSource.Text', 'TestObject.Text')]
  [BindMemberFrom(True, 'memTarget.Text', 'TestObject.Text')]
  [BindMemberTo(True, 'speValue.Value', 'TestObject.IntProp')]
  [BindMemberTo(True, 'speValue.Value', 'NewValue')]
  [BindMemberFrom(True, 'edtSame.Text', 'TestObject.IntProp')]
  [BindMemberTo(True, 'speValue.Value', 'DoubleValue', 'DoubleOf')]
  [BindMemberFrom(True, 'lblInt.Caption', 'NewValue')]
  [BindMemberFrom(True, 'edtDouble.Text', 'DoubleValue')]
  [BindMemberTo(True, 'speValue.Value', 'TabStyle', '', 'TTestSecond')]
  [BindMemberFrom(True, 'pctEnum.Style', 'TabStyle', '', 'TTestSecond')]
  [BindMember(True, 'edtBidirectional.Text', 'StrBidirectional', '', 'TTestSecond')]
  [BindMember(True, 'edtBidirectional2.Text', 'StrBidirectional', '', 'TTestSecond')]
  [BindMethod(True, 'btnTest.OnClick', 'TestEventBind')]
  TfrmBindApiSimpleDemo = class(TForm)
    btnTest: TButton;
    bvlInput: TBevel;
    bvlOutput: TBevel;
    edtBidirectional: TEdit;
    edtBidirectional2: TEdit;
    edtDouble: TEdit;
    edtSame: TEdit;
    edtSource2: TEdit;
    edtTarget2: TEdit;
    edtTarget2a: TEdit;
    lblBidirectionalArrow: TLabel;
    lblBidirectionalBindingInfo: TLabel;
    lblBidirectionalInfo2: TLabel;
    lblBinderInterval: TLabel;
    lblDoubleValueArrow: TLabel;
    lblIndirectBindingInfo: TLabel;
    lblInt: TLabel;
    lblLowercaseArrow: TLabel;
    lblMemoTextInfo: TLabel;
    lblMixedBindingInfo: TLabel;
    lblSameTextArrow: TLabel;
    lblSameValueArrow: TLabel;
    lblUppercaseArrow: TLabel;
    lblValueToEnumArrow: TLabel;
    memSource: TMemo;
    memTarget: TMemo;
    [BindMethod(True, 'OnClick', 'ShowAbout', 'GUIController')]
    mitAbout: TMenuItem;
    [BindMethod(True, 'OnClick', 'ExitProgram', 'GUIController')]
    mitExit: TMenuItem;
    mitFile: TMenuItem;
    mitHelp: TMenuItem;
    mitMonitor: TMenuItem;
    [BindMethod(True, 'OnClick', 'SwitchMonitor', 'GUIController')]
    mitMonitorVisible: TMenuItem;
    mmnMain: TMainMenu;
    pctEnum: TPageControl;
    speInterval: TSpinEdit;
    speValue: TSpinEdit;
    tbsTabA: TTabSheet;
    tbsTabB: TTabSheet;
    tbsTabC: TTabSheet;
    CheckBox1: TCheckBox;
    spbStartStop: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure speIntervalChange(Sender: TObject);
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
  TplBindManager.Bind(Self);
  speInterval.Value := TPlBindManager.Interval;
end;

procedure TfrmBindApiSimpleDemo.FormDestroy(Sender: TObject);
begin
  TplBindManager.Unbind(Self);
end;

procedure TfrmBindApiSimpleDemo.speIntervalChange(Sender: TObject);
begin
  TplBindManager.Interval := speInterval.Value;
end;

end.
