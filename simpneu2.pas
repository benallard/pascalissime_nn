(* simpneu2 *)
(* 12 oct 93*)

(*$r+*)
program simplexe_reseaux_neuronaux;
uses crt,
    uclavier, uerreur;

{
const k_variable_max = 3;
      k_contrainte_max = 3;

type t_vecteur_objectif = array[1..k_variable_max] of real;
     t_contraintes = array[1..k_constrainte_max, 1..k_variable_max + 1] of real;

const vi_objectif: t_vecteur_objectif = (3, 1, 2);
      vi_contraintes: t_contraintes = 
        ((3, -2, 4, -8),
         (-1, -2, -1, 9),
         (-2, 1, 0, 6));

(* ok *)
const k_tau = 0.51;
      k_mu = 0.05;

(* oscille fort sur 1 et 3 voisins
const k_tau = 0.51;
      k_mu = 0.5;
*)
}

const k_variable_max = 4;
      k_contrainte_max = 3;

type t_vecteur_objectif = array[1..k_variable_max] of real;
     t_contraintes = array[1..k_contrainte_max, 1..k_variable_max + 1] of real;

const vi_objectif: t_vecteur_objectif = (4, 5, 9, 11);
      vi_contraintes: t_contraintes = 
        ((1, 1, 1, 1, -15),
         (7, 5, 3, 2, -120),
         (3, 5, 10, 15, -100));
(* ok
const k_tau = 0.1;
      k_mu = 0.05;
*)

begin
  
end.