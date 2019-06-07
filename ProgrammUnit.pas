unit ProgrammUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.OleServer, AlienRFID2_TLB,
  Vcl.ExtCtrls, Vcl.StdCtrls, ActiveX, Vcl.ComCtrls, Vcl.Buttons;

type
  TProgrammForm = class(TForm)
    mReader: TclsReader;
    Timer1: TTimer;
    GroupBox1: TGroupBox;
    TagIdEdit: TEdit;
    EPCEdit: TEdit;
    ErrorReadingLabel: TLabel;
    EPCStringEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ProgrammingGroupBox: TGroupBox;
    AntennaRadioGroup: TRadioGroup;
    GroupBox3: TGroupBox;
    TrackBar1: TTrackBar;
    AntennaPowerLabel: TLabel;
    VersionLabel: TLabel;
    TypeLabel: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    EPCWriteEdit: TEdit;
    EPCStringWriteEdit: TEdit;
    WriteButton: TBitBtn;
    ErrorWritingLabel: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure EPCEditChange(Sender: TObject);
    procedure EPCWriteEditChange(Sender: TObject);
    procedure EPCStringWriteEditChange(Sender: TObject);
    procedure EPCWriteEditKeyPress(Sender: TObject; var Key: Char);
    procedure TrackBar1Change(Sender: TObject);
    procedure WriteButtonClick(Sender: TObject);
  private
    { Private declarations }
    FProgrammMode:boolean;
    procedure RefreshControls;
    procedure setProgrammMode(const Value: boolean);
    procedure verifyTag;
    procedure GetTagList;
  public
    { Public declarations }
    property ProgrammMode:boolean read FProgrammMode write setProgrammMode;
  end;

var
  ProgrammForm: TProgrammForm;

implementation

{$R *.dfm}

uses CommonUnit, StrUtils;

procedure TProgrammForm.EPCEditChange(Sender: TObject);
begin
  if ActiveControl=EPCEdit then
    EPCStringEdit.Text:=HexToString(EPCEdit.text);
end;

procedure TProgrammForm.EPCStringWriteEditChange(Sender: TObject);
begin
  if ActiveControl=EPCStringWriteEdit then
    EPCWriteEdit.Text:=StringToHex(EPCStringWriteEdit.text);
end;

procedure TProgrammForm.EPCWriteEditChange(Sender: TObject);
begin
  if ActiveControl=EPCWriteEdit then
    EPCStringWriteEdit.Text:=HexToString(EPCWriteEdit.text);
end;

procedure TProgrammForm.EPCWriteEditKeyPress(Sender: TObject; var Key: Char);
begin
  Key:=ValidHexKey(Key);
end;

procedure TProgrammForm.FormActivate(Sender: TObject);
begin
  if mReader.IsConnected then
  begin
    ProgrammMode:=true;
    VerifyTag;
    RefreshControls;
    EPCWriteEdit.Text:=EPCEdit.Text;
  end;
end;

procedure TProgrammForm.RefreshControls;
var readerVersion,readerType:String;
  SafeArray: PSafeArray;
  Antenna:boolean;
  iLow, iHigh : Integer;
  AntCount:integer;
  i:integer;
  progAntenna:WideString;
  antennaPower:Integer;
begin
  if not(mReader.isConnected) then
  begin
    VersionLabel.Caption:='Reader not connected';
    VersionLabel.Visible:=true;
    TypeLabel.Visible:=false;
    ProgrammingGroupBox.Enabled:=false;
    exit;
  end;
  ProgrammingGroupBox.Enabled:=true;

  readerVersion:=mReader.ReaderVersion;
  readerType:=mReader.ReaderType;

  VersionLabel.Caption:=readerVersion;
  VersionLabel.Visible:=true;
  TypeLabel.Caption:=readerType;
  TypeLabel.Visible:=true;

  SafeArray:=mReader.GetAllAntennaStatus;
  if SafeArray<>nil then
  begin
    SafeArrayGetLBound(SafeArray,1,iLow);
    SafeArrayGetUBound(SafeArray,1,iHigh);
    AntCount:=iHigh-iLow+1;
    AntennaRadioGroup.Items.Clear;

    for i:=0 to AntCount-1 do
    begin
      SafeArrayGetElement(SafeArray,i,Antenna);
      if Antenna then
        if (mReader.IsAntennaConnected(IntToStr(i))) then
          AntennaRadioGroup.Items.add(IntToStr(i));
    end;
  end;

  progAntenna:=mReader.ProgAntenna;
  try
    AntennaRadioGroup.ItemIndex:=StrToInt(progAntenna);
  except
    AntennaRadioGroup.ItemIndex:=-1;
  end;

  antennaPower:= mReader.GetAntennaPower(progAntenna);

  AntennaPowerLabel.Caption:='RF Power '+IntToStr(antennaPower)+' %';
  trackBar1.Position:=antennaPower;

end;

procedure TProgrammForm.setProgrammMode(const Value: boolean);
begin
  if not(mReader.IsConnected) then exit;
  if Value then
  begin
    mReader.Function_:='Programmer';
    Timer1.Enabled:=true;
  end
  else
  begin
    mReader.Function_:='Reader';
    Timer1.Enabled:=false;
  end;

  FProgrammMode := Value;
end;

procedure TProgrammForm.Timer1Timer(Sender: TObject);
begin
  VerifyTag;
end;

procedure TProgrammForm.TrackBar1Change(Sender: TObject);
var Antenna:String;
    antennaPower:Integer;
begin
  if ActiveControl=TrackBar1 then
  begin
    Antenna:=AntennaRadioGroup.Items[AntennaRadioGroup.ItemIndex];
    mReader.SetAntennaPower(Antenna, TrackBar1.Position);
    antennaPower:= mReader.GetAntennaPower(Antenna);
    AntennaPowerLabel.Caption:='RF Power '+IntToStr(antennaPower)+' %';
    trackBar1.Position:=antennaPower;
  end;
end;

procedure TProgrammForm.verifyTag;
var tagResponse,TagID, TagInfo:String;
    len:Integer;
begin
  try
    tagResponse:=mReader.G2Read(eG2Bank_EPC, '2', '6');
    len:=Length(tagResponse);
    if (len >= 35) then
      tagID:=copy(tagResponse,1,36)
    else
      tagID:=copy(tagResponse,1,24);

    TagIDEdit.Text:=trim(tagID);
    GetTagList;
    ErrorReadingLabel.Caption:='';
	except
    on ex:Exception do
    begin
      TagIDEdit.Text:='';
      ErrorReadingLabel.Caption:=ex.Message;
    end;
  end;
end;

procedure TProgrammForm.WriteButtonClick(Sender: TObject);
var data:String;
    i:integer;
    resultData:String;
    status:String;
begin
  data:=EPCWriteEdit.text;
  data:=ReplaceStr(data,' ','');
  resultData:='';
  for I := 1 to length (data) div 2 do
    resultData:= resultData+Copy(data,(I-1)*2+1,2)+' ';
  resultData:=trim(resultData);
  status:='';
 	try
	  status:= mReader.ProgramTag(resultData);
  except
    on E:Exception do status:=e.Message;
  end;
  ErrorWritingLabel.Caption:=status;
  ErrorWritingLabel.visible:=true;
end;

procedure TProgrammForm.GetTagList;
var inString:string;
  result:boolean;
  sTagList:TStringList;
  i:integer;

  SafeArray: PSafeArray;
  TagInfo:ITagInfo;
  TagInfoArray:array of ITagInfo;
  iLow, iHigh : Integer;
  tagsCount:integer;
  s:String;
begin
  if not mReader.IsConnected then
  begin
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
      i:=0;
      if tagsCount>0 then
      begin
        SafeArrayGetElement(SafeArray,i,TagInfo);
        EPCEdit.Text:=trim(TagInfo.TagID);
        EPCStringEdit.Text:=HexToString(EPCEdit.text);
        if tagsCount>1 then
          ErrorReadingLabel.Caption:='Plase leave only ONE tag near antenna';
      end;
      WriteButton.enabled:=tagsCount=1;
    end;
  end;
  application.ProcessMessages;
end;
end.
