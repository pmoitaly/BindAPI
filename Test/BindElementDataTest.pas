{*****************************************************************************}
{BindAPI                                                                      }
{Copyright (C) 2020 Paolo Morandotti                                          }
{Unit BindElementDataTest                                                     }
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
unit BindElementDataTest;

interface

uses
  DUnitX.TestFramework,
  System.Rtti,
  System.SysUtils,
  BindAPITestClasses,  PlBindAPI.BindingElement;

type
  [TestFixture('TPlBindElementData')]
  TTestPlBindElementData = class
  private
    FTestObject: TTestClassTarget;
    FBindElement: TPlBindElementData;
    FBindElementExt: TPlBindElementData;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    /// <summary>
    /// Tests the creation of TPlBindElementData and its default values.
    /// </summary>
    [Test]
    procedure TestCreate;

    /// <summary>
    /// Tests the creation of TPlBindElementData with wrong member name.
    /// </summary>
    [Test]
    procedure TestCreateException;

    /// <summary>
    /// Tests the SetValue method and checks if the value is properly updated.
    /// </summary>
    [Test]
    procedure TestSetValue;

    /// <summary>
    /// Tests the ValueChanged method to ensure it detects changes correctly.
    /// </summary>
    [Test]
    procedure TestValueChanged;

    /// <summary>
    /// Tests the IsEqualTo method to verify correct comparison behavior.
    /// </summary>
    [Test]
    procedure TestIsEqualTo;

    /// <summary>
    /// Tests the behaviour of the bridge function.
    /// </summary>
    [Test]
    procedure TestBridgeFunction;
  end;

implementation


{ TTestPlBindElementData }

procedure TTestPlBindElementData.Setup;
begin
  FTestObject := TTestClassTarget.Create;
  FBindElement := TPlBindElementData.Create(FTestObject, 'IntTarget');
  FBindElementExt := TPlBindElementData.Create(FTestObject, 'IntTarget', FTestObject.DoubleOf);
end;

procedure TTestPlBindElementData.TearDown;
begin
  FBindElement.Free;
  FBindElementExt.Free;
  FTestObject.Free;
end;

procedure TTestPlBindElementData.TestBridgeFunction;
begin
  FTestObject.IntTarget := 2;
  Assert.IsTrue(FBindElementExt.ValueChanged, 'Value of FBindElementExt did not change.');
  Assert.AreEqual(2, FBindElementExt.Value.AsInteger, 'Bridge function operates on element''s Value.');
end;

procedure TTestPlBindElementData.TestCreate;
begin
  // Verify that the object is created and has default values
  Assert.IsNotNull(FBindElement, 'FBindElement should not be nil');
  Assert.AreEqual('IntTarget', FBindElement.PropertyPath, 'PropertyPath should match the initialization value');
  Assert.IsTrue(FBindElement.Enabled, 'Default value of Enabled should be true');
end;

procedure TTestPlBindElementData.TestCreateException;
begin
  Assert.WillRaise(
    procedure
    begin
      TPlBindElementData.Create(FTestObject, 'NoProp');
    end,
    Exception,
    'Expected exception was not raised for empty property path.'
  );
end;

procedure TTestPlBindElementData.TestSetValue;
var
  NewValue: TValue;
begin
  // Set a new value and check if it's correctly updated
  NewValue := TValue.From<Integer>(42);
  FBindElement.Value := NewValue;

  Assert.AreEqual(NewValue, FBindElement.Value, 'Value should be updated to 42');
end;

procedure TTestPlBindElementData.TestValueChanged;
begin

  // Initially, ValueChanged should return False
  Assert.IsFalse(FBindElement.ValueChanged, 'ValueChanged should return false for the initial value');

  // Set a new value
  FTestObject.IntTarget := 42;

  // Now, ValueChanged should return True
  Assert.IsTrue(FBindElement.ValueChanged, 'ValueChanged should return true after setting a new value');
end;

procedure TTestPlBindElementData.TestIsEqualTo;
var
  AnotherBindElement: TPlBindElementData;
begin
  AnotherBindElement := TPlBindElementData.Create(FTestObject, 'IntTarget');
  try
    // Two instances with the same object and path should be equal
    Assert.IsTrue(FBindElement.IsEqualTo(AnotherBindElement), 'Two instances with the same data should be equal');

    // Change the property path in AnotherBindElement
    AnotherBindElement := TPlBindElementData.Create(FTestObject, 'StrTarget');

    Assert.IsFalse(FBindElement.IsEqualTo(AnotherBindElement), 'Instances with different paths should not be equal');
  finally
    AnotherBindElement.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestPlBindElementData);

end.
