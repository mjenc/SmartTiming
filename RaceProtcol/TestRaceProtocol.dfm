object FormLapProtocolTest: TFormLapProtocolTest
  Left = 0
  Top = 0
  Caption = 'Test LapProtocol'
  ClientHeight = 354
  ClientWidth = 1294
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object PanelLapProtocol: TPanel
    Left = 0
    Top = 121
    Width = 1294
    Height = 233
    Align = alClient
    TabOrder = 0
  end
  object PanelAddPassings: TPanel
    Left = 0
    Top = 0
    Width = 1294
    Height = 121
    Align = alTop
    TabOrder = 1
    object EditBib: TEdit
      Left = 80
      Top = 32
      Width = 121
      Height = 23
      NumbersOnly = True
      TabOrder = 0
    end
    object ButtonAddPassing: TButton
      Left = 224
      Top = 31
      Width = 121
      Height = 25
      Caption = 'AddPassing'
      TabOrder = 1
      OnClick = ButtonAddPassingClick
    end
    object ButtonClearAll: TButton
      Left = 1016
      Top = 31
      Width = 97
      Height = 25
      Caption = 'ButtonClearAll'
      TabOrder = 2
      OnClick = ButtonClearAllClick
    end
    object ButtonAddSeries: TButton
      Left = 224
      Top = 72
      Width = 121
      Height = 25
      Caption = 'Add Series'
      TabOrder = 3
      OnClick = ButtonAddSeriesClick
    end
    object ButtonWarmUp: TButton
      Left = 400
      Top = 31
      Width = 75
      Height = 25
      Caption = 'WarmUp'
      TabOrder = 4
      OnClick = ButtonWarmUpClick
    end
    object ButtonStartRace: TButton
      Left = 481
      Top = 31
      Width = 75
      Height = 25
      Caption = 'Start Race'
      TabOrder = 5
      OnClick = ButtonStartRaceClick
    end
    object ButtonNeutralize: TButton
      Left = 562
      Top = 31
      Width = 75
      Height = 25
      Caption = 'Neutralize'
      TabOrder = 6
      OnClick = ButtonNeutralizeClick
    end
    object ButtonFinalLap: TButton
      Left = 643
      Top = 31
      Width = 75
      Height = 25
      Caption = 'Final Lap'
      TabOrder = 7
      OnClick = ButtonFinalLapClick
    end
    object ButtonFinish: TButton
      Left = 724
      Top = 31
      Width = 75
      Height = 25
      Caption = 'Finish'
      TabOrder = 8
      OnClick = ButtonFinishClick
    end
    object ButtonStop: TButton
      Left = 805
      Top = 31
      Width = 75
      Height = 25
      Caption = 'Stop'
      TabOrder = 9
      OnClick = ButtonStopClick
    end
    object ButtonNewLeader: TButton
      Left = 886
      Top = 31
      Width = 75
      Height = 25
      Caption = 'New Leader'
      TabOrder = 10
      OnClick = ButtonNewLeaderClick
    end
  end
end
