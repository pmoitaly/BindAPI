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
  System.SysUtils, System.Classes, System.Generics.Collections;

type
  TplClassList = class(TDictionary<string, TClass>);
  TplInstanceList = class(TObjectDictionary<string, TObject>);

  TplClassManager = class
  private
    { Private declarations }
    class var FClassList: TplClassList;
    class var FInstanceList: TplInstanceList;
    class function CreateInstance(AClass: TClass): TObject;
    class function GetNewInstance(const AClassName: string): TObject;
    class function GetSingletonInstance(const AClassName: string): TObject;
  protected
    class constructor Create;
    class destructor Destroy;
  public
    { Public declarations }
    class procedure RegisterClass(AClass: TClass; AsSingleton: boolean);
    class function GetInstance(const AClassName: string): TObject;
    class function IsSingleton(const AClassName: string): Boolean; overload;
    class function IsSingleton(const AnInstance: TObject): Boolean; overload;
  end;

implementation

uses
  System.RTTI;

{ TplClassManager }

class constructor TplClassManager.Create;
begin
  FClassList := TplClassList.Create;
  FInstanceList := TplInstanceList.Create([doOwnsValues]);
end;

class function TplClassManager.CreateInstance(AClass: TClass): TObject;
var
  rContext: TRttiContext;
  rType: TRttiType;
  rValue: TValue;
begin
  rContext := TRttiContext.Create;
  rType := rContext.GetType(AClass);

  rValue := rType.GetMethod('Create').Invoke(rType.AsInstance.MetaclassType,[]);
  Result := rValue.AsObject;

  rContext.Free;
end;

class destructor TplClassManager.Destroy;
begin
  FClassList.Free;
  FInstanceList.Free;
end;

class function TplClassManager.GetInstance(const AClassName: string): TObject;
begin
  if FClassList.ContainsKey(AClassName) then
    begin
      if FInstanceList.ContainsKey(AClassName) then
        Result := GetSingletonInstance(AClassName)
      else
        Result := GetNewInstance(AClassName);
    end
  else
    raise Exception.Create(AClassName + 'not registered.');
end;

class function TplClassManager.GetNewInstance(
  const AClassName: string): TObject;
var
  aClass: TClass;
begin
  FClassList.TryGetValue(AClassName, aClass);
  Result := CreateInstance(aClass);
end;

class function TplClassManager.GetSingletonInstance(const AClassName: string): TObject;
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

class function TplClassManager.IsSingleton(const AnInstance: TObject): Boolean;
begin
  Result := IsSingleton(AnInstance.ClassName);
end;

class function TplClassManager.IsSingleton(const AClassName: string): Boolean;
begin
  Result := FInstanceList.ContainsKey(AClassName);
end;

class procedure TplClassManager.RegisterClass(AClass: TClass;
  AsSingleton: boolean);
var
  key: string;
begin
  key := AClass.ClassName;
  if not FClassList.ContainsKey(key) then
    begin
      FClassList.Add(key, AClass);
      if AsSingleton then
        FInstanceList.Add(key, nil);// CreateInstance(AClass));
    end;
end;

end.
