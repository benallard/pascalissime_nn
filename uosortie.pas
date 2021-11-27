unit uosortie;

interface

type t_sortie= record
                 choisis_sortie: procedure;
                 ferme_sortie: procedure;
               end;

var g_pt_sortie: ^ t_sortie;

implementation

begin
end.