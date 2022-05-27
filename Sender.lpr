program Sender;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  forms, MainForm,formsett
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.ShowMainForm:= False;
  Application.CreateForm(TSettForm, SettForm);
  Application.CreateForm(TSenderForm, SenderForm);
  Application.Run;
end.

