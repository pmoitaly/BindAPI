# BindAPI
BindAPI is a small framework for Delphi to bind virtually any property or field among classes without few code lines: just decorate your class with some attributes and run your app.
You can use BindAPI with any library.

## Use
BindAPI is aimed to create prototypes, demo, POC and small applications.

You can bind any property method or field to a source just adding some attributes and registering involved classes.

```language Pascal
unit fBindApiSimpleDemo;

interface

uses
  ...,
  plBindAPI.Attributes, plBindAPI.CoreBinder, plBindAPI.AutoBinder,
  plBindAPI.ClassFactory;
type
  {Bind an instance of this class to an instance of TTestController}
  [ClassBind(True, 'TTestController')]
  {The value of the property edtSame.Text is read from TTestController.TestObject.IntProp}
  [BindFormFieldFrom('edtSame.Text', 'TestObject.IntProp')]
  {The following bind is disabled (first parameter is False)}  
  [BindFormFieldFrom(False, 'edtTarget2.Text', 'LowerText')]
  {Bind an instance of this class to an instance of TTestController and the value is converted by TTestController.DoubleOf}
  [BindFormFieldTo(True, 'speValue.Value', 'DoubleValue', 'DoubleOf')]
  {Bind the event btnTest.OnClick to the procedure TTestController.TestEventBind}
  [EventBind(True, 'btnTest.OnClick', 'TestEventBind')]
  TfrmBindApiSimpleDemo = class(TForm)
    ...
    {The value of speValue.Value is sent to TTestController.TestObject.IntProp}
    [BindFormFieldTo('Value', 'TestObject.IntProp')]
    speValue: TSpinEdit;
    ...
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
 public
    {This form's property recives its value from TTestController.UpperText}
    [BindPropertyFrom('UpperText')]
    property UpperText: string read GetUpperText write SetUpperText;
    {You can bind any property or field with two or more elements}
    [BindPropertyTo(True, 'NewValue')]
    [BindPropertyTo('DoubleValue', 'DoubleOf')]
    property Value: Integer read GetValue write SetValue;

implementation

uses
  plBindAPI.BindManagement;

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

...

end.


unit Test.Controller;

interface

uses
  ..., 
  plBindAPI.ClassFactory;

type

  TTestController = class(TInterfacedObject) {or any other class}
  ... 
  end;

implementation
  ...

initialization
  TplClassManager.RegisterClass(TTestController, true);

```

That's all.
You can also bind two elements manually. See demo and test apps for other examples. 

## Features
- No need to rewrite existing libraries, just add attributes in your form, classes and so on.
- Can bind any field, property and methods of a class supported by RTTI... at present, field, property and methods I'm really use. 
- Support of property path.
- Can use a function to convert a value.
- Compatible with MVC, MVP, MVVM - just select your source and target classes to implement your architecture.
- A couple of type conversion is automatically supported.

## To be continued...
Future releases will include:
- DONE: Support for collections and array
- Better support for records
- A bit of documentation (as soon as possible, of course)
- More and more test cases
- FreePascal support (as 3.2 version will be released)
- Android support
- Better management of interval in thread, maybe introducing a timer 
- Hopefully, a tool to create bound classes skeltons from attributes

## Warning
BindAPI has been tested only with Delphi 10.3.3.
BindAPI is currently under active development. Although it is quite mature, it requires more tests before any use in real production environments. It is released as preview.
