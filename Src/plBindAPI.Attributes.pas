{ ***************************************************************************** }
{ BindAPI }
{ Copyright (C) 2020 Paolo Morandotti }
{ Unit plBindAPI.Attributes }
{ ***************************************************************************** }
{ }
{ Permission is hereby granted, free of charge, to any person obtaining }
{ a copy of this software and associated documentation files (the "Software"), }
{ to deal in the Software without restriction, including without limitation }
{ the rights to use, copy, modify, merge, publish, distribute, sublicense, }
{ and/or sell copies of the Software, and to permit persons to whom the }
{ Software is furnished to do so, subject to the following conditions: }
{ }
{ The above copyright notice and this permission notice shall be included in }
{ all copies or substantial portions of the Software. }
{ }
{ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS }
{ OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, }
{ FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE }
{ AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER }
{ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING }
{ FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS }
{ IN THE SOFTWARE. }
{ ***************************************************************************** }

unit plBindAPI.Attributes;

interface

{ *
  GLOSSARY
  Source: The class in which the attribute is defined.
  Target: The remote class involved in the bond.

  Note that "source" and "target" are always related to the attribute,
  not to the flow of information.
  They could be renamed to "LeftClass" and "RightClass" in future versions

  * }

{$IFDEF FPC}
{$MODE delphi}{$H+}{$M+}
{$WARN 5079 off} { turn warning experimental off }
{$ENDIF}
{$INCLUDE BindApi.inc}

uses
  Variants;

type
  { /// <summary>
    /// Ancestor class of all BindApi attributes
    /// </summary>
    /// <remarks>
    /// Contains general switch-on and -off bind instructions
    /// </remarks> }
  CustomBindAttribute = class(TCustomAttribute)
  protected
    FIsEnabled: Boolean;
    FTargetClassAlias: string;
    FTargetClassName: string;
  public
    /// <summary>
    /// Enable or disable the attribute.
    /// </summary>
    /// <remarks>
    /// An attribute will be processed only when IsEnabled property is true.
    /// You can enable or disable any attribute at design time, like DUnitX attributes do.
    /// </remarks>
    property IsEnabled: Boolean read FIsEnabled;
    /// <summary>
    /// An alias name for the target class.
    /// </summary>
    /// <remarks>
    /// Target class alias is an alias of the class where we search for the
    /// field/property/method to be bound to an attribute owner
    /// (or source) elmement. Use it, for instance, in inheritable classes
    /// to ensure that you can place correct attributes in superclasses.
    /// </remarks>
    property TargetClassAlias: string read FTargetClassAlias;
    /// <summary>
    /// The target class' name.
    /// </summary>
    /// <remarks>
    /// Target class is the class involved in the binding operation.
    /// Note that the source class is always the class thatt contains the attribute.
    /// </remarks>
    property TargetClassName: string read FTargetClassName;
  end;

  { An attribute to register a set of bridge functions }
  RegisterBridgeClassAttribute = class(CustomBindAttribute)
    { reserved for future use }
  end;

  { A Class attribute describing the target class of bind action }
  BindClassAttribute = class(CustomBindAttribute)
  protected
    FIsDefault: Boolean;
  public
    constructor Create(const Enabled: Boolean; const ATargetClassName: string;
      const IsDefaultClass: Boolean = False); overload;
    constructor Create(const Enabled: Boolean;
      const ATargetClassName, ATargetClassAlias: string;
      const IsDefaultClass: Boolean = False); overload;
    constructor Create(const ATargetClassName: string;
      const IsDefaultClass: Boolean = False); overload;
    constructor Create(const ATargetClassName, ATargetClassAlias: string;
      const IsDefaultClass: Boolean = False); overload;
    property IsDefault: Boolean Read FIsDefault;
  end;

  BindDefaultClassAttribute = class(BindClassAttribute)
  public
    constructor Create(const Enabled: Boolean;
      const ATargetClassName: string); overload;
    constructor Create(const Enabled: Boolean;
      const ATargetClassName, ATargetClassAlias: string); overload;
    constructor Create(const ATargetClassName: string); overload;
    constructor Create(const ATargetClassName, ATargetClassAlias
      : string); overload;
  end;

  { Ancestor class for class attributes binding methods and events }
  BindMethodAttribute = class(CustomBindAttribute)
  private
    FNewMethodName: string;
    FSourceMethodName: string;
  public
    constructor Create(const Enabled: Boolean;
      const AMethodName, ANewMethodName: string); overload;
    constructor Create(const Enabled: Boolean;
      const AMethodName, ANewMethodName, ATargetClassName: string); overload;
    property NewMethodName: string read FNewMethodName;
    property SourceMethodName: string read FSourceMethodName;
  end;

  { Attribute to force binding on properties of GUI public/published elements }
  CustomBindMemberAttribute = class(CustomBindAttribute)
  protected
    { Name of the brifge function }
    FFunctionName: string;
    { Name of field or property in source class. Full path }
    FSourcePath: string;
    { Name of field or property in target class . Full path }
    FTargetPath: string;
  public
    constructor Create(const Enabled: Boolean;
      const ASourcePath, ATargetPath: string; const AFunctionName: string = '';
      const ATargetClassName: string = ''); overload;
    constructor Create(const ASourcePath, ATargetPath: string;
      const AFunctionName: string = '';
      const ATargetClassName: string = ''); overload;
    property FunctionName: string read FFunctionName;
    property SourcePath: string read FSourcePath;
    property TargetPath: string read FTargetPath;
  end;

  { Attribute to force binding on properties of object's public/published
    elements from outside the class definition }
  BindMemberAttribute = class(CustomBindMemberAttribute);
  BindMemberFromAttribute = class(CustomBindMemberAttribute);
  BindMemberToAttribute = class(CustomBindMemberAttribute);

{$IFDEF BACKWARD_SUPPORT}
  { Compatibility with BindAPI 0.8 - These items will be removed in future releases }
  ClassBindAttribute = class(BindClassAttribute);
  MethodBindAttribute = class(BindMethodAttribute);
  EventBindAttribute = class(BindMethodAttribute);
  { Attribute to force binding on properties of  public/published elements }
  CustomBindFieldAttribute = class(CustomBindMemberAttribute);
  BindFieldAttribute = class(CustomBindFieldAttribute);
  BindFieldFromAttribute = class(CustomBindFieldAttribute);
  BindFieldToAttribute = class(CustomBindFieldAttribute);

  { Ancestor class for fields and properties bind data }
  CustomBindPropertyAttribute = class(CustomBindMemberAttribute)
  public
    constructor Create(const Enabled: Boolean; const ATargetName: string;
      const AFunctionName: string = '';
      const ATargetClassName: string = ''); overload;
    constructor Create(const ATargetName: string;
      const AFunctionName: string = '';
      const ATargetClassName: string = ''); overload;
  end;

  BindPropertyAttribute = class(CustomBindPropertyAttribute);
  BindPropertyFromAttribute = class(CustomBindPropertyAttribute);
  BindPropertyToAttribute = class(CustomBindPropertyAttribute);
{$ENDIF}

implementation

uses
  SysUtils;

resourcestring
  StrATargetIndexIsNull = 'ATargetIndex is null';
  StrASourceIndexIsNull = 'ASourceIndex is null';
  StrIndexesAreNull = 'Indexes are null';

{$REGION 'BindClassAttribute'}

  { Syntax: [BindClass(True, 'MyBindTargetClass')] }
constructor BindClassAttribute.Create(const Enabled: Boolean;
  const ATargetClassName: string; const IsDefaultClass: Boolean);
begin
  FIsDefault := IsDefaultClass;
  FTargetClassName := ATargetClassName;
  FTargetClassAlias := '';
  FIsEnabled := Enabled;
end;

constructor BindClassAttribute.Create(const ATargetClassName: string;
  const IsDefaultClass: Boolean = False);
begin
  FIsDefault := IsDefaultClass;
  FTargetClassName := ATargetClassName;
  FTargetClassAlias := '';
  FIsEnabled := True;
end;

constructor BindClassAttribute.Create(const ATargetClassName, ATargetClassAlias
  : string; const IsDefaultClass: Boolean);
begin
  FIsDefault := IsDefaultClass;
  FTargetClassName := ATargetClassName;
  FTargetClassAlias := ATargetClassAlias;
  FIsEnabled := True;
end;

constructor BindClassAttribute.Create(const Enabled: Boolean;
  const ATargetClassName, ATargetClassAlias: string;
  const IsDefaultClass: Boolean);
begin
  FIsDefault := IsDefaultClass;
  FTargetClassName := ATargetClassName;
  FTargetClassAlias := ATargetClassAlias;
  FIsEnabled := Enabled;
end;

{$ENDREGION}
{$REGION 'CustomBindMemberAttribute'}

{ Example: [BindFormField(True, 'myComponent.Property', 'MyTargetProperty')] }
constructor CustomBindMemberAttribute.Create(const Enabled: Boolean;
  const ASourcePath, ATargetPath: string; const AFunctionName: string = '';
  const ATargetClassName: string = '');
begin
  FIsEnabled := Enabled;
  FFunctionName := AFunctionName;
  FSourcePath := ASourcePath;
  FTargetPath := ATargetPath;
  // if empty, use the class name from BindClassAttribute
  FTargetClassName := ATargetClassName;
end;

constructor CustomBindMemberAttribute.Create(const ASourcePath, ATargetPath,
  AFunctionName, ATargetClassName: string);
begin
  FIsEnabled := True;
  FFunctionName := AFunctionName;
  FSourcePath := ASourcePath;
  FTargetPath := ATargetPath;
  // if empty, use the class name from ClassBindAttribute
  FTargetClassName := ATargetClassName;

end;
{$ENDREGION}
{$REGION 'BindMethodAttribute'}

{ Example: [BindMethod(True, 'myPublicMethod', 'NewMethod')] }
{ Example: [BindMethod(True, 'Button1.OnClick', 'NewEventHandler'))] }
constructor BindMethodAttribute.Create(const Enabled: Boolean;
  const AMethodName, ANewMethodName: string);
begin
  FIsEnabled := Enabled;
  FSourceMethodName := AMethodName;
  FNewMethodName := ANewMethodName;
  FTargetClassName := '';
  // if empty, use the class name from ClassBindAttribute
end;

{ Example:
  [BindMethod(True,'myPublicMethod','NewMethod','NameOfClassExposingNewMethod')] }
constructor BindMethodAttribute.Create(const Enabled: Boolean;
  const AMethodName, ANewMethodName, ATargetClassName: string);
begin
  FIsEnabled := Enabled;
  FSourceMethodName := AMethodName;
  FNewMethodName := ANewMethodName;
  FTargetClassName := ATargetClassName;
  // if empty, use the class name from ClassBindAttribute
end;
{$ENDREGION}
{$REGION 'CustomBindPropertyAttribute'}
{$IFDEF BACKWARD_SUPPORT}

{ Example: [BindPropertyAttribute(True,'PropertyOfBindedClass','BindedClass')] }
{ Example: [BindFieldFromAttribute(True, 'FieldOfBindedClass')] }
constructor CustomBindPropertyAttribute.Create(const Enabled: Boolean;
  const ATargetName: string; const AFunctionName: string = '';
  const ATargetClassName: string = '');
begin
  FIsEnabled := Enabled;
  FFunctionName := AFunctionName;
  FTargetPath := ATargetName;
  FTargetClassName := ATargetClassName;
  // if empty, use the class name from ClassBindAttribute
end;

constructor CustomBindPropertyAttribute.Create(const ATargetName, AFunctionName,
  ATargetClassName: string);
begin
  FIsEnabled := True;
  FFunctionName := AFunctionName;
  FTargetPath := ATargetName;
  FTargetClassName := ATargetClassName;
  // if empty, use the class name from ClassBindAttribute
end;
{$ENDIF}
{$ENDREGION}
{$REGION 'CustomBindIndexedPropertyAttribute'}
{$ENDREGION}
{$REGION 'CustomBindIndexedFieldAttribute'}
{$ENDREGION}
{$REGION 'DefaultClassBindAttribute' }

constructor BindDefaultClassAttribute.Create(const ATargetClassName,
  ATargetClassAlias: string);
begin

end;

constructor BindDefaultClassAttribute.Create(const ATargetClassName: string);
begin
  inherited Create(ATargetClassName, True);
end;

constructor BindDefaultClassAttribute.Create(const Enabled: Boolean;
  const ATargetClassName, ATargetClassAlias: string);
begin
  inherited Create(Enabled, ATargetClassName, ATargetClassAlias, True);
end;

constructor BindDefaultClassAttribute.Create(const Enabled: Boolean;
  const ATargetClassName: string);
begin
  inherited Create(Enabled, ATargetClassName, True);
end;

{$ENDREGION}

end.
