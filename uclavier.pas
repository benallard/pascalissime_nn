unit uclavier;

interface

procedure lis_touche(VAR pv_touche:char);

implementation
uses Crt;

procedure lis_touche(VAR pv_touche:char);
begin
  pv_touche:=readkey;
end;

end.