unit plBindAPI.BinderElement;

interface

uses
  System.Rtti, System.Generics.Collections,
  System.Generics.Defaults, System.Classes,
  plBindAPI.Types;

type

  TplRTTIMemberBind = class
  private
    function FirstLeaf(var pathLeafs: string): string;
    procedure SetRecordFieldValue(Sender: TObject;
      AOwner, AField: TRTTIField; AValue: TValue); overload;
    procedure SetRecordFieldValue(Sender: TObject;
      AOwner: TRttiProperty; AField: TRTTIField; AValue: TValue); overload;
    function GetRecordFieldValue(Sender: TObject; AOwner: TRttiProperty;
      AField: TRTTIField): TValue; overload;
    function GetRecordFieldValue(Sender: TObject;
      AOwner, AField: TRTTIField): TValue; overload;
  private
    FCalculatedValue: TplBridgeFunction;
    FElement: TObject;
    FElementPath: string;
    FEnabled: Boolean;
    FValue: TValue;
    function AreEqual(Left, Right: TValue): Boolean;
    function GetPathValue(ARoot: TObject; var APath: string): TValue;
    function GetRecordPathValue(ARoot: TObject; var APath: string): TValue;
    function GetValue: TValue;
    function InternalCastTo(const AType: TTypeKind; AValue: TValue): TValue;
    procedure SetValue(Value: TValue); virtual;
    procedure SetPathValue(ARoot: TObject; var APath: string; AValue: TValue);
    procedure SetRecordPathValue(ARoot: TObject; var APath: string; AValue: TValue);
  public
    constructor Create(AObject: TObject; const APropertyPath: string; AFunction: TplBridgeFunction = nil);
    property Element: TObject read FElement;
    property Enabled: Boolean read FEnabled write FEnabled;
    property PropertyPath: string read FElementPath;
    property Value: TValue read FValue write SetValue;
    function ValueChanged: boolean;
    function IsEqualTo(AStructure: TplRTTIMemberBind) : Boolean;
  end;

  TplPropertyBind = class(TplRTTIMemberBind)

  end;

  TPlParKeyComparer = class(TEqualityComparer<TplPropertyBind>)
    function Equals(const Left, Right: TplPropertyBind): Boolean; override;
    function GetHashCode(const Value: TplPropertyBind): Integer; override;
  end;


implementation

uses
  System.TypInfo, System.Hash, System.SysUtils, System.StrUtils, System.Math;

  {TplRTTIMemberBind}

function TplRTTIMemberBind.AreEqual(Left, Right: TValue): Boolean;
var
  pLeft, pRight: Pointer;
begin
  If Left.IsOrdinal then
    Result := Left.AsOrdinal = Right.AsOrdinal
  else if Left.TypeInfo = System.TypeInfo(Single) then
    Result := SameValue(Left.AsType<Single>(), Right.AsType<Single>())
  else if Left.TypeInfo = System.TypeInfo(Double) then
    Result := SameValue(Left.AsType<Double>(), Right.AsType<Double>())
  else if Left.Kind in [tkChar, tkString, tkWChar, tkLString, tkWString, tkUString] then
    Result := Left.AsString = Right.AsString
  else if Left.IsClass and Right.IsClass then
    Result := Left.AsClass = Right.AsClass
  else if Left.IsObject then
    Result := Left.AsObject = Right.AsObject
  else if (Left.Kind = tkPointer) or (Left.TypeInfo = Right.TypeInfo) then
    begin
      pLeft := nil;
      pRight := nil;
      Left.ExtractRawDataNoCopy(pLeft);
      Right.ExtractRawDataNoCopy(pRight);
    Result := pLeft = pRight;
    end
  else if Left.TypeInfo = System.TypeInfo(Variant) then
    Result := Left.AsVariant = Right.AsVariant
  else if Left.TypeInfo = System.TypeInfo(TGUID) then
    Result := IsEqualGuid( Left.AsType<TGUID>, Right.AsType<TGUID> )
  else
    Result := False;
end;

constructor TplRTTIMemberBind.Create(AObject: TObject;
  const APropertyPath: string; AFunction: TplBridgeFunction);
begin
  // Basic test. We should provide more test to verifiy if property exists, etc.
  if not Assigned(AObject) then
    raise Exception.Create('AObject not assgined');
  if APropertyPath = '' then
    raise Exception.Create('PropertyPath not set');

  FEnabled := True;
  FCalculatedValue := AFunction;
  FElementPath := APropertyPath;
  FElement := AObject;
  FValue := GetValue;
end;

function TplRTTIMemberBind.FirstLeaf(var pathLeafs: string): string;
var
  dot: string;
  i: Integer;
  leafs: TArray<string>;
begin
  if pathLeafs <> '' then
    begin
      leafs := pathLeafs.Split(['.']);
      Result := leafs[0];
      dot := '';
      pathLeafs := '';
      for i := 1 to High(leafs) do
        begin
          pathLeafs := pathLeafs + dot + leafs[i];
          dot := '.';
        end;
    end
  else
    Result := '';
end;

{Get record value when a is a field of a property}
function TplRTTIMemberBind.GetRecordFieldValue(Sender: TObject;
  AOwner: TRttiProperty; AField: TRTTIField): TValue;
var
  MyPointer: Pointer;
begin
    MyPointer := TRttiInstanceProperty(AOwner).PropInfo^.GetProc;
    Result := AField.GetValue(PByte(Sender) + Smallint(MyPointer));
end;

function TplRTTIMemberBind.GetPathValue(ARoot: TObject; var APath: string): TValue;
var
  currentRoot: TObject;
  myContext: TRttiContext;
  myField: TRttiField;
  myProp: TRttiProperty;
  myPath: string;
  leafName: string;
begin
  currentRoot := ARoot;
  myProp := nil;
  myField := nil;
  myPath := APath;
  while myPath <> '' do
    begin
      leafName := FirstLeaf(myPath);
      // 1) localizza la prima foglia, sia prop o field

      myField :=  myContext.GetType(currentRoot.ClassType).GetField(leafName);
      if not Assigned(myField) then
        begin
          myProp := myContext.GetType(ARoot.ClassType).GetProperty(leafName);
        end;

      // 2) esamina se il nodo è un oggetto o un record
        // Caso A: abbiamo a che fare con un oggetto
      if Assigned(myField) then
        begin
          myProp := nil;
          if myField.FieldType.IsRecord then
            begin
              if myPath <> '' then
                begin
                  // trasferisce il controllo alla procedura apposita
                  myPath := leafName + '.' + IfThen(myPath <> '', '.' + myPath, '');
                  Result := GetRecordPathValue(currentRoot, myPath);
                  Exit;
                end;
            end
          else if myField.FieldType.isInstance then
            currentRoot := myField.GetValue(currentRoot).AsObject;
        end
      else if Assigned(myProp) then
        begin
          if myProp.PropertyType.IsRecord then
            begin
              if myPath <> '' then
                begin
                  // trasferisce il controllo alla procedura apposita
                  myPath := leafName + IfThen(myPath <> '', '.' + myPath, '');
                  Result := GetRecordPathValue(currentRoot, myPath);
                  Exit;
                end;
            end
          else if myProp.PropertyType.isInstance then
            currentRoot := myProp.GetValue(currentRoot).AsObject;
        end
      else
        if myPath <> '' then
          raise Exception.Create(FElementPath + ' is not a path to property or field.');
      leafName := FirstLeaf(myPath);
    end;
  // 3) con l'ultimo nodo e la proprietà da impostare, si esegue l'operazione appropriata
    if Assigned(myField) then
      Result := myField.GetValue(currentRoot)
    else if Assigned(myProp) then
      Result := myProp.GetValue(currentRoot)
    else
      raise Exception.Create(FElementPath + ' is not a path to property or field.');
end;

function TplRTTIMemberBind.GetRecordFieldValue(Sender: TObject;
      AOwner, AField: TRTTIField): TValue;
begin
  Result := AField.GetValue(PByte(Sender) + AOwner.Offset);
end;


function TplRTTIMemberBind.GetRecordPathValue(ARoot: TObject;
  var APath: string): TValue;
var
  myContext: TRttiContext;
  myField: TRttiField;
  myFieldRoot: TRttiField;
  myRecField: TRttiField;
  myProp: TRttiProperty;
  myPropRoot: TRttiProperty;
  myPath: string;
  leafName: string;
begin
  myPropRoot := nil;
  myProp := nil;

  myPath := APath;
  leafName := FirstLeaf(myPath);
  // 1) localizza il record, sia prop o field
  myField :=  myContext.GetType(ARoot.ClassType).GetField(leafName);
  myFieldRoot := myField;
  if not Assigned(myField) then
    begin
      myProp := myContext.GetType(ARoot.ClassType).GetProperty(leafName);
      myPropRoot := myProp;
    end;
  // scorre le prop interne. La prima volta potrebbe passare da myProp, poi
  // solo da myField
  while myPath.Contains('.') do
    begin
    leafName := FirstLeaf(myPath);
    if Assigned(myField) then
      myField := myField.FieldType.GetField(leafName)
    else
      myField := myProp.PropertyType.GetField(leafName);
    end;
  if Assigned(myField) then
    myRecField := myField.FieldType.GetField(myPath)
  else
    myRecField := myProp.PropertyType.GetField(myPath);

  try
  if Assigned(myFieldRoot) then
    Result := GetRecordFieldValue(ARoot, myFieldRoot, myRecField)
  else
    Result := GetRecordFieldValue(ARoot, myPropRoot, myRecField);
  except
    on e: Exception do
      raise Exception.Create('Error on setting ' + APath + ': ' + e.Message);
  end;
end;

function TplRTTIMemberBind.GetValue: TValue;
var
  path: string;
begin
  path := FElementPath;
  Result := GetPathValue(FElement, path);
//was  Result := TRTTI.GetPathValue(FElement, FPropertyPath);
end;

function TplRTTIMemberBind.InternalCastTo(const AType: TTypeKind;
  AValue: TValue): TValue;
begin
  case AType of
    tkInteger:
        case AValue.Kind of
          tkString, tkLString, tkWString, tkWChar, tkUString: Result := StrToInt(AValue.AsString);
          tkFloat: Result := Trunc(AValue.AsType<Double>);
        end;
    tkInt64:
        case AValue.Kind of
          tkString, tkLString, tkWString, tkWChar, tkUString: Result := StrToInt64(AValue.AsString);
          tkFloat: Result := Trunc(AValue.AsType<Double>);
        end;
    tkFloat:
        case AValue.Kind of
          tkString, tkLString, tkWString, tkWChar, tkUString: Result := StrToFloat(AValue.AsString);
        end;
    tkString, tkLString, tkWString, tkWChar, tkUString:
        case AValue.Kind of
          tkString, tkLString, tkWString, tkWChar, tkUString: Result := AValue.AsString;
          tkFloat: Result := FloatToStr(AValue.AsType<Double>);
          tkInteger: Result := IntToStr(AValue.AsInteger);
          tkInt64: Result := IntToStr(AValue.AsInt64);
        end
    else
      Result := AValue;
  end;
end;

function TplRTTIMemberBind.IsEqualTo(AStructure: TplRTTIMemberBind): Boolean;
begin
  Result := (Self.Element = AStructure.Element) and
    (Self.PropertyPath = AStructure.PropertyPath);
end;

function TplRTTIMemberBind.ValueChanged: boolean;
var
  newValue: TValue;
begin
  if FEnabled and Assigned(FElement) then
    try
      newValue := GetValue;
      Result := not AreEqual(newValue, FValue); //not newValue.Equals(FValue);
      if Result then
        FValue := GetValue;
    except
      Result := False;
      FEnabled := False;
    end
  else
    Result := False;
end;

{TplRTTIMemberBind}

{Set record value when a is a field of a property}
procedure TplRTTIMemberBind.SetPathValue(ARoot: TObject; var APath: string;
  AValue: TValue);
var
  currentRoot: TObject;
  myContext: TRttiContext;
  myField: TRttiField;
  myProp: TRttiProperty;
  myPath: string;
  leafName: string;
begin
  if not FEnabled then
    Exit;
  if Assigned(FCalculatedValue) then
    FValue := FCalculatedValue(AValue, FValue)
  else
    FValue := AValue;
  currentRoot := ARoot;
  myField := nil;
  myProp := nil;
  myPath := APath;
  while myPath <> '' do
    begin
      leafName := FirstLeaf(myPath);
      // 1) localizza la prima foglia, sia prop o field

      myField :=  myContext.GetType(currentRoot.ClassType).GetField(leafName);
      if not Assigned(myField) then
        begin
          myProp := myContext.GetType(ARoot.ClassType).GetProperty(leafName);
        end;

      // 2) esamina se il nodo è un oggetto o un record
        // Caso A: abbiamo a che fare con un oggetto
      if Assigned(myField) then
        begin
          myProp := nil;
          if myField.FieldType.IsRecord then
            begin
              if myPath <> '' then
                begin
                  // trasferisce il controllo alla procedura apposita
                  myPath := leafName + '.' + IfThen(myPath <> '', '.' + myPath, '');
                  SetRecordPathValue(currentRoot, myPath, FValue);
                  Exit;
                end;
            end
          else if myField.FieldType.isInstance then
            currentRoot := myField.GetValue(currentRoot).AsObject;
        end
      else if Assigned(myProp) then
        begin
          if myProp.PropertyType.IsRecord then
            begin
              if myPath <> '' then
                begin
                  // trasferisce il controllo alla procedura apposita
                  myPath := leafName + IfThen(myPath <> '', '.' + myPath, '');
                  SetRecordPathValue(currentRoot, myPath, FValue);
                  Exit;
                end;
            end
          else if myProp.PropertyType.isInstance then
            currentRoot := myProp.GetValue(currentRoot).AsObject;
        end
      else
        if myPath <> '' then
          raise Exception.Create(FElementPath + ' is not a path to property or field.');
      leafName := FirstLeaf(myPath);
    end;
  // 3) con l'ultimo nodo e la proprietà da impostare, si esegue l'operazione appropriata
    if Assigned(myField) then
      begin
        if (myField.FieldType.TypeKind <> FValue.Kind) then
          FValue := InternalCastTo(myField.FieldType.TypeKind, FValue);
        myField.SetValue(currentRoot, FValue);
      end
    else if Assigned(myProp) then
      begin
        if (myProp.PropertyType.TypeKind <> FValue.Kind) then
          FValue := InternalCastTo(myProp.propertyType.TypeKind, FValue);
        myProp.SetValue(currentRoot, FValue);
      end
    else
      raise Exception.Create(FElementPath + ' is not a path to property or field.');

end;

procedure TplRTTIMemberBind.SetRecordFieldValue(Sender: TObject;
  AOwner: TRttiProperty; AField: TRTTIField; AValue: TValue);
var
  MyPointer: Pointer;
begin
  if (AField.FieldType.TypeKind <> AValue.Kind) then
    AValue := InternalCastTo(AField.FieldType.TypeKind, FValue);
  MyPointer := TRttiInstanceProperty(AOwner).PropInfo^.GetProc;
  AField.SetValue(PByte(Sender) + Smallint(MyPointer), AValue);
end;

{Set record value when a is a field of a field}
procedure TplRTTIMemberBind.SetRecordFieldValue(Sender: TObject;
  AOwner, AField: TRTTIField; AValue: TValue);
begin
  if (AField.FieldType.TypeKind <> AValue.Kind) then
    AValue := InternalCastTo(AField.FieldType.TypeKind, FValue);
  AField.SetValue(PByte(Sender) + AOwner.Offset, AValue);
end;

procedure TplRTTIMemberBind.SetRecordPathValue(ARoot: TObject;
  var APath: string; AValue: TValue);
var
  myContext: TRttiContext;
  myField: TRttiField;
  myFieldRoot: TRttiField;
  myRecField: TRttiField;
  myProp: TRttiProperty;
  myPropRoot: TRttiProperty;
  myPath: string;
  leafName: string;
begin
  myPropRoot := nil;
  myProp := nil;

  myPath := APath;
  leafName := FirstLeaf(myPath);
  // 1) localizza il record, sia prop o field
  myField :=  myContext.GetType(ARoot.ClassType).GetField(leafName);
  myFieldRoot := myField;
  if not Assigned(myField) then
    begin
      myProp := myContext.GetType(ARoot.ClassType).GetProperty(leafName);
      myPropRoot := myProp;
    end;
  // scorre le prop interne. La prima volta potrebbe passare da myProp, poi
  // solo da myField
  while myPath.Contains('.') do
    begin
    leafName := FirstLeaf(myPath);
    if Assigned(myField) then
      myField := myField.FieldType.GetField(leafName)
    else
      myField := myProp.PropertyType.GetField(leafName);
    end;
  if Assigned(myField) then
    myRecField := myField.FieldType.GetField(myPath)
  else
    myRecField := myProp.PropertyType.GetField(myPath);

  try
  if Assigned(myFieldRoot) then
    SetRecordFieldValue(ARoot, myFieldRoot, myRecField, AValue)
  else
    SetRecordFieldValue(ARoot, myPropRoot, myRecField, AValue);
  except
    on e: Exception do
      raise Exception.Create('Error on setting ' + APath + ': ' + e.Message);
  end;

end;

procedure TplRTTIMemberBind.SetValue(Value: TValue);
var
  path: string;
begin
  path := FElementPath;
  SetPathValue(FElement, path, Value);
//was:  QuickLib.RTTI.TRTTI.SetPathValue(FElement, FElementPath, FValue);
end;


{ TplFieldBind }


{ TPlParKeyComparer }

function TPlParKeyComparer.Equals(const Left,
  Right: TplPropertyBind): Boolean;
begin
  Result := (Left.Element = Right.Element) and
    (Left.PropertyPath = Right.PropertyPath);
end;

function TPlParKeyComparer.GetHashCode(
  const Value: TplPropertyBind): Integer;
begin
  Result := THashBobJenkins.GetHashValue(PChar(Value.PropertyPath)^, Length(Value.PropertyPath) * SizeOf(Char), 0);
end;

end.
