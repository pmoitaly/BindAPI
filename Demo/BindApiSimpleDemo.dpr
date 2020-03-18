program BindApiSimpleDemo;

uses
  Vcl.Forms,
  fBindApiSimpleDemo in 'fBindApiSimpleDemo.pas' {frmBindApiSimpleDemo},
  Test.Controller in 'Test.Controller.pas';

{$R *.res}

begin
  System.ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmBindApiSimpleDemo, frmBindApiSimpleDemo);
  Application.Run;
end.
