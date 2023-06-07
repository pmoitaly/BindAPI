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

{*
  GLOSSARY
  Source: The class in which the attribute is defined.
  Target: The remote class involved in the bond.

  Note that "source" and "target" are always related to the attribute,
  not to the flow of information.

*}

{$INCLUDE BindApi.inc}
uses
  System.Variants;

type
  {Ancestor class of all attributes, with switch on and off bind instructions}
  CustomBindAttribute = class(TCustomAttribute)
  protected
    {An attribute will be processed only when IsEnabled is true.}
    FIsEnabled: Boolean;
    {Target class alias is an alias of the class where we search for the
     field/property/method to be bound to an attribute owner
     (or source) elmement. Use it, for instance, in inheritable classes
     to ensure that you can place correct attributes in superclasses.}
    FTargetClassAlias: string;
    {Target class name is the name of the class where we search for the
     field/property/method to be bound to an attribute owner
     (or source) elmement}
    FTargetClassName: string;
  public
    property IsEnabled: Boolean read FIsEnabled;
    property TargetClassAlias: string read FTargetClassAlias;
    property TargetClassName: string read FTargetClassName;
  end;

  {A Class attribute describing the target class of bind action}
  ClassBindAttribute = class(CustomBindAttribute)
  protected
    FIsDefault: Boolean;
  public
    constructor Create(const ATargetClassName: string;
      const IsDefaultClass: Boolean = False); overload;
    constructor Create(const ATargetClassName, ATargetClassAlias: string;
      const IsDefaultClass: Boolean = False); overload;
    constructor Create(const Enabled: Boolean; const ATargetClassName: string;
      const IsDefaultClass: Boolean = False); overload;
    constructor Create(const Enabled: Boolean; const ATargetClassName, ATargetClassAlias: string;
      const IsDefaultClass: Boolean = False); overload;
    property IsDefault: Boolean Read FIsDefault;
  end;

  DefaultClassBindAttribute = class(ClassBindAttribute)
  public
    constructor Create(const Enabled: Boolean; const ATargetClassName: string); overload;
    constructor Create(const Enabled: Boolean; const ATargetClassName, ATargetClassAlias: string); overload;
    constructor Create(const ATargetClassName: string); overload;
    constructor Create(const ATargetClassName, ATargetClassAlias: string); overload;
  end;

  {Ancestor class for class attributes binding methods and events}
  BindMethodAttribute =  class(CustomBindAttribute)
  private
    FNewMethodName: string;
    FSourceMethodName: string;
  public
    constructor Create(const Enabled: Boolean; const AMethodName, ANewMethodName: string); overload;
    constructor Create(const Enabled: Boolean; const AMethodName, ANewMethodName, ATargetClassName: string); overload;
    property NewMethodName: string read FNewMethodName;
    property SourceMethodName: string read FSourceMethodName;
  end;

  MethodBindAttribute = class(BindMethodAttribute); // deprecated;

  {Attribute to force binding on properties of GUI public/published elements}
  CustomBindMemberAttribute = class(CustomBindAttribute)
  protected
    { Name of the brifge function }
    FFunctionName: string;
    { Name of field or property in source class. Full path }
    FSourcePath: string;
    { Name of field or property in target class . Full path }
    FTargetPath: string;
  public
    constructor Create(const Enabled: Boolean; const ASourcePath, ATargetPath: string;
      const AFunctionName: string = ''; const ATargetClassName: string = ''); overload;
    constructor Create(const ASourcePath, ATargetPath: string;
      const AFunctionName: string = ''; const ATargetClassName: string = ''); overload;
    property FunctionName: string read FFunctionName;
    property SourcePath: string read FSourcePath;
    property TargetPath: string read FTargetPath;
  end;

  {Attribute to force binding on properties of object's public/published elements
   from outside the class definition}
  BindMemberAttribute = class(CustomBindMemberAttribute);
  BindMemberFromAttribute = class(CustomBindMemberAttribute);
  BindMemberToAttribute = class(CustomBindMemberAttribute);

{$IFDEF BACKWARD_SUPPORT}
  {Attribute to force binding on properties of GUI public/published elements}
  CustomBindFieldAttribute = class(CustomBindMemberAttribute);
  BindFieldAttribute = class(CustomBindFieldAttribute);
  BindFieldFromAttribute = class(CustomBindFieldAttribute);
  BindFieldToAttribute = class(CustomBindFieldAttribute);


  {Ancestor class for fields and properties bind data}
  CustomBindPropertyAttribute = class(CustomBindMemberAttribute)
  public
    constructor Create(const Enabled: Boolean; const ATargetName: string;
      const AFunctionName: string = '';
      const ATargetClassName: string = ''); overload;
    constructor Create(const ATargetName: string;
      const AFunctionName: string = '';
      const ATargetClassName: string = ''); overload;
//    property TargetName: string read FTargetName; // removed: use TargetPath
  end;

  BindPropertyAttribute = class(CustomBindPropertyAttribute);
  BindPropertyFromAttribute = class(CustomBindPropertyAttribute);
  BindPropertyToAttribute = class(CustomBindPropertyAttribute);
{$ENDIF}

{$REGION 'In progress'}
  CustomBindIndexedFieldAttribute = class(CustomBindMemberAttribute)
  private
    { Value of source index }
    FSourceIndex: Variant;
    { True if the source is indexed }
    FSourceIsIndexed: Boolean;
    { Value of target index }
    FTargetIndex: Variant;
    { True if the target is indexed }
    FTargetIsIndexed: Boolean;
  public
    constructor Create(const Enabled: Boolean; const ATargetName: string;
      const ATargetIndex: Variant; const AFunctionName: string = '';
      const ATargetClassName: string = ''); overload;
    constructor Create(const Enabled: Boolean; const ASourceIndex: Variant;
      const ATargetName: string; const AFunctionName: string = '';
      const ATargetClassName: string = ''); overload;
    constructor Create(const Enabled: Boolean; const ASourceIndex: Variant;
      const ATargetName: string; const ATargetIndex: Variant;
      const AFunctionName: string = '';
      const ATargetClassName: string = ''); overload;
    {Use these signatures when only the target is indexed}
    constructor Create(const ATargetName: string; const ATargetIndex: Variant;
      const AFunctionName: string = '';
      const ATargetClassName: string = ''); overload;
    {Use these signatures when only the source is indexed}
    constructor Create(const ASourceIndex: Variant;
      const ATargetName: string; const AFunctionName: string = '';
      const ATargetClassName: string = ''); overload;
    {Use these signatures when both source and target are indexed}
    constructor Create(const ASourceIndex: Variant; const ATargetName: string;
      const ATargetIndex: Variant; const AFunctionName: string = '';
      const ATargetClassName: string = ''); overload;
    property SourceIndex: Variant read FSourceIndex;
    property SourceIsIndexed: Boolean read FSourceIsIndexed;
    property TargetIndex: Variant read FTargetIndex;
    property TargetIsIndexed: Boolean read FTargetIsIndexed;
end;

  BindIndexedFieldAttribute = class(CustomBindIndexedFieldAttribute);
  BindIndexedFieldFromAttribute = class(CustomBindIndexedFieldAttribute);
  BindIndexedFieldToAttribute = class(CustomBindIndexedFieldAttribute);

  { Attribute class for indexed properties }
  CustomBindIndexedPropertyAttribute = class(CustomBindMemberAttribute)
  private
    { Value of source index }
    FSourceIndex: Variant;
    { True if the source is indexed }
    FSourceIsIndexed: Boolean;
    { Value of target index }
    FTargetIndex: Variant;
    { True if the target is indexed }
    FTargetIsIndexed: Boolean;
  public
    constructor Create(const Enabled: Boolean; const ATargetName: string;
      const ATargetIndex: Variant; const AFunctionName: string = '';
      const ATargetClassName: string = ''); overload;
    constructor Create(const Enabled: Boolean; const ASourceIndex: Variant;
      const ATargetName: string; const AFunctionName: string = '';
      const ATargetClassName: string = ''); overload;
    constructor Create(const Enabled: Boolean; const ASourceIndex: Variant;
      const ATargetName: string; const ATargetIndex: Variant;
      const AFunctionName: string = '';
      const ATargetClassName: string = ''); overload;
    {Use these signatures when only the target is indexed}
    constructor Create(const ATargetName: string; const ATargetIndex: Variant;
      const AFunctionName: string = '';
      const ATargetClassName: string = ''); overload;
    {Use these signatures when only the source is indexed}
    constructor Create(const ASourceIndex: Variant;
      const ATargetName: string; const AFunctionName: string = '';
      const ATargetClassName: string = ''); overload;
    {Use these signatures when both source and target are indexed}
    constructor Create(const ASourceIndex: Variant; const ATargetName: string;
      const ATargetIndex: Variant; const AFunctionName: string = '';
      const ATargetClassName: string = ''); overload;
    property SourceIndex: Variant read FSourceIndex;
    property SourceIsIndexed: Boolean read FSourceIsIndexed;
    property TargetIndex: Variant read FTargetIndex;
    property TargetIsIndexed: Boolean read FTargetIsIndexed;
  end;

  BindIndexedPropertyAttribute = class(CustomBindIndexedPropertyAttribute);
  BindIndexedPropertyFromAttribute = class(CustomBindIndexedPropertyAttribute);
  BindIndexedPropertyToAttribute = class(CustomBindIndexedPropertyAttribute);

{$ENDREGION}

implementation

uses
  System.SysUtils;
{$REGION 'ClassBindAttribute'}

{Syntax: [ClassBind(True, 'MyBindTargetClass')]}
constructor ClassBindAttribute.Create(const Enabled: Boolean;
  const ATargetClassName: string; const IsDefaultClass: Boolean);
begin
  FIsDefault := IsDefaultClass;
  FTargetClassName := ATargetClassName;
  FTargetClassAlias := '';
  FIsEnabled := Enabled;
end;

constructor ClassBindAttribute.Create(const ATargetClassName: string;
 const IsDefaultClass: Boolean = False);
begin
  FIsDefault := IsDefaultClass;
  FTargetClassName := ATargetClassName;
  FTargetClassAlias := '';
  FIsEnabled := True;
end;

constructor ClassBindAttribute.Create(const ATargetClassName,
  ATargetClassAlias: string; const IsDefaultClass: Boolean);
begin
  FIsDefault := IsDefaultClass;
  FTargetClassName := ATargetClassName;
  FTargetClassAlias := ATargetClassAlias;
  FIsEnabled := True;
end;

constructor ClassBindAttribute.Create(const Enabled: Boolean;
  const ATargetClassName, ATargetClassAlias: string;
  const IsDefaultClass: Boolean);
begin
  FIsDefault := IsDefaultClass;
  FTargetClassName := ATargetClassName;
  FTargetClassAlias := ATargetClassAlias;
  FIsEnabled := Enabled;
end;

{$ENDREGION}
{$REGION 'FieldBindAttribute'}

{Example: [BindFormField(True, 'myComponent.Property', 'MyTargetProperty')]}
constructor CustomBindMemberAttribute.Create(const Enabled: Boolean; const ASourcePath,
  ATargetPath: string; const AFunctionName: string = ''; const ATargetClassName: string = '');
begin
  FIsEnabled := Enabled;
  FFunctionName := AFunctionName;
  FSourcePath := ASourcePath;
  FTargetPath := ATargetPath;
  FTargetClassName := ATargetClassName;  // if empty, use the class name from ClassBindAttribute
end;

constructor CustomBindMemberAttribute.Create(const ASourcePath, ATargetPath,
  AFunctionName, ATargetClassName: string);
begin
  FIsEnabled := True;
  FFunctionName := AFunctionName;
  FSourcePath := ASourcePath;
  FTargetPath := ATargetPath;
  FTargetClassName := ATargetClassName;  // if empty, use the class name from ClassBindAttribute

end;
{$ENDREGION}

{$REGION 'MethodBindAttribute'}

{Example: [MethodBind(True, 'myPublicMethod', 'NewMethod')]}
{Example: [EventBind(True, 'Button1.OnClick', 'NewEventHandler'))]}
constructor BindMethodAttribute.Create(const Enabled: Boolean;
  const AMethodName, ANewMethodName: string);
begin
  FIsEnabled := Enabled;
  FSourceMethodName := AMethodName;
  FNewMethodName := ANewMethodName;
  FTargetClassName := '';  // if empty, use the class name from ClassBindAttribute
end;

{Example: [MethodBind(True, 'myPublicMethod', 'NewMethod', 'NameOfClassExposingNewMethod')]}
constructor BindMethodAttribute.Create(const Enabled: Boolean;
  const AMethodName, ANewMethodName, ATargetClassName: string);
begin
  FIsEnabled := Enabled;
  FSourceMethodName := AMethodName;
  FNewMethodName := ANewMethodName;
  FTargetClassName := ATargetClassName;  // if empty, use the class name from ClassBindAttribute
end;
{$ENDREGION}

{$REGION 'CustomBindPropertyAttribute'}
{$IFDEF BACKWARD_SUPPORT}
{Example: [BindPropertyAttribute, (True, 'PropertyOfBindedClass', 'BindedClass')]}
{Example: [BindFieldFromAttribute, (True, 'FieldOfBindedClass')]}
constructor CustomBindPropertyAttribute.Create(const Enabled: Boolean;
  const ATargetName: string; const AFunctionName: string = '';
  const ATargetClassName: string = '');
begin
  FIsEnabled := Enabled;
  FFunctionName := AFunctionName;
  FTargetPath := ATargetName;
  FTargetClassName := ATargetClassName;  // if empty, use the class name from ClassBindAttribute
end;

constructor CustomBindPropertyAttribute.Create(const ATargetName, AFunctionName,
  ATargetClassName: string);
begin
  FIsEnabled := True;
  FFunctionName := AFunctionName;
  FTargetPath := ATargetName;
  FTargetClassName := ATargetClassName;  // if empty, use the class name from ClassBindAttribute
end;
{$ENDIF}
{$ENDREGION}

{$REGION 'CustomBindIndexedPropertyAttribute'}

constructor CustomBindIndexedPropertyAttribute.Create(const ASourceIndex
  : Variant; const ATargetName: string; const ATargetIndex: Variant;
  const AFunctionName, ATargetClassName: string);
begin
  Create(True, ASourceIndex, ATargetName, ATargetIndex, AFunctionName,
    ATargetClassName);
end;

constructor CustomBindIndexedPropertyAttribute.Create(const Enabled: Boolean;
  const ATargetName: string; const ATargetIndex: Variant;
  const AFunctionName, ATargetClassName: string);
begin
  if VarIsNull(ATargetIndex) then
    raise Exception.Create('ATargetIndex is null');
  FTargetIsIndexed := True;
  FSourceIsIndexed := False;
  FTargetIndex := ATargetIndex;
  inherited Create(Enabled, ATargetName, AFunctionName, ATargetClassName);
end;

constructor CustomBindIndexedPropertyAttribute.Create(const ATargetName: string;
  const ATargetIndex: Variant; const AFunctionName, ATargetClassName: string);
begin
  Create(True, ATargetName, ATargetIndex, AFunctionName, ATargetClassName);
end;

constructor CustomBindIndexedPropertyAttribute.Create(const Enabled: Boolean;
  const ASourceIndex: Variant; const ATargetName, AFunctionName,
  ATargetClassName: string);
begin
  if VarIsNull(ASourceIndex) then
    raise Exception.Create('ASourceIndex is null');
  FTargetIsIndexed := False;
  FSourceIsIndexed := True;
  FSourceIndex := ASourceIndex;
  inherited Create(Enabled, ATargetName, AFunctionName, ATargetClassName);
end;

constructor CustomBindIndexedPropertyAttribute.Create(const ASourceIndex
  : Variant; const ATargetName, AFunctionName, ATargetClassName: string);
begin
  Create(True, ASourceIndex, ATargetName, AFunctionName, ATargetClassName);
end;

constructor CustomBindIndexedPropertyAttribute.Create(const Enabled: Boolean;
  const ASourceIndex: Variant; const ATargetName: string;
  const ATargetIndex: Variant; const AFunctionName, ATargetClassName: string);
begin
  if VarIsNull(ASourceIndex) and VarIsNull(ATargetIndex) then
    raise Exception.Create('Indexes are null');
  FTargetIsIndexed := not VarIsNull(ATargetIndex);
  FSourceIsIndexed := not VarIsNull(ASourceIndex);
  FSourceIndex := ASourceIndex;
  FTargetIndex := ATargetIndex;
  inherited Create(Enabled, ATargetName, AFunctionName, ATargetClassName);
end;

{$ENDREGION}
{$REGION 'CustomBindIndexedFieldAttribute'}

constructor CustomBindIndexedFieldAttribute.Create(const ASourceIndex
  : Variant; const ATargetName: string; const ATargetIndex: Variant;
  const AFunctionName, ATargetClassName: string);
begin
  Create(True, ASourceIndex, ATargetName, ATargetIndex, AFunctionName,
    ATargetClassName);
end;

constructor CustomBindIndexedFieldAttribute.Create(const Enabled: Boolean;
  const ATargetName: string; const ATargetIndex: Variant;
  const AFunctionName, ATargetClassName: string);
begin
  if VarIsNull(ATargetIndex) then
    raise Exception.Create('ATargetIndex is null');
  FTargetIsIndexed := True;
  FSourceIsIndexed := False;
  FTargetIndex := ATargetIndex;
  inherited Create(Enabled, ATargetName, AFunctionName, ATargetClassName);
end;

constructor CustomBindIndexedFieldAttribute.Create(const ATargetName: string;
  const ATargetIndex: Variant; const AFunctionName, ATargetClassName: string);
begin
  Create(True, ATargetName, ATargetIndex, AFunctionName, ATargetClassName);
end;

constructor CustomBindIndexedFieldAttribute.Create(const Enabled: Boolean;
  const ASourceIndex: Variant; const ATargetName, AFunctionName,
  ATargetClassName: string);
begin
  if VarIsNull(ASourceIndex) then
    raise Exception.Create('ASourceIndex is null');
  FTargetIsIndexed := False;
  FSourceIsIndexed := True;
  FSourceIndex := ASourceIndex;
  inherited Create(Enabled, ATargetName, AFunctionName, ATargetClassName);
end;

constructor CustomBindIndexedFieldAttribute.Create(const ASourceIndex
  : Variant; const ATargetName, AFunctionName, ATargetClassName: string);
begin
  Create(True, ASourceIndex, ATargetName, AFunctionName, ATargetClassName);
end;

constructor CustomBindIndexedFieldAttribute.Create(const Enabled: Boolean;
  const ASourceIndex: Variant; const ATargetName: string;
  const ATargetIndex: Variant; const AFunctionName, ATargetClassName: string);
begin
  if VarIsNull(ASourceIndex) and VarIsNull(ATargetIndex) then
    raise Exception.Create('Indexes are null');
  FTargetIsIndexed := not VarIsNull(ATargetIndex);
  FSourceIsIndexed := not VarIsNull(ASourceIndex);
  FSourceIndex := ASourceIndex;
  FTargetIndex := ATargetIndex;
  inherited Create(Enabled, ATargetName, AFunctionName, ATargetClassName);
end;

{$ENDREGION}

{$REGION 'DefaultClassBindAttribute' }

constructor DefaultClassBindAttribute.Create(const ATargetClassName,
  ATargetClassAlias: string);
begin

end;

constructor DefaultClassBindAttribute.Create(const ATargetClassName: string);
begin
  inherited Create(ATargetClassName, True);
end;

constructor DefaultClassBindAttribute.Create(const Enabled: Boolean;
  const ATargetClassName, ATargetClassAlias: string);
begin
  inherited Create(Enabled, ATargetClassName, ATargetClassAlias, True);
end;

constructor DefaultClassBindAttribute.Create(const Enabled: Boolean;
  const ATargetClassName: string);
begin
  inherited Create(Enabled, ATargetClassName, True);
end;

{$ENDREGION}

end.
