{*****************************************************************************}
{       BindAPI                                                               }
{       Copyright (C) 2020 Paolo Morandotti                                   }
{       Unit plBindAPI.DeferredBinding                                             }
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
unit plBindAPI.DeferredBinding;

interface

uses
  {$IFDEF FPC}
  Classes, Rtti, Generics.Collections,
  {$ELSE}
  System.Classes, System.Rtti, System.Generics.Collections,
  {$ENDIF}
  plBindAPI.Types, plBindAPI.Attributes, plBindAPI.AutoBinder;

type
  TplDeferredElement = record
    Attribute: ClassBindAttribute;
    Source: TObject;
  end;

  TplDeferredBinding = class
  private
    class var DeferredList: TDictionary<string,TplDeferredElement>;
  public
    class constructor Create;
    class destructor Destroy;
    class function Add(ASource: TObject): TObject; overload;
    class function Add(ADeferredElement: TPlDeferredElement): TPlDeferredElement; overload;
    class procedure TestDeferred;
  end;

implementation

uses
  plBindAPI.RTTIUtils, plBindAPI.BindManagement, plBindAPI.ClassFactory;
{ TplDeferredBinding }

class function TplDeferredBinding.Add(
  ADeferredElement: TPlDeferredElement): TPlDeferredElement;
begin
  DeferredList.Add(ADeferredElement.Attribute.TargetClassName, ADeferredElement);
  Result := ADeferredElement;
end;

class function TplDeferredBinding.Add(ASource: TObject): TObject;
var
  deferredElement: TplDeferredElement;
  rType: TRttiType;
  rAttr: TCustomAttribute;
begin

  deferredElement.Source := ASource;
  rType := TplRTTIUtils.Context.GetType(ASource.ClassType);
  for rAttr in rType.GetAttributes do
    if rAttr is ClassBindAttribute then
      begin
        deferredElement.Attribute := ClassBindAttribute(rAttr);
        Add(deferredElement);
      end;
  Result := ASource;
end;

class constructor TplDeferredBinding.Create;
begin
  DeferredList :=  TDictionary<string,TplDeferredElement>.Create;
end;

class destructor TplDeferredBinding.Destroy;
begin
  DeferredList.Free;
end;

class procedure TplDeferredBinding.TestDeferred;
var
  className: string;
  deferredElement: TPlDeferredElement;
begin
  for className in DeferredList.Keys do
    if TplClassManager.IsRegistered(className) then
      begin
        // Force binding, then remove the element from the list
        deferredElement := DeferredList.Items[className];
        TplBindManager.AddBind(deferredElement.Source, deferredElement.Attribute);
        DeferredList.Remove(className);
      end;
end;

end.
