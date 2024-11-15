{*****************************************************************************}
{BindAPI                                                                      }
{Copyright (C) 2020 Paolo Morandotti                                          }
{Unit ClassManagerTest                                                        }
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
unit ClassManagerTest;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  plBindAPI.ClassFactory,
  plBindAPI.Types;

type
  [TestFixture]
  TTestPlClassManager = class
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    /// <summary>
    ///   Ensures a class can be registered and checked.
    /// </summary>
    [Test(True)]
    procedure TestRegisterClass;

    /// <summary>
    ///   Tests registration with additional creation parameters.
    /// </summary>
    [Test(True)]
    procedure TestRegisterClassWithParams;

    /// <summary>
    ///   Ensures non-singleton registration creates new instances.
    /// </summary>
    [Test(True)]
    procedure TestGetInstance_NewInstance;

    /// <summary>
    ///   Verifies singleton behavior.
    /// </summary>
    [Test(True)]
    procedure TestGetInstance_Singleton;

    /// <summary>
    ///   Confirms correct registration status.
    /// </summary>
    [Test(True)]
    procedure TestIsRegistered;

    /// <summary>
    ///   Verify singleton state by class name.
    /// </summary>
    [Test(True)]
    procedure TestIsSingleton_ByName;

    /// <summary>
    ///   Verify singleton state by instance.
    /// </summary>
    [Test(True)]
    procedure TestIsSingleton_ByInstance;

    /// <summary>
    ///   Tests instance unregistering.
    /// </summary>
    [Test(True)]
    procedure TestUnregisterInstance;

    /// <summary>
    ///   Validates the registered class list.
    /// </summary>
    [Test(True)]
    procedure TestRegisteredClasses;
  end;

implementation

uses
  System.Classes; // For TObject derivatives used in testing

procedure TTestPlClassManager.Setup;
begin
  // Setup code, initialize any required state
end;

procedure TTestPlClassManager.TearDown;
begin
  // Cleanup code, if necessary
  TPlClassManager.Clear;
end;

procedure TTestPlClassManager.TestRegisterClass;
begin
  TPlClassManager.Clear;
  TPlClassManager.RegisterClass(TObject, [Singleton]);
  Assert.IsTrue(TPlClassManager.IsRegistered('TObject'), 'TObject should be registered');
end;

procedure TTestPlClassManager.TestRegisterClassWithParams;
var
  Params: TPlCreateParams;
begin
  Params := [];
  TPlClassManager.Clear;
  TPlClassManager.RegisterClass(TObject, [Singleton], Params);
  Assert.IsTrue(TPlClassManager.IsRegistered('TObject'), 'TObject with params should be registered');
end;

procedure TTestPlClassManager.TestGetInstance_NewInstance;
var
  Obj1, Obj2: TObject;
begin
  TPlClassManager.Clear;
  TPlClassManager.RegisterClass(TObject, []);
  Obj1 := TPlClassManager.GetInstance('TObject');
  Obj2 := TPlClassManager.GetInstance('TObject');
  try
    Assert.AreNotSame(Obj1, Obj2, 'Each call should return a new instance');
  finally
    Obj1.Free;
    Obj2.Free;
  end;
end;

procedure TTestPlClassManager.TestGetInstance_Singleton;
var
  Obj1, Obj2: TObject;
begin
  TPlClassManager.Clear;
  TPlClassManager.RegisterClass(TObject, [Singleton]);
  Obj1 := TPlClassManager.GetInstance('TObject');
  Obj2 := TPlClassManager.GetInstance('TObject');
  Assert.AreSame(Obj1, Obj2, 'Both calls should return the same singleton instance');
  // If singleton, do not free the classes.
end;

procedure TTestPlClassManager.TestIsRegistered;
begin
  TPlClassManager.Clear;
  TPlClassManager.RegisterClass(TObject, []);
  Assert.IsTrue(TPlClassManager.IsRegistered('TObject'), 'TObject should be registered');
  Assert.IsFalse(TPlClassManager.IsRegistered('TNonExistent'), 'TNonExistent should not be registered');
end;

procedure TTestPlClassManager.TestIsSingleton_ByName;
begin
  TPlClassManager.Clear;
  TPlClassManager.RegisterClass(TObject, [Singleton]);
  Assert.IsTrue(TPlClassManager.IsSingleton('TObject'), 'TObject should be a singleton');
  Assert.IsFalse(TPlClassManager.IsSingleton('TNonExistent'), 'TNonExistent should not be a singleton');
end;

procedure TTestPlClassManager.TestIsSingleton_ByInstance;
var
  Obj: TObject;
begin
  TPlClassManager.Clear;
  TPlClassManager.RegisterClass(TObject, [Singleton]);
  Obj := TPlClassManager.GetInstance('TObject');
  Assert.IsTrue(TPlClassManager.IsSingleton(Obj), 'Instance should be recognized as a singleton');
end;

procedure TTestPlClassManager.TestUnregisterInstance;
var
  Obj: TObject;
begin
  Obj := TObject.Create;
    TPlClassManager.Clear;
    TPlClassManager.RegisterInstance(Obj);
    Assert.IsTrue(TPlClassManager.IsSingleton(Obj), 'Instance should be registered');
    TPlClassManager.UnregisterInstance(Obj);
    Assert.IsFalse(TPlClassManager.IsSingleton(Obj), 'Instance should be unregistered');
end;

procedure TTestPlClassManager.TestRegisteredClasses;
var
  Classes: TPlClassList;
begin
  TPlClassManager.Clear;
  TPlClassManager.RegisterClass(TObject, []);
  Classes := TPlClassManager.RegisteredClasses;
  try
    Assert.IsTrue(Classes.ContainsKey('TObject'), 'RegisteredClasses should include TObject');
  finally
    Classes.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestPlClassManager);

end.
