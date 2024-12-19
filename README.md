# BindAPI
BindAPI is a small framework for Delphi to bind virtually any property or field among classes without few code lines: just decorate your class with some attributes and run your app.
You can use BindAPI with any library.
See the [Quick Guide](.\Doc\BindApiGuide.md) for more detailed information.

Current version is [0.9.0.0 Alpha](#LastVersion).
Some improvements will be released in next weeks to obtain a more complete framework.

---

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
  [BindClass(True, 'TTestController')]
  {The value of the property edtSame.Text is read from TTestController.TestObject.IntProp}
  [BindMemberFrom('edtSame.Text', 'TestObject.IntProp')]
  {The following bind is disabled (first parameter is False)}  
  [BindMemberFrom(False, 'edtTarget2.Text', 'LowerText')]
  {Bind an instance of this class to an instance of TTestController and the value is converted by TTestController.DoubleOf}
  [BindMemberTo(True, 'speValue.Value', 'DoubleValue', 'DoubleOf')]
  {Bind the event btnTest.OnClick to the procedure TTestController.TestEventBind}
  [BindMethod(True, 'btnTest.OnClick', 'TestEventBind')]
  TfrmBindApiSimpleDemo = class(TForm)
    ...
    {The value of speValue.Value is sent to TTestController.TestObject.IntProp}
    [BindMemberTo('Value', 'TestObject.IntProp')]
    speValue: TSpinEdit;
    ...
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
 public
    {This form's property recives its value from TTestController.UpperText}
    [BindMemberFrom('.', 'UpperText')]
    property UpperText: string read GetUpperText write SetUpperText;
    {You can bind any property or field with two or more elements}
    [BindMemberTo(True, '.', 'NewValue')]
    [BindMemberTo('.', 'DoubleValue', 'DoubleOf')]
    property Value: Integer read GetValue write SetValue;
    ...

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
```

The Business Logic is in another unit:

```language Pascal
unit Test.Controller;

interface

uses
  ..., 
  plBindAPI.ClassFactory;

type

  TTestController = class(TInterfacedObject) {or any other class}
  public
    function DoubleOf(const NewValue, OldValue: TValue): TValue
  ... 
  end;

implementation
  function TTestController.DoubleOf(const NewValue, OldValue: TValue): TValue
  begin
    case NewValue.Kind of
      tkInteger:
        Result := NewValue.AsInteger * 2;
      tkInt64:
        Result := NewValue.AsInt64 * 2;
      tkFloat:
        Result := NewValue.AsType<Double> * 2
      else
        Result := 0;
    end;
  end;
  ...

initialization
  {Just add this line:}
  TplClassManager.RegisterClass(TTestController, [Singleton]);

```

That's all.
You can also bind two elements manually. See [demo](.\Doc\Demo.md) and test apps for other examples.

---

## Features
- A small but effective set of attributes for binding.
- No need to rewrite existing libraries, just add attributes in your form and classes.
- Can bind almost any field, property and methods of a class supported by RTTI. At present, support for indexed properties is not complete. 
- Support of qualified names.
- Compatible with MVC, MVP, MVVM - just select your source and target classes to implement your architecture.
- A couple of type conversion is automatically supported.
- You can use a function to test, convert or manipulate a value.

---

## New in 0.9.0.0 Beta version {#LastVersion}
- The 0.9.0.0 Beta version branch is the working branch from Dec. 19, 2024.
- Full support for indexed properties.
- New test cases.

## New in 0.9.0.0 Alpha version
It is a full rewrite of 0.8 version in order to simplify the interface of attributes and objects

*New features:*
- Full code documentation
- A new set of live templates helps you enter attributes - just copy them in your code_templates\Delphi folder.
- The new static class TPlRTTIUtils contains some useful procedures and functions to work with RTTI.
- Better support for records
- Attributes can read indexed properties values (support for write them is wip)

*Main Changes:*
- Attributes was renamed in consistent way.
See the [ChangeLog](.\Doc\Version 0.9 changes.md) for more information.

---

## Roadmap
- 0.9.0: complete test case for implemented methods.
- 0.9.1: More demo covering the full potential of BindAPI. 
- 0.9.2: A message-based system to manage registered objects destruction.
- 0.9.3: First demo for Android.
- 0.9.4: Code optimization.
- 0.9.5: Visual tools for monitoring binding status.
- 0.9.6: Interfaces definition.
- 0.9.7: ...
- 0.9.8: ...
- 0.9.9: ...

---

## To be continued...
Future releases will include:
- Full support for collections and array
- Best support for records
- A bit of documentation (as soon as possible, of course)
- More and more test cases
- FreePascal support (as 3.x version with full support for RTTI will be released)
- Android support
- Better management of interval in thread, maybe introducing a timer 
- Hopefully, a tool to create bound classes skeltons from attributes

---

## Warning
BindAPI has been tested only with Delphi 12.1 CE.
BindAPI is a previerw release and under active development.
Although it is quite mature, it requires more and more tests before any use in real production environments.
