# BindAPI 0.9 Changes

## 0.9.0.0 Alpha Release 1
This is a full rewritten version of BindAPI. After many year of internal use, the goal and the structure of the library are a bit different - not sure if the name BindAPI still reflects its new structure.

Howewer, BindAPI proven itself to be a great tool to avoid annoying tasks in operations like setup and configuration management, etc., so there is the new version. Main changes are:

#### General
- All units and classes contains their documentation in XML document format.
- Unit `plBindApi.BinderElement.pas` renamed to `plBindApi.BindingElement.pas`.
- All strings (should be) placed in resourcestring section of the units (Work in progress).

### Main Changes

#### Attributes
- Class binding supports alias for the target class' name.
- All attributes names are now in the form Bind(Class|Member|Method)[(From|To)]Attribute.
- Old names are supported defining the var `SUPPORT_08`.
Please, see the HTML Documentation and the demo to see how update projects using 0.8 version.

#### TPlBinder
-DetachAsSource and DetachAsTarget methods are deprecated. Use UnbindSource and UnbindMethod.

#### plBindApi.BinderElement
- The name of the unit was changed to `plBindApi.BindingElement`.
- The `TplRTTIMemberBind` was renamed to `TPlBindingElement`.
- `TPlBindingElement.ClassAlias`property added. 
- `function TPlBindingElement.IsEqualTo` method added. 
- `TPlPropertyBind` was removed. Use `TPlBindingElement`.

#### TPlClassManager
- `class procedure RegisterClass` accepts a params list for call to a class constructor. 

### New

#### EPlBindApiException
Exception raised by BindAPI framework.

#### TPlAutoBinder
- `function DebugInfo: TPlBindDebugInfo`: Returns a  structure containing debug info.  
- `function ErrorList: string`:Returns the errors recorded in binding process.

#### TPlBindDebugInfo
A record with some info for debug.

#### TPlAutoBindOptions
A record with some set used in bindings. See their use in demo applications.  

#### TPlBinder
- `property Status: TPlBinderStatus` Reflects the activity of the thread.
- `procedure AddError`: Adds a line of text to the error list.
- `procedure BindObject`: Performs a bind between a class or an instance and a registered class. 
- `procedure Clear`: Clears all current bindings.
- `function Count: integer`: Gets the count of registered binding sources.
- `function DebugInfo: TPlBindDebugInfo`: Provides debug information about the current state of the binder.
- `function ErrorList: string`: Returns the errors recorded in binding process.

#### TplBindManager
- Can manage deferred binding, by request or when the target class is not yet registered.
- `procedure AddBinding` Adds a new binding to the list.
- `procedure AddDeferredBinding`: Adds a new binding to the list.
- `function ErrorList: string`: Returns the errors recorded in binding process.
- `function DebugInfo: TPlBindDebugInfo`: Rreturns a structure containing debug info.  
- `class property Interval: Integer`: Gets and sets the TPlAutoBinder's instance `Interval`. 

#### TPlClassManager
- `class procedure Clear`: Removes all registered classes. 
- `class function Instances: TPlInstanceList`: Returns a copy of the internal instances list.
- `class function IsRegistered: Boolean`: Returns True if a class is registered. 
- `class function RegisteredClasses: TPlClassList`: Returns a copy of the registered classes list.
- `class procedure UnregisterInstance:`: Remove a class and its instances from the register. 

#### TPlDeferredElement and TPlDeferredBinding
New classes to manage deferred binding.

#### TPlRTTIUtils
New static class with a lot of function to simplify RTTI operations. You can use it as utility class in your projects.

#### Templates
Version 0.9 comes with a set of four Live Templates for fast typing of BindClass, BindMethod, BindMember attributes.
