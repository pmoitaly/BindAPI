{*****************************************************************************}
{                                                                             }
{Copyright (C) 2020-2024 Paolo Morandotti                                     }
{Unit plBindAPI.BindingElement                                                 }
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
unit plBindAPI.BindingElement;

interface

uses
  Classes, Rtti, TypInfo,
  Generics.Collections,
  Generics.Defaults,
  plBindAPI.Types;

type

  TPlBindElementData = class;

  TPlBindElementsList = TList<TPlBindElementData>;
  TPlBindList = TObjectDictionary<TPlBindElementData, TPlBindElementsList>;

  {List of bound members}
  /// <summary>
  /// An element data contains source or target atomic info.
  /// </summary>
  /// <remarks>
  /// <para>Two instances of this class are stored in the binder that contain
  ///  informations about bindong's source & target.</para>
  /// <para>Do not use this class directly. <see cref=”TPlBinder” \>
  /// manages all necessary instances of this class.</para>
  /// </remarks>
  TPlBindElementData = class
  private
    /// <summary>
    /// Holds a function for calculating the value sent to the target.
    /// </summary>
    FCalculatedValue: TplBridgeFunction;

    /// <summary>
    /// Stores the class alias.
    /// </summary>
    FClassAlias: string;

    /// <summary>
    /// References the associated object.
    /// </summary>
    FElement: TObject;

    /// <summary>
    /// QName of the property involved in the binding.
    /// </summary>
    FElementPath: string;

    /// <summary>
    /// Indicates whether the binding is enabled.
    /// </summary>
    FEnabled: Boolean;

    // FParametersType: TPlIndexedPropertyInfo;  // for future use

    /// <summary>
    /// Current value of the element.
    /// </summary>
    FValue: TValue;

    /// <summary>
    /// Returns the current value of the element.
    /// </summary>
    function CurrentValue: TValue;

    /// <summary>
    /// Sets a new value for the element.
    /// </summary>
    /// <param name="Value">The new value to set.</param>
    procedure SetValue(Value: TValue); virtual;

  public
    /// <summary>
    /// Constructor to initialize the element data.
    /// </summary>
    /// <param name="AObject">The object to bind.</param>
    /// <param name="APropertyPath">The path of the property to bind.</param>
    /// <param name="AFunction">Optional bridge function for value calculation.</param>
    constructor Create(AObject: TObject; const APropertyPath: string;
      AFunction: TplBridgeFunction = nil);

    /// <summary>
    /// Destructor to clean up resources.
    /// </summary>
    destructor Destroy; override;

    /// <summary>
    /// Compares the current structure with another TPlBindElementData.
    /// </summary>
    /// <param name="AStructure">The structure to compare with.</param>
    /// <returns>True if structures are equal; otherwise, false.</returns>
    function IsEqualTo(AStructure: TPlBindElementData): Boolean;

    /// <summary>
    /// Checks if the value has changed since the last update.
    /// </summary>
    /// <returns>True if the value has changed; otherwise, false.</returns>
    function ValueChanged: Boolean;

    /// <summary>
    /// Alias of the class.
    /// </summary>
    property ClassAlias: string read FClassAlias;

    /// <summary>
    /// The associated object.
    /// </summary>
    property Element: TObject read FElement;

    /// <summary>
    /// Indicates whether the binding is enabled.
    /// </summary>
    property Enabled: Boolean read FEnabled write FEnabled;

    /// <summary>
    /// The path of the bound property.
    /// </summary>
    property PropertyPath: string read FElementPath;

    /// <summary>
    /// The current value of the bound element.
    /// </summary>
    property Value: TValue read FValue write SetValue;
  end;

  /// <summary>
  /// This class is required by <see cref="TPlBindPropertyList" />.
  /// </summary>
  TPlParKeyComparer = class(TEqualityComparer<TPlBindElementData>)
    /// <summary>
    /// Compares two <see cref="TPlBindElementData /> instances for equality.
    /// </summary>
    /// <param name="Left">The first instance to compare.</param>
    /// <param name="Right">The second instance to compare.</param>
    /// <returns>True if both instances are equal; otherwise, false.</returns>
    function Equals(const Left, Right: TPlBindElementData): Boolean; override;

    /// <summary>
    /// Generates a hash code for a <see cref="TPlBindElementData /> instance.
    /// </summary>
    /// <param name="Value">The instance to generate a hash code for.</param>
    /// <returns>The generated hash code.</returns>
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

destructor TPlBindElementData.Destroy;
begin

  inherited;
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
