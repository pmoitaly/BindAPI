{*****************************************************************************}
{BindAPI                                                                      }
{Copyright (C) 2020 Paolo Morandotti                                          }
{Unit BindManagerTest                                                         }
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
unit BindManagerTest;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.Classes,
  BindAPITestClasses,
  PlBindAPI.BindManagement,
  plBindAPI.Types,
  PlBindAPI.AutoBinder,   // For TPlAutoBinder
  PlBindAPI.Attributes; // For BindClassAttribute

type
  [TestFixture]
  TTestPlBindManager = class
  private
    FSourceObject: TTestClassSource;
    FTargetObject: TTestClassTarget;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    /// <summary>
    /// Tests the AddBind method with valid inputs.
    /// </summary>
    [Test]
    procedure TestAddBindValid;

    /// <summary>
    /// Tests the AddBind method with invalid inputs and ensures an exception is raised.
    /// </summary>
    [Test]
    procedure TestAddBindInvalid;

    /// <summary>
    /// Tests the AddDeferredBind method.
    /// </summary>
    [Test]
    procedure TestAddDeferredBind;

    /// <summary>
    /// Tests the Bind method to ensure the object is properly bound.
    /// </summary>
    [Test]
    procedure TestBind;

    /// <summary>
    /// Tests the Unbind method to ensure the object is properly unbound.
    /// </summary>
    [Test]
    procedure TestUnbind;

    /// <summary>
    /// Tests the ErrorList method to verify it retrieves binding errors.
    /// </summary>
    [Test]
    procedure TestErrorList;

    /// <summary>
    /// Tests the Interval property for getting and setting the interval.
    /// </summary>
    [Test]
    procedure TestIntervalProperty;
  end;

implementation

uses
  plBindAPI.ClassFactory;

procedure TTestPlBindManager.Setup;
begin
  // Initialize test objects before each test
  FSourceObject := TTestClassSource.Create(2, 'Test String', 2.5);
  FTargetObject := TTestClassTarget.Create;
end;

procedure TTestPlBindManager.TearDown;
begin
  // Free the test objects after each test
  FSourceObject.Free;
  FTargetObject.Free;
end;

procedure TTestPlBindManager.TestAddBindValid;
var
  Attribute: BindClassAttribute;
begin
  TPlClassManager.RegisterClass(TTestClassTarget, [Singleton], []);
  Attribute := BindClassAttribute.Create('TTestClassTarget');
  try
    Assert.IsTrue(TPlBindManager.AddBinding(FSourceObject, Attribute), 'AddBind should return true for valid inputs.');
  finally
    Attribute.Free;
  end;
end;

procedure TTestPlBindManager.TestAddBindInvalid;
begin
  Assert.WillRaise(
    procedure
    begin
      TPlBindManager.AddBinding(nil, nil);
    end,
    EPlBindApiException,
    'AddBind should raise EArgumentException for invalid inputs.'
  );
end;

procedure TTestPlBindManager.TestAddDeferredBind;
begin
  Assert.IsTrue(TPlBindManager.AddDeferredBinding(FTargetObject), 'AddDeferredBind should return true for valid input.');
end;

procedure TTestPlBindManager.TestBind;
begin
  // Test the binding process
  Assert.WillNotRaiseAny(
    procedure
    begin
      TPlBindManager.Bind(FTargetObject);
    end,
    'Bind should not raise any exceptions for valid input.'
  );
end;

procedure TTestPlBindManager.TestUnbind;
begin
  // Test the unbinding process
  Assert.WillNotRaiseAny(
    procedure
    begin
      TPlBindManager.Unbind(FTargetObject);
    end,
    'Unbind should not raise any exceptions for valid input.'
  );
end;

procedure TTestPlBindManager.TestErrorList;
begin
    // Assuming no errors are present initially
    Assert.AreEqual('', TPlBindManager.ErrorList, 'ErrorList should be empty initially.');
end;

procedure TTestPlBindManager.TestIntervalProperty;
const
  TestInterval = 5000; // 5 seconds
begin
  TPlBindManager.Interval := TestInterval;
  Assert.AreEqual(TestInterval, TPlBindManager.Interval, 'Interval property should reflect the set value.');
end;

initialization
  TDUnitX.RegisterTestFixture(TTestPlBindManager);

end.
