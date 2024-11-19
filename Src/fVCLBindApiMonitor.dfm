object frmBindApiMonitor: TfrmBindApiMonitor
  Left = 0
  Top = 0
  Caption = 'plBindApi Monitor'
  ClientHeight = 472
  ClientWidth = 914
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  Menu = mmuMain
  Visible = True
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 13
  object pctMonitor: TPageControl
    Left = 0
    Top = 0
    Width = 914
    Height = 472
    ActivePage = tbsBinderMonitor
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 904
    ExplicitHeight = 454
    object tbsBinderMonitor: TTabSheet
      Caption = 'Binder'
      object lblInterval: TLabel
        Left = 256
        Top = 16
        Width = 42
        Height = 13
        Caption = 'Interval:'
      end
      object lblBindingNumber: TLabel
        Left = 472
        Top = 16
        Width = 77
        Height = 13
        Caption = 'Binding number:'
      end
      object chkBinderEnabled: TCheckBox
        Left = 24
        Top = 16
        Width = 113
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Binder Enabled:'
        TabOrder = 0
      end
      object edtInterval: TEdit
        Left = 304
        Top = 14
        Width = 33
        Height = 21
        ReadOnly = True
        TabOrder = 1
      end
      object edtBindingNumber: TEdit
        Left = 555
        Top = 13
        Width = 33
        Height = 21
        ReadOnly = True
        TabOrder = 2
      end
      object sgrBindList: TStringGrid
        Left = 0
        Top = 48
        Width = 906
        Height = 396
        Align = alBottom
        Anchors = [akLeft, akTop, akRight, akBottom]
        ColCount = 7
        DefaultColWidth = 130
        FixedCols = 0
        TabOrder = 3
        OnMouseEnter = sgrBindListMouseEnter
        OnMouseLeave = sgrBindListMouseLeave
        ExplicitWidth = 896
        ExplicitHeight = 378
        ColWidths = (
          130
          130
          130
          130
          130
          130
          130)
        RowHeights = (
          24
          24
          24
          24
          24)
      end
    end
    object tbsClasses: TTabSheet
      Caption = 'Classes'
      ImageIndex = 1
      object pnlRegisteredClasses: TPanel
        Left = 0
        Top = 0
        Width = 906
        Height = 185
        Align = alTop
        TabOrder = 0
        ExplicitWidth = 896
        object lblRegisteredClassesTitle: TLabel
          Left = 1
          Top = 1
          Width = 904
          Height = 13
          Align = alTop
          Alignment = taCenter
          AutoSize = False
          Caption = 'Registered classes - Total:'
          ExplicitTop = -5
          ExplicitWidth = 774
        end
        object sgrRegisteredClasses: TStringGrid
          Left = 1
          Top = 14
          Width = 904
          Height = 170
          Align = alClient
          ColCount = 3
          DefaultColWidth = 200
          FixedCols = 0
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
          TabOrder = 0
          OnMouseEnter = sgrRegisteredClassesMouseEnter
          OnMouseLeave = sgrRegisteredClassesMouseLeave
          ColWidths = (
            200
            200
            200)
          RowHeights = (
            24
            24
            24
            24
            24)
        end
      end
    end
  end
  object tmrUpdate: TTimer
    Enabled = False
    OnTimer = tmrUpdateTimer
    Left = 708
    Top = 240
  end
  object mmuMain: TMainMenu
    Left = 428
    Top = 272
    object mitFile: TMenuItem
      Caption = '&File'
      object mitExit: TMenuItem
        Caption = '&Exit'
        OnClick = mitExitClick
      end
    end
  end
end
