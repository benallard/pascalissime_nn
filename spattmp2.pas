(* 001 spattmp2 *)
(* 24 jan 94 *)

(*$r+*)
program reseau_spatio_temporel;
uses crt,
     uerreur;
const k_taille_mot = 5;
      k_mot: String[k_taille_mot] = 'ABCDE';
      k_neurone_max = k_taille_mot;
type t_cumul = array[1..k_neurone_max] of Real;
     t_neurone = record
                  cumul_neurones_precedents : t_cumul;
                  reliquat_activite_precedente : t_cumul;
                  poids: Char;
                  sortie: t_cumul;
                 end;
     t_reseau = record
                  couche: array[1..k_neurone_max] of t_neurone;
                end;
var g_reseau: t_reseau;

procedure initialise_reseau;
  (* -- place dans chaque neurone la lettre qu'il doit connaitre *)
  var l_neurone: Word;
  begin
    FillChar(g_reseau, SizeOf(g_reseau), 0);

    for l_neurone := 1 to k_neurone_max do
      g_reseau.couche[l_neurone].poids := k_mot[l_neurone];
  end;

const k_propage_neurone = 0.30;
      k_decroissance_temps = 5.00;
      k_amplification = 2.0;

      k_seuil = 0.1;

function f_produit(p_lettre_1, p_lettre_2: Char): Real;
  begin
    if p_lettre_1 = p_lettre_2
      then f_produit := 1
      else f_produit := 0;
  end; (* f_produit *)
  
procedure calcule_activite(p_lettre:Char);
  var l_neurone, l_neurone_suivant: Word;
      l_temps: Word;
      l_activite: Real;
  begin
    for l_neurone := 1 to k_neurone_max do
      with g_reseau.couche[l_neurone] do
      begin
        (* -- met a zero les cumuls des neurones precedents *)
        FillChar(cumul_neurones_precedents, SizeOf(cumul_neurones_precedents), 0);
        
        (* -- le reliquat du resultat du temps precedent *)
        for l_temps := 1 to k_neurone_max do
          reliquat_activite_precedente[l_temps] := k_decroissance_temps * sortie[l_temps];
      end;
    
    for l_neurone := 1 to k_neurone_max do
      with g_reseau.couche[l_neurone] do
      begin
        (* -- l'activite provenant du caractere en entree *)
        l_activite := f_produit(poids, p_lettre);
        (* -- plus l'activite des neurones precedents *)
        for l_temps := 1 to k_neurone_max do
          l_activite := l_activite + cumul_neurones_precedents[l_temps];

        if l_activite > k_seuil
          then begin
            for l_temps := 1 to k_neurone_max do
            begin
              if l_temps = l_neurone 
                then sortie[l_temps] := k_amplification * (f_produit(poids, p_lettre)
                  + cumul_neurones_precedents[l_temps])
                else sortie[l_temps] := k_amplification * cumul_neurones_precedents[l_temps];
            end;
          end
          else FillChar(sortie, SizeOf(sortie), 0);

        (* -- plus la remanence de l'activite precedente *)
        for l_temps := 1 to k_neurone_max do
          sortie[l_temps] := sortie[l_temps] + reliquat_activite_precedente[l_temps];
        
        (* -- propage ce resultat sur les neurones qui suivent *)
        for l_neurone_suivant := l_neurone + 1 to k_neurone_max do
          for l_temps := 1 to k_neurone_max do
            g_reseau.couche[l_neurone_suivant].cumul_neurones_precedents[l_temps] :=
              g_reseau.couche[l_neurone_suivant].cumul_neurones_precedents[l_temps]
               + k_propage_neurone * sortie[l_temps];
      end;
  end; (* calcule_activite *)

const k_titre = 10;
      k_colonnes = 10;
      k_ligne = 5;

      k_neurone_precedent = 15;
      k_temps_precedent = 35;
      k_sortie = 55;

procedure affiche_sortie(p_mot: String; p_lettre: Word);
  var l_neurone, l_temps: Integer;
      l_total: Real;
      l_indice: Integer;
  begin
    for l_indice := -5 to 5 do
    begin
      GotoXY(3, 14 + l_indice);
      if (l_indice + p_lettre >= 1) and (l_indice + p_lettre <= k_taille_mot)
        then begin
            Write(p_mot[l_indice + p_lettre]);
          end
        else Write(' ');
    end;
    GotoXY(5, 14); Write('->');

    for l_neurone := 1 to k_neurone_max do
    begin
      GotoXY(k_neurone_precedent - 2, (l_neurone-1) * (k_neurone_max) + k_neurone_max - 2);
      Write(k_mot[l_neurone]);
      GotoXY(k_neurone_precedent - 2, (l_neurone-1) * (k_neurone_max) + k_neurone_max);
      Write('___');
    end;

    for l_neurone := 1 to k_neurone_max do
      with g_reseau.couche[l_neurone] do
      begin
        l_total := 0;
        for l_temps := 1 to k_neurone_max do
        begin
          GotoXY(k_temps_precedent, (l_neurone-1) * (k_neurone_max) + l_temps);
          Write(cumul_neurones_precedents[l_temps]:8:2);
          l_total := l_total + cumul_neurones_precedents[l_temps];
        end;
        Write(l_total:9:2);

        l_total := 0;
        for l_temps := 1 to k_neurone_max do
        begin
          GotoXY(k_temps_precedent, (l_neurone-1) * (k_neurone_max) + l_temps);
          Write(reliquat_activite_precedente[l_temps]:8:2);
          l_total := l_total + reliquat_activite_precedente[l_temps];
        end;
        Write(l_total:9:2);

        l_total := 0;
        for l_temps := 1 to k_neurone_max do
        begin
          GotoXY(k_sortie, (l_neurone-1) * (k_neurone_max) + l_temps);
          Write(sortie[l_temps]:8:2);
          l_total := l_total + sortie[l_temps];
        end;
        Write(l_total:9:2);
      end;
  end; (* affiche_sortie *)

procedure go(p_mot: String);
  var l_lettre: Integer;
  begin
    initialise_reseau;
    ClrScr;
    WriteLn('neu prec: '); WriteLn(k_propage_neurone:7:2);
    WriteLn('tps prec:'); WriteLn(k_decroissance_temps:7:2);
    WriteLn('amplifie:'); WriteLn(k_amplification:7:2);

    for l_lettre := 1 to Length(p_mot) do
    begin
      calcule_activite(p_mot[l_lettre]);
      affiche_sortie(p_mot, l_lettre);
      
      stoppe;

    end;
    stoppe;
    GotoXY(1, 22);
  end;

var g_choix: Char;

begin
  repeat
    WriteLn;
    Write('Normal, Debut, Fin, ');
    Write('Quitte ? ');
    g_choix := UpCase(ReadKey);WriteLn(g_choix);
    case g_choix of
      ' ': ClrScr;
      'N': go(k_mot);
      'D': go('BACDE');
      'F': go('ABCED');
    end;
  until g_choix = 'Q';
end.