{*****************************************************************************}
{BindAPI                                                                      }
{Copyright (C) 2020 Paolo Morandotti                                          }
{Unit plBindAPI.RTTIUtils                                                   }
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

unit plBindAPI.RTTIUtils;

interface

uses
  Classes, StrUtils,Rtti,
  Generics.Collections, Generics.Defaults,
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
    class function ExtractField(ARoot: TObject; out AField: TRTTIField;
      const ANodeName: string): Boolean; static;
    class function ExtractFieldType(AField: TRTTIField; out AType: TRttiType)
      : Boolean; static;
    class function ExtractIndexedProperty(ARoot: TObject;
      out AProp: TRttiIndexedProperty; const ANodeName: string): Boolean;
    class function ExtractIndexedPropertyType(AProp: TRttiIndexedProperty;
      out AType: TRttiType): Boolean; static;
    class function ExtractNode(ARoot: TObject; out AMember: TRTTIDataMember;
      out AIndexedProp: TRttiIndexedProperty; const ANodeName: string)
      : Boolean; overload;
    class function ExtractNode(ARoot: TObject; out AField: TRTTIField;
      out AProp: TRttiProperty; out AnIndexedProperty: TRttiIndexedProperty;
      const ANodeName: string): Boolean; overload;
    class function ExtractNodeType(var AField: TRTTIField;
      var AProp: TRttiProperty; const APath: string): TRttiType;
      overload; inline;
    class function ExtractNodeType(AField: TRTTIField; AProp: TRttiProperty;
      AIndexedProp: TRttiIndexedProperty): TRttiType; overload; inline;
    class function ExtractProperty(ARoot: TObject; out AProp: TRttiProperty;
      const ANodeName: string): Boolean; static;
    class function ExtractPropertyType(AProp: TRttiProperty;
      out AType: TRttiType): Boolean; static;
    class function FirstNode(var pathNodes: string): string;
    class function GetRecordFieldValue(Sender: TObject;
      AOwner, AField: TRTTIField): TValue; overload;
    class function GetRecordFieldValue(Sender: TObject; AOwner: TRttiProperty;
      AField: TRTTIField): TValue; overload;
    class function IsEqualPointer(Left, Right: TValue): Boolean;
    class procedure Log(const AMessage: string);
    class function NextNode(const ANodeName: string; var ARoot: TObject;
      var AField: TRTTIField; var AProp: TRttiProperty;
      var AIndexedProp: TRttiIndexedProperty; var APath: string)
      : TValue; inline;
    class function ReadFieldValue(ARoot: TObject; AField: TRTTIField;
      out AValue: TValue): Boolean; static;
    class function ReadIndexedPropertyValue(ARoot: TObject;
      AProp: TRttiIndexedProperty; const AnIndex: string; out AValue: TValue)
      : Boolean; static;
    class function ReadMemberValue(ARoot: TObject; AField: TRTTIField;
      AProp: TRttiProperty; AIndexedProp: TRttiIndexedProperty;
      const AIndex: string): TValue; inline;
    class function ReadPropertyValue(ARoot: TObject; AProp: TRttiProperty;
      out AValue: TValue): Boolean; static;
    class procedure SetRecordFieldValue(Sender: TObject;
      AOwner, AField: TRTTIField; AValue: TValue); overload;
    class procedure SetRecordFieldValue(Sender: TObject; AOwner: TRttiProperty;
      AField: TRTTIField; AValue: TValue); overload;
    class function StringToEnumeration(const AType: TRttiType; AValue: TValue)
      : TValue; static;
    class procedure WriteFieldValue(ANode: TObject; AField: TRTTIField;
      AValue: TValue);
    class procedure WriteMemberValue(ANode: TObject; AField: TRTTIField;
      AProp: TRttiProperty; const APath: string; AValue: TValue); inline;
    class procedure WritePropertyValue(ANode: TObject; AProp: TRttiProperty;
      AValue: TValue);
  public
    class constructor Create;
    class function AreEqual(Left, Right: TValue): Boolean;
    class function ComponentFromPath(ASource: TComponent;
      var APropertyPath: string): TComponent; static;
    class function EnumerationToOrdinal(const AType: TRttiType;
      AValue: TValue): TValue;
    class function GetIndexedPropertyInfo(ARoot: TObject;
      const APropertyName: string): TPlIndexedPropertyInfo; overload;
    class function GetIndexedPropertyInfo(AIndexedProp: TRttiIndexedProperty;
      const AIndex: string): TPlIndexedPropertyInfo; overload;
    class function GetLastNodeInPath(ARoot: TObject; var APath: string;
      out AField: TRTTIField; out AProp: TRttiProperty;
      out AIndexedProperty: TRttiIndexedProperty): TValue;
      deprecated 'use GetPropertyOwner instead.';
    class function GetPathValue(ARoot: TObject; var APath: string): TValue;
    class function GetPropertyOwner(ARoot: TObject; var APath: string;
      out AField: TRTTIField; out AProp: TRttiProperty;
      out AIndexedProperty: TRttiIndexedProperty): TValue;
    class function GetRecordPathValue(ARoot: TObject;
      var APath: string): TValue;
    class function InternalCastTo(const AType: TRttiType; AValue: TValue)
      : TValue; overload;
    class function InternalCastTo(const AType: TTypeKind; AValue: TValue)
      : TValue; overload;
    class function InvokeEx(const AMethodName: string; AClass: TClass;
      Instance: TValue; const Args: array of TValue): TValue; static;
    class function IsIndexedProperty(const AName: string): Boolean; overload;
    class function IsIndexedProperty(ARoot: TObject; const AName: string)
      : Boolean; overload;
    class function IsValidPath(ARoot: TObject; const APath: string): Boolean;
    class function MethodIsImplemented(ATypeInfo: Pointer; AMethodName: string)
      : Boolean; overload;
    class function MethodIsImplemented(const AClass: TClass;
      AMethodName: string): Boolean; overload;
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

resourcestring
  StrCantFind = 'Can''t find ';
  StrErrorOnSetting = 'Error on setting ';
  StrIsNotAPathToProperty = ' is not a path to property or field.';
  StrMethodSNotFound = 'method %s not found';
  StrNoMemberAvailable = 'No member available.';

implementation

uses
  TypInfo, Hash, IOUtils, SysUtils, Math;

resourcestring

// START resource string wizard section
  SMorandottiIt = 'morandotti.it';
  SBindApi = 'BindApi';
  SErrorsLog = 'Errors.log';
// END resource string wizard section
  SWrongParamsNumber = 'Wrong params number.';
  SInvalidFieldOrProperty = 'Invalid field or property';

{TPlRTTIUtils}

class constructor TPlRTTIUtils.Create;
begin
  FContext := TRttiContext.Create;
end;

class function TPlRTTIUtils.AreEqual(Left, Right: TValue): Boolean;
begin
  Result := False;
  if Left.IsOrdinal then
    Exit(Left.AsOrdinal = Right.AsOrdinal);
  if Left.TypeInfo = System.TypeInfo(Single) then
    Exit(SameValue(Left.AsType<Single>(), Right.AsType<Single>()));
  if Left.TypeInfo = System.TypeInfo(Double) then
    Exit(SameValue(Left.AsType<Double>(), Right.AsType<Double>()));
  if Left.Kind in [tkChar, tkString, tkWChar, tkLString, tkWString, tkUString]
  then
    Exit(Left.AsString = Right.AsString);
  if Left.IsClass and Right.IsClass then
    Exit(Left.AsClass = Right.AsClass);
  if Left.IsObject then
    Exit(Left.AsObject = Right.AsObject);
  if (Left.Kind = tkPointer) or (Left.TypeInfo = Right.TypeInfo) then
    Exit(IsEqualPointer(Left, Right));
  if Left.TypeInfo = System.TypeInfo(Variant) then
    Exit(Left.AsVariant = Right.AsVariant);
  if Left.TypeInfo = System.TypeInfo(TGUID) then
    Exit(IsEqualGuid(Left.AsType<TGUID>, Right.AsType<TGUID>));
end;

class function TPlRTTIUtils.CastToEnumeration(AValue: TValue): TValue;
begin
  Result := AValue;
  case AValue.Kind of
    tkInteger, tkInt64:
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

class function TPlRTTIUtils.ExtractField(ARoot: TObject; out AField: TRTTIField;
  const ANodeName: string): Boolean;
begin
  AField := nil;
  Result := False;
  if ANodeName <> '' then
    begin
      AField := FContext.GetType(ARoot.ClassType).GetField(ANodeName);
      Result := Assigned(AField);
    end;
end;

class function TPlRTTIUtils.ExtractFieldType(AField: TRTTIField;
  out AType: TRttiType): Boolean;
begin
  Result := Assigned(AField);
  if Result then
    AType := AField.FieldType;
end;

class function TPlRTTIUtils.ExtractIndexedProperty(ARoot: TObject;
  out AProp: TRttiIndexedProperty; const ANodeName: string): Boolean;
var
  nodeName: string;
begin
  Result := False;
  AProp := nil;
  nodeName := ANodeName.Substring(0, ANodeName.IndexOf('['));
  if nodeName <> '' then
    begin
      AProp := FContext.GetType(ARoot.ClassType).GetIndexedProperty(nodeName);
      Result := Assigned(AProp);
    end;
end;

class function TPlRTTIUtils.ExtractIndexedPropertyType
  (AProp: TRttiIndexedProperty; out AType: TRttiType): Boolean;
begin
  Result := Assigned(AProp);
  if Result then
    AType := AProp.PropertyType;
end;

class function TPlRTTIUtils.ExtractNode(ARoot: TObject;
  out AMember: TRTTIDataMember; out AIndexedProp: TRttiIndexedProperty;
  const ANodeName: string): Boolean;
begin
  AMember := FContext.GetType(ARoot.ClassType).GetField(ANodeName);
  if not Assigned(AMember) then
    begin
      AMember := FContext.GetType(ARoot.ClassType).GetProperty(ANodeName);
      if not Assigned(AMember) then
        begin
          {TODO -oPMo -cFeatures : write this error to a log file}
          Log(StrCantFind + ARoot.ClassName + '.' + ANodeName);
          raise EPlBindApiException.Create
            (Format('%s %s. %s', [StrCantFind, ARoot.ClassName, ANodeName]));
        end;
    end;
  Result := Assigned(AMember);
end;

class function TPlRTTIUtils.ExtractNode(ARoot: TObject; out AField: TRTTIField;
  out AProp: TRttiProperty; out AnIndexedProperty: TRttiIndexedProperty;
  const ANodeName: string): Boolean;
begin
  Result := True;

  if not(ExtractField(ARoot, AField, ANodeName) or ExtractProperty(ARoot, AProp,
    ANodeName) or ExtractIndexedProperty(ARoot, AnIndexedProperty, ANodeName))
  then
    begin
      Log(StrCantFind + ARoot.ClassName + '.' + ANodeName);
      raise EPlBindApiException.CreateFmt('%s %s. %s',
        [StrCantFind, ARoot.ClassName, ANodeName]);
    end;
end;

class function TPlRTTIUtils.ExtractNodeType(var AField: TRTTIField;
  var AProp: TRttiProperty; const APath: string): TRttiType;
begin
  if Assigned(AField) then
    begin
      AProp := nil;
      Exit(AField.FieldType);
    end
  else if Assigned(AProp) then
    begin
      AField := nil;
      Exit(AProp.PropertyType);
    end;
  Log(APath + StrIsNotAPathToProperty);
  raise EPlBindApiException.Create(APath + StrIsNotAPathToProperty);
end;

class function TPlRTTIUtils.ExtractNodeType(AField: TRTTIField;
  AProp: TRttiProperty; AIndexedProp: TRttiIndexedProperty): TRttiType;
var
  typeFound: Boolean;
begin
  Result := nil;
  typeFound := ExtractFieldType(AField, Result) or
    ExtractPropertyType(AProp, Result) or ExtractIndexedPropertyType
    (AIndexedProp, Result);
  if not typeFound then
    raise EPlBindApiException.Create(StrNoMemberAvailable);
end;

class function TPlRTTIUtils.ExtractProperty(ARoot: TObject;
  out AProp: TRttiProperty; const ANodeName: string): Boolean;
begin
  AProp := FContext.GetType(ARoot.ClassType).GetProperty(ANodeName);
  Result := Assigned(AProp);
end;

class function TPlRTTIUtils.ExtractPropertyType(AProp: TRttiProperty;
  out AType: TRttiType): Boolean;
begin
  Result := Assigned(AProp);
  if Result then
    AType := AProp.PropertyType;
end;

class function TPlRTTIUtils.FirstNode(var pathNodes: string): string;
var
  dotPosition: Integer;
begin
  dotPosition := pathNodes.IndexOf('.');
  if (dotPosition = -1) or (pathNodes = '') then
    begin
      Result := pathNodes;
      pathNodes := '';
    end
  else
    begin
      Result := pathNodes.Substring(0, dotPosition);
      pathNodes := pathNodes.Substring(dotPosition + 1);
    end;
end;

class function TPlRTTIUtils.GetIndexedPropertyInfo(ARoot: TObject;
  const APropertyName: string): TPlIndexedPropertyInfo;
var
  myIndexedProp: TRttiIndexedProperty;
  myPropIndex: string;
  myPropName: string;
  splitPoint: Integer;
begin
  splitPoint := APropertyName.IndexOf('[');
  myPropName := APropertyName.Substring(0, splitPoint);
  myPropIndex := APropertyName.Substring(splitPoint + 1,
    APropertyName.Length - 1);
  myIndexedProp := FContext.GetType(ARoot.ClassType)
    .GetIndexedProperty(myPropName);
  Result := GetIndexedPropertyInfo(myIndexedProp, myPropIndex);
end;

class function TPlRTTIUtils.GetIndexedPropertyInfo(AIndexedProp
  : TRttiIndexedProperty; const AIndex: string): TPlIndexedPropertyInfo;
var
  i: Integer;
  method: TRttiMethod;
  newParam: TValue;
  params: TArray<string>;
  rttiParams: TArray<TRttiParameter>;
begin
  if Assigned(AIndexedProp) and (AIndex <> '') then
    begin
      params := AIndex.Split([',']);
      method := AIndexedProp.ReadMethod;
      if Assigned(method) then
        begin
          rttiParams := method.GetParameters;
          if Length(rttiParams) <> Length(params) then
            raise EPlBindApiException.Create(SWrongParamsNumber);
          for i := 0 to High(rttiParams) do
            begin
              SetLength(Result.paramsTypes, Length(Result.paramsTypes) + 1);
              SetLength(Result.paramsValues, Length(Result.paramsValues) + 1);
              Result.paramsTypes[High(Result.paramsTypes)] :=
                rttiParams[i].ParamType.TypeKind;
              newParam := TValue.From<string>(params[i]);
              if (rttiParams[i].ParamType is TRttiEnumerationType) then
                begin

                end;
              Result.paramsValues[High(Result.paramsValues)] :=
                InternalCastTo(rttiParams[i].ParamType, newParam);
            end;
        end;
    end;
end;

{RENAMED to GetPropertyOwner}
class function TPlRTTIUtils.GetLastNodeInPath(ARoot: TObject; var APath: string;
  out AField: TRTTIField; out AProp: TRttiProperty;
  out AIndexedProperty: TRttiIndexedProperty): TValue;
begin
  {Deprecated - use GetPropertyOwner instead}
  Result := GetPropertyOwner(ARoot, APath, AField, AProp, AIndexedProperty);
end;

class function TPlRTTIUtils.GetPathValue(ARoot: TObject;
  var APath: string): TValue;
var
  currentNode: TObject;
  lastNode: TValue;
  myField: TRTTIField;
  myPath: string;
  myProp: TRttiProperty;
  myIndexedProperty: TRttiIndexedProperty;
  paramsPosition: Integer;
begin
  if APath = '' then
    Exit(ARoot);
  {TODO Memo interno: fare una prova con un elemento indexed (es strings[0]) per capire sul campo il comportamento del sistema}
  myPath := APath;
  currentNode := ARoot;
  lastNode := GetPropertyOwner(currentNode, myPath, myField, myProp,
    myIndexedProperty);
  if lastNode.IsObject then
    begin
      currentNode := lastNode.AsObject;
      paramsPosition := myPath.LastIndexOf('[');
      try
        Result := ReadMemberValue(currentNode, myField, myProp,
          myIndexedProperty, myPath.Substring(paramsPosition + 1,
          myPath.LastIndexOf(']') - paramsPosition - 1));
      except
        //sul superamento degli indici restituire un valore vuoto:
        //il bind potrebbe avvenire quando l'oggetto target non è ancora popolato
        Result := TValue.Empty;
      end;
    end
  else
    begin
      Result := GetRecordPathValue(currentNode, myPath);
      Exit;
    end;
end;

{Returns the instance of the (last - 1) object in the path}
{We assume that the very last node of the path is the property to be read}
{so this functions returns the object or record to which the property belongs.}
{Use this function to}
{verify if the path is correct}
{or}
{get the last node value}
class function TPlRTTIUtils.GetPropertyOwner(ARoot: TObject; var APath: string;
  out AField: TRTTIField; out AProp: TRttiProperty;
  out AIndexedProperty: TRttiIndexedProperty): TValue;
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
      if (not Assigned(currentNode)) or
        (not ExtractNode(currentNode, AField, AProp, AIndexedProperty, nodeName))
      then
        Exit(nil);

      nodeType := ExtractNodeType(AField, AProp, AIndexedProperty);
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
            NextNode(nodeName, currentNode, AField, AProp,
              AIndexedProperty, myPath);
        end;
    except
      {TODO 1 -oPMo -cRefactoring : Consider to raise an exception instead of return nil.}
      Exit(nil);
    end;
  {3. Eventually read the member value}
  Result := currentNode;
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
  {TODO 1 -oPMo -cRefactoring : Manage properties of complex/advanced records}
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
      raise EPlBindApiException.CreateFmt('%s %s: %s.',
        [StrErrorOnSetting, APath, e.Message]);
  end;
end;

class function TPlRTTIUtils.InternalCastTo(const AType: TRttiType;
  AValue: TValue): TValue;
begin
  (*InternalBug#12: tkEnumeration type requires a specific cast*)
  if (AType.TypeKind = tkEnumeration) then
    begin
      if AValue.IsOrdinal then
        Result := OrdinalToEnumeration(AType, AValue)
      else if (AValue.Kind in [tkString, tkLString, tkWString, tkWChar,
        tkUString]) then
        Result := StringToEnumeration(AType, AValue)
      else
        Result := InternalCastTo(AType.TypeKind, AValue);
    end
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

{from https://stackoverflow.com/questions/10083448/
 trttimethod-invoke-function-doesnt-work-in-overloaded-methods}
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
    raise EPlBindApiException.CreateFmt(StrMethodSNotFound, [AMethodName]);
end;

class function TPlRTTIUtils.IsEqualPointer(Left, Right: TValue): Boolean;
var
  pLeft: Pointer;
  pRight: Pointer;
begin
  pLeft := nil;
  pRight := nil;
  Left.ExtractRawDataNoCopy(pLeft);
  Right.ExtractRawDataNoCopy(pRight);
  Result := (pLeft = pRight);
end;

class function TPlRTTIUtils.IsIndexedProperty(const AName: string): Boolean;
begin
  Result := AName.IndexOf('[') > -1;
end;

class function TPlRTTIUtils.IsIndexedProperty(ARoot: TObject;
  const AName: string): Boolean;
begin
  Result := IsIndexedProperty(AName) or
    Assigned(FContext.GetType(ARoot.ClassType).GetIndexedProperty(AName));
end;

class function TPlRTTIUtils.IsValidPath(ARoot: TObject;
  const APath: string): Boolean;
var
  lastNode: TValue;
  myField: TRTTIField;
  myIndexedProperty: TRttiIndexedProperty;
  myPath: string;
  myProp: TRttiProperty;
begin
  myPath := APath;
  myField := nil;
  myProp := nil;
  myIndexedProperty := nil;
  lastNode := GetPropertyOwner(ARoot, myPath, myField, myProp,
    myIndexedProperty);
  Result := (not lastNode.IsEmpty) and (Assigned(myField) or Assigned(myProp) or
    Assigned(myIndexedProperty));
end;

class procedure TPlRTTIUtils.Log(const AMessage: string);
var
  fileName: string;
begin
  {Getting the filename for the logfile
   In this case should be the Filename 'application-exename.log'?}
  fileName := TPath.GetPublicPath + TPath.DirectorySeparatorChar +
    SMorandottiIt + TPath.DirectorySeparatorChar + SBindApi +
    TPath.DirectorySeparatorChar + SErrorsLog;

  if not DirectoryExists(ExtractFilePath(fileName)) then
    ForceDirectories(ExtractFilePath(fileName));

  TFile.AppendAllText(fileName, AMessage);
end;

class function TPlRTTIUtils.MethodIsImplemented(ATypeInfo: Pointer;
  AMethodName: string): Boolean;
var
  m: TRttiMethod;
begin
  {from https://stackoverflow.com/questions/8305008/
   how-i-can-determine-if-an-abstract-method-is-implemented}
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
  {from https://stackoverflow.com/questions/8305008/
   how-i-can-determine-if-an-abstract-method-is-implemented}
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
  var AIndexedProp: TRttiIndexedProperty; var APath: string): TValue;
var
  memberType: TRttiType;
begin
  (*TODO: manage AIndexProp*)
  memberType := ExtractNodeType(AField, AProp, AIndexedProp);
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
      (*TODO: manage AIndexProp*)
    end;
end;

class function TPlRTTIUtils.OrdinalToEnumeration(const AType: TRttiType;
  AValue: TValue): TValue;
begin
  (*Bug#12: To be implemented*)
  Result := TValue.FromOrdinal(AType.Handle, AValue.AsInteger);
end;

class function TPlRTTIUtils.PropertyExists(ATypeInfo: Pointer;
  APropertyName: string): Boolean;
var
  rType: TRttiType;
begin
  Result := False;
  rType := FContext.GetType(ATypeInfo);
  if rType <> nil then
    begin
      Result := rType.GetProperty(APropertyName) <> nil;
      if not Result then
        Result := rType.GetIndexedProperty(APropertyName) <> nil;
    end;
end;

class function TPlRTTIUtils.PropertyExists(const AClass: TClass;
  APropertyName: string): Boolean;
begin
  Result := PropertyExists(AClass.ClassInfo, APropertyName);
end;

class function TPlRTTIUtils.ReadFieldValue(ARoot: TObject; AField: TRTTIField;
  out AValue: TValue): Boolean;
begin
  Result := Assigned(AField);
  if Result then
    case AField.FieldType.TypeKind of
      tkClass:
        AValue := AField.GetValue(ARoot).AsObject
    else
      AValue := AField.GetValue(ARoot);
    end
end;

class function TPlRTTIUtils.ReadIndexedPropertyValue(ARoot: TObject;
  AProp: TRttiIndexedProperty; const AnIndex: string;
  out AValue: TValue): Boolean;
var
  indexedPropertyInfo: TPlIndexedPropertyInfo;
  propertyInfo: PPropInfo;
begin
  Result := Assigned(AProp);
  if Result then
    begin
      indexedPropertyInfo := GetIndexedPropertyInfo(AProp, AnIndex);
      AValue := AProp.GetValue(ARoot, indexedPropertyInfo.paramsValues);
    end;
end;

class function TPlRTTIUtils.ReadMemberValue(ARoot: TObject; AField: TRTTIField;
  AProp: TRttiProperty; AIndexedProp: TRttiIndexedProperty;
  const AIndex: string): TValue;
var
  propertyInfo: PPropInfo;
begin
  {TODO: manage method}
  Result := TValue.Empty;
  if not(ReadFieldValue(ARoot, AField, Result) or ReadPropertyValue(ARoot,
    AProp, Result) or ReadIndexedPropertyValue(ARoot, AIndexedProp, AIndex,
    Result)) then
    raise EPlBindApiException.Create(SInvalidFieldOrProperty);
end;

class function TPlRTTIUtils.ReadPropertyValue(ARoot: TObject;
  AProp: TRttiProperty; out AValue: TValue): Boolean;
var
  propertyInfo: PPropInfo;
begin
  Result := Assigned(AProp);
  if Result then
    case AProp.PropertyType.TypeKind of
      tkClass:
        begin
          propertyInfo := (AProp as TRttiInstanceProperty).PropInfo;
          AValue := GetObjectProp(ARoot, propertyInfo);
        end
    else
      AValue := AProp.GetValue(ARoot);
    end;
end;

class function TPlRTTIUtils.SameSignature(const AParams: TArray<TRttiParameter>;
  const Args: array of TValue): Boolean;
var
  rIndex: Integer;
begin
  Result := False;
  if Length(Args) = Length(AParams) then
    begin
      Result := True;
      for rIndex := 0 to Length(AParams) - 1 do
        if not(((AParams[rIndex].ParamType.TypeKind = tkClass) and
          (Args[rIndex].TypeInfo = nil)) or
          (AParams[rIndex].ParamType.Handle = Args[rIndex].TypeInfo) or
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
      recMethod.Data := Pointer(ATarget); //(Self);
      SetMethodProp(sourceObject, methodPath, recMethod);
      Result := True;
    end;

end;

class procedure TPlRTTIUtils.SetPathValue(ARoot: TObject; const APath: string;
  AValue: TValue);
var
  currentNode: TObject;
  myField: TRTTIField;
  myIndexedProperty: TRttiIndexedProperty;
  myPath: string;
  myProp: TRttiProperty;
  nodeName: string;
  nodeType: TRttiType;
begin
  currentNode := ARoot;
  myField := nil;
  myIndexedProperty := nil;
  myProp := nil;
  myPath := APath;

  while myPath <> '' do
    begin
      nodeName := FirstNode(myPath);
      {First node, both prop or field}
      ExtractNode(currentNode, myField, myProp, myIndexedProperty, nodeName);
      nodeType := ExtractNodeType(myField, myProp, myIndexedProperty);
      {2a. if there are more nodes...}
      if myPath <> '' then
        begin
          if nodeType.IsRecord then
            begin
              myPath := nodeName + IfThen(myPath <> '', '.' + myPath, '');
              SetRecordPathValue(currentNode, myPath, AValue);
              Exit;
            end
          else
            {2b. if there are more Nodes manages them}
            NextNode(nodeName, currentNode, myField, myProp,
              myIndexedProperty, myPath);
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
      raise EPlBindApiException.CreateFmt('%s %s: %s.',
        [StrErrorOnSetting, APath, e.Message]);
  end;

end;

class function TPlRTTIUtils.StringToEnumeration(const AType: TRttiType;
  AValue: TValue): TValue;
var
  intValue: Integer;
begin
  intValue := GetEnumValue(AType.Handle, AValue.AsString);
  Result := OrdinalToEnumeration(AType, intValue);
end;

class procedure TPlRTTIUtils.WriteFieldValue(ANode: TObject; AField: TRTTIField;
  AValue: TValue);
begin
  if (AField.FieldType.TypeKind <> AValue.Kind) then
    AValue := InternalCastTo(AField.FieldType, AValue);
  case AField.FieldType.TypeKind of
    tkClass:
      AField.SetValue(ANode, TObject(AValue.AsObject))
  else
    AField.SetValue(ANode, AValue);
  end;
end;

class procedure TPlRTTIUtils.WriteMemberValue(ANode: TObject;
  AField: TRTTIField; AProp: TRttiProperty; const APath: string;
  AValue: TValue);
begin
  if Assigned(AField) then
    WriteFieldValue(ANode, AField, AValue)
  else if Assigned(AProp) then
    WritePropertyValue(ANode, AProp, AValue)
  else
    raise EPlBindApiException.Create(APath + StrIsNotAPathToProperty);
end;

class procedure TPlRTTIUtils.WritePropertyValue(ANode: TObject;
  AProp: TRttiProperty; AValue: TValue);
var
  propertyInfo: PPropInfo;
  propTypeKind: TTypeKind;
begin
  propTypeKind := AProp.PropertyType.TypeKind;
  if (propTypeKind <> AValue.Kind) then
    AValue := InternalCastTo(AProp.PropertyType, AValue);
  case propTypeKind of
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
