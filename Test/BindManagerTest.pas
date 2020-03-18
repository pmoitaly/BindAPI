unit BindManagerTest;

interface
uses
  DUnitX.TestFramework,
  Vcl.StdCtrls,
  plBindAPI.CoreBinder,
  BindAPITestClasses;

type

  [TestFixture]
  TPlBindManagerTest = class(TObject)
  private
    binder: TPlBinder;
    activeClass: TTestClassB;
    passiveClass: TTestClassA;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // Test properties binding
    [Test(True)]
    [TestCase('Test On Properties', '2, Pippo, 3.6')]
    [TestCase('Test On Properties', '3, Topolino, 0.8')]
    procedure TestBindProperty(const AnInt: Integer; const AStr: string; const ADbl: Double);
    // Test fields binding
    [Test(True)]
    [TestCase('Test On Record Field', '2, Pippo, 3.6')]
    procedure TestBindRecordField(const AnInt: Integer; const AStr: string; const ADbl: Double);
    [Test(True)]
    [TestCase('Test On Object Field', '3, Pippo, 12')]
    procedure TestBindFieldProperty(const AnInt: Integer; const AStr: string; const ADbl: Double);
    // Test property as objects
    [Test(True)]
    [TestCase('Test On Object Property', '3, Pippo, 12')]
    procedure TestBindObjectProperty(const AnInt: Integer; const AStr: string; const ADbl: Double);
    // Test event binding
    [Test(True)]
    [TestCase('Test On Event', '2, Pippo, 3.6')]
    procedure TestBindEvent(const AnInt: Integer; const AStr: string; const ADbl: Double);

  end;

implementation

procedure TPlBindManagerTest.Setup;
begin
  binder := TPlBinder.Create;
  passiveClass := TTestClassA.Create;
end;

procedure TPlBindManagerTest.TearDown;
begin
  binder.Free;
  // Free classes
  activeClass.Free;
  passiveClass.Free;
end;

procedure TPlBindManagerTest.TestBindEvent(const AnInt: Integer;
  const AStr: string; const ADbl: Double);
begin
  activeClass := TTestClassB.Create(AnInt, AStr, ADbl);
  // Binding
  binder.Bind(passiveClass, 'EventFiredTarget', activeClass, 'EventFired');
  binder.BindMethod(activeClass.btnTest, 'OnClick', passiveClass, 'TestEventBind');
  // Test
  activeClass.btnTest.Click;
  binder.UpdateValues;
  Assert.IsTrue(activeClass.EventFired, 'Event not fired');
end;

procedure TPlBindManagerTest.TestBindFieldProperty(const AnInt: Integer;
  const AStr: string; const ADbl: Double);
begin
  activeClass := TTestClassB.Create(AnInt, AStr, ADbl);

  // binding
  { TODO 4 -oPMo -cRefactoring :
    Although BindAPI allows this operation, if not carefully managed it causes pointer errors when freeing the instances.
    Consider to automatically bind on each fields. }
//  binder.Bind(activeClass, 'FObjPropOut', passiveClass, 'FObjTarget');
  binder.Bind(activeClass, 'FObjPropOut.Age', passiveClass, 'FObjTarget.Age');
  binder.Bind(activeClass, 'FObjPropOut.Name', passiveClass, 'FObjTarget.Name');
  binder.Bind(passiveClass, 'FObjTarget.Age', activeClass, 'FObjPropIn.Age');
  // Test
  with activeClass do
    begin
      Assert.AreEqual(AStr + ' (Obj)', passiveClass.ObjTarget.Name, 'ObjTarget Name field error');
      Assert.AreEqual('', ObjPropIn.Name, 'Object Name field error');
      Assert.AreEqual(AnInt + 11, ObjPropIn.Age, 'Object Age field error');
    end;
end;

procedure TPlBindManagerTest.TestBindObjectProperty(const AnInt: Integer;
  const AStr: string; const ADbl: Double);
begin
  activeClass := TTestClassB.Create(AnInt, AStr, ADbl);

  // binding
  { TODO 4 -oPMo -cRefactoring :
    Although BindAPI allows this operation, if not carefully managed it causes pointer errors when freeing the instances.
    Consider to automatically bind on fields. }
//  binder.Bind(activeClass, 'ObjPropOut', passiveClass, 'ObjTarget');
  binder.Bind(activeClass, 'ObjPropOut.Age', passiveClass, 'ObjTarget.Age');
  binder.Bind(activeClass, 'ObjPropOut.Name', passiveClass, 'ObjTarget.Name');
  binder.Bind(passiveClass, 'ObjTarget.Age', activeClass, 'ObjPropIn.Age');
  // Test
  with activeClass do
    begin
      Assert.AreEqual(AStr + ' (Obj)', passiveClass.ObjTarget.Name, 'ObjTarget Name property error');
      Assert.AreEqual('', ObjPropIn.Name, 'Object Name property error');
      Assert.AreEqual(AnInt + 11, ObjPropIn.Age, 'Object Age property error');
    end;
end;

procedure TPlBindManagerTest.TestBindProperty(const AnInt: Integer; const AStr: string; const ADbl: Double);
begin
  activeClass := TTestClassB.Create(AnInt, AStr, ADbl);

  // binding
  binder.Bind(activeClass, 'DblPropOut', passiveClass, 'DblTarget');
  binder.Bind(activeClass, 'IntPropOut', passiveClass, 'intTarget');
  binder.Bind(activeClass, 'IntPropOut', passiveClass, 'intTarget3', passiveClass.TripleOf);
  binder.Bind(activeClass, 'RecPropOut', passiveClass, 'RecTarget');
  binder.Bind(activeClass, 'StrPropOut', passiveClass, 'StrTarget', passiveClass.ToName);
  binder.Bind(passiveClass, 'dblTarget', activeClass, 'DblPropIn');
  binder.Bind(passiveClass, 'dblTarget', activeClass, 'DblPropIn2', passiveClass.DoubleOf);
  binder.Bind(passiveClass, 'intTarget', activeClass, 'IntPropIn');
  binder.Bind(passiveClass, 'intTarget', activeClass, 'IntPropIn2', passiveClass.DoubleOf);
  binder.Bind(passiveClass, 'IntTarget3', activeClass, 'IntPropIn3');
  binder.Bind(passiveClass, 'RecTarget', activeClass, 'RecPropIn');
  binder.Bind(passiveClass, 'StrTarget', activeClass, 'StrPropIn');
  // Test
  with activeClass do
    begin
      Assert.AreEqual(AStr + ' (Rec)', RecPropIn.Name, 'Record Name property error');
      Assert.AreEqual(AnInt + 1, RecPropIn.Age, 'Record Age property error');
      Assert.AreEqual(DblPropOut, DblPropIn, 'Double property error');
      Assert.AreEqual(AnInt, IntPropIn, 'Integer property error');
      Assert.AreEqual(Double(ADbl * 2.0), DblPropIn2, 'Double property function error');
      Assert.AreEqual(AnInt * 2, IntPropIn2, 'Integer 2 property function error');
      Assert.AreEqual(AnInt * 3, IntPropIn3, 'Integer 3 property function error');
      Assert.AreEqual(AStr + ' (No Rec)', StrPropIn, 'String property error');
    end;

end;

procedure TPlBindManagerTest.TestBindRecordField(const AnInt: Integer;
  const AStr: string; const ADbl: Double);
begin
  activeClass := TTestClassB.Create(AnInt, AStr, ADbl);

  // binding
  binder.Bind(activeClass, 'RecPropOut', passiveClass, 'RecTarget');
//  binder.Bind(passiveClass, 'RecTarget.Name', activeClass, 'RecPropIn.Name');
  binder.Bind(passiveClass, 'RecTarget.Age', activeClass, 'RecPropIn.Age');
  // Test
  with activeClass do
    begin
      Assert.AreEqual('', RecPropIn.Name, 'Record Name property error');
      Assert.AreEqual(AnInt + 1, RecPropIn.Age, 'Record Age property error');
    end;
end;

initialization
  TDUnitX.RegisterTestFixture(TPlBindManagerTest);
end.
