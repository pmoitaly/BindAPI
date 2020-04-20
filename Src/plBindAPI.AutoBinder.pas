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
  System.Classes, System.Rtti, System.Generics.Collections,
  plBindAPI.Types, plBindAPI.Attributes, plBindAPI.CoreBinder;

type
  TarAttributes = TArray<TCustomAttribute>;
  TarFields = TArray<TRttiField>;
  TarMethods = TArray<TRttiMethod>;
  TarProperties = TArray<TRttiProperty>;
  TListObjects = TList<TObject>;

  TplAutoBinder = class(TInterfacedObject, IplAutoBinder)
  private
    FBinder: TPlBinder;
    FIsDefault: Boolean; {Thread unsafe}
    FLastBound: TListObjects;
    procedure BindAll(ASource, aTarget: TObject);
    function BindClass(ASource, aTarget: TObject): Boolean;
    procedure BindClassAttributes(ASource, aTarget: TObject);
    procedure BindField(ASource, aTarget: TObject; AnAttribute: FieldBindAttribute; AFieldNAme: string = '');
    procedure BindFields(ASource, aTarget: TObject; AList: TarFields);
    procedure BindMethod(ASource, aTarget: TObject; AnAttribute: MethodBindAttribute);
    procedure BindMethods(ASource, aTarget: TObject; AList: TarMethods);
    procedure BindProperty(ASource, aTarget: TObject;  const SourceProperty: string; AnAttribute: PropertiesBindAttribute);
    procedure BindProperties(ASource, aTarget: TObject; AList: TarProperties);
    function CanBind(AnAttribute: CustomBindAttribute; ATarget: TObject): boolean;
    function GetEnabled: Boolean;
    function GetInterval: integer;
    function FindCalculatingFuncion(AnOwner: TObject; const AFunctionName: string): TplBridgeFunction;
    procedure SetEnabled(const Value: Boolean);
    procedure SetInterval(const Value: integer);
    procedure UnbindMethod(ASource: TObject; AnAttribute: MethodBindAttribute);
    procedure UnbindMethods; overload;
  public
    constructor Create;
    destructor Destroy; override;
  public
    property Enabled: Boolean read GetEnabled write SetEnabled;
    property Interval: integer read GetInterval write SetInterval;
    procedure Bind(ASource: TObject; const APropertySource: string; ATarget: TObject; const APropertyTarget: string; AFunction: TplBridgeFunction = nil);
    procedure BindObject(ASource, aTarget: TObject);
    function Count: integer;
    procedure Start(const SleepInterval: Integer);
    procedure Stop;
    procedure UnbindMethods(ASource: TObject); overload;
    procedure UnbindSource(ASource: TObject);
    procedure UnbindTarget(ATarget: TObject);
    procedure UpdateValues;
  end;

implementation

uses
  TypInfo, System.StrUtils;

{ TplAutoBinder }

procedure TplAutoBinder.Bind(ASource: TObject; const APropertySource: string;
  ATarget: TObject; const APropertyTarget: string;
  AFunction: TplBridgeFunction);
begin
  FBinder.Bind(ASource, APropertySource, ATarget, APropertyTarget, AFunction);
end;

procedure TplAutoBinder.BindAll(ASource, aTarget: TObject);
var
  rContext: TRttiContext;
  rFields: TarFields;
  rMethods: TarMethods;
  rProperties: TarProperties;
  rType: TRttiType;
begin
  rContext := TRttiContext.Create;
  rType := rContext.GetType(ASource.ClassType);
  rFields := rType.GetFields;
  rMethods := rType.GetMethods;
  rProperties := rType.GetProperties;
  BindProperties(ASource, aTarget, rProperties);
  BindFields(ASource, aTarget, rFields);
  BindMethods(ASource, aTarget, rMethods);
  rContext.Free;
end;

function TplAutoBinder.BindClass(ASource, aTarget: TObject): boolean;
var
  classBinder: ClassBindAttribute;
  rContext: TRttiContext;
  rType: TRttiType;
  rAttr: TCustomAttribute;
  rAttributes: TarAttributes;
begin
  Result := False;
  if not Assigned(aTarget) then
    aTarget := Self;
  rContext := TRttiContext.Create;
  rType := rContext.GetType(ASource.ClassType);
  rAttributes := rType.GetAttributes;
  for rAttr in rAttributes do
    if rAttr is ClassBindAttribute then
      begin
        classBinder := ClassBindAttribute(rAttr);
        if (classBinder.IsEnabled) and
          (classBinder.TargetClassName = aTarget.ClassName) then
          begin
           FLastBound.Add(ASource);
           FIsDefault := ClassBindAttribute(rAttr).IsDefault;
           Result := True;
           Break;
          end;
      end;
  rContext.Free;
end;

procedure TplAutoBinder.BindClassAttributes(ASource, aTarget: TObject);
var
  rContext: TRttiContext;
  rType: TRttiType;
  rAttr: TCustomAttribute;
  rAttributes: TarAttributes;
begin
  rContext := TRttiContext.Create;
  rType := rContext.GetType(ASource.ClassType);
  rAttributes := rType.GetAttributes;
  for rAttr in rAttributes do
    if rAttr is FieldBindAttribute then
      BindField(ASource, aTarget, FieldBindAttribute(rAttr))
    else if rAttr is MethodBindAttribute then
      BindMethod(ASource, aTarget, MethodBindAttribute(rAttr));
end;

procedure TplAutoBinder.BindFields(ASource, aTarget: TObject; AList: TarFields);
var
  rField: TRttiField;
  rAttr: TCustomAttribute;
begin
  for rField in AList do
    { Search for the custom attribute and do some custom processing }
    for rAttr in rField.GetAttributes() do
      if (rAttr is FieldBindAttribute) and (rField.Visibility in [mvPublic, mvPublished]) then
        BindField(ASource, aTarget, FieldBindAttribute(rAttr), rField.Name)
      else if rAttr is MethodBindAttribute then
        BindMethod( rField.GetValue(ASource).AsObject, aTarget, MethodBindAttribute(rAttr));
end;

procedure TplAutoBinder.BindField(ASource, aTarget: TObject;
  AnAttribute: FieldBindAttribute; AFieldName: string = '');
var
  calculateValue: TplBridgeFunction;
  separator: string;
  SourceObject: TObject;
  SourcePath: string;
  TargetObject: TObject;
  TargetPath: string;
begin
  if CanBind(AnAttribute, aTarget) then
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

      if (AnAttribute is BindFieldAttribute)
      or (AnAttribute is BindFieldFromAttribute) then
        Bind(TargetObject, TargetPath, SourceObject, SourcePath, calculateValue);
      if (AnAttribute is BindFieldAttribute)
      or (AnAttribute is BindFieldToAttribute) then
        Bind(SourceObject, SourcePath, TargetObject, TargetPath, calculateValue);
    end;
end;

procedure TplAutoBinder.BindMethod(ASource, aTarget: TObject;
  AnAttribute: MethodBindAttribute);
begin
  if CanBind(AnAttribute, aTarget) then
    FBinder.BindMethod(ASource, AnAttribute.SourceMethodName, aTarget, AnAttribute.NewMethodName);
end;

procedure TplAutoBinder.BindMethods(ASource, aTarget: TObject; AList: TarMethods);
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

procedure TplAutoBinder.BindObject(ASource, aTarget: TObject);
begin
  if BindClass(ASource, aTarget) then
    begin
      BindClassAttributes(ASource, aTarget);
      BindAll(ASource, aTarget);
    end;
end;

procedure TplAutoBinder.BindProperties(ASource, aTarget: TObject; AList: TarProperties);
var
  rProperty: TRttiProperty;
  rAttr: TCustomAttribute;
begin
  for rProperty in AList do
    { Search for the custom attribute and do some custom processing }
    for rAttr in rProperty.GetAttributes() do
      if rAttr is PropertiesBindAttribute then
        BindProperty(ASource, aTarget, rProperty.Name, PropertiesBindAttribute(rAttr))
      else if rAttr is MethodBindAttribute then
        BindMethod(rProperty.GetValue(ASource).AsObject, aTarget, MethodBindAttribute(rAttr));
end;

procedure TplAutoBinder.BindProperty(ASource, aTarget: TObject;
   const SourceProperty: string; AnAttribute: PropertiesBindAttribute);
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

function TplAutoBinder.CanBind(AnAttribute: CustomBindAttribute; ATarget: TObject): boolean;
begin
  Result := AnAttribute.IsEnabled and
    (((AnAttribute.TargetClassName = '') and FIsDefault)or
     (AnAttribute.TargetClassName = ATarget.ClassName));
end;

constructor TplAutoBinder.Create;
begin
  inherited;
  FBinder := TPlBinder.Create;
  FLastBound := TListObjects.Create;
end;

destructor TplAutoBinder.Destroy;
begin
  UnbindMethods;
  FLastBound.Free;
  FBinder.Free;
  inherited;
end;

function TplAutoBinder.FindCalculatingFuncion(AnOwner: TObject;
  const AFunctionName: string): TplBridgeFunction;
var
  rContext: TRttiContext;
  rType: TRttiType;
  rMethod: TRTTIMethod;
  methodPath: string;
  recMethod: TMethod;
  targetObject: TObject;
begin
  methodPath := AFunctionName;
  rContext := TRttiContext.Create;
  TargetObject := FBinder.NormalizePath(AnOwner, methodPath);
  { Extract type information for ASource's type }
  rType := rContext.GetType(targetObject.ClassType);
  rMethod := rType.GetMethod(methodPath);
  if Assigned(rMethod) then
    begin
      recMethod.Code := rMethod.CodeAddress;
      recMethod.Data := pointer(targetObject); //(Self);
    end;
  Result := TplBridgeFunction(recMethod);
end;

function TplAutoBinder.Count: integer;
begin
  Result := FBinder.Count;
end;

function TplAutoBinder.GetEnabled: Boolean;
begin
  Result := FBinder.Enabled;
end;

function TplAutoBinder.GetInterval: integer;
begin
  Result := FBinder.Interval;
end;

procedure TplAutoBinder.SetEnabled(const Value: Boolean);
begin
  FBinder.Enabled := Value;
end;

procedure TplAutoBinder.SetInterval(const Value: integer);
begin
  FBinder.Interval := Value;
end;

procedure TplAutoBinder.Start(const SleepInterval: Integer);
begin
  FBinder.Start(SleepInterval);
end;

procedure TplAutoBinder.Stop;
begin
  FBinder.Stop;
end;

procedure TplAutoBinder.UnbindMethod(ASource: TObject; AnAttribute: MethodBindAttribute);
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

procedure TplAutoBinder.UnbindMethods(ASource: TObject);
var
  rContext: TRttiContext;
  rType: TRttiType;
  rAttr: TCustomAttribute;
  rAttributes: TarAttributes;
begin
  rContext := TRttiContext.Create;
  rType := rContext.GetType(ASource.ClassType);
  rAttributes := rType.GetAttributes;
  for rAttr in rAttributes do
    if rAttr is MethodBindAttribute then
      UnbindMethod(ASource, MethodBindAttribute(rAttr));
  FLastBound.Remove(ASource);
  rContext.Free;
end;

procedure TplAutoBinder.UnbindMethods;
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

procedure TplAutoBinder.UnbindSource(ASource: TObject);
begin
  FBinder.DetachAsSource(ASource);
end;

procedure TplAutoBinder.UnbindTarget(ATarget: TObject);
begin
  FBinder.DetachAsTarget(ATarget);
end;

procedure TplAutoBinder.UpdateValues;
begin
  FBinder.UpdateValues;
end;

end.
