{*****************************************************************************}
{       BindAPI                                                               }
{       Copyright (C) 2020 Paolo Morandotti                                   }
{       Unit plBindAPI.Attributes                                             }
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

unit plBindAPI.ClassFactory;

interface

uses
  SysUtils, Classes, Generics.Collections, RTTI,
  plBindAPI.Types;

type
  { This record stores the class information }
  TPlClassData = record
  strict private
    FRegisteredClass: TClass;
    FCreateParams: TPlCreateParams;
  public
    property RegisteredClass: TClass read FRegisteredClass;
    property CreateParams: TPlCreateParams read FCreateParams;
    constructor Create(AClass: TClass; const AParamsSet: TPlCreateParams);
  end;

  (* Was: TplClassList = class(TDictionary<string, TClass>); *)
  TPlClassList = class(TDictionary<string, TplClassData>);
  TPlInstanceList = class(TObjectDictionary<string, TObject>);

  TPlClassManager = class
  private
    class var FClassList: TPlClassList;
    class var FInstanceList: TPlInstanceList;
    class function CreateInstance(AClassData: TPlClassData): TObject;
    class function GetNewInstance(const AClassName: string): TObject;
    class function GetSingletonInstance(const AClassName: string): TObject;
  protected
    class constructor Create;
    class destructor Destroy;
    class procedure AddClassToBindingList(key: string; AClassData: TPlClassData;
      AnOptionsSet: TPlBindOptionsSet);
    class procedure AddClassToDeferredList(AClass: TClass); virtual;
  public
    { Public declarations }
    class function GetInstance(const AClassName: string): TObject;
    class function Instances: TplInstanceList;
    class function IsRegistered(const AClassName: string): Boolean;
    class function IsSingleton(const AClassName: string): Boolean; overload;
    class function IsSingleton(const AnInstance: TObject): Boolean; overload;
    class procedure RegisterClass(AClass: TClass; AsSingleton: Boolean;
      AsDeferred: Boolean = false); overload; deprecated;
    class procedure RegisterClass(AClass: TClass;
      const AnOptionsSet: TPlBindOptionsSet); overload;
    class procedure RegisterClass(AClass: TClass; const AnOptionsSet:
        tplBindOptionsSet; const AParamsSet: TPlCreateParams); overload;
    class function RegisteredClasses: TPlClassList;
    class procedure RegisterInstance(AnObject: TObject); deprecated;
    class procedure UnregisterInstance(AnObject: TObject);
  end;

implementation

uses
  plBindAPI.BindManagement,
  plBindAPI.DeferredBinding, plBindAPI.RTTIUtils;

{ TPlClassManager }

class constructor TPlClassManager.Create;
begin
  FClassList := TplClassList.Create;
  FInstanceList := TplInstanceList.Create([doOwnsValues]);
end;

class destructor TPlClassManager.Destroy;
begin
  FClassList.Free;
  FInstanceList.Free;
end;

class procedure TPlClassManager.AddClassToBindingList(key: string;
  AClassData: TplClassData; AnOptionsSet: tplBindOptionsSet);
begin
  FClassList.Add(key, AClassData);
  if boSingleton in AnOptionsSet then
    FInstanceList.Add(key, nil);
end;

class procedure TPlClassManager.AddClassToDeferredList(AClass: TClass);
begin
{ TODO -oPMo -cRefactoring : Why is this method not yet implemented? }
  // TplDeferredBinding.Add(AClass);
end;

class function TPlClassManager.CreateInstance(AClassData: TplClassData)
  : TObject;
var
  methodFound: Boolean;
  rMethod: TRttiMethod;
  rParams: TArray<TRttiParameter>;
  rType: TRttiType;
  rValue: TValue;
begin
  rValue := nil;
  rType := TplRTTIUtils.Context.GetType(AClassData.RegisteredClass);
  for rMethod in rType.GetMethods('Create') do
    begin
      rParams := rMethod.GetParameters;
      methodFound := TPlRTTIUtils.SameSignature(rParams, AClassData.CreateParams);
      if methodFound then
        begin
          rValue := rMethod.Invoke(rType.AsInstance.MetaclassType,
            AClassData.CreateParams);
          Result := rValue.AsObject;
          { GetMethods return methods from the class and its ancestors.
            The first one is from the class you passed as parameter.
            If you do not exit here, the create method of
            any ancestors could be called and the rValue class could be wrong }
          Exit;
        end;
    end;
  raise EplBindApiException.Create('Method ''Create'' not found');
end;

class function TPlClassManager.GetInstance(const AClassName: string): TObject;
begin
  if FClassList.ContainsKey(AClassName) then
    begin
      if FInstanceList.ContainsKey(AClassName) then
        Result := GetSingletonInstance(AClassName)
      else
        Result := GetNewInstance(AClassName);
    end
  else
    raise EplBindApiException.Create(AClassName + ' not registered.');
end;

class function TPlClassManager.GetNewInstance(const AClassName: string)
  : TObject;
var
  classData: TplClassData;
begin
  FClassList.TryGetValue(AClassName, classData);
  Result := CreateInstance(classData);
// HP:  TplBindManager.Bind(Result);
end;

class function TPlClassManager.GetSingletonInstance(const AClassName
  : string): TObject;
begin
  begin
    FInstanceList.TryGetValue(AClassName, Result);
    if not Assigned(Result) then
      begin
        Result := GetNewInstance(AClassName);
        FInstanceList.AddOrSetValue(AClassName, Result);
      end;
  end;
end;

class function TPlClassManager.Instances: TplInstanceList;
begin
  Result := FInstanceList;
end;

class function TPlClassManager.IsRegistered(const AClassName: string): Boolean;
begin
  Result := FClassList.ContainsKey(AClassName);
end;

class function TPlClassManager.IsSingleton(const AClassName: string): Boolean;
begin
  Result := FInstanceList.ContainsKey(AClassName);
end;

class function TPlClassManager.IsSingleton(const AnInstance: TObject): Boolean;
begin
  Result := IsSingleton(AnInstance.ClassName);
end;

class procedure TPlClassManager.RegisterClass(AClass: TClass;
  AsSingleton: Boolean; AsDeferred: Boolean = false);
var
  options: tplBindOptionsSet;
begin
  if AsSingleton then
    options := [boSingleton];
  if AsDeferred then
    options := options + [boDeferred];
  RegisterClass(AClass, options, []);
end;

class procedure TPlClassManager.RegisterClass(AClass: TClass;
  const AnOptionsSet: tplBindOptionsSet);
begin
  RegisterClass(AClass, AnOptionsSet, []);
end;

class procedure TPlClassManager.RegisterClass(AClass: TClass;
  const AnOptionsSet: tplBindOptionsSet; const AParamsSet: TPlCreateParams);
var
  classData: TPlClassData;
  key: string;
begin
  classData.Create(AClass, AParamsSet);
  key := AClass.ClassName;
  if not FClassList.ContainsKey(key) then
    AddClassToBindingList(key, classData, AnOptionsSet);
  // CreateInstance(AClass));
  if boDeferred in AnOptionsSet then
    AddClassToDeferredList(AClass);
  TPlDeferredBinding.TestDeferred;
end;

class function TPlClassManager.RegisteredClasses: TplClassList;
begin
  Result := FClassList;
end;

class procedure TPlClassManager.RegisterInstance(AnObject: TObject);
var
  key: string;
begin
  key := AnObject.ClassName;
  if not FInstanceList.ContainsKey(key) then
    FInstanceList.Add(key, AnObject); // CreateInstance(AClass));
end;

class procedure TPlClassManager.UnregisterInstance(AnObject: TObject);
var
  key: string;
begin
  key := AnObject.ClassName;
  if not FInstanceList.ContainsKey(key) then
    begin
      // Free the instance: FInstanceList.Get
      FInstanceList.Remove(key);
    end;
end;

{$REGION 'TPlClassData'}

constructor TPlClassData.Create(AClass: TClass; const AParamsSet:
    TPlCreateParams);
var
  i: Integer;
begin
  FRegisteredClass := AClass;
  setLength(FCreateParams, Length(AParamsSet));
  for i := Low(AParamsSet) to High(AParamsSet) do
    FCreateParams[i] := AParamsSet[i];
end;

{$ENDREGION}

end.
