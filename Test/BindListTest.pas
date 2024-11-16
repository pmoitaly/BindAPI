unit BindListTest;

interface

uses
  DUnitX.TestFramework,
  System.Generics.Collections,
  BindAPITestClasses,
  plBindAPI.BindingElement;

type
  [TestFixture]
  TTestTPlBindList = class
  private
    FBindList: TPlBindList;
    FSource1, FSource2: TTestClassSource;
    FKey1, FKey2, FKey3: TPlBindElementData;
    FList1: TPlBindElementsList;
  public
    [Setup]
    procedure Setup;
    [Teardown]
    procedure Teardown;

    /// <summary>
    ///   Check if the items are correctly disabled.
    /// </summary>
    [Test]
    procedure TestDisableElement;

    /// <summary>
    ///   Check if the items are correctly enabled.
    /// </summary>
    [Test]
    procedure TestEnableElement;

    /// <summary>
    ///   Check that methods return the correct keys for a given object.
    /// </summary>
    [Test]
    procedure TestFindKeys;

    /// <summary>
    ///   Check that methods return the first key for a given object.
    /// </summary>
    [Test]
    procedure TestFindKey;

    /// <summary>
    ///   Make sure the method finds the correct value associated with a key.
    /// </summary>
    [Test]
    procedure TestFindValue;
  end;

implementation

procedure TTestTPlBindList.Setup;
begin
  FBindList := TPlBindList.Create([doOwnsKeys, doOwnsValues]);

  // Oggetti per i test
  FSource1 := TTestClassSource.Create(2,'Source 1', 3.14);
  FSource2 := TTestClassSource.Create(37,'Source 2', 2.72);

  // Crea chiavi e liste
  FKey1 := TPlBindElementData.Create(FSource1, 'StrPropOut');
  FKey2 := TPlBindElementData.Create(FSource2, 'StrPropIn');
  FList1 := TPlBindElementsList.Create;

  // Aggiungi elementi al dizionario
  FBindList.Add(FKey1, FList1);
  FBindList.Add(FKey2, TPlBindElementsList.Create);
end;

procedure TTestTPlBindList.Teardown;
begin
  FBindList.Free;
end;

procedure TTestTPlBindList.TestDisableElement;
begin
  FBindList.DisableElement(FSource1, 'StrPropOut');
  Assert.IsFalse(FKey1.Enabled, 'Element should be disabled');
end;

procedure TTestTPlBindList.TestEnableElement;
begin
  FBindList.DisableElement(FSource1, 'StrPropOut');
  FBindList.EnableElement(FSource1, 'StrPropOut');
  Assert.IsTrue(FKey1.Enabled, 'Element should be enabled');
end;

procedure TTestTPlBindList.TestFindKeys;
var
  Keys: TPlBindElementsArray;
begin
  Keys := FBindList.FindKeys(FSource1);
  Assert.AreEqual(1, Length(Keys), 'Should find exactly one key for Source1');
  Assert.AreSame(FKey1, Keys[0], 'Found key should match Key1');
end;

procedure TTestTPlBindList.TestFindKey;
var
  Key: TPlBindElementData;
begin
  Key := FBindList.FindKey(FSource1, 'StrPropOut');
  Assert.IsNotNull(Key, 'Should find a key for Source1 and StrPropOut');
  Assert.AreSame(FKey1, Key, 'Found key should match Key1');
end;

procedure TTestTPlBindList.TestFindValue;
var
  FoundValue: TPlBindElementData;
begin
  FKey3 := TPlBindElementData.Create(FSource1, 'StrPropOut');
  FList1.Add(FKey3);
  FoundValue := FBindList.FindValue(FKey1, FSource1);
  Assert.IsNotNull(FoundValue, 'Should find value for Key3 and Source1');
  Assert.AreSame(FKey3, FoundValue, 'Found value should match Key3');
  Assert.AreNotSame(FKey1, FoundValue, 'Found value should not match Key1');
end;

end.

