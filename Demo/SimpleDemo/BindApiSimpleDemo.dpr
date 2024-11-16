program BindApiSimpleDemo;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Vcl.Forms,
  Test.Controller in '..\Common\Test.Controller.pas',
  fBindApiSimpleDemo in 'fBindApiSimpleDemo.pas' {frmBindApiSimpleDemo},
  fVCLBindApiMonitor in '..\..\Src\fVCLBindApiMonitor.pas' {frmBindApiMonitor},
  Register.Demo in '..\Common\Register.Demo.pas';

{$R *.res}

begin
  System.ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'plBindApi Simple Demo';
  Application.CreateForm(TfrmBindApiSimpleDemo, frmBindApiSimpleDemo);
  Application.CreateForm(TfrmBindApiMonitor, frmBindApiMonitor);
  Application.Run;
end.
