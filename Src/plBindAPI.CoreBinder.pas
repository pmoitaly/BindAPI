{*****************************************************************************}
{BindAPI                                                                      }
{Copyright (C) 2020-2024 Paolo Morandotti                                     }
{Unit plBindAPI.CoreBinder                                                    }
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
/// <summary>
///   Implementation of TPlBinder.
/// </summary>
/// <remarks>
///  <c>TplBinder</c> is the class that handles all mappings.
/// BindAPI attributes produce elements of this class, but you can also create
///  new links programmatically.
/// It periodically checks the values of the source elements and,
/// if they have changed, propagates them to the bound elements.
/// </remarks>
unit plBindAPI.CoreBinder;

interface

uses
  Rtti, Classes,
  Generics.Defaults, Generics.Collections,
  plBindAPI.Types, plBindAPI.BindingElement;

type

  /// <summary>
  /// TPlBinder is a class that manages data binding between objects.
  /// </summary>
  /// <remarks>
  /// It supports automatic value synchronization between source and target properties or objects.
  /// </remarks>
  TPlBinder = class(TInterfacedObject)
  private
    /// <summary>List of binding error messages.</summary>
    FBindErrorList: TStrings;

    /// <summary>Custom comparer used for key comparison in bindings.</summary>
    FComparer: TPlParKeyComparer;

    /// <summary>Indicates whether the binder is enabled or not.</summary>
    FEnabled: Boolean;

    /// <summary>Specifies the interval (in milliseconds) for automatic updates.</summary>
    FInterval: integer;

{$IFDEF MSWINDOWS}{$WARN SYMBOL_PLATFORM OFF}
    /// <summary>Specifies the thread priority for the internal thread on Windows.</summary>
    FPriority: TThreadPriority;
{$WARN SYMBOL_PLATFORM ON}{$ENDIF}

    /// <summary>Indicates the current status of the binder.</summary>
    /// <remarks>
    /// Allowed values are:
    /// <list type="bullet">
    ///   <listheader><term>Value</term> <description>Description</description></listheader>
    ///   <item><term>bsStopped</term> <description>There no control of data changes.</description></item>
    ///   <item>><term>bsRunning</term> <description>Test for data changes occours every <see cref="Interval" /> milliseconds.</description></item>
    /// </list>
    /// </remarks>
    FStatus: TPlBinderStatus;

    /// <summary>Adds a new binding between a key and a value.</summary>
    procedure AddNewItem(AKey, AValue: TplBindElementData);

    /// <summary>Retrieves a component based on the property path.</summary>
    /// <remarks>
    /// Use this function to speed up the search of the last component in the path.
    /// </remarks>
    /// <param name="ASource">The source component to start from.</param>
    /// <param name="APropertyPath">The property path to resolve.</param>
    /// <returns>The resolved component.</returns>
    function ComponentFromPath(ASource: TComponent; var APropertyPath: string)
      : TComponent;

    /// <summary>Gets a copy of the list of binding errors.</summary>
    function GetBindErrorList: TStrings;

    /// <summary>Internally adds a source-target binding pair.</summary>
    procedure InternalAdd(Source, Target: TplBindElementData);

    /// <summary>Sets the list of binding errors.</summary>
    procedure SetBindErrorList(const Value: TStrings);

    /// <summary>Enables or disables the binder.</summary>
    procedure SetFEnabled(const Value: Boolean);

    /// <summary>Upgrades an existing binding item.</summary>
    procedure UpgradeExistingItem(AKey, AValue: TplBindElementData);
  protected
    /// <summary>List of binding properties currently managed by the binder.</summary>
    FBindPropertyList: TPlBindList;

    /// <summary>Internal thread used for background monitoring.</summary>
    FInternalThread: TThread;

    /// <summary>Indicates whether the internal thread has been terminated.</summary>
    FThreadTerminated: Boolean;

    /// <summary>Closes and frees the internal thread.</summary>
    procedure CloseAndFreeThread; virtual;

    /// <summary>Handles notifications for key-related changes.</summary>
    procedure HandleKeyNotify(Sender: TObject; const Key: TplBindElementData;
      Action: TCollectionNotification);

    /// <summary>Handles notifications for value-related changes.</summary>
    procedure HandleValueNotify(Sender: TObject; const Key: TPlBindElementsList;
      Action: TCollectionNotification);

    /// <summary>Monitors values and updates bindings as necessary.</summary>
    procedure MonitorValues(const ARepeat: Boolean = True); virtual;

    /// <summary>Updates values in the provided binding list with the new value.</summary>
    procedure UpdateListValues(aList: TPlBindElementsList; newValue: TValue);
  public
    /// <summary>Initializes a new instance of the TPlBinder class.</summary>
    constructor Create; overload;

    /// <summary>Frees resources used by the TPlBinder instance.</summary>
    destructor Destroy; override;

    /// <summary>Gets or sets the list of binding errors.</summary>
    property BindErrorList: TStrings read GetBindErrorList write SetBindErrorList;

    /// <summary>Gets or sets whether the binder is enabled.</summary>
    property Enabled: Boolean read FEnabled write SetFEnabled;

    /// <summary>Gets or sets the interval for automatic updates.</summary>
    property Interval: integer read FInterval write FInterval;

{$IFDEF MSWINDOWS}{$WARN SYMBOL_PLATFORM OFF}
    /// <summary>Gets or sets the priority of the internal thread.</summary>
    property Priority: TThreadPriority read FPriority write FPriority;
{$WARN SYMBOL_PLATFORM ON}{$ENDIF}
    /// <summary>Gets the current status of the binder.</summary>
    property Status: TPlBinderStatus read FStatus;

    /// <summary>Adds a line to the BindErrorList property.</summary>
    /// <param name="AError">The exception message.</param>
    procedure AddError(AError: string);

    /// <summary>Binds a source object and property to a target object and property.</summary>
    /// <param name="ASource">The source object.</param>
    /// <param name="APropertySource">The source property name.</param>
    /// <param name="ATarget">The target object.</param>
    /// <param name="APropertyTarget">The target property name.</param>
    /// <param name="AFunction">Optional transformation function.</param>
    /// <returns>True if the binding was successful; otherwise, false.</returns>
    function Bind(ASource: TObject; const APropertySource: string;
      ATarget: TObject; const APropertyTarget: string;
      AFunction: TplBridgeFunction = nil): Boolean;

    /// <summary>Provides information about all current bindings.</summary>
    /// <returns>A COPY of the BindPropertyList, with a list of current bindings. The caller is responsible for freeing it.</returns>
    function BindInfo: TPlBindList;

    /// <summary>Binds a method from a source to a new method on a target object.</summary>
    procedure BindMethod(ASource: TObject; const AMethodPath: string;
      ATarget: TObject; const ANewMethodName: string;
      AFunction: TplBridgeFunction = nil);

    /// <summary>Binds a source object and property to a target object (overloaded).</summary>
    procedure BindObject(ASource: TObject; const APropertySource: string;
      ATarget: TObject); overload;

    /// <summary>Binds a source object and property to a target object and path (overloaded).</summary>
    procedure BindObject(ASource: TObject; const APropertySource: string;
      ATarget: TObject; ATargetPath: string); overload;

    /// <summary>Clears all current bindings.</summary>
    procedure Clear;

    /// <summary>Gets the count of registered binding sources.</summary>
    function Count: integer;

    /// <summary>Provides debug information about the current state of the binder.</summary>
    function DebugInfo: TplBindDebugInfo;

    /// <summary>Deprecated. Use <see cref="UnbindSource" />.</summary>
    procedure DetachAsSource(ASource: TObject);
      deprecated 'Will be removed in 0.9 version - Use UnbindSource';

    /// <summary>Deprecated. Use <see cref="UnbindTarget" />.</summary>
    procedure DetachAsTarget(ATarget: TObject); overload;
      deprecated 'Will be removed in 0.9 version - Use UnbindTarget';

    /// <summary>Deprecated. Use <see cref="UnbindTarget" />.</summary>
    procedure DetachAsTarget(ATarget: TObject; ASource: TObject); overload;
      deprecated 'Will be removed in 0.9 version - Use UnbindTarget';

    /// <summary>
    /// Normalizes the property path for a given source object.
    /// </summary>
    /// <remarks>
    /// <para>This method ensures that the property path is valid and converts it into
    /// a form suitable for data binding.</para>
    /// <para>Given an input in the form Object, QualifiedName of a property, this
    ///  method searches for the last component in the QN to reduce the
    ///  SourcePath parameter to is shorter dimension.</para>
    /// <para>For instance, assume the Source is a <c>TPageControl</c> class and the
    /// SourcePath is like <i>ATab.APanel.AMemo.Text</i>, the result will be
    /// the instance of the AMemo component and SourcePath will be reduced
    /// to <i>Text</i>.</para>
    /// </remarks>
    /// <param name="ASource">The source object whose property path is to be normalized.</param>
    /// <param name="SourcePath">The property path to normalize.</param>
    /// <returns>The resolved object associated with the normalized path.</returns>
    function NormalizePath(ASource: TObject; var SourcePath: string): TObject;

    /// <summary>Starts the binder with a specified sleep interval.</summary>
    procedure Start(const ASleepInterval: integer);

    /// <summary>Stops the binder.</summary>
    procedure Stop;

    /// <summary>Unbinds a specific source object from all targets.</summary>
    function UnbindSource(ASource: TObject): Boolean;

    /// <summary>Unbinds a specific target object from all sources (overloaded).</summary>
    function UnbindTarget(ATarget: TObject): Boolean; overload;

    /// <summary>Unbinds a specific target object from a specific source object (overloaded).</summary>
    function UnbindTarget(ATarget: TObject; ASource: TObject): Boolean;
      overload;

    /// <summary>Updates values for all active bindings.</summary>
    procedure UpdateValues;
  end;

implementation

uses
  TypInfo, Hash, SysUtils, Math, StrUtils,
  plBindAPI.RTTIUtils;

resourcestring
  SErrorInsertingABinding = 'Error inserting a binding: ';
  SOnUpgradingBindIsDisabled = '%s on upgrading %s. Bind is disabled.';
  SRemovingFromBindPropertyList = '%s : %s removing %s from BindPropertyList.';

const
  DEFAULT_INTERVAL = 100;

  {TPlBinder}

procedure TPlBinder.AddNewItem(AKey, AValue: TplBindElementData);
var
  newList: TPlBindElementsList;
begin
  newList := TPlBindElementsList.Create(True);
  newList.Add(AValue);
  FBindPropertyList.Add(AKey, newList);
end;

function TPlBinder.Bind(ASource: TObject; const APropertySource: string;
  ATarget: TObject; const APropertyTarget: string;
  AFunction: TplBridgeFunction = nil): Boolean;
var
  Source, Target: TplBindElementData;
begin
  Result := False;
  try
    Source := TplBindElementData.Create(ASource, APropertySource);
  except
    on e: Exception do
      begin
        FBindErrorList.Add(SErrorInsertingABinding + e.message + '.');
        Exit;
      end;
  end;
  try
    Target := TplBindElementData.Create(ATarget, APropertyTarget, AFunction);
  except
    on e: Exception do
      begin
        if Assigned(Source) then
          Source.Free;
        FBindErrorList.Add(SErrorInsertingABinding + e.message + '.');
        Exit;
      end;
  end;
  InternalAdd(Source, Target);
  Result := True;
end;

{Returns A COPY of the BindPropertyList. Caller is responsible of freeing it.}
function TPlBinder.BindInfo: TPlBindList;
begin
  Result := TPlBindList.Create(FBindPropertyList);
end;

{CAVEAT: works only with _published_ event handlers}
procedure TPlBinder.BindMethod(ASource: TObject; const AMethodPath: string;
  ATarget: TObject; const ANewMethodName: string; AFunction: TplBridgeFunction);
var
  rType: TRttiType;
  rMethod: TRttiMethod;
  methodPath: string;
  sourceObject: TObject;
  recMethod: TMethod;
begin
  methodPath := AMethodPath;
  if (ASource is TComponent) then
    sourceObject := ComponentFromPath(TComponent(ASource), methodPath)
  else
    sourceObject := ASource;
  {Extract type information for ASource's type}
  rType := TPlRTTIUtils.Context.GetType(ATarget.ClassType);
  rMethod := rType.GetMethod(ANewMethodName);
  if Assigned(rMethod) then
    begin
      recMethod.Code := rMethod.CodeAddress;
      recMethod.Data := pointer(ATarget);
      SetMethodProp(sourceObject, methodPath, recMethod);
    end;

end;

procedure TPlBinder.BindObject(ASource: TObject; const APropertySource: string;
  ATarget: TObject);
begin
  TPlRTTIUtils.SetPathValue(ASource, APropertySource, ATarget);
end;

procedure TPlBinder.BindObject(ASource: TObject; const APropertySource: string;
  ATarget: TObject; ATargetPath: string);
var
  targetObject: TValue;
begin
  targetObject := TPlRTTIUtils.GetPathValue(ATarget, ATargetPath);
  BindObject(ASource, APropertySource, targetObject.AsObject);
end;

procedure TPlBinder.Clear;
begin
  Stop;
  FBindPropertyList.Clear;
end;

procedure TPlBinder.CloseAndFreeThread;
begin
  FEnabled := False;
  FInternalThread.Terminate;
  FInternalThread.WaitFor;
  FInternalThread.Free;
end;

function TPlBinder.ComponentFromPath(ASource: TComponent;
  var APropertyPath: string): TComponent;
var
  componentName: string;
  dotIndex: integer;
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

function TPlBinder.Count: integer;
begin
  Result := FBindPropertyList.Count;
end;

constructor TPlBinder.Create;
begin
  inherited;
  FThreadTerminated := True;
  FEnabled := False;
  FInterval := DEFAULT_INTERVAL;
{$IFDEF MSWINDOWS}
  FPriority := tpIdle;
{$ENDIF}
  FComparer := TPlParKeyComparer.Create;
  FBindPropertyList := TPlBindList.Create([doOwnsKeys, doOwnsValues], 0,
    FComparer);
  //  FBindPropertyList.OnKeyNotify := HandleKeyNotify;
  //  FBindPropertyList.OnValueNotify := HandleValueNotify;
  FBindErrorList := TStringList.Create;
end;

function TPlBinder.DebugInfo: TplBindDebugInfo;
begin
  Result.Active := FEnabled;
  Result.Interval := FInterval;
  Result.Count := FBindPropertyList.Count;
end;

destructor TPlBinder.Destroy;
begin
  Stop;
  //FreeValues; {Keys and Values are managed by TObjectsDictionary}
  FBindPropertyList.Clear;
  FBindPropertyList.Free;
  FBindErrorList.Free;
  inherited;
end;

procedure TPlBinder.AddError(AError: string);
begin
  FBindErrorList.Add(AError);
end;

procedure TPlBinder.DetachAsSource(ASource: TObject);
begin
  UnbindSource(ASource);
end;

procedure TPlBinder.DetachAsTarget(ATarget: TObject);
begin
  UnbindTarget(ATarget);
end;

procedure TPlBinder.DetachAsTarget(ATarget, ASource: TObject);
begin
  UnbindTarget(ATarget, ASource);
end;

function TPlBinder.GetBindErrorList: TStrings;
begin
  Result := TStringList.Create;
  Result.Assign(FBindErrorList);
end;

procedure TPlBinder.HandleKeyNotify(Sender: TObject;
  const Key: TplBindElementData; Action: TCollectionNotification);
var
  sourceElement: TValue;
  targetKey: TplBindElementData;
  tempPath: string;
begin
  case Action of
    cnRemoved:
      begin
        tempPath := Key.PropertyPath;
        sourceElement := TPlRTTIUtils.GetPathValue(Key.Element, tempPath);
        if sourceElement.IsObjectInstance then
          for targetKey in FBindPropertyList.Keys do
            TPlRTTIUtils.SetPathValue(targetKey.Element,
              targetKey.PropertyPath, nil);
      end;
  end;
end;

procedure TPlBinder.HandleValueNotify(Sender: TObject;
  const Key: TPlBindElementsList; Action: TCollectionNotification);
var
  targetElement: TValue;
  targetKey: TplBindElementData;
  tempPath: string;
begin
  case Action of
    cnRemoved:
      for targetKey in Key do
        begin
          tempPath := targetKey.PropertyPath;
          targetElement := TPlRTTIUtils.GetPathValue(targetKey.Element,
            tempPath);
          if targetElement.IsObjectInstance then
            TPlRTTIUtils.SetPathValue(targetKey.Element,
              targetKey.PropertyPath, nil);
        end;
  end;
end;

procedure TPlBinder.InternalAdd(Source, Target: TplBindElementData);
begin
  Target.Value := Source.Value;
  if FBindPropertyList.ContainsKey(Source) then
    UpgradeExistingItem(Source, Target)
  else
    AddNewItem(Source, Target);
end;

procedure TPlBinder.MonitorValues(const ARepeat: Boolean = True);
begin
  FThreadTerminated := False;
  FInternalThread := TThread.CreateAnonymousThread(
    procedure
    var
      item: TplBindElementData;
      doRepeat: Boolean;
    begin
      doRepeat := True;
      while doRepeat and Enabled and not TThread.CheckTerminated do
        begin
          if (Interval > 0) then
            TThread.Sleep(Interval);
          for item in FBindPropertyList.Keys do
            begin
              if (Enabled) and not TThread.CheckTerminated and item.ValueChanged
              then
                TThread.Synchronize(nil,
                  procedure
                  begin
                    UpdateListValues(FBindPropertyList[item], item.Value);
                  end);
            end;
          doRepeat := ARepeat;
        end;
      FThreadTerminated := True;
      Exit;
    end);
{$IFDEF MSWINDOWS}
  FInternalThread.Priority := FPriority;
{$ENDIF}
  FInternalThread.FreeOnTerminate := False;
  FInternalThread.Start();
end;

function TPlBinder.NormalizePath(ASource: TObject;
var SourcePath: string): TObject;
begin
  if Assigned(ASource) and (ASource is TComponent) then
    Result := ComponentFromPath(TComponent(ASource), SourcePath)
  else
    Result := ASource;
end;

procedure TPlBinder.SetBindErrorList(const Value: TStrings);
begin
  FBindErrorList.Assign(Value);
end;

procedure TPlBinder.SetFEnabled(const Value: Boolean);
begin
  if FEnabled <> Value then
    begin
      FEnabled := Value;
      if Value then
        MonitorValues
      else
        CloseAndFreeThread;
    end;
end;

procedure TPlBinder.Start(const ASleepInterval: integer);
begin
  Interval := ASleepInterval;
  Enabled := True;
end;

procedure TPlBinder.Stop;
begin
  Enabled := False;
end;

function TPlBinder.UnbindSource(ASource: TObject): Boolean;
var
  Key: TplBindElementData;
begin
  {TODO 5 -oPMo -cDebug : Removing a Key allegedly causes a memory leak when
   TPlBindPropertyList is created with Create([doOwnsKeys, doOwnsValues]),
   so we could enable/disable its binding. However, removing an element when
   the binder is running could create problems in the MonitorValues procedure,
   because its for.. in loop could be modified.
   This TODO applies to UnbindTarget procedures too.}
  Result := FBindPropertyList.Count = 0;
  if FBindPropertyList.Count > 0 then
    begin
      Key := FBindPropertyList.FindKey(ASource);
      while Key <> nil do
        begin
          FBindPropertyList.Remove(Key);
          Key := FBindPropertyList.FindKey(ASource);
        end;
    end;
end;

function TPlBinder.UnbindTarget(ATarget: TObject): Boolean;
var
  Key: TplBindElementData;
  keyOfValue: TplBindElementData;
  keysToDelete: TPlBindElementsList;
begin
  Result := FBindPropertyList.Count = 0;
  if FBindPropertyList.Count > 0 then
    begin
      for Key in FBindPropertyList.Keys do
        begin
          keyOfValue := FBindPropertyList.FindValue(Key, ATarget);
          while keyOfValue <> nil do
            begin
              FBindPropertyList.TryGetValue(Key, keysToDelete);
              keysToDelete.Remove(keyOfValue);
              keyOfValue := FBindPropertyList.FindValue(Key, ATarget);
            end;
        end;
      Result := True
    end;
end;

{TODO 3 -oPMo -cRefactoring : move Unbind* methods to TPlBindElementsList}
function TPlBinder.UnbindTarget(ATarget: TObject; ASource: TObject): Boolean;
var
  Key: TplBindElementData;
  Keys: TPlBindElementsArray;
  keyOfValue: TplBindElementData;
  Value: TPlBindElementsList;
begin
  Result := FBindPropertyList.Count = 0;
  if FBindPropertyList.Count > 0 then
    begin
      Keys := FBindPropertyList.FindKeys(ASource);
      for Key in Keys do
        begin
          keyOfValue := FBindPropertyList.FindValue(Key, ATarget);
          while keyOfValue <> nil do
            begin
              FBindPropertyList.TryGetValue(Key, Value);
              Value.Remove(keyOfValue);
              keyOfValue := FBindPropertyList.FindValue(Key, ATarget);
            end;
        end;
      Result := True
    end;
end;

procedure TPlBinder.UpdateListValues(aList: TPlBindElementsList;
newValue: TValue);
var
  item: TplBindElementData;
begin
  for item in aList do
    item.Value := newValue;
end;

procedure TPlBinder.UpdateValues;
var
  item: TplBindElementData;
begin
  for item in FBindPropertyList.Keys do
    try
      if item.ValueChanged then
        UpdateListValues(FBindPropertyList[item], item.Value);
    except
      on e: Exception do
        FBindErrorList.Add(Format(SOnUpgradingBindIsDisabled,
          [e.message, item.PropertyPath]));
    end;
end;

procedure TPlBinder.UpgradeExistingItem(AKey, AValue: TplBindElementData);
var
  structureList: TPlBindElementsList;
begin
  structureList := FBindPropertyList.Items[AKey];
  if not structureList.Contains(AValue) then
    structureList.Add(AValue)
  else
    {TODO 1 -oPMo -cRefactoring : Maybe would be better
     to override existing item? Or to enable it?}
    AValue.Free;
  AKey.Free;
end;

end.
