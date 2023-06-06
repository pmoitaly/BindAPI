{*****************************************************************************}
{       BindAPI                                                               }
{       Copyright (C) 2020 Paolo Morandotti                                   }
{       Unit plBindAPI.BindManagement                                         }
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
unit plBindAPI.BindManagement;

interface

uses
  Classes,
  plBindAPI.Attributes, plBindAPI.AutoBinder, plBindAPI.ClassFactory,
  plBindApi.Types;

type

  TPlBindManager = class(TInterfacedObject)
  private
    class var FBinder: TPlAutoBinder;
    class function ExtractTarget(ASource: TObject; AClassAttribute:
        ClassBindAttribute): TObject;
    class procedure AddDeferredElement(ASource: TObject; AClassAttribute:
        ClassBindAttribute);
    class function GetInterval: Integer; static;
    class procedure SetInterval(const Value: Integer); static;
  protected
    class constructor Create;
    class destructor Destroy;
  public
    { Public declarations }
    class function AddBind(ASource: TObject; AClassAttribute: ClassBindAttribute): boolean;
    class function AddDeferredBind(ASource: TObject): boolean; static;
    class procedure Bind(ASource: TObject);
    class function DebugInfo: TPlBindDebugInfo;
    class procedure Unbind(ASource: TObject);
    class property Binder: TPlAutoBinder read FBinder;
    class property Interval: Integer read GetInterval write SetInterval;
  end;

implementation

uses
  Rtti, StrUtils, TypInfo,
  plBindAPI.DeferredBinding, plBindAPI.RTTIUtils;

{$REGION 'TPlBindManager'}

class constructor TPlBindManager.Create;
begin
  inherited;
  FBinder := TplAutoBinder.Create;
  FBinder.Start(10);
end;

class destructor TPlBindManager.Destroy;
begin
  FBinder.Free;
  inherited;
end;

class function TPlBindManager.AddBind(ASource: TObject; AClassAttribute: ClassBindAttribute): boolean;
var
  target: TObject;
begin
  target := ExtractTarget(ASource, AClassAttribute);
  if Assigned(target) then
    FBinder.BindObject(ASource, target, AClassAttribute)
  else
    AddDeferredElement(ASource, AClassAttribute);
  Result := Assigned(target);
end;

class function TPlBindManager.AddDeferredBind(ASource: TObject): boolean;
var
  rType: TRttiType;
  rAttr: TCustomAttribute;
begin
  Result := True;

  { Extract type information for ASource's type }
  rType := TplRTTIUtils.Context.GetType(ASource.ClassType);
  { Search for the custom attribute and do some custom processing }
  for rAttr in rType.GetAttributes() do
    if rAttr is ClassBindAttribute and ClassBindAttribute(rAttr).IsEnabled then
      AddDeferredElement(ASource, ClassBindAttribute(rAttr));
end;

class procedure TPlBindManager.AddDeferredElement(ASource: TObject;
    AClassAttribute: ClassBindAttribute);
var
  deferredElement: TplDeferredElement;
begin
  deferredElement.Attribute := AClassAttribute;
  deferredElement.Source := ASource;
  TPlDeferredBinding.Add(deferredElement);
end;

class procedure TPlBindManager.Bind(ASource: TObject);
var
  rType: TRttiType;
  rAttr: TCustomAttribute;
begin

  { Extract type information for ASource's type }
  rType := TplRTTIUtils.Context.GetType(ASource.ClassType);
  { Search for enabled BindAPI attributes and process them }
  for rAttr in rType.GetAttributes() do
    if rAttr is ClassBindAttribute and ClassBindAttribute(rAttr).IsEnabled then
      AddBind(ASource, ClassBindAttribute(rAttr));
end;

class function TPlBindManager.DebugInfo: TplBindDebugInfo;
begin
  Result := FBinder.DebugInfo;
end;

class function TPlBindManager.ExtractTarget(ASource: TObject; AClassAttribute:
    ClassBindAttribute): TObject;
var
  targetName: string;
  target: TObject;
begin
  targetName := AClassAttribute.TargetClassName;
  if (targetName = 'Self') or (targetName = ASource.ClassName) then
    target := ASource
  else
    target := TplClassManager.GetInstance(AClassAttribute.TargetClassName);
  Result := target;
end;

class function TPlBindManager.GetInterval: Integer;
begin
  Result := FBinder.Interval;
end;

class procedure TPlBindManager.SetInterval(const Value: Integer);
begin
  FBinder.Interval := Value;
end;

class procedure TPlBindManager.Unbind(ASource: TObject);
begin
  FBinder.UnbindTarget(ASource);
  FBinder.UnbindSource(ASource);
  FBinder.UnbindMethods(ASource);
end;

{$ENDREGION}

end.
