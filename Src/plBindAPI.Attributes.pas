{*****************************************************************************}
{       BindAPI                                                               }
{       Copyright (C) 2020 Paolo Morandotti                                   }
{       Unit plBindAPI.Attributes                                             }
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

unit plBindAPI.Attributes;

interface

type

  {Ancestor class o switch on and off bind instructions}
  CustomBindAttribute = class(TCustomAttribute)
  protected
    FIsEnabled: Boolean;
    FTargetClassName: string;
  public
    property IsEnabled: Boolean read FIsEnabled;
    property TargetClassName: string read FTargetClassName;
  end;

  {A Class attribute describing the target class of bind action}
  ClassBindAttribute = class(CustomBindAttribute)
  public
    constructor Create(ATargetClassName: string); overload;
    constructor Create(const Enabled: Boolean; ATargetClassName: string); overload;
  end;

  {Ancestor class for class attributes binding methods and events}
  MethodBindAttribute =  class(CustomBindAttribute)
  private
    FSourceMethodName: string;
    FNewMethodName: string;
  public
    constructor Create(const Enabled: Boolean; const AMethodName, ANewMethodName: string); overload;
    constructor Create(const Enabled: Boolean; const AMethodName, ANewMethodName, ATargetClassName: string); overload;
    property SourceMethodName: string read FSourceMethodName;
    property NewMethodName: string read FNewMethodName;
    property TargetClassName: string read FTargetClassName;
  end;

  {Attribute to bind an event}
  EventBindAttribute =  class(MethodBindAttribute);

  {Attribute to force binding on properties of GUI public/published elements}
  FormFieldBindAttribute = class(CustomBindAttribute)
  private
    FFunctionName: string;
    FSourcePath: string;
    FTargetPath: string;
  public
    constructor Create(const ASourcePath, ATargetPath: string;
      const AFunctionName: string = ''; const ATargetClassName: string = ''); overload;
    constructor Create(const Enabled: Boolean; const ASourcePath, ATargetPath: string;
      const AFunctionName: string = ''; const ATargetClassName: string = ''); overload;
    property FunctionName: string read FFunctionName;
    property SourcePath: string read FSourcePath;
    property TargetPath: string read FTargetPath;
  end;

  BindFormFieldAttribute = class(FormFieldBindAttribute);
  BindFormFieldFromAttribute = class(FormFieldBindAttribute);
  BindFormFieldToAttribute = class(FormFieldBindAttribute);

  {Ancestor class for fields and properties bind data}
  AutoBindingAttribute = class(CustomBindAttribute)
  private
    {Name of the validator function}
    FFunctionName: string;
    {Name of field or property in target class}
    FTargetName: string;
  public
    constructor Create(const ATargetName: string;
      const AFunctionName: string = ''; const ATargetClassName: string = ''); overload;
    constructor Create(const Enabled: Boolean; const ATargetName: string;
      const AFunctionName: string = ''; const ATargetClassName: string = ''); overload;
    property FunctionName: string read FFunctionName;
    property TargetClassName: string read FTargetClassName;
    property TargetName: string read FTargetName;
  end;

  PropertiesBindAttribute = class(AutoBindingAttribute);

  BindPropertyAttribute = class(PropertiesBindAttribute);
  BindPropertyFromAttribute = class(PropertiesBindAttribute);
  BindPropertyToAttribute = class(PropertiesBindAttribute);

implementation

{ AutoBindAttribute }

{Syntax: [ClassBind(True, 'MyBindTargetClass')]}
constructor ClassBindAttribute.Create(const Enabled: Boolean;
  ATargetClassName: string);
begin
  FTargetClassName := ATargetClassName;
  FIsEnabled := Enabled;
end;

constructor ClassBindAttribute.Create(ATargetClassName: string);
begin
  FTargetClassName := ATargetClassName;
  FIsEnabled := True;
end;


{ AutoBindingAttribute }

{Example: [BindPropertyAttribute, (True, 'PropertyOfBindedClass', 'BindedClass')]}
{Example: [BindFieldFromAttribute, (True, 'FieldOfBindedClass')]}
constructor AutoBindingAttribute.Create(const Enabled: Boolean;
  const ATargetName: string; const AFunctionName: string = '';
  const ATargetClassName: string = '');
begin
  FIsEnabled := Enabled;
  FFunctionName := AFunctionName;
  FTargetName := ATargetName;
  FTargetClassName := ATargetClassName;  // if empty, use the class name from ClassBindAttribute
end;

constructor AutoBindingAttribute.Create(const ATargetName, AFunctionName,
  ATargetClassName: string);
begin
  FIsEnabled := True;
  FFunctionName := AFunctionName;
  FTargetName := ATargetName;
  FTargetClassName := ATargetClassName;  // if empty, use the class name from ClassBindAttribute
end;

{ MethodBindAttribute }

{Example: [MethodBind(True, 'myPublicMethod', 'NewMethod')]}
{Example: [EventBind(True, 'Button1.OnClick', 'NewEventHandler'))]}
constructor MethodBindAttribute.Create(const Enabled: Boolean;
  const AMethodName, ANewMethodName: string);
begin
  FIsEnabled := Enabled;
  FSourceMethodName := AMethodName;
  FNewMethodName := ANewMethodName;
  FTargetClassName := '';  // if empty, use the class name from ClassBindAttribute
end;

{Example: [MethodBind(True, 'myPublicMethod', 'NewMethod', 'NameOfClassExposingNewMethod')]}
constructor MethodBindAttribute.Create(const Enabled: Boolean;
  const AMethodName, ANewMethodName, ATargetClassName: string);
begin
  FIsEnabled := Enabled;
  FSourceMethodName := AMethodName;
  FNewMethodName := ANewMethodName;
  FTargetClassName := ATargetClassName;  // if empty, use the class name from ClassBindAttribute
end;

{ FormFieldBindAttribute }

{Example: [BindFormField(True, 'myComponent.Property', 'MyTargetProperty')]}
constructor FormFieldBindAttribute.Create(const Enabled: Boolean; const ASourcePath,
  ATargetPath: string; const AFunctionName: string = ''; const ATargetClassName: string = '');
begin
  FIsEnabled := Enabled;
  FFunctionName := AFunctionName;
  FSourcePath := ASourcePath;
  FTargetPath := ATargetPath;
  FTargetClassName := ATargetClassName;  // if empty, use the class name from ClassBindAttribute
end;

constructor FormFieldBindAttribute.Create(const ASourcePath, ATargetPath,
  AFunctionName, ATargetClassName: string);
begin
  FIsEnabled := True;
  FFunctionName := AFunctionName;
  FSourcePath := ASourcePath;
  FTargetPath := ATargetPath;
  FTargetClassName := ATargetClassName;  // if empty, use the class name from ClassBindAttribute

end;



end.
