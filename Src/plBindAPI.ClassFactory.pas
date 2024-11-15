{*****************************************************************************}
{                                                                             }
{Copyright (C) 2020-2024 Paolo Morandotti                                     }
{Unit plBindAPI.ClassFactory                                                  }
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
  /// <summary>
  /// Represents the metadata for a registered class, including binding and creation parameters.
  /// </summary>
  TPlClassData = record
  strict private
    /// <summary>
    /// Indicates whether the class is set for automatic binding.
    /// </summary>
    FAutoBind: Boolean;

    /// <summary>
    /// Stores the parameters required to create an instance of the class.
    /// </summary>
    FCreateParams: TPlCreateParams;

    /// <summary>
    /// Holds the reference to the registered class type.
    /// </summary>
    FRegisteredClass: TClass;

  public
    /// <summary>
    /// Indicates if the class is automatically bound to data sources.
    /// </summary>
    property AutoBind: Boolean read FAutoBind;

    /// <summary>
    /// Provides the registered class type.
    /// </summary>
    property RegisteredClass: TClass read FRegisteredClass;

    /// <summary>
    /// Returns the parameters used to create an instance of the registered class.
    /// </summary>
    property CreateParams: TPlCreateParams read FCreateParams;

    /// <summary>
    /// Initializes a new instance of the <c>TPlClassData</c> record.
    /// </summary>
    /// <param name="AClass">The class type to be registered.</param>
    /// <param name="AParamsSet">The creation parameters for the class.</param>
    /// <param name="AAutoBind">Specifies whether the class should be automatically bound. Default is <c>False</c>.</param>
    constructor Create(AClass: TClass; const AParamsSet: TPlCreateParams;
      AAutoBind: Boolean = False);
  end;

  TPlClassList = class(TDictionary<string, TPlClassData>);
  TPlInstanceList = class(TObjectDictionary<string, TObject>);

type
  /// <summary>
  /// Manages a set of classes for binding, including their registration,
  /// instantiation, and lifecycle.
  /// </summary>
  TPlClassManager = class
  private
    /// <summary>
    /// List of registered classes and their associated metadata.
    /// </summary>
    class var FClassList: TPlClassList;

    /// <summary>
    /// List of instantiated objects managed by the class manager.
    /// </summary>
    class var FInstanceList: TPlInstanceList;

    /// <summary>
    /// Creates and returns a new instance of a registered class using its metadata.
    /// </summary>
    /// <param name="AClassData">Metadata containing information about the class to instantiate.</param>
    /// <returns>A new instance of the specified class.</returns>
    class function CreateInstance(AClassData: TPlClassData): TObject;

    /// <summary>
    /// Creates and returns a new instance of a class based on its name.
    /// </summary>
    /// <param name="AClassName">The name of the class to instantiate.</param>
    /// <returns>A new instance of the specified class.</returns>
    class function GetNewInstance(const AClassName: string): TObject;

    /// <summary>
    /// Retrieves the singleton instance of a class by its class' name.
    /// </summary>
    /// <param name="AClassName">The name of the class for which to retrieve the singleton instance.</param>
    /// <returns>The singleton instance of the specified class.</returns>
    class function GetSingletonInstance(const AClassName: string): TObject;

  protected
    /// <summary>
    /// Initializes the <c>TPlClassManager</c> class.
    /// </summary>
    class constructor Create;

    /// <summary>
    /// Finalizes the <c>TPlClassManager</c> class and releases resources.
    /// </summary>
    class destructor Destroy;

    /// <summary>
    /// Adds a class to the binding list with the specified key and options.
    /// </summary>
    /// <param name="AKey">The unique key for the class in the binding list.</param>
    /// <param name="AClassData">Metadata for the class to be added.</param>
    /// <param name="AnOptionsSet">Set of options defining the binding behavior.</param>
    class procedure AddClassToBindingList(AKey: string;
      AClassData: TPlClassData; AnOptionsSet: TPlBindOptionsSet);

    /// <summary>
    /// Adds a class to the deferred instantiation list.
    /// </summary>
    /// <param name="AClass">The class type to defer instantiation for.</param>
    /// <param name="AClassData">Metadata for the deferred class.</param>
    class procedure AddClassToDeferredList(AClass: TClass;
      AClassData: TPlClassData); virtual;

  public
    /// <summary>
    /// Remove all registered classes and instances.
    /// </summary>
    class procedure Clear;

    /// <summary>
    /// Retrieves an instance of a class by its name. Returns either a singleton or a new instance based on the registration.
    /// </summary>
    /// <param name="AClassName">The name of the class to retrieve.</param>
    /// <returns>An instance of the specified class.</returns>
    class function GetInstance(const AClassName: string): TObject;

    /// <summary>
    /// Returns the list of currently managed instances.
    /// </summary>
    /// <returns>A list of managed instances. At present, this function is
    /// used for monitoring purposes, but could be removed in future.</returns>
    class function Instances: TPlInstanceList;

    /// <summary>
    /// Checks if a class with the specified name is registered.
    /// </summary>
    /// <param name="AClassName">The name of the class to check.</param>
    /// <returns><c>True</c> if the class is registered; otherwise, <c>False</c>.</returns>
    class function IsRegistered(const AClassName: string): Boolean;

    /// <summary>
    /// Determines if a class is registered as a singleton by its name.
    /// </summary>
    /// <param name="AClassName">The name of the class to check.</param>
    /// <returns><c>True</c> if the class is a singleton; otherwise, <c>False</c>.</returns>
    class function IsSingleton(const AClassName: string): Boolean; overload;

    /// <summary>
    /// Determines if an instance is a singleton.
    /// </summary>
    /// <param name="AnInstance">The instance to check.</param>
    /// <returns><c>True</c> if the instance is a singleton; otherwise, <c>False</c>.</returns>
    class function IsSingleton(const AnInstance: TObject): Boolean; overload;

    /// <summary>
    /// Registers a class with options to determine its singleton and deferred status.
    /// </summary>
    /// <param name="AClass">The class to register.</param>
    /// <param name="AsSingleton">Specifies if the class should be a singleton.</param>
    /// <param name="AsDeferred">Specifies if instantiation should be deferred. Default is <c>False</c>.</param>
    [deprecated('Use the RegisterClass method with TPlBindOptionsSet instead.')]
    class procedure RegisterClass(AClass: TClass; AsSingleton: Boolean;
      AsDeferred: Boolean = False); overload;

    /// <summary>
    /// Registers a class with specified binding options.
    /// </summary>
    /// <param name="AClass">The class to register.</param>
    /// <param name="AnOptionsSet">Set of binding options for the class.</param>
    class procedure RegisterClass(AClass: TClass;
      const AnOptionsSet: TPlBindOptionsSet); overload;

    /// <summary>
    /// Registers a class with binding options and creation parameters.
    /// </summary>
    /// <param name="AClass">The class to register.</param>
    /// <param name="AnOptionsSet">Set of binding options for the class.</param>
    /// <param name="AParamsSet">Parameters for creating an instance of the class.</param>
    class procedure RegisterClass(AClass: TClass;
      const AnOptionsSet: TPlBindOptionsSet;
      const AParamsSet: TPlCreateParams); overload;

    /// <summary>
    /// Returns a copy of the list of all registered classes.
    /// </summary>
    /// <returns>A list of registered classes and their metadata. At present,
    /// this function used for monitoring purposes, but could be removed in future.</returns>
    class function RegisteredClasses: TPlClassList;

    /// <summary>
    /// Registers an instance for binding. This method is deprecated.
    /// </summary>
    /// <param name="AnObject">The instance to register.</param>
    [deprecated
      ('Instance registration is handled automatically in newer versions.')]
    class procedure RegisterInstance(AnObject: TObject);

    /// <summary>
    /// Unregisters an instance from binding.
    /// </summary>
    /// <param name="AnObject">The instance to unregister.</param>
    class procedure UnregisterInstance(AnObject: TObject);
  end;

implementation

uses
  plBindAPI.BindManagement,
  plBindAPI.DeferredBinding,
  plBindAPI.RTTIUtils;

resourcestring
  StrNotRegistered = ' not registered.';
  StrMethodCreateNotFound = 'Method ''Create'' not found';

  { TPlClassManager }

class constructor TPlClassManager.Create;
begin
  FClassList := TPlClassList.Create;
  FInstanceList := TPlInstanceList.Create([doOwnsValues]);
end;

class destructor TPlClassManager.Destroy;
begin
  FClassList.Free;
  FInstanceList.Free;
end;

class procedure TPlClassManager.AddClassToBindingList(AKey: string;
  AClassData: TPlClassData; AnOptionsSet: TPlBindOptionsSet);
begin
  FClassList.Add(AKey, AClassData);
  if Singleton in AnOptionsSet then
    FInstanceList.Add(AKey, nil);
end;

class procedure TPlClassManager.AddClassToDeferredList(AClass: TClass;
  AClassData: TPlClassData);
var
  AnObject: TObject;
begin
  AnObject := CreateInstance(AClassData);
  TplDeferredBinding.Add(AnObject);
end;

class procedure TPlClassManager.Clear;
var
  instance: TObject;
begin
  FClassList.Clear;
  for instance in FInstanceList.Values do
    TPlBindManager.Unbind(instance);
  FInstanceList.Clear;
  TplDeferredBinding.Clear;
end;

class function TPlClassManager.CreateInstance(AClassData: TPlClassData)
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
      methodFound := TplRTTIUtils.SameSignature(rParams,
        AClassData.CreateParams);
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
  raise EplBindApiException.Create(StrMethodCreateNotFound);
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
    raise EplBindApiException.Create(AClassName + StrNotRegistered);
end;

class function TPlClassManager.GetNewInstance(const AClassName: string)
  : TObject;
var
  classData: TPlClassData;
begin
  FClassList.TryGetValue(AClassName, classData);
  Result := CreateInstance(classData);
  { DONE 3 -oPMo -cRefactoring : Should the new instance bound automatically?
    like: if classData.AutoBind then TplBindManager.Bind(Result); }
  if classData.AutoBind then
    TplBindManager.Bind(Result);
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

class function TPlClassManager.Instances: TPlInstanceList;
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
  AsSingleton: Boolean; AsDeferred: Boolean = False);
var
  options: TPlBindOptionsSet;
begin
  if AsSingleton then
    options := [Singleton];
  if AsDeferred then
    options := options + [Deferred];
  RegisterClass(AClass, options, []);
end;

class procedure TPlClassManager.RegisterClass(AClass: TClass;
  const AnOptionsSet: TPlBindOptionsSet);
begin
  RegisterClass(AClass, AnOptionsSet, []);
end;

class procedure TPlClassManager.RegisterClass(AClass: TClass;
  const AnOptionsSet: TPlBindOptionsSet; const AParamsSet: TPlCreateParams);
var
  classData: TPlClassData;
  key: string;
begin
  key := AClass.ClassName;
  if FClassList.ContainsKey(key) then
    raise EplBindApiException.CreateFmt('%s is already registered.', [key]);

  classData.Create(AClass, AParamsSet, (AutoBind in AnOptionsSet));
  AddClassToBindingList(key, classData, AnOptionsSet);
  if Deferred in AnOptionsSet then
    AddClassToDeferredList(AClass, classData);
  TplDeferredBinding.ProcessDeferred;
end;

class function TPlClassManager.RegisteredClasses: TPlClassList;
begin
  Result := TPlClassList.Create(FClassList);
end;

class procedure TPlClassManager.RegisterInstance(AnObject: TObject);
var
  key: string;
begin
  key := AnObject.ClassName;
  if not FInstanceList.ContainsKey(key) then
    FInstanceList.Add(key, AnObject);
end;

class procedure TPlClassManager.UnregisterInstance(AnObject: TObject);
var
  key: string;
begin
  key := AnObject.ClassName;
  if FInstanceList.ContainsKey(key) then
    begin
      // This step frees the instance
      { TODO 5 -oPMo -cDebugging : Should we unbind the instance? }
      FInstanceList.Remove(key);
    end;
end;

{$REGION 'TPlClassData'}

constructor TPlClassData.Create(AClass: TClass;
  const AParamsSet: TPlCreateParams; AAutoBind: Boolean = False);
var
  i: Integer;
begin
  FRegisteredClass := AClass;
  FAutoBind := AAutoBind;
  setLength(FCreateParams, Length(AParamsSet));
  for i := Low(AParamsSet) to High(AParamsSet) do
    FCreateParams[i] := AParamsSet[i];
end;

{$ENDREGION}

end.
