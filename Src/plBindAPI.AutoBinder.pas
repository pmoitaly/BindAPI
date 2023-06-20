{*****************************************************************************}
{       BindAPI                                                               }
{       Copyright (C) 2020 Paolo Morandotti                                   }
{       Unit plBindAPI.AutoBinder                                             }
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
  plBindAPI.Types, plBindApi.BinderElement, plBindAPI.Attributes,
  plBindAPI.CoreBinder;

{$UNDEF SUPPORT_08}

type

  TPlAutoBinder = class(TInterfacedObject, IplAutoBinder)
  private
    /// <link>aggregation</link>
    FBinder: TPlBinder;
    FBoundObjectsList: TPlListObjects;
    procedure BindAttributes(ASource, aTarget: TObject; AClassAttribute:
        ClassBindAttribute);
    function BindClass(ASource, ATarget: TObject; AClassAttribute: ClassBindAttribute):
        boolean;
    procedure BindClassAttributes(ASource, aTarget: TObject; AClassAttribute:
        ClassBindAttribute);
{$IFDEF SUPPORT_08}
    procedure BindField(ASource, ATarget: TObject; AMemberAttribute:
        CustomBindMemberAttribute; AClassAttribute: ClassBindAttribute; AFieldName:
        string = '');
    procedure BindFields(ASource, ATarget: TObject; AClassAttribute:
        ClassBindAttribute; AList: TarFields);
{$ENDIF}
    procedure BindMember(ASource, ATarget: TObject; AMemberAttribute:
        CustomBindMemberAttribute; AClassAttribute: ClassBindAttribute; AMemberName:
        string = '');
    procedure BindMembers(ASource, ATarget: TObject; AClassAttribute:
        ClassBindAttribute; AList: TarFields); overload;
    procedure BindMembers(ASource, ATarget: TObject; AClassAttribute:
        ClassBindAttribute; AList: TarProperties); overload;
    procedure BindMethod(ASource, ATarget: TObject; AMethodAttribute:
        BindMethodAttribute; AClassAttribute: ClassBindAttribute);
    procedure BindMethods(ASource, ATarget: TObject; AClassAttribute:
        ClassBindAttribute; AList: TarMethods);
{$IFDEF SUPPORT_08}
    procedure BindProperties(ASource, ATarget: TObject; AClassAttribute:
        ClassBindAttribute; AList: TarProperties);
    procedure BindProperty(ASource, ATarget: TObject; const SourceProperty: string;
        AMemberAttribute: CustomBindMemberAttribute; AClassAttribute:
        ClassBindAttribute);
{$ENDIF}
    function CanBind(AClassAttribute: ClassBindAttribute; AMemberAttribute:
        CustomBindAttribute; ATarget: TObject): boolean;
    function FindCalculatingFuncion(AnOwner: TObject; const AFunctionName: string): TplBridgeFunction;
    function FindSource(AField: TRttiField; AnObject: TObject):
        TObject; overload;
    function FindSource(AProperty: TRttiProperty; AnObject: TObject):
        TObject; overload;
    function GetEnabled: Boolean;
    function GetInterval: integer;
    function IsBindFrom(AnAttribute: CustomBindMemberAttribute): Boolean;
    function IsBindTo(AnAttribute: CustomBindMemberAttribute): Boolean;
    procedure SetEnabled(const Value: Boolean);
    procedure SetInterval(const Value: integer);
    procedure UnbindMethod(ASource: TObject; AMethodAttribute: BindMethodAttribute);
    procedure UnbindMethods; overload;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Bind(ASource: TObject; const APropertySource: string; ATarget: TObject; const APropertyTarget: string; AFunction: TplBridgeFunction = nil);
    function BindInfo: TPlBindList;
    procedure BindObject(ASource, ATarget: TObject; AClassAttribute:
        ClassBindAttribute);
    function Count: integer;
    function DebugInfo: TplBindDebugInfo;
    procedure Start(const AnInterval: Integer = 0);
    procedure Stop;
    procedure UnbindMethods(ASource: TObject); overload;
    procedure UnbindSource(ASource: TObject);
    procedure UnbindTarget(ATarget: TObject); overload;
    procedure UnbindTarget(ATarget, ASource: TObject); overload;
    procedure UpdateValues;
    property Enabled: Boolean read GetEnabled write SetEnabled;
    property Interval: integer read GetInterval write SetInterval;
  end;

implementation

uses
  TypInfo, StrUtils,
  PlBindAPI.RTTIUtils;

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
  ATarget: TObject; const APropertyTarget: string;
  AFunction: TplBridgeFunction);
begin
  FBinder.Bind(ASource, APropertySource, ATarget, APropertyTarget, AFunction);
end;

procedure TPlAutoBinder.BindAttributes(ASource, ATarget: TObject; AClassAttribute:
    ClassBindAttribute);
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
  BindMembers(ASource, ATarget, AClassAttribute, rFields);
  BindMembers(ASource, ATarget, AClassAttribute, rProperties);
  BindMethods(ASource, aTarget, AClassAttribute, rMethods);
end;

function TPlAutoBinder.BindClass(ASource, ATarget: TObject; AClassAttribute:
        ClassBindAttribute): boolean;
var
  classBinderAttr: ClassBindAttribute;
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
    if rAttr is ClassBindAttribute then
      begin
        classBinderAttr := ClassBindAttribute(rAttr);
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

procedure TPlAutoBinder.BindClassAttributes(ASource, ATarget: TObject;
    AClassAttribute: ClassBindAttribute);
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
      BindField(ASource, aTarget, CustomBindFieldAttribute(rAttr), AClassAttribute)
    else
{$ENDIF}
    if rAttr is CustomBindMemberAttribute then
      BindMember(ASource, aTarget, CustomBindFieldAttribute(rAttr), AClassAttribute)
    else if rAttr is BindMethodAttribute then
      BindMethod(ASource, aTarget, BindMethodAttribute(rAttr), AClassAttribute);
end;

{$IFDEF SUPPORT_08}
procedure TPlAutoBinder.BindField(ASource, ATarget: TObject; AMemberAttribute:
    CustomBindMemberAttribute; AClassAttribute: ClassBindAttribute; AFieldName:
    string = '');
var
  bridgeFunction: TplBridgeFunction;
  separator: string;
  sourceObject: TObject;
  sourcePath: string;
  targetObject: TObject;
  targetPath: string;
begin
  if CanBind(AClassAttribute, AMemberAttribute, ATarget) then
    begin
      bridgeFunction := FindCalculatingFuncion(ATarget, AMemberAttribute.FunctionName);

      sourcePath := AMemberAttribute.SourcePath;
      separator := IfThen(sourcePath <> '', '.', '');
      if AFieldName <> '' then
        sourcePath := AFieldName + separator + sourcePath;
      targetPath := AMemberAttribute.targetPath;
      sourceObject := FBinder.NormalizePath(ASource, sourcePath);
      targetObject := FBinder.NormalizePath(ATarget, targetPath);

      if IsBindFrom(AMemberAttribute) then
        Bind(targetObject, targetPath, sourceObject, sourcePath, bridgeFunction);
      if IsBindTo(AMemberAttribute) then
        Bind(sourceObject, sourcePath, targetObject, targetPath, bridgeFunction);
    end;
end;

procedure TPlAutoBinder.BindFields(ASource, ATarget: TObject; AClassAttribute:
    ClassBindAttribute; AList: TarFields);
var
  bindSource: TObject;
  rAttr: TCustomAttribute;
  rField: TRttiField;
begin
  for rField in AList do
    { Search for the custom attribute and do some custom processing }
    for rAttr in rField.GetAttributes() do
      if (rAttr is CustomBindFieldAttribute) and (rField.Visibility in [mvPublic, mvPublished]) then
        BindField(ASource, ATarget, CustomBindFieldAttribute(rAttr), AClassAttribute, rField.Name)
      else if (rAttr is CustomBindMemberAttribute) and (rField.Visibility in [mvPublic, mvPublished]) then
        begin
          {If the field value is an object, it becomes the bind source}
          bindSource := FindSource(rField, ASource);
          BindMember(bindSource, ATarget, CustomBindFieldAttribute(rAttr), AClassAttribute, rField.Name)
        end
      else if rAttr is BindMethodAttribute then
        BindMethod( rField.GetValue(ASource).AsObject, ATarget, BindMethodAttribute(rAttr), AClassAttribute);
end;
{$ENDIF}

function TPlAutoBinder.BindInfo: TPlBindList;
begin
  Result := FBinder.BindInfo;
end;

procedure TPlAutoBinder.BindMember(ASource, ATarget: TObject; AMemberAttribute:
    CustomBindMemberAttribute; AClassAttribute: ClassBindAttribute; AMemberName:
    string = '');
var
  bridgeFunction: TplBridgeFunction;
  sourceObject: TObject;
  sourcePath: string;
  targetObject: TObject;
  targetPath: string;
begin
  if CanBind(AClassAttribute, AMemberAttribute, ATarget) then
    begin
      bridgeFunction := FindCalculatingFuncion(ATarget, AMemberAttribute.FunctionName);

      sourcePath := IfThen(AMemberAttribute.SourcePath <> '', AMemberAttribute.SourcePath, AMemberName);
      targetPath := AMemberAttribute.targetPath;
      sourceObject := ASource;
      targetObject := ATarget; // FBinder.NormalizePath(ATarget, targetPath);

      if IsBindFrom(AMemberAttribute) then
        Bind(targetObject, targetPath, sourceObject, sourcePath, bridgeFunction);
      if IsBindTo(AMemberAttribute) then
        Bind(sourceObject, sourcePath, targetObject, targetPath, bridgeFunction);
    end;
end;

procedure TPlAutoBinder.BindMembers(ASource, ATarget: TObject;
  AClassAttribute: ClassBindAttribute; AList: TarFields);
var
  bindSource: TObject;
  rAttr: TCustomAttribute;
  rField: TRttiField;
begin
  for rField in AList do
    { Search for the custom attribute and do some custom processing }
    for rAttr in rField.GetAttributes() do
      if (rAttr is CustomBindMemberAttribute) and (rField.Visibility in [mvPublic, mvPublished]) then
        begin
          {If the field value is an object, it becomes the bind source}
          bindSource := FindSource(rField, ASource);
          BindMember(bindSource, ATarget, CustomBindFieldAttribute(rAttr), AClassAttribute, rField.Name)
        end
      else if rAttr is BindMethodAttribute then
        BindMethod( rField.GetValue(ASource).AsObject, ATarget, BindMethodAttribute(rAttr), AClassAttribute);
end;

procedure TPlAutoBinder.BindMembers(ASource, ATarget: TObject;
  AClassAttribute: ClassBindAttribute; AList: TarProperties);
var
  bindSource: TObject;
  rAttr: TCustomAttribute;
  rField: TRttiProperty;
begin
  for rField in AList do
    { Search for the custom attribute and do some custom processing }
    for rAttr in rField.GetAttributes() do
      if (rAttr is CustomBindMemberAttribute) and (rField.Visibility in [mvPublic, mvPublished]) then
        begin
          {If the field value is an object, it becomes the bind source}
          bindSource := FindSource(rField, ASource);
          BindMember(bindSource, ATarget, CustomBindFieldAttribute(rAttr), AClassAttribute, rField.Name)
        end
      else if rAttr is BindMethodAttribute then
        BindMethod( rField.GetValue(ASource).AsObject, ATarget, BindMethodAttribute(rAttr), AClassAttribute);
end;

procedure TPlAutoBinder.BindMethod(ASource, ATarget: TObject; AMethodAttribute:
    BindMethodAttribute; AClassAttribute: ClassBindAttribute);
begin
  if CanBind(AClassAttribute, AMethodAttribute, aTarget) then
    FBinder.BindMethod(ASource, AMethodAttribute.SourceMethodName, aTarget, AMethodAttribute.NewMethodName);
end;

procedure TPlAutoBinder.BindMethods(ASource, ATarget: TObject; AClassAttribute:
    ClassBindAttribute; AList: TarMethods);
var
  rAttr: TCustomAttribute;
  rMethod: TRttiMethod;
begin
  for rMethod in AList do
    { Search for the custom attribute and do some custom processing }
    for rAttr in rMethod.GetAttributes() do
      if rAttr is BindMethodAttribute then
        BindMethod(ASource, aTarget, BindMethodAttribute(rAttr), AClassAttribute);
end;

procedure TPlAutoBinder.BindObject(ASource, ATarget: TObject; AClassAttribute:
    ClassBindAttribute);
begin
  if BindClass(ASource, ATarget, AClassAttribute) then
    begin
      BindClassAttributes(ASource, ATarget, AClassAttribute);
      BindAttributes(ASource, ATarget, AClassAttribute);
    end;
end;

{$IFDEF SUPPORT_08}
procedure TPlAutoBinder.BindProperties(ASource, ATarget: TObject;
  AClassAttribute: ClassBindAttribute; AList: TarProperties);
var
  rAttr: TCustomAttribute;
  rProperty: TRttiProperty;
begin
  for rProperty in AList do
    { Search for the custom attribute and do some custom processing }
    for rAttr in rProperty.GetAttributes() do
      if rAttr is CustomBindPropertyAttribute then
        BindProperty(ASource, ATarget, rProperty.Name,
          CustomBindPropertyAttribute(rAttr), AClassAttribute)
      else if rAttr is BindMethodAttribute then
        BindMethod(rProperty.GetValue(ASource).AsObject, aTarget,
          BindMethodAttribute(rAttr), AClassAttribute);
end;

procedure TPlAutoBinder.BindProperty(ASource, ATarget: TObject;
   const SourceProperty: string; AMemberAttribute: CustomBindMemberAttribute;
   AClassAttribute: ClassBindAttribute);
var
  bridgeFunction: TplBridgeFunction;
  sourceObject: TObject;
  sourcePath: string;
  targetObject: TObject;
  targetPath: string;
begin
  if CanBind(AClassAttribute, AMemberAttribute, ATarget) then
    begin
      bridgeFunction := FindCalculatingFuncion(ATarget, AMemberAttribute.FunctionName);

      sourcePath := SourceProperty;
      targetPath := AMemberAttribute.targetPath;
      sourceObject := FBinder.NormalizePath(ASource, sourcePath);
      targetObject := FBinder.NormalizePath(ATarget, targetPath);

      if IsBindFrom(AMemberAttribute) then
        Bind(targetObject, targetPath, sourceObject, sourcePath, bridgeFunction);
      if IsBindTo(AMemberAttribute) then
        Bind(sourceObject, sourcePath, targetObject, targetPath, bridgeFunction);
  end;
end;
{$ENDIF}

function TPlAutoBinder.CanBind(AClassAttribute: ClassBindAttribute; AMemberAttribute: CustomBindAttribute; ATarget: TObject): boolean;
begin
  {An attribute can be bound when is enabled...}
  Result := AMemberAttribute.IsEnabled and
    {or its Target class is the default class...}
    (((AMemberAttribute.TargetClassName = '') and AClassAttribute.IsDefault) or
      {or its Target class is the processed class}
      (AMemberAttribute.TargetClassName = ATarget.ClassName) or
      {or the Alias name it reference to is the current Alias name}
     ((AClassAttribute.TargetClassAlias <> '') and (AMemberAttribute.TargetClassName = AClassAttribute.TargetClassAlias)));
end;

function TPlAutoBinder.Count: integer;
begin
  Result := FBinder.Count;
end;

function TPlAutoBinder.DebugInfo: TplBindDebugInfo;
begin
  Result := FBinder.DebugInfo;
end;

function TPlAutoBinder.FindCalculatingFuncion(AnOwner: TObject;
  const AFunctionName: string): TplBridgeFunction;
var
  methodPath: string;
  recMethod: TMethod;
  rMethod: TRTTIMethod;
  rType: TRttiType;
  targetObject: TObject;
begin
  Result := nil;
  if AFunctionName = '' then
    Exit;
  methodPath := AFunctionName;
  TargetObject := FBinder.NormalizePath(AnOwner, methodPath);
  { Extract type information for ASource's type }
  rType := TplRTTIUtils.Context.GetType(targetObject.ClassType);
  rMethod := rType.GetMethod(methodPath);
  if Assigned(rMethod) then
    begin
      recMethod.Code := rMethod.CodeAddress;
      recMethod.Data := Pointer(targetObject); //(Self);
      Result := TplBridgeFunction(recMethod);
    end;
end;

function TPlAutoBinder.FindSource(AField: TRttiField; AnObject: TObject):
    TObject;
var
  fieldValue: TValue;
begin
  Result := AnObject;
  fieldValue := AField.GetValue(AnObject);
  if fieldValue.IsObject then
    Result := fieldValue.AsObject;
end;

function TPlAutoBinder.FindSource(AProperty: TRttiProperty; AnObject: TObject):
    TObject;
var
  fieldValue: TValue;
begin
  Result := AnObject;
  fieldValue := AProperty.GetValue(AnObject);
  if fieldValue.IsObject then
    Result := fieldValue.AsObject;
end;

function TPlAutoBinder.GetEnabled: Boolean;
begin
  Result := FBinder.Enabled;
end;

function TPlAutoBinder.GetInterval: integer;
begin
  Result := FBinder.Interval;
end;

function TPlAutoBinder.IsBindFrom(AnAttribute: CustomBindMemberAttribute):
    Boolean;
begin
  Result := (AnAttribute is BindFieldAttribute)
    or (AnAttribute is BindFieldFromAttribute)
    or (AnAttribute is BindMemberAttribute)
    or (AnAttribute is BindMemberFromAttribute);
end;

function TPlAutoBinder.IsBindTo(AnAttribute: CustomBindMemberAttribute):
    Boolean;
begin
  Result := (AnAttribute is BindFieldAttribute)
    or (AnAttribute is BindFieldToAttribute)
    or (AnAttribute is BindMemberAttribute)
    or (AnAttribute is BindMemberToAttribute);
end;

procedure TPlAutoBinder.SetEnabled(const Value: Boolean);
begin
  FBinder.Enabled := Value;
end;

procedure TPlAutoBinder.SetInterval(const Value: integer);
begin
  FBinder.Interval := Value;
end;

procedure TPlAutoBinder.Start(const AnInterval: Integer);
begin
  FBinder.Start(AnInterval);
end;

procedure TPlAutoBinder.Stop;
begin
  FBinder.Stop;
end;

procedure TPlAutoBinder.UnbindMethod(ASource: TObject; AMethodAttribute:
    BindMethodAttribute);
var
  propertyPath: string;
  recMethod: TMethod ;
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
      Continue;
    end;
end;

procedure TPlAutoBinder.UnbindMethods(ASource: TObject);
var
  rAttr: TCustomAttribute;
  rAttributes: TarAttributes;
  rType: TRttiType;
begin
  rType := TPlRTTIUtils.Context.GetType(ASource.ClassType);
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

procedure TPlAutoBinder.UnbindTarget(ATarget: TObject);
begin
  FBinder.UnbindTarget(ATarget); //FBinder.DetachAsTarget(ATarget);
end;

procedure TPlAutoBinder.UnbindTarget(ATarget, ASource: TObject);
begin
  FBinder.UnbindTarget(ATarget, ASource);
end;

procedure TPlAutoBinder.UpdateValues;
begin
  FBinder.UpdateValues;
end;

{$ENDREGION}

end.
