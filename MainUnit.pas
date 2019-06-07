unit MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.OleServer, AlienRFID2_TLB, ActiveX, Vcl.Grids, Vcl.ExtCtrls;

type
  TMainForm = class(TForm)
    clsReaderMonitor1: TclsReaderMonitor;
    StartListeningButton: TBitBtn;
    ReaderInfo1: TReaderInfo;
    StopListeningButton: TBitBtn;
    StringGrid1: TStringGrid;
    ConnectButton: TBitBtn;
    GetTagsButton: TBitBtn;
    mReader: TclsReader;
    Panel1: TPanel;
    Timer1: TTimer;
    Memo1: TMemo;
    MonitorButton: TBitBtn;
    procedure StartListeningButtonClick(Sender: TObject);
    procedure clsReaderMonitor1ReaderAdded(ASender: TObject;
      const data: IReaderInfo);
    procedure clsReaderMonitor1ReaderRemoved(ASender: TObject;
      const data: IReaderInfo);
    procedure clsReaderMonitor1ReaderRenewed(ASender: TObject;
      const data: IReaderInfo);
    procedure StopListeningButtonClick(Sender: TObject);
    procedure ConnectButtonClick(Sender: TObject);
    procedure GetTagsButtonClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure MonitorButtonClick(Sender: TObject);
  private
    { Private declarations }
    FListening:boolean;
    FConnected:boolean;
    tfs:TFormatSettings;

//    ReadersArray:array of IReaderInfo;
    procedure setListening(const Value: boolean);
    procedure fillScanners;
    procedure setConnected(const Value: boolean);
    procedure WriteLog(OutString: string);
  public
    { Public declarations }
    property Listening:boolean read FListening write setListening;
    property Connected:boolean read FConnected write setConnected;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses MonitorUnit, CommonUnit;

procedure TMainForm.StartListeningButtonClick(Sender: TObject);
begin
  WriteLog('Start Listening');
  Listening:=true;
end;

procedure TMainForm.StopListeningButtonClick(Sender: TObject);
begin
  WriteLog('Stop Listening');
  Listening:=false;
end;


procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled:=false;
  fillScanners;
//  Timer1.Enabled:=true;
end;

procedure TMainForm.ConnectButtonClick(Sender: TObject);
begin
  WriteLog('try to '+TBitBtn(Sender).caption);
  Connected:=not(Connected);
end;

procedure TMainForm.GetTagsButtonClick(Sender: TObject);
var sTagList:string;
  result:boolean;
begin
  if not Connected then
    exit;
  mReader.TagListFormat:='XML';
  mReader.TagListFormat:='Text';
  mReader.TagListFormat:='Custom';
  mReader.TagListCustomFormat:= '%i, %k, %a, %D %T, %p, %l';
  sTagList:=mReader.TagList;
  showmessage(sTagList);
end;

procedure TMainForm.clsReaderMonitor1ReaderAdded(ASender: TObject;
  const data: IReaderInfo);
begin
  WriteLog('Found New Reader');
  Timer1.Enabled:=true;
end;

procedure TMainForm.clsReaderMonitor1ReaderRemoved(ASender: TObject;
  const data: IReaderInfo);
begin
  WriteLog('Remove Reader');
  Timer1.Enabled:=true;
end;

procedure TMainForm.clsReaderMonitor1ReaderRenewed(ASender: TObject;
  const data: IReaderInfo);
begin
  Timer1.Enabled:=true;
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
  tfs:=tformatSettings.create(LOCALE_SYSTEM_DEFAULT);
  Connected:=false;
  Listening:=false;
  StringGrid1.cells[0,0]:='Name';
  StringGrid1.cells[1,0]:='IP Address';
  StringGrid1.cells[2,0]:='Type';
  StringGrid1.cells[3,0]:='MAC Address';
  StringGrid1.cells[4,0]:='Latest Heartbeat';
  fillScanners;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Connected:=false;
  Listening:=false;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  MyGridSize(StringGrid1)
end;

procedure TMainForm.setConnected(const Value: boolean);
var s:String;
    ip:String;
    r,c:integer;
    result:boolean;
    TimeZone: TTimeZoneInformation;
begin
  if Value then
  begin
    if StringGrid1.Row>0 then
    begin
      ip:=StringGrid1.Cells[1, StringGrid1.Row];
    end;

    if ip<>'' then
    begin

      if not(mReader.IsConnected) then
      begin
        mReader.InitOnNetwork(ip,23);
        s:=mReader.Connect1;
      end;
      if mReader.IsConnected then
      begin
        result:=mReader.Login('alien', 'password');

        if not result then
        begin
          WriteLog('Login failed! Calling Disconnect()...');
          mReader.Disconnect();
        end;
        //to make it faster and not to lose any tag
    		mReader.AutoMode:= 'On';
        GetTimeZoneInformation(TimeZone);
        mReader.TimeServer:='132.163.4.101 132.163.4.102 132.163.4.103 129.6.15.28 129.6.15.29 129.6.15.30 192.43.244.18';
        mReader.TimeZone:=IntToStr(TimeZone.Bias div -60);
      end;
    end;
  end
  else
  begin
    if mReader.IsConnected then
      s:=mReader.Disconnect1;
  end;

  application.ProcessMessages;

  FConnected := mReader.IsConnected;

  GetTagsButton.Enabled:=FConnected;
  MonitorButton.Enabled:=FConnected;

  if FConnected then
    ConnectButton.Caption:='Disconnect'
  else
    ConnectButton.Caption:='Connect';

  if FConnected then
    WriteLog('Connected')
  else
    WriteLog('Disconnected');
end;

procedure TMainForm.setListening(const Value: boolean);
begin
  if Value then
  begin
    clsReaderMonitor1.NetworkMonitoring:=true;
    clsReaderMonitor1.UpdateInterval:=5000;
    clsReaderMonitor1.StartListening;
    if clsReaderMonitor1.IsListening then
    begin
      StartListeningButton.Enabled:=false;
      StopListeningButton.Enabled:=true;
      FListening := Value
    end
    else
      Listening:=false;
  end
  else
  begin
    if clsReaderMonitor1.IsListening then
      clsReaderMonitor1.StopListening;
    StartListeningButton.Enabled:=true;
    StopListeningButton.Enabled:=false;
    FListening := Value;
  end;
end;

procedure TMainForm.fillScanners;
var
  ReaderInfo:IReaderInfo;
  ReaderInfoArray:array of IReaderInfo;
  SafeArray: PSafeArray;
  s:String;
  i:integer;
  iLow, iHigh : Integer;
begin
  application.ProcessMessages;
  i:=clsReaderMonitor1.GetReaderListOnNetwork(SafeArray);
  if i=0 then
  begin
    StringGrid1.RowCount:=2;
    StringGrid1.cells[0,1]:='';
    StringGrid1.cells[1,1]:='';
    StringGrid1.cells[2,1]:='';
    StringGrid1.cells[3,1]:='';
    StringGrid1.cells[4,1]:='';
  end
  else
    StringGrid1.RowCount:=i+1;

  if i>0 then
  begin
    SetLength(ReaderInfoArray,i);

    SafeArrayGetLBound(SafeArray,1,iLow);
    SafeArrayGetUBound(SafeArray,1,iHigh);
    for i:=iLow to iHigh do
    begin
      SafeArrayGetElement(SafeArray,i,readerInfo);
      ReaderInfoArray[i]:=ReaderInfo;
      StringGrid1.cells[0,i+1]:=ReaderInfo.name;
      StringGrid1.cells[1,i+1]:=ReaderInfo.IPAddress;
      StringGrid1.cells[2,i+1]:=ReaderInfo.type_;
      StringGrid1.cells[3,i+1]:=ReaderInfo.MACAddress;
      StringGrid1.cells[4,i+1]:=IntToStr(ReaderInfo.LatestHeartbeat  div 1000);
    end;
  end;
  StringGrid1.Options:=StringGrid1.Options + [goColSizing] -[goFixedRowClick];
  MyGridSize(StringGrid1);
  application.ProcessMessages;
end;

procedure TMainForm.MonitorButtonClick(Sender: TObject);
begin
  if MonitorForm=nil then
  begin
    try
      MonitorForm:=TMonitorForm.create(Application);
    finally

    end;
  end;
  if MonitorForm<>nil then
  begin
    try
      MonitorForm.mReader:=mReader;
      MonitorForm.showmodal;
    finally
      MonitorForm.free;
      MonitorForm:=nil;
    end;
  end;
end;

procedure TMainForm.WriteLog(OutString:string);
var i:integer;
begin
  if Memo1.Lines.count>=1024 then
    for i:=0 to 127 do
      try
        memo1.Lines.Delete(0);
      finally
      end;
  Memo1.Lines.add(DateTimeToStr(now(),tfs)+'->'+OutString);
end;

end.
