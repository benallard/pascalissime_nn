UNIT usortie;
interface
var g_sortie : record
                  sortie: text;
                  nom_sortie: String;
                end;
procedure choisis_sortie;
procedure ferme_sortie;
implementation
procedure choisis_sortie;
  begin
    WriteLn('Only stdout supported.');
  end;

procedure ferme_sortie;
  begin
    Close(g_sortie.sortie)
  end;

begin
  with g_sortie do
  begin
    Assign(sortie, '');
    nom_sortie := 'Con';
    Rewrite(sortie);
    SetTextLineEnding(sortie, #13#10);
  end;
end.