unit CommonUnit;


interface

uses Grids, AlienRFID2_TLB;

function HexToString(H: String): String;
function StringToHex(S: String): string;
function ValidHexKey(AKey:Char):Char;
procedure MyGridSize(Grid: TStringGrid);
procedure SetReaderMask(AMask:String; AOffset:Integer; AmReader:TclsReader);

implementation
uses StrUtils,SysUtils;

function HexToString(H: String): String;
var I: Integer;
begin
  Result:= '';
  H:=ReplaceStr(H,' ','');
  for I := 1 to length (H) div 2 do
    Result:= Result+Char(StrToInt('$'+Copy(H,(I-1)*2+1,2)));
end;

function StringToHex(S: String): string;
var I: Integer;
begin
  Result:= '';
  for I := 1 to length (S) do
    Result:= Result+IntToHex(ord(S[i]),2);
end;

procedure MyGridSize(Grid: TStringGrid);
const
  DEFBORDER = 10;
var
  temp, n,m: Integer;
  lmax: array [0..30] of Integer;
  cmax:Integer;
  k:real;
begin
  cmax:=0;
  with Grid do
  begin
    Canvas.Font := Font;
    for n := 0 to ColCount - 1 do
      lmax[n] := Canvas.TextWidth(Grid.cells[n,0]) + DEFBORDER;
    for m := 1 to RowCount - 1 do
    begin
      for n := 0 to ColCount - 1 do
      begin
        temp := Canvas.TextWidth(trim(Grid.cells[n,m])) + DEFBORDER;
        if temp > lmax[n] then lmax[n] := temp;
      end; {for}
    end;
    for n := 0 to ColCount - 1 do
      if lmax[n] > 0 then
        cmax:=cmax+lmax[n];
    k:=Grid.Width/cmax;
    for n := 0 to ColCount - 1 do
      if lmax[n] > 0 then
        ColWidths[n] := trunc(lmax[n]*k);
  end;
end;

procedure SetReaderMask(AMask:String; AOffset:Integer; AmReader:TclsReader);
var Offset:integer;
    i,l:integer;
    resultMask:string;
begin
  if AmReader.IsConnected then
  begin
    if AMask='' then
      AmReader.Mask:='00'
    else
    begin
      AMask:=ReplaceStr(AMask,' ','');
      resultMask:='';
      for I := 1 to length (AMask) div 2 do
        resultMask:= resultMask+Copy(AMask,(I-1)*2+1,2)+' ';
      resultMask:=trim(resultMask);
      l:=length(AMask);
      l:=(l div 2)*8;
      Offset:=32+AOffset*8;
      AmReader.SetAcqG2Mask(IntToStr(eG2Bank_EPC),IntToStr(Offset),IntToStr(l),resultMask);
    end;
  end;
end;

function ValidHexKey(AKey:Char):Char;
begin
  Akey:=UpCase(AKey);
  Result:=AKey;
  if not (AKey in ['0'..'9','A'..'F',#8]) then Result:=chr(0);
end;

end.
