object FormCompetitorDetails: TFormCompetitorDetails
  Left = 0
  Top = 0
  Caption = 'Fahrer Details'
  ClientHeight = 485
  ClientWidth = 525
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object PanelMain: TPanel
    Left = 0
    Top = 0
    Width = 525
    Height = 444
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 523
    ExplicitHeight = 436
    DesignSize = (
      525
      444)
    object Label1: TLabel
      Left = 32
      Top = 24
      Width = 32
      Height = 15
      Caption = 'Klasse'
    end
    object DBCompetitorID: TDBText
      Left = 444
      Top = 24
      Width = 65
      Height = 17
      Anchors = [akTop, akRight]
      ExplicitLeft = 440
    end
    object Label2: TLabel
      Left = 32
      Top = 53
      Width = 70
      Height = 15
      Caption = 'Startnummer'
    end
    object Label3: TLabel
      Left = 300
      Top = 53
      Width = 27
      Height = 15
      Anchors = [akTop, akRight]
      Caption = 'Tx-ID'
      ExplicitLeft = 296
    end
    object Label4: TLabel
      Left = 32
      Top = 99
      Width = 47
      Height = 15
      Caption = 'Vorname'
    end
    object Label5: TLabel
      Left = 300
      Top = 99
      Width = 58
      Height = 15
      Anchors = [akTop, akRight]
      Caption = 'Nachname'
      ExplicitLeft = 296
    end
    object Label6: TLabel
      Left = 32
      Top = 157
      Width = 32
      Height = 15
      Caption = 'Verein'
    end
    object Label7: TLabel
      Left = 32
      Top = 186
      Width = 28
      Height = 15
      Caption = 'Team'
    end
    object Label8: TLabel
      Left = 32
      Top = 227
      Width = 36
      Height = 15
      Caption = 'Nation'
    end
    object Label9: TLabel
      Left = 300
      Top = 227
      Width = 23
      Height = 15
      Anchors = [akTop, akRight]
      Caption = 'Kurz'
      ExplicitLeft = 296
    end
    object Label10: TLabel
      Left = 32
      Top = 128
      Width = 35
      Height = 15
      Caption = 'UCI-ID'
    end
    object Label11: TLabel
      Left = 32
      Top = 275
      Width = 89
      Height = 15
      Caption = 'Handicap-Faktor'
    end
    object Label12: TLabel
      Left = 32
      Top = 323
      Width = 62
      Height = 15
      Caption = 'Zus'#228'tzlich 1'
    end
    object Label13: TLabel
      Left = 32
      Top = 352
      Width = 62
      Height = 15
      Caption = 'Zus'#228'tzlich 2'
    end
    object Label14: TLabel
      Left = 32
      Top = 381
      Width = 62
      Height = 15
      Caption = 'Zus'#228'tzlich 3'
    end
    object DBComboBoxClass: TDBComboBox
      Left = 128
      Top = 21
      Width = 149
      Height = 23
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      ExplicitWidth = 147
    end
    object DBEditBib: TDBEdit
      Left = 128
      Top = 50
      Width = 145
      Height = 23
      TabOrder = 1
    end
    object DBEditFirstName: TDBEdit
      Left = 128
      Top = 96
      Width = 149
      Height = 23
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 3
      ExplicitWidth = 145
    end
    object DBEditLastName: TDBEdit
      Left = 364
      Top = 96
      Width = 145
      Height = 23
      Anchors = [akTop, akRight]
      TabOrder = 4
      ExplicitLeft = 360
    end
    object DBComboBoxClub: TDBComboBox
      Left = 128
      Top = 154
      Width = 381
      Height = 23
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 6
      ExplicitWidth = 379
    end
    object DBComboBoxTeam: TDBComboBox
      Left = 128
      Top = 183
      Width = 381
      Height = 23
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 7
      ExplicitWidth = 379
    end
    object DBComboBoxNationality: TDBComboBox
      Left = 128
      Top = 224
      Width = 145
      Height = 23
      TabOrder = 8
    end
    object DBComboBoxNationalityISO: TDBComboBox
      Left = 364
      Top = 224
      Width = 145
      Height = 23
      Anchors = [akTop, akRight]
      TabOrder = 9
      ExplicitLeft = 362
    end
    object DBEditUCIID: TDBEdit
      Left = 128
      Top = 125
      Width = 145
      Height = 23
      TabOrder = 5
    end
    object DBEditHandicapFactor: TDBEdit
      Left = 128
      Top = 272
      Width = 145
      Height = 23
      TabOrder = 10
    end
    object DBEditTxId: TDBEdit
      Left = 364
      Top = 50
      Width = 145
      Height = 23
      Anchors = [akTop, akRight]
      TabOrder = 2
      ExplicitLeft = 360
    end
    object DBEditAddtional1: TDBEdit
      Left = 128
      Top = 320
      Width = 381
      Height = 23
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 11
      ExplicitWidth = 377
    end
    object DBEditAdditional2: TDBEdit
      Left = 128
      Top = 349
      Width = 381
      Height = 23
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 12
      ExplicitWidth = 377
    end
    object DBEditAdditional3: TDBEdit
      Left = 128
      Top = 378
      Width = 381
      Height = 23
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 13
      ExplicitWidth = 377
    end
  end
  object PanelButtons: TPanel
    Left = 0
    Top = 444
    Width = 525
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 436
    ExplicitWidth = 523
    DesignSize = (
      525
      41)
    object ButtonOK: TButton
      Left = 351
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
      OnClick = ButtonOKClick
      ExplicitLeft = 347
    end
    object ButtonCancel: TButton
      Left = 439
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Abbrechen'
      ModalResult = 2
      TabOrder = 1
      ExplicitLeft = 435
    end
  end
end
