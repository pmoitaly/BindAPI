unit Register.Demo;

interface

uses
  Test.Controller, plBindAPI.ClassFactory;

implementation

initialization
  TplClassManager.RegisterClass(TTestController, true);
  TplClassManager.RegisterClass(TTestSecond, true);

end.
