object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Alien Scan'
  ClientHeight = 425
  ClientWidth = 569
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnClose = FormClose
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object StringGrid1: TStringGrid
    Left = 0
    Top = 0
    Width = 569
    Height = 201
    Align = alTop
    FixedCols = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSizing, goColSizing]
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 201
    Width = 569
    Height = 41
    Align = alTop
    TabOrder = 1
    ExplicitTop = 195
    object StartListeningButton: TBitBtn
      Left = 8
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Start Listening'
      TabOrder = 0
      OnClick = StartListeningButtonClick
    end
    object StopListeningButton: TBitBtn
      Left = 89
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Stop Listening'
      TabOrder = 1
      OnClick = StopListeningButtonClick
    end
    object ConnectButton: TBitBtn
      Left = 170
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Connect'
      TabOrder = 2
      OnClick = ConnectButtonClick
    end
    object GetTagsButton: TBitBtn
      Left = 486
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Get Tag List'
      TabOrder = 3
      OnClick = GetTagsButtonClick
    end
    object MonitorButton: TBitBtn
      Left = 405
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Monitor'
      TabOrder = 4
      OnClick = MonitorButtonClick
    end
  end
  object Memo1: TMemo
    Left = 0
    Top = 242
    Width = 569
    Height = 183
    Align = alClient
    TabOrder = 2
  end
  object clsReaderMonitor1: TclsReaderMonitor
    AutoConnect = False
    ConnectKind = ckRunningOrNew
    OnReaderAdded = clsReaderMonitor1ReaderAdded
    OnReaderRemoved = clsReaderMonitor1ReaderRemoved
    OnReaderRenewed = clsReaderMonitor1ReaderRenewed
    Left = 32
    Top = 16
  end
  object ReaderInfo1: TReaderInfo
    AutoConnect = False
    ConnectKind = ckRunningOrNew
    Left = 32
    Top = 56
  end
  object mReader: TclsReader
    AutoConnect = False
    ConnectKind = ckRunningOrNew
    Left = 128
    Top = 16
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 312
    Top = 120
  end
end
