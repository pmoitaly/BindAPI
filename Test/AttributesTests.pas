unit AttributesTests;

interface
uses
  DUnitX.TestFramework, plBindAPI.Attributes;

type
  [TestFixture]
  TCustomBindMemberAttributeTests = class
  public
    [Test]
    [TestCase('Test Create_With Enabled Status True', 'True')]
    [TestCase('Test Create_With Enabled Status False', 'False')]
    procedure Test_Create_WithEnabledStatus(const Enabled: boolean);

    [Test]
    procedure Test_Create_WithoutEnabledStatus;

    [Test]
    procedure Test_FunctionNameProperty;

    [Test]
    procedure Test_SourceQNameProperty;

    [Test]
    procedure Test_TargetQNameProperty;

  end;

 [TestFixture]
TBindMethodAttributeTests = class
public
  [Test]
  [TestCase('BindMethodAttribute Test Create_With_Enabled Status True', 'True')]
  [TestCase('BindMethodAttribute Test Create_With Enabled Status False', 'False')]
  procedure Test_CreateWithEnabledTrue(const Enabled: Boolean);

  [Test]
  procedure Test_CreateWithOnlyMethodNameAndNewMethodName;
end;

[TestFixture]
TBindDefaultClassAttributeTests = class
public
  [Test]
  procedure Test_CreateWithClassNameOnly;

  [Test]
  procedure Test_CreateWithClassNameAndAlias;
end;

  [TestFixture]
  TBindClassAttributeTests = class
  public
    [Test]
    [TestCase('BindMethodAttribute Test Create With Enabled True And Defaule True', 'True, True, TargetName1')]
    [TestCase('BindMethodAttribute Test Create_With Enabled False And Status False', 'False, False, TargetName2')]
    [TestCase('BindMethodAttribute Test Create With Enabled True And Defaule False', 'True, False, TargetName3')]
    [TestCase('BindMethodAttribute Test Create_With Enabled True And Status False', 'True, False, TargetName4')]
    procedure Test_CreateWithEnabledAndDefault(const Enabled, Default: Boolean; const TargetName: string);

    [Test]
    [TestCase('BindMethodAttribute Test Create With Enabled True And Default True, Alias1 as Alias', 'True, True, TargetName1, Alias1')]
    [TestCase('BindMethodAttribute Test Create_With Enabled False And Default False, Alias2 as Alias', 'False, False, TargetName2, Alias2')]
    [TestCase('BindMethodAttribute Test Create With Enabled True And Default False, Alias3 as Alias', 'True, False, TargetName3, Alias3')]
    [TestCase('BindMethodAttribute Test Create_With Enabled True And Default False, Alias4 as Alias', 'True, False, TargetName3, Alias4')]
    procedure Test_CreateWithEnabledAliasAndDefault(const Enabled, Default:
        Boolean; const TargetName, Alias: string);

    [Test]
    [TestCase('BindMethodAttribute Test Create With Default True, TargetName1 as TargetName', 'True, TargetName1')]
    [TestCase('BindMethodAttribute Test Create_With Default False, TargetName2 as TargetName', 'False, TargetName2')]
    procedure Test_CreateWithOnlyClassNameAndDefault(const Default: Boolean; const TargetName: string);

    [Test]
    [TestCase('BindMethodAttribute Test Create With Default True, TargetName1 as TargetName, Alias1 as Alias', 'True, TargetName1, Alias1')]
    [TestCase('BindMethodAttribute Test Create_With Default False, TargetName2 as TargetName, Alias2 as Alias', 'False, TargetName2, Alias2')]
    procedure Test_CreateWithClassNameAliasAndDefault(const Default: Boolean; const TargetName, Alias: string);

    [Test]
    [TestCase('BindMethodAttribute Test Create With Enabled True, TargetName1 as TargetName', 'True, TargetName1')]
    [TestCase('BindMethodAttribute Test Create_With Enabled False, TargetName2 as TargetName', 'False, TargetName2')]
    procedure Test_CreateWithOnlyEnabledAndClassName(const Enabled: Boolean; const TargetName: string);

    [Test]
    [TestCase('BindMethodAttribute Test Create With Enabled True, TargetName1 as TargetName, Alias1 as Alias', 'True, TargetName1, Alias1')]
    [TestCase('BindMethodAttribute Test Create_With Enabled False, TargetName2 as TargetName', 'False, TargetName2, Alias2')]
    procedure Test_CreateWithOnlyEnabledClassNameAndAlias(const Enabled: Boolean; const TargetName, Alias: string);

    [Test]
    [TestCase('BindMethodAttribute Test Create With TargetName1 as TargetName', 'TargetName1')]
    [TestCase('BindMethodAttribute Test Create_With TargetName2 as TargetName', 'TargetName2')]
    procedure Test_CreateWithOnlyClassName(const TargetName: string);

  end;

implementation

procedure TCustomBindMemberAttributeTests.Test_Create_WithEnabledStatus(const Enabled: boolean);
var
  Attr: CustomBindMemberAttribute;
begin
  Attr := CustomBindMemberAttribute.Create(Enabled, 'Source.Field1', 'Target.Field2', 'BridgeFunction', 'TargetClass');
  try
    Assert.AreEqual('Source.Field1', Attr.SourceQName);
    Assert.AreEqual('Target.Field2', Attr.TargetQName);
    Assert.AreEqual('BridgeFunction', Attr.FunctionName);
    Assert.AreEqual('TargetClass', Attr.TargetClassName);
    Assert.AreEqual(Enabled, Attr.IsEnabled);
   finally
    Attr.Free;
  end;
end;

procedure TCustomBindMemberAttributeTests.Test_Create_WithoutEnabledStatus;
var
  Attr: CustomBindMemberAttribute;
begin
  Attr := CustomBindMemberAttribute.Create('Source.Field1', 'Target.Field2', 'BridgeFunction', 'TargetClass');
  try
    Assert.AreEqual('Source.Field1', Attr.SourceQName);
    Assert.AreEqual('Target.Field2', Attr.TargetQName);
    Assert.AreEqual('BridgeFunction', Attr.FunctionName);
    Assert.IsTrue(Attr.IsEnabled);
  finally
    Attr.Free;
  end;
end;

procedure TCustomBindMemberAttributeTests.Test_FunctionNameProperty;
var
  Attr: CustomBindMemberAttribute;
begin
  Attr := CustomBindMemberAttribute.Create('Source.Field1', 'Target.Field2', 'BridgeFunction');
  try
    Assert.AreEqual('BridgeFunction', Attr.FunctionName);
  finally
    Attr.Free;
  end;
end;

procedure TCustomBindMemberAttributeTests.Test_SourceQNameProperty;
var
  Attr: CustomBindMemberAttribute;
begin
  Attr := CustomBindMemberAttribute.Create('Source.Field1', 'Target.Field2');
  try
    Assert.AreEqual('Source.Field1', Attr.SourceQName);
  finally
    Attr.Free;
  end;
end;

procedure TCustomBindMemberAttributeTests.Test_TargetQNameProperty;
var
  Attr: CustomBindMemberAttribute;
begin
  Attr := CustomBindMemberAttribute.Create('Source.Field1', 'Target.Field2');
  try
    Assert.AreEqual('Target.Field2', Attr.TargetQName);
  finally
    Attr.Free;
  end;
end;
{$ENDREGION}
{$REGION 'TBindMethodAttributeTests'}

procedure TBindMethodAttributeTests.Test_CreateWithEnabledTrue(const Enabled:
    Boolean);
var
  Attribute: BindMethodAttribute;
begin
  Attribute := BindMethodAttribute.Create(Enabled, 'SourceMethod', 'NewMethod');
  try
    Assert.AreEqual(Enabled, Attribute.IsEnabled);
    Assert.AreEqual('SourceMethod', Attribute.SourceMethodName);
    Assert.AreEqual('NewMethod', Attribute.NewMethodQName);
  finally
    Attribute.Free;
  end;
end;

procedure TBindMethodAttributeTests.Test_CreateWithOnlyMethodNameAndNewMethodName;
var
  Attribute: BindMethodAttribute;
begin
  Attribute := BindMethodAttribute.Create('SourceMethod', 'NewMethod');
  try
    Assert.IsTrue(Attribute.IsEnabled);
    Assert.AreEqual('SourceMethod', Attribute.SourceMethodName);
    Assert.AreEqual('NewMethod', Attribute.NewMethodQName);
  finally
    Attribute.Free;
  end;
end;

{$ENDREGION}

{$REGION 'TBindDefaultClassAttributeTests'}
procedure TBindDefaultClassAttributeTests.Test_CreateWithClassNameOnly;
var
  Attribute: BindDefaultClassAttribute;
begin
  Attribute := BindDefaultClassAttribute.Create('DefaultClass');
  try
    Assert.IsTrue(Attribute.IsEnabled);
    Assert.AreEqual('DefaultClass', Attribute.TargetClassName);
    Assert.IsTrue(Attribute.IsDefault);
  finally
    Attribute.Free;
  end;
end;

procedure TBindDefaultClassAttributeTests.Test_CreateWithClassNameAndAlias;
var
  Attribute: BindDefaultClassAttribute;
begin
  Attribute := BindDefaultClassAttribute.Create(True, 'DefaultClass', 'DefaultAlias');
  try
    Assert.IsTrue(Attribute.IsEnabled);
    Assert.AreEqual('DefaultClass', Attribute.TargetClassName);
    Assert.AreEqual('DefaultAlias', Attribute.TargetClassAlias);
    Assert.IsTrue(Attribute.IsDefault);
  finally
    Attribute.Free;
  end;
end;
{$ENDREGION}


{$REGION 'TBindClassAttributeTests'}

procedure TBindClassAttributeTests.Test_CreateWithEnabledAndDefault(const
    Enabled, Default: Boolean; const TargetName: string);
var
  Attribute: BindClassAttribute;
begin
  Attribute := BindClassAttribute.Create(Enabled, TargetName, Default);
  try
    Assert.AreEqual(Enabled, Attribute.IsEnabled);
    Assert.AreEqual(TargetName, Attribute.TargetClassName);
    Assert.AreEqual(Default, Attribute.IsDefault);
    Assert.AreEqual('', Attribute.TargetClassAlias);
  finally
    Attribute.Free;
  end;
end;

procedure TBindClassAttributeTests.Test_CreateWithEnabledAliasAndDefault(const
    Enabled, Default: Boolean; const TargetName, Alias: string);
var
  Attribute: BindClassAttribute;
begin
  Attribute := BindClassAttribute.Create(Enabled, TargetName, Alias, Default);
  try
    Assert.AreEqual(Enabled, Attribute.IsEnabled);
    Assert.AreEqual(TargetName, Attribute.TargetClassName);
    Assert.AreEqual(Alias, Attribute.TargetClassAlias);
    Assert.AreEqual(Default, Attribute.IsDefault);
  finally
    Attribute.Free;
  end;
end;

procedure TBindClassAttributeTests.Test_CreateWithOnlyClassName(
  const TargetName: string);
var
  Attribute: BindClassAttribute;
begin
  Attribute := BindClassAttribute.Create(TargetName);
  try
    Assert.IsTrue(Attribute.IsEnabled);
    Assert.AreEqual(TargetName, Attribute.TargetClassName);
    Assert.AreEqual('', Attribute.TargetClassAlias);
    Assert.IsFalse(Attribute.IsDefault);
  finally
    Attribute.Free;
  end;
end;

procedure TBindClassAttributeTests.Test_CreateWithOnlyClassNameAndDefault(const
    Default: Boolean; const TargetName: string);
var
  Attribute: BindClassAttribute;
begin
  Attribute := BindClassAttribute.Create(TargetName, Default);
  try
    Assert.IsTrue(Attribute.IsEnabled);
    Assert.AreEqual(TargetName, Attribute.TargetClassName);
    Assert.AreEqual('', Attribute.TargetClassAlias);
    Assert.AreEqual(Default, Attribute.IsDefault);
  finally
    Attribute.Free;
  end;
end;

procedure TBindClassAttributeTests.Test_CreateWithOnlyEnabledAndClassName(
  const Enabled: Boolean; const TargetName: string);
var
  Attribute: BindClassAttribute;
begin
  Attribute := BindClassAttribute.Create(Enabled, TargetName);
  try
    Assert.AreEqual(Enabled, Attribute.IsEnabled);
    Assert.AreEqual(TargetName, Attribute.TargetClassName);
    Assert.AreEqual('', Attribute.TargetClassAlias);
    Assert.IsFalse(Attribute.IsDefault);
  finally
    Attribute.Free;
  end;
end;

procedure TBindClassAttributeTests.Test_CreateWithOnlyEnabledClassNameAndAlias(
  const Enabled: Boolean; const TargetName, Alias: string);
var
  Attribute: BindClassAttribute;
begin
  Attribute := BindClassAttribute.Create(Enabled, TargetName, Alias);
  try
    Assert.AreEqual(Enabled, Attribute.IsEnabled);
    Assert.AreEqual(TargetName, Attribute.TargetClassName);
    Assert.AreEqual(Alias, Attribute.TargetClassAlias);
    Assert.IsFalse(Attribute.IsDefault);
  finally
    Attribute.Free;
  end;
end;


procedure TBindClassAttributeTests.Test_CreateWithClassNameAliasAndDefault(
    const Default: Boolean; const TargetName, Alias: string);
var
  Attribute: BindClassAttribute;
begin
  Attribute := BindClassAttribute.Create(TargetName, Alias, Default);
  try
    Assert.IsTrue(Attribute.IsEnabled);
    Assert.AreEqual(TargetName, Attribute.TargetClassName);
    Assert.AreEqual(Alias, Attribute.TargetClassAlias);
    Assert.AreEqual(Default, Attribute.IsDefault);
  finally
    Attribute.Free;
  end;
end;
{$ENDREGION}

initialization
  TDUnitX.RegisterTestFixture(TCustomBindMemberAttributeTests);

end.
