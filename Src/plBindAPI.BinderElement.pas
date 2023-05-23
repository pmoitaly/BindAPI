{*****************************************************************************}
{       BindAPI                                                               }
{       Copyright (C) 2020 Paolo Morandotti                                   }
{       Unit plBindAPI.BinderElement                                          }
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
unit plBindAPI.BinderElement;

interface

uses
  System.Rtti, System.Classes, System.Generics.Collections,
  System.Generics.Defaults,
  plBindAPI.Types;

type

  TPlBindElementData = class;

  TPlBindTargetList = TList<TplBindElementData>;
  TPlBindList = TObjectDictionary<TplBindElementData, TPlBindTargetList>;


  {List of bound members}
  {An element data contains source or target atomic info}
  TPlBindElementData = class
  private
    FCalculatedValue: TplBridgeFunction;
    FClassAlias: string;
    FElement: TObject;
    FElementPath: string;
    FEnabled: Boolean;
    FValue: TValue;
    function CurrentValue: TValue;
    procedure SetValue(Value: TValue); virtual;
  public
    constructor Create(AObject: TObject; const APropertyPath: string; AFunction: TplBridgeFunction = nil);
    function IsEqualTo(AStructure: TplBindElementData) : Boolean;
    function ValueChanged: boolean;
    property ClassAlias: string read FClassAlias;
    property Element: TObject read FElement;
    property Enabled: Boolean read FEnabled write FEnabled;
    property PropertyPath: string read FElementPath;
    property Value: TValue read FValue write SetValue;
  end;

  {This class is required by TPlBindPropertyList}
  TPlParKeyComparer = class(TEqualityComparer<TPlBindElementData>)
    function Equals(const Left, Right: TPlBindElementData): Boolean; override;
    function GetHashCode(const Value: TPlBindElementData): Integer; override;
  end;

implementation

uses
  System.TypInfo, System.Hash, System.SysUtils, System.StrUtils, System.Math,
  plBindAPI.RTTIUtils;

{$REGION 'TPlBindElementData'}

constructor TPlBindElementData.Create(AObject: TObject;
  const APropertyPath: string; AFunction: TplBridgeFunction);
begin
  // Basic test. We should provide more test to verifiy if property exists, etc.
  if not Assigned(AObject) then
    raise Exception.Create('AObject not assgined');
  if APropertyPath = '' then
    raise Exception.Create('PropertyPath not set');

  FEnabled := True;
  FCalculatedValue := AFunction;
  FElementPath := APropertyPath;
  FElement := AObject;
  FValue := CurrentValue;
end;

{Get record value when a is a field of a property}
function TPlBindElementData.CurrentValue: TValue;
var
  path: string;
begin
  path := FElementPath;
  Result := TplRTTIUtils.GetPathValue(FElement, path);
end;

function TPlBindElementData.IsEqualTo(AStructure: TplBindElementData): Boolean;
begin
  Result := (Self.Element = AStructure.Element) and
    (Self.PropertyPath = AStructure.PropertyPath);
end;

procedure TPlBindElementData.SetValue(Value: TValue);
var
  path: string;
begin
  if not FEnabled then
    Exit;
  if Assigned(FCalculatedValue) then
    FValue := FCalculatedValue(Value, FValue)
  else
    FValue := Value;
  path := FElementPath;
  TplRTTIUtils.SetPathValue(FElement, path, FValue);
end;

{ TODO 2 -oPMo -cRefactoring : We should raise a specific exception without disabling the binding. }
function TPlBindElementData.ValueChanged: boolean;
var
  newValue: TValue;
begin
  if FEnabled and Assigned(FElement) then
    try
      newValue := CurrentValue;
      Result := not TplRTTIUtils.AreEqual(newValue, FValue);
      if Result then
        FValue := newValue;
    except
      Result := False;
      FEnabled := False;
    end
  else
    Result := False;
end;

{$ENDREGION}

{$REGION 'TPlParKeyComparer'}

function TPlParKeyComparer.Equals(const Left, Right: TPlBindElementData): Boolean;
begin
  Result := (Left.Element = Right.Element) and
    (Left.PropertyPath = Right.PropertyPath);
end;

function TPlParKeyComparer.GetHashCode(
  const Value: TPlBindElementData): Integer;
begin
  Result := THashBobJenkins.GetHashValue(PChar(Value.PropertyPath)^, Length(Value.PropertyPath) * SizeOf(Char), 0);
end;

{$ENDREGION}
end.
