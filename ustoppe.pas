unit ustoppe;
interface
procedure stoppe;
procedure sonne;

implementation
uses Crt;

procedure stoppe;
var l_stop: char;
begin
  l_stop := readkey;
end;

procedure sonne;
begin
  write(chr(7));
end;

begin
end.
