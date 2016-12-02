{Формула Харриса-Бенедикта (ВОО на основе общей массы тела)}
unit u_calculator;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Menus, ActnList, ExtCtrls, ComCtrls, mylib, LCLType;

type

  { TForm1 }

  TProduct = record
     Name          : string;
     Root          : integer;
     Checked       : boolean;
     Ves           : integer;
     KKalIn100Gram : single;
     KKalValue     : single; //число с плавающей точкой (4 байта), double - 8 байт
  end;

  TForm1 = class(TForm)
    ClrScrBtn: TButton;
    ImageList1: TImageList;
    Label10: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    SaveD: TSaveDialog;
    SumcalLb: TLabel;
    SaveToFileBtn: TButton;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    SexRG: TRadioGroup;
    GetResultBtn: TButton;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Label1: TLabel;
    Memo: TMemo;
    TreeView1: TTreeView;
    procedure ClrScrBtnClick(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GetResultBtnClick(Sender: TObject);
    procedure MemoChange(Sender: TObject);
    procedure SaveToFileBtnClick(Sender: TObject);
    procedure TreeView1Click(Sender: TObject);
    procedure TreeView1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);

  private
    { private declarations }
  public
    { public declarations }
  end;

const
  db_filename = 'produkts_db.txt';

function fMan(activ: integer): real;
function fWoman(activ: integer): real;

var
  Form1 : TForm1;
  st2   : integer;
  st1   : string;
  grams : array[0..100] of integer;

  ProduktRoots  : array[0..100] of string;
  ProduktArray  : array[0..1500] of TProduct;
  ProduktCount  : integer;
  GroupCalSum   : array[0..100] of single;
  voz, ves, rost: real;
  snorm         : real;
  mX, mY        : integer;  //переменные для позиционирования мыши
implementation
function fMan(activ: integer): real;

begin
  result:= 66+(13.7*ves)+(5*rost)-(6.8*voz);
  case  activ of
  1: result:= result*1.2;
  2: result:= result*1.375;
  3: result:= result*1.55;
  4: result:= result*1.725;
  5: result:= result*1.9;
  end;

end;

function fWoman(activ: integer): real;

begin
   result:= 655+(9.6*ves)+(1.8*rost)-(4.7*voz);
  case  activ of
  1: result:= result*1.2;
  2: result:= result*1.375;
  3: result:= result*1.55;
  4: result:= result*1.725;
  5: result:= result*1.9;
  end;
end;

{$R *.lfm}

{ TForm1 }

procedure TForm1.Edit1Change(Sender: TObject);
begin
  if (Edit1.Text >'') and (Edit2.text>'') and (edit3.text>'') then
    GetResultBtn.Enabled:=true else GetResultBtn.Enabled:=false;
end;

procedure TForm1.FormCreate(Sender: TObject);
var sl,nodesl  : tstringlist;
    ss,s1      : string;
    rootidx,i  : integer;
    p          : byte;
    troot,tnode: TTreeNode;
begin
    Edit1.TextHint := 'Полных лет';
    Edit2.TextHint := 'Точный вес вводится через ","';
    Edit3.TextHint := 'Точный рост вводится через ","';
    sl:=TStringList.Create;
    try
    sl.LoadFromFile(db_filename);

     rootidx:=0;
     ProduktCount:=0;

     for i:=0 to sl.count-1 do
        begin
        ss:=sl[i];
        if pos('#',ss)=0 then
           begin
           if pos('[',ss)>0 then
              begin
              ProduktRoots[rootidx]:=ss;
              Troot:=TreeView1.Items.Add(nil, ss);
              inc(rootidx);
              end
           else
              begin
              p:=pos(':',ss);
              s1:=copy(ss,1,p-1);
              delete(ss,1,p);

              nodesl:=fun_ParsStr(ss);

              ProduktArray[ProduktCount].Name:=s1;
              ProduktArray[ProduktCount].Checked:=false;
              ProduktArray[ProduktCount].Root:=rootidx-1;
              ProduktArray[ProduktCount].KKalIn100Gram:= strtoint(nodesl[0]);
              ProduktArray[ProduktCount].KKalValue:=0;

              tnode:=TreeView1.Items.AddChild(troot, s1);
              tnode.ImageIndex:=0;
              tnode.SelectedIndex:=0;
              tnode.Data:=Pointer(ProduktCount);
              inc(ProduktCount);
              end;
           end;
        end;
    sl.free;
    except
      ShowMessage('Поздравляю! Ты похерил файл с продуктами. Ходи голодный!');
    end;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
      if (Key = VK_ESCAPE) then Form1.Close;
end;


procedure TForm1.GetResultBtnClick(Sender: TObject);
begin
  try
  voz:= (strtofloat (edit1.text));
  ves:= (strtofloat (edit2.text));
  rost:=(strtofloat (edit3.text));
  if SexRG.ItemIndex=0 then snorm:= fMan(ComboBox1.ItemIndex)
  else snorm:= fWoman (ComboBox1.ItemIndex);
  memo.Append('Кагбэ норма: ' +floattostrf(snorm,fffixed,10,2)+ ' кал./сут.');
  memo.Append('Но для "смело раздеться на пляже" нужно: ' +floattostrf(snorm-(snorm*0.2),fffixed,10,2)+ ' кал./сут.');
  except
    ShowMessage('И шо это мы давим на всё подряд, а?!');
  end;
end;

procedure TForm1.MemoChange(Sender: TObject);
begin
  if (memo.Text >'') then
    SaveToFileBtn.Enabled:=true else SaveToFileBtn.Enabled:=false;
end;

procedure TForm1.SaveToFileBtnClick(Sender: TObject);
var f:text;
begin
  saveD.FileName:='жиротест_'+datetostr(date)+'.txt';
  // Give the dialog a title
  saveD.Title := 'Сохранение файла в *.txt';
  // Установка начального каталога
  saveD.InitialDir := GetCurrentDir;
  // Разрешаем сохранять файлы типа .txt и .doc
  saveD.Filter := 'Text|*.txt|Word|*.doc|Все файлы|*.*';
  // Установка расширения по умолчанию
  saveD.DefaultExt := 'txt';
  // Выбор текстовых файлов как стартовый тип фильтра
  saveD.FilterIndex := 1;
  // Отображение диалог сохранения файла
  if saveD.Execute
  then
    begin
      if FileExists(saveD.FileName) then
    begin
     assignfile (f, saveD.FileName);
     Append (f);
    end else
    begin
      assignfile (f, saveD.FileName);
      Rewrite (f);
    end;
        writeln(f, timetostr(time)+'  '+datetostr(date));
        writeln(f, '===============================================');
        writeln(f, 'Исходя из данных:');
        writeln(f, 'Пол - ',SexRG.Items[SexRG.ItemIndex]);
        WriteLn(f, 'Возраст - ', floattostrf(voz,fffixed,2,0));
        WriteLn(f, 'Рост - ', floattostrf(rost,fffixed,7,1),' см.');
        WriteLn(f, 'Вес - ', floattostrf(ves,fffixed,7,1),' кг.');
        WriteLn(f, 'Активность - ', ComboBox1.Items[ComboBox1.ItemIndex]);
        write(f, memo.Text);
        closefile (f);
  end else
      ShowMessage('Правильно, лучше забыть эти цифры!');
end;

procedure TForm1.TreeView1Click(Sender: TObject);
var ss     : string;
    pidx,i : integer;
    sum    : single;
    curNode: TTreeNode;
begin
  if TreeView1.Selected = nil then exit;
  if TreeView1.Selected.Parent = nil then exit;

  curNode:= TreeView1.GetNodeAt(mX,mY);
  if curNode.Parent = nil then exit;

  pidx:=integer(TreeView1.Selected.Data);

  if TreeView1.Selected.ImageIndex=1 then
     begin
      TreeView1.Selected.ImageIndex:=0;
      TreeView1.Selected.SelectedIndex:=0;
      TreeView1.Selected.Text:=ProduktArray[pidx].Name;
      ProduktArray[pidx].Checked:=false;
     end
   else
     begin
       try
       TreeView1.Selected.ImageIndex:=1;
       TreeView1.Selected.SelectedIndex:=1;
       ProduktArray[pidx].Checked:=true;

       ss:=IntToStr(ProduktArray[pidx].Ves);

       ss:=inputBox('','Чиркани вес в граммах',ss);
       ProduktArray[pidx].Ves:=StrToInt(ss);
       ProduktArray[pidx].KKalValue:=ProduktArray[pidx].Ves*ProduktArray[pidx].KKalIn100Gram/100;
       TreeView1.Selected.Text:=ProduktArray[pidx].Name+' [ '+ss+' г. = '+floattostrf (ProduktArray[pidx].KKalValue,fffixed,7,1) +' кал. ]';
       except
          ShowMessage('И чё мы давим на все подряд?!');
       end;
     end;
    sum:=0;
   // Обнуляем индексы суммы калорий по группам продуктов
    for i:=0 to 100 do
       GroupCalSum[i]:=0;
   // Считаем калории выбранных продуктов и записываем в GroupCalSum
    for i:=0 to ProduktCount - 1 do
       if ProduktArray[i].Checked then
         begin
         GroupCalSum[ProduktArray[i].Root]:= GroupCalSum[ProduktArray[i].Root]+ ProduktArray[i].KKalValue;
         sum:= sum+ProduktArray[i].KKalValue;
         end;
   // Выводим общую сумму калорий по всем группам продуктов
    SumcalLb.Caption:=(floattostrf(sum,fffixed,7,2));
   // Пробегаемся по дереву и выводим калории напротив каждой коренной группы
     pidx:=0;
    for i:=0 to TreeView1.Items.Count -1 do
       begin
         if pos (ProduktRoots[pidx], TreeView1.Items[i].Text) > 0 then
           begin
             if GroupCalSum[pidx] >0 then
               TreeView1.Items[i].Text:=ProduktRoots[pidx]+'   < '+floattostrf (GroupCalSum[pidx],fffixed,7,1) +' кал. >'
             else
               TreeView1.Items[i].Text:=ProduktRoots[pidx];
            inc(pidx);
           end;
       end;

    // Проверяем, не превышает ли сумма калорий разового приема пищи суточной нормы калорий
    if (snorm <> 0) then
      if (strtofloat(SumcalLb.Caption)) > (snorm-(snorm*0.2)) then
        Memo.Append('Хо-хо! Это не "алинклюзив", чтоб набирать жратвы на '+SumcalLb.Caption+' калорий! Хоть для тебя это будет сложно, но отсыпь до нормы.');
end;

procedure TForm1.TreeView1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  mX := X;
  mY := Y;

end;


procedure TForm1.ClrScrBtnClick(Sender: TObject);
var sl,nodesl  : tstringlist;
    ss,s1      : string;
    rootidx,i  : integer;
    p          : byte;
    troot,tnode: TTreeNode;
begin
   memo.Text:='';
   Edit1.Text:='';
   Edit2.Text:='';
   Edit3.Text:='';
   SaveToFileBtn.Enabled:=false;
   ComboBox1.ItemIndex:=0;
   TreeView1.Items.Clear;
   SumcalLb.Caption:='0 калорий';

   sl:=TStringList.Create;;
   sl.LoadFromFile(db_filename);

     rootidx:=0;
     ProduktCount:=0;

     for i:=0 to sl.count-1 do
        begin
        ss:=sl[i];
        if pos('#',ss)=0 then
           begin
           if pos('[',ss)>0 then
              begin
              ProduktRoots[rootidx]:=ss;
              Troot:=TreeView1.Items.Add(nil, ss);
              inc(rootidx);
              end
           else
              begin
              p:=pos(':',ss);
              s1:=copy(ss,1,p-1);
              delete(ss,1,p);

              nodesl:=fun_ParsStr(ss);

              ProduktArray[ProduktCount].Name:=s1;
              ProduktArray[ProduktCount].Checked:=false;
              ProduktArray[ProduktCount].Root:=rootidx-1;
              ProduktArray[ProduktCount].KKalIn100Gram:= strtoint(nodesl[0]);
              ProduktArray[ProduktCount].KKalValue:=0;

              tnode:=TreeView1.Items.AddChild(troot, s1);
              tnode.ImageIndex:=0;
              tnode.SelectedIndex:=0;
              tnode.Data:=Pointer(ProduktCount);
              inc(ProduktCount);
              end;
           end;
        end;
    sl.free;
end;

end.

