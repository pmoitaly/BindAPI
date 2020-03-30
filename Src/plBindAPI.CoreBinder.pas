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

  TPlBindPropertiesList = TList<TplPropertyBind>;
  TPlBindPropertyList = TObjectDictionary<TplPropertyBind, TPlBindPropertiesList>;

  TPlBinder = class(TInterfacedObject)
  private
    FBindPropertyList: TPlBindPropertyList;
    FComparer: TPlParKeyComparer;
    FEnabled: Boolean;
    FInternalThread: TThread;
    FThreadTerminated: boolean;
    FInterval: integer;
    procedure AddNewItem(AKey, AValue: TplPropertyBind);
    function ComponentFromPath(ASource: TComponent; var APropertyPath: string): TComponent;
    procedure FreeValues;
    procedure InternalAdd(Source, Target: TplPropertyBind);
    procedure MonitorValues;
    procedure UpgradeExistingItem(AKey, AValue: TplPropertyBind);
    procedure UpdateListValues(aList: TPlBindPropertiesList; newValue: TValue);
    procedure SetFEnabled(const Value: Boolean);
    procedure CloseAndFreeThread;
  protected
  public
    constructor Create; overload;
    destructor Destroy; override;
    property Enabled: Boolean read FEnabled write SetFEnabled;
    property Interval: integer read FInterval write FInterval;
    procedure Bind(ASource: TObject; const APropertySource: string; ATarget: TObject; const APropertyTarget: string; AFunction: TplBridgeFunction = nil);
    procedure BindMethod(ASource: TObject; const AMethodPath: string; ATarget: TObject; const ANewMethodName: string; AFunction: TplBridgeFunction = nil);
    function Count: integer;
    procedure DetachAsSource(ASource: TObject);
    procedure DetachAsTarget(ATarget: TObject);
    function NormalizePath(ASource: TObject; var SourcePath: string): TObject;
    procedure Start(const SleepInterval: Integer);
    procedure Stop;
    procedure UpdateValues;
  end;

implementation

uses
  System.TypInfo, System.Hash, System.SysUtils, System.Math;
//  , Delphi.Mocks.Helpers;

{ TPlBinder }

procedure TPlBinder.AddNewItem(AKey, AValue: TplPropertyBind);
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
  Source, Target: TplPropertyBind;
begin
  Source := TplPropertyBind.Create(ASource, APropertySource);
  Target := TplPropertyBind.Create(ATarget, APropertyTarget, AFunction);
  InternalAdd(Source, Target);
end;


procedure TPlBinder.BindMethod(ASource: TObject; const AMethodPath: string;
  ATarget: TObject; const ANewMethodName: string; AFunction: TplBridgeFunction);
var
  rContext: TRttiContext;
  rType: TRttiType;
  rMethod: TRttiMethod;
  methodPath: string;
  targetObject: TObject;
  recMethod: TMethod;
begin
  methodPath := AMethodPath;
  rContext := TRttiContext.Create;
  if (ASource is TComponent) then
    targetObject := ComponentFromPath(TComponent(ASource), methodPath)
  else
    targetObject := ASource;
  { Extract type information for ASource's type }
  rType := rContext.GetType(ATarget.ClassType);
  rMethod := rType.GetMethod(ANewMethodName);
  if Assigned(rMethod) then
    begin
      recMethod.Code := rMethod.CodeAddress;
      recMethod.Data := pointer(ATarget); //(Self);
      SetMethodProp(targetObject, methodPath, recMethod);
    end;

  rContext.Free;
end;


procedure TPlBinder.CloseAndFreeThread;
var
  i: Integer;
begin
  FEnabled := False;
  i := 0;
  while not FThreadTerminated and (i < 5) do
  begin
    FInternalThread.Terminate;
    i := i + 1;
    Sleep(FInterval);
  end;
//  FInternalThread.Free;
  if Assigned(FInternalThread) and not FThreadTerminated then
    try
      FInternalThread.FreeOnTerminate := False;
      FInternalThread.Free;
    finally
      // ?
    end;
end;

constructor TPlBinder.Create;
begin
  FThreadTerminated := True;
  FEnabled := False;
  FInterval := 100;
  FComparer := TPlParKeyComparer.Create;
  FBindPropertyList := TPlBindPropertyList.Create([doOwnsKeys, doOwnsValues], FComparer);
end;

destructor TPlBinder.Destroy;
begin
  Stop;
  FreeValues; {Keys are managed by TObjectsDictionary}
  FBindPropertyList.Free;
  inherited;
end;

procedure TPlBinder.DetachAsSource(ASource: TObject);
var
  Key: TplPropertyBind;
begin
  {Remove a Key causes a memory leak when TPlBindPropertyList is created with
   Create([doOwnsKeys, doOwnsValues], so we enable/disable it}
  for Key in FBindPropertyList.Keys do
    if Key.Element = ASource then
      Key.Enabled := False;
end;

procedure TPlBinder.DetachAsTarget(ATarget: TObject);
var
  Value: TPlBindPropertiesList;
  KeyOfValue: TplPropertyBind;
begin
  for Value in FBindPropertyList.Values do
    for KeyOfValue in Value do
      if KeyOfValue.Element = ATarget then
        KeyOfValue.Enabled := False;
end;

procedure TPlBinder.FreeValues;
var
  value: TPlBindPropertiesList;
  structure: TplPropertyBind;
begin
  for value in FBindPropertyList.Values do
    for structure in value do
      structure.Free;
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

procedure TPlBinder.InternalAdd(Source, Target: TplPropertyBind);
begin
  Target.Value := Source.Value;
  if FBindPropertyList.ContainsKey(Source) then
    UpgradeExistingItem(Source, Target)
  else
    AddNewItem(Source,Target);
end;

procedure TPlBinder.MonitorValues;
begin
  FEnabled := True;
  FThreadTerminated := False;
  FInternalThread := TThread.CreateAnonymousThread(
    procedure
    var
      item: TplPropertyBind;
    begin
    while FEnabled do
      begin
      Sleep(FInterval);
      for item in FBindPropertyList.Keys do
        begin
          if item.ValueChanged then
          IF (FEnabled) then
          TThread.Synchronize(nil,
            procedure
            begin
              UpdateListValues(FBindPropertyList[item], item.Value);
            end);
        end;
      end;
    FThreadTerminated := True;
    end
  );
//  FInternalThread.Priority := tpLowest;
  FInternalThread.FreeOnTerminate := True;
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

procedure TPlBinder.UpdateListValues(AList: TPlBindPropertiesList; newValue: TValue);
var
  item: TplPropertyBind;
begin
  for item in AList do
    item.Value := newValue;
end;

procedure TPlBinder.UpdateValues;
var
  item: TplPropertyBind;
begin
  for item in FBindPropertyList.Keys do
    if item.ValueChanged then
      UpdateListValues(FBindPropertyList[item], item.Value);
end;

procedure TPlBinder.UpgradeExistingItem(AKey, AValue: TplPropertyBind);
var
  structureList: TPlBindPropertiesList;
begin
  structureList := FBindPropertyList.Items[AKey];
  if not structureList.Contains(AValue) then
    structureList.Add(AValue)
  else
    AValue.Free;
  AKey.Free;
end;

end.
