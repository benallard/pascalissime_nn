(* 001 spattemp *)
(* 22 jan 94 *)

(*$r+*)
program reseau_spatio_temporel;
uses Crt,
     uerreur;
const k_taille_mot = 5;
      k_mot: String[k_taille_mot] = 'ABCDE';
      k_neurone_max = k_taille_mot;
type t_neurone = record
                   poids: Char;
                   cumul_neurones_precedents: REal;
                   reliquat_activite_precedente: Real;
                   activite: Real;
                   sortie: Real;
                 end;
     t_reseau = record
                 couche: array[1..k_neurone_max] of t_neurone;
                end;
var g_reseau: t_reseau;

procedure initialise_reseau;
  (* -- place dans chaque neurone la lettre qu'il doit reconnaitre *)
  var l_neurone: Word;
  begin
    FillChar(g_reseau, SizeOf(g_reseau), 0);

    for l_neurone := 1 to k_neurone_max do
      g_reseau.couche[l_neurone].poids := k_mot[l_neurone];
  end; (* initialise_reseau *)

const k_propage_neurone= 0.1;
      k_decroissance_temps = 0.3;
      k_amplification = 1.1;

      k_seuil = 0.1;

function f_produit(p_lettre_1, p_lettre_2: Char): Real;
  begin
    if p_lettre_1 = p_lettre_2
      then f_produit := 1
      else f_produit := 0;
  end; (* f_produit *)

procedure calcule_activite(p_lettre: Char);
  var l_neurone, l_neurone_suivant: Word;
  begin
    (* -- met a zero les cumuls des neurones precedents *)
    for l_neurone := 1 to k_neurone_max do
        g_reseau.couche[l_neurone].cumul_neurones_precedents := 0.0;

    for l_neurone := 1 to k_neurone_max do
    with g_reseau.couche[l_neurone] do
      begin
        (* -- l'activite provenant du caractere en entree *)    
        activite := f_produit(poids, p_lettre);
        (* -- plus l'activite des neurones precedents *)
        activite := activite + cumul_neurones_precedents;

        if activite > k_seuil
          then activite := activite * k_amplification
          else activite := 0;
          
        (* -- plus la remanance de l'activite precedente *)
        sortie := activite + reliquat_activite_precedente;

        (* -- calcule la sortie en fonction de l'activite *)
        (* -- propage ce resultat sur les neurones qui suivent *)
        for l_neurone_suivant := 1 to k_neurone_max do
          with g_reseau.couche[l_neurone_suivant] do
            cumul_neurones_precedents := cumul_neurones_precedents +
                                         k_propage_neurone * sortie;

        (* -- prepare le reliquat pour le click d'horloge suivant *)
        reliquat_activite_precedente := k_decroissance_temps * sortie;
      end; (* for *)
  end; (* calcule_activite *)

const k_titre = 10;
      k_colonnes = 10;
      k_ligne = 5;

procedure affiche_sortie;
  var l_neurone: Integer;
  begin
    for l_neurone := 1 to k_neurone_max do
      with g_reseau.couche[l_neurone] do
      begin
        GotoXY(k_titre  + (l_neurone - 1) * k_colonnes, k_ligne + 1); Write(sortie:6:2);
        GotoXY(k_titre  + (l_neurone - 1) * k_colonnes, k_ligne + 2); Write(activite:6:2);
        GotoXY(k_titre  + (l_neurone - 1) * k_colonnes, k_ligne + 3); Write(cumul_neurones_precedents:6:2);
        Gotoxy(k_titre  + (l_neurone - 1) * k_colonnes, k_ligne + 4); Write(reliquat_activite_precedente:6:2);
      end;
  end; (* affiche_sortie *)

procedure go(p_mot: String);
  var l_lettre: Integer;
  begin
    initialise_reseau;
    ClrScr;
    GotoXY(1, k_ligne + 1); Write('sortie');
    GotoXY(1, k_ligne + 2); Write('activite');
    GotoXY(1, k_ligne + 3); Write('neur prec');
    GotoXY(1, k_ligne + 4); Write('act prec');

    GotoXY(3, 1);
    for l_lettre := 1 to k_taille_mot do
      begin
        GotoXY(k_titre + (l_lettre - 1) * k_colonnes + 3, k_ligne - 1);
        Write(p_mot[l_lettre]);
      end;

    for l_lettre := 1 to Length(p_mot) do
      begin
        calcule_activite(p_mot[l_lettre]);

        GotoXY(3, 1); Write(p_mot[l_lettre]);
        affiche_sortie;
        stoppe;
      end;

    GotoXY(1, 25);
  end; (* go *)

var g_choix: Char;

begin
  repeat
    WriteLn;
    Write('Normal, Debut, Fin, ');
    Write('Quitter ? ');
    g_choix := UpCase(ReadKey);WriteLn(g_choix);
    case g_choix of
      'N': go(k_mot);
      'D': go('BACDE');
      'F': go('ABCED');
    end;
  until g_choix = 'Q';
end.
