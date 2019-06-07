object MonitorForm: TMonitorForm
  Left = 0
  Top = 0
  Caption = 'Reader Monitor'
  ClientHeight = 477
  ClientWidth = 851
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
  object OptionsGroupBox: TGroupBox
    Left = 0
    Top = 0
    Width = 225
    Height = 477
    Align = alLeft
    Caption = 'Options'
    TabOrder = 0
    object GroupBox2: TGroupBox
      Left = 2
      Top = 15
      Width = 221
      Height = 218
      Align = alTop
      Caption = 'Mask'
      TabOrder = 0
      object Label1: TLabel
        Left = 7
        Top = 36
        Width = 28
        Height = 13
        Caption = 'String'
      end
      object Label2: TLabel
        Left = 7
        Top = 81
        Width = 19
        Height = 13
        Caption = 'HEX'
      end
      object Label3: TLabel
        Left = 7
        Top = 139
        Width = 85
        Height = 13
        Caption = 'Offset from begin'
      end
      object MaskCheckBox: TCheckBox
        Left = 7
        Top = 16
        Width = 97
        Height = 17
        Caption = 'Enable'
        TabOrder = 0
        OnClick = MaskCheckBoxClick
      end
      object StringMaskEdit: TEdit
        Left = 7
        Top = 55
        Width = 178
        Height = 21
        MaxLength = 12
        TabOrder = 1
        OnChange = StringMaskEditChange
      end
      object SetMaskButton: TBitBtn
        Left = 7
        Top = 179
        Width = 91
        Height = 25
        Caption = 'Set'
        TabOrder = 2
        OnClick = SetMaskButtonClick
      end
      object HexMaskEdit: TEdit
        Left = 7
        Top = 100
        Width = 178
        Height = 21
        MaxLength = 24
        TabOrder = 3
        OnChange = HexMaskEditChange
        OnKeyPress = HexMaskEditKeyPress
      end
      object OffsetMaskSpinEdit: TSpinEdit
        Left = 128
        Top = 136
        Width = 57
        Height = 22
        MaxValue = 11
        MinValue = 0
        TabOrder = 4
        Value = 0
      end
    end
    object GroupBox3: TGroupBox
      Left = 2
      Top = 233
      Width = 221
      Height = 242
      Align = alClient
      Caption = 'Reader Info'
      TabOrder = 1
    end
  end
  object GroupBox1: TGroupBox
    Left = 225
    Top = 0
    Width = 626
    Height = 477
    Align = alClient
    Caption = 'Monitor'
    TabOrder = 1
    object Splitter1: TSplitter
      Left = 2
      Top = 244
      Width = 622
      Height = 3
      Cursor = crVSplit
      Align = alBottom
      ExplicitTop = 219
      ExplicitWidth = 28
    end
    object StringGrid1: TStringGrid
      Left = 2
      Top = 15
      Width = 622
      Height = 229
      Align = alClient
      ColCount = 6
      FixedCols = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSizing, goColSizing]
      TabOrder = 0
    end
    object NotifyMemo: TMemo
      Left = 2
      Top = 247
      Width = 622
      Height = 187
      Align = alBottom
      TabOrder = 1
    end
    object Panel1: TPanel
      Left = 2
      Top = 434
      Width = 622
      Height = 41
      Align = alBottom
      TabOrder = 2
      DesignSize = (
        622
        41)
      object LabelProgram: TLabel
        Left = 113
        Top = 14
        Width = 180
        Height = 13
        Caption = 'You must select TAG for programming'
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentColor = False
        ParentFont = False
      end
      object GetTagsButton: TBitBtn
        Left = 523
        Top = 8
        Width = 91
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Get Tag List'
        TabOrder = 0
        OnClick = GetTagsButtonClick
      end
      object StartMonitorButton: TBitBtn
        Left = 426
        Top = 8
        Width = 91
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Start Monitoring'
        TabOrder = 1
        OnClick = StartMonitorButtonClick
      end
      object ProgramTagButton: TBitBtn
        Left = 11
        Top = 8
        Width = 91
        Height = 25
        Caption = 'Programm TAG'
        TabOrder = 2
        OnClick = ProgramTagButtonClick
      end
    end
  end
  object mReader: TclsReader
    AutoConnect = False
    ConnectKind = ckRunningOrNew
    Left = 720
    Top = 24
  end
  object NotifyServer: TCAlienServer
    AutoConnect = False
    ConnectKind = ckRunningOrNew
    OnServerMessageReceived = NotifyServerServerMessageReceived
    OnServerConnectionEstablished = NotifyServerServerConnectionEstablished
    OnServerConnectionEnded = NotifyServerServerConnectionEnded
    OnServerListeningStarted = NotifyServerServerListeningStarted
    OnServerListeningStopped = NotifyServerServerListeningStopped
    OnServerSocketError = NotifyServerServerSocketError
    Left = 760
    Top = 24
  end
  object AlienUtils1: TAlienUtils
    AutoConnect = False
    ConnectKind = ckRunningOrNew
    Left = 689
    Top = 72
  end
end
