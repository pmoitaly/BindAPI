{*****************************************************************************}
{BindAPI                                                                      }
{Copyright (C) 2020 Paolo Morandotti                                          }
{Unit plBindAPI.Attributes                                                    }
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
  /// <summary>
  /// Ancestor class of all BindApi attributes
  /// </summary>
  /// <remarks>
  /// Contains general switch-on and -off bind instructions
  /// </remarks>
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
    /// An attribute is processed only when its IsEnabled property is true.
    /// You can enable or disable any attribute at design time.
    /// If you omits this parameter, BindApi assumes that it is True, so you
    /// can write a bit cleaner code.
    /// </remarks>
    ///  <value>
    ///  Boolean
    ///  </value>
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
    /// Note that the source class is always the class that contains the attribute.
    /// </remarks>
    ///  <value>
    ///  string
    ///  </value>
    property TargetClassName: string read FTargetClassName;
  end;

  /// <summary>
  /// Bridge class register
  /// </summary>
  /// <remarks>
  /// Not used. Reserved for future development
  /// Should be an attribute to register a set of bridge functions.
  /// </remarks>
  RegisterBridgeClassAttribute = class(CustomBindAttribute)

  end;

  /// <summary>
  ///  A Class attribute describing the target class of bind action.
  /// </summary>
  /// <remarks>
  /// This attribute tells that the following class must contains the bind information.
  /// The constructor has many signatures, supporting different options. However, the only mandatory parameter is ATargetClassName.
  /// </remarks>
  ///  <example>
  /// <c>type
  /// [BindClass(True, 'MyBindTargetClass')]
  /// TMyForm = class(TForm)
  ///  public
  ///
  ///  ...</c>
  ///  </example>
  BindClassAttribute = class(CustomBindAttribute)
  protected
    FIsDefault: Boolean;
  public
    /// <summary>
    /// The constructor has many signatures, supporting different options
    /// </summary>
    /// <remarks>
    /// There are four signatures. However, the only mandatory parameter is ATargetClassName.
    /// Set Enabled to False to skip the binding.
    /// </remarks>
    /// <param name="Enabled">
    /// If False the attribute is ignored
    /// </param>
    /// <param name="ATargetClassName">
    /// The name of the class that will be bound
    /// </param>
    /// <param name="IsDefaultClass">
    /// If True, any binding that does not specify the Target class will refer to this one.
    /// This param will be removed in future. Please, use BindDefaultClass instead.
    /// Default: False
    /// </param>
    /// <example>
    ///    <c>type
    ///   { Syntax: [BindClass(True, 'MyBindTargetClass')] }
    ///   TMyClass = class
    ///   ...
    ///    </c>
    ///  </example>
    constructor Create(const Enabled: Boolean; const ATargetClassName: string; const IsDefaultClass: Boolean = False); overload;
    /// <summary>
    /// Initializes a new instance of the <c>BindClassAttribute</c> class with enabled status,
    /// target class name, target class alias, and an optional default class flag.
    /// </summary>
    /// <remarks>
    /// Set Enabled to False to skip the binding. This could be usefull at design time, to test the behaviour of some specific binding.
    /// </remarks>
    /// <param name="Enabled">Indicates whether the binding is enabled.</param>
    /// <param name="ATargetClassName">The name of the target class.</param>
    /// <param name="ATargetClassAlias">The alias for the target class.</param>
    /// <param name="IsDefaultClass">Optional flag indicating if the target class is the default class.
    /// This param will be removed in future. Please, use BindDefaultClass instead.
    /// Default value: <c>False</c></param>
    constructor Create(const Enabled: Boolean; const ATargetClassName, ATargetClassAlias: string; const IsDefaultClass: Boolean = False); overload;
   /// <summary>
    /// Initializes a new instance of the <c>BindClassAttribute</c> class with target class name
    /// and an optional default class flag.
    /// </summary>
    /// <remarks>
    /// Enabled is automatically set to True.
    /// </remarks>
    /// <param name="ATargetClassName">The name of the target class.</param>
    /// <param name="IsDefaultClass">Optional flag indicating if the target class is the default class.
    /// This param will be removed in future. Please, use BindDefaultClass instead.
    /// Default value: <c>False</c></param>
    constructor Create(const ATargetClassName: string; const IsDefaultClass: Boolean = False); overload;
    /// <summary>
    /// Initializes a new instance of the <c>BindClassAttribute</c> class with target class name,
    /// target class alias, and an optional default class flag.
    /// </summary>
    /// <remarks>
    /// Enabled is automatically set to True.
    /// </remarks>
    /// <param name="ATargetClassName">The name of the target class.</param>
    /// <param name="ATargetClassAlias">The alias for the target class.</param>
    /// <param name="IsDefaultClass">Optional flag indicating if the target class is the default class.
    /// This param will be removed in future. Please, use BindDefaultClass instead.
    /// Default value: <c>False</c></param>
    constructor Create(const ATargetClassName, ATargetClassAlias: string; const IsDefaultClass: Boolean = False); overload;
    /// <summary>
    /// Gets a value indicating whether the target class is the default class for this binding.
    /// </summary>
    /// <remarks>
    /// If True, any binding that does not specify the Target class will refer to this one.
    /// This param will be removed in future. Please, use BindDefaultClass instead.
    /// </remarks>
    property IsDefault: Boolean Read FIsDefault;
  end;

  /// <summary>
  ///  An attribute describing the default target class of bind action
  /// </summary>
  /// <remarks>
  /// This attribute contains the bind information. The Target class will be used as default class.
  /// Always place it before the class definition
  /// </remarks>
  BindDefaultClassAttribute = class(BindClassAttribute)
  public
    /// <summary>
    /// Initializes a new instance of the <c>BindDefaultClassAttribute</c> class
    /// with enabled status and the target class name.
    /// </summary>
    /// <remarks>
    /// <para>Set Enabled to False to skip this binding.</para>
    /// <para>No alias will be registered for this class.</para>
    /// <para>IsDefault is automatically set to False.</para>
    /// </remarks>
    /// <param name="Enabled">Indicates whether the binding is enabled.</param>
    /// <param name="ATargetClassName">The name of the class that will be bound.</param>
    constructor Create(const Enabled: Boolean; const ATargetClassName: string); overload;
    /// <summary>
    /// Initializes a new instance of the <c>BindDefaultClassAttribute</c> class with enabled status, the target class name and the target class alias.
    /// </summary>
    /// <remarks>
    /// <para>Set Enabled to False to skip this binding.</para>
    /// <para>IsDefault is automatically set to True.</para>
    /// </remarks>
    /// <param name="Enabled">Indicates whether the binding is enabled.</param>
    /// <param name="ATargetClassName">The name of the class that will be bound.</param>
    /// <param name="ATargetClassAlias"><para>Generic class reference.</para>
    /// <para>When the name of the class to bind is not known in advance,
    /// a generic alias can be entered here that will be used to look up the class in the binding process.</para>
    /// </param>
    constructor Create(const Enabled: Boolean; const ATargetClassName, ATargetClassAlias: string); overload;
    /// <summary>
    /// Initializes a new instance of the <c>BindDefaultClassAttribute</c>
    /// class with the target class name.
    /// </summary>
    /// <remarks>
    /// <para>Enabled is automatically set to True./para>
    /// <para>No alias will be registered for this class.</para>
    /// <para>IsDefault is automatically set to True.</para>
    /// </remarks>
    /// <param name="ATargetClassName">The name of the class that will be bound.</param>
    constructor Create(const ATargetClassName: string); overload;
    /// <summary>
    /// Initializes a new instance of the <c>BindDefaultClassAttribute</c>
    /// class with the target class and the target class alias.
    /// </summary>
    /// <remarks>
    /// <para>Enabled is automatically set to True./para>
    /// <para>IsDefault is automatically set to True.</para>
    /// </remarks>
    /// <param name="ATargetClassName">The name of the class that will be bound.</param>
     /// <param name="ATargetClassAlias"><para>Generic class reference.</para>
    /// <para>When the name of the class to bind is not known in advance,
    /// a generic alias can be entered here that will be used to look up the class in the binding process.</para>
    /// </param>
    constructor Create(const ATargetClassName, ATargetClassAlias: string); overload;
  end;

  /// <summary>
  /// Ancestor class for attributes containing information about a single bind
  /// of methods and events.
  /// </summary>
  /// <remarks>
  /// Use this attribute to replace a method or an event indentified by
  ///  SourceMethidName with the method called NewMethidName in the
  ///  Target class.
  ///  <note type="warning">If the Source's method is already defined, it is
  ///  replaced by the new method and no info is kept. So you will not able
  ///  to restore it.</note>
  /// </remarks>
  BindMethodAttribute = class(CustomBindAttribute)
  private
    /// <summary>
    /// The name of the new method to be used in the binding.
    /// </summary>
    FNewMethodName: string;

    /// <summary>
    /// The qualified name of the source method in the binding.
    /// </summary>
    FSourceMethodName: string;
  public
    /// <summary>
    /// Initializes a new instance of the <c>BindMethodAttribute</c> class with enabled status,
    /// qualified name of the source method, and name of the new method.
    /// </summary>
    /// <param name="Enabled">Indicates whether the binding is enabled.</param>
    /// <param name="AMethodQName">The fully qualified name of the source method.</param>
    /// <param name="ANewMethodName">The name of the new method to be used in the binding.</param>
    /// <example>
    ///  <c>type
    ///   {...}
    ///   [BindDefaultClass(True, 'MyBindTargetClass')]
    ///   [BindMethod(True, 'MyMethod', 'NewMethod')]
    ///   TMyForm := class(TForm)
    ///   public
    ///     MyMethod:  TNotifyEvent;
    ///   {...}
    ///  </c>
    ///  or
    ///  <c>type
    ///   [BindDefaultClass(True, 'MyBindTargetClass')]
    ///   [BindMethod(True, 'Button1.OnClick', 'NewEventHandler'))]
    ///   TMyForm := class(TForm)
    ///     Button1: TButton;
    ///   {...}
    ///  </c>
    ///  </example>
    constructor Create(const Enabled: Boolean; const AMethodQName, ANewMethodName: string); overload;

    /// <summary>
    /// Initializes a new instance of the <c>BindMethodAttribute</c> class with enabled status,
    /// name of the source method, name of the new method, and target class name.
    /// </summary>
    /// <param name="Enabled">Indicates whether the binding is enabled.</param>
    /// <param name="AMethodQName">The fully qualified name of the source method.</param>
    /// <param name="ANewMethodName">The name of the new method to be used in the binding.</param>
    /// <param name="ATargetClassName">Optional name of the target class for the binding.</param>
    constructor Create(const Enabled: Boolean; const AMethodQName, ANewMethodName, ATargetClassName: string); overload;

    /// <summary>
    /// Initializes a new instance of the <c>BindMethodAttribute</c> class with the name of the source method
    /// and the name of the new method to be used in the binding.
    /// </summary>
    /// <param name="AMethodQName">The fully qualified name of the source method.</param>
    /// <param name="ANewMethodName">The name of the new method to be used in the binding.</param>
    constructor Create(const AMethodQName, ANewMethodName: string); overload;

    /// <summary>
    /// Initializes a new instance of the <c>BindMethodAttribute</c> class with the name of the source method,
    /// name of the new method, and target class name.
    /// </summary>
    /// <param name="AMethodName">The name of the source method.</param>
    /// <param name="AMethodQName">The fully qualified name of the source method.</param>
    /// <param name="ATargetClassName">Optional name of the target class for the binding.</param>
    constructor Create(const AMethodQName, ANewMethodName, ATargetClassName: string); overload;

    /// <summary>
    /// Gets the fully qualified name of the new method to be used in the binding.
    /// </summary>
    property NewMethodQName: string read FNewMethodName;

    /// <summary>
    /// Gets the qualified name of the source method.
    /// </summary>
    property SourceMethodName: string read FSourceMethodName;
  end;


  /// <summary>
  ///  Attribute to force bind properties of object's public/published section
  /// </summary>
  /// <remarks>
  /// <para><c>CustomBindMemberAttribute</c> inherits all members of <c>CustomBindAttribute</c>.
  /// Place a <c>CustomBindMemberAttribute</c> subclass before the class definition to
  /// bind its members to a target.
  /// To place such binding outside the class avoids the binding to be inherited
  /// in subclasses.
  /// </remarks>
  /// <example>
  /// <c>type
  ///   [BindDefaultClass(True, 'TTestController')]
  ///   [BindClass(True, 'TTestSecond')]
  ///   [BindMemberTo(True, 'edtSource2.Text', 'CurrentText')]
  ///   [BindMemberFrom(True, 'edtTarget2.Text', 'LowerText')]
  ///   [BindMemberFrom(True, 'edtTarget2a.Text', 'UpperText')]
  ///   TfrmBindApiSimpleDemo = class(TForm)
  ///     edtSource2: TEdit;
  ///     edtTarget2: TEdit;
  ///     edtTarget2a: TEdit;
  ///     {...}
  /// </c>
  /// </example>
  CustomBindMemberAttribute = class(CustomBindAttribute)
  protected
    /// <summary>
    /// Name of the bridge function that handles the binding between source and target.
    /// </summary>
    FFunctionName: string;

    /// <summary>
    /// Qualified name of the source field or property in the source class.
    /// </summary>
    FSourceQName: string;

    /// <summary>
    /// Qualified name of the target field or property in the target class.
    /// </summary>
    FTargetQName: string;
  public
    /// <summary>
    /// Constructor that initializes the binding attribute with enabled status, source member qualified name, target member qualified name, and optional function name and target class name.
    /// </summary>
    /// <description>
    ///  If you omits the ATargetClassName attribute the target member will be searched in the Default Class.
    /// </description>
    /// <param name="Enabled">Indicates whether the binding is enabled.</param>
    /// <param name="ASourceQName">Qualified name of the field or property in the source class.</param>
    /// <param name="ATargetQName">Qualified name of the field or property in the target class.</param>
    /// <param name="AFunctionName">Optional name of the bridge function.</param>
    /// <param name="ATargetClassName">Optional name of the target class.</param>
    constructor Create(const Enabled: Boolean; const ASourceQName, ATargetQName: string; const AFunctionName: string = ''; const ATargetClassName: string = ''); overload;

    /// <summary>
    /// Constructor that initializes the binding attribute with source member qualified name, target member qualified name,
    /// and optional function name and target class name.
    /// </summary>
    /// <remarks>
    ///  IsEnabled property is set to True. Use this shorter signature to create an always-enabled attribute.
    /// </remarks>
    /// <param name="ASourceQName">Qualified name of the field or property in the source class.</param>
    /// <param name="ATargetQName">Qualified name of the field or property in the target class.</param>
    /// <param name="AFunctionName">Optional name of the bridge function.</param>
    /// <param name="ATargetClassName">Optional name of the target class.</param>
    constructor Create(const ASourceQName, ATargetQName: string; const AFunctionName: string = ''; const ATargetClassName: string = ''); overload;

    /// <summary>
    /// Gets the name of the bridge function associated with this binding.
    /// </summary>
    property FunctionName: string read FFunctionName;

    /// <summary>
    /// Gets the qualified name of the field or property in the source class.
    /// </summary>
    property SourceQName: string read FSourceQName;

    /// <summary>
    /// Gets the qualified name of the field or property in the target class.
    /// </summary>
    property TargetQName: string read FTargetQName;
  end;

  /// <summary>
  /// Requires a bi-directional bindig for the involved member.
  /// </summary>
  /// <remarks>
  /// When this attribute is encountered, a bindig is created
  /// from the targets' member to then source's member.
  /// See <see cref="CustomBindMemberAttribute" /> form methods, properties and examples.
  /// </remarks>
  BindMemberAttribute = class(CustomBindMemberAttribute);
  /// <summary>
  /// Requires a bi-directional bindig for the involved member.
  /// </summary>
  /// <remarks>
  /// When this attribute is encountered, a bindig is created
  /// from the source's member to the targets' member.
  /// See <see cref="CustomBindMemberAttribute" /> form methods, properties and examples.
  /// </remarks>
  BindMemberFromAttribute = class(CustomBindMemberAttribute);
  /// <summary>
  /// Requires a bi-directional bindig for the involved member.
  /// </summary>
  /// <remarks>
  /// When this attribute is encountered, a bindig is created
  /// between the source's member and targets' member.
  /// See <see cref="CustomBindMemberAttribute" /> form methods, properties and examples.
  /// </remarks>
  BindMemberToAttribute = class(CustomBindMemberAttribute);

{$IFDEF SUPPORT_08}
  { Compatibility with BindAPI 0.8 - These items will be removed in future releases }
  ClassBindAttribute = class(BindClassAttribute);
  MethodBindAttribute = class(BindMethodAttribute);
  EventBindAttribute = class(BindMethodAttribute);
  { Attribute to force binding on properties of  public/published elements }
  CustomBindFieldAttribute = class(CustomBindMemberAttribute);
  BindFieldAttribute = class(CustomBindFieldAttribute);
  BindFieldFromAttribute = class(CustomBindFieldAttribute);
  BindFieldToAttribute = class(CustomBindFieldAttribute);

  CustomBindPropertyAttribute = class(CustomBindMemberAttribute)
  public
    constructor Create(const Enabled: Boolean; const ATargetName: string; const AFunctionName: string = ''; const ATargetClassName: string = ''); overload;
    constructor Create(const ATargetName: string; const AFunctionName: string = ''; const ATargetClassName: string = ''); overload;
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
constructor BindClassAttribute.Create(const Enabled: Boolean; const ATargetClassName: string; const IsDefaultClass: Boolean);
begin
  FIsDefault := IsDefaultClass;
  FTargetClassName := ATargetClassName;
  FTargetClassAlias := '';
  FIsEnabled := Enabled;
end;

constructor BindClassAttribute.Create(const ATargetClassName: string; const IsDefaultClass: Boolean = False);
begin
  FIsDefault := IsDefaultClass;
  FTargetClassName := ATargetClassName;
  FTargetClassAlias := '';
  FIsEnabled := True;
end;

constructor BindClassAttribute.Create(const ATargetClassName, ATargetClassAlias: string; const IsDefaultClass: Boolean);
begin
  FIsDefault := IsDefaultClass;
  FTargetClassName := ATargetClassName;
  FTargetClassAlias := ATargetClassAlias;
  FIsEnabled := True;
end;

constructor BindClassAttribute.Create(const Enabled: Boolean; const ATargetClassName, ATargetClassAlias: string; const IsDefaultClass: Boolean);
begin
  FIsDefault := IsDefaultClass;
  FTargetClassName := ATargetClassName;
  FTargetClassAlias := ATargetClassAlias;
  FIsEnabled := Enabled;
end;

{$ENDREGION}
{$REGION 'CustomBindMemberAttribute'}

constructor CustomBindMemberAttribute.Create(const Enabled: Boolean; const ASourceQName, ATargetQName: string; const AFunctionName: string = ''; const ATargetClassName: string = '');
begin
  FIsEnabled := Enabled;
  FFunctionName := AFunctionName;
  FSourceQName := ASourceQName;
  FTargetQName := ATargetQName;
  // if empty, use the class name from BindClassAttribute
  FTargetClassName := ATargetClassName;
end;

constructor CustomBindMemberAttribute.Create(const ASourceQName, ATargetQName: string; const AFunctionName: string = ''; const ATargetClassName: string = '');
begin
  FIsEnabled := True;
  FFunctionName := AFunctionName;
  FSourceQName := ASourceQName;
  FTargetQName := ATargetQName;
  // if empty, use the class name from ClassBindAttribute
  FTargetClassName := ATargetClassName;

end;
{$ENDREGION}
{$REGION 'BindMethodAttribute'}

constructor BindMethodAttribute.Create(const Enabled: Boolean; const AMethodQName, ANewMethodName: string);
begin
  FIsEnabled := Enabled;
  FSourceMethodName := AMethodQName;
  FNewMethodName := ANewMethodName;
  FTargetClassName := '';
  // if empty, use the class name from ClassBindAttribute
end;
//
{ Example:
  [BindMethod(True,'myPublicMethod','NewMethod','NameOfClassExposingNewMethod')] }
constructor BindMethodAttribute.Create(const Enabled: Boolean; const AMethodQName, ANewMethodName, ATargetClassName: string);
begin
  FIsEnabled := Enabled;
  FSourceMethodName := AMethodQName;
  FNewMethodName := ANewMethodName;
  FTargetClassName := ATargetClassName;
  // if empty, use the class name from ClassBindAttribute
end;

constructor BindMethodAttribute.Create(const AMethodQName, ANewMethodName, ATargetClassName: string);
begin
  Create(True, AMethodQName, ANewMethodName, ATargetClassName);
end;

constructor BindMethodAttribute.Create(const AMethodQName, ANewMethodName: string);
begin
  Create(True, AMethodQName, ANewMethodName);
end;
{$ENDREGION}
{$REGION 'CustomBindPropertyAttribute'}
{$IFDEF SUPPORT_08}

{ Example: [BindPropertyAttribute(True,'PropertyOfBindedClass','BindedClass')] }
{ Example: [BindFieldFromAttribute(True, 'FieldOfBindedClass')] }
constructor CustomBindPropertyAttribute.Create(const Enabled: Boolean; const ATargetName: string; const AFunctionName: string = ''; const ATargetClassName: string = '');
begin
  FIsEnabled := Enabled;
  FFunctionName := AFunctionName;
  FTargetQName := ATargetName;
  FTargetClassName := ATargetClassName;
  // if empty, use the class name from ClassBindAttribute
end;

constructor CustomBindPropertyAttribute.Create(const ATargetName, AFunctionName, ATargetClassName: string);
begin
  FIsEnabled := True;
  FFunctionName := AFunctionName;
  FTargetQName := ATargetName;
  FTargetClassName := ATargetClassName;
  // if empty, use the class name from ClassBindAttribute
end;
{$ENDIF}
{$ENDREGION}

{$REGION 'DefaultClassBindAttribute' }
constructor BindDefaultClassAttribute.Create(const ATargetClassName, ATargetClassAlias: string);
begin
   inherited Create(ATargetClassName, ATargetClassAlias, True);
end;

constructor BindDefaultClassAttribute.Create(const ATargetClassName: string);
begin
  inherited Create(ATargetClassName, True);
end;

constructor BindDefaultClassAttribute.Create(const Enabled: Boolean; const ATargetClassName, ATargetClassAlias: string);
begin
  inherited Create(Enabled, ATargetClassName, ATargetClassAlias, True);
end;

constructor BindDefaultClassAttribute.Create(const Enabled: Boolean; const ATargetClassName: string);
begin
  inherited Create(Enabled, ATargetClassName, True);
end;

{$ENDREGION}

end.
