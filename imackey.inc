(* 001 imackey *)
(* 12 mar 95 *)


const k_mackey_max = 50;
{
const k_mackey_max = 17;
}
var g_mackey: array[0..k_mackey_max-1] of Real;
    g_indice_mackey: Integer;

procedure initialise_mackey;
  var l_indice: Integer;
  begin
    for l_indice := 0 to k_mackey_max-1 do
{
      g_mackey[l_indice] := 0.1;
}
      g_mackey[l_indice] := 0.6 + 0.02 * l_indice * 1;

    g_indice_mackey := 0;
  end; (* initialise_mackey *)

function f_mackey: Real;
  var l_valeur: Real;
      l_mackey_0: Real;
      l_puissance: Real;
      l_indice_suivant: Integer;
      l_terme_1, l_terme_2: Real;
      l_exposant: Integer;
  begin
    l_mackey_0 := g_mackey[g_indice_mackey];

    l_puissance := l_mackey_0;
    for l_exposant := 1 to 9 do
      l_puissance := l_puissance * l_mackey_0;
    l_indice_suivant := (g_indice_mackey + 1) mod k_mackey_max;

    l_terme_1 :=  l_mackey_0 / (1 + l_puissance);
    l_terme_2 := g_mackey[l_indice_suivant];

    l_valeur := 0.9 * l_terme_1 + 0.1 * l_terme_2;

    g_mackey[g_indice_mackey] := l_valeur;
    g_indice_mackey := l_indice_suivant;

    f_mackey := l_valeur;
  end; (* f_mackey *)

procedure saute_mackey(p_nombre: Integer);
  var l_indice: Integer;
      l_valeur: Real;
  begin
    for l_indice := 1 to p_nombre do
      l_valeur := f_mackey;
  end; (* saute_mackey *)

procedure affiche_mackey;
  var l_indice: Integer;
  begin
    initialise_mackey;

    for l_indice := 0 to 2000 do
    begin
      Write(l_indice: 3, ' ');
      WriteLn(f_mackey: 10: 7, ' ');
    end;
  end; (* affiche_mackey *)

(* -- imackey *)