unit fmx.fBindApiSimpleDemo;

interface

uses
  SysUtils, Types, UITypes, Classes, Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.TabControl, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  FMX.EditBox, FMX.SpinBox, FMX.Edit, FMX.Controls.Presentation,
  plBindAPI.Attributes, plBindAPI.CoreBinder, plBindAPI.AutoBinder;

type
  [DefaultClassBind(True, 'TTestController')]
  [ClassBind(True, 'TTestSecond')]
  [BindMemberTo(True, 'edtSource2.Text', 'CurrentText')]
  [BindMemberFrom(True, 'edtTarget2.Text', 'LowerText')]
  [BindMemberFrom(True, 'edtTarget2a.Text', 'UpperText')]
//  [BindMemberTo(False, 'memSource.Text', 'Text')]
  [BindMemberTo(True, 'memSource.Text', 'TestObject.Text')]
  [BindMemberFrom(True, 'memTarget.Text', 'TestObject.Text')]
  [BindMemberTo(True, 'speValue.Value', 'TestObject.IntProp')]
  [BindMemberTo(True, 'speValue.Value', 'NewValue')]
  [BindMemberFrom(True, 'edtSame.Text', 'TestObject.IntProp')]
  [BindMemberTo(True, 'speValue.Value', 'DoubleValue', 'DoubleOf')]
  [BindMemberFrom(True, 'lblInt.Text', 'NewValue')]
  [BindMemberFrom(True, 'edtDouble.Text', 'DoubleValue')]
  [BindMemberTo(True, 'speValue.Value', 'TabStyle', '', 'TTestSecond')]
  [BindMemberFrom(True, 'pctEnum.TabPosition', 'TabStyle', '', 'TTestSecond')]
  [BindMember(True, 'edtBidirectional.Text', 'StrBidirectional', '', 'TTestSecond')]
  [BindMember(True, 'edtBidirectional2.Text', 'StrBidirectional', '', 'TTestSecond')]
  [MethodBind(True, 'btnTest.OnClick', 'TestEventBind')]
  TBindApiSimpleDemo = class(TForm)
    btnTest: TButton;
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
    pctEnum: TTabControl;
    pnlInput: TPanel;
    pnlOutput: TPanel;
    speValue: TSpinBox;
    tbiFirst: TTabItem;
    tbiSecond: TTabItem;
    tbiThird: TTabItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  end;

var
  BindApiSimpleDemo: TBindApiSimpleDemo;

implementation

uses
  plBindAPI.BindManagement;

{$R *.fmx}
{$R *.Windows.fmx MSWINDOWS}
{$R *.XLgXhdpiTb.fmx ANDROID}

{ TfrmBindApiSimpleDemo }

procedure TBindApiSimpleDemo.FormCreate(Sender: TObject);
begin
  {Remember: if the bound class is not a singleton, the binder is
   responsible of its destruction}
  TplBindManager.Bind(Self);
end;

procedure TBindApiSimpleDemo.FormDestroy(Sender: TObject);
begin
  TplBindManager.Unbind(Self);
end;

end.
