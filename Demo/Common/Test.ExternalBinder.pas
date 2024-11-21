unit Test.ExternalBinder;

interface

uses
  plBindAPI.CoreBinder, Vcl.Controls;

procedure ExecuteBind(Source: TControl);
procedure TerminateBind;

implementation

uses
  fBindApiSimpleDemoBase, Test.Controller, System.SysUtils;

var
  binder: TPlBinder;
  testController: TTestController;
  secondController: TTestSecond;

procedure ExecuteBind(Source: TControl);
begin
  TerminateBind;
  binder := TPlBinder.Create;
  testController := TTestController.Create;
  secondController := TTestSecond.Create;
  // Test group 1
  binder.Bind(testController, 'LowerText', Source, 'edtTarget2.Text');
  binder.Bind(testController, 'UpperText', Source, 'edtTarget2a.Text');
  binder.BindMethod(Source, 'btnTest.OnClick', testController, 'TestEventBind');
  binder.Bind(testController, 'TestObject.IntProp', Source, 'edtSame.Text');
  binder.Bind(testController, 'DoubleValue', Source, 'edtDouble.Text');
  binder.Bind(Source, 'speValue.Value', testController, 'TestObject.IntProp');
  binder.Bind(Source, 'speValue.Value', testController, 'DoubleValue', testController.DoubleOf);
  binder.Bind(Source, 'speValue.Value', testController, 'NewValue');
  binder.Bind(Source, 'edtSource2.Text', testController, 'CurrentText');
  binder.Bind(testController, 'DoubleValue', Source, 'lblInt.caption');
  // Test group 3  - bidirectional
  binder.Bind(Source, 'edtBidirectional.Text', secondController, 'StrBidirectional');
  binder.Bind(secondController, 'StrBidirectional', Source, 'edtBidirectional2.Text');
  binder.Bind(secondController, 'StrBidirectional', Source, 'edtBidirectional.Text');
  binder.Bind(Source, 'edtBidirectional2.Text', secondController, 'StrBidirectional');

  binder.Start(10);
end;

procedure TerminateBind;
begin
  if Assigned(Binder) then
    begin
      binder.Stop;
      FreeAndNil(binder);
    end;
  if Assigned(testController) then
    FreeAndNil(testController);
  if Assigned(secondController) then
    FreeAndNil(secondController);
end;

end.
