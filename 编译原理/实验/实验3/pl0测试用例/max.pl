(*�����������������*)

procedure p;
var a,b,c,m;
begin
  read(a,b,c);
  m:=a;
  if a<b then m:=b;
  if m<c then m:=c;
  write(m)
end;
begin
 call p
end.