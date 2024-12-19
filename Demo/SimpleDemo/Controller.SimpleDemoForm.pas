unit Controller.SimpleDemoForm;

interface

uses
  Forms;

type
  TSimpleDemoFormController = class
  private
    FMonitorVisible: Boolean;
  public
    procedure ExitProgram(Sender: TObject);
    procedure ShowAbout(Sender: TObject);
    procedure SwitchMonitor(Sender: TObject);
    property monitorVisible: Boolean read FMonitorVisible;
  end;

implementation

{ TSimpleDemoFormController }

uses Menus,
  plBindApi.ClassFactory, plBindApi.Types,
  fVCLBindApiMonitor, Vcl.About;

procedure TSimpleDemoFormController.ExitProgram(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TSimpleDemoFormController.ShowAbout(Sender: TObject);
begin
  frmAbout := TFrmAbout.Create(nil);
  try
    frmAbout.ShowModal;
  finally
    frmAbout.Free;
  end;
end;

procedure TSimpleDemoFormController.SwitchMonitor(Sender: TObject);
begin
  if not Assigned(frmBindApiMonitor) then
    begin
      frmBindApiMonitor := TfrmBindApiMonitor.Create(Application);
      frmBindApiMonitor.BringToFront;
    end
  else
    frmBindApiMonitor.Visible := not frmBindApiMonitor.Visible;
end;

initialization
  TPlClassManager.RegisterClass(TSimpleDemoFormController, [Singleton]);

end.
