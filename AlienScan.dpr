program AlienScan;

uses
  Vcl.Forms,
  MainUnit in 'MainUnit.pas' {MainForm},
  MonitorUnit in 'MonitorUnit.pas' {MonitorForm},
  ProgrammUnit in 'ProgrammUnit.pas' {ProgrammForm},
  CommonUnit in 'CommonUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
