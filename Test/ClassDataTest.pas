unit ClassDataTest;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  PlBindAPI.ClassFactory, PlBindAPI.Types;

type
  [TestFixture]
  TTestPlClassData = class
  private
    FParams: TPlCreateParams;
  public
    [Setup]
    procedure Setup;

    [TearDown]
    procedure TearDown;

    /// <summary>
    /// Tests the Create constructor to ensure it initializes the record correctly.
    /// </summary>
    [Test]
    procedure TestCreateConstructor;

    /// <summary>
    /// Tests the AutoBind property to ensure it reflects the correct value.
    /// </summary>
    [Test]
    procedure TestAutoBindProperty;

    /// <summary>
    /// Tests the RegisteredClass property to ensure it returns the expected class.
    /// </summary>
    [Test]
    procedure TestRegisteredClassProperty;

    /// <summary>
    /// Tests the CreateParams property to ensure it returns the correct parameters.
    /// </summary>
    [Test]
    procedure TestCreateParamsProperty;
  end;

implementation

procedure TTestPlClassData.Setup;
begin
  // Initialize the parameters before each test
  FParams := [];
end;

procedure TTestPlClassData.TearDown;
begin
end;

procedure TTestPlClassData.TestCreateConstructor;
var
  ClassData: TPlClassData;
  TestClass: TClass;
begin
  TestClass := TTestPlClassData;  // Using the test class as an example
  ClassData := TPlClassData.Create(TestClass, FParams, True);

  Assert.AreEqual(TestClass, ClassData.RegisteredClass, 'RegisteredClass should match the class passed to the constructor.');
  Assert.IsTrue(FParams = ClassData.CreateParams, 'CreateParams should match the instance passed to the constructor.');
  Assert.IsTrue(ClassData.AutoBind, 'AutoBind should be True as specified in the constructor.');
end;

procedure TTestPlClassData.TestAutoBindProperty;
var
  ClassData: TPlClassData;
begin
  ClassData := TPlClassData.Create(TTestPlClassData, FParams, False);
  Assert.IsFalse(ClassData.AutoBind, 'AutoBind should be False as specified in the constructor.');

  ClassData := TPlClassData.Create(TTestPlClassData, FParams, True);
  Assert.IsTrue(ClassData.AutoBind, 'AutoBind should be True as specified in the constructor.');
end;

procedure TTestPlClassData.TestRegisteredClassProperty;
var
  ClassData: TPlClassData;
  TestClass: TClass;
begin
  TestClass := TTestPlClassData;
  ClassData := TPlClassData.Create(TestClass, FParams);
  Assert.AreEqual(TestClass, ClassData.RegisteredClass, 'RegisteredClass should return the correct class.');
end;

procedure TTestPlClassData.TestCreateParamsProperty;
var
  ClassData: TPlClassData;
begin
  ClassData := TPlClassData.Create(TTestPlClassData, FParams);
  Assert.IsTrue(FParams = ClassData.CreateParams, 'CreateParams should return the correct parameters.');
end;

initialization
  TDUnitX.RegisterTestFixture(TTestPlClassData);

end.
