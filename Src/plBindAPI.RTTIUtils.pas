unit plBindAPI.RTTIUtils;
{ ***************************************************************************** }
{ BindAPI }
{ Copyright (C) 2020 Paolo Morandotti }
{ Unit plBindAPI.RTTIQuery }
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

interface

uses
{$IFDEF FPC}
  Rtti, Generics.Collections, Generics.Defaults, Classes, StrUtils,
{$ELSE}
  System.Rtti, System.Classes, System.StrUtils,
  System.Generics.Defaults, System.Generics.Collections,
{$ENDIF}
  plBindAPI.Types;

type

  TPlRTTIUtils = class
  private
    class var FContext: TRttiContext;
    class function CastToEnumeration(AValue: TValue): TValue;
    class function CastToFloat(AValue: TValue): TValue;
    class function CastToInt64(AValue: TValue): TValue;
    class function CastToInteger(AValue: TValue): TValue;
    class function CastToString(AValue: TValue): TValue;
    class function FirstNode(var pathNodes: string): string;
    class function GetRecordFieldValue(Sender: TObject;
      AOwner, AField: TRTTIField): TValue; overload;
    class function GetRecordFieldValue(Sender: TObject; AOwner: TRttiProperty;
      AField: TRTTIField): TValue; overload;
    class procedure SetRecordFieldValue(Sender: TObject;
      AOwner, AField: TRTTIField; AValue: TValue); overload;
    class procedure SetRecordFieldValue(Sender: TObject; AOwner: TRttiProperty;
      AField: TRTTIField; AValue: TValue); overload;
  public
    class constructor Create;
    class property Context: TRttiContext read FContext;
    class function AreEqual(Left, Right: TValue): Boolean;
    class function ComponentFromPath(ASource: TComponent;
      var APropertyPath: string): TComponent; static;
    class function EnumerationToOrdinal(const AType: TRTTIType;
      AValue: TValue): TValue;
    class function GetPathValue(ARoot: TObject; var APath: string): TValue;
    class function GetRecordPathValue(ARoot: TObject;
      var APath: string): TValue;
    class function InternalCastTo(const AType: TTypeKind; AValue: TValue)
      : TValue; overload;
    class function InternalCastTo(const AType: TRTTIType; AValue: TValue)
      : TValue; overload;
    class function InvokeEx(const AMethodName: string; AClass: TClass;
      Instance: TValue; const Args: array of TValue): TValue; static;
    class function MethodIsImplemented(const AClass: TClass; MethodName: string)
      : Boolean; overload;
    class function MethodIsImplemented(ATypeInfo: Pointer; MethodName: string)
      : Boolean; overload;
    class function OrdinalToEnumeration(const AType: TRTTIType;
      AValue: TValue): TValue;
    class function PropertyExists(const AClass: TClass; APropertyName: string)
      : Boolean; overload;
    class function PropertyExists(ATypeInfo: Pointer; APropertyName: string)
      : Boolean; overload;
    class function SameSignature(const rParams: TArray<TRttiParameter>; const Args:
        array of TValue): Boolean; static;
    class function SetMethod(ARoot: TObject; const ARootMethodPath: string;
      ATarget: TObject; const ATargetMethodName: string = ''): Boolean; inline;
    class procedure SetPathValue(ARoot: TObject; const APath: string;
      AValue: TValue); inline;
    class procedure SetRecordPathValue(ARoot: TObject; const APath: string;
      AValue: TValue);
  end;

implementation

uses
  System.TypInfo, System.Hash, System.SysUtils, System.Math;

{ TPlRTTIUtils }

class function TPlRTTIUtils.AreEqual(Left, Right: TValue): Boolean;
var
  pLeft, pRight: Pointer;
begin
  Result := False;
  if Left.IsOrdinal then
    Result := Left.AsOrdinal = Right.AsOrdinal
  else if Left.TypeInfo = System.TypeInfo(Single) then
    Result := SameValue(Left.AsType<Single>(), Right.AsType<Single>())
  else if Left.TypeInfo = System.TypeInfo(Double) then
    Result := SameValue(Left.AsType<Double>(), Right.AsType<Double>())
  else if Left.Kind in [tkChar, tkString, tkWChar, tkLString, tkWString,
    tkUString] then
    Result := Left.AsString = Right.AsString
  else if Left.IsClass and Right.IsClass then
    Result := Left.AsClass = Right.AsClass
  else if Left.IsObject then
    Result := Left.AsObject = Right.AsObject
  else if (Left.Kind = tkPointer) or (Left.TypeInfo = Right.TypeInfo) then
  begin
    pLeft := nil;
    pRight := nil;
    Left.ExtractRawDataNoCopy(pLeft);
    Right.ExtractRawDataNoCopy(pRight);
    Result := pLeft = pRight;
  end
  else if Left.TypeInfo = System.TypeInfo(Variant) then
    Result := Left.AsVariant = Right.AsVariant
  else if Left.TypeInfo = System.TypeInfo(TGUID) then
    Result := IsEqualGuid(Left.AsType<TGUID>, Right.AsType<TGUID>)
end;

class function TPlRTTIUtils.ComponentFromPath(ASource: TComponent;
  var APropertyPath: string): TComponent;
var
  componentName: string;
  dotIndex: Integer;
  nextComponent: TComponent;
  sourceComponent: TComponent;
begin
  sourceComponent := TComponent(ASource);
  dotIndex := Pos('.', APropertyPath);
  while dotIndex > 0 do
  begin
    componentName := Copy(APropertyPath, 1, dotIndex - 1);
    Delete(APropertyPath, 1, dotIndex);
    nextComponent := sourceComponent.FindComponent(componentName);
    if Assigned(nextComponent) then
    begin
      dotIndex := Pos('.', APropertyPath);
      sourceComponent := nextComponent;
    end
    else
      dotIndex := 0;
  end;
  Result := sourceComponent;
end;

class constructor TPlRTTIUtils.Create;
begin
  FContext := TRttiContext.Create;
end;

class function TPlRTTIUtils.CastToEnumeration(AValue: TValue): TValue;
begin
  Result := AValue;
  case AValue.Kind of
    tkInteger:
      Result := AValue.AsOrdinal;
  end;
end;

class function TPlRTTIUtils.CastToFloat(AValue: TValue): TValue;
begin
  Result := AValue;
  case AValue.Kind of
    tkString, tkLString, tkWString, tkWChar, tkUString:
      Result := StrToFloat(AValue.AsString);
  end;
end;

class function TPlRTTIUtils.CastToInt64(AValue: TValue): TValue;
begin
  Result := AValue;
  case AValue.Kind of
    tkString, tkLString, tkWString, tkWChar, tkUString:
      Result := StrToInt64(AValue.AsString);
    tkFloat:
      Result := Trunc(AValue.AsType<Double>);
  end;
end;

class function TPlRTTIUtils.CastToInteger(AValue: TValue): TValue;
begin
  Result := AValue;
  case AValue.Kind of
    tkString, tkLString, tkWString, tkWChar, tkUString:
      Result := StrToInt(AValue.AsString);
    tkFloat:
      Result := Trunc(AValue.AsType<Double>);
  end;
end;

class function TPlRTTIUtils.CastToString(AValue: TValue): TValue;
begin
  Result := AValue;
  case AValue.Kind of
    tkString, tkLString, tkWString, tkWChar, tkUString:
      Result := AValue.AsString;
    tkFloat:
      Result := FloatToStr(AValue.AsType<Double>);
    tkInteger:
      Result := IntToStr(AValue.AsInteger);
    tkInt64:
      Result := IntToStr(AValue.AsInt64);
  end;
end;

class function TPlRTTIUtils.EnumerationToOrdinal(const AType: TRTTIType;
  AValue: TValue): TValue;
begin
  Result := AValue.AsOrdinal; (* Bug#12 - Could be useless *)
end;

class function TPlRTTIUtils.FirstNode(var pathNodes: string): string;
var
  dot: string;
  i: Integer;
  nodes: TArray<string>;
begin
  if pathNodes <> '' then
  begin
    nodes := pathNodes.Split(['.']);
    Result := nodes[0];
    dot := '';
    pathNodes := '';
    for i := 1 to High(nodes) do
    begin
      pathNodes := pathNodes + dot + nodes[i];
      dot := '.';
    end;
  end
  else
    Result := '';
end;

class function TPlRTTIUtils.GetPathValue(ARoot: TObject;
  var APath: string): TValue;
var
  currentRoot: TObject;
  myField: TRTTIField;
  myPath: string;
  myProp: TRttiProperty;
  nodeName: string;
  propertyInfo: PPropInfo;
begin
  myPath := APath;
  if myPath = '' then
  begin
    Result := ARoot;
    Exit;
  end;
  currentRoot := ARoot;
  myProp := nil;
  myField := nil;
  while myPath <> '' do
  begin
    nodeName := FirstNode(myPath);
    { 1. locate the first Node, both prop or field }
    myField := FContext.GetType(currentRoot.ClassType).GetField(nodeName);
    if not Assigned(myField) then
      myProp := FContext.GetType(currentRoot.ClassType).GetProperty(nodeName);

    { 2. if there are no more Nodes... }
    if myPath <> '' then
    begin
      { ... we manage the next Node in the tree }
      if Assigned(myField) then
      begin
        myProp := nil;
        if myField.FieldType.IsRecord then
        begin
          myPath := nodeName + IfThen(myPath <> '', '.' + myPath, '');
          Result := GetRecordPathValue(currentRoot, myPath);
          Exit;
        end
        else if myField.FieldType.isInstance then
          currentRoot := myField.GetValue(currentRoot).AsObject;
      end
      else if Assigned(myProp) then
      begin
        if myProp.PropertyType.IsRecord then
        begin
          myPath := nodeName + IfThen(myPath <> '', '.' + myPath, '');
          Result := GetRecordPathValue(currentRoot, myPath);
          Exit;
        end
        else if (myProp.PropertyType.isInstance) then
          currentRoot := myProp.GetValue(currentRoot).AsObject;
      end
      else
        raise Exception.Create(APath + ' is not a path to property or field.');
    end;
  end;

  // 3) con l'ultimo nodo e la proprietà da impostare, si esegue l'operazione appropriata
  if Assigned(myField) then
    case myField.FieldType.TypeKind of
      tkClass:
        Result := myField.GetValue(currentRoot).AsObject
    else
      Result := myField.GetValue(currentRoot);
    end
  else if Assigned(myProp) then
    case myProp.PropertyType.TypeKind of
      tkClass:
        begin
          propertyInfo := (myProp as TRttiInstanceProperty).PropInfo;
          Result := GetObjectProp(currentRoot, propertyInfo);
        end
    else
      Result := myProp.GetValue(currentRoot);
    end
  else
    raise Exception.Create(APath + ' is not a path to property or field.');
end;

class function TPlRTTIUtils.GetRecordFieldValue(Sender: TObject;
  AOwner, AField: TRTTIField): TValue;
begin
  Result := AField.GetValue(PByte(Sender) + AOwner.Offset);
end;

{ Get record value when a is a field of a property }
class function TPlRTTIUtils.GetRecordFieldValue(Sender: TObject;
  AOwner: TRttiProperty; AField: TRTTIField): TValue;
var
  MyPointer: Pointer;
begin
  MyPointer := TRttiInstanceProperty(AOwner).PropInfo^.GetProc;
  Result := AField.GetValue(PByte(Sender) + Smallint(MyPointer));
end;

class function TPlRTTIUtils.GetRecordPathValue(ARoot: TObject;
  var APath: string): TValue;
var
  myField: TRTTIField;
  myFieldRoot: TRTTIField;
  myRecField: TRTTIField;
  myProp: TRttiProperty;
  myPropRoot: TRttiProperty;
  myPath: string;
  nodeName: string;
begin
  myPropRoot := nil;
  myProp := nil;

  myPath := APath;
  nodeName := FirstNode(myPath);
  { Find the record, both prop or field }
  myField := FContext.GetType(ARoot.ClassType).GetField(nodeName);
  myFieldRoot := myField;
  if not Assigned(myField) then
  begin
    myProp := FContext.GetType(ARoot.ClassType).GetProperty(nodeName);
    myPropRoot := myProp;
  end;
  { Loop on props tree }
  { TODO 1 -oPMo -cRefactoring : Manage properties of advanced records }
  while myPath.Contains('.') do
  begin
    nodeName := FirstNode(myPath);
    if Assigned(myField) then
      myField := myField.FieldType.GetField(nodeName)
    else
      myField := myProp.PropertyType.GetField(nodeName);
  end;
  if Assigned(myField) then
    myRecField := myField.FieldType.GetField(myPath)
  else
    myRecField := myProp.PropertyType.GetField(myPath);

  try
    if Assigned(myFieldRoot) then
      Result := GetRecordFieldValue(ARoot, myFieldRoot, myRecField)
    else
      Result := GetRecordFieldValue(ARoot, myPropRoot, myRecField);
  except
    on e: Exception do
      raise Exception.Create('Error on setting ' + APath + ': ' + e.Message);
  end;
end;

class function TPlRTTIUtils.InternalCastTo(const AType: TTypeKind;
  AValue: TValue): TValue;
begin
  Result := AValue;
  case AType of
    tkInteger:
      Result := CastToInteger(AValue);
    tkInt64:
      Result := CastToInt64(AValue);
    tkFloat:
      Result := CastToFloat(AValue);
    tkString, tkLString, tkWString, tkWChar, tkUString:
      Result := CastToString(AValue);
    tkEnumeration:
      Result := CastToEnumeration(AValue);
  end;
end;

{ from https://stackoverflow.com/questions/10083448/trttimethod-invoke-function-doesnt-work-in-overloaded-methods }
{
  r := RttiMethodInvokeEx('Create', AClass, '', ['hello from constructor string']);
  r := RttiMethodInvokeEx('Create', AClass, '', []);
  RttiMethodInvokeEx('Add', AClass, AnObject , ['this is a string']);
}
class function TPlRTTIUtils.InternalCastTo(const AType: TRTTIType;
  AValue: TValue): TValue;
begin
  (* Bug#12: Inserted to differentiate the cast for tkEnumeration type *)
  if (AType.TypeKind = tkEnumeration) and (AValue.IsOrdinal) then
    Result := OrdinalToEnumeration(AType, AValue)
  else if (AType.TypeKind = tkInteger) and (AValue.Kind = tkEnumeration) then
    Result := EnumerationToOrdinal(AType, AValue)
  else
    Result := InternalCastTo(AType.TypeKind, AValue);
end;

class function TPlRTTIUtils.InvokeEx(const AMethodName: string; AClass: TClass;
  Instance: TValue; const Args: array of TValue): TValue;
var
  methodFound: Boolean;
  rMethod: TRttiMethod;
//  rIndex: Integer;
  rParams: TArray<TRttiParameter>;
  rType: TRttiInstanceType;
begin
  Result := nil;
  rMethod := nil;
  methodFound := False;
  rType := FContext.GetType(AClass) as TRttiInstanceType;
  if not Instance.IsObject then
    Instance := rType.MetaclassType;
  for rMethod in rType.GetMethods do
    if SameText(rMethod.Name, AMethodName) then
    begin
      rParams := rMethod.GetParameters;
      (* TODO: extracted code - remove after test
        if Length(Args) = Length(rParams) then
        begin
        methodFound := True;
        for rIndex := 0 to Length(rParams) - 1 do
        if not((rParams[rIndex].ParamType.Handle = Args[rIndex].TypeInfo)
        or (Args[rIndex].IsObject and Args[rIndex].AsObject.InheritsFrom
        (rParams[rIndex].ParamType.AsInstance.MetaclassType))) then
        begin
        methodFound := False;
        Break;
        end;
        end;
      *)
      methodFound := SameSignature(rParams, Args);
      if methodFound then
        Break;
    end;

  if (rMethod <> nil) and methodFound then
    Result := rMethod.Invoke(Instance, Args)
  else
    raise Exception.CreateFmt('method %s not found', [AMethodName]);
end;

class function TPlRTTIUtils.MethodIsImplemented(ATypeInfo: Pointer;
  MethodName: string): Boolean;
var
  m: TRttiMethod;
begin
  { from https://stackoverflow.com/questions/8305008/how-i-can-determine-if-an-abstract-method-is-implemented }
  Result := False;
  for m in FContext.GetType(ATypeInfo).GetDeclaredMethods do
  begin
    Result := CompareText(m.Name, MethodName) = 0;
    if Result then
      Break;
  end;
end;

class function TPlRTTIUtils.OrdinalToEnumeration(const AType: TRTTIType;
  AValue: TValue): TValue;
begin
  (* Bug#12: To be implemented *)
end;

class function TPlRTTIUtils.PropertyExists(const AClass: TClass;
  APropertyName: string): Boolean;
begin
  Result := PropertyExists(AClass.ClassInfo, APropertyName);
end;

class function TPlRTTIUtils.PropertyExists(ATypeInfo: Pointer;
  APropertyName: string): Boolean;
var
  rType: TRTTIType;
begin
  Result := False;
  rType := FContext.GetType(ATypeInfo);
  if rType <> nil then
    Result := rType.GetProperty(APropertyName) <> nil;
end;

class function TPlRTTIUtils.MethodIsImplemented(const AClass: TClass;
  MethodName: string): Boolean;
var
  m: TRttiMethod;
begin
  { from https://stackoverflow.com/questions/8305008/how-i-can-determine-if-an-abstract-method-is-implemented }
  Result := False;
  for m in FContext.GetType(AClass.ClassInfo).GetDeclaredMethods do
  begin
    Result := CompareText(m.Name, MethodName) = 0;
    if Result then
      Break;
  end;
end;

class function TPlRTTIUtils.SameSignature(const rParams: TArray<TRttiParameter>;
  const Args: array of TValue): Boolean;
var
  rIndex: Integer;
begin
  Result := False;
  if Length(Args) = Length(rParams) then
  begin
    Result := True;
    for rIndex := 0 to Length(rParams) - 1 do
      if not((rParams[rIndex].ParamType.Handle = Args[rIndex].TypeInfo) or
        (Args[rIndex].IsObject and Args[rIndex].AsObject.InheritsFrom(rParams
        [rIndex].ParamType.AsInstance.MetaclassType))) then
      begin
        Result := False;
        Break;
      end;
  end;
end;

class function TPlRTTIUtils.SetMethod(ARoot: TObject;
  const ARootMethodPath: string; ATarget: TObject;
  const ATargetMethodName: string): Boolean;
var
  rType: TRTTIType;
  rMethod: TRttiMethod;
  methodPath: string;
  sourceObject: TObject;
  recMethod: TMethod;
begin
  Result := False;
  methodPath := ARootMethodPath;
  if (ARoot is TComponent) then
    sourceObject := ComponentFromPath(TComponent(ARoot), methodPath)
  else
    sourceObject := ARoot;
  { Extract type information for ASource's type }
  rType := FContext.GetType(ATarget.ClassType);
  rMethod := rType.GetMethod(ATargetMethodName);
  if Assigned(rMethod) then
  begin
    recMethod.Code := rMethod.CodeAddress;
    recMethod.Data := Pointer(ATarget); // (Self);
    SetMethodProp(sourceObject, methodPath, recMethod);
    Result := True;
  end;

end;

class procedure TPlRTTIUtils.SetPathValue(ARoot: TObject; const APath: string;
  AValue: TValue);
var
  currentRoot: TObject;
  myField: TRTTIField;
  myPath: string;
  myProp: TRttiProperty;
  nodeName: string;
  propertyInfo: PPropInfo;
begin
  currentRoot := ARoot;
  myField := nil;
  myProp := nil;
  myPath := APath;
  while myPath <> '' do
  begin
    nodeName := FirstNode(myPath);
    { First node, both prop or field }
    myField := FContext.GetType(currentRoot.ClassType).GetField(nodeName);
    if not Assigned(myField) then
    begin
      myProp := FContext.GetType(currentRoot.ClassType).GetProperty(nodeName);
    end;

    if myPath <> '' then
    begin
      { the child node is a field }
      if Assigned(myField) then
      begin
        myProp := nil;
        if myField.FieldType.IsRecord then
        begin
          myPath := nodeName + '.' + IfThen(myPath <> '', '.' + myPath, '');
          SetRecordPathValue(currentRoot, myPath, AValue);
          Exit;
        end
        else if myField.FieldType.isInstance then
          currentRoot := myField.GetValue(currentRoot).AsObject;
      end
      else if Assigned(myProp) then
      begin
        if myProp.PropertyType.IsRecord then
        begin
          { Set the record value using a procedure and exit }
          myPath := nodeName + IfThen(myPath <> '', '.' + myPath, '');
          SetRecordPathValue(currentRoot, myPath, AValue);
          Exit;
        end
        else if myProp.PropertyType.isInstance then
          currentRoot := myProp.GetValue(currentRoot).AsObject;
      end
      else
        raise Exception.Create(APath + ' is not a path to property or field.');
      if myPath = '' then
        Break;
    end;
  end;
  { eventually, we set the value of the last node, if any }
  if Assigned(myField) then
  begin
    if (myField.FieldType.TypeKind <> AValue.Kind) then
      AValue := InternalCastTo(myField.FieldType.TypeKind, AValue);
    case myField.FieldType.TypeKind of
      tkClass:
        myField.SetValue(currentRoot, TObject(AValue.AsObject))
    else
      myField.SetValue(currentRoot, AValue);
    end;
  end
  else if Assigned(myProp) then
  begin
    if (myProp.PropertyType.TypeKind <> AValue.Kind) then
      AValue := InternalCastTo(myProp.PropertyType.TypeKind, AValue);
    case myProp.PropertyType.TypeKind of
      tkClass:
        begin
          propertyInfo := (myProp as TRttiInstanceProperty).PropInfo;
          SetObjectProp(currentRoot, propertyInfo, AValue.AsObject);
        end
    else
      myProp.SetValue(currentRoot, AValue);
    end;
  end
  else
    raise Exception.Create(APath + ' is not a path to property or field.');
end;

{ Set record value when a is a field of a field }
class procedure TPlRTTIUtils.SetRecordFieldValue(Sender: TObject;
  AOwner, AField: TRTTIField; AValue: TValue);
begin
  if (AField.FieldType.TypeKind <> AValue.Kind) then
    AValue := InternalCastTo(AField.FieldType.TypeKind, AValue);
  AField.SetValue(PByte(Sender) + AOwner.Offset, AValue);
end;

class procedure TPlRTTIUtils.SetRecordFieldValue(Sender: TObject;
  AOwner: TRttiProperty; AField: TRTTIField; AValue: TValue);
var
  lPointer: Pointer;
begin
  if (AField.FieldType.TypeKind <> AValue.Kind) then
    AValue := InternalCastTo(AField.FieldType.TypeKind, AValue);
  lPointer := TRttiInstanceProperty(AOwner).PropInfo^.GetProc;
  AField.SetValue(PByte(Sender) + Smallint(lPointer), AValue);
end;

{ Set record value when a is a field of a property
  Remember a record should not contain classes as member, nor record as prop.
  So the first Node could be a simple property or a field,
  and the following Nodes should be fields only }
class procedure TPlRTTIUtils.SetRecordPathValue(ARoot: TObject;
  const APath: string; AValue: TValue);
var
  myField: TRTTIField;
  myFieldRoot: TRTTIField;
  myRecField: TRTTIField;
  myProp: TRttiProperty;
  myPropRoot: TRttiProperty;
  myPath: string;
  nodeName: string;
begin
  myPropRoot := nil;
  myProp := nil;

  myPath := APath;
  nodeName := FirstNode(myPath);

  myField := FContext.GetType(ARoot.ClassType).GetField(nodeName);
  myFieldRoot := myField;
  if not Assigned(myField) then
  begin
    myProp := FContext.GetType(ARoot.ClassType).GetProperty(nodeName);
    myPropRoot := myProp;
  end;
  { First Node, both prop or field }
  while myPath.Contains('.') do
  begin
    nodeName := FirstNode(myPath);
    if Assigned(myField) then
      myField := myField.FieldType.GetField(nodeName)
    else
      myField := myProp.PropertyType.GetField(nodeName);
  end;
  if Assigned(myField) then
    myRecField := myField.FieldType.GetField(myPath)
  else
    myRecField := myProp.PropertyType.GetField(myPath);

  try
    if Assigned(myFieldRoot) then
      SetRecordFieldValue(ARoot, myFieldRoot, myRecField, AValue)
    else
      SetRecordFieldValue(ARoot, myPropRoot, myRecField, AValue);
  except
    on e: Exception do
      raise Exception.Create('Error on setting ' + APath + ': ' + e.Message);
  end;

end;

end.
