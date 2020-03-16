object frmBindApiSimpleDemo: TfrmBindApiSimpleDemo
  Left = 0
  Top = 0
  Caption = 'plBindApi Simple Demo'
  ClientHeight = 307
  ClientWidth = 442
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object lblCounter2: TLabel
    Left = 351
    Top = 27
    Width = 6
    Height = 13
    Caption = '0'
  end
  object edtSource2: TEdit
    Left = 16
    Top = 24
    Width = 200
    Height = 21
    TabOrder = 0
    Text = 'Test'
  end
  object edtTarget2: TEdit
    Left = 218
    Top = 24
    Width = 200
    Height = 21
    TabOrder = 1
  end
  object edtTarget2a: TEdit
    Left = 218
    Top = 56
    Width = 200
    Height = 21
    TabOrder = 2
  end
  object btnTest: TButton
    Left = 343
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Clear'
    TabOrder = 3
  end
  object edtSame: TEdit
    Left = 218
    Top = 160
    Width = 121
    Height = 21
    TabOrder = 4
    Text = 'edtSame'
  end
  object speValue: TSpinEdit
    Left = 16
    Top = 160
    Width = 121
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 5
    Value = 0
  end
  object edtDouble: TEdit
    Left = 218
    Top = 200
    Width = 121
    Height = 21
    TabOrder = 6
    Text = 'edtDouble'
  end
end
