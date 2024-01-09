object FormMain: TFormMain
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'SmartStarting Main'
  ClientHeight = 614
  ClientWidth = 1000
  Color = clBackground
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Microsoft New Tai Lue'
  Font.Style = []
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  TextHeight = 17
  object PanelTime: TPanel
    Left = 0
    Top = 250
    Width = 1000
    Height = 256
    Align = alClient
    BevelOuter = bvNone
    Caption = '12:23:45'
    Color = clBackground
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
      Left = 400
      Top = 0
      Width = 600
      Height = 250
      Margins.Left = 400
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alRight
      Alignment = taCenter
      AutoSize = False
      Caption = 'Jenc, Michael RSG Ried Rastatt'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clHighlightText
      Font.Height = -53
      Font.Name = 'Consolas'
      Font.Style = []
      ParentFont = False
      WordWrap = True
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
    object ButtonSwitchDarkMode: TButton
      Left = 641
      Top = 16
      Width = 161
      Height = 57
      Anchors = [akTop, akRight, akBottom]
      Caption = 'Hell/Dunkel'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clHighlightText
      Font.Height = -27
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = ButtonSwitchDarkModeClick
    end
    object ButtonIntervalSettings: TButton
      Left = 474
      Top = 16
      Width = 161
      Height = 57
      Anchors = [akTop, akRight, akBottom]
      Caption = 'Intervalle'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clHighlightText
      Font.Height = -27
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = ButtonIntervalSettingsClick
    end
    object ButtonImportStartingList: TButton
      Left = 232
      Top = 16
      Width = 236
      Height = 57
      Anchors = [akTop, akRight, akBottom]
      Caption = 'Startlistenimport'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clHighlightText
      Font.Height = -27
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      OnClick = ButtonImportStartingListClick
    end
  end
  object TimerSeconds: TTimer
    Enabled = False
    OnTimer = TimerSecondsTimer
    Left = 392
    Top = 546
  end
  object FileOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'CSV'
        FileMask = '*.csv'
      end>
    Options = []
    Left = 64
    Top = 554
  end
end
