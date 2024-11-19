object frmBindApiSimpleDemo: TfrmBindApiSimpleDemo
  Left = 0
  Top = 0
  Caption = 'plBindApi Simple Demo'
  ClientHeight = 642
  ClientWidth = 843
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = mmnMain
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 13
  object bvlOutput: TBevel
    Left = 392
    Top = 8
    Width = 286
    Height = 617
  end
  object bvlInput: TBevel
    Left = 8
    Top = 5
    Width = 289
    Height = 620
  end
  object lblInt: TLabel
    Left = 635
    Top = 168
    Width = 24
    Height = 13
    Caption = 'lblInt'
  end
  object lblIndirectBindingInfo: TLabel
    Left = 24
    Top = 51
    Width = 249
    Height = 105
    AutoSize = False
    Caption = 
      'Test Group 1. The editor above is linked to a property of an ext' +
      'ernal entity by its Text property. '#13#10'The external class uses its' +
      ' value to populate two more properties. '#13#10'Each property is linke' +
      'd to on of the editors on the right. Type anything to propagate ' +
      'of text.'
    WordWrap = True
  end
  object lblLowercaseArrow: TLabel
    Left = 303
    Top = 27
    Width = 63
    Height = 13
    Caption = '-> lowercase'
  end
  object lblUppercaseArrow: TLabel
    Left = 303
    Top = 70
    Width = 73
    Height = 13
    Caption = '-> UPPERCASE'
  end
  object lblSameValueArrow: TLabel
    Left = 303
    Top = 168
    Width = 69
    Height = 13
    Caption = '-> same value'
  end
  object lblDoubleValueArrow: TLabel
    Left = 303
    Top = 195
    Width = 59
    Height = 13
    Caption = '-> value x 2'
  end
  object lblMixedBindingInfo: TLabel
    Left = 24
    Top = 196
    Width = 249
    Height = 140
    AutoSize = False
    Caption = 
      'Test Group 2. The editor above is linked to two properties of an' +
      ' external entity by its Value property. '#13#10'The first is a simple,' +
      ' direct bind. The second one uses a bridge function (Value * 2).' +
      ' The same value is stored into a label caption, with automatic c' +
      'onversion from integer to string. Finally, the TabStyle of the p' +
      'age control is updated too, using the BindApi internal cast. '
    WordWrap = True
  end
  object lblBidirectionalArrow: TLabel
    Left = 330
    Top = 343
    Width = 24
    Height = 13
    Caption = '<-->'
  end
  object lblBidirectionalBindingInfo: TLabel
    Left = 24
    Top = 367
    Width = 249
    Height = 51
    AutoSize = False
    Caption = 
      'Test Group 3. The editor above is linked to one property in a bi' +
      'directional way. The same property is bidirectionally linked to ' +
      'the editor in the right.'
    WordWrap = True
  end
  object lblBidirectionalInfo2: TLabel
    Left = 416
    Top = 367
    Width = 215
    Height = 13
    Caption = 'Type something in the editor above and see!'
  end
  object lblSameTextArrow: TLabel
    Left = 303
    Top = 430
    Width = 63
    Height = 13
    Caption = '-> same text'
  end
  object lblMemoTextInfo: TLabel
    Left = 24
    Top = 535
    Width = 249
    Height = 79
    AutoSize = False
    Caption = 
      'Test Group 4. The memo above is linked to one property of an ext' +
      'ernal class in a monodirectional way. The same property is bound' +
      ' to the Text property of the Memo in the right. Type any text to' +
      ' seet it on the right.'
    WordWrap = True
  end
  object lblValueToEnumArrow: TLabel
    Left = 303
    Top = 225
    Width = 83
    Height = 13
    Caption = '-> value to Enum'
  end
  object lblBinderInterval: TLabel
    Left = 696
    Top = 27
    Width = 75
    Height = 13
    Caption = '&Binder Interval:'
    FocusControl = speInterval
  end
  object edtSource2: TEdit
    Left = 24
    Top = 24
    Width = 249
    Height = 21
    TabOrder = 0
    Text = 'Test'
  end
  object edtTarget2: TEdit
    Left = 416
    Top = 24
    Width = 247
    Height = 21
    TabOrder = 1
  end
  object edtTarget2a: TEdit
    Left = 416
    Top = 67
    Width = 247
    Height = 21
    TabOrder = 2
  end
  object btnTest: TButton
    Left = 588
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Clear'
    TabOrder = 3
  end
  object edtSame: TEdit
    Left = 416
    Top = 165
    Width = 153
    Height = 21
    TabOrder = 4
    Text = 'edtSame'
  end
  object speValue: TSpinEdit
    Left = 24
    Top = 168
    Width = 121
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 5
    Value = 2
  end
  object edtDouble: TEdit
    Left = 416
    Top = 192
    Width = 153
    Height = 21
    TabOrder = 6
    Text = 'edtDouble'
  end
  object edtBidirectional: TEdit
    Left = 24
    Top = 340
    Width = 249
    Height = 21
    TabOrder = 7
    Text = 'Two way'
  end
  object edtBidirectional2: TEdit
    Left = 416
    Top = 340
    Width = 247
    Height = 21
    TabOrder = 8
  end
  object memSource: TMemo
    Left = 24
    Top = 427
    Width = 249
    Height = 102
    ScrollBars = ssBoth
    TabOrder = 9
  end
  object memTarget: TMemo
    Left = 416
    Top = 427
    Width = 247
    Height = 102
    Lines.Strings = (
      'memSource')
    ScrollBars = ssBoth
    TabOrder = 10
  end
  object pctEnum: TPageControl
    Left = 412
    Top = 222
    Width = 247
    Height = 98
    ActivePage = tbsTabA
    TabOrder = 11
    object tbsTabA: TTabSheet
      Caption = 'First tab'
    end
    object tbsTabB: TTabSheet
      Caption = 'Second tab'
      ImageIndex = 1
    end
    object tbsTabC: TTabSheet
      Caption = 'Third tab'
      ImageIndex = 2
    end
  end
  object speInterval: TSpinEdit
    Left = 787
    Top = 24
    Width = 48
    Height = 22
    Hint = 'Change the refresh interval of the binder manager.'
    MaxValue = 2000
    MinValue = 0
    TabOrder = 12
    Value = 0
    OnChange = speIntervalChange
  end
  object mmnMain: TMainMenu
    Left = 736
    Top = 200
    object mitFile: TMenuItem
      Caption = '&File'
      object mitExit: TMenuItem
        Caption = 'E&xit'
      end
    end
    object mitMonitor: TMenuItem
      Caption = '&Monitor'
    end
    object mitHelp: TMenuItem
      Caption = '&Help'
      object mitContents: TMenuItem
        Caption = '&Contents'
      end
      object mitAbout: TMenuItem
        Caption = '&About...'
      end
    end
  end
end
