unit plBindAPI.BindManagement;

interface

uses
  System.Classes, plBindAPI.AutoBinder, plBindAPI.ClassFactory;

type
  TplBoundObjects = TArray<TObject>;

  TplBindManager = class(TInterfacedObject)
  private
    class var FBinder: TplAutoBinder;
    { Private declarations }
  protected
    class constructor Create;
    class destructor Destroy;
  public
    { Public declarations }
    class property Binder: TplAutoBinder read FBinder;
    class function Bind(ASource: TObject): TplBoundObjects;
    class procedure Unbind(ASource: TObject);
  end;

  TModelBinder = class(TplBindManager);
  TVMBinder = class(TplBindManager);

implementation

uses
  System.Rtti, System.StrUtils, System.TypInfo,
  plBindAPI.Attributes;

{ TplBindManager }

class function TplBindManager.Bind(ASource: TObject): TplBoundObjects;
var
  rContext: TRttiContext;
  rType: TRttiType;
  rAttr: TCustomAttribute;
  target: TObject;
begin
  Result := TplBoundObjects.Create();

  rContext := TRttiContext.Create;
  { Extract type information for ASource's type }
  rType := rContext.GetType(ASource.ClassType);
  { Search for the custom attribute and do some custom processing }
  for rAttr in rType.GetAttributes() do
    if rAttr is ClassBindAttribute and ClassBindAttribute(rAttr).IsEnabled then
      begin
        target := TplClassManager.GetInstance(ClassBindAttribute(rAttr).TargetClassName);
        if Assigned(target) then
          FBinder.BindObject(ASource, target);
        SetLength(Result, Length(Result) + 1);
        Result[High(Result)] := target;
      end;
  rContext.Free;
end;

class constructor TplBindManager.Create;
begin
  inherited;
  FBinder := TplAutoBinder.Create;
  FBinder.Start(200);
end;

class destructor TplBindManager.Destroy;
begin
  FBinder.Free;
  inherited;
end;

class procedure TplBindManager.Unbind(ASource: TObject);
begin
  FBinder.UnbindTarget(ASource);
  FBinder.UnbindSource(ASource);
  FBinder.UnbindMethods(ASource);
end;

end.
