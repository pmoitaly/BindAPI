{*****************************************************************************}
{                                                                             }
{Copyright (C) 2020-2024 Paolo Morandotti                                     }
{Unit plBindAPI.AutoBinder                                                    }
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
unit plBindAPI.AutoBinder;

interface

uses
  Classes, Rtti, Generics.Collections,
  plBindAPI.Types, plBindAPI.BindingElement, plBindAPI.Attributes,
  plBindAPI.CoreBinder;

{$UNDEF SUPPORT_08}

type

  /// <summary>
  /// TPlAutoBinder is a class that implements the IplAutoBinder interface and provides functionality for automatic binding between objects.
  /// </summary>
  /// <remarks>
  /// This class is designed to bind properties of one object to another, allowing for automatic synchronization of data between them.
  /// It can be used to create data-binding scenarios where changes in one object's properties are automatically reflected in another.
  /// </remarks>
  /// <example>
  /// <code>
  /// // Example usage of TPlAutoBinder
  /// var
  ///   AutoBinder: IplAutoBinder;
  ///   SourceObject, TargetObject: TObject;
  /// begin
  ///   AutoBinder := TPlAutoBinder.Create;
  ///   try
  ///     AutoBinder.Bind(SourceObject, 'PropertyName', TargetObject, 'PropertyName');
  ///     // Perform operations with the bound objects
  ///   finally
  ///     AutoBinder.Free;
  ///   end;
  /// end.
  /// </code>
  /// </example>
  /// <seealso cref="IplAutoBinder">IplAutoBinder Interface</seealso>
  TPlAutoBinder = class(TInterfacedObject, IplAutoBinder)
  private
    /// <summary>Aggregates a TPlBinder instance used for binding management.</summary>
    FBinder: TPlBinder;
    /// <summary>List of objects that are currently bound.</summary>
    FBoundObjectsList: TPlListObjects;
    /// <summary>
    /// Performs class-level binding between a source and a target object using
    /// a BindClassAttribute.
    /// </summary>
    /// <returns>True if binding was successful; otherwise, false.</returns>
    function BindClass(ASource, aTarget: TObject;
      AClassAttribute: BindClassAttribute): boolean;
    /// <summary>
    /// Binds attributes from a source object to a target object based on a
    /// given BindClassAttribute.
    /// </summary>
    procedure BindInnerAttributes(ASource, aTarget: TObject;
      AClassAttribute: BindClassAttribute);
    /// <summary>
    /// Binds a specific member between the source and target objects based
    /// on custom and class binding attributes.
    /// </summary>
    /// <param name="AMemberName">Optional name of the member to bind.</param>
    procedure BindMember(ASource, aTarget: TObject;
      AMemberAttribute: CustomBindMemberAttribute;
      AClassAttribute: BindClassAttribute; AMemberName: string = '');
    /// <summary>
    /// Binds members from a source object to a target object using a list of
    /// fields.
    /// </summary>
    procedure BindMembers(ASource, aTarget: TObject;
      AClassAttribute: BindClassAttribute; AList: TarFields); overload;
    /// <summary>
    /// Binds members from a source object to a target object using a list of
    /// properties.
    /// </summary>
    procedure BindMembers(ASource, aTarget: TObject;
      AClassAttribute: BindClassAttribute; AList: TarProperties); overload;
    /// <summary>
    /// Binds a specific method between the source and target objects based on
    /// method and class binding attributes.
    /// </summary>
    procedure BindMethod(ASource, aTarget: TObject;
      AMethodAttribute: BindMethodAttribute;
      AClassAttribute: BindClassAttribute);
    /// <summary>
    /// Binds methods from the source object to the target object based on a
    /// list of method attributes.
    /// </summary>
    procedure BindMethods(ASource, aTarget: TObject;
      AClassAttribute: BindClassAttribute; AList: TarMethods);
    /// <summary>
    /// Binds all attributes of a source object to a target object using
    /// a BindClassAttribute.
    /// </summary>
    procedure BindOuterAttributes(ASource, aTarget: TObject;
      AClassAttribute: BindClassAttribute);
    /// <summary>
    /// Checks if a specific binding is possible between objects based on provided attributes.
    /// </summary>
    /// <returns>True if binding is possible; otherwise, false.</returns>
    function CanBind(AClassAttribute: BindClassAttribute;
      AMemberAttribute: CustomBindAttribute; aTarget: TObject): boolean;
    /// <summary>
    /// Finds a function within the owner object by name for custom calculations.
    /// </summary>
    /// <param name="AFunctionName">The name of the function to find.</param>
    /// <returns>The function found, or nil if no matching function is found.</returns>
    function FindCalculatingFuncion(AnOwner: TObject;
      const AFunctionName: string): TplBridgeFunction;
    /// <summary>
    /// Finds the source object associated with a given field.
    /// </summary>
    /// <returns>The source object if found, or nil otherwise.</returns>
    function FindSource(AField: TRttiField; AnObject: TObject;
      const APath: string): TObject; overload;
    /// <summary>
    /// Finds the source object associated with a given property.
    /// </summary>
    /// <returns>The source object if found, or nil otherwise.</returns>
    function FindSource(AProperty: TRttiProperty; AnObject: TObject;
      const APath: string): TObject; overload;
    /// <summary>Gets the enabled state of the binding.</summary>
    function GetEnabled: boolean;
    /// <summary>Gets the interval at which bindings are updated.</summary>
    function GetInterval: integer;
    /// <summary>Determines if the binding is from a specified attribute.</summary>
    /// <returns>True if the binding is from the specified attribute; otherwise, false.</returns>
    function IsBindFrom(AnAttribute: CustomBindMemberAttribute): boolean;
    /// <summary>Determines if the binding is to a specified attribute.</summary>
    /// <returns>True if the binding is to the specified attribute; otherwise, false.</returns>
    function IsBindTo(AnAttribute: CustomBindMemberAttribute): boolean;
    /// <summary>Sets the enabled state of the binding.</summary>
    procedure SetEnabled(const Value: boolean);
    /// <summary>Sets the interval at which bindings are updated.</summary>
    procedure SetInterval(const Value: integer);
    /// <summary>Stops binding a specific method based on the method attribute.</summary>
    procedure UnbindMethod(ASource: TObject;
      AMethodAttribute: BindMethodAttribute);
    /// <summary>Stops binding methods.</summary>
    procedure UnbindMethods; overload;
  public
    /// <summary>Initializes a new instance of the TPlAutoBinder class.</summary>
    constructor Create;
    /// <summary>Releases resources used by the TPlAutoBinder class.</summary>
    destructor Destroy; override;
    /// <summary>
    /// Binds a source property to a target property, optionally using a custom bridge function.
    /// </summary>
    /// <param name="APropertySource">The source property to bind.</param>
    /// <param name="APropertyTarget">The target property to bind.</param>
    /// <param name="AFunction">Optional custom function for transformation.</param>
    procedure Bind(ASource: TObject; const APropertySource: string;
      aTarget: TObject; const APropertyTarget: string;
      AFunction: TplBridgeFunction = nil);
    /// <summary>Retrieves a list of currently bound objects.</summary>
    /// <returns>A list of bindings in TPlBindList format.</returns>
    function BindInfo: TPlBindList;
    /// <summary>
    /// Binds an entire object from a source to a target using the specified class attribute.
    /// </summary>
    procedure BindObject(ASource, aTarget: TObject;
      AClassAttribute: BindClassAttribute);
    /// <summary>Counts the number of current bindings.</summary>
    /// <returns>The total number of bindings.</returns>
    function Count: integer;
    /// <summary>Provides debug information about current bindings.</summary>
    /// <returns>A TplBindDebugInfo instance with debugging details.</returns>
    function DebugInfo: TplBindDebugInfo;
    /// <summary>Gets a list of any errors encountered during binding.</summary>
    /// <returns>A TStrings object containing error messages.</returns>
    function ErrorList: TStrings;
    /// <summary>Starts the binding process with an optional update interval.</summary>
    /// <param name="AnInterval">Optional interval for binding updates in milliseconds.</param>
    procedure Start(const AnInterval: integer = 0);
    /// <summary>Stops the binding process.</summary>
    procedure Stop;
    /// <summary>Unbinds all methods from the source object.</summary>
    procedure UnbindMethods(ASource: TObject); overload;
    /// <summary>Unbinds all bindings related to the specified source object.</summary>
    procedure UnbindSource(ASource: TObject);
    /// <summary>Unbinds all bindings related to the specified target object.</summary>
    procedure UnbindTarget(aTarget: TObject); overload;
    /// <summary>Unbinds all bindings related to a specified source and target object pair.</summary>
    procedure UnbindTarget(aTarget, ASource: TObject); overload;
    /// <summary>Updates values in bound objects based on the current binding configuration.</summary>
    procedure UpdateValues;
    /// <summary>Gets or sets whether the binding is enabled.</summary>
    property Enabled: boolean read GetEnabled write SetEnabled;
    /// <summary>Gets or sets the update interval for the binding process.</summary>
    property Interval: integer read GetInterval write SetInterval;
  end;

implementation

uses
  TypInfo, StrUtils,
  plBindAPI.RTTIUtils, System.SysUtils;

{$REGION 'TplAutoBinder'}

constructor TPlAutoBinder.Create;
begin
  inherited;
  FBinder := TPlBinder.Create;
  FBoundObjectsList := TPlListObjects.Create;
end;

destructor TPlAutoBinder.Destroy;
begin
  UnbindMethods;
  FBoundObjectsList.Free;
  FBinder.Free;
  inherited;
end;

procedure TPlAutoBinder.Bind(ASource: TObject; const APropertySource: string;
  aTarget: TObject; const APropertyTarget: string;
  AFunction: TplBridgeFunction);
begin
  FBinder.Bind(ASource, APropertySource, aTarget, APropertyTarget, AFunction);
end;

procedure TPlAutoBinder.BindInnerAttributes(ASource, aTarget: TObject;
  AClassAttribute: BindClassAttribute);
var
  rFields: TarFields;
  rMethods: TarMethods;
  rProperties: TarProperties;
  rType: TRttiType;
begin
  rType := TplRTTIUtils.Context.GetType(ASource.ClassType);
  rFields := rType.GetFields;
  rMethods := rType.GetMethods;
  rProperties := rType.GetProperties;
{$IFDEF SUPPORT_08}
  BindProperties(ASource, aTarget, AClassAttribute, rProperties);
  BindFields(ASource, aTarget, AClassAttribute, rFields);
{$ENDIF}
  BindMembers(ASource, aTarget, AClassAttribute, rFields);
  BindMembers(ASource, aTarget, AClassAttribute, rProperties);
  BindMethods(ASource, aTarget, AClassAttribute, rMethods);
end;

function TPlAutoBinder.BindClass(ASource, aTarget: TObject;
  AClassAttribute: BindClassAttribute): boolean;
var
  classBinderAttr: BindClassAttribute;
  rAttr: TCustomAttribute;
  rAttributes: TarAttributes;
  rType: TRttiType;
begin
  Result := False;
  if not Assigned(aTarget) then
    Exit;
  {Get class' attributes}
  rType := TplRTTIUtils.Context.GetType(ASource.ClassType);
  rAttributes := rType.GetAttributes;
  for rAttr in rAttributes do
    if rAttr is BindClassAttribute then
      begin
        classBinderAttr := BindClassAttribute(rAttr);
        if (classBinderAttr.IsEnabled) and
          ((classBinderAttr.TargetClassName = aTarget.ClassName) or
          (AClassAttribute.TargetClassAlias = aTarget.ClassName)) then
          begin
            FBoundObjectsList.Add(ASource);
            Result := True;
            Break;
          end;
      end;
end;

procedure TPlAutoBinder.BindOuterAttributes(ASource, aTarget: TObject;
  AClassAttribute: BindClassAttribute);
var
  rAttr: TCustomAttribute;
  rAttributes: TarAttributes;
  rType: TRttiType;
begin
  rType := TplRTTIUtils.Context.GetType(ASource.ClassType);
  rAttributes := rType.GetAttributes;
  for rAttr in rAttributes do
{$IFDEF SUPPORT_08}
    if rAttr is CustomBindFieldAttribute then
      BindField(ASource, aTarget, CustomBindFieldAttribute(rAttr),
        AClassAttribute)
    else
{$ENDIF}
      if rAttr is CustomBindMemberAttribute then
        BindMember(ASource, aTarget, CustomBindMemberAttribute(rAttr),
          AClassAttribute)
      else if rAttr is BindMethodAttribute then
        BindMethod(ASource, aTarget, BindMethodAttribute(rAttr),
          AClassAttribute);
end;

{$IFDEF SUPPORT_08}

procedure TPlAutoBinder.BindField(ASource, aTarget: TObject;
  AMemberAttribute: CustomBindMemberAttribute;
  AClassAttribute: ClassBindAttribute; AFieldName: string = '');
var
  bridgeFunction: TplBridgeFunction;
  separator: string;
  sourceObject: TObject;
  sourcePath: string;
  targetObject: TObject;
  targetPath: string;
begin
  if CanBind(AClassAttribute, AMemberAttribute, aTarget) then
    begin
      bridgeFunction := FindCalculatingFuncion(aTarget,
        AMemberAttribute.FunctionName);

      sourcePath := AMemberAttribute.sourcePath;
      separator := IfThen(sourcePath <> '', '.', '');
      if AFieldName <> '' then
        sourcePath := AFieldName + separator + sourcePath;
      targetPath := AMemberAttribute.targetPath;
      sourceObject := FBinder.NormalizePath(ASource, sourcePath);
      targetObject := FBinder.NormalizePath(aTarget, targetPath);

      if IsBindFrom(AMemberAttribute) then
        Bind(targetObject, targetPath, sourceObject, sourcePath,
          bridgeFunction);
      if IsBindTo(AMemberAttribute) then
        Bind(sourceObject, sourcePath, targetObject, targetPath,
          bridgeFunction);
    end;
end;

procedure TPlAutoBinder.BindFields(ASource, aTarget: TObject;
  AClassAttribute: ClassBindAttribute; AList: TarFields);
var
  bindSource: TObject;
  rAttr: TCustomAttribute;
  rField: TRttiField;
begin
  for rField in AList do
    {Search for the custom attribute and do some custom processing}
    for rAttr in rField.GetAttributes() do
      if (rAttr is CustomBindFieldAttribute) and
        (rField.Visibility in [mvPublic, mvPublished]) then
        BindField(ASource, aTarget, CustomBindFieldAttribute(rAttr),
          AClassAttribute, rField.Name)
        //else if (rAttr is CustomBindMemberAttribute)
        //and (rField.Visibility in [mvPublic, mvPublished]) then
        //begin
        //{If the field value is an object, it becomes the bind source}
        //bindSource := FindSource(rField, ASource);
        //BindMember(bindSource, ATarget, CustomBindFieldAttribute(rAttr),
        //AClassAttribute, rField.Name)
        //end
      else if rAttr is BindMethodAttribute then
        BindMethod(rField.GetValue(ASource).AsObject, aTarget,
          BindMethodAttribute(rAttr), AClassAttribute);
end;
{$ENDIF}

function TPlAutoBinder.BindInfo: TPlBindList;
begin
  Result := FBinder.BindInfo;
end;

procedure TPlAutoBinder.BindMember(ASource, aTarget: TObject;
  AMemberAttribute: CustomBindMemberAttribute;
  AClassAttribute: BindClassAttribute; AMemberName: string = '');
var
  bridgeFunction: TplBridgeFunction;
  sourceObject: TObject;
  sourcePath: string;
  targetObject: TObject;
  targetPath: string;
begin
  if CanBind(AClassAttribute, AMemberAttribute, aTarget) then
    begin
      bridgeFunction := FindCalculatingFuncion(aTarget,
        AMemberAttribute.FunctionName);
      sourcePath := IfThen(MatchStr(AMemberAttribute.SourceQName,
        PL_SELF_ALIAS), AMemberName, AMemberAttribute.SourceQName);
      targetPath := AMemberAttribute.TargetQName;
      sourceObject := ASource;
      targetObject := aTarget; //FBinder.NormalizePath(ATarget, targetPath);

      if IsBindFrom(AMemberAttribute) then
        Bind(targetObject, targetPath, sourceObject, sourcePath,
          bridgeFunction);
      if IsBindTo(AMemberAttribute) then
        Bind(sourceObject, sourcePath, targetObject, targetPath,
          bridgeFunction);
    end;
end;

procedure TPlAutoBinder.BindMembers(ASource, aTarget: TObject;
  AClassAttribute: BindClassAttribute; AList: TarFields);
var
  bindSource: TObject;
  rAttr: TCustomAttribute;
  rField: TRttiField;
begin
  for rField in AList do
    {Search for the custom attribute and do some custom processing}
    for rAttr in rField.GetAttributes() do
      if (rAttr is CustomBindMemberAttribute) and
        (rField.Visibility in [mvPublic, mvPublished]) then
        begin
          {If the field value is an object, it becomes the bind source}
          bindSource := FindSource(rField, ASource,
            CustomBindMemberAttribute(rAttr).SourceQName);
          BindMember(bindSource, aTarget, CustomBindMemberAttribute(rAttr),
            AClassAttribute, rField.Name)
        end
      else if rAttr is BindMethodAttribute then
        BindMethod(rField.GetValue(ASource).AsObject, aTarget,
          BindMethodAttribute(rAttr), AClassAttribute);
end;

procedure TPlAutoBinder.BindMembers(ASource, aTarget: TObject;
  AClassAttribute: BindClassAttribute; AList: TarProperties);
var
  bindSource: TObject;
  rAttr: TCustomAttribute;
  rField: TRttiProperty;
begin
  for rField in AList do
    {Search for the custom attribute and do some custom processing}
    for rAttr in rField.GetAttributes() do
      if (rAttr is CustomBindMemberAttribute) and
        (rField.Visibility in [mvPublic, mvPublished]) then
        begin
          { TODO 5 -oPMo -cDebugging : The call to FindSource could be useless after
            the most recent changes. }
          {If the field value is an object, it becomes the bind source}
          bindSource := FindSource(rField, ASource,
            CustomBindMemberAttribute(rAttr).SourceQName);
          BindMember(bindSource, aTarget, CustomBindMemberAttribute(rAttr),
            AClassAttribute, rField.Name)
          //
          //          BindMember(ASource, aTarget, CustomBindMemberAttribute(rAttr),
          //            AClassAttribute, rField.Name)
        end
      else if rAttr is BindMethodAttribute then
        BindMethod(rField.GetValue(ASource).AsObject, aTarget,
          BindMethodAttribute(rAttr), AClassAttribute);
end;

procedure TPlAutoBinder.BindMethod(ASource, aTarget: TObject;
  AMethodAttribute: BindMethodAttribute; AClassAttribute: BindClassAttribute);
begin
  if CanBind(AClassAttribute, AMethodAttribute, aTarget) then
    FBinder.BindMethod(ASource, AMethodAttribute.SourceMethodName, aTarget,
      AMethodAttribute.NewMethodQName);
end;

procedure TPlAutoBinder.BindMethods(ASource, aTarget: TObject;
  AClassAttribute: BindClassAttribute; AList: TarMethods);
var
  rAttr: TCustomAttribute;
  rMethod: TRttiMethod;
begin
  for rMethod in AList do
    {Search for the custom attribute and do some custom processing}
    for rAttr in rMethod.GetAttributes() do
      if rAttr is BindMethodAttribute then
        BindMethod(ASource, aTarget, BindMethodAttribute(rAttr),
          AClassAttribute);
end;

procedure TPlAutoBinder.BindObject(ASource, aTarget: TObject;
  AClassAttribute: BindClassAttribute);
begin
  if BindClass(ASource, aTarget, AClassAttribute) then
    begin
      BindOuterAttributes(ASource, aTarget, AClassAttribute);
      BindInnerAttributes(ASource, aTarget, AClassAttribute);
    end;
end;

{$IFDEF SUPPORT_08}

procedure TPlAutoBinder.BindProperties(ASource, aTarget: TObject;
  AClassAttribute: ClassBindAttribute; AList: TarProperties);
var
  rAttr: TCustomAttribute;
  rProperty: TRttiProperty;
begin
  for rProperty in AList do
    {Search for the custom attribute and do some custom processing}
    for rAttr in rProperty.GetAttributes() do
      if rAttr is CustomBindPropertyAttribute then
        BindProperty(ASource, aTarget, rProperty.Name,
          CustomBindPropertyAttribute(rAttr), AClassAttribute)
      else if rAttr is BindMethodAttribute then
        BindMethod(rProperty.GetValue(ASource).AsObject, aTarget,
          BindMethodAttribute(rAttr), AClassAttribute);
end;

procedure TPlAutoBinder.BindProperty(ASource, aTarget: TObject;
  const SourceProperty: string; AMemberAttribute: CustomBindMemberAttribute;
  AClassAttribute: ClassBindAttribute);
var
  bridgeFunction: TplBridgeFunction;
  sourceObject: TObject;
  sourcePath: string;
  targetObject: TObject;
  targetPath: string;
begin
  if CanBind(AClassAttribute, AMemberAttribute, aTarget) then
    begin
      bridgeFunction := FindCalculatingFuncion(aTarget,
        AMemberAttribute.FunctionName);

      sourcePath := SourceProperty;
      targetPath := AMemberAttribute.targetPath;
      sourceObject := FBinder.NormalizePath(ASource, sourcePath);
      targetObject := FBinder.NormalizePath(aTarget, targetPath);

      if IsBindFrom(AMemberAttribute) then
        Bind(targetObject, targetPath, sourceObject, sourcePath,
          bridgeFunction);
      if IsBindTo(AMemberAttribute) then
        Bind(sourceObject, sourcePath, targetObject, targetPath,
          bridgeFunction);
    end;
end;
{$ENDIF}

function TPlAutoBinder.CanBind(AClassAttribute: BindClassAttribute;
  AMemberAttribute: CustomBindAttribute; aTarget: TObject): boolean;
begin
  {An attribute can be bound when is enabled...}
  Result := AMemberAttribute.IsEnabled and
  {or its Target class is the default class...}
    (((AMemberAttribute.TargetClassName = '') and
    (AMemberAttribute.TargetClassAlias = '') and AClassAttribute.IsDefault) or
    {or its Target class is the processed class}
    (AMemberAttribute.TargetClassName = aTarget.ClassName) or
    {or the Alias name it reference to is the current Alias name}
    ((AClassAttribute.TargetClassAlias <> '') and
    (AMemberAttribute.TargetClassName = AClassAttribute.TargetClassAlias)));
end;

function TPlAutoBinder.Count: integer;
begin
  Result := FBinder.Count;
end;

function TPlAutoBinder.DebugInfo: TplBindDebugInfo;
begin
  Result := FBinder.DebugInfo;
end;

function TPlAutoBinder.ErrorList: TStrings;
begin
  Result := FBinder.BindErrorList;
end;

function TPlAutoBinder.FindCalculatingFuncion(AnOwner: TObject;
  const AFunctionName: string): TplBridgeFunction;
var
  methodPath: string;
  recMethod: TMethod;
  rMethod: TRttiMethod;
  rType: TRttiType;
  targetObject: TObject;
begin
  Result := nil;
  if AFunctionName = '' then
    Exit;
  methodPath := AFunctionName;
  targetObject := FBinder.NormalizePath(AnOwner, methodPath);
  {Extract type information for ASource's type}
  rType := TplRTTIUtils.Context.GetType(targetObject.ClassType);
  rMethod := rType.GetMethod(methodPath);
  if Assigned(rMethod) then
    begin
      recMethod.Code := rMethod.CodeAddress;
      recMethod.Data := Pointer(targetObject); //(Self);
      Result := TplBridgeFunction(recMethod);
    end;
end;

function TPlAutoBinder.FindSource(AField: TRttiField; AnObject: TObject;
  const APath: string): TObject;
var
  fieldValue: TValue;
begin
  Result := AnObject;
  if not MatchStr(APath, PL_SELF_ALIAS) then
    begin
      fieldValue := AField.GetValue(AnObject);
      if fieldValue.IsObject then
        Result := fieldValue.AsObject;
    end;
end;

function TPlAutoBinder.FindSource(AProperty: TRttiProperty; AnObject: TObject;
  const APath: string): TObject;
var
  fieldValue: TValue;
begin
  Result := AnObject;
  if not MatchStr(APath, PL_SELF_ALIAS) then
    begin
      fieldValue := AProperty.GetValue(AnObject);
      if fieldValue.IsObject then
        Result := fieldValue.AsObject;
    end;
end;

function TPlAutoBinder.GetEnabled: boolean;
begin
  Result := FBinder.Enabled;
end;

function TPlAutoBinder.GetInterval: integer;
begin
  Result := FBinder.Interval;
end;

function TPlAutoBinder.IsBindFrom(AnAttribute
  : CustomBindMemberAttribute): boolean;
begin
  Result := {$IFDEF SUPPORT_08}(AnAttribute is BindFieldAttribute) or
    (AnAttribute is BindFieldFromAttribute) or {$ENDIF}
    (AnAttribute is BindMemberAttribute) or
    (AnAttribute is BindMemberFromAttribute);
end;

function TPlAutoBinder.IsBindTo(AnAttribute: CustomBindMemberAttribute)
  : boolean;
begin
  Result := {$IFDEF SUPPORT_08}(AnAttribute is BindFieldAttribute) or
    (AnAttribute is BindFieldToAttribute) or {$ENDIF}
    (AnAttribute is BindMemberAttribute) or
    (AnAttribute is BindMemberToAttribute);
end;

procedure TPlAutoBinder.SetEnabled(const Value: boolean);
begin
  FBinder.Enabled := Value;
end;

procedure TPlAutoBinder.SetInterval(const Value: integer);
begin
  FBinder.Interval := Value;
end;

procedure TPlAutoBinder.Start(const AnInterval: integer);
begin
  FBinder.Start(AnInterval);
end;

procedure TPlAutoBinder.Stop;
begin
  FBinder.Stop;
end;

procedure TPlAutoBinder.UnbindMethod(ASource: TObject;
  AMethodAttribute: BindMethodAttribute);
var
  propertyPath: string;
  recMethod: TMethod;
  targetObject: TObject;
begin
  propertyPath := AMethodAttribute.SourceMethodName;
  targetObject := FBinder.NormalizePath(ASource, propertyPath);

  recMethod.Code := nil;
  recMethod.Data := nil;
  SetMethodProp(targetObject, propertyPath, recMethod);
end;

procedure TPlAutoBinder.UnbindMethods;
var
  target: TObject;
begin
  for target in FBoundObjectsList do
    try
      UnbindMethods(target);
    except
      on e: Exception do
        begin
          FBinder.BindErrorList.Add(Format('%s: % with a %s class',
            ['TPlAutoBinder.UnbindMethods', e.Message, target.ClassName]));
          Continue;
        end;
    end;
end;

procedure TPlAutoBinder.UnbindMethods(ASource: TObject);
var
  rAttr: TCustomAttribute;
  rAttributes: TarAttributes;
  rType: TRttiType;
begin
  try
    rType := TplRTTIUtils.Context.GetType(ASource.ClassType);
  except
    // If an error occours when reading ClassType, the Source has been freed
    // so we can exit.
    exit;
  end;
  rAttributes := rType.GetAttributes;
  for rAttr in rAttributes do
    if rAttr is BindMethodAttribute then
      UnbindMethod(ASource, BindMethodAttribute(rAttr));
  FBoundObjectsList.Remove(ASource);
end;

procedure TPlAutoBinder.UnbindSource(ASource: TObject);
begin
  FBinder.UnbindSource(ASource); //FBinder.DetachAsSource(ASource);
end;

procedure TPlAutoBinder.UnbindTarget(aTarget: TObject);
begin
  FBinder.UnbindTarget(aTarget); //FBinder.DetachAsTarget(ATarget);
end;

procedure TPlAutoBinder.UnbindTarget(aTarget, ASource: TObject);
begin
  FBinder.UnbindTarget(aTarget, ASource);
end;

procedure TPlAutoBinder.UpdateValues;
begin
  FBinder.UpdateValues;
end;

{$ENDREGION}

end.
