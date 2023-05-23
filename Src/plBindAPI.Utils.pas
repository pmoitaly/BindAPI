unit plBindAPI.Utils;

interface
uses
  System.RTTI, VCL.Forms,
  plBindAPI.RTTIUtils;

type
  TplBindAPIUtils = class
  private
  public
    class function ShowFormModal<T: TCustomForm>(const Args: array of TValue): integer; overload;
    class function ShowFormModal(AClass: TFormClass;
      const Args: array of TValue): integer; overload;
  end;

implementation

uses
  plBindAPI.BindManagement;

{ TplBindAPIUtils }

class function TplBindAPIUtils.ShowFormModal<T>(const Args: array of TValue): integer;
var
  modalForm: T;
begin
  modalForm := TplRTTIUtils.InvokeEx('Create', T, '', Args).AsType<T>;
  try
    if Assigned(modalForm) then
      begin
        TplBindManager.Bind(modalForm);
        Result := modalForm.ShowModal;
        TplBindManager.UnBind(modalForm);
      end;
  finally
    modalForm.Free;
  end;
end;


class function TplBindAPIUtils.ShowFormModal(AClass: TFormClass;
    const Args: array of TValue): integer;
var
  modalForm: TCustomForm;
begin
  Result := 0;
  modalForm := TplRTTIUtils.InvokeEx('Create', AClass, '', Args).AsType<TCustomForm>;
  try
    if Assigned(modalForm) then
      begin
        TplBindManager.Bind(modalForm);
        modalForm.Visible := False;
        Result := modalForm.ShowModal;
        TplBindManager.UnBind(modalForm);
      end;
  finally
    modalForm.Free;
  end;
end;


end.
