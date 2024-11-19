unit Test.RegisterController;
{
  This unit registers some controllers, to use them in attributes
}

interface

uses
  Test.Controller, plBindApi.ClassFactory;

implementation

initialization
  TplClassManager.RegisterClass(TTestController, true);
  TplClassManager.RegisterClass(TTestSecond, true);


end.
