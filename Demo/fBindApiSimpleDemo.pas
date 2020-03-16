unit fBindApiSimpleDemo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Samples.Spin,
  plBindAPI.Attributes, plBindAPI.CoreBinder, plBindAPI.AutoBinder,
  plBindAPI.ClassFactory;

type
  [ClassBind(True, 'TTestController')]
  [BindFormFieldFrom(False, 'edtTarget2.Text', 'LowerText')]
  [BindFormFieldFrom(False, 'edtTarget2a.Text', 'UpperText')]
  [BindFormFieldTo(False, 'edtSource2.Text', 'CurrentText')]
  [BindFormFieldFrom(True, 'edtSame.Text', 'TestObject.IntProp')]
  [BindFormFieldFrom(True, 'edtDouble.Text', 'DoubleValue')]
  [BindFormFieldTo(False, 'speValue.Value', 'TestObject.IntProp')]
  [BindFormFieldTo(False, 'speValue.Value', 'NewValue')]
  [BindFormFieldTo(False, 'speValue.Value', 'DoubleValue', 'DoubleOf')]
  [EventBind(True, 'btnTest.OnClick', 'TestEventBind')]
  TfrmBindApiSimpleDemo = class(TForm)
    lblCounter2: TLabel;
    edtSource2: TEdit;
    edtTarget2: TEdit;
    edtTarget2a: TEdit;
    btnTest: TButton;
    edtSame: TEdit;
    [BindFormFieldTo(True, 'Value', 'TestObject.IntProp')]
    speValue: TSpinEdit;
    edtDouble: TEdit;
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
    [BindPropertyTo(True, 'CurrentText')]
    property SourceText: string read GetSourceText write SetSourceText;
    [BindPropertyFrom(True, 'LowerText')]
    property LowerText: string read GetLowerText write SetLowerText;
    [BindPropertyFrom(True, 'UpperText')]
    property UpperText: string read GetUpperText write SetUpperText;
    [BindPropertyTo(True, 'NewValue')]
    [BindPropertyTo(True, 'DoubleValue', 'DoubleOf')]
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
