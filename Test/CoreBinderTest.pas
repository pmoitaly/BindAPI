{*****************************************************************************}
{BindAPI                                                                      }
{Copyright (C) 2020 Paolo Morandotti                                          }
{Unit CoreBinder Test                                                         }
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
unit CoreBinderTest;

interface

uses
  Classes,
  DUnitX.TestFramework,
  Vcl.StdCtrls,
  plBindAPI.CoreBinder,
  BindAPITestClasses;

type

  [TestFixture]
  TPlBindManagerTest = class(TObject)
  private
    FBinder: TPlBinder;
    FSourceClass: TTestClassSource;
    FTargetClass: TTestClassTarget;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    // standard test
    [Test]
    procedure TestCreate_Destroy;

    [Test]
    procedure TestEnabledProperty;

    [Test]
    procedure TestBindErrorListProperty;

    [Test]
    procedure TestNormalizePath_ValidPath;

    [Test]
    procedure TestNormalizePath_InvalidPath;

    [Test]
    procedure TestBind_AddsBinding;

    [Test]
    procedure TestUnbindTarget_RemovesBinding;

    [Test]
    procedure TestClear_RemovesAllBindings;

    [Test]
    procedure TestCount_ReturnsCorrectCount;

    [Test(True)]
    [TestCase(
      'Test Reading Number form an IndexedProperty using enumerated', '')]
    procedure TestReadNumbers;
    [Test(True)]
    [TestCase('Test Reading Number form a StringList', '0')]
    [TestCase('Test Reading Strings form a StringList', '1')]
    [TestCase('Test Reading Strings form a StringList', '2')]
    [TestCase('Test Reading Strings form a StringList', '3')]
    procedure TestReadStrings(AIndex: integer);
    // Test properties binding
    [Test(True)]
    [TestCase('Test On Properties', '2, Pippo, 3.6')]
    [TestCase('Test On Properties', '3, Topolino, 0.8')]
    procedure TestBindProperty(const AnInt: integer; const AStr: string;
      const ADbl: Double);
    // Test fields binding
    [Test(True)]
    [TestCase('Test On Record Field', '2, Pippo, 3.6')]
    procedure TestBindRecordField(const AnInt: integer; const AStr: string;
      const ADbl: Double);
    [Test(True)]
    [TestCase('Test On Object Field', '3, Pippo, 12')]
    procedure TestBindFieldProperty(const AnInt: integer; const AStr: string;
      const ADbl: Double);
    // Test property as objects
    [Test(True)]
    [TestCase('Test On Object Property', '3, Pippo, 12')]
    procedure TestBindObjectProperty(const AnInt: integer; const AStr: string;
      const ADbl: Double);
    // Test event binding
    [Test(True)]
    [TestCase('Test On Event binding for BindMethod', '2, Pippo, 3.6')]
    procedure TestBindEvent(const AnInt: integer; const AStr: string;
      const ADbl: Double);
    [Test(True)]
    [TestCase('Test for BindMethod method', '2, Pippo, 3.6')]
    procedure TestDirectBindEvent(const AnInt: integer; const AStr: string;
      const ADbl: Double);
    // General Test
    [Test(True)]
    [TestCase('Test On Start and Stop', '2, Pippo, 3.6')]
    procedure TestUpdateValues(const AnInt: integer; const AStr: string;
      const ADbl: Double);

  end;

implementation

uses
  System.SysUtils;

procedure TPlBindManagerTest.Setup;
begin
  FBinder := TPlBinder.Create;
  FTargetClass := TTestClassTarget.Create;
end;

procedure TPlBindManagerTest.TearDown;
begin
  FBinder.Free;
  // Free classes
  FSourceClass.Free;
  FTargetClass.Free;
end;

procedure TPlBindManagerTest.TestCreate_Destroy;
begin
  Assert.IsNotNull(FBinder, 'FBinder should be created successfully');
end;

procedure TPlBindManagerTest.TestEnabledProperty;
begin
  FBinder.Enabled := True;
  Assert.IsTrue(FBinder.Enabled, 'Enabled should be True after setting');

  FBinder.Enabled := False;
  Assert.IsFalse(FBinder.Enabled, 'Enabled should be False after setting');
end;

procedure TPlBindManagerTest.TestBindErrorListProperty;
var
  TestList: TStrings;
begin
    FBinder.BindErrorList.Add('Error 1');
    Assert.AreEqual(1, FBinder.BindErrorList.Count,
      'BindErrorList count should match');
    Assert.AreEqual('Error 1', FBinder.BindErrorList[0],
      'First error should match');
  // Do not free the TestList here, or you will get a AV when the Binder will try to free it
  // TestList.Free;
end;

procedure TPlBindManagerTest.TestNormalizePath_ValidPath;
var
  TestComponent: TObject;
  Path: string;
  ResultComponent: TObject;
begin
  TestComponent := TComponent.Create(nil);
  try
    Path := 'Name';
    ResultComponent := FBinder.NormalizePath(TestComponent, Path);
    Assert.IsNotNull(ResultComponent, 'Normalized component should not be nil');
    Assert.AreSame(TestComponent, ResultComponent, 'Normalized component should not change');
  finally
    TestComponent.Free;
  end;
end;

procedure TPlBindManagerTest.TestNormalizePath_InvalidPath;
var
  TestComponent: TObject;
  Path: string;
  ResultComponent: TObject;
begin
  TestComponent := TComponent.Create(nil);
  try
    Path := 'InvalidPath';
    ResultComponent := FBinder.NormalizePath(TestComponent, Path);
    Assert.AreSame(ResultComponent, TestComponent,
      'Normalized component should be the same for an invalid path');
  finally
    TestComponent.Free;
  end;
end;

procedure TPlBindManagerTest.TestBind_AddsBinding;
var
  Source, Target: TObject;
  Success: Boolean;
begin
  FSourceClass := TTestClassSource.Create(2, '', 3.5);
  Success := FBinder.Bind(FSourceClass, 'DblPropOut', FTargetClass, 'dblTarget');
  Assert.IsTrue(Success, 'Bind should return True for valid binding');
  Assert.AreEqual(1, FBinder.Count, 'Binding count should increase');
end;

procedure TPlBindManagerTest.TestUnbindTarget_RemovesBinding;
begin
  FSourceClass := TTestClassSource.Create(2, '', 3.5);
  FBinder.Bind(FSourceClass, 'DblPropOut', FTargetClass, 'dblTarget');
    Assert.AreEqual(1, FBinder.Count,
      'Binding count should be 1 after binding');

    FBinder.UnbindTarget(FTargetClass);
    Assert.AreEqual(1, FBinder.Count,
      'Binding count should be 1 after target unbinding');
end;

procedure TPlBindManagerTest.TestClear_RemovesAllBindings;
var
  Source2: TObject;
begin
  FSourceClass := TTestClassSource.Create(2, '', 3.5);
  FBinder.Bind(FSourceClass, 'DblPropOut', FTargetClass, 'dblTarget');
  Source2 := TComponent.Create(nil);
  try
    FBinder.Bind(Source2, 'Tag', FTargetClass, 'intTarget');
    Assert.AreEqual(2, FBinder.Count,
      'Binding count should be 2 after two bindings');

    FBinder.Clear;
    Assert.AreEqual(0, FBinder.Count, 'Binding count should be 0 after Clear');
  finally
    Source2.Free;
  end;
end;

procedure TPlBindManagerTest.TestCount_ReturnsCorrectCount;
begin
  Assert.AreEqual(0, FBinder.Count, 'Initial binding count should be 0');
  FSourceClass := TTestClassSource.Create(2, '', 3.5);
  FBinder.Bind(FSourceClass, 'DblPropOut', FTargetClass, 'dblTarget');
  Assert.AreEqual(1, FBinder.Count,
    'Binding count should be 1 after one binding');
end;

procedure TPlBindManagerTest.TestBindEvent(const AnInt: integer;
  const AStr: string; const ADbl: Double);
begin
  FSourceClass := TTestClassSource.Create(AnInt, AStr, ADbl);
  // Binding
  FBinder.Bind(FTargetClass, 'EventFiredTarget', FSourceClass, 'EventFired');
  FBinder.BindMethod(FSourceClass.btnTest, 'OnClick', FTargetClass,
    'TestEventBind');
  // Test
  FSourceClass.btnTest.Click;
  FBinder.UpdateValues;
  Assert.IsTrue(FSourceClass.EventFired, 'Event not fired');
end;

procedure TPlBindManagerTest.TestBindFieldProperty(const AnInt: integer;
  const AStr: string; const ADbl: Double);
begin
  FSourceClass := TTestClassSource.Create(AnInt, AStr, ADbl);

  // binding
  { TODO 4 -oPMo -cRefactoring :
    Although BindAPI allows this operation, if not carefully managed it causes pointer errors when freeing the instances.
   Consider to automatically bind on each fields. }
  //  binder.Bind(activeClass, 'FObjPropOut', passiveClass, 'FObjTarget');
  FBinder.Bind(FSourceClass, 'FObjPropOut.Age', FTargetClass, 'FObjTarget.Age');
  FBinder.Bind(FSourceClass, 'FObjPropOut.Name', FTargetClass,
    'FObjTarget.Name');
  FBinder.Bind(FTargetClass, 'FObjTarget.Age', FSourceClass, 'FObjPropIn.Age');
  // Test
  with FSourceClass do
    begin
      Assert.AreEqual(AStr + ' (Obj)', FTargetClass.ObjTarget.Name,
        'ObjTarget Name field error');
      Assert.AreEqual('', ObjPropIn.Name, 'Object Name field error');
      Assert.AreEqual(AnInt + 11, ObjPropIn.Age, 'Object Age field error');
    end;
end;

procedure TPlBindManagerTest.TestBindObjectProperty(const AnInt: integer;
  const AStr: string; const ADbl: Double);
begin
  FSourceClass := TTestClassSource.Create(AnInt, AStr, ADbl);

  // binding
  { TODO 4 -oPMo -cRefactoring :
    Although BindAPI allows this operation, if not carefully managed it causes pointer errors when freeing the instances.
   Consider to automatically bind on fields. }
  //  binder.Bind(activeClass, 'ObjPropOut', passiveClass, 'ObjTarget');
  FBinder.Bind(FSourceClass, 'ObjPropOut.Age', FTargetClass, 'ObjTarget.Age');
  FBinder.Bind(FSourceClass, 'ObjPropOut.Name', FTargetClass, 'ObjTarget.Name');
  FBinder.Bind(FTargetClass, 'ObjTarget.Age', FSourceClass, 'ObjPropIn.Age');
  // Test
  with FSourceClass do
    begin
      Assert.AreEqual(AStr + ' (Obj)', FTargetClass.ObjTarget.Name,
        'ObjTarget Name property error');
      Assert.AreEqual('', ObjPropIn.Name, 'Object Name property error');
      Assert.AreEqual(AnInt + 11, ObjPropIn.Age, 'Object Age property error');
    end;
end;

procedure TPlBindManagerTest.TestBindProperty(const AnInt: integer;
  const AStr: string; const ADbl: Double);
var
  dblValue: Double;
begin
  FSourceClass := TTestClassSource.Create(AnInt, AStr, ADbl);
  { TODO 5 -oPMo -cTesting : Add full path test (i.e. propA.propB.propC) }
  // binding
  FBinder.Bind(FSourceClass, 'DblPropOut', FTargetClass, 'DblTarget');
  FBinder.Bind(FSourceClass, 'IntPropOut', FTargetClass, 'intTarget');
  FBinder.Bind(FSourceClass, 'IntPropOut', FTargetClass, 'intTarget3',
    FTargetClass.TripleOf);
  FBinder.Bind(FSourceClass, 'RecPropOut', FTargetClass, 'RecTarget');
  FBinder.Bind(FSourceClass, 'StrPropOut', FTargetClass, 'StrTarget',
    FTargetClass.ToName);
  FBinder.Bind(FTargetClass, 'dblTarget', FSourceClass, 'DblPropIn');
  FBinder.Bind(FTargetClass, 'dblTarget', FSourceClass, 'DblPropIn2',
    FTargetClass.DoubleOf);
  FBinder.Bind(FTargetClass, 'intTarget', FSourceClass, 'IntPropIn');
  FBinder.Bind(FTargetClass, 'intTarget', FSourceClass, 'IntPropIn2',
    FTargetClass.DoubleOf);
  FBinder.Bind(FTargetClass, 'IntTarget3', FSourceClass, 'IntPropIn3');
  FBinder.Bind(FTargetClass, 'RecTarget', FSourceClass, 'RecPropIn');
  FBinder.Bind(FTargetClass, 'StrTarget', FSourceClass, 'StrPropIn');
  // Test
  dblValue := ADbl + ADbl;
  with FSourceClass do
    begin
      Assert.AreEqual(AStr + ' (Rec)', RecPropIn.Name,
        'Record Name property error');
      Assert.AreEqual(AnInt + 1, RecPropIn.Age, 'Record Age property error');
      Assert.AreEqual(DblPropOut, DblPropIn, 'Double property error');
      Assert.AreEqual(AnInt, IntPropIn, 'Integer property error');
      Assert.AreEqual(dblValue, DblPropIn2, 'Double property function error');
      Assert.AreEqual(AnInt * 2, IntPropIn2,
        'Integer 2 property function error');
      Assert.AreEqual(AnInt * 3, IntPropIn3,
        'Integer 3 property function error');
      Assert.AreEqual(AStr + ' (No Rec)', StrPropIn, 'String property error');
    end;

end;

procedure TPlBindManagerTest.TestBindRecordField(const AnInt: integer;
  const AStr: string; const ADbl: Double);
begin
  FSourceClass := TTestClassSource.Create(AnInt, AStr, ADbl);

  // binding
  FBinder.Bind(FSourceClass, 'RecPropOut', FTargetClass, 'RecTarget');
  //  binder.Bind(passiveClass, 'RecTarget.Name', activeClass, 'RecPropIn.Name');
  FBinder.Bind(FTargetClass, 'RecTarget.Age', FSourceClass, 'RecPropIn.Age');
  // Test
  with FSourceClass do
    begin
      Assert.AreEqual('', RecPropIn.Name, 'Record Name property error');
      Assert.AreEqual(AnInt + 1, RecPropIn.Age, 'Record Age property error');
    end;
end;

procedure TPlBindManagerTest.TestDirectBindEvent(const AnInt: integer;
  const AStr: string; const ADbl: Double);
begin
  FSourceClass := TTestClassSource.Create(AnInt, AStr, ADbl);
  // Binding
  FBinder.Bind(FTargetClass, 'EventFiredTarget', FSourceClass, 'EventFired');
  FBinder.BindMethod(FSourceClass, 'OnEvent', FTargetClass, 'TestEventBind');
  //  binder.BindEventHandler(activeClass, 'OnEvent', passiveClass, 'TestEventBind');
  // Test
  FSourceClass.OnEvent(nil);
  FBinder.UpdateValues;
  Assert.IsTrue(FSourceClass.EventFired, 'Event not fired');
end;

procedure TPlBindManagerTest.TestReadNumbers;
begin
  FSourceClass := TTestClassSource.Create(0, '', 0);
  FBinder.Bind(FTargetClass, 'ObjTarget.Numbers[tiFirst]', FSourceClass,
    'IntPropIn');
  Assert.AreEqual(TEST_ARRAY[tiFirst], FSourceClass.IntPropIn,
    'Test on tiFirst');
  FBinder.Bind(FTargetClass, 'ObjTarget.Numbers[tiSecond]', FSourceClass,
    'IntPropIn');
  Assert.AreEqual(TEST_ARRAY[tiSecond], FSourceClass.IntPropIn,
    'Test on tiSecond');
  FBinder.Bind(FTargetClass, 'ObjTarget.Numbers[tiThird]', FSourceClass,
    'IntPropIn');
  Assert.AreEqual(TEST_ARRAY[tiThird], FSourceClass.IntPropIn,
    'Test on tiThird');
end;

procedure TPlBindManagerTest.TestReadStrings(AIndex: integer);
const
  STRINGS_TEST: array [0 .. 3] of string = ('FirstString', 'SecondString',
    'ThirdString', 'FourthString');
begin
  {TODO 2 -oPMo -cRefactoring : change TTestClassSource.Create to use custom strings}
  FSourceClass := TTestClassSource.Create(0, '', 0);
  FBinder.Bind(FTargetClass, 'ObjTarget.Strings.Strings[' + IntToStr(AIndex) +
    ']', FSourceClass, STRINGS_TEST[AIndex]);
  case AIndex of
    0:
      Assert.AreEqual(FTargetClass.ObjTarget.Strings[AIndex],
        FSourceClass.FirstString);
    1:
      Assert.AreEqual(FTargetClass.ObjTarget.Strings[AIndex],
        FSourceClass.SecondString);
    2:
      Assert.AreEqual(FTargetClass.ObjTarget.Strings[AIndex],
        FSourceClass.ThirdString);
    3:
      Assert.AreEqual(FTargetClass.ObjTarget.Strings[AIndex],
        FSourceClass.FourthString);
  else
    Assert.IsTrue(False, 'No tested: index out of bound is not yet detected')
  end;

end;

procedure TPlBindManagerTest.TestUpdateValues(const AnInt: integer;
  const AStr: string; const ADbl: Double);
begin
  FSourceClass := TTestClassSource.Create(AnInt, AStr, ADbl);

  // binding
  FBinder.Bind(FSourceClass, 'IntPropOut', FTargetClass, 'intTarget');
  // 1.st Test
  Assert.AreEqual(AnInt, FTargetClass.intTarget, 'Integer map error');
  FSourceClass.IntPropOut := AnInt * 2;
  FBinder.UpdateValues;
  Assert.AreEqual(AnInt * 2, FTargetClass.intTarget, 'Integer bind error');
  Exit;

  FBinder.Start(100);
  //  if activeClass.IntPropOut < 5 then
  //    Exit;
  Sleep(5000);
  if FTargetClass.intTarget > 2 then
    Exit;
  with FSourceClass do
    Assert.AreEqual(4, FTargetClass.intTarget, 'Integer bind error');
  FBinder.Stop;
  //  activeClass.IntPropOut := 6;
  //  Sleep(150);
  //  with activeClass do
  //    Assert.AreEqual(4, passiveClass.intTarget, 'Integer bind error');
end;

initialization

TDUnitX.RegisterTestFixture(TPlBindManagerTest);

end.
