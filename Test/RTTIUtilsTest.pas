{*****************************************************************************}
{BindAPI                                                                      }
{Copyright (C) 2020 Paolo Morandotti                                          }
{Unit RTTIUdilsTest                                                           }
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
unit RTTIUtilsTest;

interface

uses
  DUnitX.TestFramework,
  System.Rtti,
  System.SysUtils,
  System.Classes,
  System.TypInfo,
  plBindAPI.Types,
  plBindAPI.RTTIUtils;

type
  [TestFixture]
  TTestTPlRTTIUtils = class
  private
    FSampleComponent: TComponent;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestAreEqual;

    [Test]
    procedure TestComponentFromPath;

    [Test]
    procedure TestEnumerationToOrdinal;

    [Test]
    procedure TestGetIndexedPropertyInfo;

    [Test]
    procedure TestGetPathValue;

    [Test]
    procedure TestSetPathValue;

    [Test]
    procedure TestIsValidPath;

    [Test]
    procedure TestPropertyExists;

    [Test]
    procedure TestMethodIsImplemented;

    [Test]
    procedure TestOrdinalToEnumeration;

    [Test]
    procedure TestTryExtractNode;

    [Test]
    procedure TestGetIndexedPropertyValue;

    [Test]
    procedure TestSetIndexedPropertyValue;
end;

implementation

const
  SCpmTest = 'cpmTest';

procedure TTestTPlRTTIUtils.Setup;
begin
  FSampleComponent := TComponent.Create(nil);
  FSampleComponent.Name := SCpmTest;
end;

procedure TTestTPlRTTIUtils.TearDown;
begin
  FreeAndNil(FSampleComponent);
end;

procedure TTestTPlRTTIUtils.TestAreEqual;
var
  Value1, Value2: TValue;
begin
  Value1 := TValue.From<Integer>(42);
  Value2 := TValue.From<Integer>(42);
  Assert.IsTrue(TPlRTTIUtils.AreEqual(Value1, Value2));
  Value1 := TValue.From<Double>(4.2);
  Value2 := TValue.From<Double>(4.2);
  Assert.IsTrue(TPlRTTIUtils.AreEqual(Value1, Value2));
end;

procedure TTestTPlRTTIUtils.TestComponentFromPath;
var
  PropertyPath: string;
  ResultComponent: TComponent;
begin
  PropertyPath := 'Name';
  ResultComponent := TPlRTTIUtils.ComponentFromPath(FSampleComponent, PropertyPath);
  Assert.AreEqual(FSampleComponent, ResultComponent);
end;

procedure TTestTPlRTTIUtils.TestEnumerationToOrdinal;
var
  Context: TRttiContext;
  TypeInfo: TRttiType;
  Value: TValue;
  Result: TValue;
begin
  Context := TRttiContext.Create;
  try
    TypeInfo := Context.GetType(System.TypeInfo(TTypeKind)); // Qui il parametro è PTypeInfo
    Assert.IsNotNull(TypeInfo, 'Failed to retrieve RTTI type for TTypeKind');

    Value := TValue.From<TTypeKind>(tkInteger);
    Result := TPlRTTIUtils.EnumerationToOrdinal(TypeInfo, Value);

    Assert.AreEqual(Ord(tkInteger), Result.AsInteger,
      'The ordinal value of tkInteger does not match expected value');
  finally
    Context.Free; // Correct cleanup of RTTI context
  end;
end;


procedure TTestTPlRTTIUtils.TestGetIndexedPropertyInfo;
var
  PropertyInfo: TPlIndexedPropertyInfo;
begin
  Assert.WillNotRaise(
    procedure
    begin
      { TODO 3 -oPMo -cDebugging : Name? It is not an indexed property. }
      PropertyInfo := TPlRTTIUtils.GetIndexedPropertyInfo(FSampleComponent, 'Name');
    end
  );
end;

procedure TTestTPlRTTIUtils.TestGetIndexedPropertyValue;
var
  path: string;
  testComponent: TObject;
  testStrings: TStrings;
begin
  testStrings := TStringList.Create;
  testStrings.AddObject('TComponent', FSampleComponent);
  path := 'Objects[0]';
  try
    testComponent := TPlRTTIUtils.GetPathValue(testStrings, path).AsObject;
    Assert.IsTrue(Assigned(testComponent), 'Object from StringList not read');
    Assert.AreEqual(testComponent.ClassName, testStrings.Objects[0].ClassName);
  finally
    testStrings.Free;
  end;
end;

procedure TTestTPlRTTIUtils.TestGetPathValue;
var
  path: string;
  testString: TValue;
begin
    path := 'Name';
    testString := TPlRTTIUtils.GetPathValue(FSampleComponent, path);
    Assert.AreEqual(SCpmTest, testString.AsString);
end;

procedure TTestTPlRTTIUtils.TestSetIndexedPropertyValue;
var
  testStrings: TStrings;
begin
  testStrings := TStringList.Create;
  testStrings.Add('TComponent');
  try
    TPlRTTIUtils.SetPathValue(testStrings, 'Objects[0]', FSampleComponent);
    Assert.AreEqual(FSampleComponent.ClassName, testStrings.Objects[0].ClassName);
  finally
    testStrings.Free;
  end;
end;

procedure TTestTPlRTTIUtils.TestSetPathValue;
var
  Path: string;
begin
  Path := 'Name';
  TPlRTTIUtils.SetPathValue(FSampleComponent, Path, 'NewComponentName');
  Assert.AreEqual('NewComponentName', FSampleComponent.Name);
end;

procedure TTestTPlRTTIUtils.TestIsValidPath;
var
  Path: string;
begin
  Path := 'Name';
  Assert.IsTrue(TPlRTTIUtils.IsValidPath(FSampleComponent, Path));
end;

procedure TTestTPlRTTIUtils.TestPropertyExists;
begin
  Assert.IsTrue(TPlRTTIUtils.PropertyExists(TComponent, 'Name'));
end;

procedure TTestTPlRTTIUtils.TestMethodIsImplemented;
var
  aComponent: TComponent;
  aText: string;
begin
  aComponent := TComponent.Create(nil);
  try
    aText := aComponent.ToString;
  finally
    aComponent.Free;
  end;
  // TObject's methods are not found by RTTI's GetMethods
  Assert.IsFalse(TPlRTTIUtils.MethodIsImplemented(TComponent, 'ToString'), aText + ' ToString method is not implemented in TComponent class.');
  Assert.IsFalse(TPlRTTIUtils.MethodIsImplemented(TComponent, 'InheritsFrom'), aText + '.InheritsFrom method is not implemented in TComponent class.');
  // TPersistent's methods are!
  Assert.IsTrue(TPlRTTIUtils.MethodIsImplemented(TComponent, 'GetNamePath'), 'GetNamePath method is not implemented in TComponent class.');
end;

procedure TTestTPlRTTIUtils.TestOrdinalToEnumeration;
var
  TypeInfo: TRttiType;
  Value: TValue;
begin
  TypeInfo := TRttiContext.Create.GetType(System.TypeInfo(TTypeKind));
  Value := TValue.From<Integer>(Ord(tkInteger));
  Assert.AreEqual(TValue.From<TTypeKind>(tkInteger).AsOrdinal,
                  TPlRTTIUtils.OrdinalToEnumeration(TypeInfo, Value).AsOrdinal);
end;

procedure TTestTPlRTTIUtils.TestTryExtractNode;
var
  Field: TRTTIField;
  Prop: TRttiProperty;
  IndexedProp: TRttiIndexedProperty;
  NodeName: string;
begin
  NodeName := 'Name';
  Assert.IsTrue(TPlRTTIUtils.TryExtractNode(FSampleComponent, Field, Prop, IndexedProp, NodeName));
end;

initialization
  TDUnitX.RegisterTestFixture(TTestTPlRTTIUtils);

end.

