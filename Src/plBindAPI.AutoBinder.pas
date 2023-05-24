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

type
  TarAttributes = TArray<TCustomAttribute>;
  TarFields = TArray<TRttiField>;
  TarMethods = TArray<TRttiMethod>;
  TarProperties = TArray<TRttiProperty>;
  TPlListObjects = TList<TObject>;

  TPlAutoBindOptions = (abRecursive); // To be continued...
  TPlAutoBindOptionSet = Set of TplAutoBindOptions;

  TPlAutoBinder = class(TInterfacedObject, IplAutoBinder)
  private
    /// <link>aggregation</link>
    FBinder: TPlBinder;
    FLastBound: TPlListObjects;
    function BindClass(ASource, ATarget: TObject; AnAttribute: ClassBindAttribute):
        boolean;
    procedure BindClassAttributes(ASource, aTarget: TObject; AMemberAttribute:
        ClassBindAttribute);
    procedure BindField(ASource, ATarget: TObject; AMemberAttribute:
        CustomBindMemberAttribute; AClassAttribute: ClassBindAttribute; AFieldName:
        string = '');
    procedure BindFields(ASource, aTarget: TObject; AClassAttribute:
        ClassBindAttribute; AList: TarFields);
    procedure BindMembers(ASource, aTarget: TObject; AnAttribute:
        ClassBindAttribute);
    procedure BindMethod(ASource, ATarget: TObject; AMemberAttribute:
        MethodBindAttribute; AClassAttribute: ClassBindAttribute);
    procedure BindMethods(ASource, aTarget: TObject; AClassAttribute:
        ClassBindAttribute; AList: TarMethods);
    procedure BindProperties(ASource, aTarget: TObject; AClassAttribute:
        ClassBindAttribute; AList: TarProperties);
    procedure BindProperty(ASource, aTarget: TObject; const SourceProperty: string;
        AMemberAttribute: CustomBindMemberAttribute; AClassAttribute:
        ClassBindAttribute);
    function CanBind(AClassAttribute: ClassBindAttribute; AMemberAttribute:
        CustomBindAttribute; ATarget: TObject): boolean;
    function FindCalculatingFuncion(AnOwner: TObject; const AFunctionName: string): TplBridgeFunction;
    function GetEnabled: Boolean;
    function GetInterval: integer;
    function IsBindFrom(AnAttribute: CustomBindMemberAttribute): Boolean;
    function IsBindTo(AnAttribute: CustomBindMemberAttribute): Boolean;
    procedure SetEnabled(const Value: Boolean);
    procedure SetInterval(const Value: integer);
    procedure UnbindMethod(ASource: TObject; AMethodAttribute: MethodBindAttribute);
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
    procedure Start(const SleepInterval: Integer);
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
  System.TypInfo, System.StrUtils,
  PlBindAPI.RTTIUtils;

constructor TPlAutoBinder.Create;
begin
  inherited;
  FBinder := TPlBinder.Create;
  FLastBound := TPlListObjects.Create;
end;

destructor TPlAutoBinder.Destroy;
begin
  UnbindMethods;
  FLastBound.Free;
  FBinder.Free;
  inherited;
end;

{ TplAutoBinder }

procedure TPlAutoBinder.Bind(ASource: TObject; const APropertySource: string;
  ATarget: TObject; const APropertyTarget: string;
  AFunction: TplBridgeFunction);
begin
  FBinder.Bind(ASource, APropertySource, ATarget, APropertyTarget, AFunction);
end;

function TPlAutoBinder.BindClass(ASource, ATarget: TObject; AnAttribute:
        ClassBindAttribute): boolean;
var
  classBinderAttr: ClassBindAttribute;
  rType: TRttiType;
  rAttr: TCustomAttribute;
  rAttributes: TarAttributes;
begin
  Result := False;
  if not Assigned(aTarget) then
    Exit; // was: aTarget := Self; but this makes a little sense to me.
  {Get class' attributes}
  rType := TplRTTIUtils.Context.GetType(ASource.ClassType);
  rAttributes := rType.GetAttributes;
  for rAttr in rAttributes do
    if rAttr is ClassBindAttribute then
      begin
        classBinderAttr := ClassBindAttribute(rAttr);
        if (classBinderAttr.IsEnabled) and
           ((classBinderAttr.TargetClassName = aTarget.ClassName) or
             (AnAttribute.TargetClassAlias = aTarget.ClassName)) then
          begin
           // not thread safe
           FLastBound.Add(ASource);
           Result := True;
           Break;
          end;
      end;
end;

procedure TPlAutoBinder.BindClassAttributes(ASource, aTarget: TObject;
    AMemberAttribute: ClassBindAttribute);
var
  rType: TRttiType;
  rAttr: TCustomAttribute;
  rAttributes: TarAttributes;
begin
  rType := TplRTTIUtils.Context.GetType(ASource.ClassType);
  rAttributes := rType.GetAttributes;
  for rAttr in rAttributes do
    if rAttr is CustomBindFieldAttribute then
      BindField(ASource, aTarget, CustomBindFieldAttribute(rAttr), AMemberAttribute)
    else if rAttr is MethodBindAttribute then
      BindMethod(ASource, aTarget, MethodBindAttribute(rAttr), AMemberAttribute);
end;

procedure TPlAutoBinder.BindField(ASource, ATarget: TObject; AMemberAttribute:
    CustomBindMemberAttribute; AClassAttribute: ClassBindAttribute; AFieldName:
    string = '');
var
  calculateValue: TplBridgeFunction;
  separator: string;
  SourceObject: TObject;
  SourcePath: string;
  TargetObject: TObject;
  TargetPath: string;
begin
  if CanBind(AClassAttribute, AMemberAttribute, ATarget) then
    begin
      calculateValue := FindCalculatingFuncion(aTarget, AMemberAttribute.FunctionName);

      SourcePath := AMemberAttribute.SourcePath;
      separator := IfThen(SourcePath <> '', '.', '');
      if AFieldName <> '' then
        SourcePath := AFieldName + separator + SourcePath;
      TargetPath := AMemberAttribute.TargetPath;
      SourceObject := FBinder.NormalizePath(ASource, SourcePath);
      TargetObject := FBinder.NormalizePath(aTarget, TargetPath);

      if IsBindFrom(AMemberAttribute) then
        Bind(TargetObject, TargetPath, SourceObject, SourcePath, calculateValue);
      if IsBindTo(AMemberAttribute) then
        Bind(SourceObject, SourcePath, TargetObject, TargetPath, calculateValue);
    end;
end;

procedure TPlAutoBinder.BindFields(ASource, aTarget: TObject; AClassAttribute:
    ClassBindAttribute; AList: TarFields);
var
  rField: TRttiField;
  rAttr: TCustomAttribute;
begin
  for rField in AList do
    { Search for the custom attribute and do some custom processing }
    for rAttr in rField.GetAttributes() do
      if (rAttr is CustomBindFieldAttribute) and (rField.Visibility in [mvPublic, mvPublished]) then
        BindField(ASource, aTarget, CustomBindFieldAttribute(rAttr), AClassAttribute, rField.Name)
      else if rAttr is MethodBindAttribute then
        BindMethod( rField.GetValue(ASource).AsObject, aTarget, MethodBindAttribute(rAttr), AClassAttribute);
end;

function TPlAutoBinder.BindInfo: TPlBindList;
begin
  Result := FBinder.BindInfo;
end;

procedure TPlAutoBinder.BindMembers(ASource, aTarget: TObject; AnAttribute:
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
  BindProperties(ASource, aTarget, AnAttribute, rProperties);
  BindFields(ASource, aTarget, AnAttribute, rFields);
  BindMethods(ASource, aTarget, AnAttribute, rMethods);
end;

procedure TPlAutoBinder.BindMethod(ASource, ATarget: TObject; AMemberAttribute:
    MethodBindAttribute; AClassAttribute: ClassBindAttribute);
begin
  if CanBind(AClassAttribute, AMemberAttribute, aTarget) then
    FBinder.BindMethod(ASource, AMemberAttribute.SourceMethodName, aTarget, AMemberAttribute.NewMethodName);
end;

procedure TPlAutoBinder.BindMethods(ASource, aTarget: TObject; AClassAttribute:
    ClassBindAttribute; AList: TarMethods);
var
  rMethod: TRttiMethod;
  rAttr: TCustomAttribute;
begin
  for rMethod in AList do
    { Search for the custom attribute and do some custom processing }
    for rAttr in rMethod.GetAttributes() do
      if rAttr is MethodBindAttribute then
        BindMethod(ASource, aTarget, MethodBindAttribute(rAttr), AClassAttribute);
end;

procedure TPlAutoBinder.BindObject(ASource, ATarget: TObject; AClassAttribute:
    ClassBindAttribute);
begin
  if BindClass(ASource, ATarget, AClassAttribute) then
    begin
      BindClassAttributes(ASource, ATarget, AClassAttribute);
      BindMembers(ASource, ATarget, AClassAttribute);
    end;
end;

procedure TPlAutoBinder.BindProperties(ASource, aTarget: TObject;
  AClassAttribute: ClassBindAttribute; AList: TarProperties);
var
  rProperty: TRttiProperty;
  rAttr: TCustomAttribute;
begin
  for rProperty in AList do
    { Search for the custom attribute and do some custom processing }
    for rAttr in rProperty.GetAttributes() do
      if rAttr is CustomBindPropertyAttribute then
        BindProperty(ASource, aTarget, rProperty.Name,
          CustomBindPropertyAttribute(rAttr), AClassAttribute)
      else if rAttr is MethodBindAttribute then
        BindMethod(rProperty.GetValue(ASource).AsObject, aTarget,
          MethodBindAttribute(rAttr), AClassAttribute);
end;

procedure TPlAutoBinder.BindProperty(ASource, aTarget: TObject;
   const SourceProperty: string; AMemberAttribute: CustomBindMemberAttribute;
   AClassAttribute: ClassBindAttribute);
var
  SourceObject: TObject;
  SourcePath: string;
  TargetObject: TObject;
  TargetPath: string;

  calculateValue: TplBridgeFunction;
begin
  if CanBind(AClassAttribute, AMemberAttribute, aTarget) then
    begin
      calculateValue := FindCalculatingFuncion(aTarget, AMemberAttribute.FunctionName);

      SourcePath := SourceProperty;
      TargetPath := AMemberAttribute.TargetPath;
      SourceObject := FBinder.NormalizePath(ASource, SourcePath);
      TargetObject := FBinder.NormalizePath(aTarget, TargetPath);

      if (AMemberAttribute is BindPropertyAttribute)
      or (AMemberAttribute is BindPropertyFromAttribute) then
        Bind(TargetObject, TargetPath, SourceObject, SourcePath, calculateValue);
      if (AMemberAttribute is BindPropertyAttribute)
      or (AMemberAttribute is BindPropertyToAttribute) then
        Bind(SourceObject, SourcePath, TargetObject, TargetPath, calculateValue);
  end;
end;

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
  rType: TRttiType;
  rMethod: TRTTIMethod;
  methodPath: string;
  recMethod: TMethod;
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

procedure TPlAutoBinder.Start(const SleepInterval: Integer);
begin
  FBinder.Start(SleepInterval);
end;

procedure TPlAutoBinder.Stop;
begin
  FBinder.Stop;
end;

procedure TPlAutoBinder.UnbindMethod(ASource: TObject; AMethodAttribute:
    MethodBindAttribute);
var
  propertyPath: string;
  targetObject: TObject;
  recMethod: TMethod ;
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
  for target in FLastBound do
    try
      UnbindMethods(target);
    except
      Continue;
    end;
end;

procedure TPlAutoBinder.UnbindMethods(ASource: TObject);
var
  rType: TRttiType;
  rAttr: TCustomAttribute;
  rAttributes: TarAttributes;
begin
  rType := TPlRTTIUtils.Context.GetType(ASource.ClassType);
  rAttributes := rType.GetAttributes;
  for rAttr in rAttributes do
    if rAttr is MethodBindAttribute then
      UnbindMethod(ASource, MethodBindAttribute(rAttr));
  FLastBound.Remove(ASource);
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

end.
