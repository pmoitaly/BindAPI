program fmx.BindApiSimpleDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  fmx.fBindApiSimpleDemo in 'fmx.fBindApiSimpleDemo.pas' {BindApiSimpleDemo},
  Test.Controller in '..\Common\Test.Controller.pas',
  Register.Demo in '..\Common\Register.Demo.pas';

{$R *.res}

begin
  System.ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.CreateForm(TBindApiSimpleDemo, BindApiSimpleDemo);
  Application.Run;
end.
