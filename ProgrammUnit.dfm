object ProgrammForm: TProgrammForm
  Left = 0
  Top = 0
  Caption = 'Programm Tag'
  ClientHeight = 306
  ClientWidth = 630
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 630
    Height = 120
    Align = alTop
    Caption = 'Reading Tag'
    TabOrder = 0
    object ErrorReadingLabel: TLabel
      Left = 3
      Top = 45
      Width = 302
      Height = 21
      Alignment = taCenter
      AutoSize = False
      Caption = 'ErrorReadingLabel'
      Visible = False
      WordWrap = True
    end
    object Label1: TLabel
      Left = 5
      Top = 21
      Width = 32
      Height = 14
      Caption = 'Tag ID'
    end
    object Label2: TLabel
      Left = 321
      Top = 21
      Width = 45
      Height = 14
      Caption = 'EPC Data'
    end
    object Label3: TLabel
      Left = 321
      Top = 48
      Width = 50
      Height = 16
      Caption = 'EPC String'
    end
    object VersionLabel: TLabel
      Left = 3
      Top = 72
      Width = 302
      Height = 13
      Alignment = taCenter
      AutoSize = False
      Caption = 'Version'
      Visible = False
      WordWrap = True
    end
    object TypeLabel: TLabel
      Left = 3
      Top = 91
      Width = 302
      Height = 13
      Alignment = taCenter
      AutoSize = False
      Caption = 'Type'
      Visible = False
      WordWrap = True
    end
    object TagIdEdit: TEdit
      Left = 64
      Top = 18
      Width = 241
      Height = 21
      Alignment = taCenter
      ReadOnly = True
      TabOrder = 0
    end
    object EPCEdit: TEdit
      Left = 380
      Top = 18
      Width = 241
      Height = 21
      Alignment = taCenter
      ReadOnly = True
      TabOrder = 1
      OnChange = EPCEditChange
    end
    object EPCStringEdit: TEdit
      Left = 380
      Top = 45
      Width = 241
      Height = 21
      Alignment = taCenter
      ReadOnly = True
      TabOrder = 2
    end
  end
  object ProgrammingGroupBox: TGroupBox
    Left = 0
    Top = 120
    Width = 630
    Height = 186
    Align = alClient
    Caption = 'Programming'
    TabOrder = 1
    ExplicitLeft = 256
    ExplicitTop = 184
    ExplicitWidth = 185
    ExplicitHeight = 105
    object AntennaPowerLabel: TLabel
      Left = 169
      Top = 45
      Width = 68
      Height = 13
      Caption = 'RF Power (%)'
    end
    object AntennaRadioGroup: TRadioGroup
      Left = 2
      Top = 15
      Width = 296
      Height = 169
      Align = alLeft
      Caption = 'Antenna'
      Items.Strings = (
        '0'
        '1'
        '2'
        '3')
      TabOrder = 0
      ExplicitHeight = 166
    end
    object GroupBox3: TGroupBox
      Left = 298
      Top = 15
      Width = 330
      Height = 169
      Align = alClient
      Caption = 'Writing Data'
      TabOrder = 1
      ExplicitLeft = 304
      object Label5: TLabel
        Left = 23
        Top = 21
        Width = 45
        Height = 13
        Caption = 'EPC Data'
      end
      object Label6: TLabel
        Left = 23
        Top = 48
        Width = 50
        Height = 13
        Caption = 'EPC String'
      end
      object ErrorWritingLabel: TLabel
        Left = 23
        Top = 114
        Width = 298
        Height = 39
        Alignment = taCenter
        AutoSize = False
        Caption = 'ErrorWritingLabel'
        Visible = False
        WordWrap = True
      end
      object EPCWriteEdit: TEdit
        Left = 82
        Top = 18
        Width = 241
        Height = 21
        Alignment = taCenter
        MaxLength = 24
        TabOrder = 0
        OnChange = EPCWriteEditChange
        OnKeyPress = EPCWriteEditKeyPress
      end
      object EPCStringWriteEdit: TEdit
        Left = 82
        Top = 45
        Width = 241
        Height = 21
        Alignment = taCenter
        MaxLength = 12
        TabOrder = 1
        OnChange = EPCStringWriteEditChange
      end
      object WriteButton: TBitBtn
        Left = 131
        Top = 83
        Width = 91
        Height = 25
        Caption = 'WRITE !'
        TabOrder = 2
        OnClick = WriteButtonClick
      end
    end
    object TrackBar1: TTrackBar
      Left = 120
      Top = 80
      Width = 161
      Height = 61
      Max = 100
      Frequency = 10
      Position = 100
      TabOrder = 2
      OnChange = TrackBar1Change
    end
  end
  object mReader: TclsReader
    AutoConnect = False
    ConnectKind = ckRunningOrNew
    Left = 554
    Top = 80
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = Timer1Timer
    Left = 592
    Top = 80
  end
end
