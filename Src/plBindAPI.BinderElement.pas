{*****************************************************************************}
{                                                                             }
{Copyright (C) 2020-2024 Paolo Morandotti                                     }
{Unit plBindAPI.BinderElement                                                 }
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
  Classes, Rtti, TypInfo,
  Generics.Collections,
  Generics.Defaults,
  plBindAPI.Types;

type

  TPlBindElementData = class;

  TPlBindTargetList = TList<TPlBindElementData>;
  TPlBindList = TObjectDictionary<TPlBindElementData, TPlBindTargetList>;

  {List of bound members}
  {An element data contains source or target atomic info}
  TPlBindElementData = class
  private
    FCalculatedValue: TplBridgeFunction;
    FClassAlias: string;
    FElement: TObject;
    FElementPath: string;
    FEnabled: Boolean;
    FParametersType: TPlIndexedPropertyInfo;
    FValue: TValue;
    function CurrentValue: TValue;
    procedure SetValue(Value: TValue); virtual;
  public
    constructor Create(AObject: TObject; const APropertyPath: string;
      AFunction: TplBridgeFunction = nil); // overload; deprecated;
    // constructor Create(AObject: TObject; const APropertyPath: string;
    //  const AFunction: string = ''); overload;
    function IsEqualTo(AStructure: TPlBindElementData): Boolean;
    function ValueChanged: Boolean;
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
  Hash,
  Math,
  StrUtils,
  SysUtils,

  plBindAPI.RTTIUtils;

resourcestring
  StrAObjectParameterNo = 'AObject parameter not assigned';
  StrPropertyPathNotSet = 'PropertyPath not set';

{$REGION 'TPlBindElementData'}

constructor TPlBindElementData.Create(AObject: TObject;
  const APropertyPath: string; AFunction: TplBridgeFunction);
begin
  { TODO 5 -oPMo -cRefactoring : Basic test. Should we provide more test to verifiy if property exists, etc. ? }
  if not Assigned(AObject) then
    raise Exception.Create(StrAObjectParameterNo);
  if APropertyPath = '' then
    raise Exception.Create(StrPropertyPathNotSet);

  FEnabled := True;
  FCalculatedValue := AFunction;
  FElementPath := APropertyPath;
  FElement := AObject;

  FValue := CurrentValue;
end;

{Get record value when there is a field of a property}
function TPlBindElementData.CurrentValue: TValue;
var
  path: string;
begin
  path := FElementPath;
  Result := TplRTTIUtils.GetPathValue(FElement, path);
end;

function TPlBindElementData.IsEqualTo(AStructure: TPlBindElementData): Boolean;
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

{TODO 2 -oPMo -cRefactoring : Should we raise a specific exception
without disabling the binding?}
function TPlBindElementData.ValueChanged: Boolean;
var
  newValue: TValue;
begin
    Result := False;
  if FEnabled and Assigned(FElement) then
    try
      newValue := CurrentValue;
      Result := not TplRTTIUtils.AreEqual(newValue, FValue);
      if Result then
        FValue := newValue;
    except
      // Result := False;
      on e: Exception do
        begin
          FEnabled := False;
          raise;
        end;
    end;
end;

{$ENDREGION}
{$REGION 'TPlParKeyComparer'}

function TPlParKeyComparer.Equals(const Left,
  Right: TPlBindElementData): Boolean;
begin
  Result := (Left.Element = Right.Element) and
    (Left.PropertyPath = Right.PropertyPath);
end;

function TPlParKeyComparer.GetHashCode(const Value: TPlBindElementData)
  : Integer;
begin
  Result := THashBobJenkins.GetHashValue(PChar(Value.PropertyPath)^,
    Length(Value.PropertyPath) * SizeOf(Char), 0);
end;

{$ENDREGION}

end.
