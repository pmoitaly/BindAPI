program VCL.BindApiSimpleDemo;

uses
  Vcl.Forms,
  Test.Controller in '..\Common\Test.Controller.pas',
  fBindApiSimpleDemo in 'fBindApiSimpleDemo.pas' {frmBindApiSimpleDemo},
  fVCLBindApiMonitor in '..\Common\fVCLBindApiMonitor.pas' {frmBindApiMonitor},
  Register.Demo in '..\Common\Register.Demo.pas',
  Controller.SimpleDemoForm in 'Controller.SimpleDemoForm.pas',
  Vcl.About in 'Vcl.About.pas' {frmAbout};

{$R *.res}

begin
  System.ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'plBindApi Simple Demo';
  Application.CreateForm(TfrmBindApiSimpleDemo, frmBindApiSimpleDemo);
  Application.Run;
end.
