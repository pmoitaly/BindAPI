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
/// <summary>
///   Implementation of TPlBindElement.
/// </summary>
/// <remarks>
///   Implementation of the structures that store the atomic informations of a
// binding. You should never need a direct access to them.
/// </remarks>
unit plBindAPI.BindingElement;

interface

uses
  Classes, Rtti, TypInfo,
  Generics.Collections,
  Generics.Defaults,
  plBindAPI.Types;

type
  TPlBindElementData = class;
  TPlBindElementsArray = array of TPlBindElementData;

  TPlBindElementsList = TObjectList<TPlBindElementData>;

  TPlBindList = class(TObjectDictionary<TPlBindElementData,
    TPlBindElementsList>)
  public
    /// <summary>
    /// Disables the key element identified by an object and a property path
    /// </summary>
    /// <remarks>
    /// <para>Performs a linear search over the keys and disable the first
    /// occurrence that matches the parameters.</para>
    ///  <note type="warning"><b>Do not use an instance of this class, unless
    /// you konw what are you doing. If you do that, does not add the same
    /// <c>TPlElementData</c> as key and as value, nor as many values. That
    /// would resolve in lots of <i>Invalid point operation</i> errors when
    /// the istance is destroyed.</note>
    ///  </remarks>
    /// <param name="ASource">The object to compare with.</param>
    /// <param name="APropertyPath">Optional. The property path to compare with.</param>
    procedure DisableElement(ASource: TObject; const APropertyPath: string = '§');
    /// <summary>
    /// Enables the key element identified by an object and a property path
    /// </summary>
    /// <remarks>
    /// <para>Performs a linear search over the keys and enable the first
    /// occurrence that matches the parameters.</para>
    /// <param name="ASource">The object to compare with.</param>
    /// <param name="APropertyPath">Optional. The property path to compare with.</param>
    procedure EnableElement(ASource: TObject; const APropertyPath: string = '§');
    /// <summary>
    /// Returns the all keys where element equals the parameter ASource.
    /// </summary>
    /// <remarks>
    /// <para>Performs a linear search over the keys and returns any
    /// occurrence that matches the parameter.</para>
    /// <para>If no key is found, the function returns an empty list.</para>
    /// </remarks>
    /// <param name="ASource">The object to compare with.</param>
    /// <returns>The first matching key or nil.</returns>
    function FindKeys(ASource: TObject): TPlBindElementsArray;
    /// <summary>
    /// Returns the first key where element equals the parameter ASource.
    /// </summary>
    /// <remarks>
    /// <para>Performs a linear search over the keys and returns the first
    /// occurrence that matches the parameter.</para>
    /// <para>If no key is found, the function returns nil.</para>
    /// </remarks>
    /// <param name="ASource">The object to compare with.</param>
    /// <returns>The first matching key or nil.</returns>
    function FindKey(ASource: TObject; const APropertyPath: string = '§'): TPlBindElementData;
    /// <summary>
    /// Returns the first value of a key where element equals the parameter ASource.
    /// </summary>
    /// <remarks>
    /// <para>Performs a linear search over the values of the keys and returns the first
    /// occurrence that matches the parameter.</para>
    /// <para>If no value is found, the function returns nil.</para>
    /// </remarks>
    /// <param name="ASource">The object to compare with.</param>
    /// <param name="ATarget">The object to compare with.</param>
    /// <returns>The first matching key or nil.</returns>
    function FindValue(AKey: TPlBindElementData; ATarget: TObject)
      : TPlBindElementData;
  end;

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
{$REGION 'TPlBindList'}

procedure TPlBindList.DisableElement(ASource: TObject; const APropertyPath:
    string = '§');
var
  key: TPlBindElementData;
begin
  key := FindKey(ASource, APropertyPath);
  if Assigned(key) then
    key.Enabled := False;
end;


procedure TPlBindList.EnableElement(ASource: TObject; const APropertyPath:
    string = '§');
var
  key: TPlBindElementData;
begin
  key := FindKey(ASource, APropertyPath);
  if Assigned(key) then
    key.Enabled := True;
end;

function TPlBindList.FindKey(ASource: TObject; const APropertyPath: string =
    '§'): TPlBindElementData;
var
  key: TPlBindElementData;
begin
  for key in keys do
    if (key.Element = ASource) and ((key.PropertyPath = APropertyPath) or (APropertyPath = '§')) then
      begin
        Result := key;
        Exit;
      end;
  Result := nil;
end;

function TPlBindList.FindKeys(ASource: TObject): TPlBindElementsArray;
var
  key: TPlBindElementData;
begin
  for key in keys do
    if key.Element = ASource then
      begin
        SetLength(Result, Length(Result) + 1);
        Result[High(Result)] := key;
      end;
end;

function TPlBindList.FindValue(AKey: TPlBindElementData; ATarget: TObject)
  : TPlBindElementData;
var
  Value: TPlBindElementData;
  keyValue: TPlBindElementsList;
begin
  TryGetValue(AKey, keyValue);
  if Assigned(keyValue) then
    for Value in keyValue do
      if Value.Element = ATarget then
        begin
          Result := Value;
          Exit
        end;

  Result := nil;
end;

{$ENDREGION}

end.
