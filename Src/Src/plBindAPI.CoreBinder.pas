{*****************************************************************************}
{       BindAPI                                                               }
{       Copyright (C) 2020 Paolo Morandotti                                   }
{       Unit plBindAPI.CoreBinder                                             }
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
unit plBindAPI.CoreBinder;

interface

uses
  System.Rtti, System.Generics.Collections,
  System.Generics.Defaults, System.Classes,
  plBindAPI.Types, plBindAPI.BinderElement;

type

  TPlBinder = class(TInterfacedObject)
  private
    FComparer: TPlParKeyComparer;
    FEnabled: Boolean;
    FInterval: integer;
{$IFDEF MSWINDOWS}
    FPriority: TThreadPriority;
{$ENDIF}
    procedure AddNewItem(AKey, AValue: TplRTTIMemberBind);
    function ComponentFromPath(ASource: TComponent; var APropertyPath: string): TComponent;
    procedure FreeValues;
    procedure InternalAdd(Source, Target: TplRTTIMemberBind);
    procedure SetFEnabled(const Value: Boolean);
    procedure UpgradeExistingItem(AKey, AValue: TplRTTIMemberBind);
  protected
    FBindPropertyList: TPlBindList;
    FInternalThread: TThread;
    FThreadTerminated: boolean;
    procedure CloseAndFreeThread; virtual;
    procedure MonitorValues; virtual;
    procedure UpdateListValues(aList: TPlBindPropertiesList; newValue: TValue);
  public
    constructor Create; overload;
    destructor Destroy; override;
    property Enabled: Boolean read FEnabled write SetFEnabled;
    property Interval: integer read FInterval write FInterval;
{$IFDEF MSWINDOWS}
    property Priority: TThreadPriority read FPriority write FPriority;
{$ENDIF}
    procedure Bind(ASource: TObject; const APropertySource: string; ATarget: TObject; const APropertyTarget: string; AFunction: TplBridgeFunction = nil);
(*    procedure BindEventHandler(ASource: TObject; const AMethodPath: string; ATarget: TObject; const AHandlerName: string; AFunction: TplBridgeFunction = nil); *)
    function BindInfo: TPlBindList;
    procedure BindMethod(ASource: TObject; const AMethodPath: string; ATarget: TObject; const ANewMethodName: string; AFunction: TplBridgeFunction = nil);
    procedure BindObject(ASource: TObject; const APropertySource: string; ATarget: TObject); overload;
    procedure BindObject(ASource: TObject; const APropertySource: string; ATarget: TObject; ATargetPath: string); overload;
    procedure Clear;
    function Count: integer;
    function DebugInfo: TplBindDebugInfo;
    procedure DetachAsSource(ASource: TObject); deprecated;
    procedure DetachAsTarget(ATarget: TObject); overload; deprecated;
    procedure DetachAsTarget(ATarget: TObject; ASource: TObject); overload; deprecated;
    function NormalizePath(ASource: TObject; var SourcePath: string): TObject;
    procedure Start(const SleepInterval: Integer);
    procedure Stop;
    procedure UnbindSource(ASource: TObject);
    procedure UnbindTarget(ATarget: TObject); overload;
    procedure UnbindTarget(ATarget: TObject; ASource: TObject); overload;
    procedure UpdateValues;
  end;

implementation

uses
  Winapi.Windows,
  System.TypInfo, System.Hash, System.SysUtils, System.Math, System.StrUtils,
  plBindAPI.RTTIUtils;

{ TPlBinder }

constructor TPlBinder.Create;
begin
  inherited;
  FThreadTerminated := True;
  FEnabled := False;
  FInterval := 100;
{$IFDEF MSWINDOWS}
  FPriority := tpIdle;
{$ENDIF}
  FComparer := TPlParKeyComparer.Create;
  FBindPropertyList := TPlBindList.Create([doOwnsKeys, doOwnsValues], 0, FComparer);
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
  FreeValues; {Keys are managed by TObjectsDictionary}
  FBindPropertyList.Free;
  inherited;
end;

procedure TPlBinder.AddNewItem(AKey, AValue: TplRTTIMemberBind);
var
  newList: TPlBindPropertiesList;
begin
  newList := TPlBindPropertiesList.Create;
  newList.Add(AValue);
  FBindPropertyList.Add(AKey, newList);
end;

procedure TPlBinder.Bind(ASource: TObject; const APropertySource: string;
  ATarget: TObject; const APropertyTarget: string;
  AFunction: TplBridgeFunction);
var
  Source, Target: TplRTTIMemberBind;
begin
  Source := TplRTTIMemberBind.Create(ASource, APropertySource);
  Target := TplRTTIMemberBind.Create(ATarget, APropertyTarget, AFunction);
  InternalAdd(Source, Target);
end;

function TPlBinder.BindInfo: TPlBindList;
begin
  Result := FBindPropertyList;
end;

{CAVEAT: bugged. AV on calling the bound method}
(*
procedure TPlBinder.BindEventHandler(ASource: TObject; const AMethodPath: string;
  ATarget: TObject; const AHandlerName: string; AFunction: TplBridgeFunction);
var
  rField: TRttiField;
  handlerMethod: TRttiMethod;
  eventProperty: TRttiProperty;
  methodPath: string;
  sourceObject: TObject;
  value: TValue;
begin
  raise Exception.Create('Uncallable method ;-)');
  methodPath := AMethodPath;
  if (ASource is TComponent) then
    sourceObject := ComponentFromPath(TComponent(ASource), methodPath)
  else
    sourceObject := ASource;

  eventProperty := FContext.GetType(sourceObject.ClassType).GetProperty(methodPath);
  handlerMethod := FContext.GetType(ATarget.ClassType).GetMethod(AHandlerName);

   begin
      if eventProperty.PropertyType.TypeKind = tkMethod then
      begin
         TValue.Make(@handlerMethod, eventProperty.PropertyType.Handle, value);
         eventProperty.SetValue(sourceObject, value);
      end;
   end;
end;
*)
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
  { Extract type information for ASource's type }
  rType := TplRTTIUtils.Context.GetType(ATarget.ClassType);
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
  TplRTTIUtils.SetPathValue(ASource, APropertySource, ATarget);
end;

procedure TPlBinder.BindObject(ASource: TObject; const APropertySource: string;
  ATarget: TObject; ATargetPath: string);
var
  targetObject: TValue;
begin
  targetObject := TplRTTIUtils.GetPathValue(ATarget, ATargetPath);
  bindObject(ASource, APropertySource, targetObject.AsObject);
end;

procedure TPlBinder.Clear;
begin
  Stop;
  FreeValues;
end;

procedure TPlBinder.CloseAndFreeThread;
begin
  FEnabled := False;
  FInternalThread.Terminate;
  FInternalThread.WaitFor;
//  if Assigned(FInternalThread) then
    FInternalThread.Free;  // restore if FreeOnTerminate becomes False
end;

function TPlBinder.ComponentFromPath(ASource: TComponent;
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
      nextComponent := sourceComponent.FindComponent(ComponentName);
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

procedure TPlBinder.FreeValues;
var
  value: TPlBindPropertiesList;
  structure: TplRTTIMemberBind;
begin
  for value in FBindPropertyList.Values do
    for structure in value do
      structure.Free;
end;

procedure TPlBinder.InternalAdd(Source, Target: TplRTTIMemberBind);
begin
  Target.Value := Source.Value;
  if FBindPropertyList.ContainsKey(Source) then
    UpgradeExistingItem(Source, Target)
  else
    AddNewItem(Source,Target);
end;

procedure TPlBinder.MonitorValues;
begin
  FThreadTerminated := False;
  FInternalThread := TThread.CreateAnonymousThread(
    procedure
    var
      item: TplRTTIMemberBind;
      FTickEvent: THandle;
    begin
      FTickEvent := CreateEvent(nil, True, False, nil);
      while Enabled and not TThread.CheckTerminated do
        begin
          if WaitForSingleObject(FTickEvent, Interval) = WAIT_TIMEOUT then
            begin
              for item in FBindPropertyList.Keys do
                begin
                  if (Enabled) and not TThread.CheckTerminated and item.ValueChanged then
                  TThread.Synchronize(nil,
                    procedure
                    begin
                      UpdateListValues(FBindPropertyList[item], item.Value);
                    end);
                end;
            end;
        end;
      SetEvent(FTickEvent);
      CloseHandle(FTickEvent);
      FThreadTerminated := True;
      Exit;
    end
    );
{$IFDEF MSWINDOWS}
  FInternalThread.Priority := FPriority;
{$ENDIF}
  FInternalThread.FreeOnTerminate := False;
  FInternalThread.Start();
end;

function TplBinder.NormalizePath(ASource: TObject; var SourcePath: string): TObject;
begin
  if Assigned(ASource) and (ASource is TComponent) then
    Result := ComponentFromPath(TComponent(ASource), SourcePath)
  else
    Result := ASource;
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

procedure TPlBinder.Start(const SleepInterval: Integer);
begin
  Interval := SleepInterval;
  Enabled := True;
end;

procedure TPlBinder.Stop;
begin
  Enabled := False;
end;

procedure TPlBinder.UnbindSource(ASource: TObject);
var
  Key: TplRTTIMemberBind;
begin
  {Remove a Key causes a memory leak when TPlBindPropertyList is created with
   Create([doOwnsKeys, doOwnsValues], so we enable/disable it}
  for Key in FBindPropertyList.Keys do
    if Key.Element = ASource then
      Key.Enabled := False;
end;

procedure TPlBinder.UnbindTarget(ATarget: TObject);
var
  value: TPlBindPropertiesList;
  keyOfValue: TplRTTIMemberBind;
begin
  for value in FBindPropertyList.Values do
    for keyOfValue in value do
      if keyOfValue.Element = ATarget then
        keyOfValue.Enabled := False;
end;

procedure TPlBinder.UnbindTarget(ATarget, ASource: TObject);
var
  key: TplRTTIMemberBind;
  sourceKey: TplRTTIMemberBind;
  sourceValue: TPlBindPropertiesList;
begin
  for key in FBindPropertyList.Keys do
    if key.Element = ASource then
      begin
        FBindPropertyList.TryGetValue(key, sourceValue);
        for sourceKey in sourceValue do
          if sourceKey.Element = ATarget then
            sourceKey.Enabled := False;
      end;
{TODO: unbind methods}      
end;

procedure TPlBinder.UpdateListValues(AList: TPlBindPropertiesList; newValue: TValue);
var
  item: TplRTTIMemberBind;
begin
  for item in AList do
    item.Value := newValue;
end;

procedure TPlBinder.UpdateValues;
var
  item: TplRTTIMemberBind;
begin
  for item in FBindPropertyList.Keys do
    if item.ValueChanged then
      UpdateListValues(FBindPropertyList[item], item.Value);
end;

procedure TPlBinder.UpgradeExistingItem(AKey, AValue: TplRTTIMemberBind);
var
  structureList: TPlBindPropertiesList;
begin
  structureList := FBindPropertyList.Items[AKey];
  if not structureList.Contains(AValue) then
    structureList.Add(AValue)
  else
{ TODO 1 -oPMo -cRefactoring : Maybe would be better to override existing item? Or to enable it? }
    AValue.Free;
  AKey.Free;
end;

end.
