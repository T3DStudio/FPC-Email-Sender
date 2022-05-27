unit formsett;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TSettForm }

  TSettForm = class(TForm)
    b_sv: TButton;
    b_rd: TButton;
    cb_ssl: TCheckBox;
    cb_tls: TCheckBox;
    cb_scantags: TCheckBox;
    e_tags: TEdit;
    e_host: TEdit;
    e_port: TEdit;
    e_sndr: TEdit;
    e_rcsv: TEdit;
    e_usr: TEdit;
    e_pswd: TEdit;
    l_tags: TLabel;
    l_host: TLabel;
    l_port: TLabel;
    l_usr: TLabel;
    l_rcvs: TLabel;
    l_sndr: TLabel;
    l_pswd: TLabel;
    procedure b_rdClick(Sender: TObject);
    procedure b_svClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private
    { private declarations }
  public
    { public declarations }
   // procedure SetWXYWH(x,y,w,h:integer);
  end;

const b2pm  : array[false..true] of char = ('-','+');
      cfgfn = 'settings.ini';

cfg_str_sender   = 'sender';
cfg_str_receiver = 'receiver';
cfg_str_user     = 'user';
cfg_str_pass     = 'pass';
cfg_str_host     = 'host';
cfg_str_port     = 'port';
cfg_str_ssl      = 'ssl';
cfg_str_tls      = 'tls';
cfg_str_x        = 'x';
cfg_str_y        = 'y';
cfg_str_w        = 'w';
cfg_str_h        = 'h';
cfg_str_tags     = 'tags';
cfg_str_stags    = 'scan_tags';

var
  SettForm: TSettForm;

  winx,winy,winw,winh: integer;


implementation

{$R *.lfm}

{ TSettForm }

function s2i(str:string):integer;var t:integer;begin val(str,s2i,t);end;

function str2bool(s:string):boolean;
begin
   str2bool:=false;
   case LowerCase(s) of
'+',
'y','yes',
'true',
'1'     : str2bool:=true;
   else
     if(s2i(s)>0)then str2bool:=true;
   end;
end;

procedure cfg_setval(vr,vl:string);
var vlb:integer;
begin
   vlb:=s2i(vl);
   case vr of
cfg_str_sender   : settform.e_sndr.text := vl;
cfg_str_receiver : settform.e_rcsv.text := vl;
cfg_str_user     : settform.e_usr .text := vl;
cfg_str_pass     : settform.e_pswd.text := vl;
cfg_str_host     : settform.e_host.text := vl;
cfg_str_port     : settform.e_port.text := vl;
cfg_str_ssl      : settform.cb_ssl.Checked :=str2bool(vl);
cfg_str_tls      : settform.cb_tls.Checked :=str2bool(vl);
cfg_str_x        : winx := vlb;
cfg_str_y        : winy := vlb;
cfg_str_w        : winw := vlb;
cfg_str_h        : winh := vlb;
cfg_str_tags     : settform.e_tags.text := vl;
cfg_str_stags    : settform.cb_scantags.Checked :=str2bool(vl);
   end;
end;

procedure cfg_parse_str(s:string);
var vr,vl:string;
    i:byte;
begin
   vr:='';
   vl:='';
   i :=pos('=',s);
   if(i>0)then
   begin
      vl:=trim(copy(s,1,i-1));
      delete(s,1,i);
      vr:=trim(s);
   end;
   cfg_setval(vl,vr);
end;

procedure cfg_read;
var f:text;
    s:string;
begin
   if FileExists(cfgfn) then
   begin
      assign(f,cfgfn);
      {$I-}reset(f);{$I+}
      if(ioresult<>0)then exit;
      while not eof(f) do
      begin
         readln(f,s);
         cfg_parse_str(s);
      end;
      close(f);
   end;
end;

procedure cfg_write;
var f:text;
begin
   assign(f,cfgfn);
   {$I-}rewrite(f);{$I+}
   if(ioresult<>0)then exit;

   writeln(f,cfg_str_sender   ,'=',settform.e_sndr.text);
   writeln(f,cfg_str_receiver ,'=',settform.e_rcsv.text);
   writeln(f,cfg_str_user     ,'=',settform.e_usr .text);
   writeln(f,cfg_str_pass     ,'=',settform.e_pswd.text);
   writeln(f,cfg_str_host     ,'=',settform.e_host.text);
   writeln(f,cfg_str_port     ,'=',settform.e_port.text);
   writeln(f,cfg_str_ssl      ,'=',b2pm[settform.cb_ssl.Checked]);
   writeln(f,cfg_str_tls      ,'=',b2pm[settform.cb_tls.Checked]);
   writeln(f,cfg_str_x        ,'=',winx);
   writeln(f,cfg_str_y        ,'=',winy);
   writeln(f,cfg_str_w        ,'=',winw);
   writeln(f,cfg_str_h        ,'=',winh);
   writeln(f,cfg_str_tags     ,'=',settform.e_tags.text);
   writeln(f,cfg_str_stags    ,'=',b2pm[settform.cb_scantags.Checked]);
   close(f);
end;


procedure TSettForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
   SettForm.hide;
   CloseAction:=caNone;
end;

procedure TSettForm.b_svClick(Sender: TObject);
begin
   cfg_write;
   SettForm.hide;
end;
procedure TSettForm.b_rdClick(Sender: TObject);
begin
   cfg_read;
end;

procedure TSettForm.FormCreate(Sender: TObject);
begin
   winx:=-1;
   winy:=-1;
   winw:=320;
   winh:=233;

   SettForm.Position:=poScreenCenter;
   cfg_read;
end;

procedure TSettForm.FormDestroy(Sender: TObject);
begin
  cfg_write;
end;

procedure TSettForm.FormShow(Sender: TObject);
begin
   SettForm.Position:=poScreenCenter;
end;

end.

