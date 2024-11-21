{*****************************************************************************}
{       BindAPI                                                               }
{       Copyright (C) 2020 Paolo Morandotti                                   }
{       Unit BinderElementTest                                                  }
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

{ DUnitX test for TplBindElementData }

unit BinderElementTest;

interface

uses
  DUnitX.TestFramework,
  System.Rtti,
  Vcl.StdCtrls,
  plBindAPI.BinderElement,
  BindAPITestClasses;

type
  [TestFixture]
  TplBindElementDataTest = class(TObject)
  private
    ElementData: TplBindElementData;
    activeClass: TTestClassB;
    passiveClass: TTestClassA;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    // Test properties binding
    [Test(True)]
    [TestCase('Test On PropertyPath property #1', 'Property.Path.1')]
    [TestCase('Test On PropertyPath property #2', '')]
    [TestCase('Test On PropertyPath property #3', 'PropertyPath')]
    procedure TestPropertyPath(const APath: string);
//    procedure TestBindProperty(const AnInt: Integer; const AStr: string; const ADbl: Double);

    [Test(False)]
    procedure TestIsEqualTo(AStructure: TplBindElementData);

    [Test(False)]
    procedure TestValueChanged;

    [Test(True)]
    [TestCase('Test On ClassAlias property #1', 'Class alias #1')]
    [TestCase('Test On ClassAlias property #2', '')]
    [TestCase('Test On ClassAlias property #3', 'ClassAlias2')]
    procedure TestClassAlias(const AnAlias: string);

    [Test(False)]
    procedure TestElement(AnElement: TObject);

    [Test(True)]
    [TestCase('Test On Enabled property #1', 'True')]
    [TestCase('Test On Enabled property #2', 'False')]
    procedure TestEnabled(const AValue: Boolean);

//    [Test(False)]
//    [TestCase('Test On Value property #1', 'ValueString')]
//    [TestCase('Test On Value property #2', '')]
//    [TestCase('Test On Value property #3', '3.2')]
//    procedure TestValue(AValue: TValue);
  end;

implementation

{ TplBindElementDataTest }

procedure TplBindElementDataTest.Setup;
begin
    ElementData := TplBindElementData.Create();
end;

procedure TplBindElementDataTest.TearDown;
begin
    ElementData.Free;
end;

procedure TplBindElementDataTest.TestClassAlias(const AnAlias: string);
begin

end;

procedure TplBindElementDataTest.TestElement(AnElement: TObject);
begin

end;

procedure TplBindElementDataTest.TestEnabled(const AValue: Boolean);
begin

end;

procedure TplBindElementDataTest.TestIsEqualTo(AStructure: TplBindElementData);
begin

end;

procedure TplBindElementDataTest.TestPropertyPath(const APath: string);
begin

end;

procedure TplBindElementDataTest.TestValueChanged;
begin

end;

end.
