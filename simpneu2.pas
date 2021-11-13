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
const k_tau = 0.5;
      k_mu = 0.01;

const k_repetition_max = 250;
      k_stoppe = False;

type t_neurone_1 = record
                     entree: Real;
                     poids: array[1..k_variable_max + 1] of Real;
                     resultat: Real;
                   end;
     t_couche_1 = array[1..k_contrainte_max] of t_neurone_1;

     t_neurone_2 = record
                     biais: Real;
                     poids: array[1..k_contrainte_max] of Real;
                     resultat: Real;
                   end;
     t_couche_2 = array[1..k_variable_max] of t_neurone_2;

var g_couche_1: t_couche_1;
    g_couche_2: t_couche_2;
    g_affiche: Boolean;

(* -- le reseau neuronal *)

const k_x_neurone_2 = 30;
      k_y_0_neurone_2 = 3;
      k_y_neurone_2 = (24 - k_y_0_neurone_2) div k_variable_max;

      k_x_neurone_1 = 10;
      k_y_0_neurone_1 = 5;
      k_y_neurone_1 = (24 - k_y_0_neurone_1) div k_contrainte_max;

procedure propage;

  procedure affiche_entree;
    var l_neurone_2: Integer;
    begin
      for l_neurone_2 := 1 to k_variable_max do
      begin
        GotoXY(1, k_y_0_neurone_2 + k_y_neurone_2 * (l_neurone_2 - 1));
        Write(g_couche_2[l_neurone_2].resultat:5:2);
      end;
    end;

  function f_valeur_objectif: Real;
    var l_neurone_2: 1..k_variable_max;
        l_resultat: Real;
    begin
      l_resultat := 0;
      for l_neurone_2 := 1 to k_variable_max do
        l_resultat := l_resultat + vi_objectif[l_neurone_2] * g_couche_2[l_neurone_2].resultat;
      f_valeur_objectif := l_resultat;
    end; (* f_valeur_objectif *)
    
  procedure initialise_depart;
    var l_indice: 1..k_variable_max;
    begin
      for l_indice := 1 to k_variable_max do
        g_couche_2[l_indice].resultat := 0;
    end; (* initialise_depart *)

  procedure propage_1;
    var l_neurone_1, l_variable: Integer;
    begin
      if g_affiche
        then affiche_entree;

      (* pour chaque neurone *)
      for l_neurone_1 := 1 to k_contrainte_max do
        with g_couche_1[l_neurone_1] do
        begin
          (* -- calcule l'activation *)

          (* -- le biais, egal au membre droit des contraintes *)
          resultat := poids[k_variable_max + 1];

          (* -- la somme ponderee des entrees (les sorties de l'iteration precedente) *)
          for l_variable := 1 to k_variable_max do
            resultat := resultat + poids[l_variable] * g_couche_2[l_variable].resultat;

          if g_affiche
            then begin
              GotoXY(k_x_neurone_1, k_y_0_neurone_1 + k_y_neurone_1 * (l_neurone_1 - 1));
              Write(resultat:6:2);
              if resultat > 0
                then Write(' -> 0');
            end;

          (* -- la fonction de transfert *)
          if resultat > 0
            then resultat := 0
            else resultat := k_tau * resultat;
        end; (* for *)
    end; (* propage_1 *)

  procedure propage_2;
    var l_neurone_2, l_contrainte: Integer;
        l_resultat: Real;
    begin
      (* pour chaque neurone *)
      for l_neurone_2 := 1 to k_variable_max do
        with g_couche_2[l_neurone_2] do
        begin
          (* -- calcule l'activation *)

          (* -- le biais, egal au coefficient de la fonction objectif *)
          resultat := biais;

          (* -- la somme ponderee des entrees (les sorties de l'iteration precedente) *)
          for l_contrainte := 1 to k_contrainte_max do
            resultat := resultat + poids[l_contrainte] * g_couche_1[l_contrainte].resultat;

          (* Xn+1 = Xn - mu * resultat *)
          resultat := resultat - k_mu * resultat;

          if g_affiche
            then begin
              GotoXY(k_x_neurone_2, k_y_0_neurone_2 + k_y_neurone_2 * (l_neurone_2 - 1));
              Write(resultat:6:2);
              if resultat <0
                then Write(' -> 0');
            end;
  
          (* -- rester dans le premier quadrant *)
          if resultat < 0
            then resultat := 0;
        end; (* for *)
    end; (* propage_2 *)

  procedure affiche_resultat(p_repetition: Word);
    var l_variable: Integer;
    begin
      for l_variable := 1 to k_variable_max do
        with g_couche_2[l_variable] do
        begin
          if not g_affiche
            then Write(resultat:15:2);
        end;
    end; (* affiche_resultat *)

  var l_repetition: Integer;
      l_choix: Char;

  begin (* propage *)
    if g_affiche
      then ClrScr;
    WriteLn('<q> pour quitter ');

    initialise_depart;
    affiche_resultat(0);

    l_repetition := 1;

    repeat
      if g_affiche
        then begin
          GotoXY(1, 1);
          ClrEol;
          Write('iteration: ', l_repetition: 3, ', valeur objectif: ', f_valeur_objectif:8:2);
        end;

      propage_1;
      propage_2;
      affiche_resultat(l_repetition);

      if k_stoppe
        then lis_touche(l_choix)
        else l_choix := 'c';

      Inc(l_repetition);
    until (l_choix = 'q') or (l_repetition > k_repetition_max);

    if g_affiche
      then GotoXY(1, 22);
  end; (* propage *)

procedure initialise;
  var l_neurone_1, l_variable: Integer;
      l_neurone_2, l_contrainte: Integer;
  begin
    for l_neurone_1 := 1 to k_contrainte_max do
      with g_couche_1[l_neurone_1] do
        for l_variable := 1 to k_variable_max + 1 do
          poids[l_variable] := vi_contraintes[l_neurone_1, l_variable];

    for l_neurone_2 := 1 to k_variable_max do
      with g_couche_2[l_neurone_2] do
      begin
        biais := vi_objectif[l_neurone_2];
        for l_contrainte := 1 to k_contrainte_max do
          poids[l_contrainte] := vi_contraintes[l_contrainte, l_neurone_2];
      end;
    
    g_affiche := True;
  end;

var g_choix: Char;

begin (* main *)
  initialise;

  repeat
    WriteLn;

    Write('Propage, Quitte ?');
    g_choix := ReadKey; WriteLn(g_choix);
    case g_choix of
      ' ': ClrScr;
      'p': propage;
    end;
  until g_choix = 'q';
end. (* main *)