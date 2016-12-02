unit MyLib;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type Tcharbuf= array [0..$ffff] of char;
     TSetOfChar=set of char;


const Delimiters = [' ',',','.',':',';','!','?','$','#','^','%','@','*','(',')','-','+','=','/','\','|','"','&', #09];


function fun_SetNull(a,b: byte): byte; //Установить ноль в заданный бит
function fun_SetOne(a,b: byte): byte; //Установить единицу в заданный бит
function fun_ReadStr(r: string): string; // Чтение строки из файла
function fun_FileMaximum(r: string): string; // Поиск максимального из двух чисел в файле
function fun_InputMaximum(r: string): string; // Поиск максимального из двух чисел введенных с клавиатуры
function fun_PKruga(t: string): string;  // Определение площади круга
function fun_PKvadrata(t: string): string; // Определение площади квадрата
function fun_Count (value:string):string; // Подсчет единичных битов числа (n<=16)
function fun_FindMax(s:string):string;  // Поиска максимального значения в строке
function fun_Podschet(s: string): string; //Поиск символа в строке
function fun_StrFFbyNum (n:integer):string; // Чтение строки из файла по номеру строки
function fun_RFTSL(n: string): tstringlist;  // Считывание файла целиком в СтрингЛист, возвращает строки!
function fun_RFTFS(n: string; var cb:tcharbuf; var nr: word): boolean; //Функция возвращает кол-во байт в файле (считывания файла целиком в буфер)
function fun_StrFromFile (s:string; n:integer):string; // Функция чтения определенной строки из файла (имя файла, номер строки): содержание
function fun_StrFromText(filename: string;n:integer): string; //Получение строки из большого текста
function fun_ModPos ( Ch:TsetOfChar; st:string): integer; // Модифицированная функция POS
function fun_ParsStr(st: string): tstringlist;  //Разбор строки на элементы массива 
function fun_Binary(num: integer): string; // Функция вывода введенного числа в бинарном виде
function fun_GetWordByNum(st: string; n: integer): string; //Взять из строки элемент по номеру 





implementation

{Взять из строки элемент по номеру}
function fun_GetWordByNum(st: string; n: integer): string;
begin
   result:= fun_ParsStr(st)[n-1];
end;


{Функция вывода введенного числа в бинарном виде}
function fun_Binary(num: integer): string;
  var i, j, k : integer;
  t1, t2, t3 : string;
begin
  t2 := '';
  t3 := '0';
  i := num;
  while i <> 0 do
  begin
    j := i mod 2;
    str(j,t1);
    t2 := concat(t1, t2);
    i := i div 2
  end;
  k := 8 - length(t2);
  if k <> 0 then
    for i := 1 to k do
      t2 := concat(t3, t2);
  fun_binary := t2;
end;



{Разбор строки на элементы массива}
function fun_ParsStr(st: string): tstringlist;
var SL:TStringList; p:byte; S:string;
begin
  SL:=TStringList.Create;
  SL.Clear;
  while (length(st) > 0) and (st[1] in Delimiters) do
      Delete (st,1,1);
  if length (st) = 0 then exit;

  p:= fun_ModPos (Delimiters, st);
  while p > 0 do
    begin
     S:= copy (st, 1, p-1);
     Delete (st, 1, p);
     while (length(st) > 0) and (st[1] in Delimiters) do
       Delete (st,1,1);
     SL.Add(S);
     p:= fun_ModPos (Delimiters, st);
    end;
    if length (st) > 0 then
       SL.Add(st);
  result:=SL;
 end;


{Модифицированная функция POS}
function fun_ModPos ( Ch:TsetOfChar; st:string): integer;
var i:integer;
begin
   result:=0;
   for i:=1 to length(st) do
   begin
      if st[i] in Ch then
        begin
        result:=i;
        exit;
        end;
   end;
end;


 {Считывание файла целиком в СтрингЛист}       //возвращает строки из файла
  function fun_RFTSL(n: string): tstringlist;
  var sl:TStringList;
 begin
    sl:=TstringList.Create;
    sl.LoadFromFile(n);
    result:= sl;
end;


{Функция считывания файла целиком в буфер}    // возвращает байты из файла
function fun_RFTFS(n: string; var cb:tcharbuf; var nr: word): boolean;      //объявляем тип после uses (наш буфер в виде массива )  type Tcharbuf= array [0..$ffff] of char;
var fs: TFileStream;
begin
     fs:= TFileStream.Create(n, fmOpenRead);     // подобно Assign где n - файл который открываем, а fmOpenRead - режим "только чтение"
     nr:= fs.Size;				 // размер/кол-во байт в файле
     fs.Read(cb, nr);
     fs.Free;					 // освобождаем переменную
     result:= true;
end; 
 {procedure TForm1.ReadFileBtnClick(Sender: TObject);
var cbuf: tCharBuf; rnum, i: word;
begin

  if fun_RFTFS ('input.txt', cbuf, rnum)  then
    begin
      for i:=0 to rnum-1 do
        memo.Text:= memo.Text + cbuf[i];
    end;
end;}



{Установить ноль в заданный бит}
function fun_SetNull(a,b: byte): byte;
var V:byte;
begin
  V:= a and (255-(1 shl (b-1)));
  result:= v;
end;


{Установить единицу в заданный бит}
function fun_SetOne(a,b: byte): byte;
var V:byte;
 begin
   V:= a or (1 shl (b-1));
   result:= v;
end;

{Максимальное значение числа в строке, введенного через пробел}
function fun_FindMax(s: string): string; // начало функции findMS
var p: integer; // объявляем локальные переменные функции
    mxs, m: longint;
    tmpValue:string;
begin
  //  посчитать кол-во пробелов в строке S
  //  записать их в l
  //  перебрать все элементы в строке s и найти максимальный
  //  максимальный вернуть в  качестве результата

  mxs:=0;  // присваиваем максимальному значению 0

  repeat  //оператор цикла с постусловием
   begin
     p:= pos (' ', s); //ищу пробел в строке S
      if p<>0 then  // если пробел не равен 0, выполняем копирование значения
             begin
                  tmpValue:=copy (s, 1, p-1); // коприруем до пробела в переменную tmpValue
                  m:= strtoint (tmpValue);    // меняем тип
             end
          else
             begin
                  if length(s)>0 then m:=strtoint(s);
             end;
            if m>mxs then mxs:=m;
          delete (s, 1, p);  // удаляем пробел из строки s
   end
  until (p<=0);  // условие "пока не"... пока пробел не < или = нулю

  result:=inttostr(mxs);  // результат переводим из числа в строку и запоминаем в mxs

end;


{Чтение строки из файла}
function fun_ReadStr(r: string): string;
var f:text;
begin
  Assignfile (f, r); //имя файла, от куда читаем
  reset (f);
  readln (f, r);   //переменная, в которую записываем, что прочли из файла
  closefile (f);
  result:= r;
end;

Procedure Swap(var a, b: Integer);
 Var T: Integer;
 Begin
   T := a; a := b; b := T
 End;


{Ищем большее из двух чисел в файле и выводим только его}
function fun_FileMaximum(r: string): string;
var f:text; st,a1,b1:string; a,b:integer; p:byte;
begin
  Assignfile (f, 'input.txt'); //имя файла, от куда читаем
  reset (f);
  readln (f, st);   //переменная, в которую записываем, что прочли из файла
  closefile (f);
  p:= pos (' ', st);
  a1:= copy (st, 1, p-1);
  b1:= copy (st, p+1, length(st)-(p));
  a:= strtoint(a1);
  b:= strtoint(b1);
  if a>=b then r:=inttostr(a) else r:=inttostr(b); //ищем бОльшее из двух чисел
                                                   //в файле.
  result:= r;                                      //Выводим только его
end;


{Ищем большее из двух чисел с клавиатуры через пробел и выводим только его}
function fun_InputMaximum(r: string): string;
var v,a1,b1:string; a,b:integer; p:byte;
begin
  p:= pos (' ', r);
  a1:= copy (r, 1, p-1);
  b1:= copy (r, p+1, length(r)-(p));
  a:= strtoint(a1);
  b:= strtoint(b1);
  if a>=b then v:=inttostr(a) else v:=inttostr(b); //ищем бОльшее из двух чисел
                                                   //в файле.
  result:= v;                                      //Выводим только его
end;


{Ploshad kruga}
function fun_PKruga(t: string): string;   //Функция расчета площади круга при вводе радиусса
                                      //с клавиатуры
var R:integer; Skr:real;
const Pi:real=3.14;
begin
   R:= strtoint(t);
   Skr:= Pi*R*R;
   result:= FloatToStr(skr);
end;


{Ploshad kvadrata}
function fun_PKvadrata(t: string): string;
var Skv:integer;
begin
  Skv:= strtoint(t);
  result:= inttostr(Skv*Skv);
end;


{Дано натуральное число меньше 16. Посчитать количество его единичных битов}
 function fun_Count (value:string):string;
 var n, count:integer;
 begin
   count:=0;
   n:= strtoint (value);
   count := count + n mod 2;
   n := n div 2;
   count := count + n mod 2;
   n := n div 2;
   count := count + n mod 2;
   n := n div 2;
   count := count + n;
   result:= inttostr(count);
 end;

{Функция считает, сколько раз в строке встречается то или иное число/та или иная буква}
function fun_Podschet(s: string): string;
var i,k: byte;
begin
   k:=0;
   for i:=1 to length(s) do
   if (s[i] = '3') then		//поменять на искомый символ !!!
      begin
           inc(k);
      end;
    result:=inttostr(k);
end;

{Функция чтения определенной (по номеру с клавиатуры) строки из файла}
function fun_StrFFbyNum (n:integer):string;
var f:text; i:integer; st:string;
begin
  Assignfile (f, 'input.txt'); 
  reset (f);
  for i := 1 to n do readln(f, st);
  closefile (f);
  result:= st
end;

{Функция чтения определенной строки из файла (имя файла, номер строки): содержание}
function fun_StrFromFile (s:string; n:integer):string; 
var f:text; i:integer;
begin
  Assignfile (f, s);
  reset (f);
  for i := 1 to n do readln(f, s);
  closefile (f);
  result:= s;
end;

{Получение строки из большого текста}
function fun_StrFromText(filename: string;n:integer): string;
  var sl:TStringList;
 begin
    sl:=TstringList.Create;
    sl.LoadFromFile(filename);
    result:=sl[n];
end;




end.

