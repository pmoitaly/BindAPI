object frmBindApiSimpleDemo: TfrmBindApiSimpleDemo
  Left = 0
  Top = 0
  Caption = 'plBindApi Simple Demo'
  ClientHeight = 419
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
  object bvlInput: TBevel
    Left = 8
    Top = 8
    Width = 204
    Height = 371
  end
  object bvlOutput: TBevel
    Left = 224
    Top = 8
    Width = 210
    Height = 345
  end
  object lblInt: TLabel
    Left = 368
    Top = 160
    Width = 24
    Height = 13
    Caption = 'lblInt'
  end
  object lblIndirectBinding: TLabel
    Left = 24
    Top = 56
    Width = 177
    Height = 138
    AutoSize = False
    Caption = 
      'The editor above il linked to a property of an external class by' +
      ' its Text property. '#13#10'The external class use its value to popula' +
      'te two more properties. '#13#10'Each property is linked to on of the e' +
      'ditors on the right: if you change the text above, they are upda' +
      'ted with the text in lowercase and uppercas.'
    WordWrap = True
  end
  object edtSource2: TEdit
    Left = 16
    Top = 24
    Width = 185
    Height = 21
    TabOrder = 0
    Text = 'Test'
  end
  object edtTarget2: TEdit
    Left = 232
    Top = 24
    Width = 186
    Height = 21
    TabOrder = 1
  end
  object edtTarget2a: TEdit
    Left = 232
    Top = 56
    Width = 186
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
    Left = 232
    Top = 160
    Width = 121
    Height = 21
    TabOrder = 4
    Text = 'edtSame'
  end
  object speValue: TSpinEdit
    Left = 24
    Top = 200
    Width = 121
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 5
    Value = 2
  end
  object edtDouble: TEdit
    Left = 232
    Top = 200
    Width = 121
    Height = 21
    TabOrder = 6
    Text = 'edtDouble'
  end
  object edtBidirectional: TEdit
    Left = 24
    Top = 264
    Width = 121
    Height = 21
    TabOrder = 7
  end
  object edtBidirectional2: TEdit
    Left = 232
    Top = 264
    Width = 121
    Height = 21
    TabOrder = 8
  end
end
