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
    // Test event binding
    [Test(True)]
    [TestCase('Test On Event', '2, Pippo, 3.6')]
    procedure TestBindEvent(const AnInt: Integer; const AStr: string; const ADbl: Double);

  end;

implementation

procedure TPlBindManagerTest.Setup;
begin
  binder := TPlBinder.Create;
end;

procedure TPlBindManagerTest.TearDown;
begin
  binder.Free;
end;

procedure TPlBindManagerTest.TestBindEvent(const AnInt: Integer;
  const AStr: string; const ADbl: Double);
begin
  activeClass := TTestClassB.Create(AnInt, AStr, ADbl);
  passiveClass := TTestClassA.Create;
  // Binding
  binder.Bind(passiveClass, 'EventFiredTarget', activeClass, 'EventFired');
  binder.BindMethod(activeClass.btnTest, 'OnClick', passiveClass, 'TestEventBind');
  // Test
  activeClass.btnTest.Click;
  binder.UpdateValues;
  Assert.IsTrue(activeClass.EventFired, 'Event not fired');
  // Free classes
  activeClass.Free;
  passiveClass.Free;
end;

procedure TPlBindManagerTest.TestBindProperty(const AnInt: Integer; const AStr: string; const ADbl: Double);
begin
  activeClass := TTestClassB.Create(AnInt, AStr, ADbl);
  passiveClass := TTestClassA.Create;
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
      Assert.AreEqual(RecPropIn.Name, RecPropOut.Name, 'Record Name property error');
      Assert.AreEqual(RecPropIn.Age, RecPropOut.Age, 'Record Age property error');
      Assert.AreEqual(DblPropIn, DblPropOut, 'Double property error');
      Assert.AreEqual(IntPropIn, IntPropOut, 'Integer property error');
      Assert.AreEqual(DblPropIn2, Double(DblPropOut * 2.0), 'Double property function error');
      Assert.AreEqual(IntPropIn2, IntPropOut * 2, 'Integer 2 property function error');
      Assert.AreEqual(IntPropIn3, IntPropOut * 3, 'Integer 3 property function error');
      Assert.AreEqual(StrPropIn, StrPropOut + ' (No Rec)', 'String property error');
    end;
  // Free classes
  activeClass.Free;
  passiveClass.Free;
end;

procedure TPlBindManagerTest.TestBindRecordField(const AnInt: Integer;
  const AStr: string; const ADbl: Double);
begin
  activeClass := TTestClassB.Create(AnInt, AStr, ADbl);
  passiveClass := TTestClassA.Create;
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
  // Free classes
  activeClass.Free;
  passiveClass.Free;
end;

initialization
  TDUnitX.RegisterTestFixture(TPlBindManagerTest);
end.
