object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'SmartTiming'
  ClientHeight = 59
  ClientWidth = 482
  Color = clBackground
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object PanelMain: TPanel
    Left = 0
    Top = 0
    Width = 482
    Height = 10
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
  end
  object PanelStatus: TPanel
    AlignWithMargins = True
    Left = 0
    Top = 10
    Width = 482
    Height = 49
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alBottom
    BevelKind = bkFlat
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 1
    object PanelDecoder: TPanel
      Left = 0
      Top = 0
      Width = 401
      Height = 45
      Align = alLeft
      BevelOuter = bvNone
      ShowCaption = False
      TabOrder = 0
      object LabelDecoderIpAddress: TLabel
        Left = 8
        Top = 23
        Width = 56
        Height = 15
        Caption = 'IP-Adresse'
      end
      object LabelDecoderId: TLabel
        Left = 8
        Top = 2
        Width = 134
        Height = 15
        Caption = 'Decoder nicht verbunden'
      end
      object LabelDecoderTemperature: TLabel
        Left = 248
        Top = 2
        Width = 60
        Height = 15
        Caption = 'Temperatur'
      end
      object LabelDecoderNoiseLevel: TLabel
        Left = 248
        Top = 23
        Width = 71
        Height = 15
        Caption = 'St'#246'rungslevel'
      end
    end
  end
end
