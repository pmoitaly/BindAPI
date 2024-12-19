unit fVCLBindApiMonitor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.Grids, Vcl.Menus;

type
  {Please, don't use plBindAPI here: it could change the list of applications bindings}
  TfrmBindApiMonitor = class(TForm)
    lblRegisteredClassesTitle: TLabel;
    pctMonitor: TPageControl;
    pnlRegisteredClasses: TPanel;
    sgrRegisteredClasses: TStringGrid;
    tbsBindingMonitor: TTabSheet;
    tbsClasses: TTabSheet;
    tmrUpdate: TTimer;
    chkBinderEnabled: TCheckBox;
    lblInterval: TLabel;
    edtInterval: TEdit;
    edtBindingNumber: TEdit;
    lblBindingNumber: TLabel;
    mmuMain: TMainMenu;
    mitFile: TMenuItem;
    mitExit: TMenuItem;
    sgrBindingList: TStringGrid;
    tbsErrorsList: TTabSheet;
    memErrorList: TMemo;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure mitExitClick(Sender: TObject);
    procedure sgrBindingListMouseEnter(Sender: TObject);
    procedure sgrBindingListMouseLeave(Sender: TObject);
    procedure sgrRegisteredClassesMouseEnter(Sender: TObject);
    procedure sgrRegisteredClassesMouseLeave(Sender: TObject);
    procedure tmrUpdateTimer(Sender: TObject);
  private
    { Private declarations }
    FSuspendBinderUpdate: boolean;
    FSuspendRegisteredClassesUpdate: boolean;
    procedure UpdateBinderData;
    procedure UpdateRegisteredClassesList;
  end;

var
  frmBindApiMonitor: TfrmBindApiMonitor;

implementation

uses
  System.StrUtils,
  plBindAPI.ClassFactory, plBindAPI.Types,
  plBindAPI.BindManagement, plBindAPI.BindingElement,
  plBindAPI.RTTIUtils;

{$R *.dfm}

// START resource string wizard section
resourcestring
  SEnabled = 'Enabled';
  SSourceClassName = 'Source Class Name';
  SSourcePath = 'Source Path';
  SSourceValue = 'Source value';
  STargetClassName = 'Target Class Name';
  STargetPath = 'Target Path';
  STargetValue = 'Target value';
  SYes = 'Yes';
  SNo = 'No';
  SClassName = 'Class Name';
  SIsSingleton = 'Is singleton';
  SInstances = 'Instances';
  SRegisteredClassesTotal = 'Registered classes - Total: ';
// END resource string wizard section

procedure TfrmBindApiMonitor.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  tmrUpdate.Enabled := False;
end;

procedure TfrmBindApiMonitor.FormCreate(Sender: TObject);
begin
  tmrUpdate.Enabled := True;
end;

procedure TfrmBindApiMonitor.mitExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmBindApiMonitor.sgrBindingListMouseEnter(Sender: TObject);
begin
  {When the mouse is over the grid, refresh is suspended}
  FSuspendBinderUpdate := True;
end;

procedure TfrmBindApiMonitor.sgrBindingListMouseLeave(Sender: TObject);
begin
  {When the mouse leaves the grid, refresh is enabled}
  FSuspendBinderUpdate := False;
end;

procedure TfrmBindApiMonitor.sgrRegisteredClassesMouseEnter(Sender: TObject);
begin
  {When the mouse is over the grid, refresh is suspended}
  FSuspendRegisteredClassesUpdate := True;
end;

procedure TfrmBindApiMonitor.sgrRegisteredClassesMouseLeave(Sender: TObject);
begin
  {When the mouse leaves the grid, refresh is enabled}
  FSuspendRegisteredClassesUpdate := False;
end;

procedure TfrmBindApiMonitor.tmrUpdateTimer(Sender: TObject);
begin
  if not FSuspendBinderUpdate then
    UpdateBinderData;
  if not FSuspendRegisteredClassesUpdate then
    UpdateRegisteredClassesList;
end;

{ TfrmBindApiMonitor }

procedure TfrmBindApiMonitor.UpdateBinderData;
var
  bindingInfo: TPlBindingList;
  debugInfo: TplBindDebugInfo;
  errorList: string;
  internalLoopIndex: integer;
  keyPropertyList: TPlBindingElement;
  rowIndex: integer;
  value: TPlBindingElement;
  valuePropertyList: TPlBindingElementsList;

begin
  debugInfo := TplBindManager.DebugInfo;
  chkBinderEnabled.Checked := debugInfo.Active;
  edtBindingNumber.Text := IntToStr(debugInfo.Count);
  edtInterval.Text := IntToStr(debugInfo.Interval);

  bindingInfo := TplBindManager.Binder.BindingInfo;
  try
    sgrBindingList.RowCount := 1;
    sgrBindingList.Cells[0, 0] := SEnabled;
    sgrBindingList.Cells[1, 0] := SSourceClassName;
    sgrBindingList.Cells[2, 0] := SSourcePath;
    sgrBindingList.Cells[3, 0] := SSourceValue;
    sgrBindingList.Cells[4, 0] := STargetClassName;
    sgrBindingList.Cells[5, 0] := STargetPath;
    sgrBindingList.Cells[6, 0] := STargetValue;

    rowIndex := 0;
    for keyPropertyList in bindingInfo.Keys do
      begin
        Inc(rowIndex);
        sgrBindingList.RowCount := sgrBindingList.RowCount + 1;
        valuePropertyList := bindingInfo[keyPropertyList];
        sgrBindingList.Cells[0, rowIndex] := IfThen(keyPropertyList.Enabled,
          SYes, SNo);
        sgrBindingList.Cells[1, rowIndex] := keyPropertyList.Element.ClassName;
        sgrBindingList.Cells[2, rowIndex] := keyPropertyList.PropertyPath;
        sgrBindingList.Cells[3, rowIndex] := keyPropertyList.value.ToString;
        internalLoopIndex := 0;
        for value in valuePropertyList do
          begin
            if internalLoopIndex > 0 then
              begin
                Inc(rowIndex);
                sgrBindingList.RowCount := sgrBindingList.RowCount + 1;
              end;
            sgrBindingList.Cells[4, rowIndex] := value.Element.ClassName;
            sgrBindingList.Cells[5, rowIndex] := value.PropertyPath;
            sgrBindingList.Cells[6, rowIndex] := value.value.ToString;
            Inc(internalLoopIndex);
          end;
      end;
  finally
    bindingInfo.Free;
  end;

  errorList := TplBindManager.ErrorList;
  if errorList <> '' then
    memErrorList.Text := errorList;

end;

procedure TfrmBindApiMonitor.UpdateRegisteredClassesList;
var
  instances: TPlInstanceList;
  key: string;
  registeredClasses: TPlClassList;
  rowIndex: integer;
begin
  instances := TplClassManager.instances;
  try
    registeredClasses := TplClassManager.registeredClasses;
    try
      sgrRegisteredClasses.RowCount := registeredClasses.Count + 1;
      sgrRegisteredClasses.Cells[0, 0] := SClassName;
      sgrRegisteredClasses.Cells[1, 0] := SIsSingleton;
      sgrRegisteredClasses.Cells[2, 0] := SInstances;

      rowIndex := 1;
      for key in registeredClasses.Keys do
        begin
          sgrRegisteredClasses.Cells[0, rowIndex] := key;
          sgrRegisteredClasses.Cells[1, rowIndex] :=
            IfThen(TplClassManager.IsSingleton(key), SYes, SNo);
          sgrRegisteredClasses.Cells[2, rowIndex] :=
            IfThen(instances.ContainsKey(key) and Assigned(instances.Items[key]
            ), '1', '0');
          Inc(rowIndex);
        end;

      lblRegisteredClassesTitle.Caption := SRegisteredClassesTotal +
        IntToStr(registeredClasses.Count);
    finally
      registeredClasses.Free;
    end;
  finally
    instances.Free;
  end;
end;

end.
