unit MainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Menus, CheckLst, xmailer,formsett ;

type

  { TSenderForm }

  TSenderForm = class(TForm)
    b_snd: TButton;
    b_cnc: TButton;
    clb_tags: TCheckListBox;
    e_cpt: TEdit;
    l_cpt: TLabel;
    l_tags: TLabel;
    l_txt: TLabel;
    mi1: TMenuItem;
    mi2: TMenuItem;
    m_txt: TMemo;
    pm1: TPopupMenu;
    ti1: TTrayIcon;
    procedure b_cncClick(Sender: TObject);
    procedure b_sndClick(Sender: TObject);
    procedure clb_tagsClickCheck(Sender: TObject);
    procedure clb_tagsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);
    procedure mi1Click(Sender: TObject);
    procedure mi2Click(Sender: TObject);
    procedure m_txtEditingDone(Sender: TObject);
    procedure m_txtKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ti1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

const spliter = '|';

var
  SenderForm: TSenderForm;
  Mail: TSendMail;

implementation

{$R *.lfm}

{ TSenderForm }

procedure TagsAddNew(tag:string);
begin
   if(length(tag)>0)then
    with SenderForm.clb_tags.items do
     if(IndexOf(tag)<0)then Add(tag);
end;

procedure Tags2SettStr;
var i:integer;
  str:string;
begin
   str:='';
   with SenderForm.clb_tags.Items do
    if(Count>0)then
    begin
       for i:=0 to Count-1 do
        if(length(str)=0)
        then str:=Strings[i]
        else str+=spliter+Strings[i];
    end;
   SettForm.e_tags.text:=str;
end;

procedure TagsStr2CLB(str:string);
var sl,
    i  :integer;
    tag:string;
begin
   SenderForm.clb_tags.Clear;
   sl:=length(str);
   while(sl>0)do
   begin
      i:=pos(spliter,str);
      if(i>0)then
      begin
         tag:=copy(str,1,i-1);
         delete(str,1,i);
      end
      else
      begin
         tag:=str;
         delete(str,1,sl);
      end;
      sl:=length(str);

      if(length(tag)>0)then TagsAddNew(tag);
   end;
   Tags2SettStr;
end;

function TagExtract(tag:string):string;
var u:integer;
begin
   TagExtract:='';

   if(length(tag)<2)then exit;
   if(tag[1]<>'#')then exit;
   if(tag[2]in[' ',spliter,'0'..'9'])then exit;

   delete(tag,1,1);
   u:=pos(' '    ,tag);if(u>0)then delete(tag,u,length(tag)-u+1);
   u:=pos(spliter,tag);if(u>0)then delete(tag,u,length(tag)-u+1);

   TagExtract:=tag;
end;

procedure TagsScanText;
var i:integer;
function ProcTag(tag:string):boolean;
var u:integer;
begin
   ProcTag:=false;

   tag:=TagExtract(tag);
   if(length(tag)=0)then exit;

   ProcTag:=true;

   TagsAddNew(tag);
   u:=SenderForm.clb_tags.Items.IndexOf(tag);
   if(u>-1)then SenderForm.clb_tags.Checked[u]:=True;
end;
begin
   with SenderForm.clb_tags do
    if(Count>0)then
     for i:=0 to Count-1 do Checked[i]:=false;

   with SenderForm.m_txt.lines do
    if(Count>0)then
     for i:=Count-1 downto 0 do
      if(not ProcTag(strings[i]))then
       if(length(trim(strings[i]))>0)then break;

   Tags2SettStr;
end;

procedure TagsFromCheckBoxesToText;
var i,r:integer;
begin
   r:=0;
   with SenderForm.m_txt.lines do
   begin
      if(Count>0)then
       for i:=Count-1 downto 0 do
        if(length(TagExtract(strings[i]))>0)
        then r+=1
        else
         if(length(trim(strings[i]))>0)
         then break
         else r+=1;
      while(r>0)do
      begin
         r-=1;
         Delete(Count-1);
      end;
   end;
   with SenderForm.clb_tags do
    if(Count>0)then
    begin
       SenderForm.m_txt.lines.Add('');
       for i:=0 to Count-1 do
        if(Checked[i])then SenderForm.m_txt.lines.Add('#'+items.Strings[i]);
    end;

   Tags2SettStr;
end;

procedure TSenderForm.FormShow(Sender: TObject);
begin
   e_cpt.SetFocus;
   {if(0<FormSett.winx)and(FormSett.winx<(Monitor.Width-FormSett.winw))and(0<FormSett.winy)and(FormSett.winy<(Monitor.Height-FormSett.winh))then
   begin }
      Left  :=FormSett.winx;
      Top   :=FormSett.winy;
      Width :=FormSett.winw;
      Height:=FormSett.winh;
   {end;
   else
   begin
      SenderForm.Position:=poScreenCenter;
      FormSett.winx:=Left;
      FormSett.winy:=Top;
      FormSett.winw:=Width;
      FormSett.winh:=Height;
   end; }
   TagsStr2CLB(SettForm.e_tags.text);
end;

procedure TSenderForm.FormWindowStateChange(Sender: TObject);
begin
   case WindowState of
     //wsNormal   : SenderForm.res;
     //wsMaximized: Application.Title := 'Maximized';
     wsMinimized: SenderForm.hide;
   end;
end;

procedure TSenderForm.mi1Click(Sender: TObject);
begin
   settform.show;
end;

procedure TSenderForm.mi2Click(Sender: TObject);
begin
   Application.Terminate;
end;

procedure TSenderForm.m_txtEditingDone(Sender: TObject);
begin
   if(SettForm.cb_scantags.Checked)then
   begin
      TagsScanText;
      TagsFromCheckBoxesToText;
   end;
end;

procedure TSenderForm.m_txtKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if (ssCtrl in Shift) and (Key = 13) then
   begin
      b_sndClick(sender);
      key:=0;
   end;
end;

procedure TSenderForm.ti1Click(Sender: TObject);
begin
   SenderForm.show;
   SenderForm.WindowState:=wsNormal;
end;

procedure TSenderForm.b_cncClick(Sender: TObject);
begin
   SenderForm.hide;
end;

procedure TSenderForm.b_sndClick(Sender: TObject);
begin
  // if(SettForm.m_rcvs.Text='')then
   try
     try
       Mail.Sender := SettForm.e_sndr.text; //'<active80@ipsedix.ru>';
       Mail.Receivers.Clear;
       Mail.Receivers.text:=SettForm.e_rcsv.text;
       Mail.Subject := e_cpt.text;
       Mail.Message.Clear;
       Mail.Message.text:=m_txt.Lines.text;
       // SMTP
       Mail.Smtp.UserName := SettForm.e_usr.text;
       Mail.Smtp.Password := SettForm.e_pswd.text;
       Mail.Smtp.Host := SettForm.e_host.text;//'82.146.47.110';
       Mail.Smtp.Port := SettForm.e_port.text;
       Mail.Smtp.SSL  := SettForm.cb_ssl.Checked;
       Mail.Smtp.TLS  := SettForm.cb_tls.Checked;
       Mail.Send;
     except
       on E: Exception do ShowMessage(E.Message);
     end;
   finally
     //Mail.Free;
   end;
   SenderForm.hide;
end;

procedure TSenderForm.clb_tagsClickCheck(Sender: TObject);
begin
   TagsFromCheckBoxesToText;
end;

procedure TSenderForm.clb_tagsMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   if(Button=mbRight)then
   begin
      SenderForm.clb_tags.DeleteSelected;
      TagsFromCheckBoxesToText;
   end;
end;

procedure TSenderForm.FormActivate(Sender: TObject);
begin
   TagsStr2CLB(SettForm.e_tags.text);
end;

procedure TSenderForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
   SenderForm.hide;
   CloseAction:=caNone;
end;

procedure TSenderForm.FormCreate(Sender: TObject);
begin
   Mail  :=TSendMail.Create;
   Left  :=FormSett.winx;
   Top   :=FormSett.winy;
   Width :=FormSett.winw;
   Height:=FormSett.winh;

   Constraints.MinHeight:=376;
   Constraints.MinWidth :=200;
end;

procedure TSenderForm.FormHide(Sender: TObject);
begin
   e_cpt.Text:='';
   m_txt.Lines.text:='';

   FormSett.winx:=Left;
   FormSett.winy:=Top;
   FormSett.winw:=Width;
   FormSett.winh:=Height;
end;

procedure TSenderForm.FormKeyPress(Sender: TObject; var Key: char);
begin
   if(key=#27)then
   begin
      key:=#0;
      SenderForm.hide;
      exit;
   end;
end;


end.

