object FormMain: TFormMain
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'SmartStarting Main'
  ClientHeight = 614
  ClientWidth = 1000
  Color = clDefault
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnResize = FormResize
  TextHeight = 15
  object PanelTime: TPanel
    Left = 0
    Top = 250
    Width = 1000
    Height = 256
    Align = alClient
    BevelOuter = bvNone
    Caption = '12:23:45'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHighlightText
    Font.Height = -240
    Font.Name = 'Microsoft New Tai Lue'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
  end
  object PanelCompetitorInfo: TPanel
    Left = 0
    Top = 0
    Width = 1000
    Height = 250
    Align = alTop
    Alignment = taLeftJustify
    BevelOuter = bvNone
    Caption = '  123'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHighlightText
    Font.Height = -160
    Font.Name = 'Doppio One'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    object LabelCompetitorInfo: TLabel
      Left = 478
      Top = 0
      Width = 522
      Height = 250
      Align = alRight
      Anchors = [akLeft, akTop, akRight, akBottom]
      Caption = 'Jenc, Michael RSG Ried Rastatt'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clHighlightText
      Font.Height = -53
      Font.Name = 'Consolas'
      Font.Style = []
      ParentFont = False
      WordWrap = True
      ExplicitLeft = 416
      ExplicitHeight = 124
    end
  end
  object PanelControls: TPanel
    Left = 0
    Top = 506
    Width = 1000
    Height = 108
    Align = alBottom
    BevelOuter = bvNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    DesignSize = (
      1000
      108)
    object ButtonExit: TButton
      Left = 808
      Top = 16
      Width = 161
      Height = 57
      Anchors = [akTop, akRight, akBottom]
      Caption = 'Exit'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clHighlightText
      Font.Height = -27
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = ButtonExitClick
    end
  end
  object TimerSeconds: TTimer
    Enabled = False
    OnTimer = TimerSecondsTimer
    Left = 392
    Top = 546
  end
end
