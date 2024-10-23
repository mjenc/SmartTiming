object FormPZFStartList: TFormPZFStartList
  Left = 0
  Top = 0
  Caption = 'FormPZFStartList'
  ClientHeight = 232
  ClientWidth = 354
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Label1: TLabel
    Left = 32
    Top = 16
    Width = 76
    Height = 15
    Caption = 'Benutzername'
  end
  object Label2: TLabel
    Left = 32
    Top = 45
    Width = 51
    Height = 15
    Caption = 'Kennwort'
  end
  object Label3: TLabel
    Left = 32
    Top = 74
    Width = 97
    Height = 15
    Caption = 'Applikationsserver'
  end
  object Label4: TLabel
    Left = 32
    Top = 103
    Width = 57
    Height = 15
    Caption = 'Datenbank'
  end
  object EditUsername: TEdit
    Left = 144
    Top = 13
    Width = 169
    Height = 23
    TabOrder = 0
    Text = 'Administrator'
  end
  object EditPassword: TEdit
    Left = 144
    Top = 42
    Width = 169
    Height = 23
    PasswordChar = '*'
    TabOrder = 1
  end
  object EditAppServer: TEdit
    Left = 144
    Top = 71
    Width = 169
    Height = 23
    TabOrder = 2
  end
  object ComboBoxDatabase: TComboBox
    Left = 144
    Top = 100
    Width = 169
    Height = 23
    TabOrder = 3
    Text = 'PZF'
  end
  object ButtonLogon: TButton
    Left = 32
    Top = 144
    Width = 75
    Height = 25
    Caption = 'Anmelden'
    TabOrder = 4
    OnClick = ButtonLogonClick
  end
end
