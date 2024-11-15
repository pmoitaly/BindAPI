{*****************************************************************************}
{BindAPI                                                                      }
{Copyright (C) 2020 Paolo Morandotti                                          }
{Unit DeferredBindTest                                                        }
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
unit DeferredBindTest;

interface

uses
  DUnitX.TestFramework, System.Generics.Collections, System.SysUtils,
  plBindAPI.Attributes,
  BindAPITestClasses,
  PlBindAPI.DeferredBinding;

type
  [TestFixture]
  TTestPlDeferredBinding = class
  private
    FDeferredElement: TPlDeferredElement;
    FSourceObject: TTestClassSource;
    FCreateAttribute: BindClassAttribute;
  public
    [Setup]
    procedure Setup;
    [Teardown]
    procedure Teardown;

    [Test]
    /// <summary>
    ///   Make sure that adding an object to the deferred list returns the same item.
    /// </summary>
    procedure TestAddObject;

    [Test]
    /// <summary>
    ///   Make sure that adding a deferred item to preserve the data.
    /// </summary>
    procedure TestAddDeferredElement;

    [Test]
    /// <summary>
    /// Make sure Clear's call to empty the deferred list.
    /// </summary>
    procedure TestClear;

    [Test]
    /// <summary>
    /// Make sure Count functions returns the correct value.
    /// </summary>
    procedure TestCount;

    [Test]
    /// <summary>
    /// Verify that TestDeferred is working without errors.
    /// Memo: Add specific controls if this function changes the status.
    /// </summary>
    procedure TestDeferredProcessing;
  end;

implementation

{ TTestPlDeferredBinding }

procedure TTestPlDeferredBinding.Setup;
begin
  FSourceObject := TTestClassSource.Create(5,'Test', 3.14);
  FCreateAttribute := BindClassAttribute.Create('AClassName');
  // Initialize a sample deferred element
  FDeferredElement.Attribute := FCreateAttribute; // Replace with actual attribute type if available
  FDeferredElement.Source := FSourceObject;

  // Ensure the deferred list is cleared before each test
  TPlDeferredBinding.Clear;
end;

procedure TTestPlDeferredBinding.Teardown;
begin
  TPlDeferredBinding.Clear;
  FSourceObject.Free;
  FCreateAttribute.Free;
end;

procedure TTestPlDeferredBinding.TestAddObject;
var
  ResultObject: TObject;
begin
  ResultObject := TPlDeferredBinding.Add(FSourceObject);
  Assert.AreSame(FSourceObject, ResultObject, 'The added source object should match the returned object.');
end;

procedure TTestPlDeferredBinding.TestAddDeferredElement;
var
  AddedElement: TPlDeferredElement;
begin
  AddedElement := TPlDeferredBinding.Add(FDeferredElement);
  Assert.AreEqual(FDeferredElement.Source, AddedElement.Source, 'The added element should have the same source object.');
end;

procedure TTestPlDeferredBinding.TestClear;
begin
  TPlDeferredBinding.Add(FSourceObject);
  Assert.AreEqual(1, TPlDeferredBinding.Count, 'The deferred list should not be empty after calling Clear.');
  TPlDeferredBinding.Clear;

  Assert.AreEqual(0, TPlDeferredBinding.Count, 'The deferred list should be empty after calling Clear.');
end;

procedure TTestPlDeferredBinding.TestCount;
begin
  TPlDeferredBinding.Add(FSourceObject);
  Assert.AreEqual(1, TPlDeferredBinding.Count, 'The deferred list should not be empty after calling Clear.');
end;

procedure TTestPlDeferredBinding.TestDeferredProcessing;
var
  localObject: TTestClassSource;
begin
  localObject := TTestClassSource.Create(12,'local', 22.3);
  try
// Testing the method with an object covers the case of calling the method
// with an attribute as parameter, so it is not necessary to use
//  TPlDeferredBinding.Add(FDeferredElement);
  TPlDeferredBinding.Add(localObject);

  // This method should process or handle deferred elements. Replace with specific checks if TestDeferred has observable effects.
  TPlDeferredBinding.ProcessDeferred;
  Assert.Pass('TestDeferred executed without exceptions.');
  finally
//    localObject.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestPlDeferredBinding);

end.

