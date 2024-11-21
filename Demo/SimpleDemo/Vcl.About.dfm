object frmAbout: TfrmAbout
  Left = 0
  Top = 0
  Caption = 'About...'
  ClientHeight = 167
  ClientWidth = 384
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsStayOnTop
  TextHeight = 15
  object lblShortMessage: TLabel
    Left = 0
    Top = 40
    Width = 400
    Height = 15
    Alignment = taCenter
    AutoSize = False
    Caption = 'Built with BindAPI framework.'
  end
  object btnOk: TButton
    Left = 165
    Top = 104
    Width = 52
    Height = 25
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
end
