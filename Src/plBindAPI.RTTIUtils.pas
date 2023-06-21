{ **************************************************************************** }
{ BindAPI                                                                      }
{ Copyright (C) 2020 Paolo Morandotti                                          }
{ Unit plBindAPI.RTTIQuery                                                     }
{ **************************************************************************** }
{                                                                              }
{ Permission is hereby granted, free of charge, to any person obtaining        }
{ a copy of this software and associated documentation files (the "Software"), }
{ to deal in the Software without restriction, including without limitation    }
{ the rights to use, copy, modify, merge, publish, distribute, sublicense,     }
{ and/or sell copies of the Software, and to permit persons to whom the        }
{ Software is furnished to do so, subject to the following conditions:         }
{                                                                              }
{ The above copyright notice and this permission notice shall be included in   }
{ all copies or substantial portions of the Software.                          }
{                                                                              }
{ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS      }
{ OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  }
{ FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE  }
{ AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER       }
{ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING      }
{ FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS }
{ IN THE SOFTWARE.                                                             }
{ **************************************************************************** }

unit plBindAPI.RTTIUtils;

interface

uses
  Rtti, Generics.Collections, Generics.Defaults, Classes, StrUtils,
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
    class function ExtractNode(ARoot: TObject; out AField: TRTTIField; out AProp:
        TRttiProperty; const ANodeName: string): Boolean;
    class function ExtractNodeType(AField: TRTTIField; AProp: TRttiProperty)
      : TRttiType; inline;
    class function FirstNode(var pathNodes: string): string;
    class function GetRecordFieldValue(Sender: TObject;
      AOwner, AField: TRTTIField): TValue; overload;
    class function GetRecordFieldValue(Sender: TObject; AOwner: TRttiProperty;
      AField: TRTTIField): TValue; overload;
    class procedure Log(const AMessage: string);
    class function NextNode(const ANodeName: string; var ARoot: TObject;
      var AField: TRTTIField; var AProp: TRttiProperty; var APath: string)
      : TValue; inline;
    class function ReadMemberValue(ARoot: TObject; AField: TRTTIField;
      AProp: TRttiProperty): TValue; inline;
    class procedure SetRecordFieldValue(Sender: TObject;
      AOwner, AField: TRTTIField; AValue: TValue); overload;
    class procedure SetRecordFieldValue(Sender: TObject; AOwner: TRttiProperty;
      AField: TRTTIField; AValue: TValue); overload;
    class procedure WriteFieldValue(ANode: TObject; AField: TRTTIField; AValue:
        TValue);
    class procedure WriteMemberValue(ANode: TObject; AField: TRTTIField; AProp:
        TRttiProperty; const APath: string; AValue: TValue); inline;
    class procedure WritePropertyValue(ANode: TObject; AProp: TRttiProperty;
        AValue: TValue);
  public
    class constructor Create;
    class function AreEqual(Left, Right: TValue): Boolean;
    class function ComponentFromPath(ASource: TComponent;
      var APropertyPath: string): TComponent; static;
    class function EnumerationToOrdinal(const AType: TRttiType;
      AValue: TValue): TValue;
    class function GetPathLastNode(ARoot: TObject; var APath: string; out myField:
        TRTTIField; out myProp: TRttiProperty): TValue;
    class function GetPathValue(ARoot: TObject; var APath: string): TValue;
    class function GetRecordPathValue(ARoot: TObject;
      var APath: string): TValue;
    class function InternalCastTo(const AType: TRttiType; AValue: TValue)
      : TValue; overload;
    class function InternalCastTo(const AType: TTypeKind; AValue: TValue)
      : TValue; overload;
    class function InvokeEx(const AMethodName: string; AClass: TClass;
      Instance: TValue; const Args: array of TValue): TValue; static;
    class function IsValidPath(ARoot: TObject; const APath: string): Boolean;
    class function MethodIsImplemented(ATypeInfo: Pointer; AMethodName: string)
      : Boolean; overload;
    class function MethodIsImplemented(const AClass: TClass; AMethodName: string)
      : Boolean; overload;
    class function OrdinalToEnumeration(const AType: TRttiType;
      AValue: TValue): TValue;
    class function PropertyExists(ATypeInfo: Pointer; APropertyName: string)
      : Boolean; overload;
    class function PropertyExists(const AClass: TClass; APropertyName: string)
      : Boolean; overload;
    class function SameSignature(const AParams: TArray<TRttiParameter>;
      const Args: array of TValue): Boolean; static;
    class function SetMethod(ARoot: TObject; const ARootMethodPath: string;
      ATarget: TObject; const ATargetMethodName: string = ''): Boolean; inline;
    class procedure SetPathValue(ARoot: TObject; const APath: string;
      AValue: TValue); inline;
    class procedure SetRecordPathValue(ARoot: TObject; const APath: string;
      AValue: TValue);
    class property Context: TRttiContext read FContext;
  end;

implementation

uses
  TypInfo, Hash, IOUtils, SysUtils, Math;

class constructor TPlRTTIUtils.Create;
begin
  FContext := TRttiContext.Create;
end;

{TPlRTTIUtils}

class function TPlRTTIUtils.AreEqual(Left, Right: TValue): Boolean;
var
  pLeft, pRight: Pointer;
begin
  Result := False;
  if Left.IsOrdinal then
    Exit(Left.AsOrdinal = Right.AsOrdinal);
  if Left.TypeInfo = System.TypeInfo(Single) then
    Exit(SameValue(Left.AsType<Single>(), Right.AsType<Single>()));
  if Left.TypeInfo = System.TypeInfo(Double) then
    Exit(SameValue(Left.AsType<Double>(), Right.AsType<Double>()));
  if Left.Kind in [tkChar, tkString, tkWChar, tkLString, tkWString, tkUString] then
    Exit(Left.AsString = Right.AsString);
  if Left.IsClass and Right.IsClass then
    Exit(Left.AsClass = Right.AsClass);
  if Left.IsObject then
    Exit(Left.AsObject = Right.AsObject);
  if (Left.Kind = tkPointer) or (Left.TypeInfo = Right.TypeInfo) then
    begin
      pLeft := nil;
      pRight := nil;
      Left.ExtractRawDataNoCopy(pLeft);
      Right.ExtractRawDataNoCopy(pRight);
      Exit(pLeft = pRight);
    end;
  if Left.TypeInfo = System.TypeInfo(Variant) then
    Exit(Left.AsVariant = Right.AsVariant);
  if Left.TypeInfo = System.TypeInfo(TGUID) then
    Exit(IsEqualGuid(Left.AsType<TGUID>, Right.AsType<TGUID>));
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

class function TPlRTTIUtils.EnumerationToOrdinal(const AType: TRttiType;
  AValue: TValue): TValue;
begin
  Result := AValue.AsOrdinal; (*Bug#12 - Could be useless*)
end;

class function TPlRTTIUtils.ExtractNode(ARoot: TObject; out AField: TRTTIField;
    out AProp: TRttiProperty; const ANodeName: string): Boolean;
begin
  Result := True;
  AProp := nil;
  AField := FContext.GetType(ARoot.ClassType).GetField(ANodeName);
  if not Assigned(AField) then
    begin
      AProp := FContext.GetType(ARoot.ClassType).GetProperty(ANodeName);
      if not Assigned(AProp) then
        begin
          { TODO -oPMo -cFeatures : write this error to a log file }
          Log('Can''t find ' + ARoot.ClassName + '.' + ANodeName);
          raise Exception.Create('Can''t find ' + ARoot.ClassName + '.' +
          ANodeName);
        end;
    end;

end;

class function TPlRTTIUtils.ExtractNodeType(AField: TRTTIField;
  AProp: TRttiProperty): TRttiType;
begin
  if Assigned(AField) then
    Result := AField.FieldType
  else if Assigned(AProp) then
    Result := AProp.PropertyType
  else
    raise Exception.Create('No member available.');
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

{returns the instance of the last - 1 object in the path}
{use this function to                                   }
{verify if the path is correct                          }
{ or                                                    }
{get the last node value                                }
class function TPlRTTIUtils.GetPathLastNode(ARoot: TObject;
  var APath: string; out myField: TRTTIField;
  out myProp: TRttiProperty): TValue;
var
  currentNode: TObject;
  myPath: string;
  nodeName: string;
  nodeType: TRttiType;
begin

  if APath = '' then
    Exit(ARoot);

  myPath := APath;
  currentNode := ARoot;
  while myPath <> '' do
    try
      nodeName := FirstNode(myPath);
      {1. locate the first node of the path, both prop or field}
      if (not Assigned(currentNode)) or (not ExtractNode(currentNode, myField, myProp, nodeName)) then
        Exit(nil);

      nodeType := ExtractNodeType(myField, myProp);
      {2a. if there are more nodes...}
      if myPath <> '' then
        begin
          if nodeType.IsRecord then
            begin
              myPath := nodeName + IfThen(myPath <> '', '.' + myPath, '');
              Result := GetRecordPathValue(currentNode, myPath);
              Exit;
            end
          else
            {2b. if there are more Nodes manages them}
            NextNode(nodeName, currentNode, myField, myProp, myPath);
        end;
    except
      Exit(nil);
    end;
  {3. Eventually read the member value}
  Result := currentNode;
end;

class function TPlRTTIUtils.GetPathValue(ARoot: TObject;
  var APath: string): TValue;
var
  currentNode: TObject;
  lastNode: TValue;
  myField: TRTTIField;
  myPath: string;
  myProp: TRttiProperty;
//  nodeName: string;
  NodeType: TRttiType;
begin
  if APath = '' then
      Exit(ARoot);

  myPath := APath;
  currentNode := ARoot;
  lastNode := GetPathLastNode(currentNode, myPath, myField, myProp);
  if lastNode.IsObject then
    begin
      currentNode := lastNode.AsObject;
      Result := ReadMemberValue(currentNode, myField, myProp);
    end
  else
    begin
      Result := GetRecordPathValue(currentNode, myPath);
      Exit;
    end;
end;

class function TPlRTTIUtils.GetRecordFieldValue(Sender: TObject;
  AOwner, AField: TRTTIField): TValue;
begin
  Result := AField.GetValue(PByte(Sender) + AOwner.Offset);
end;

{Get record value when a is a field of a property}
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
  {Find the record, both prop or field}
  myField := FContext.GetType(ARoot.ClassType).GetField(nodeName);
  myFieldRoot := myField;
  if not Assigned(myField) then
    begin
      myProp := FContext.GetType(ARoot.ClassType).GetProperty(nodeName);
      myPropRoot := myProp;
    end;
  {Loop on props tree}
  {TODO 1 -oPMo -cRefactoring : Manage properties of advanced records}
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

class function TPlRTTIUtils.InternalCastTo(const AType: TRttiType;
  AValue: TValue): TValue;
begin
  (*Bug#12: Inserted to differentiate the cast for tkEnumeration type*)
  if (AType.TypeKind = tkEnumeration) and (AValue.IsOrdinal) then
    Result := OrdinalToEnumeration(AType, AValue)
  else if (AType.TypeKind = tkInteger) and (AValue.Kind = tkEnumeration) then
    Result := EnumerationToOrdinal(AType, AValue)
  else
    Result := InternalCastTo(AType.TypeKind, AValue);
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

{from https://stackoverflow.com/questions/10083448/trttimethod-invoke-function-doesnt-work-in-overloaded-methods}
{
  r := RttiMethodInvokeEx('Create', AClass, '', ['hello from constructor string']);
  r := RttiMethodInvokeEx('Create', AClass, '', []);
  RttiMethodInvokeEx('Add', AClass, AnObject , ['this is a string']);
}
class function TPlRTTIUtils.InvokeEx(const AMethodName: string; AClass: TClass;
  Instance: TValue; const Args: array of TValue): TValue;
var
  methodFound: Boolean;
  rMethod: TRttiMethod;
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
        methodFound := SameSignature(rParams, Args);
        if methodFound then
          Break;
      end;

  if (rMethod <> nil) and methodFound then
    Result := rMethod.Invoke(Instance, Args)
  else
    raise Exception.CreateFmt('method %s not found', [AMethodName]);
end;

class function TPlRTTIUtils.IsValidPath(ARoot: TObject; const APath: string):
    Boolean;
var
  lastNode: TValue;
  myField: TRTTIField;
  myPath: string;
  myProp: TRttiProperty;
begin
  myPath := APath;
  lastNode := GetPathLastNode(ARoot, myPath, myField, myProp);
  Result := (not lastNode.IsEmpty) and (Assigned(myField) or Assigned(myProp));
end;

class procedure TPlRTTIUtils.Log(const AMessage: string);
var
  fileName: string;
begin
  // Getting the filename for the logfile (In this case the Filename is 'application-exename.log'
  fileName := TPath.GetPublicPath + TPath.DirectorySeparatorChar +
    'morandotti.it' +  TPath.DirectorySeparatorChar + 'BindApi' +
    TPath.DirectorySeparatorChar +'Errors.log';

  if not DirectoryExists(ExtractFilePath(fileName)) then
    ForceDirectories(ExtractFilePath(fileName));

  TFile.AppendAllText(fileName, AMessage);
end;

class function TPlRTTIUtils.MethodIsImplemented(ATypeInfo: Pointer;
  AMethodName: string): Boolean;
var
  m: TRttiMethod;
begin
  {from https://stackoverflow.com/questions/8305008/how-i-can-determine-if-an-abstract-method-is-implemented}
  Result := False;
  for m in FContext.GetType(ATypeInfo).GetDeclaredMethods do
    begin
      Result := CompareText(m.Name, AMethodName) = 0;
      if Result then
        Break;
    end;
end;

class function TPlRTTIUtils.MethodIsImplemented(const AClass: TClass;
  AMethodName: string): Boolean;
var
  m: TRttiMethod;
begin
  {from https://stackoverflow.com/questions/8305008/how-i-can-determine-if-an-abstract-method-is-implemented}
  Result := False;
  for m in FContext.GetType(AClass.ClassInfo).GetDeclaredMethods do
    begin
      Result := CompareText(m.Name, AMethodName) = 0;
      if Result then
        Break;
    end;
end;

class function TPlRTTIUtils.NextNode(const ANodeName: string;
  var ARoot: TObject; var AField: TRTTIField; var AProp: TRttiProperty;
  var APath: string): TValue;
var
  memberType: TRttiType;
begin
  if Assigned(AField) then
    begin
      AProp := nil;
      memberType := AField.FieldType;
    end
  else if Assigned(AProp) then
    begin
      AField := nil;
      memberType := AProp.PropertyType;
    end
  else
    begin
      Log(APath + ' is not a path to property or field.');
      raise Exception.Create(APath + ' is not a path to property or field.');
    end;
  Result := TValue.Empty;
  if memberType.IsRecord then
    begin
      APath := ANodeName + IfThen(APath <> '', '.' + APath, '');
      Result := GetRecordPathValue(ARoot, APath);
    end;
  if memberType.isInstance then
    begin
      if Assigned(AField) then
        ARoot := AField.GetValue(ARoot).AsObject
      else
        ARoot := AProp.GetValue(ARoot).AsObject;
    end;
end;

class function TPlRTTIUtils.OrdinalToEnumeration(const AType: TRttiType;
  AValue: TValue): TValue;
begin
  (*Bug#12: To be implemented*)
end;

class function TPlRTTIUtils.PropertyExists(ATypeInfo: Pointer;
  APropertyName: string): Boolean;
var
  rType: TRttiType;
begin
  Result := False;
  rType := FContext.GetType(ATypeInfo);
  if rType <> nil then
    Result := rType.GetProperty(APropertyName) <> nil;
end;

class function TPlRTTIUtils.PropertyExists(const AClass: TClass;
  APropertyName: string): Boolean;
begin
  Result := PropertyExists(AClass.ClassInfo, APropertyName);
end;

class function TPlRTTIUtils.ReadMemberValue(ARoot: TObject; AField: TRTTIField;
  AProp: TRttiProperty): TValue;
var
  propertyInfo: PPropInfo;
begin
  Result := TValue.Empty;
  if Assigned(AField) then
    case AField.FieldType.TypeKind of
      tkClass:
        Result := AField.GetValue(ARoot).AsObject
    else
      Result := AField.GetValue(ARoot);
    end
  else if Assigned(AProp) then
    case AProp.PropertyType.TypeKind of
      tkClass:
        begin
          propertyInfo := (AProp as TRttiInstanceProperty).PropInfo;
          Result := GetObjectProp(ARoot, propertyInfo);
        end
    else
      Result := AProp.GetValue(ARoot);
    end;
end;

class function TPlRTTIUtils.SameSignature(const AParams:
    TArray<TRttiParameter>; const Args: array of TValue): Boolean;
var
  rIndex: Integer;
begin
  Result := False;
  if Length(Args) = Length(AParams) then
    begin
      Result := True;
      for rIndex := 0 to Length(AParams) - 1 do
        if not((AParams[rIndex].ParamType.Handle = Args[rIndex].TypeInfo) or
          (Args[rIndex].IsObject and Args[rIndex].AsObject.InheritsFrom(AParams
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
  rType: TRttiType;
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
  {Extract type information for ASource's type}
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
  currentNode: TObject;
  myField: TRTTIField;
  myPath: string;
  myProp: TRttiProperty;
  nodeName: string;
  nodeType: TRttiType;
begin
  currentNode := ARoot;
  myField := nil;
  myProp := nil;
  myPath := APath;
  while myPath <> '' do
    begin
      nodeName := FirstNode(myPath);
      {First node, both prop or field}
      ExtractNode(currentNode, myField, myProp, nodeName);

      nodeType := ExtractNodeType(myField, myProp);
      {2a. if there are more nodes...}
      if myPath <> '' then
        begin
          if NodeType.IsRecord then
            begin
              myPath := nodeName + IfThen(myPath <> '', '.' + myPath, '');
              SetRecordPathValue(currentNode, myPath, AValue);
              Exit;
            end
          else
            {2b. if there are more Nodes manages them}
            NextNode(nodeName, currentNode, myField, myProp, myPath);
        end;
    end;
  {eventually, we set the value of the last node, if any}
  WriteMemberValue(currentNode, myField, myProp, APath, AValue);
end;

{Set record value when a is a field of a field}
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

{Set record value when a is a field of a property
  Remember a record should not contain classes as member, nor record as prop.
  So the first Node could be a simple property or a field,
  and the following Nodes should be fields only}
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
  {First Node, both prop or field}
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

class procedure TPlRTTIUtils.WriteFieldValue(ANode: TObject; AField:
    TRTTIField; AValue: TValue);
begin
  if (AField.FieldType.TypeKind <> AValue.Kind) then
    AValue := InternalCastTo(AField.FieldType.TypeKind, AValue);
  case AField.FieldType.TypeKind of
    tkClass:
      AField.SetValue(ANode, TObject(AValue.AsObject))
  else
    AField.SetValue(ANode, AValue);
  end;
end;

class procedure TPlRTTIUtils.WriteMemberValue(ANode: TObject; AField:
    TRTTIField; AProp: TRttiProperty; const APath: string; AValue: TValue);
begin
  if Assigned(AField) then
    WriteFieldValue(ANode, AField, AValue)
  else if Assigned(AProp) then
    WritePropertyValue(ANode, AProp, AValue)
  else
    raise Exception.Create(APath + ' is not a path to property or field.');
end;

class procedure TPlRTTIUtils.WritePropertyValue(ANode: TObject; AProp:
    TRttiProperty; AValue: TValue);
var
  propertyInfo: PPropInfo;
begin
  if (AProp.PropertyType.TypeKind <> AValue.Kind) then
    AValue := InternalCastTo(AProp.PropertyType.TypeKind, AValue);
  case AProp.PropertyType.TypeKind of
    tkClass:
      begin
        propertyInfo := (AProp as TRttiInstanceProperty).PropInfo;
        SetObjectProp(ANode, propertyInfo, AValue.AsObject);
      end
  else
    AProp.SetValue(ANode, AValue);
  end;
end;

end.
