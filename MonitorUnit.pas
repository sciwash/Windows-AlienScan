unit MonitorUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleServer, AlienRFID2_TLB,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.Grids, ActiveX, Vcl.ExtCtrls, StrUtils,
  Vcl.Samples.Spin;

type
  TMonitorForm = class(TForm)
    mReader: TclsReader;
    GetTagsButton: TBitBtn;
    OptionsGroupBox: TGroupBox;
    GroupBox1: TGroupBox;
    StringGrid1: TStringGrid;
    NotifyMemo: TMemo;
    NotifyServer: TCAlienServer;
    AlienUtils1: TAlienUtils;
    StartMonitorButton: TBitBtn;
    MaskCheckBox: TCheckBox;
    GroupBox2: TGroupBox;
    StringMaskEdit: TEdit;
    SetMaskButton: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    HexMaskEdit: TEdit;
    OffsetMaskSpinEdit: TSpinEdit;
    Label3: TLabel;
    Panel1: TPanel;
    Splitter1: TSplitter;
    ProgramTagButton: TBitBtn;
    LabelProgram: TLabel;
    GroupBox3: TGroupBox;
    procedure GetTagsButtonClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure StartMonitorButtonClick(Sender: TObject);
    procedure NotifyServerServerMessageReceived(ASender: TObject;
      const msg: WideString);
    procedure NotifyServerServerConnectionEstablished(ASender: TObject;
      const guid: WideString);
    procedure NotifyServerServerConnectionEnded(ASender: TObject;
      const guid: WideString);
    procedure NotifyServerServerListeningStarted(Sender: TObject);
    procedure NotifyServerServerListeningStopped(Sender: TObject);
    procedure NotifyServerServerSocketError(ASender: TObject;
      const msg: WideString);
    procedure MaskCheckBoxClick(Sender: TObject);
    procedure SetMaskButtonClick(Sender: TObject);
    procedure HexMaskEditKeyPress(Sender: TObject; var Key: Char);
    procedure HexMaskEditChange(Sender: TObject);
    procedure StringMaskEditChange(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ProgramTagButtonClick(Sender: TObject);
  private
    { Private declarations }
    tfs:TFormatSettings;
    FMonitoring:boolean;
    FTagsCount:integer;
    procedure WriteLog(OutString: string;Memo1:TMemo=nil);
    procedure setMonitoring(const Value: boolean);
    procedure setTagsCount(const Value: integer);
    property Monitoring:boolean read FMonitoring write setMonitoring;
    property TagsCount:integer read FTagsCount write setTagsCount;
  public
    { Public declarations }
  end;

var
  MonitorForm: TMonitorForm;

implementation

{$R *.dfm}

uses ProgrammUnit,CommonUnit;

procedure TMonitorForm.NotifyServerServerConnectionEnded(ASender: TObject;
  const guid: WideString);
begin
  if ASender=NotifyServer then
  begin
    GetTagsButtonClick(self);
    WriteLOg('End with '+guid,NotifyMemo);
  end;
end;

procedure TMonitorForm.NotifyServerServerConnectionEstablished(
  ASender: TObject; const guid: WideString);
begin
  if ASender=NotifyServer then
    WriteLOg('Est with '+guid,NotifyMemo);
end;

procedure TMonitorForm.NotifyServerServerListeningStarted(Sender: TObject);
begin
  if Sender=NotifyServer then
    WriteLOg('Listening started',NotifyMemo);
end;

procedure TMonitorForm.NotifyServerServerListeningStopped(Sender: TObject);
begin
  if Sender=NotifyServer then
    WriteLOg('Listening stopped', NotifyMemo);
end;

procedure TMonitorForm.NotifyServerServerMessageReceived(ASender: TObject;
  const msg: WideString);
var   SafeArray: PSafeArray;
  TagInfo:ITagInfo;
  TagInfoArray:array of ITagInfo;
  iLow,iHigh,i,p:integer;
  inString:String;
  selTag:String;
  selRow:Integer;
begin
//  WriteLog('Notify message Received '+msg,NotifyMemo);

  inString:=msg;
  p:=pos('<',InString);
  inString:=trim(copy(InString,p,Length(inString)));

  if (inString<>'') and (pos('No Tags',inString)=0) then
  begin
    mReader.ParseXMLTagList(inString,SafeArray,false);
//    mReader.ParseTagList(inString,SafeArray);
    if SafeArray<>nil then
    begin
      SafeArrayGetLBound(SafeArray,1,iLow);
      SafeArrayGetUBound(SafeArray,1,iHigh);
      tagsCount:=iHigh-iLow+1;

      if tagsCount>0 then
      begin
        SetLength(TagInfoArray,tagsCount);
        SelTag:=StringGrid1.cells[0,StringGrid1.Row];
        SelRow:=0;
        for i:=iLow to iHigh do
        begin
          SafeArrayGetElement(SafeArray,i,TagInfo);
          TagInfoArray[i]:=TagInfo;
          StringGrid1.cells[0,i+1]:=TagInfo.TagID;
          StringGrid1.cells[1,i+1]:=HexToString(TagInfo.TagID);
          StringGrid1.cells[2,i+1]:=TagInfo.DiscoveryTime;
          StringGrid1.cells[3,i+1]:=TagInfo.LastSeenTime;
          StringGrid1.cells[4,i+1]:=IntToStr(TagInfo.Antenna);
          StringGrid1.cells[5,i+1]:=IntToStr(TagInfo.ReadCount);
          if TagInfo.TagID=selTag then
            SelRow:=i+1;
        end;
        if SelRow>1 then
          StringGrid1.Row:=SelRow;
      end
    end
    else
      tagsCount:=0;
  end
  else
    tagsCount:=0;


//  WriteLog('Found '+IntToStr(TagsCount)+' tag(s)',NotifyMemo);

  StringGrid1.Options:=StringGrid1.Options + [goColSizing] -[goFixedRowClick];
  MyGridSize(StringGrid1);
  application.ProcessMessages;

end;

procedure TMonitorForm.NotifyServerServerSocketError(ASender: TObject;
  const msg: WideString);
begin
  WriteLOg('Socket error '+msg);
end;

procedure TMonitorForm.ProgramTagButtonClick(Sender: TObject);
var TagId:String;
  lastMonitoring:boolean;
begin
  TagId:='';
  if StringGrid1.Row>0 then
  begin
    TagId:=StringGrid1.Cells[0, StringGrid1.Row];
  end;

  if TagId='' then
  begin
    showMessage('Please select TAG to programm it');
    exit;
  end;

  if ProgrammForm=nil then
  begin
    try
      ProgrammForm:=TProgrammForm.create(Application);
    finally

    end;
  end;
  if ProgrammForm<>nil then
  begin
    try
      lastMonitoring:=Monitoring;
      Monitoring:=false;
      SetReaderMask(TagId,0,mReader);
      ProgrammForm.mReader:=mReader;
      ProgrammForm.showmodal;
    finally
      Monitoring:=lastMonitoring;
      SetReaderMask('',0,mReader);
      ProgrammForm.free;
      ProgrammForm:=nil;
    end;
  end;
end;

procedure TMonitorForm.SetMaskButtonClick(Sender: TObject);
var Offset:integer;
    i,l:integer;
    mask,resultMask:string;
begin
  Mask:= trim(HexMaskEdit.text);
  Offset:=OffsetMaskSpinEdit.Value;
  if MaskCheckBox.checked then
    SetReaderMask(Mask,OffSet,mReader);
end;

procedure TMonitorForm.FormActivate(Sender: TObject);
begin
  Monitoring:=false;

  tfs:=tformatSettings.create(LOCALE_SYSTEM_DEFAULT);
  StringGrid1.cells[0,0]:='Tag ID';
  StringGrid1.cells[1,0]:='String Tag ID';
  StringGrid1.cells[2,0]:='Discovery Time';
  StringGrid1.cells[3,0]:='Last Seen Time';
  StringGrid1.cells[4,0]:='Antenna';
  StringGrid1.cells[5,0]:='Read Count';

  if mreader.IsConnected then
    GetTagsButtonClick(self)
  else
    TagsCount:=0;

  MyGridSize(StringGrid1);

end;

procedure TMonitorForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Monitoring:=false;
end;

procedure TMonitorForm.FormResize(Sender: TObject);
begin
  MyGridSize(StringGrid1);
end;

procedure TMonitorForm.GetTagsButtonClick(Sender: TObject);
var inString:string;
  result:boolean;
  sTagList:TStringList;
  i:integer;

  SafeArray: PSafeArray;
  TagInfo:ITagInfo;
  TagInfoArray:array of ITagInfo;
  iLow, iHigh : Integer;
  selTag:String;
  selRow:Integer;
  s:String;
begin
  WriteLog('Try to Read Tags...');
  application.ProcessMessages;
  if not mReader.IsConnected then
  begin
    WriteLog('Reader not connected. Exit');
    exit;
  end;
  mReader.TagListFormat:='Text';
  mReader.TagListFormat:='XML';
  inString:=mReader.TagList;
  if (inString<>'') and (pos('No Tags',inString)=0) then
  begin
    mReader.ParseXMLTagList(inString,SafeArray,false);
    if SafeArray<>nil then
    begin
      SafeArrayGetLBound(SafeArray,1,iLow);
      SafeArrayGetUBound(SafeArray,1,iHigh);
      tagsCount:=iHigh-iLow+1;

      if tagsCount>0 then
      begin
        SetLength(TagInfoArray,tagsCount);
        SelTag:=StringGrid1.cells[0,StringGrid1.Row];
        SelRow:=0;
        for i:=iLow to iHigh do
        begin
          SafeArrayGetElement(SafeArray,i,TagInfo);
          TagInfoArray[i]:=TagInfo;
          StringGrid1.cells[0,i+1]:=TagInfo.TagID;
          StringGrid1.cells[1,i+1]:=HexToString(TagInfo.TagID);
          StringGrid1.cells[2,i+1]:=TagInfo.DiscoveryTime;
          StringGrid1.cells[3,i+1]:=TagInfo.LastSeenTime;
          StringGrid1.cells[4,i+1]:=IntToStr(TagInfo.Antenna);
          StringGrid1.cells[5,i+1]:=IntToStr(TagInfo.ReadCount);
          if TagInfo.TagID=selTag then
            SelRow:=i+1;
        end;
        if SelRow>1 then
          StringGrid1.Row:=SelRow;
      end;
    end
    else
      tagsCount:=0;
  end
  else
    tagsCount:=0;
//  WriteLog('Found '+IntToStr(TagsCount)+' tag(s)');

  StringGrid1.Options:=StringGrid1.Options + [goColSizing] -[goFixedRowClick];
  MyGridSize(StringGrid1);
  application.ProcessMessages;
end;

procedure TMonitorForm.MaskCheckBoxClick(Sender: TObject);
begin
  if Not(TCheckBox(Sender).Checked) then
    if mReader.IsConnected then
      mReader.Mask:='00';
end;

procedure TMonitorForm.setMonitoring(const Value: boolean);
begin
  if Value then
  begin
    NotifyServer.port:=4000;
    if not(mReader.IsConnected) then
      mReader.connect;
    if mReader.IsConnected then
    begin
      mReader.NotifyAddress:=NotifyServer.notificationHost;
	  	mReader.AutoMode:= 'On';

  	  mReader.NotifyMode:= 'On';
  	  mReader.NotifyTime:= '0';
  	  mReader.NotifyTrigger:= 'Change';
	  	mReader.NotifyFormat:= 'Text';
	  	mReader.NotifyFormat:= 'XML';
  		mReader.NotifyHeader:= 'OFF';
  		mReader.AcquireMode:= 'Inventory';

  		mReader.TagListMillis:= 'On';
  		mReader.TagStreamMode:= 'OFF';
	  	mReader.TagStreamFormat:= 'Terse';
	  	mReader.TagStreamFormat:= 'XML';
	  	mReader.TagStreamFormat:= 'Text';

  		mReader.IOStreamMode:= 'OFF';
  		mReader.IOStreamFormat:= 'Terse';
    end;
    NotifyServer.StartListening;
    GetTagsButtonClick(self);
  end
  else
  begin
  	mReader.AutoMode:= 'OFF';
	  mReader.NotifyMode:= 'OFF';

    NotifyServer.StopListening;
    if not(mReader.IsConnected) then
      mReader.connect;
  end;

  FMonitoring := NotifyServer.IsListening;

  if FMonitoring then
  begin
    WriteLog('Monitoring started');
    StartMonitorButton.Caption:='Stop Monitoring';
  end
  else
  begin
    WriteLog('Monitoring stopped');
    StartMonitorButton.Caption:='Start Monitoring';
  end;
end;

procedure TMonitorForm.setTagsCount(const Value: integer);
begin
  if Value=0 then
  begin
    StringGrid1.RowCount:=2;
    StringGrid1.cells[0,1]:='';
    StringGrid1.cells[1,1]:='';
    StringGrid1.cells[2,1]:='';
    StringGrid1.cells[3,1]:='';
    StringGrid1.cells[4,1]:='';
    StringGrid1.cells[5,1]:='';
  end
  else
    StringGrid1.RowCount:=Value+1;

  MyGridSize(StringGrid1);

  LabelProgram.Visible:=false;
  ProgramTagButton.Enabled:=false;

  if (mReader.IsConnected) then
    if (Value>0) and (StringGrid1.cells[0,StringGrid1.Row]<>'') then
    begin
      LabelProgram.Visible:=false;
      ProgramTagButton.Enabled:=true;
    end
    else
    begin
      LabelProgram.Visible:=true;
      ProgramTagButton.Enabled:=false;
    end;

  Application.ProcessMessages;

  FTagsCount := Value;
end;

procedure TMonitorForm.StartMonitorButtonClick(Sender: TObject);
begin
  WriteLog('Try to '+TBitBtn(Sender).caption+'...');
  Monitoring:=not(Monitoring);
end;

procedure TMonitorForm.WriteLog(OutString:string;Memo1:TMemo=nil);
var i:integer;
begin
  if Memo1=nil then Memo1:=self.NotifyMemo;

{  if Memo1.Lines.count>=1024 then
    for i:=0 to 127 do
      try
        memo1.Lines.Delete(0);
      finally
      end;}
  Memo1.Lines.add(DateTimeToStr(now(),tfs)+'->'+OutString);
end;

procedure TMonitorForm.StringMaskEditChange(Sender: TObject);
begin
  if ActiveControl=StringMaskEdit then
    HexMaskEdit.Text:=StringToHex(StringMaskEdit.text);
end;

procedure TMonitorForm.HexMaskEditChange(Sender: TObject);
begin
  if ActiveControl=HexMaskEdit then
    StringMaskEdit.Text:=HexToString(HexMaskEdit.text);
end;

procedure TMonitorForm.HexMaskEditKeyPress(Sender: TObject; var Key: Char);
begin
  Key:=ValidHexKey(Key);
end;

end.
