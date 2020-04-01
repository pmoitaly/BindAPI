# API

The BindAPI library allows you to link the properties of two classes through the following attributes:

## ClassBind

ClassBind attribute, placed before the definition of the class, indicates that the class itself must be connected to a second class whose name corresponds to the TargetClassName property.
### Property

- **IsEnabled**: boolean. If True, the binding is done with the target class, otherwise the binding is not done. Default: True.

- **TargetClassName**: string. The name of the class that contains fields and properties to link. If its value is 'Self', the instances of the class will link fields and properties internally. Required.

- **IsDefault**: boolean. If True, the class name can be omitted in the attributes of type BindField and BindProperty. It is useful to avoid weighing down the code when using 1: 1 relationships between classes. Default: False.

### Examples

Enable binding between elements of the TfrmBindApiSimpleDemo and TTestController classes:
```pascal
type
  [ClassBind (True, 'TTestController')]
  TfrmBindApiSimpleDemo = class (TForm)
```
As above, in compact form:
```pascal
type
  [ClassBind ( 'TTestController')]
  TfrmBindApiSimpleDemo = class (TForm)
```
Disable binding between elements of the TfrmBindApiSimpleDemo and TTestController classes:
```pascal
type
  [ClassBind (False, 'TTestController')]
  TfrmBindApiSimpleDemo = class (TForm)
```
It is possible to define bindings on multiple classes, provided they are registered:
```pascal
type
  [ClassBind (True, 'TTestController', True)]
  [ClassBind (True, 'TTestSecond')]
  TfrmBindApiSimpleDemo = class (TForm)
    [BindFieldTo ('Value', 'TestObject.IntProp')]
    speValue: TSpinEdit;
    [BindField ('Text', 'StrBidirectional', '', 'TTestSecond')]
    edtBidirectional: TEdit;
  private
    {Private declarations}
    ...
  published
     {Public declarations}
    ...
  end;
```
The first ClassBind attribute defines the class as default; in this way, it will not be necessary to spell its name in the attributes that refer to it - in this case, the first attribute [BindFieldTo ('Value', 'TestObject.IntProp')] which does not contain indications on the name of the target class. The second attribute, on the contrary, indicates that the target class to bind to is TTestSecond.

## FieldBind

FieldBind attribute is the superclass of the BindField, BindFieldFrom and BindFieldTo (see below) attributes which indicate that a field of the class or field defined by the SourcePath property must be linked to an element defined by the TargetPath property, belonging to a second class whose name corresponds to the TargetClassName property. FieldBind descentant can be placed before the definition of the class or before the definition of a field of type TObject or record.

FieldBind should never be used; BindAPI will ignore it. Attributes that generalize FieldBind neither introduce properties nor alter the behavior of existing ones.

### Property

- **IsEnabled**: boolean. If True, binding is done, otherwise binding is not done. Default: True.

- **TargetClassName**: string. The name of the class that contains fields and properties to link. If its value is 'Self', the instances of the class will link fields and properties internally. Required.

- **SourcePath**: defines the binding element found in the source class, i.e. the one in which the attribute is inserted. It may contain a path, such as "myField.AProp". Required.

- **TargetPath**: defines the binding element found in the target class, i.e. the one defined by TargetClassName. It may contain a path, such as "myField.AProp". Required.

- **FunctionName**: name of a TplBridgeFunction type function defined within the target class. The value assigned to the element that must receive it will be the result of this function. Optional.

### Examples

See examples of the BindField, BindFieldFrom and BindFieldTo attributes.

### Note

For performance issues, the bind always occurs between fields and properties of two classes; if you need to work with a record, you need to use a class level attribute and identify the record type field with a valid path; you should therefore write:
```pascal
type
  [ClassBind (True, 'TTestBind')]
  [BindFieldTo ('myRecordField.X', 'IntProp')]
  TfrmBindApiSimpleDemo = class (TForm)
     ...
     myRecordField: TMyRecord;
     ...
  end;
```
and not
```pascal
type
  [ClassBind (True, 'TTestBind')]
  TfrmBindApiSimpleDemo = class (TForm)
    ...
    [BindFieldTo ('X', 'IntProp')]
    myRecordField: TMyRecord;
    ...
  end;
```

## BindField

BindField attribute, placed before the definition of the class or before the definition of a field of type TObject or record, indicates that a field of the class or field defined by the SourcePath property must be connected in a bidirectional way to an element defined by the TargetPath property , belonging to a second class whose name corresponds to the TargetClassName property.

Any change in the element of the source class will be propagated to the element of the target class and vice versa.

### Property

See FieldBind.

### Examples

In this example, the values ​​of frmBindApiSimpleDemo.speValue.Value and of testController.TestObject.IntProp are connected in a bidirectional way: if one changes, its new value is automatically propagated to the other.
```pascal
type
  [ClassBind (True, 'TTestController')]
   TfrmBindApiSimpleDemo = class (TForm)
     [BindField ('Value', 'TestObject.IntProp')]
     speValue: TSpinEdit;
   private
...
  end;
```
Alternative:
```pascal
type
  [ClassBind (True, 'TTestController')]
  [BindField (speValue.'Value ',' TestObject.IntProp ')]
  TfrmBindApiSimpleDemo = class (TForm)
     speValue: TSpinEdit;
  private
    ...
  end;
```

## BindFieldFrom

BindFieldFrom attribute, placed before the definition of the class or before the definition of a field of type TObject or record, indicates that the value of a field of the class or field defined by the SourcePath property must receive its value from an element defined by the TargetPath property, belonging to a second class whose name corresponds to the TargetClassName property.

Any change in the element of the target class will be propagated to the element of the source class.

### Property

See FieldBind.

### Examples

In this example, the values ​​of frmBindApiSimpleDemo.speValue.Value and of testController.TestObject.IntProp are connected in a unidirectional way: if the second changes, the first assumes the new value; if the former changes, the latter remains unchanged.
```pascal
type
  [ClassBind (True, 'TTestController')]
   TfrmBindApiSimpleDemo = class (TForm)
     [BindFieldFrom ('Value', 'TestObject.IntProp')]
     speValue: TSpinEdit;
   private
...
  end;
```
Alternative:
```pascal
type
  [ClassBind (True, 'TTestController')]
  [BindFieldFrom (speValue.'Value ',' TestObject.IntProp ')]
  TfrmBindApiSimpleDemo = class (TForm)
     speValue: TSpinEdit;
  private
    ...
  end;
  ```

 ## BindFieldTo

The BindFieldTo attribute, placed before the definition of the class or before the definition of a field of type TObject or record, indicates that the value of a field of the class or field defined by the SourcePath property must be propagated to an element defined by the TargetPath property , belonging to a second class whose name corresponds to the TargetClassName property.

Any change in the element of the source class will be propagated to the element of the target class.

### Property

See FieldBind.

### Examples

In this example, the values ​​of frmBindApiSimpleDemo.speValue.Value and testController.TestObject.IntProp are connected in a unidirectional way: if the former changes, the latter assumes the new value; if the latter changes, the former remains unchanged.
```pascal
type
  [ClassBind (True, 'TTestController')]
   TfrmBindApiSimpleDemo = class (TForm)
     [BindFieldTo ('Value', 'TestObject.IntProp')]
     speValue: TSpinEdit;
   private
...
  end;
```
Alternative:
```pascal
type
  [ClassBind (True, 'TTestController')]
  [BindFieldTo (speValue.'Value ',' TestObject.IntProp ')]
  TfrmBindApiSimpleDemo = class (TForm)
     speValue: TSpinEdit;
  private
    ...
  end;
```

## PropertiesBind

The PropertiesBind attribute is the superclass of the BindProperty, BindPropertyFrom and BindPropertyTo attributes which, placed before the definition of a property, indicate that the property - or a member of it defined by the SourcePath property - must be linked to an element defined by the TargetPath property, member of a second class whose name corresponds to the TargetClassName property.

PropertiesBind should never be used;BindAPI will ignore it. Attributes that generalize PropertiesBind do not introduce properties nor alter the behavior of existing ones.

### Property

- **IsEnabled**: boolean. If True, binding is done, otherwise binding is not done. Default: True.

- **TargetClassName**: string. The name of the class that contains fields and properties to link. If its value is 'Self', the instances of the class will link fields and properties internally. Obligatory.

- **SourcePath**: defines the binding element found in the source class, i.e. the one in which the attribute is inserted. It may contain a path, such as "myField.AProp". If omitted, the property of which it is attributed is considered. Optional.

- **TargetPath**: defines the binding element found in the target class, i.e. the one defined by TargetClassName. It may contain a path, such as "myField.AProp". Obligatory.

- **FunctionName**: name of a TplBridgeFunction type function defined within the target class. The value assigned to the element that must receive it will be the result of this function. Optional.

### Examples

See examples of the BindProperty, BindPropertyFrom and BindPropertyTo attributes.

## BindProperty

The BindProperty attribute, placed before the definition of a property, indicates that the value of the same - or of a member of it defined by the SourcePath property - must be connected in a bidirectional way to that of an element defined by the TargetPath property, belonging to a second class whose name corresponds to the TargetClassName property.

Each new value of the element of the source class will be propagated to the element of the target class and vice versa.

### Property

See PropertiesBind.

### Examples

In this example, the value of the SourceText property is linked bidirectionally to the testController.CurrentText property.
```pascal
type
   [ClassBind (True, 'TTestController')]
   TfrmBindApiSimpleDemo = class (TForm)
   private
     ...
   published
   [BindProperty ('CurrentText')]
   property SourceText: string read GetSourceText write SetSourceText;
   end;
```

## BindPropertyFrom

The BindPropertyFrom attribute, placed before the definition of a property, indicates that the value of the property - or of a member of it defined by the SourcePath property - must be that received by an element defined by the TargetPath property, belonging to a second class whose name corresponds to the TargetClassName property.

Each new value of the target class element will be propagated to the source class element.
### Property

See PropertiesBind.

### Examples

In this example, the value of the frmBindApiSimpleDemo.UpperText property is received directly from the testController.NewValue property.
```pascal
 type
  [ClassBind (True, 'TTestController')]
  TfrmBindApiSimpleDemo = class (TForm)
  private
    ...
  published
    [BindPropertyFrom ( 'UpperText')]
    property UpperText: string read GetUpperText write SetUpperText;
  end;
```
Note this is the simplest form of use of an attribute that derives from PropertiesBind, as it only contains the name of the external property to refer to.

## BindPropertyTo

The BindPropertyTo attribute, placed before the definition of a property, indicates that the value of the property - or of a member of it defined by the SourcePath property - must be propagated to an element defined by the TargetPath property, belonging to a second class whose name corresponds to the TargetClassName property.

Each new value of the source class element will be propagated to the target class element.

### Property

See PropertiesBind.

### Examples

In this example, the value of the Value property is propagated directly to the testController.NewValue property and, through the testController.DoubleOf function, to the testController.DoubleValue property.
```pascal
 type
  [ClassBind (True, 'TTestController')]
  TfrmBindApiSimpleDemo = class (TForm)
  private
    ...
  published
    [BindPropertyTo (True, 'NewValue')]
    [BindPropertyTo ('DoubleValue', 'DoubleOf')]
    property Value: Integer read GetValue write SetValue;
  end;
```
Note that, in the first case, the IsEnabled parameter is present, which in this case would be optional, and the name of the source class property is omitted, since it is assumed to be the property to which the attribute belongs.

In the second case, however, there is also the name of a link function.