program BindApiSimpleDemo;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Vcl.Forms,
  fBindApiSimpleDemo in 'fBindApiSimpleDemo.pas' {frmBindApiSimpleDemo},
  Test.Controller in 'Test.Controller.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmBindApiSimpleDemo, frmBindApiSimpleDemo);
  Application.Run;
end.
