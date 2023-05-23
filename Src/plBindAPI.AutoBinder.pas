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
    FAliasName: string; {Thread unsafe}
    FBinder: TPlBinder;
    FIsDefault: Boolean; {Thread unsafe}
    FLastBound: TPlListObjects;
    procedure BindAll(ASource, aTarget: TObject; const AnAlias: string);
    function BindClass(ASource, ATarget: TObject; const AnAlias: string): Boolean;
    procedure BindClassAttributes(ASource, aTarget: TObject; const AnAlias: string);
    procedure BindField(ASource, ATarget: TObject; AnAttribute: CustomBindFieldAttribute; AFieldNAme: string = '');
    procedure BindFields(ASource, ATarget: TObject; AList: TarFields);
    procedure BindMethod(ASource, ATarget: TObject; AnAttribute: MethodBindAttribute);
    procedure BindMethods(ASource, ATarget: TObject; AList: TarMethods);
    procedure BindProperty(ASource, ATarget: TObject;  const SourceProperty: string; AnAttribute: CustomBindPropertyAttribute);
    procedure BindProperties(ASource, ATarget: TObject; AList: TarProperties);
    function CanBind(AnAttribute: CustomBindAttribute; ATarget: TObject): boolean;
    function GetEnabled: Boolean;
    function GetInterval: integer;
    function FindCalculatingFuncion(AnOwner: TObject; const AFunctionName: string): TplBridgeFunction;
    function IsBindFrom(AnAttribute: CustomBindFieldAttribute): Boolean;
    procedure SetEnabled(const Value: Boolean);
    procedure SetInterval(const Value: integer);
    procedure UnbindMethod(ASource: TObject; AnAttribute: MethodBindAttribute);
    procedure UnbindMethods; overload;
    function IsBindTo(AnAttribute: CustomBindFieldAttribute): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
  public
    property Enabled: Boolean read GetEnabled write SetEnabled;
    property Interval: integer read GetInterval write SetInterval;
    procedure Bind(ASource: TObject; const APropertySource: string; ATarget: TObject; const APropertyTarget: string; AFunction: TplBridgeFunction = nil);
    function BindInfo: TPlBindList;
    procedure BindObject(ASource, ATarget: TObject; const AnAlias: string);
    function Count: integer;
    function DebugInfo: TplBindDebugInfo;
    procedure Start(const SleepInterval: Integer);
    procedure Stop;
    procedure UnbindMethods(ASource: TObject); overload;
    procedure UnbindSource(ASource: TObject);
    procedure UnbindTarget(ATarget: TObject); overload;
    procedure UnbindTarget(ATarget, ASource: TObject); overload;
    procedure UpdateValues;
  end;

implementation

uses
  System.TypInfo, System.StrUtils,
  PlBindAPI.RTTIUtils;

{ TplAutoBinder }

procedure TPlAutoBinder.Bind(ASource: TObject; const APropertySource: string;
  ATarget: TObject; const APropertyTarget: string;
  AFunction: TplBridgeFunction);
begin
  FBinder.Bind(ASource, APropertySource, ATarget, APropertyTarget, AFunction);
end;

procedure TPlAutoBinder.BindAll(ASource, aTarget: TObject; const AnAlias: string);
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
  BindProperties(ASource, aTarget, rProperties);
  BindFields(ASource, aTarget, rFields);
  BindMethods(ASource, aTarget, rMethods);
end;

function TPlAutoBinder.BindClass(ASource, ATarget: TObject; const AnAlias: string): boolean;
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
  FIsDefault := False;
  FAliasName := '';
  for rAttr in rAttributes do
    if rAttr is ClassBindAttribute then
      begin
        classBinderAttr := ClassBindAttribute(rAttr);
        if (classBinderAttr.IsEnabled) and
           (classBinderAttr.TargetClassName = aTarget.ClassName) then
          begin
           // not thread safe
           FLastBound.Add(ASource);

           FIsDefault := ClassBindAttribute(rAttr).IsDefault;
           FAliasName := ClassBindAttribute(rAttr).TargetClassAlias;
           Result := True;
           Break;
          end;
      end;
end;

procedure TPlAutoBinder.BindClassAttributes(ASource, aTarget: TObject; const AnAlias: string);
var
  rType: TRttiType;
  rAttr: TCustomAttribute;
  rAttributes: TarAttributes;
begin
  rType := TplRTTIUtils.Context.GetType(ASource.ClassType);
  rAttributes := rType.GetAttributes;
  for rAttr in rAttributes do
    if rAttr is CustomBindFieldAttribute then
      BindField(ASource, aTarget, CustomBindFieldAttribute(rAttr))
    else if rAttr is MethodBindAttribute then
      BindMethod(ASource, aTarget, MethodBindAttribute(rAttr));
end;

procedure TPlAutoBinder.BindFields(ASource, aTarget: TObject; AList: TarFields);
var
  rField: TRttiField;
  rAttr: TCustomAttribute;
begin
  for rField in AList do
    { Search for the custom attribute and do some custom processing }
    for rAttr in rField.GetAttributes() do
      if (rAttr is CustomBindFieldAttribute) and (rField.Visibility in [mvPublic, mvPublished]) then
        BindField(ASource, aTarget, CustomBindFieldAttribute(rAttr), rField.Name)
      else if rAttr is MethodBindAttribute then
        BindMethod( rField.GetValue(ASource).AsObject, aTarget, MethodBindAttribute(rAttr));
end;

function TPlAutoBinder.BindInfo: TPlBindList;
begin
  Result := FBinder.BindInfo;
end;

procedure TPlAutoBinder.BindField(ASource, ATarget: TObject;
  AnAttribute: CustomBindFieldAttribute; AFieldName: string = '');
var
  calculateValue: TplBridgeFunction;
  separator: string;
  SourceObject: TObject;
  SourcePath: string;
  TargetObject: TObject;
  TargetPath: string;
begin
  if CanBind(AnAttribute, ATarget) then
    begin
      if AnAttribute.FunctionName <> '' then
        calculateValue := FindCalculatingFuncion(aTarget, AnAttribute.FunctionName)
      else
        calculateValue := nil;

      SourcePath := AnAttribute.SourcePath;
      separator := IfThen(SourcePath <> '', '.', '');
      if AFieldName <> '' then
        SourcePath := AFieldName + separator + SourcePath;
      TargetPath := AnAttribute.TargetPath;
      SourceObject := FBinder.NormalizePath(ASource, SourcePath);
      TargetObject := FBinder.NormalizePath(aTarget, TargetPath);

      if IsBindFrom(AnAttribute) then
        Bind(TargetObject, TargetPath, SourceObject, SourcePath, calculateValue);
      if IsBindTo(AnAttribute) then
        Bind(SourceObject, SourcePath, TargetObject, TargetPath, calculateValue);
    end;
end;

procedure TPlAutoBinder.BindMethod(ASource, aTarget: TObject;
  AnAttribute: MethodBindAttribute);
begin
  if CanBind(AnAttribute, aTarget) then
    FBinder.BindMethod(ASource, AnAttribute.SourceMethodName, aTarget, AnAttribute.NewMethodName);
end;

procedure TPlAutoBinder.BindMethods(ASource, aTarget: TObject; AList: TarMethods);
var
  rMethod: TRttiMethod;
  rAttr: TCustomAttribute;
begin
  for rMethod in AList do
    { Search for the custom attribute and do some custom processing }
    for rAttr in rMethod.GetAttributes() do
      if rAttr is MethodBindAttribute then
        BindMethod(ASource, aTarget, MethodBindAttribute(rAttr));
end;

procedure TPlAutoBinder.BindObject(ASource, ATarget: TObject; const AnAlias: string);
begin
  if BindClass(ASource, ATarget, AnAlias) then
    begin
      BindClassAttributes(ASource, ATarget, AnAlias);
      BindAll(ASource, ATarget, AnAlias);
    end;
end;

procedure TPlAutoBinder.BindProperties(ASource, aTarget: TObject; AList: TarProperties);
var
  rProperty: TRttiProperty;
  rAttr: TCustomAttribute;
begin
  for rProperty in AList do
    { Search for the custom attribute and do some custom processing }
    for rAttr in rProperty.GetAttributes() do
      if rAttr is CustomBindPropertyAttribute then
        BindProperty(ASource, aTarget, rProperty.Name, CustomBindPropertyAttribute(rAttr))
      else if rAttr is MethodBindAttribute then
        BindMethod(rProperty.GetValue(ASource).AsObject, aTarget, MethodBindAttribute(rAttr));
end;

procedure TPlAutoBinder.BindProperty(ASource, aTarget: TObject;
   const SourceProperty: string; AnAttribute: CustomBindPropertyAttribute);
var
  SourceObject: TObject;
  SourcePath: string;
  TargetObject: TObject;
  TargetPath: string;

  calculateValue: TplBridgeFunction;
begin
  if CanBind(AnAttribute, aTarget) then
    begin
      if AnAttribute.FunctionName <> '' then
        calculateValue := FindCalculatingFuncion(aTarget, AnAttribute.FunctionName)
      else
        calculateValue := nil;

      SourcePath := SourceProperty;
      TargetPath := AnAttribute.TargetName;
      SourceObject := FBinder.NormalizePath(ASource, SourcePath);
      TargetObject := FBinder.NormalizePath(aTarget, TargetPath);

      if (AnAttribute is BindPropertyAttribute)
      or (AnAttribute is BindPropertyFromAttribute) then
        Bind(TargetObject, TargetPath, SourceObject, SourcePath, calculateValue);
      if (AnAttribute is BindPropertyAttribute)
      or (AnAttribute is BindPropertyToAttribute) then
        Bind(SourceObject, SourcePath, TargetObject, TargetPath, calculateValue);
  end
end;

function TPlAutoBinder.CanBind(AnAttribute: CustomBindAttribute; ATarget: TObject): boolean;
begin
  {An attribute can be bound when is enabled...}
  Result := AnAttribute.IsEnabled and
    {or its Target class is the default class...}
    (((AnAttribute.TargetClassName = '') and FIsDefault) or
      {or its Target class is the processed class}
      (AnAttribute.TargetClassName = ATarget.ClassName) or
      {or the Alias name it reference to is the current Alias name}
     ((FAliasName <> '') and (AnAttribute.TargetClassName = FAliasName)));
end;

constructor TPlAutoBinder.Create;
begin
  inherited;
  FBinder := TPlBinder.Create;
  FLastBound := TPlListObjects.Create;
end;

function TPlAutoBinder.DebugInfo: TplBindDebugInfo;
begin
  Result := FBinder.DebugInfo;
end;

destructor TPlAutoBinder.Destroy;
begin
  UnbindMethods;
  FLastBound.Free;
  FBinder.Free;
  inherited;
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
  methodPath := AFunctionName;
  TargetObject := FBinder.NormalizePath(AnOwner, methodPath);
  { Extract type information for ASource's type }
  rType := TplRTTIUtils.Context.GetType(targetObject.ClassType);
  rMethod := rType.GetMethod(methodPath);
  if Assigned(rMethod) then
    begin
      recMethod.Code := rMethod.CodeAddress;
      recMethod.Data := Pointer(targetObject); //(Self);
    end;
  Result := TplBridgeFunction(recMethod);
end;

function TPlAutoBinder.Count: integer;
begin
  Result := FBinder.Count;
end;

function TPlAutoBinder.GetEnabled: Boolean;
begin
  Result := FBinder.Enabled;
end;

function TPlAutoBinder.GetInterval: integer;
begin
  Result := FBinder.Interval;
end;

function TPlAutoBinder.IsBindFrom(AnAttribute: CustomBindFieldAttribute):
    Boolean;
begin
  Result := (AnAttribute is BindFieldAttribute)
    or (AnAttribute is BindFieldFromAttribute)
    or (AnAttribute is BindMemberAttribute)
    or (AnAttribute is BindMemberFromAttribute);
end;

function TPlAutoBinder.IsBindTo(AnAttribute: CustomBindFieldAttribute):
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

procedure TPlAutoBinder.UnbindMethod(ASource: TObject; AnAttribute: MethodBindAttribute);
var
  propertyPath: string;
  targetObject: TObject;
  recMethod: TMethod ;
begin
  if CanBind(AnAttribute, ASource) then
    begin
      propertyPath := AnAttribute.SourceMethodName;
      targetObject := FBinder.NormalizePath(ASource, propertyPath);

      recMethod.Code := nil;
      recMethod.Data := nil;
      SetMethodProp(targetObject, propertyPath, recMethod);

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

procedure TPlAutoBinder.UnbindSource(ASource: TObject);
begin
  FBinder.UnbindSource(ASource); //FBinder.DetachAsSource(ASource);
end;

procedure TPlAutoBinder.UnbindTarget(ATarget, ASource: TObject);
begin
  FBinder.UnbindTarget(ATarget, ASource);
end;

procedure TPlAutoBinder.UnbindTarget(ATarget: TObject);
begin
  FBinder.UnbindTarget(ATarget); //FBinder.DetachAsTarget(ATarget);
end;

procedure TPlAutoBinder.UpdateValues;
begin
  FBinder.UpdateValues;
end;

end.
