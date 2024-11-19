{*****************************************************************************}
{                                                                             }
{Copyright (C) 2020-2024 Paolo Morandotti                                     }
{Unit plBindAPI.BindManagement                                                }
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
/// <summary>
///   Implementation of TPlBindManager.
/// </summary>
/// <remarks>
///  <c>TPlBindManager</c> is a class composed of static methods
/// and implements the binding mechanism between classes.
/// Each class decorated with BindAPI attributes can use its Bind and Unbind
/// methods to set, start and stop binding.
/// </remarks>
unit plBindAPI.BindManagement;

interface

uses
  Classes,
  plBindAPI.Attributes, plBindAPI.AutoBinder, plBindAPI.ClassFactory,
  plBindAPI.Types;

type
  /// <summary>
  /// Manages binding operations and provides utilities for deferred and immediate bindings.
  /// </summary>
  /// <remarks>
  /// <para>Using TPlBindManager is the easiest and fastest way to manage
  /// an application based on the BindAPI framework.</para>
  /// <para>Use this class to parse the attributes of a class and manage BindAPI
  ///  ones' without create any instance of other objects.</para>
  /// <para>It is a completely static class that manacontains an instance of
  /// <see cref="TPlAutoBinder" />, to which it sends information read from
  ///  the attributes of a class (usually a TForm, TFrame or TComponent
  ///  descendant).</para>
  /// </remarks>
  ///  <example>
  ///  The following example comes from the form of <c>BindApiSimpleDemo</c>.
  ///  <code>procedure TfrmBindApiSimpleDemo.FormCreate(Sender: TObject);
  ///  begin
  ///    {Remember: if the bound class is not a singleton, the binder is
  ///     responsible of its destruction}
  ///   TplBindManager.Bind(Self);
  ///  end;
  ///
  ///  procedure TfrmBindApiSimpleDemo.FormDestroy(Sender: TObject);
  ///  begin
  ///    TplBindManager.Unbind(Self);
  ///  end;
  ///  </code>
  ///  </example>
  TPlBindManager = class(TInterfacedObject)
  private
    /// <summary>
    /// Holds the instance of the auto-binder (see <see cref="TPlAutoBinder" />).
    /// </summary>
    class var FBinder: TPlAutoBinder;

    /// <summary>
    /// Adds a deferred binding element for the specified source object.
    /// </summary>
    /// <param name="ASource">The source object to bind.</param>
    /// <param name="AClassAttribute">The binding attribute for the class.</param>
    class procedure AddDeferredElement(ASource: TObject;
      AClassAttribute: BindClassAttribute);

    /// <summary>
    /// Extracts the target object from the specified source object using the given class attribute.
    /// </summary>
    /// <param name="ASource">The source object.</param>
    /// <param name="AClassAttribute">The binding attribute for the class.</param>
    /// <returns>The target object to bind.</returns>
    class function ExtractTarget(ASource: TObject;
      AClassAttribute: BindClassAttribute): TObject;

    /// <summary>
    /// Gets the interval for automatic binding operations.
    /// </summary>
    /// <returns>The interval in milliseconds.</returns>
    class function GetInterval: Integer; static;

    /// <summary>
    /// Sets the interval for automatic binding operations.
    /// </summary>
    /// <param name="Value">The interval in milliseconds.</param>
    class procedure SetInterval(const Value: Integer); static;

  protected
    /// <summary>
    /// Class constructor, initializes static members.
    /// </summary>
    class constructor Create;

    /// <summary>
    /// Class destructor, cleans up static members.
    /// </summary>
    class destructor Destroy;

  public
    /// <summary>
    /// Adds a binding for the specified source object with the given class attribute.
    /// </summary>
    /// <param name="ASource">The source object to bind.</param>
    /// <param name="AClassAttribute">The binding attribute for the class.</param>
    /// <returns>True if the binding was successfully added; otherwise, false.</returns>
    class function AddBind(ASource: TObject;
      AClassAttribute: BindClassAttribute): boolean;

    /// <summary>
    /// Adds a deferred binding for the specified source object.
    /// </summary>
    /// <param name="ASource">The source object to bind.</param>
    /// <returns>True if the deferred binding was successfully added; otherwise, false.</returns>
    class function AddDeferredBind(ASource: TObject): boolean; static;

    /// <summary>
    /// Performs binding operations on the specified source object.
    /// </summary>
    /// <remarks>
    /// The <c>Bind</c> procedure parses the attributes of the <i>ASource</i> object.
    /// If a <see cref="TCustomBindClassAttribute" /> is found, <see cref="TPlBindManager.AddBind" />
    /// is called, which calls the binder's <see cref="TPlAutoBinder|BindObject">BindObject</see> procedure.
    /// </remarks>
    /// <param name="ASource">The source object to bind.</param>
    class procedure Bind(ASource: TObject);

    /// <summary>
    /// Provides debug information about the binding operations.
    /// </summary>
    /// <returns>A <c>TPlBindDebugInfo</c> object containing debug details.</returns>
    class function DebugInfo: TPlBindDebugInfo;

    /// <summary>
    /// Retrieves a list of errors encountered during binding.
    /// </summary>
    /// <returns>A <c>TStrings</c> object containing error messages.</returns>
    class function ErrorList: TStrings;

    /// <summary>
    /// Unbinds the specified source object.
    /// </summary>
    /// <param name="ASource">The source object to unbind.</param>
    class procedure Unbind(ASource: TObject);

    /// <summary>
    /// Gets the instance of the auto-binder.
    ///  <note type="caution">Use this function for monitoring and debug purposes only!</note>
    /// </summary>
    class property Binder: TPlAutoBinder read FBinder;

    /// <summary>
    /// Gets or sets the interval for automatic binding operations.
    /// </summary>
    class property Interval: Integer read GetInterval write SetInterval;
  end;

implementation

uses
  Rtti, StrUtils, TypInfo,
  plBindAPI.DeferredBinding, plBindAPI.RTTIUtils;

resourcestring
  SInvalidArgumentInAddBind = 'Invalid argument in AddBind';

const
  DEFAULT_INTERVAL = 10;

{$REGION 'TPlBindManager'}

class constructor TPlBindManager.Create;
begin
  inherited;
  FBinder := TPlAutoBinder.Create;
  FBinder.Start(DEFAULT_INTERVAL);
end;

class destructor TPlBindManager.Destroy;
begin
  FBinder.Stop;
  FBinder.Free;
  inherited;
end;

class function TPlBindManager.AddBind(ASource: TObject;
  AClassAttribute: BindClassAttribute): boolean;
var
  target: TObject;
begin
  if (not Assigned(ASource)) or (not Assigned(AClassAttribute)) then
    raise EPlBindApiException.Create(SInvalidArgumentInAddBind);

  target := ExtractTarget(ASource, AClassAttribute);
  if Assigned(target) then
    FBinder.BindObject(ASource, target, AClassAttribute)
  else
    AddDeferredElement(ASource, AClassAttribute);
  Result := Assigned(target);
end;

class function TPlBindManager.AddDeferredBind(ASource: TObject): boolean;
var
  rType: TRttiType;
  rAttr: TCustomAttribute;
begin
  Result := True;

  {Extract type information for ASource's type}
  rType := TplRTTIUtils.Context.GetType(ASource.ClassType);
  {Search for the custom attribute and do some custom processing}
  for rAttr in rType.GetAttributes() do
    if rAttr is BindClassAttribute and BindClassAttribute(rAttr).IsEnabled then
      AddDeferredElement(ASource, BindClassAttribute(rAttr));
end;

class procedure TPlBindManager.AddDeferredElement(ASource: TObject;
  AClassAttribute: BindClassAttribute);
var
  deferredElement: TplDeferredElement;
begin
  deferredElement.Attribute := AClassAttribute;
  deferredElement.Source := ASource;
  TPlDeferredBinding.Add(deferredElement);
end;

class procedure TPlBindManager.Bind(ASource: TObject);
var
  rType: TRttiType;
  rAttr: TCustomAttribute;
begin
  {Extract type information for ASource's type}
  rType := TplRTTIUtils.Context.GetType(ASource.ClassType);
  {Search for enabled BindAPI attributes and process them}
  for rAttr in rType.GetAttributes() do
    if rAttr is BindClassAttribute and BindClassAttribute(rAttr).IsEnabled then
      AddBind(ASource, BindClassAttribute(rAttr));
end;

class function TPlBindManager.DebugInfo: TPlBindDebugInfo;
begin
  Result := FBinder.DebugInfo;
end;

class function TPlBindManager.ErrorList: TStrings;
begin
  Result := FBinder.ErrorList;
end;

class function TPlBindManager.ExtractTarget(ASource: TObject;
  AClassAttribute: BindClassAttribute): TObject;
var
  targetName: string;
  target: TObject;
begin
  targetName := AClassAttribute.TargetClassName;
  if (targetName = 'Self') or (targetName = ASource.ClassName) then
    target := ASource
  else
    target := TplClassManager.GetInstance(AClassAttribute.TargetClassName);
  Result := target;
end;

class function TPlBindManager.GetInterval: Integer;
begin
  Result := FBinder.Interval;
end;

class procedure TPlBindManager.SetInterval(const Value: Integer);
begin
  FBinder.Interval := Value;
end;

class procedure TPlBindManager.Unbind(ASource: TObject);
begin
  if Assigned(ASource) then
    begin
      FBinder.UnbindMethods(ASource);
      FBinder.UnbindTarget(ASource);
      FBinder.UnbindSource(ASource);
    end;
end;

{$ENDREGION}

end.
