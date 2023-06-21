program BindApiSimpleDemo;

uses
  Vcl.Forms,
  fBindApiSimpleDemoBase in 'fBindApiSimpleDemoBase.pas' {frmBindApiSimpleDemo},
  Test.Controller in 'Common\Test.Controller.pas';

{$R *.res}

begin
  System.ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmBindApiSimpleDemo, frmBindApiSimpleDemo);
  Application.Run;
end.
