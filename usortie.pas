UNIT usortie;
interface
var g_sortie : record
                  sortie: text;
                end;
procedure choisis_sortie;
procedure ferme_sortie;
implementation
procedure choisis_sortie;
  begin
  
  end;
procedure ferme_sortie;
  begin
    Close(g_sortie.sortie)
  end;
begin
  Assign(g_sortie.sortie, 'sortie');
  Rewrite(g_sortie.sortie);
end.