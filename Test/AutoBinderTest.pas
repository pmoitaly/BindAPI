{*****************************************************************************}
{BindAPI                                                                      }
{Copyright (C) 2020 Paolo Morandotti                                          }
{Unit AutobinderTest                                                    }
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
unit AutoBinderTest;

interface

uses
  DUnitX.TestFramework,
  plBindAPI.AutoBinder,
  Classes, SysUtils,
  BindAPITestClasses;

type

  [TestFixture]
  TPlAutoBinderTests = class
  private
    FAutoBinder: TPlAutoBinder;
    FSourceObject: TTestClassSource;
    FTargetObject: TTestClassTarget;
    FSecondTarget: TTestClassC;
  public
    [Setup]
    procedure Setup; // Inizializza le risorse prima di ogni test

    [TearDown]
    procedure TearDown; // Libera le risorse dopo ogni test

    [Test]
    procedure TestBindObject_WithValidAttributes;

    [Test]
    procedure TestCreate; // Testa la creazione dell'oggetto

    [Test]
    procedure TestBind; // Testa il binding tra oggetti

    [Test]
    procedure TestUnbindSource; // Testa l'unbinding tra oggetti

    [Test]
    procedure TestUnbindTarget; // Testa l'unbinding tra oggetti

    [Test]
    procedure TestUnbindTarget2; // Testa l'unbinding tra oggetti

    [Test]
    procedure TestBindInfo;  // Testa l'ottenimento delle informazioni sul binding

    [Test]
    procedure TestBindInfoCreation; // Testa l'ottenimento delle informazioni sul binding

    [Test]
    procedure TestBind_WithInvalidAttributes;

    [Test]
    procedure TestErrorList; // Testa la gestione degli errori

    [Test]
    procedure TestUpdateValues;

    [Test]
    procedure TestEnabledProperty;

    [Test]
    procedure TestIntervalProperty;


  end;

implementation

uses
  plBindAPI.Types, plBindAPI.Attributes, plBindAPI.BindingElement,
  Rtti;

{ TPlAutoBinderTests }

procedure TPlAutoBinderTests.Setup;
begin
  FAutoBinder := TPlAutoBinder.Create;
  { Test classes }
  FSourceObject := TTestClassSource.Create(2, 'Base string', 2.5);
  FTargetObject := TTestClassTarget.Create;
  FSecondTarget := TTestClassC.Create;
end;

procedure TPlAutoBinderTests.TearDown;
begin
  FAutoBinder.Free;
  FTargetObject.Free;
  FSourceObject.Free;
  FSecondTarget.Free;
end;

procedure TPlAutoBinderTests.TestCreate;
begin
  Assert.IsNotNull(FAutoBinder, 'The TPlAutoBinder instance should be created.');
end;

procedure TPlAutoBinderTests.TestBind;
begin

  // integer binding
  FAutoBinder.Bind(FSourceObject, 'IntPropOut', FTargetObject,
    'intTarget', nil);

  // Verifica lo stato dopo il binding
  Assert.AreEqual(1, FAutoBinder.Count,
    'There should be 1 binding after binding.');
  Assert.AreEqual(FTargetObject.intTarget, FSourceObject.IntPropOut,
    'Bound properties are different.');

end;

procedure TPlAutoBinderTests.TestUnbindSource;
begin

  // Execute binding
  FAutoBinder.Bind(FSourceObject, 'IntPropOut', FTargetObject,
    'intTarget', nil);

  // Execute unbinding
  FAutoBinder.UnbindSource(FSourceObject);

  // Verify the count after the unbinding
  Assert.AreEqual(0, FAutoBinder.Count,
    'There should be 0 bindings after Source unbinding.');
end;

procedure TPlAutoBinderTests.TestUnbindTarget;
begin

  // Execute binding
  FAutoBinder.Bind(FSourceObject, 'IntPropOut', FTargetObject,
    'intTarget', nil);

  // Execute unbinding
  FAutoBinder.UnbindTarget(FTargetObject);

  // Verify the count after the unbinding
  Assert.AreEqual(0, FAutoBinder.Count,
    'There should be 0 bindings after Target unbinding.');

end;

procedure TPlAutoBinderTests.TestUnbindTarget2;
begin
  // Execute binding
  FAutoBinder.Bind(FSourceObject, 'IntPropOut', FTargetObject,
    'intTarget', nil);
  FAutoBinder.Bind(FSourceObject, 'IntPropOut', FSecondTarget, 'intProp', nil);

  // Execute unbinding
  FAutoBinder.UnbindTarget(FTargetObject, FSourceObject);
  // Verify the count after the unbinding
  Assert.AreEqual(1, FAutoBinder.Count,
    'There should be 1 bindings after 1st Target unbinding.');
  // Execute unbinding
  FAutoBinder.UnbindTarget(FSecondTarget, FSourceObject);
  // Verify the count after the unbinding
  Assert.AreEqual(0, FAutoBinder.Count,
    'There should be 0 bindings after 2nd Target unbinding.');

end;

procedure TPlAutoBinderTests.TestBindInfo;
var
  BindList: TPlBindList;
begin
  FAutoBinder.Bind(FSourceObject, 'IntPropOut', FTargetObject, 'intTarget', nil);
  FAutoBinder.Bind(FSourceObject, 'IntPropOut', FSecondTarget, 'intProp', nil);

  // Testa l'ottenimento delle informazioni di binding
  BindList := FAutoBinder.BindInfo;
  try
  Assert.AreEqual(1, FAutoBinder.BindInfo.Count,
    'There should be 1 bindings after 2nd Target unbinding.');
  finally
    BindList.Free;
  end;
end;

procedure TPlAutoBinderTests.TestBindInfoCreation;
var
  BindList: TPlBindList;
begin
  // Testa l'ottenimento delle informazioni di binding
  BindList := FAutoBinder.BindInfo;
  try
    // Verifica che la lista di binding non sia nulla
    Assert.IsNotNull(BindList, 'The bind information list should not be null.');
  finally
    BindList.Free;
  end;
end;

procedure TPlAutoBinderTests.TestBindObject_WithValidAttributes;
var
  classAttribute: BindClassAttribute;
  myrec: TTestRecord;
begin
  FSourceObject.DblPropOut := 2.5;
  FSourceObject.intPropOut := 2;
  myrec.Name := 'Pippo';
  myrec.Age := 26;
  FSourceObject.RecPropOut := myRec;
  FSourceObject.StrPropOut := 'Test string';
  FSourceObject.ObjPropOut.Age := 22;
  FSourceObject.ObjPropOut.Name := 'Topolino';

  classAttribute := BindClassAttribute.Create(True, 'TTestClassTarget','', True);
  try
    FAutoBinder.BindObject(FSourceObject, FTargetObject, classAttribute);
  finally
    classAttribute.Free;
  end;
  Assert.IsTrue(FAutoBinder.Count > 0, 'Class-level binding should have been created.');
  Assert.IsTrue(FAutoBinder.ErrorList.Count = 0, 'No errors should have been registered.' + chr(13) + FAutoBinder.ErrorList.Text);
  Assert.AreEqual(FSourceObject.DblPropOut, FTargetObject.dblTarget, 'DblPropOut did not propagate its value.');
  Assert.AreEqual(FSourceObject.intPropOut, FTargetObject.intTarget, 'intPropOut did not propagate its value.');
  Assert.AreEqual(FSourceObject.intPropOut * 3, FTargetObject.intTarget3, 'intPropOut did not multiplicate its value.');
  Assert.AreSame(FSourceObject.BridgeObjPropOut, FTargetObject.BridgeObjTarget, 'BridgeObjPropOut did not propagate its value.');
  Assert.AreEqual(FSourceObject.RecPropOut, FTargetObject.RecTarget, 'RecPropOut did not propagate its value.');
  Assert.AreEqual(FSourceObject.StrPropOut, FTargetObject.StrTarget, 'StrPropOut did not propagate its value.');
  Assert.AreEqual(FTargetObject.dblTarget, FSourceObject.DblPropIn, 'DblPropIn did not receive the correct value.');
  Assert.AreEqual(Double(FTargetObject.dblTarget * 2.0), FSourceObject.DblPropIn2, 'DblPropIn did not receive the correct double value.');
  Assert.AreEqual(FTargetObject.intTarget, FSourceObject.IntPropIn, 'IntPropIn did not receive the correct value.');
  Assert.AreEqual(FTargetObject.intTarget * 2, FSourceObject.IntPropIn2, 'IntPropIn did not receive the correct double value.');
  Assert.AreEqual(FTargetObject.intTarget * 3, FSourceObject.IntPropIn3, 'IntPropIn did not receive the correct triple value.');
  Assert.AreEqual(FTargetObject.ObjTarget.Age, FSourceObject.ObjPropIn.Age, 'ObjPropIn.Age did not receive the correct value.');
  Assert.AreSame(FTargetObject.BridgeObjTarget, FSourceObject.BridgeObjPropIn, 'BridgeObjTarget did not propagate its value.');
  Assert.AreEqual(FTargetObject.RecTarget, FSourceObject.RecPropIn, 'RecTarget did not propagate its value.');
  Assert.AreEqual(FTargetObject.StrTarget, FSourceObject.StrPropIn, 'True did not propagate its value.');
  Assert.AreEqual(FTargetObject.ObjTarget.Strings.Strings[0], FSourceObject.FirstString, '.ObjTarget.Strings.Strings[0] did not propagate its value.');

end;

procedure TPlAutoBinderTests.TestBind_WithInvalidAttributes;
begin
  FAutoBinder.Bind(FSourceObject, 'IntPropOut', FTargetObject, 'none', nil);

  // Verify the count after the unbinding
  Assert.AreEqual(0, FAutoBinder.Count,
    'There should be 0 bindings after a failed binding.');
end;

procedure TPlAutoBinderTests.TestErrorList;
var
  ErrorList: TStrings;
begin
  // Ottieni la lista di errori
  ErrorList := FAutoBinder.ErrorList;
  Assert.IsNotNull(ErrorList, 'ErrorList should not be nil.');
  Assert.AreEqual(0, ErrorList.Count, 'ErrorList should initially be empty.');

  // Esegui un'operazione che genera un errore di binding
  FAutoBinder.Bind(FSourceObject, 'IntPropOut', FTargetObject, 'none', nil); // Codice per generare un errore


  // Verifica che la lista di errori non sia vuota
  Assert.AreEqual(1, ErrorList.Count,
    'Error list should contain errors after a failed binding operation.');

end;

procedure TPlAutoBinderTests.TestUpdateValues;
begin
  FSourceObject.IntPropOut := 2;
  FAutoBinder.Bind(FSourceObject, 'IntPropOut', FTargetObject, 'intTarget', nil);
  Assert.AreEqual(2, FTargetObject.intTarget, 'TargetObject.intTarget should be 2.');
  FSourceObject.IntPropOut := 4;

  FAutoBinder.UpdateValues;
  // Ensure no exceptions are raised
  Assert.Pass('UpdateValues executed without exceptions.');
  Assert.AreEqual(4, FTargetObject.intTarget, 'TargetObject.intTarget should be 4.');

end;

procedure TPlAutoBinderTests.TestEnabledProperty;
begin
  FAutoBinder.Enabled := True;
  Assert.IsTrue(FAutoBinder.Enabled, 'Enabled property should be True.');
  FAutoBinder.Enabled := False;
  Assert.IsFalse(FAutoBinder.Enabled, 'Enabled property should be False.');
  FAutoBinder.Enabled := True;
  Assert.IsTrue(FAutoBinder.Enabled, 'Enabled property should be True again.');
end;

procedure TPlAutoBinderTests.TestIntervalProperty;
begin
  FAutoBinder.Interval := 500;
  Assert.AreEqual(500, FAutoBinder.Interval, 'Interval property should reflect the set value.');
  FAutoBinder.Interval := 100;
  Assert.AreEqual(100, FAutoBinder.Interval, 'Interval property should reflect the set value.');
end;
initialization

TDUnitX.RegisterTestFixture(TPlAutoBinderTests);

end.
