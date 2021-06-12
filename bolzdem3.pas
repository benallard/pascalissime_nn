(* 001 bolzdem3 *)
(* 30 jul 92 *)

{ complet: 300 cycles, 30 18, 27 20 sur 30. Difference 1.65 }
{ entree/sortie: 300 cycles, 26 23, 29, 27 sur 30. Difference 0.84 }

(*$r+*)
program reseau_neuronal_bolzman;
uses crt;
const k_entree_max = 2;
      k_sortie_max = 2;
      k_cache_max = 1;
      k_exemplaire_max = 4;
      k_neurone_max = k_entree_max + k_sortie_max + k_cache_max;

      (* -- architecture complete ou entree / sortie *)
      k_architecture_complet_ou_entree_sortie = True;

      k_pallier_recuit_max = 4;
      k_coefficient_apprentissage = 0.3;

      k_cycles_apprentissage = 300;
      k_cycles_co_occurences_apprentissage = 5;
      k_cycles_verification = 30;
      k_saute_random = 70;
      k_periodicite_affichage = 300;
type t_un_exemple = array [1..k_entree_max + k_sortie_max] of 0..1;
     t_exemplaire = array [1..k_exemplaire_max] of t_un_exemple;

     t_neurone = record
                   valeur_sortie: Integer;
                   poids: array[1..k_neurone_max] of real;
                 end;

     t_pallier_de_recuit = record
                             temperature: Integer;
                             iteration: Integer;
                           end;
     t_programme_de_recuit = array [1..k_pallier_recuit_max] of t_pallier_de_recuit;

     t_co_occurence = array[1..k_neurone_max, 1..k_neurone_max] of real;

const k_exemplaire: t_exemplaire = 
        ((1,1,0, 1),
         (0, 1, 1, 1),
         (1, 0, 0, 1),
         (0, 0, 1, 0));


      vi_programme_de_recuit: t_programme_de_recuit = 
        ((temperature: 20; iteration: 1),
         (temperature: 10; iteration: 2),
         (temperature: 5; iteration: 4),
         (temperature: 1; iteration: 10));
      { autre essai: (20, 2), (13, 2), (9, 4), (7, 10); }
var g_choix: Char;

    g_reseau: array[1..k_neurone_max] of t_neurone;
    g_co_occurence_fige, g_co_occurence_libre: t_co_occurence;

    g_niveau: Integer;
    g_energie_moyenne, g_difference_moyenne: Real;

(*$i iaffbolz *)

begin
end.