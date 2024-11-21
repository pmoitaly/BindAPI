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
    sgrBindingList.Cells[0, 0] := 'Enabled';
    sgrBindingList.Cells[1, 0] := 'Source Class Name';
    sgrBindingList.Cells[2, 0] := 'Source Path';
    sgrBindingList.Cells[3, 0] := 'Source value';
    sgrBindingList.Cells[4, 0] := 'Target Class Name';
    sgrBindingList.Cells[5, 0] := 'Target Path';
    sgrBindingList.Cells[6, 0] := 'Target value';

    rowIndex := 0;
    for keyPropertyList in bindingInfo.Keys do
      begin
        Inc(rowIndex);
        sgrBindingList.RowCount := sgrBindingList.RowCount + 1;
        valuePropertyList := bindingInfo[keyPropertyList];
        sgrBindingList.Cells[0, rowIndex] := IfThen(keyPropertyList.Enabled,
          'Yes', 'No');
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
      sgrRegisteredClasses.Cells[0, 0] := 'Class Name';
      sgrRegisteredClasses.Cells[1, 0] := 'Is singleton';
      sgrRegisteredClasses.Cells[2, 0] := 'Instances';

      rowIndex := 1;
      for key in registeredClasses.Keys do
        begin
          sgrRegisteredClasses.Cells[0, rowIndex] := key;
          sgrRegisteredClasses.Cells[1, rowIndex] :=
            IfThen(TplClassManager.IsSingleton(key), 'Yes', 'No');
          sgrRegisteredClasses.Cells[2, rowIndex] :=
            IfThen(instances.ContainsKey(key) and Assigned(instances.Items[key]
            ), '1', '0');
          Inc(rowIndex);
        end;

      lblRegisteredClassesTitle.Caption := 'Registered classes - Total: ' +
        IntToStr(registeredClasses.Count);
    finally
      registeredClasses.Free;
    end;
  finally
    instances.Free;
  end;
end;

end.