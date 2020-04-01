# Classes

BindAPI library allows direct binding of members of two instances using the following classes:

- plBindAPI.ClassFactory.TplClassManager
- plBindAPI.BindManagement.TplBindManager
- plBindAPI.CoreBinder.TPlBinder

The first two are used to manage attributes, while the third allows the direct creation of mappings via code.

BindAPI uses other classes and interfaces, which should not need to be accessed directly.

## TplClassManager

```pascal
TplClassManager = class
```
TplClassManager is a class composed of static methods and contains instances of the classes involved in the binding process. Classes must be registered during initialization and can be marked as singleton.

During the parsing of ClassBind type attributes, BindAPI queries TplClassManager to obtain an instance of the classes with whose properties are to be mapped. If a class is marked as a singleton, only one instance is created at the first request; otherwise a new instance is created for each request.

### Property
```pascal
class property Binder: TplAutoBinder read FBinder;
```
The Binder class property allows access to an instance of the TplAutoBinder class, which generalizes TplBinder. This instance is useful if you have to create links via code and not just via attributes.

### Methods
```pascal
class procedure RegisterClass (AClass: TClass; AsSingleton: boolean);
class function GetInstance (const AClassName: string): TObject;
class function IsSingleton (const AClassName: string): Boolean; overload;
class function IsSingleton (const AnInstance: TObject): Boolean; overload;
```

### Examples

RegisterClass must be called in the initialization section to register the classes that must be binded. In this example, two classes are registered, the first as singleton and the second not:
```pascal
initialization
  TplClassManager.RegisterClass (TTestController, true);
  TplClassManager.RegisterClass (TTestSecond, false);
```
In this example, however, a method queries the TplClassManager class to find out if a class is singleton; if it is not, it destroys the instance.
```pascal
...
if TplClassManager.IsSingleton (myObject) then
  myObject.Free;
...
```
or
```pascal
...
if TplClassManager.IsSingleton (myObject.ClassName) then
  myObject.Free;
...
```
The other functions are used internally in the library and are unlikely to be used in other contexts.

## TplBindManager
```pascal
TplBoundObjects = TArray;
TplBindManager = class (TInterfacedObject)
```
TplBindManager is a class composed of static methods and implements the binding mechanism between classes. Each class decorated with the BindAPI attributes must use its Bind and Unbind methods to start and stop mapping its members.

### Property

None.

### Methods
```pascal
class function Bind (ASource: TObject): TplBoundObjects;
class procedure Unbind (ASource: TObject);
```
The Bind function returns an array with instances of the target classes created during the mapping process. If the classes have not been marked as singleton, it is the responsibility of the source class to release the resources, storing the array during binding and using the methods of the TplClassManager class to know which instances are singleton and which are not. In a future version of BindAPI an Unbind method will be implemented which, by receiving a parameter of type TplBoundObjects, will manage the release of the classes.

### Examples

In this example, a form decorated with the BindAPI attributes activates the binding in its OnCreate event and deactivates it in its OnDestroy event.
```pascal
implementation
 uses
   plBindAPI.BindManagement;

 {$ R * .dfm}

TfrmBindApiSimpleDemo.FormCreate procedures (Sender: TObject);
 begin
   {Remember: if any bound class is not a singleton, this class has
              the responsibility to destroy it}
   TplBindManager.Bind (Self);
 end;
 TfrmBindApiSimpleDemo.FormDestroy procedures (Sender: TObject);
 begin
   TplBindManager.Unbind (Self);
 end;
 ```

 ## TplBinder
```pascal
TPlBinder = class (TInterfacedObject)
```
TplBinder is the class that manages all the mappings. The BindAPI attributes produce elements of this class, but it is also possible to create new links programmatically by accessing the property.

Periodically, it checks the values ​​of the source elements and, if they have changed, propagates them to the connected elements.

### Property
```pascal
  property Enabled: Boolean read FEnabled write SetFEnabled;
  property Interval: integer read FInterval write FInterval;
```
- **Enabled**: activates or suspends the control of any changes in the values ​​of the source elements.
- **Interval**: defines the time interval between one check and the next.

### Methods
```pascal
  public
    constructor Create; overload;
    destructor Destroy; override;
   ...
    Bind procedure (ASource: TObject; const APropertySource: string; ATarget: TObject; const APropertyTarget: string; AFunction: TplBridgeFunction = nil);
    BindMethod procedures (ASource: TObject; const AMethodPath: string; ATarget: TObject; const ANewMethodName: string; AFunction: TplBridgeFunction = nil);
    function Count: integer;
    DetachAsSource procedures (ASource: TObject);
    DetachAsTarget procedures (ATarget: TObject);
    Start procedure (const SleepInterval: Integer);
    Stop procedures;
    UpdateValues ​​procedures;
```
### Examples

For examples on how to use the methods exposed by TplBinder please see, for now, the test folder. Real examples will be published as soon as possible.